from __future__ import annotations

import hashlib
import uuid
from datetime import date, datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP

from sqlalchemy import and_, func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.client_rewards_pricing import (
    ConsentRewardLevel,
    ConsentRewardPolicy,
    ExtraImagePricingPolicy,
    ExtraImagePurchase,
    ExtraImagePurchaseStatus,
    ProExtraImagePrice,
    ShareFraudSetting,
    ShareLinkEngagement,
    ShareLinkView,
    ShareRewardGrant,
    ShareRewardMetric,
    ShareRewardThreshold,
)
from app.models.gallery import ProofGallery
from app.models.gig import Gig
from app.models.media_rights import GigUsageConsentEvent, ShareLink
from app.models.niche import ProNicheSkill, SkillTier
from app.models.ops import AbuseSeverity
from app.models.reward import RewardEntryType, RewardLedgerEntry
from app.services.abuse import create_abuse_signal
from app.services.analytics import log_event
from app.services.rewards import add_reward_entry

settings = get_settings()

DEFAULT_FRAUD_SETTINGS: dict[str, int] = {
    "min_seconds_viewed": 8,
    "max_views_per_ip_per_day": 100,
    "max_rewards_per_user_per_month": 20,
}


def ensure_default_consent_reward_policies(db: Session) -> None:
    defaults = {
        ConsentRewardLevel.none: 0,
        ConsentRewardLevel.pro_marketing_only: 80,
        ConsentRewardLevel.rawwers_marketing_only: 100,
        ConsentRewardLevel.both_pro_and_rawwers: 160,
    }
    now = datetime.now(timezone.utc)
    for level, points in defaults.items():
        row = db.execute(select(ConsentRewardPolicy).where(ConsentRewardPolicy.consent_level == level)).scalar_one_or_none()
        if row:
            continue
        db.add(
            ConsentRewardPolicy(
                consent_level=level,
                points_award=points,
                cooldown_hours=48,
                allow_clawback=True,
                max_awards_per_user_per_month=10,
                updated_at=now,
            )
        )
    db.flush()


def ensure_default_share_thresholds(db: Session) -> None:
    now = datetime.now(timezone.utc)
    defaults = [
        (ShareRewardMetric.unique_views_30d, 20, 120),
        (ShareRewardMetric.unique_views_30d, 50, 350),
        (ShareRewardMetric.conversions_30d, 1, 300),
    ]
    for metric, threshold_value, points_award in defaults:
        row = db.execute(
            select(ShareRewardThreshold).where(
                ShareRewardThreshold.metric == metric,
                ShareRewardThreshold.threshold_value == threshold_value,
            )
        ).scalar_one_or_none()
        if row:
            continue
        db.add(
            ShareRewardThreshold(
                metric=metric,
                threshold_value=threshold_value,
                points_award=points_award,
                max_awards_per_share_link=1,
                is_active=True,
                updated_at=now,
            )
        )
    db.flush()


def get_share_fraud_settings(db: Session) -> dict[str, int]:
    values = dict(DEFAULT_FRAUD_SETTINGS)
    rows = db.execute(select(ShareFraudSetting)).scalars().all()
    for row in rows:
        values[row.key] = int(row.value)
    return values


def upsert_share_fraud_settings(db: Session, values: dict[str, int]) -> dict[str, int]:
    for key, value in values.items():
        if key not in DEFAULT_FRAUD_SETTINGS:
            continue
        row = db.get(ShareFraudSetting, key)
        if not row:
            row = ShareFraudSetting(key=key, value=max(0, int(value)))
            db.add(row)
        else:
            row.value = max(0, int(value))
    db.flush()
    return get_share_fraud_settings(db)


