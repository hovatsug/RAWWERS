from __future__ import annotations

import hashlib
import re
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import and_, func, select
from sqlalchemy.orm import Session

from app.models.admin import UserAccount
from app.models.chat import ChatMessage, ChatSenderType, ChatThread
from app.models.gig import Gig, PaymentStatus, StripePayment
from app.models.ops import AbuseSeverity, AbuseSignal, AbuseSignalStatus
from app.models.reward import ReferralAttribution

_LINK_RE = re.compile(r"https?://|www\.", flags=re.IGNORECASE)
_TAG_RE = re.compile(r"<[^>]+>")
_REPEAT_RE = re.compile(r"(.)\1{12,}")


def strip_html(value: str) -> str:
    return _TAG_RE.sub("", value)


def hash_ip(ip: str | None) -> str | None:
    if not ip:
        return None
    return hashlib.sha256(ip.encode("utf-8")).hexdigest()


def create_abuse_signal(
    db: Session,
    *,
    signal_type: str,
    severity: AbuseSeverity,
    user_id: uuid.UUID | None = None,
    ip_hash: str | None = None,
    evidence: dict | None = None,
) -> AbuseSignal:
    row = AbuseSignal(
        user_id=user_id,
        ip_hash=ip_hash,
        signal_type=signal_type,
        severity=severity,
        evidence=evidence or {},
        status=AbuseSignalStatus.open,
    )
    db.add(row)
    db.flush()
    return row


def detect_chat_spam(db: Session, *, thread: ChatThread, user_id: uuid.UUID, content: str, ip: str | None) -> AbuseSignal | None:
    cleaned = strip_html(content).strip()
    if len(cleaned) < 2:
        return None

    if _REPEAT_RE.search(cleaned):
        return create_abuse_signal(
            db,
            signal_type="spam_chat",
            severity=AbuseSeverity.medium,
            user_id=user_id,
            ip_hash=hash_ip(ip),
            evidence={"reason": "repeated_character_pattern", "sample": cleaned[:200]},
        )

    recent = db.execute(
        select(ChatMessage)
        .where(
            ChatMessage.thread_id == thread.id,
            ChatMessage.sender_user_id == user_id,
            ChatMessage.sender_type.in_([ChatSenderType.client, ChatSenderType.pro]),
        )
        .order_by(ChatMessage.created_at.desc())
        .limit(5)
    ).scalars().all()

    identical_count = sum(1 for item in recent if (item.content or "").strip().lower() == cleaned.lower())
    if identical_count >= 2:
        return create_abuse_signal(
            db,
            signal_type="spam_chat",
            severity=AbuseSeverity.high,
            user_id=user_id,
            ip_hash=hash_ip(ip),
            evidence={"reason": "repeated_identical_messages", "count": identical_count + 1},
        )

    account = db.get(UserAccount, user_id)
    if account and _LINK_RE.search(cleaned):
        if account.created_at >= datetime.now(timezone.utc) - timedelta(days=7):
            return create_abuse_signal(
                db,
                signal_type="spam_chat",
                severity=AbuseSeverity.medium,
                user_id=user_id,
                ip_hash=hash_ip(ip),
                evidence={"reason": "new_account_external_link", "sample": cleaned[:200]},
            )
    return None


def detect_review_fraud(db: Session, *, gig: Gig, reviewer_user_id: uuid.UUID, created_at: datetime, ip: str | None) -> AbuseSignal | None:
    if gig.updated_at and created_at <= gig.updated_at + timedelta(minutes=2):
        return create_abuse_signal(
            db,
            signal_type="review_fraud",
            severity=AbuseSeverity.low,
            user_id=reviewer_user_id,
            ip_hash=hash_ip(ip),
            evidence={"reason": "review_posted_too_fast_after_gig_update", "gig_id": str(gig.id)},
        )
    return None


def detect_referral_abuse(db: Session, *, referred_user_id: uuid.UUID, referrer_user_id: uuid.UUID, ip: str | None) -> list[AbuseSignal]:
    findings: list[AbuseSignal] = []
    ip_h = hash_ip(ip)
    if ip_h:
        since = datetime.now(timezone.utc) - timedelta(hours=24)
        count_same_ip = db.execute(
            select(func.count())
            .select_from(AbuseSignal)
            .where(
                AbuseSignal.signal_type == "referral_claim_observation",
                AbuseSignal.ip_hash == ip_h,
                AbuseSignal.created_at >= since,
            )
        ).scalar_one()
        db.add(
            AbuseSignal(
                user_id=referred_user_id,
                ip_hash=ip_h,
                signal_type="referral_claim_observation",
                severity=AbuseSeverity.low,
                evidence={"referrer_user_id": str(referrer_user_id)},
                status=AbuseSignalStatus.ignored,
            )
        )
        if count_same_ip >= 3:
            findings.append(
                create_abuse_signal(
                    db,
                    signal_type="referral_abuse",
                    severity=AbuseSeverity.high,
                    user_id=referred_user_id,
                    ip_hash=ip_h,
                    evidence={"reason": "many_claims_same_ip_24h", "count": count_same_ip + 1},
                )
            )

    circular = db.execute(
        select(ReferralAttribution)
        .where(
            ReferralAttribution.referred_user_id == referrer_user_id,
            ReferralAttribution.referrer_user_id == referred_user_id,
        )
    ).scalar_one_or_none()
    if circular:
        findings.append(
            create_abuse_signal(
                db,
                signal_type="referral_abuse",
                severity=AbuseSeverity.high,
                user_id=referred_user_id,
                ip_hash=ip_h,
                evidence={"reason": "circular_referral_pattern", "edge_id": str(circular.id)},
            )
        )
    return findings


def detect_payment_failures_anomaly(db: Session, *, client_user_id: uuid.UUID, payment_intent_id: str) -> AbuseSignal | None:
    since = datetime.now(timezone.utc) - timedelta(hours=1)
    failures = db.execute(
        select(func.count())
        .select_from(StripePayment)
        .where(
            StripePayment.client_user_id == client_user_id,
            StripePayment.status == PaymentStatus.failed,
            StripePayment.updated_at >= since,
        )
    ).scalar_one()
    if failures >= 3:
        return create_abuse_signal(
            db,
            signal_type="payment_anomaly",
            severity=AbuseSeverity.medium,
            user_id=client_user_id,
            evidence={"reason": "repeated_payment_failures", "count_last_hour": failures, "payment_intent_id": payment_intent_id},
        )
    return None


def detect_scraping_activity(db: Session, *, ip: str | None, hits_last_hour: int) -> AbuseSignal | None:
    if not ip or hits_last_hour < 500:
        return None
    return create_abuse_signal(
        db,
        signal_type="scraping",
        severity=AbuseSeverity.medium,
        ip_hash=hash_ip(ip),
        evidence={"reason": "high_request_volume_discovery", "hits_last_hour": hits_last_hour},
    )


def resolve_abuse_signal(db: Session, signal_id: uuid.UUID, status: AbuseSignalStatus) -> AbuseSignal | None:
    row = db.get(AbuseSignal, signal_id)
    if not row:
        return None
    row.status = status
    return row
