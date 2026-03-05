from __future__ import annotations

import hashlib
import uuid
from datetime import datetime, timedelta, timezone

from fastapi import Request
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import Dispute, UserAccount
from app.models.auth import AuthEventLog, SessionRefreshToken
from app.models.booking import BookingRequest
from app.models.client_rewards_pricing import ShareLinkView
from app.models.gig import PaymentStatus, StripePayment
from app.models.payouts import EarningsLedgerEntry
from app.models.risk import (
    DeviceFingerprint,
    IpSignal,
    RiskAction,
    RiskActionStatus,
    RiskActionType,
    RiskEvent,
    RiskLevel,
    RiskProfile,
    RiskRule,
    SessionSignal,
)
from app.services.analytics import log_event
from app.services.auth_service import revoke_all_user_sessions

settings = get_settings()

DEFAULT_RISK_RULES: dict[str, dict] = {
    "auth.velocity_login_failures": {
        "params": {"window_minutes": 10, "max_failures": 10},
        "score_delta": 20,
        "action_on_trigger": {"actions": ["require_verification"]},
    },
    "referral.farm_suspected": {
        "params": {"window_hours": 24, "max_same_ip_claims": 8},
        "score_delta": 30,
        "action_on_trigger": {"actions": ["freeze_rewards", "manual_review"]},
    },
    "share.view_farm_suspected": {
        "params": {"window_hours": 24, "max_views_same_ip": 30, "max_seconds_viewed": 2},
        "score_delta": 30,
        "action_on_trigger": {"actions": ["disable_share_links", "freeze_rewards"]},
    },
    "booking.spam": {
        "params": {"window_hours": 24, "max_requests": 5},
        "score_delta": 20,
        "action_on_trigger": {"actions": ["throttle_bookings"]},
    },
    "payment.failure_rate": {
        "params": {"window_hours": 24, "max_failures": 3},
        "score_delta": 25,
        "action_on_trigger": {"actions": ["require_verification"]},
    },
    "payout.anomaly": {
        "params": {"within_hours_of_first_available": 1},
        "score_delta": 25,
        "action_on_trigger": {"actions": ["freeze_payouts", "manual_review"]},
    },
    "dispute.rate_high": {
        "params": {"window_days": 30, "max_disputes": 3},
        "score_delta": 20,
        "action_on_trigger": {"actions": ["manual_review"]},
    },
}


def _now() -> datetime:
    return datetime.now(timezone.utc)


def risk_hash_ip(ip: str | None) -> str | None:
    if not ip:
        return None
    return hashlib.sha256(f"{ip}|{settings.risk_ip_hash_pepper}".encode("utf-8")).hexdigest()


def risk_hash_device(device_id: str | None) -> str | None:
    if not device_id:
        return None
    return hashlib.sha256(f"{device_id}|{settings.risk_device_hash_pepper}".encode("utf-8")).hexdigest()


def risk_hash_session(session_id: str | None) -> str | None:
    if not session_id:
        return None
    return hashlib.sha256(f"{session_id}|{settings.risk_session_hash_pepper}".encode("utf-8")).hexdigest()


def ensure_default_risk_rules(db: Session) -> None:
    for rule_id, cfg in DEFAULT_RISK_RULES.items():
        row = db.get(RiskRule, rule_id)
        if row:
            continue
        db.add(
            RiskRule(
                id=rule_id,
                is_active=True,
                params=cfg["params"],
                score_delta=int(cfg["score_delta"]),
                action_on_trigger=cfg["action_on_trigger"],
            )
        )
    db.flush()


def _score_to_level(score: int) -> RiskLevel:
    if score >= 80:
        return RiskLevel.critical
    if score >= 50:
        return RiskLevel.high
    if score >= 20:
        return RiskLevel.medium
    return RiskLevel.low


def get_or_create_risk_profile(db: Session, user_id: uuid.UUID) -> RiskProfile:
    row = db.get(RiskProfile, user_id)
    if row:
        return row
    row = RiskProfile(user_id=user_id, risk_score=0, risk_level=RiskLevel.low, reasons=[], flags={})
    db.add(row)
    db.flush()
    return row


def has_active_risk_action(db: Session, *, user_id: uuid.UUID, action_type: RiskActionType) -> bool:
    row = db.execute(
        select(RiskAction).where(
            RiskAction.user_id == user_id,
            RiskAction.action_type == action_type,
            RiskAction.status == RiskActionStatus.active,
        )
    ).scalar_one_or_none()
    return row is not None