def compute_extra_image_unit_price(
    db: Session,
    *,
    gig: Gig,
    gallery: ProofGallery,
) -> tuple[Decimal, Decimal, Decimal, Decimal | None, SkillTier]:
    niche_id = gig.niche_id
    tier = SkillTier.rookie
    if niche_id:
        skill = db.execute(
            select(ProNicheSkill).where(ProNicheSkill.pro_user_id == gig.pro_user_id, ProNicheSkill.niche_id == niche_id)
        ).scalar_one_or_none()
        if skill:
            tier = skill.tier

    policy = None
    if niche_id:
        policy = db.execute(
            select(ExtraImagePricingPolicy).where(
                ExtraImagePricingPolicy.niche_id == niche_id,
                ExtraImagePricingPolicy.tier == tier,
                ExtraImagePricingPolicy.is_active.is_(True),
            )
        ).scalar_one_or_none()

    pro_price = None
    if niche_id:
        pro_price = db.execute(
            select(ProExtraImagePrice).where(
                ProExtraImagePrice.pro_user_id == gig.pro_user_id,
                ProExtraImagePrice.niche_id == niche_id,
            )
        ).scalar_one_or_none()

    configured = (pro_price.configured_unit_price if pro_price else gallery.extra_photo_price).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    policy_min = (policy.unit_price_min if policy else Decimal("0.00")).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    policy_max = policy.unit_price_max.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP) if policy and policy.unit_price_max is not None else None

    applied = configured
    if applied < policy_min:
        applied = policy_min
    if policy_max is not None and applied > policy_max:
        applied = policy_max

    return (
        configured,
        applied,
        policy_min,
        policy_max,
        tier,
    )


def enforce_max_extra_images(db: Session, *, gig: Gig, tier: SkillTier, extra_images: int) -> None:
    if not gig.niche_id:
        return
    policy = db.execute(
        select(ExtraImagePricingPolicy).where(
            ExtraImagePricingPolicy.niche_id == gig.niche_id,
            ExtraImagePricingPolicy.tier == tier,
            ExtraImagePricingPolicy.is_active.is_(True),
        )
    ).scalar_one_or_none()
    if not policy or policy.max_extra_images is None:
        return
    if extra_images > int(policy.max_extra_images):
        from app.core.errors import APIError

        raise APIError(code="validation_error", message="Extra image count exceeds policy maximum", status_code=422)


def upsert_extra_image_purchase_snapshot(
    db: Session,
    *,
    gig: Gig,
    gallery: ProofGallery,
    selected_images: int,
    extra_images: int,
    unit_price_configured: Decimal,
    unit_price_applied: Decimal,
    policy_min: Decimal,
    policy_max: Decimal | None,
    subtotal: Decimal,
    discounts_total: Decimal,
    total: Decimal,
    points_spent: int,
    stripe_payment_intent_id: str,
    share_link_id: uuid.UUID | None = None,
) -> ExtraImagePurchase:
    row = db.execute(
        select(ExtraImagePurchase)
        .where(ExtraImagePurchase.gig_id == gig.id, ExtraImagePurchase.stripe_payment_intent_id == stripe_payment_intent_id)
        .order_by(ExtraImagePurchase.created_at.desc())
    ).scalars().first()
    if not row:
        row = ExtraImagePurchase(
            gig_id=gig.id,
            client_user_id=gig.client_user_id,
            pro_user_id=gig.pro_user_id,
            niche_id=gig.niche_id,
            included_images=gallery.included_photos,
            selected_images=selected_images,
            extra_images=extra_images,
            unit_price_applied=unit_price_applied,
            unit_price_configured=unit_price_configured,
            policy_unit_price_min=policy_min,
            policy_unit_price_max=policy_max,
            subtotal=subtotal,
            points_spent=points_spent,
            discounts_total=discounts_total,
            total=total,
            stripe_payment_intent_id=stripe_payment_intent_id,
            status=ExtraImagePurchaseStatus.pending,
            share_link_id=share_link_id,
            meta={},
        )
        db.add(row)
        db.flush()
        return row

    row.included_images = gallery.included_photos
    row.selected_images = selected_images
    row.extra_images = extra_images
    row.unit_price_applied = unit_price_applied
    row.unit_price_configured = unit_price_configured
    row.policy_unit_price_min = policy_min
    row.policy_unit_price_max = policy_max
    row.subtotal = subtotal
    row.points_spent = points_spent
    row.discounts_total = discounts_total
    row.total = total
    row.share_link_id = share_link_id
    db.flush()
    return row


