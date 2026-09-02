from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.gig import Gig, GigStatus
from app.models.legacy_shoot import (
    LegacyBooking,
    LegacyBookingStatus,
    LegacyBrief,
    LegacyMarketingConsent,
    LegacyPaymentMode,
    LegacyPrivacyLevel,
    LegacyReview,
    LegacyReviewResponse,
    LegacyReviewStage,
    LegacyTone,
    PremiumProduct,
    VaultAccessAction,
    VaultAccessLog,
    VaultItem,
    VaultItemStatus,
    VaultItemType,
)
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.services.analytics import log_event
from app.services.authz import get_user_roles
from app.services.notifications import enqueue_notification
from app.services.payment_intents import create_or_get_gig_payment_intent
from app.services.storage import create_presigned_get, create_presigned_put

settings = get_settings()

LEGACY_PRODUCT_CODE = "legacy_shoot"
LEGACY_BRIEF_REQUIRED_FIELDS = [
    "identity",
    "milestones",
    "people",
    "what_to_preserve",
    "desired_output",
    "reference_style",
    "boundaries",
    "consent_for_public_use",
]
TIER_RANK: dict[SkillTier, int] = {
    SkillTier.rookie: 1,
    SkillTier.skilled: 2,
    SkillTier.pro: 3,
    SkillTier.elite: 4,
    SkillTier.master: 5,
}


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def ensure_legacy_product(db: Session) -> PremiumProduct:
    row = db.execute(select(PremiumProduct).where(PremiumProduct.code == LEGACY_PRODUCT_CODE)).scalar_one_or_none()
    if row:
        return row
    row = PremiumProduct(
        code=LEGACY_PRODUCT_CODE,
        name_key="products.legacy_shoot.name",
        description_key="products.legacy_shoot.description",
        base_price_eur=Decimal("1490.00"),
        deposit_price_eur=Decimal("390.00"),
        duration_minutes=180,
        eligibility_rules={"min_tier": "elite", "niche": "portrait"},
    )
    db.add(row)
    db.flush()
    return row


def checkout_legacy_shoot(db: Session, *, client_user_id: uuid.UUID, payment_mode: LegacyPaymentMode) -> tuple[LegacyBooking, object]:
    product = ensure_legacy_product(db)
    price_full = Decimal(product.base_price_eur)
    amount_due = Decimal(product.deposit_price_eur or price_full) if payment_mode == LegacyPaymentMode.deposit else price_full

    niche_id = None
    niche_slug = (product.eligibility_rules or {}).get("niche")
    if niche_slug:
        niche = db.execute(select(Niche).where(Niche.slug == niche_slug)).scalar_one_or_none()
        if niche:
            niche_id = niche.id

    platform_fee = (amount_due * Decimal(max(0, int(settings.platform_fee_bps))) / Decimal("10000")).quantize(Decimal("0.01"))
    pro_gross = (amount_due - platform_fee).quantize(Decimal("0.01"))

    gig = Gig(
        client_user_id=client_user_id,
        # Temporary assignment until curation assigns a pro.
        pro_user_id=client_user_id,
        niche_id=niche_id,
        status=GigStatus.payment_pending,
        currency="EUR",
        amount_minimum=amount_due,
        amount_platform_fee=platform_fee,
        amount_pro_gross=pro_gross,
        meta={
            "type": "legacy_shoot",
            "legacy_product_code": LEGACY_PRODUCT_CODE,
            "legacy_price_eur": str(price_full),
            "legacy_dispute_default": "admin_review",
        },
    )
    db.add(gig)
    db.flush()

    booking = LegacyBooking(
        gig_id=gig.id,
        client_user_id=client_user_id,
        assigned_pro_user_id=None,
        status=LegacyBookingStatus.brief_pending,
        price_eur=price_full,
        payment_mode=payment_mode,
    )
    db.add(booking)
    db.flush()

    db.add(LegacyMarketingConsent(legacy_booking_id=booking.id, consent=False, channels=[]))
    payment, intent = create_or_get_gig_payment_intent(
        db,
        gig,
        payment_method_types=["card"],
        amount_override=amount_due,
        extra_metadata={
            "legacy_booking_id": str(booking.id),
            "legacy_product_code": LEGACY_PRODUCT_CODE,
            "payment_mode": payment_mode.value,
            "due_amount_eur": str(amount_due),
        },
    )
    payment.meta = {**(payment.meta or {}), "legacy_booking_id": str(booking.id)}

    for admin_user_id in settings.admin_user_id_set():
        enqueue_notification(
            db,
            user_id=admin_user_id,
            notification_type="legacy.order.created",
            payload={"title": "Premium legacy order", "body": "A new Legacy Shoot order requires curation."},
            reference_type="legacy_booking",
            reference_id=str(booking.id),
        )

    log_event(db, event_name="legacy.checkout_started", user_id=client_user_id, properties={"legacy_booking_id": str(booking.id), "payment_mode": payment_mode.value})
    log_event(db, event_name="legacy.paid", user_id=client_user_id, properties={"legacy_booking_id": str(booking.id), "status": payment.status.value})
    return booking, intent