def enforce_risk_action_not_active(
    db: Session,
    *,
    user_id: uuid.UUID,
    action_type: RiskActionType,
    message: str,
    code: str = "forbidden",
) -> None:
    if has_active_risk_action(db, user_id=user_id, action_type=action_type):
        raise APIError(code=code, message=message, status_code=403)


def enforce_require_verification_if_flagged(db: Session, *, user_id: uuid.UUID) -> None:
    if not has_active_risk_action(db, user_id=user_id, action_type=RiskActionType.require_verification):
        return
    account = db.get(UserAccount, user_id)
    if not account or account.email_verified_at is None:
        raise APIError(code="verification_required", message="Additional verification is required", status_code=403)


def apply_risk_action(
    db: Session,
    *,
    user_id: uuid.UUID,
    action_type: RiskActionType,
    reason: str | None,
) -> RiskAction:
    existing = db.execute(
        select(RiskAction).where(
            RiskAction.user_id == user_id,
            RiskAction.action_type == action_type,
            RiskAction.status == RiskActionStatus.active,
        )
    ).scalar_one_or_none()
    if existing:
        return existing

    row = RiskAction(user_id=user_id, action_type=action_type, status=RiskActionStatus.active, reason=reason)
    db.add(row)
    profile = get_or_create_risk_profile(db, user_id)
    flags = dict(profile.flags or {})
    flags[action_type.value] = True
    profile.flags = flags
    profile.last_calculated_at = _now()
    log_event(
        db,
        event_name="risk.action_applied",
        user_id=user_id,
        properties={"action_type": action_type.value, "reason": reason},
    )

    if action_type == RiskActionType.force_logout:
        revoke_all_user_sessions(db, user_id)
    db.flush()
    return row


def clear_risk_action(db: Session, *, user_id: uuid.UUID, action_type: RiskActionType) -> bool:
    row = db.execute(
        select(RiskAction).where(
            RiskAction.user_id == user_id,
            RiskAction.action_type == action_type,
            RiskAction.status == RiskActionStatus.active,
        )
    ).scalar_one_or_none()
    if not row:
        return False
    row.status = RiskActionStatus.cleared
    row.cleared_at = _now()

    still_active = has_active_risk_action(db, user_id=user_id, action_type=action_type)
    profile = get_or_create_risk_profile(db, user_id)
    flags = dict(profile.flags or {})
    if not still_active and action_type.value in flags:
        flags.pop(action_type.value, None)
    profile.flags = flags
    profile.last_calculated_at = _now()
    log_event(
        db,
        event_name="risk.action_cleared",
        user_id=user_id,
        properties={"action_type": action_type.value},
    )
    db.flush()
    return True


def trigger_risk_rule(
    db: Session,
    *,
    user_id: uuid.UUID,
    rule_id: str,
    payload: dict | None = None,
) -> RiskEvent | None:
    ensure_default_risk_rules(db)
    rule = db.get(RiskRule, rule_id)
    if not rule or not rule.is_active:
        return None

    profile = get_or_create_risk_profile(db, user_id)
    delta = int(rule.score_delta)
    event = RiskEvent(user_id=user_id, rule_id=rule_id, delta=delta, payload=payload or {})
    db.add(event)

    profile.risk_score = max(0, int(profile.risk_score) + delta)
    profile.risk_level = _score_to_level(profile.risk_score)
    reasons = list(profile.reasons or [])
    if rule_id not in reasons:
        reasons.append(rule_id)
    profile.reasons = reasons
    profile.last_calculated_at = _now()

    actions = list((rule.action_on_trigger or {}).get("actions", []))
    for action_name in actions:
        try:
            action_type = RiskActionType(action_name)
        except Exception:
            continue
        apply_risk_action(db, user_id=user_id, action_type=action_type, reason=rule_id)

    log_event(
        db,
        event_name="risk.rule_triggered",
        user_id=user_id,
        properties={"rule_id": rule_id, "delta": delta, "actions": actions},
    )
    log_event(
        db,
        event_name="risk.score_changed",
        user_id=user_id,
        properties={"rule_id": rule_id, "risk_score": profile.risk_score, "risk_level": profile.risk_level.value},
    )
    db.flush()
    return event


def set_risk_score_manual(db: Session, *, user_id: uuid.UUID, score: int, note: str | None) -> RiskProfile:
    profile = get_or_create_risk_profile(db, user_id)
    profile.risk_score = max(0, int(score))
    profile.risk_level = _score_to_level(profile.risk_score)
    profile.last_calculated_at = _now()
    db.add(
        RiskEvent(
            user_id=user_id,
            rule_id="admin.manual_score",
            delta=0,
            payload={"score": profile.risk_score, "note": note},
        )
    )
    log_event(
        db,
        event_name="risk.score_changed",
        user_id=user_id,
        properties={"rule_id": "admin.manual_score", "risk_score": profile.risk_score, "risk_level": profile.risk_level.value},
    )
    db.flush()
    return profile