def maybe_award_consent_points(
    db: Session,
    *,
    gig_id: uuid.UUID,
    client_user_id: uuid.UUID,
    consent_level: str,
) -> RewardLedgerEntry | None:
    ensure_default_consent_reward_policies(db)
    try:
        level = ConsentRewardLevel(consent_level)
    except ValueError:
        return None

    policy = db.execute(select(ConsentRewardPolicy).where(ConsentRewardPolicy.consent_level == level)).scalar_one_or_none()
    if not policy or int(policy.points_award) <= 0:
        return None

    month_start = datetime.now(timezone.utc).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    month_count = db.execute(
        select(func.count()).select_from(RewardLedgerEntry).where(
            RewardLedgerEntry.user_id == client_user_id,
            RewardLedgerEntry.reference_type == "consent_reward",
            RewardLedgerEntry.created_at >= month_start,
            RewardLedgerEntry.entry_type == RewardEntryType.earn,
        )
    ).scalar_one()
    if month_count >= int(policy.max_awards_per_user_per_month):
        return None

    entry = add_reward_entry(
        db,
        user_id=client_user_id,
        amount=int(policy.points_award),
        entry_type=RewardEntryType.earn,
        reference_type="consent_reward",
        reference_id=f"{gig_id}:{level.value}",
        metadata={"gig_id": str(gig_id), "consent_level": level.value},
        min_balance_floor=settings.reward_balance_floor,
    )
    if entry:
        log_event(
            db,
            event_name="client.consent.reward_awarded",
            user_id=client_user_id,
            properties={"gig_id": str(gig_id), "consent_level": level.value, "points": policy.points_award},
        )
    return entry


def maybe_clawback_consent_points(
    db: Session,
    *,
    gig_id: uuid.UUID,
    client_user_id: uuid.UUID,
    from_level: str,
    to_level: str,
) -> RewardLedgerEntry | None:
    ensure_default_consent_reward_policies(db)
    try:
        from_policy = db.execute(
            select(ConsentRewardPolicy).where(ConsentRewardPolicy.consent_level == ConsentRewardLevel(from_level))
        ).scalar_one_or_none()
        to_policy = db.execute(
            select(ConsentRewardPolicy).where(ConsentRewardPolicy.consent_level == ConsentRewardLevel(to_level))
        ).scalar_one_or_none()
    except ValueError:
        return None

    if not from_policy or not from_policy.allow_clawback:
        return None

    event = db.execute(
        select(GigUsageConsentEvent)
        .where(
            GigUsageConsentEvent.gig_id == gig_id,
            GigUsageConsentEvent.to_level == from_level,
        )
        .order_by(GigUsageConsentEvent.created_at.desc())
    ).scalars().first()
    if not event:
        return None

    cutoff = event.created_at + timedelta(hours=int(from_policy.cooldown_hours))
    if datetime.now(timezone.utc) > cutoff:
        return None

    from_points = int(from_policy.points_award)
    to_points = int(to_policy.points_award) if to_policy else 0
    delta = max(0, from_points - to_points)
    if delta <= 0:
        return None

    entry = add_reward_entry(
        db,
        user_id=client_user_id,
        amount=-delta,
        entry_type=RewardEntryType.adjustment,
        reference_type="consent_clawback",
        reference_id=f"{gig_id}:{from_level}:{to_level}",
        metadata={"gig_id": str(gig_id), "from_level": from_level, "to_level": to_level},
        min_balance_floor=settings.reward_balance_floor,
    )
    if entry:
        log_event(
            db,
            event_name="client.consent.reward_clawback",
            user_id=client_user_id,
            properties={"gig_id": str(gig_id), "from_level": from_level, "to_level": to_level, "points": delta},
        )
        from app.services.notifications import enqueue_notification

        enqueue_notification(
            db,
            user_id=client_user_id,
            notification_type="consent.updated",
            payload={
                "title": "Consent reward adjusted",
                "body": "Your consent reward was adjusted after a consent level change.",
                "action": {"label": "Open gig", "url": f"/gigs/{gig_id}"},
            },
            reference_type="gig",
            reference_id=str(gig_id),
        )
    return entry


def build_share_view_fingerprint(ip: str | None, user_agent: str | None) -> tuple[str, str | None, str | None]:
    ip_clean = ip or ""
    ua_clean = user_agent or ""
    ip_hash = hashlib.sha256(f"{ip_clean}{settings.media_access_ip_hash_pepper}".encode("utf-8")).hexdigest() if ip else None
    ua_hash = hashlib.sha256(ua_clean.encode("utf-8")).hexdigest() if user_agent else None
    fingerprint = hashlib.sha256(f"{ip_clean}|{ua_clean}|{settings.share_view_fingerprint_pepper}".encode("utf-8")).hexdigest()
    return fingerprint, ip_hash, ua_hash