def get_legacy_booking_or_404(db: Session, legacy_booking_id: uuid.UUID) -> LegacyBooking:
    row = db.get(LegacyBooking, legacy_booking_id)
    if not row:
        raise APIError(code="not_found", message="Legacy booking not found", status_code=404)
    return row


def can_access_legacy_booking(db: Session, *, booking: LegacyBooking, user_id: uuid.UUID) -> bool:
    if user_id in {booking.client_user_id, booking.assigned_pro_user_id}:
        return True
    roles = get_user_roles(db, user_id)
    return UserRoleType.admin in roles


def enforce_legacy_access(db: Session, *, booking: LegacyBooking, user_id: uuid.UUID) -> None:
    if not can_access_legacy_booking(db, booking=booking, user_id=user_id):
        raise APIError(code="forbidden", message="Not allowed for this legacy booking", status_code=403)


def validate_legacy_brief_answers(answers: dict) -> None:
    if not isinstance(answers, dict):
        raise APIError(code="validation_error", message="answers must be an object", status_code=422)
    missing = [key for key in LEGACY_BRIEF_REQUIRED_FIELDS if key not in answers]
    if missing:
        raise APIError(code="validation_error", message=f"Missing brief fields: {', '.join(missing)}", status_code=422)

    identity = answers.get("identity")
    milestones = answers.get("milestones")
    people = answers.get("people")
    desired_output = answers.get("desired_output")
    boundaries = answers.get("boundaries")
    consent_for_public_use = answers.get("consent_for_public_use")

    if not isinstance(identity, dict) or not identity.get("name"):
        raise APIError(code="validation_error", message="identity.name is required", status_code=422)
    if not isinstance(milestones, list):
        raise APIError(code="validation_error", message="milestones must be a list", status_code=422)
    if not isinstance(people, list):
        raise APIError(code="validation_error", message="people must be a list", status_code=422)
    if not isinstance(desired_output, dict):
        raise APIError(code="validation_error", message="desired_output must be an object", status_code=422)
    if not isinstance(boundaries, list):
        raise APIError(code="validation_error", message="boundaries must be a list", status_code=422)
    if not isinstance(consent_for_public_use, bool):
        raise APIError(code="validation_error", message="consent_for_public_use must be boolean", status_code=422)