def capture_request_signals(
    db: Session,
    *,
    request: Request,
    user_id: uuid.UUID | None,
) -> None:
    ip_hash = risk_hash_ip(_request_ip(request))
    session_hash = risk_hash_session(request.cookies.get("rw_sid") or request.headers.get("X-Session-Id"))
    device_hash = risk_hash_device(request.headers.get("X-Device-Id"))
    now = _now()

    if ip_hash:
        row = db.execute(select(IpSignal).where(IpSignal.ip_hash == ip_hash)).scalar_one_or_none()
        if row is None:
            db.add(IpSignal(ip_hash=ip_hash, first_seen_at=now, last_seen_at=now, meta={}))
        else:
            row.last_seen_at = now

    device_id: uuid.UUID | None = None
    if device_hash:
        drow = db.execute(select(DeviceFingerprint).where(DeviceFingerprint.fingerprint_hash == device_hash)).scalar_one_or_none()
        if drow is None:
            drow = DeviceFingerprint(
                user_id=user_id,
                fingerprint_hash=device_hash,
                first_seen_at=now,
                last_seen_at=now,
                meta={
                    "platform": request.headers.get("X-Platform"),
                    "app_version": request.headers.get("X-App-Version"),
                },
            )
            db.add(drow)
            db.flush()
        else:
            drow.last_seen_at = now
            if user_id and not drow.user_id:
                drow.user_id = user_id
        device_id = drow.id

    if session_hash:
        srow = db.execute(select(SessionSignal).where(SessionSignal.session_id_hash == session_hash)).scalar_one_or_none()
        if srow is None:
            db.add(
                SessionSignal(
                    session_id_hash=session_hash,
                    user_id=user_id,
                    device_fingerprint_id=device_id,
                    ip_hash=ip_hash,
                    created_at=now,
                    last_seen_at=now,
                )
            )
        else:
            srow.last_seen_at = now
            if user_id and not srow.user_id:
                srow.user_id = user_id
            if device_id:
                srow.device_fingerprint_id = device_id
            if ip_hash:
                srow.ip_hash = ip_hash
    db.flush()


def _request_ip(request: Request) -> str | None:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None


def evaluate_login_failure_rule(db: Session, *, user_id: uuid.UUID) -> None:
    ensure_default_risk_rules(db)
    rule = db.get(RiskRule, "auth.velocity_login_failures")
    if not rule or not rule.is_active:
        return
    params = rule.params or {}
    window_minutes = int(params.get("window_minutes", 10))
    max_failures = int(params.get("max_failures", 10))
    since = _now() - timedelta(minutes=window_minutes)
    failures = db.execute(
        select(func.count())
        .select_from(AuthEventLog)
        .where(
            AuthEventLog.user_id == user_id,
            AuthEventLog.event_type == "login_failure",
            AuthEventLog.created_at >= since,
        )
    ).scalar_one()
    if int(failures) >= max_failures:
        trigger_risk_rule(
            db,
            user_id=user_id,
            rule_id="auth.velocity_login_failures",
            payload={"failures": int(failures), "window_minutes": window_minutes},
        )


def evaluate_booking_spam_rule(db: Session, *, user_id: uuid.UUID) -> None:
    ensure_default_risk_rules(db)
    rule = db.get(RiskRule, "booking.spam")
    if not rule or not rule.is_active:
        return
    params = rule.params or {}
    window_hours = int(params.get("window_hours", 24))
    max_requests = int(params.get("max_requests", 5))
    since = _now() - timedelta(hours=window_hours)
    count = db.execute(
        select(func.count())
        .select_from(BookingRequest)
        .where(BookingRequest.client_user_id == user_id, BookingRequest.created_at >= since)
    ).scalar_one()
    if int(count) > max_requests:
        trigger_risk_rule(
            db,
            user_id=user_id,
            rule_id="booking.spam",
            payload={"count": int(count), "window_hours": window_hours},
        )


def evaluate_payment_failure_rule(db: Session, *, user_id: uuid.UUID) -> None:
    ensure_default_risk_rules(db)
    rule = db.get(RiskRule, "payment.failure_rate")
    if not rule or not rule.is_active:
        return
    params = rule.params or {}
    window_hours = int(params.get("window_hours", 24))
    max_failures = int(params.get("max_failures", 3))
    since = _now() - timedelta(hours=window_hours)
    count = db.execute(
        select(func.count())
        .select_from(StripePayment)
        .where(
            StripePayment.client_user_id == user_id,
            StripePayment.status == PaymentStatus.failed,
            StripePayment.updated_at >= since,
        )
    ).scalar_one()
    if int(count) > max_failures:
        trigger_risk_rule(
            db,
            user_id=user_id,
            rule_id="payment.failure_rate",
            payload={"count": int(count), "window_hours": window_hours},
        )