def record_share_link_view(db: Session, *, link: ShareLink, ip: str | None, user_agent: str | None) -> ShareLinkView:
    settings_row = get_share_fraud_settings(db)
    fingerprint, ip_hash, ua_hash = build_share_view_fingerprint(ip, user_agent)
    today = datetime.now(timezone.utc).date()
    row = db.execute(
        select(ShareLinkView).where(
            ShareLinkView.share_link_id == link.id,
            ShareLinkView.fingerprint == fingerprint,
            ShareLinkView.viewed_on == today,
        )
    ).scalar_one_or_none()
    if row:
        return row

    row = ShareLinkView(
        share_link_id=link.id,
        ip_hash=ip_hash,
        ua_hash=ua_hash,
        fingerprint=fingerprint,
        viewed_at=datetime.now(timezone.utc),
        viewed_on=today,
        seconds_viewed=0,
    )
    db.add(row)
    db.flush()

    if ip_hash:
        count_ip_today = db.execute(
            select(func.count()).select_from(ShareLinkView).where(
                ShareLinkView.share_link_id == link.id,
                ShareLinkView.ip_hash == ip_hash,
                ShareLinkView.viewed_on == today,
            )
        ).scalar_one()
        if count_ip_today > int(settings_row["max_views_per_ip_per_day"]):
            create_abuse_signal(
                db,
                signal_type="share_view_abuse",
                severity=AbuseSeverity.medium,
                user_id=link.created_by_user_id,
                ip_hash=ip_hash,
                evidence={"share_link_id": str(link.id), "count_today": int(count_ip_today)},
            )

    return row


def ping_share_link_view(
    db: Session,
    *,
    link: ShareLink,
    ip: str | None,
    user_agent: str | None,
    seconds_increment: int,
) -> ShareLinkView:
    today = datetime.now(timezone.utc).date()
    fingerprint, _, _ = build_share_view_fingerprint(ip, user_agent)
    row = db.execute(
        select(ShareLinkView).where(
            ShareLinkView.share_link_id == link.id,
            ShareLinkView.fingerprint == fingerprint,
            ShareLinkView.viewed_on == today,
        )
    ).scalar_one_or_none()
    if row is None:
        row = record_share_link_view(db, link=link, ip=ip, user_agent=user_agent)

    row.seconds_viewed = max(0, int(row.seconds_viewed or 0) + max(0, int(seconds_increment)))
    db.flush()
    return row


def refresh_share_link_engagement(db: Session, *, share_link_id: uuid.UUID) -> ShareLinkEngagement:
    now = datetime.now(timezone.utc)
    start_7d = now - timedelta(days=7)
    start_30d = now - timedelta(days=30)
    fraud = get_share_fraud_settings(db)
    min_seconds = int(fraud["min_seconds_viewed"])

    unique_7d = int(
        db.execute(
            select(func.count()).select_from(
                select(ShareLinkView.fingerprint)
                .where(
                    ShareLinkView.share_link_id == share_link_id,
                    ShareLinkView.viewed_at >= start_7d,
                    ShareLinkView.seconds_viewed >= min_seconds,
                )
                .distinct()
                .subquery()
            )
        ).scalar_one()
    )
    unique_30d = int(
        db.execute(
            select(func.count()).select_from(
                select(ShareLinkView.fingerprint)
                .where(
                    ShareLinkView.share_link_id == share_link_id,
                    ShareLinkView.viewed_at >= start_30d,
                    ShareLinkView.seconds_viewed >= min_seconds,
                )
                .distinct()
                .subquery()
            )
        ).scalar_one()
    )

    row = db.get(ShareLinkEngagement, share_link_id)
    if row is None:
        row = ShareLinkEngagement(
            share_link_id=share_link_id,
            unique_views_7d=unique_7d,
            unique_views_30d=unique_30d,
            conversions_30d=0,
        )
        db.add(row)
    else:
        row.unique_views_7d = unique_7d
        row.unique_views_30d = unique_30d

    low_engagement_count = int(
        db.execute(
            select(func.count()).select_from(ShareLinkView).where(
                ShareLinkView.share_link_id == share_link_id,
                ShareLinkView.viewed_at >= start_30d,
                ShareLinkView.seconds_viewed <= 0,
            )
        ).scalar_one()
    )
    if low_engagement_count >= 30 and unique_30d <= 1:
        link = db.get(ShareLink, share_link_id)
        create_abuse_signal(
            db,
            signal_type="share_zero_engagement_pattern",
            severity=AbuseSeverity.medium,
            user_id=link.created_by_user_id if link else None,
            evidence={"share_link_id": str(share_link_id), "low_engagement_count": low_engagement_count},
        )
    db.flush()
    return row