def upsert_legacy_brief(
    db: Session,
    *,
    booking: LegacyBooking,
    answers: dict,
    tone: LegacyTone | None,
    privacy_level: LegacyPrivacyLevel,
    actor_user_id: uuid.UUID,
) -> LegacyBrief:
    if actor_user_id != booking.client_user_id:
        raise APIError(code="forbidden", message="Only client can submit legacy brief", status_code=403)
    validate_legacy_brief_answers(answers)
    row = db.get(LegacyBrief, booking.id)
    if row is None:
        row = LegacyBrief(legacy_booking_id=booking.id, answers=answers, tone=tone, privacy_level=privacy_level)
        db.add(row)
    else:
        row.answers = answers
        row.tone = tone
        row.privacy_level = privacy_level
        row.updated_at = now_utc()
    booking.status = LegacyBookingStatus.brief_submitted
    booking.updated_at = now_utc()

    for admin_user_id in settings.admin_user_id_set():
        enqueue_notification(
            db,
            user_id=admin_user_id,
            notification_type="legacy.brief.submitted",
            payload={"title": "Legacy brief submitted", "body": "A legacy brief is ready for pro assignment."},
            reference_type="legacy_booking",
            reference_id=str(booking.id),
        )
    log_event(db, event_name="legacy.brief_submitted", user_id=actor_user_id, properties={"legacy_booking_id": str(booking.id)})
    db.flush()
    return row


def _ensure_pro_eligible(db: Session, *, booking: LegacyBooking, pro_user_id: uuid.UUID, admin_override: bool) -> None:
    if admin_override:
        return
    product = ensure_legacy_product(db)
    rules = product.eligibility_rules or {}
    min_tier_raw = str(rules.get("min_tier") or "elite").lower()
    niche_slug = rules.get("niche")

    try:
        min_tier = SkillTier(min_tier_raw)
    except Exception as exc:
        raise APIError(code="validation_error", message="Invalid product eligibility tier", status_code=500) from exc

    if niche_slug:
        niche = db.execute(select(Niche).where(Niche.slug == niche_slug)).scalar_one_or_none()
        if not niche:
            raise APIError(code="validation_error", message="Eligibility niche not configured", status_code=409)
        skill = db.execute(
            select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro_user_id, ProNicheSkill.niche_id == niche.id)
        ).scalar_one_or_none()
        if not skill or TIER_RANK.get(skill.tier, 0) < TIER_RANK.get(min_tier, 0) or not bool(skill.verified):
            raise APIError(code="forbidden", message="Pro does not meet legacy eligibility", status_code=403)


def assign_legacy_pro(
    db: Session,
    *,
    booking: LegacyBooking,
    pro_user_id: uuid.UUID,
    admin_override: bool,
    actor_user_id: uuid.UUID,
) -> LegacyBooking:
    _ensure_pro_eligible(db, booking=booking, pro_user_id=pro_user_id, admin_override=admin_override)
    booking.assigned_pro_user_id = pro_user_id
    booking.status = LegacyBookingStatus.pro_assigned
    booking.updated_at = now_utc()

    gig = db.get(Gig, booking.gig_id)
    if gig:
        gig.pro_user_id = pro_user_id
        gig.meta = {**(gig.meta or {}), "legacy_assignment_override": bool(admin_override)}

    enqueue_notification(
        db,
        user_id=pro_user_id,
        notification_type="legacy.pro_assigned",
        payload={"title": "You were assigned a Legacy Shoot", "body": "Please review the legacy brief and prepare scheduling."},
        reference_type="legacy_booking",
        reference_id=str(booking.id),
    )
    enqueue_notification(
        db,
        user_id=booking.client_user_id,
        notification_type="legacy.pro_assigned",
        payload={"title": "Legacy pro assigned", "body": "Your premium pro has been assigned."},
        reference_type="legacy_booking",
        reference_id=str(booking.id),
    )
    log_event(db, event_name="legacy.pro_assigned", user_id=actor_user_id, properties={"legacy_booking_id": str(booking.id), "pro_user_id": str(pro_user_id), "override": admin_override})
    db.flush()
    return booking