def evaluate_referral_farm_rule(db: Session, *, referrer_user_id: uuid.UUID, ip_hash: str | None) -> None:
    ensure_default_risk_rules(db)
    if not ip_hash:
        return
    rule = db.get(RiskRule, "referral.farm_suspected")
    if not rule or not rule.is_active:
        return
    params = rule.params or {}
    window_hours = int(params.get("window_hours", 24))
    max_same_ip_claims = int(params.get("max_same_ip_claims", 8))
    since = _now() - timedelta(hours=window_hours)

    # Keep this DB-agnostic for sqlite tests by filtering JSON payload in Python.
    observed_rows = db.execute(
        select(RiskEvent).where(
            RiskEvent.user_id == referrer_user_id,
            RiskEvent.rule_id == "referral.claim_ip_observation",
            RiskEvent.created_at >= since,
        )
    ).scalars().all()
    observations = sum(1 for row in observed_rows if isinstance(row.payload, dict) and row.payload.get("ip_hash") == ip_hash)
    db.add(
        RiskEvent(
            user_id=referrer_user_id,
            rule_id="referral.claim_ip_observation",
            delta=0,
            payload={"ip_hash": ip_hash},
        )
    )
    if int(observations) + 1 > max_same_ip_claims:
        trigger_risk_rule(
            db,
            user_id=referrer_user_id,
            rule_id="referral.farm_suspected",
            payload={"ip_hash": ip_hash, "claims": int(observations) + 1},
        )


def evaluate_share_view_farm_rule(db: Session, *, owner_user_id: uuid.UUID, share_link_id: uuid.UUID, ip_hash: str | None) -> None:
    ensure_default_risk_rules(db)
    if not ip_hash:
        return
    rule = db.get(RiskRule, "share.view_farm_suspected")
    if not rule or not rule.is_active:
        return
    params = rule.params or {}
    window_hours = int(params.get("window_hours", 24))
    max_views_same_ip = int(params.get("max_views_same_ip", 30))
    max_seconds_viewed = int(params.get("max_seconds_viewed", 2))
    since = _now() - timedelta(hours=window_hours)
    low_engagement_views = db.execute(
        select(func.count())
        .select_from(ShareLinkView)
        .where(
            ShareLinkView.share_link_id == share_link_id,
            ShareLinkView.ip_hash == ip_hash,
            ShareLinkView.viewed_at >= since,
            ShareLinkView.seconds_viewed <= max_seconds_viewed,
        )
    ).scalar_one()
    if int(low_engagement_views) > max_views_same_ip:
        trigger_risk_rule(
            db,
            user_id=owner_user_id,
            rule_id="share.view_farm_suspected",
            payload={
                "share_link_id": str(share_link_id),
                "ip_hash": ip_hash,
                "views": int(low_engagement_views),
                "max_seconds_viewed": max_seconds_viewed,
            },
        )


def evaluate_payout_anomaly_rule(db: Session, *, pro_user_id: uuid.UUID) -> None:
    ensure_default_risk_rules(db)
    rule = db.get(RiskRule, "payout.anomaly")
    if not rule or not rule.is_active:
        return
    params = rule.params or {}
    within_hours = int(params.get("within_hours_of_first_available", 1))
    first_available = db.execute(
        select(EarningsLedgerEntry)
        .where(EarningsLedgerEntry.pro_user_id == pro_user_id)
        .order_by(EarningsLedgerEntry.available_at.asc())
        .limit(1)
    ).scalar_one_or_none()
    if not first_available:
        return
    if _now() <= (first_available.available_at + timedelta(hours=within_hours)):
        trigger_risk_rule(
            db,
            user_id=pro_user_id,
            rule_id="payout.anomaly",
            payload={"first_available_at": first_available.available_at.isoformat(), "within_hours": within_hours},
        )


def evaluate_dispute_rate_rule(db: Session, *, user_id: uuid.UUID) -> None:
    ensure_default_risk_rules(db)
    rule = db.get(RiskRule, "dispute.rate_high")
    if not rule or not rule.is_active:
        return
    params = rule.params or {}
    window_days = int(params.get("window_days", 30))
    max_disputes = int(params.get("max_disputes", 3))
    since = _now() - timedelta(days=window_days)
    count = db.execute(
        select(func.count())
        .select_from(Dispute)
        .where(Dispute.opened_by_user_id == user_id, Dispute.opened_at >= since)
    ).scalar_one()
    if int(count) > max_disputes:
        trigger_risk_rule(
            db,
            user_id=user_id,
            rule_id="dispute.rate_high",
            payload={"count": int(count), "window_days": window_days},
        )