def increment_share_link_conversion(db: Session, *, share_link_id: uuid.UUID, count: int = 1) -> ShareLinkEngagement:
    row = db.get(ShareLinkEngagement, share_link_id)
    if row is None:
        row = ShareLinkEngagement(share_link_id=share_link_id, conversions_30d=max(0, count))
        db.add(row)
    else:
        row.conversions_30d = max(0, int(row.conversions_30d) + max(0, int(count)))
    db.flush()
    return row


def evaluate_share_reward_thresholds(db: Session, *, share_link_id: uuid.UUID) -> list[ShareRewardGrant]:
    ensure_default_share_thresholds(db)
    refresh_share_link_engagement(db, share_link_id=share_link_id)

    link = db.get(ShareLink, share_link_id)
    engagement = db.get(ShareLinkEngagement, share_link_id)
    if not link or not engagement:
        return []

    thresholds = db.execute(select(ShareRewardThreshold).where(ShareRewardThreshold.is_active.is_(True))).scalars().all()
    granted_rows: list[ShareRewardGrant] = []

    for threshold in thresholds:
        current = 0
        if threshold.metric == ShareRewardMetric.unique_views_30d:
            current = int(engagement.unique_views_30d)
        elif threshold.metric == ShareRewardMetric.conversions_30d:
            current = int(engagement.conversions_30d)
        if current < int(threshold.threshold_value):
            continue

        existing_count = db.execute(
            select(func.count()).select_from(ShareRewardGrant).where(
                ShareRewardGrant.share_link_id == share_link_id,
                ShareRewardGrant.metric == threshold.metric.value,
                ShareRewardGrant.threshold_value == threshold.threshold_value,
                ShareRewardGrant.user_id == link.created_by_user_id,
            )
        ).scalar_one()
        if existing_count >= int(threshold.max_awards_per_share_link):
            continue

        month_start = datetime.now(timezone.utc).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        monthly_grants = db.execute(
            select(func.count()).select_from(RewardLedgerEntry).where(
                RewardLedgerEntry.user_id == link.created_by_user_id,
                RewardLedgerEntry.reference_type == "share_reward",
                RewardLedgerEntry.created_at >= month_start,
                RewardLedgerEntry.entry_type == RewardEntryType.earn,
            )
        ).scalar_one()
        if monthly_grants >= int(get_share_fraud_settings(db)["max_rewards_per_user_per_month"]):
            continue

        reward_entry = add_reward_entry(
            db,
            user_id=link.created_by_user_id,
            amount=int(threshold.points_award),
            entry_type=RewardEntryType.earn,
            reference_type="share_reward",
            reference_id=f"{share_link_id}:{threshold.metric.value}:{threshold.threshold_value}",
            metadata={"metric": threshold.metric.value, "threshold": threshold.threshold_value},
            min_balance_floor=settings.reward_balance_floor,
        )
        grant = ShareRewardGrant(
            share_link_id=share_link_id,
            metric=threshold.metric.value,
            threshold_value=threshold.threshold_value,
            user_id=link.created_by_user_id,
            reward_ledger_entry_id=reward_entry.id if reward_entry else None,
        )
        db.add(grant)
        granted_rows.append(grant)

        if reward_entry:
            log_event(
                db,
                event_name="client.share.reward_awarded",
                user_id=link.created_by_user_id,
                properties={
                    "share_link_id": str(share_link_id),
                    "metric": threshold.metric.value,
                    "threshold": threshold.threshold_value,
                    "points": threshold.points_award,
                },
            )

    db.flush()
    return granted_rows


def maybe_emit_consent_toggle_abuse(db: Session, *, gig_id: uuid.UUID, actor_user_id: uuid.UUID) -> None:
    since = datetime.now(timezone.utc) - timedelta(hours=24)
    toggles = db.execute(
        select(func.count()).select_from(GigUsageConsentEvent).where(
            GigUsageConsentEvent.gig_id == gig_id,
            GigUsageConsentEvent.actor_user_id == actor_user_id,
            GigUsageConsentEvent.created_at >= since,
        )
    ).scalar_one()
    if int(toggles) > 6:
        create_abuse_signal(
            db,
            signal_type="consent_toggle_abuse",
            severity=AbuseSeverity.medium,
            user_id=actor_user_id,
            evidence={"gig_id": str(gig_id), "toggles_24h": int(toggles)},
        )
