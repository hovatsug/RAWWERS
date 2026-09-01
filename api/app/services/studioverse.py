from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

import stripe
from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile, UserRoleType
from app.models.discovery import ProPublicIndex
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.models.media_rights import GigConsentLevel, GigUsageConsent
from app.models.ops import AbuseSeverity
from app.models.reward import RewardEntryType
from app.models.payouts import EarningsSourceType
from app.models.studioverse import (
    ContentLicense,
    ContentPack,
    ContentPackCategory,
    ContentPackEntitlement,
    ContentPackOrder,
    ContentPackOrderStatus,
    ContentPackPaymentMethod,
    ContentPackReviewDecision,
    ContentPackStatus,
    ContentPackVersion,
    PackDownloadLog,
    PackSourceReference,
    PackSourceType,
    RoyaltyLedgerEntry,
    RoyaltyLedgerStatus,
    RoyaltyRule,
)
from app.services.abuse import create_abuse_signal, hash_ip
from app.services.authz import ensure_user_account, get_user_roles
from app.services.rewards import add_reward_entry
from app.services.storage import create_presigned_get
from app.services.stripe_service import map_intent_status, to_cents
from app.services.proof_of_gigs import reverse_raww_mints_for_reference
from app.services.payouts import reverse_earnings_entries_for_source

settings = get_settings()

PLATFORM_TREASURY_USER_ID = uuid.UUID("00000000-0000-0000-0000-000000000001")


def ensure_default_content_licenses(db: Session) -> None:
    rows = {
        "standard_personal": {
            "name": "Standard Personal",
            "terms": {"commercial": False, "redistribution": False, "seats": 1},
        },
        "standard_commercial": {
            "name": "Standard Commercial",
            "terms": {"commercial": True, "redistribution": False, "seats": 3},
        },
    }
    now = datetime.now(timezone.utc)
    for code, payload in rows.items():
        existing = db.get(ContentLicense, code)
        if existing:
            continue
        db.add(ContentLicense(code=code, name=payload["name"], terms=payload["terms"], updated_at=now))
    db.flush()


def ensure_default_royalty_rule(db: Session) -> RoyaltyRule:
    row = db.execute(select(RoyaltyRule).where(RoyaltyRule.category.is_(None))).scalar_one_or_none()
    if row:
        return row
    row = RoyaltyRule(category=None, platform_fee_percent=20, creator_percent=80)
    db.add(row)
    db.flush()
    return row


def ensure_creator_can_submit(db: Session, *, creator_user_id: uuid.UUID) -> None:
    ensure_user_account(db, creator_user_id)
    roles = get_user_roles(db, creator_user_id)
    if UserRoleType.pro not in roles:
        raise APIError(code="forbidden", message="Pro role required", status_code=403)

    profile = db.get(ProProfile, creator_user_id)
    onboarding = db.get(ProOnboarding, creator_user_id)
    if not profile or profile.kyc_status != KYCStatus.approved:
        raise APIError(code="kyc_required", message="KYC approved profile required", status_code=409)
    if not onboarding or onboarding.status != ProOnboardingStatus.approved_public:
        raise APIError(code="forbidden", message="Pro onboarding not approved for public", status_code=403)


def validate_submission_sources(db: Session, *, pack: ContentPack) -> None:
    ensure_default_content_licenses(db)
    license_row = db.get(ContentLicense, pack.license_code)
    if not license_row:
        raise APIError(code="validation_error", message="Unknown license_code", status_code=422)

    if not pack.title.strip() or not pack.description.strip() or not pack.pack_file_storage_key.strip():
        raise APIError(code="validation_error", message="Missing required pack fields", status_code=422)

    rows = db.execute(
        select(PackSourceReference).where(PackSourceReference.content_pack_id == pack.id)
    ).scalars().all()
    for src in rows:
        if src.source_type == PackSourceType.gig:
            _validate_gig_source_consent(db, pack=pack, source=src)
            src.is_consent_verified = True