def list_risk_profiles(
    db: Session,
    *,
    level: RiskLevel | None,
    score_min: int,
    limit: int,
) -> list[RiskProfile]:
    stmt = select(RiskProfile).where(RiskProfile.risk_score >= score_min)
    if level:
        stmt = stmt.where(RiskProfile.risk_level == level)
    return db.execute(stmt.order_by(RiskProfile.risk_score.desc()).limit(limit)).scalars().all()


def get_risk_user_detail(db: Session, *, user_id: uuid.UUID) -> dict:
    profile = get_or_create_risk_profile(db, user_id)
    events = db.execute(
        select(RiskEvent).where(RiskEvent.user_id == user_id).order_by(RiskEvent.created_at.desc()).limit(200)
    ).scalars().all()
    actions = db.execute(
        select(RiskAction).where(RiskAction.user_id == user_id).order_by(RiskAction.created_at.desc()).limit(100)
    ).scalars().all()
    devices = db.execute(
        select(DeviceFingerprint).where(DeviceFingerprint.user_id == user_id).order_by(DeviceFingerprint.last_seen_at.desc()).limit(20)
    ).scalars().all()
    sessions = db.execute(
        select(SessionSignal).where(SessionSignal.user_id == user_id).order_by(SessionSignal.last_seen_at.desc()).limit(50)
    ).scalars().all()
    ip_hashes = [s.ip_hash for s in sessions if s.ip_hash]
    ips = []
    if ip_hashes:
        ips = db.execute(select(IpSignal).where(IpSignal.ip_hash.in_(ip_hashes)).limit(50)).scalars().all()

    return {
        "profile": profile,
        "events": events,
        "actions": actions,
        "devices": devices,
        "sessions": sessions,
        "ips": ips,
    }


def put_risk_rule(
    db: Session,
    *,
    rule_id: str,
    is_active: bool,
    params: dict,
    score_delta: int,
    action_on_trigger: dict,
) -> RiskRule:
    row = db.get(RiskRule, rule_id)
    if row is None:
        row = RiskRule(
            id=rule_id,
            is_active=is_active,
            params=params,
            score_delta=score_delta,
            action_on_trigger=action_on_trigger,
        )
        db.add(row)
    else:
        row.is_active = is_active
        row.params = params
        row.score_delta = score_delta
        row.action_on_trigger = action_on_trigger
        row.updated_at = _now()
    db.flush()
    return row


def list_risk_rules(db: Session) -> list[RiskRule]:
    ensure_default_risk_rules(db)
    return db.execute(select(RiskRule).order_by(RiskRule.id.asc())).scalars().all()


def reconcile_risk_profile(db: Session, *, user_id: uuid.UUID) -> RiskProfile:
    profile = get_or_create_risk_profile(db, user_id)
    since = _now() - timedelta(days=30)
    score = db.execute(
        select(func.coalesce(func.sum(RiskEvent.delta), 0)).where(RiskEvent.user_id == user_id, RiskEvent.created_at >= since)
    ).scalar_one()
    score_i = max(0, int(score or 0))
    profile.risk_score = score_i
    profile.risk_level = _score_to_level(score_i)
    recent_reasons = db.execute(
        select(RiskEvent.rule_id)
        .where(RiskEvent.user_id == user_id, RiskEvent.created_at >= since, RiskEvent.delta > 0)
        .order_by(RiskEvent.created_at.desc())
        .limit(30)
    ).scalars().all()
    profile.reasons = list(dict.fromkeys(recent_reasons))
    profile.last_calculated_at = _now()
    db.flush()
    return profile


def reconcile_all_risk_profiles(db: Session, *, limit: int = 500) -> int:
    user_ids = db.execute(select(RiskEvent.user_id).distinct().limit(limit)).scalars().all()
    count = 0
    for user_id in user_ids:
        reconcile_risk_profile(db, user_id=user_id)
        count += 1
    return count


def purge_old_risk_signals(db: Session) -> int:
    cutoff = _now() - timedelta(days=max(1, int(settings.risk_signal_retention_days)))
    deleted = 0
    for model in (SessionSignal, DeviceFingerprint):
        rows = db.execute(select(model).where(model.last_seen_at < cutoff).limit(2000)).scalars().all()
        for row in rows:
            db.delete(row)
            deleted += 1
    return deleted