def set_legacy_status(db: Session, *, booking: LegacyBooking, status: LegacyBookingStatus) -> LegacyBooking:
    booking.status = status
    booking.updated_at = now_utc()

    gig = db.get(Gig, booking.gig_id)
    if gig and status == LegacyBookingStatus.scheduled:
        gig.status = GigStatus.scheduled
    if gig and status in {LegacyBookingStatus.shoot_done, LegacyBookingStatus.edit_in_progress}:
        gig.status = GigStatus.shoot_done

    if status == LegacyBookingStatus.scheduled and booking.assigned_pro_user_id:
        enqueue_notification(
            db,
            user_id=booking.client_user_id,
            notification_type="legacy.schedule.confirmed",
            payload={"title": "Legacy Shoot scheduled", "body": "Your legacy session is now scheduled."},
            reference_type="legacy_booking",
            reference_id=str(booking.id),
        )
    if status == LegacyBookingStatus.delivered:
        enqueue_notification(
            db,
            user_id=booking.client_user_id,
            notification_type="legacy.final.delivered",
            payload={"title": "Legacy deliverables ready", "body": "Your legacy vault now contains final deliverables."},
            reference_type="legacy_booking",
            reference_id=str(booking.id),
        )
        log_event(db, event_name="legacy.delivered", user_id=booking.client_user_id, properties={"legacy_booking_id": str(booking.id)})
    db.flush()
    return booking


def log_vault_access(
    db: Session,
    *,
    booking_id: uuid.UUID,
    user_id: uuid.UUID | None,
    action: VaultAccessAction,
    vault_item_id: uuid.UUID | None,
) -> None:
    db.add(
        VaultAccessLog(
            legacy_booking_id=booking_id,
            user_id=user_id,
            action=action,
            vault_item_id=vault_item_id,
        )
    )


def _guess_ext(content_type: str) -> str:
    raw = (content_type or "").lower()
    if "pdf" in raw:
        return "pdf"
    if "mp4" in raw:
        return "mp4"
    if "mpeg" in raw or "mp3" in raw:
        return "mp3"
    if "wav" in raw:
        return "wav"
    if "jpeg" in raw or "jpg" in raw:
        return "jpg"
    if "png" in raw:
        return "png"
    return "bin"


def issue_vault_upload(
    db: Session,
    *,
    booking: LegacyBooking,
    actor_user_id: uuid.UUID,
    item_type: VaultItemType,
    content_type: str,
    bytes_size: int | None,
) -> tuple[VaultItem, str]:
    if actor_user_id != booking.assigned_pro_user_id and UserRoleType.admin not in get_user_roles(db, actor_user_id):
        raise APIError(code="forbidden", message="Only assigned pro or admin can upload vault items", status_code=403)

    ext = _guess_ext(content_type)
    storage_key = f"legacy/{booking.id}/{uuid.uuid4()}.{ext}"
    row = VaultItem(
        legacy_booking_id=booking.id,
        type=item_type,
        storage_key=storage_key,
        content_type=content_type,
        bytes=bytes_size,
        version=1,
        status=VaultItemStatus.draft,
        created_by=actor_user_id,
    )
    db.add(row)
    db.flush()
    url = create_presigned_put(storage_key, content_type=content_type, expires_in=900)
    log_vault_access(db, booking_id=booking.id, user_id=actor_user_id, action=VaultAccessAction.upload, vault_item_id=row.id)
    return row, url


def issue_vault_download(
    db: Session,
    *,
    booking: LegacyBooking,
    item: VaultItem,
    actor_user_id: uuid.UUID,
) -> str:
    enforce_legacy_access(db, booking=booking, user_id=actor_user_id)
    if item.legacy_booking_id != booking.id:
        raise APIError(code="forbidden", message="Vault item does not belong to booking", status_code=403)
    if item.status not in {VaultItemStatus.approved, VaultItemStatus.final, VaultItemStatus.submitted}:
        raise APIError(code="invalid_state", message="Vault item is not available for download", status_code=409)
    log_vault_access(db, booking_id=booking.id, user_id=actor_user_id, action=VaultAccessAction.download, vault_item_id=item.id)
    return create_presigned_get(item.storage_key, expires_in=900)