def _validate_gig_source_consent(db: Session, *, pack: ContentPack, source: PackSourceReference) -> None:
    if not source.gig_id:
        raise APIError(code="validation_error", message="gig_id required for gig source", status_code=422)
    consent = db.execute(
        select(GigUsageConsent).where(
            GigUsageConsent.gig_id == source.gig_id,
            GigUsageConsent.pro_user_id == pack.creator_user_id,
        )
    ).scalar_one_or_none()
    if not consent:
        raise APIError(code="forbidden", message="Gig source consent not found", status_code=403)

    if not _consent_satisfies(consent.consent_level, source.requires_consent_level):
        raise APIError(code="forbidden", message="Gig consent level is insufficient for content reuse", status_code=403)

    evidence = source.evidence or {}
    if not bool(evidence.get("derivative_only", False)):
        raise APIError(
            code="validation_error",
            message="Gig sources must prove derivative-only assets in evidence.derivative_only",
            status_code=422,
        )


def _consent_satisfies(actual: GigConsentLevel, required: GigConsentLevel) -> bool:
    if required == GigConsentLevel.none:
        return True
    if required == GigConsentLevel.both_pro_and_rawwers:
        return actual == GigConsentLevel.both_pro_and_rawwers
    if required == GigConsentLevel.pro_marketing_only:
        return actual in {GigConsentLevel.pro_marketing_only, GigConsentLevel.both_pro_and_rawwers}
    if required == GigConsentLevel.rawwers_marketing_only:
        return actual in {GigConsentLevel.rawwers_marketing_only, GigConsentLevel.both_pro_and_rawwers}
    return False


def get_royalty_rule(db: Session, category: ContentPackCategory) -> RoyaltyRule:
    row = db.execute(select(RoyaltyRule).where(RoyaltyRule.category == category.value)).scalar_one_or_none()
    if row:
        return row
    return ensure_default_royalty_rule(db)


def list_marketplace_packs_db(
    db: Session,
    *,
    search: str | None,
    category: ContentPackCategory | None,
    niche: str | None,
    limit: int,
    offset: int,
) -> tuple[int, list[ContentPack]]:
    stmt = select(ContentPack).where(ContentPack.status == ContentPackStatus.approved)
    if category:
        stmt = stmt.where(ContentPack.category == category)
    if niche:
        stmt = stmt.where(ContentPack.niche_slugs.contains([niche]))
    if search:
        q = f"%{search.lower()}%"
        stmt = stmt.where(or_(func.lower(ContentPack.title).like(q), func.lower(ContentPack.description).like(q)))

    total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    rows = (
        db.execute(stmt.order_by(ContentPack.approved_at.desc().nullslast(), ContentPack.updated_at.desc()).offset(offset).limit(limit))
        .scalars()
        .all()
    )
    return int(total), rows


def settle_paid_order(db: Session, *, order: ContentPackOrder) -> tuple[ContentPackEntitlement, RoyaltyLedgerEntry]:
    existing_entitlement = db.execute(
        select(ContentPackEntitlement).where(ContentPackEntitlement.order_id == order.id)
    ).scalar_one_or_none()
    existing_royalty = db.execute(
        select(RoyaltyLedgerEntry).where(RoyaltyLedgerEntry.content_pack_order_id == order.id)
    ).scalar_one_or_none()
    if existing_entitlement and existing_royalty:
        return existing_entitlement, existing_royalty

    pack = db.get(ContentPack, order.content_pack_id)
    if not pack:
        raise APIError(code="not_found", message="Pack not found", status_code=404)

    now = datetime.now(timezone.utc)
    entitlement = existing_entitlement or ContentPackEntitlement(
        order_id=order.id,
        buyer_user_id=order.buyer_user_id,
        content_pack_id=order.content_pack_id,
        valid_from=now,
        valid_until=None,
        download_limit=20,
        downloads_used=0,
    )
    if not existing_entitlement:
        db.add(entitlement)

    royalty_rule = get_royalty_rule(db, pack.category)
    gross_eur = (order.price_eur_paid or Decimal("0.00")).quantize(Decimal("0.01"))
    gross_raww = int(order.price_raww_paid or 0)
    fee_eur = _pct_amount(gross_eur, royalty_rule.platform_fee_percent)
    net_creator_eur = (gross_eur - fee_eur).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    fee_raww = int((gross_raww * royalty_rule.platform_fee_percent) // 100)
    net_creator_raww = int(gross_raww - fee_raww)

    royalty = existing_royalty or RoyaltyLedgerEntry(
        content_pack_order_id=order.id,
        creator_user_id=pack.creator_user_id,
        gross_eur=gross_eur,
        fee_eur=fee_eur,
        net_creator_eur=net_creator_eur,
        gross_raww=gross_raww,
        fee_raww=fee_raww,
        net_creator_raww=net_creator_raww,
        status=RoyaltyLedgerStatus.settled,
    )
    if not existing_royalty:
        db.add(royalty)

    db.flush()
    return entitlement, royalty


def reverse_paid_order(db: Session, *, order: ContentPackOrder, reason: str) -> None:
    if order.status == ContentPackOrderStatus.refunded:
        return

    order.status = ContentPackOrderStatus.refunded
    order.updated_at = datetime.now(timezone.utc)

    entitlement = db.execute(
        select(ContentPackEntitlement).where(ContentPackEntitlement.order_id == order.id)
    ).scalar_one_or_none()
    if entitlement:
        entitlement.valid_until = datetime.now(timezone.utc)

    royalty = db.execute(
        select(RoyaltyLedgerEntry).where(RoyaltyLedgerEntry.content_pack_order_id == order.id)
    ).scalar_one_or_none()
    if royalty:
        royalty.status = RoyaltyLedgerStatus.reversed
        royalty.updated_at = datetime.now(timezone.utc)

    # Reverse credits whenever the order included RAWW credits.
    if int(order.price_raww_paid or 0) > 0:
        pack = db.get(ContentPack, order.content_pack_id)
        if pack:
            ensure_user_account(db, PLATFORM_TREASURY_USER_ID)
            add_reward_entry(
                db,
                user_id=pack.creator_user_id,
                amount=-int(royalty.net_creator_raww if royalty else int(order.price_raww_paid)),
                entry_type=RewardEntryType.adjustment,
                reference_type="studioverse_refund",
                reference_id=f"creator:{order.id}",
                metadata={"reason": reason},
                min_balance_floor=settings.reward_balance_floor,
            )
            add_reward_entry(
                db,
                user_id=PLATFORM_TREASURY_USER_ID,
                amount=-int(royalty.fee_raww if royalty else 0),
                entry_type=RewardEntryType.adjustment,
                reference_type="studioverse_refund",
                reference_id=f"platform:{order.id}",
                metadata={"reason": reason},
                min_balance_floor=settings.reward_balance_floor,
            )
            add_reward_entry(
                db,
                user_id=order.buyer_user_id,
                amount=int(order.price_raww_paid),
                entry_type=RewardEntryType.adjustment,
                reference_type="studioverse_refund",
                reference_id=f"buyer:{order.id}",
                metadata={"reason": reason},
            )
    reverse_raww_mints_for_reference(
        db,
        reference_type="content_pack_order",
        reference_id=order.id,
        reason=f"studioverse_refund:{reason}",
    )
    reverse_earnings_entries_for_source(
        db,
        source_type=EarningsSourceType.studioverse_sale,
        source_id=order.id,
        reason=f"studioverse_refund:{reason}",
    )


def process_raww_credit_split(db: Session, *, order: ContentPackOrder, pack: ContentPack) -> None:
    if int(order.price_raww_paid or 0) <= 0:
        return

    royalty_rule = get_royalty_rule(db, pack.category)
    gross = int(order.price_raww_paid)
    fee = int((gross * royalty_rule.platform_fee_percent) // 100)
    creator_take = gross - fee

    ensure_user_account(db, PLATFORM_TREASURY_USER_ID)

    debit = add_reward_entry(
        db,
        user_id=order.buyer_user_id,
        amount=-gross,
        entry_type=RewardEntryType.spend,
        reference_type="studioverse_order",
        reference_id=f"buyer:{order.id}",
        min_balance_floor=0,
        metadata={"content_pack_id": str(order.content_pack_id)},
    )
    if debit is None:
        raise APIError(code="validation_error", message="Insufficient RAWW credits", status_code=422)

    add_reward_entry(
        db,
        user_id=pack.creator_user_id,
        amount=creator_take,
        entry_type=RewardEntryType.earn,
        reference_type="studioverse_order",
        reference_id=f"creator:{order.id}",
        metadata={"content_pack_id": str(order.content_pack_id)},
    )
    add_reward_entry(
        db,
        user_id=PLATFORM_TREASURY_USER_ID,
        amount=fee,
        entry_type=RewardEntryType.earn,
        reference_type="studioverse_order",
        reference_id=f"platform:{order.id}",
        metadata={"content_pack_id": str(order.content_pack_id)},
    )


def create_stripe_payment_intent_for_pack(
    *,
    order_id: uuid.UUID,
    buyer_user_id: uuid.UUID,
    pack: ContentPack,
    amount: Decimal,
) -> stripe.PaymentIntent:
    return stripe.PaymentIntent.create(
        amount=to_cents(amount),
        currency=(pack.currency or "EUR").lower(),
        payment_method_types=["card"],
        automatic_payment_methods={"enabled": True},
        metadata={
            "content_pack_order_id": str(order_id),
            "content_pack_id": str(pack.id),
            "buyer_user_id": str(buyer_user_id),
            "creator_user_id": str(pack.creator_user_id),
        },
        idempotency_key=f"studioverse:{order_id}:pi",
    )


def validate_checkout_method(*, method: ContentPackPaymentMethod, pack: ContentPack) -> tuple[Decimal, int]:
    eur_amount = (pack.price_eur or Decimal("0.00")).quantize(Decimal("0.01"))
    raww_amount = int(pack.price_raww or 0)

    if method == ContentPackPaymentMethod.stripe and eur_amount <= Decimal("0.00"):
        raise APIError(code="validation_error", message="This pack has no EUR price", status_code=422)
    if method == ContentPackPaymentMethod.raww_credits and raww_amount <= 0:
        raise APIError(code="validation_error", message="This pack has no RAWW credits price", status_code=422)
    if method == ContentPackPaymentMethod.mixed:
        if eur_amount <= Decimal("0.00") or raww_amount <= 0:
            raise APIError(code="validation_error", message="Mixed payment requires EUR and RAWW prices", status_code=422)
    return eur_amount, raww_amount


def mark_download_or_raise(
    db: Session,
    *,
    order: ContentPackOrder,
    entitlement: ContentPackEntitlement,
    user_id: uuid.UUID,
    ip: str | None,
    user_agent: str | None,
) -> str:
    now = datetime.now(timezone.utc)
    if entitlement.valid_until and entitlement.valid_until <= now:
        raise APIError(code="forbidden", message="Entitlement expired", status_code=403)
    if entitlement.downloads_used >= entitlement.download_limit:
        create_abuse_signal(
            db,
            signal_type="studioverse_download_limit_exceeded",
            severity=AbuseSeverity.medium,
            user_id=user_id,
            ip_hash=hash_ip(ip),
            evidence={"order_id": str(order.id), "downloads_used": entitlement.downloads_used},
        )
        raise APIError(code="forbidden", message="Download limit exceeded", status_code=403)

    entitlement.downloads_used += 1
    db.add(
        PackDownloadLog(
            order_id=order.id,
            entitlement_id=entitlement.id,
            buyer_user_id=user_id,
            content_pack_id=order.content_pack_id,
            download_number=entitlement.downloads_used,
            ip_hash=hash_ip(ip),
            user_agent=(user_agent or "")[:512] or None,
        )
    )

    pack = db.get(ContentPack, order.content_pack_id)
    if not pack:
        raise APIError(code="not_found", message="Pack not found", status_code=404)
    return create_presigned_get(pack.pack_file_storage_key, expires_in=max(60, settings.media_signed_url_ttl_seconds))


def build_content_pack_document(db: Session, content_pack_id: uuid.UUID) -> dict | None:
    pack = db.get(ContentPack, content_pack_id)
    if not pack or pack.status != ContentPackStatus.approved:
        return None
    creator = db.get(ProProfile, pack.creator_user_id)
    index = db.get(ProPublicIndex, pack.creator_user_id)
    return {
        "id": str(pack.id),
        "title": pack.title,
        "description": pack.description,
        "category": pack.category.value,
        "niche_slugs": pack.niche_slugs or [],
        "tags": pack.tags or [],
        "price_eur": float(pack.price_eur) if pack.price_eur is not None else None,
        "price_raww": int(pack.price_raww) if pack.price_raww is not None else None,
        "creator_name": creator.display_name if creator else None,
        "rating": float(index.avg_rating) if index and index.avg_rating is not None else None,
        "updated_at": pack.updated_at.isoformat() if pack.updated_at else None,
    }


def _pct_amount(amount: Decimal, percent: int) -> Decimal:
    return (amount * Decimal(percent) / Decimal("100")).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def update_pack_sources(db: Session, *, content_pack_id: uuid.UUID, sources: list[dict]) -> None:
    db.execute(
        PackSourceReference.__table__.delete().where(PackSourceReference.content_pack_id == content_pack_id)
    )
    for row in sources:
        db.add(
            PackSourceReference(
                content_pack_id=content_pack_id,
                source_type=row["source_type"],
                gig_id=row.get("gig_id"),
                evidence=row.get("evidence") or {},
                requires_consent_level=row.get("requires_consent_level") or GigConsentLevel.both_pro_and_rawwers,
            )
        )
    db.flush()


def query_creator_packs(db: Session, *, creator_user_id: uuid.UUID) -> list[ContentPack]:
    return db.execute(
        select(ContentPack)
        .where(ContentPack.creator_user_id == creator_user_id)
        .order_by(ContentPack.updated_at.desc(), ContentPack.created_at.desc())
    ).scalars().all()


def query_admin_packs(db: Session, *, status: ContentPackStatus | None) -> list[ContentPack]:
    stmt = select(ContentPack)
    if status:
        stmt = stmt.where(ContentPack.status == status)
    return db.execute(stmt.order_by(ContentPack.updated_at.desc(), ContentPack.created_at.desc())).scalars().all()


def query_buyer_orders(db: Session, *, buyer_user_id: uuid.UUID) -> list[ContentPackOrder]:
    return db.execute(
        select(ContentPackOrder)
        .where(ContentPackOrder.buyer_user_id == buyer_user_id)
        .order_by(ContentPackOrder.created_at.desc())
    ).scalars().all()


def append_pack_version_if_changed(db: Session, *, pack: ContentPack, new_storage_key: str, release_notes: str | None = None) -> None:
    latest = db.execute(
        select(ContentPackVersion)
        .where(ContentPackVersion.content_pack_id == pack.id)
        .order_by(ContentPackVersion.version.desc())
        .limit(1)
    ).scalar_one_or_none()
    if latest and latest.pack_file_storage_key == new_storage_key:
        return
    next_version = 1 if not latest else latest.version + 1
    db.add(
        ContentPackVersion(
            content_pack_id=pack.id,
            version=next_version,
            pack_file_storage_key=new_storage_key,
            release_notes=release_notes,
        )
    )
    db.flush()


def validate_review_transition(*, pack: ContentPack, decision: ContentPackReviewDecision) -> None:
    if pack.status not in {ContentPackStatus.submitted, ContentPackStatus.approved}:
        raise APIError(code="validation_error", message="Pack is not in reviewable state", status_code=422)
    if decision == ContentPackReviewDecision.approved and pack.status == ContentPackStatus.approved:
        raise APIError(code="validation_error", message="Pack already approved", status_code=422)


def detect_suspicious_refund_pattern(db: Session, *, buyer_user_id: uuid.UUID) -> bool:
    since = datetime.now(timezone.utc).replace(day=1)
    refunded_count = db.execute(
        select(func.count())
        .select_from(ContentPackOrder)
        .where(
            ContentPackOrder.buyer_user_id == buyer_user_id,
            ContentPackOrder.status == ContentPackOrderStatus.refunded,
            ContentPackOrder.updated_at >= since,
        )
    ).scalar_one()
    return int(refunded_count) >= 3


def can_access_pack_for_purchase(pack: ContentPack) -> bool:
    return pack.status == ContentPackStatus.approved


def normalize_search_filters(*, category: str | None, niche: str | None) -> tuple[ContentPackCategory | None, str | None]:
    parsed_category = None
    if category:
        try:
            parsed_category = ContentPackCategory(category)
        except Exception as exc:
            raise APIError(code="validation_error", message="Invalid category", status_code=422) from exc
    parsed_niche = niche.strip() if niche else None
    return parsed_category, parsed_niche


def payment_succeeded_from_intent_status(status: str) -> bool:
    mapped = map_intent_status(status)
    return mapped == "succeeded"