def submit_legacy_review(
    db: Session,
    *,
    booking: LegacyBooking,
    actor_user_id: uuid.UUID,
    stage: LegacyReviewStage,
    vault_item_ids: list[uuid.UUID],
) -> LegacyReview:
    if actor_user_id != booking.assigned_pro_user_id and UserRoleType.admin not in get_user_roles(db, actor_user_id):
        raise APIError(code="forbidden", message="Only assigned pro or admin can submit legacy review", status_code=403)
    if not vault_item_ids:
        raise APIError(code="validation_error", message="vault_item_ids cannot be empty", status_code=422)

    rows = db.execute(select(VaultItem).where(VaultItem.id.in_(vault_item_ids))).scalars().all()
    if len(rows) != len(set(vault_item_ids)) or any(item.legacy_booking_id != booking.id for item in rows):
        raise APIError(code="validation_error", message="Invalid vault_item_ids", status_code=422)

    for item in rows:
        item.status = VaultItemStatus.submitted

    review = LegacyReview(
        legacy_booking_id=booking.id,
        stage=stage,
        submitted_by=actor_user_id,
        client_response=LegacyReviewResponse.pending,
        client_notes=None,
        item_ids=[str(item_id) for item_id in vault_item_ids],
    )
    db.add(review)
    booking.status = LegacyBookingStatus.client_review
    booking.updated_at = now_utc()

    enqueue_notification(
        db,
        user_id=booking.client_user_id,
        notification_type="legacy.review.requested",
        payload={"title": "Legacy review requested", "body": "Please review and approve your legacy deliverables."},
        reference_type="legacy_review",
        reference_id=str(review.id),
    )
    log_event(db, event_name="legacy.review_requested", user_id=actor_user_id, properties={"legacy_booking_id": str(booking.id), "review_id": str(review.id), "stage": stage.value})
    db.flush()
    return review


def respond_legacy_review(
    db: Session,
    *,
    booking: LegacyBooking,
    review: LegacyReview,
    actor_user_id: uuid.UUID,
    response: LegacyReviewResponse,
    notes: str | None,
) -> LegacyReview:
    if actor_user_id != booking.client_user_id:
        raise APIError(code="forbidden", message="Only client can respond to legacy review", status_code=403)
    if review.legacy_booking_id != booking.id:
        raise APIError(code="forbidden", message="Review does not belong to booking", status_code=403)

    review.client_response = response
    review.client_notes = notes
    review.updated_at = now_utc()

    item_ids = [uuid.UUID(value) for value in (review.item_ids or []) if value]
    items = db.execute(select(VaultItem).where(VaultItem.id.in_(item_ids))).scalars().all() if item_ids else []

    if response == LegacyReviewResponse.approved:
        for item in items:
            item.status = VaultItemStatus.final if review.stage == LegacyReviewStage.final_delivery else VaultItemStatus.approved
        if review.stage == LegacyReviewStage.final_delivery:
            booking.status = LegacyBookingStatus.delivered
        else:
            booking.status = LegacyBookingStatus.approved
    elif response in {LegacyReviewResponse.changes_requested, LegacyReviewResponse.rejected}:
        for item in items:
            item.status = VaultItemStatus.rejected
        booking.status = LegacyBookingStatus.edit_in_progress
        if booking.assigned_pro_user_id:
            enqueue_notification(
                db,
                user_id=booking.assigned_pro_user_id,
                notification_type="legacy.changes.requested",
                payload={"title": "Legacy changes requested", "body": "Client requested changes on legacy deliverables."},
                reference_type="legacy_review",
                reference_id=str(review.id),
            )
    booking.updated_at = now_utc()
    db.flush()
    return review


def upsert_marketing_consent(
    db: Session,
    *,
    booking: LegacyBooking,
    actor_user_id: uuid.UUID,
    consent: bool,
    channels: list[str],
) -> LegacyMarketingConsent:
    if actor_user_id != booking.client_user_id:
        raise APIError(code="forbidden", message="Only client can update marketing consent", status_code=403)
    row = db.get(LegacyMarketingConsent, booking.id)
    if row is None:
        row = LegacyMarketingConsent(legacy_booking_id=booking.id, consent=False, channels=[])
        db.add(row)
    row.consent = bool(consent)
    row.channels = sorted(set(channels or [])) if consent else []
    row.updated_at = now_utc()
    db.flush()
    return row
