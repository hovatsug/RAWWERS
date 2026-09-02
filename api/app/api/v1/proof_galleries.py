from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP

import stripe
from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import ProProfile, UserRoleType
from app.models.gallery import (
    ClientSelection,
    ClientSelectionItem,
    ProofGallery,
    ProofGalleryItem,
    ProofGalleryStatus,
    SelectionStatus,
    UpsellPurchase,
    UpsellPurchaseStatus,
)
from app.models.gig import Gig, GigStatus, StripePaymentKind
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaVariant, ObjectStatus
from app.models.media_rights import GigEntitlementType, MediaDerivativeKind
from app.models.reward import DiscountRedemption, DiscountRedemptionStatus, RedemptionContextType
from app.schemas.gallery import (
    AddGalleryItemsRequest,
    CreateProofGalleryRequest,
    DownloadsResponse,
    GalleryDetailResponse,
    GalleryItemView,
    ProofGalleryResponse,
    PublishGalleryResponse,
    SaveSelectionRequest,
    SelectionResponse,
    SubmitSelectionResponse,
    UpsellCreateIntentRequest,
    UpsellCreateIntentResponse,
)
from app.schemas.media import CurrentUser
from app.services.audit import add_admin_audit_log
from app.services.authz import get_user_roles
from app.services.analytics import log_event
from app.services.reminders import cancel_proof_selection_reminders, schedule_proof_selection_reminders
from app.services.followups import schedule_followups
from app.services.metrics import observe_business_event
from app.services.outbox import enqueue_outbox_event
from app.services.rewards import reserve_points_for_discount
from app.services.client_rewards_pricing import (
    compute_extra_image_unit_price,
    enforce_max_extra_images,
    increment_share_link_conversion,
    upsert_extra_image_purchase_snapshot,
)
from app.services.media_rights import upsert_gig_entitlement
from app.services.storage import create_presigned_get
from app.services.disputes import upsert_delivery_sla_snapshot
from app.services.gallery_completion import finalize_gallery_and_complete_gig
from app.services.package_pricing import compute_package_total, enforce_minimum_selection_count
from app.services.payment_intents import create_or_get_gig_payment_intent

settings = get_settings()
router = APIRouter(tags=["proof_galleries"])


@router.post("/gigs/{gig_id}/proof-gallery", response_model=ProofGalleryResponse)
def create_proof_gallery(
    gig_id: uuid.UUID,
    body: CreateProofGalleryRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProofGalleryResponse:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    if gig.pro_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only gig pro can create proof gallery", status_code=403)

    existing = db.execute(select(ProofGallery).where(ProofGallery.gig_id == gig_id)).scalar_one_or_none()
    if existing:
        return _gallery_to_response(existing)

    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=gig.pro_user_id,
        client_user_id=gig.client_user_id,
        included_photos=body.included_photos,
        extra_photo_price=body.extra_photo_price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP),
        currency=gig.currency,
        status=ProofGalleryStatus.draft,
    )
    db.add(gallery)
    db.commit()
    db.refresh(gallery)
    return _gallery_to_response(gallery)


@router.post("/proof-galleries/{gallery_id}/items", response_model=ProofGalleryResponse)
def add_gallery_items(
    gallery_id: uuid.UUID,
    body: AddGalleryItemsRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProofGalleryResponse:
    gallery = db.get(ProofGallery, gallery_id)
    if not gallery:
        raise APIError(code="not_found", message="Gallery not found", status_code=404)
    if gallery.pro_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only pro can add gallery items", status_code=403)

    next_sort_order = body.sort_order_optional
    if next_sort_order is None:
        max_sort = db.execute(select(func.max(ProofGalleryItem.sort_order)).where(ProofGalleryItem.gallery_id == gallery_id)).scalar_one()
        next_sort_order = (max_sort or 0) + 1

    for media_asset_id in body.media_asset_ids:
        asset = db.get(MediaAsset, media_asset_id)
        if not asset:
            raise APIError(code="not_found", message=f"Media asset {media_asset_id} not found", status_code=404)
        if asset.kind != MediaKind.photo or asset.owner_user_id != user.user_id:
            raise APIError(code="forbidden", message="Gallery items must be pro-owned photos", status_code=403)

        wm_obj = db.execute(
            select(MediaObject).where(
                MediaObject.media_asset_id == asset.id,
                MediaObject.variant == MediaVariant.watermark_preview,
                MediaObject.status == ObjectStatus.ready,
            )
        ).scalar_one_or_none()
        if not wm_obj:
            raise APIError(code="validation_error", message="Each item needs ready watermark_preview variant", status_code=422)

        exists = db.execute(
            select(ProofGalleryItem).where(
                ProofGalleryItem.gallery_id == gallery_id,
                ProofGalleryItem.media_asset_id == media_asset_id,
            )
        ).scalar_one_or_none()
        if exists:
            continue

        db.add(
            ProofGalleryItem(
                gallery_id=gallery_id,
                media_asset_id=media_asset_id,
                sort_order=next_sort_order,
            )
        )
        next_sort_order += 1

    db.commit()
    db.refresh(gallery)
    return _gallery_to_response(gallery)


@router.post("/proof-galleries/{gallery_id}/publish", response_model=PublishGalleryResponse)
def publish_gallery(
    gallery_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PublishGalleryResponse:
    gallery = db.get(ProofGallery, gallery_id)
    if not gallery:
        raise APIError(code="not_found", message="Gallery not found", status_code=404)
    if gallery.pro_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only pro can publish gallery", status_code=403)

    count = db.execute(select(func.count()).select_from(ProofGalleryItem).where(ProofGalleryItem.gallery_id == gallery_id)).scalar_one()
    if count < 1:
        raise APIError(code="validation_error", message="Gallery must contain at least one item", status_code=422)

    gallery.status = ProofGalleryStatus.published
    gallery.published_at = datetime.now(timezone.utc)
    gig = db.get(Gig, gallery.gig_id)
    if gig:
        upsert_delivery_sla_snapshot(db, gig=gig, proofs_published_at=gallery.published_at)

    upsert_gig_entitlement(
        db,
        gig_id=gallery.gig_id,
        user_id=gallery.client_user_id,
        entitlement_type=GigEntitlementType.view_proofs,
        metadata={"source": "proof_gallery_publish", "gallery_id": str(gallery.id)},
    )
    upsert_gig_entitlement(
        db,
        gig_id=gallery.gig_id,
        user_id=gallery.client_user_id,
        entitlement_type=GigEntitlementType.share_link_manage,
        metadata={"source": "proof_gallery_publish", "gallery_id": str(gallery.id)},
    )
    upsert_gig_entitlement(
        db,
        gig_id=gallery.gig_id,
        user_id=gallery.pro_user_id,
        entitlement_type=GigEntitlementType.share_link_manage,
        metadata={"source": "proof_gallery_publish", "gallery_id": str(gallery.id)},
    )

    media_asset_ids = db.execute(select(ProofGalleryItem.media_asset_id).where(ProofGalleryItem.gallery_id == gallery.id)).scalars().all()
    for media_asset_id in media_asset_ids:
        for derivative_kind in (
            MediaDerivativeKind.preview_watermarked.value,
            MediaDerivativeKind.web_res.value,
            MediaDerivativeKind.thumbnail.value,
        ):
            enqueue_outbox_event(
                db,
                topic="media.derivative.generate",
                payload={"media_asset_id": str(media_asset_id), "kind": derivative_kind},
                idempotency_key=f"media-derivative:{media_asset_id}:{derivative_kind}",
                idempotency_scope="media_derivative",
            )

    add_admin_audit_log(
        db,
        actor_user_id=user.user_id,
        target_type="gallery",
        target_id=str(gallery.id),
        action="gallery_published",
        reason=None,
    )

    schedule_proof_selection_reminders(db, gallery.client_user_id, gallery.id)
    schedule_followups(
        db,
        trigger="proof_gallery.published.client",
        user_id=gallery.client_user_id,
        target_type="gallery",
        target_id=gallery.id,
    )

    db.commit()
    observe_business_event("proof_gallery_published")
    return PublishGalleryResponse(ok=True, status=gallery.status)


@router.get("/proof-galleries/{gallery_id}", response_model=GalleryDetailResponse)
def get_gallery(
    gallery_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GalleryDetailResponse:
    gallery = db.get(ProofGallery, gallery_id)
    if not gallery:
        raise APIError(code="not_found", message="Gallery not found", status_code=404)

    is_admin = _is_admin(db, user.user_id)
    is_participant = user.user_id in {gallery.client_user_id, gallery.pro_user_id}
    if not is_admin and not is_participant:
        raise APIError(code="forbidden", message="Not allowed to access this gallery", status_code=403)

    if gallery.status == ProofGalleryStatus.draft and user.user_id == gallery.client_user_id and not is_admin:
        raise APIError(code="forbidden", message="Gallery not published yet", status_code=403)

    items = db.execute(
        select(ProofGalleryItem).where(ProofGalleryItem.gallery_id == gallery_id).order_by(ProofGalleryItem.sort_order.asc())
    ).scalars().all()

    views: list[GalleryItemView] = []
    for item in items:
        thumb = db.execute(
            select(MediaObject).where(
                MediaObject.media_asset_id == item.media_asset_id,
                MediaObject.variant == MediaVariant.thumbnail,
                MediaObject.status == ObjectStatus.ready,
            )
        ).scalar_one_or_none()
        wm = db.execute(
            select(MediaObject).where(
                MediaObject.media_asset_id == item.media_asset_id,
                MediaObject.variant == MediaVariant.watermark_preview,
                MediaObject.status == ObjectStatus.ready,
            )
        ).scalar_one_or_none()

        views.append(
            GalleryItemView(
                media_asset_id=item.media_asset_id,
                sort_order=item.sort_order,
                thumbnail_url=create_presigned_get(thumb.storage_key, expires_in=300) if thumb else None,
                watermark_preview_url=create_presigned_get(wm.storage_key, expires_in=300) if wm else None,
            )
        )

    if user.user_id == gallery.client_user_id:
        gig = db.get(Gig, gallery.gig_id)
        pro_profile = db.get(ProProfile, gig.pro_user_id) if gig else None
        log_event(
            db,
            event_name="client.proofs_viewed",
            user_id=user.user_id,
            properties={"gallery_id": str(gallery.id), "gig_id": str(gallery.gig_id), "country": pro_profile.country if pro_profile else None, "city": pro_profile.city if pro_profile else None},
        )
        db.commit()

    return GalleryDetailResponse(gallery=_gallery_to_response(gallery), items=views)


@router.post("/proof-galleries/{gallery_id}/selections", response_model=SelectionResponse)
def save_selection(
    gallery_id: uuid.UUID,
    body: SaveSelectionRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> SelectionResponse:
    gallery = db.get(ProofGallery, gallery_id)
    if not gallery:
        raise APIError(code="not_found", message="Gallery not found", status_code=404)
    if gallery.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only client can save selection", status_code=403)
    if gallery.status not in {ProofGalleryStatus.published, ProofGalleryStatus.selection_submitted}:
        raise APIError(code="invalid_state", message="Gallery is not open for selection", status_code=409)

    _validate_selected_items_belong_to_gallery(db, gallery.id, body.media_asset_ids)

    latest_version = db.execute(
        select(func.max(ClientSelection.version)).where(ClientSelection.gallery_id == gallery_id)
    ).scalar_one()
    version = (latest_version or 0) + 1

    selection = ClientSelection(
        gallery_id=gallery_id,
        client_user_id=user.user_id,
        version=version,
        status=SelectionStatus.draft,
    )
    db.add(selection)
    db.flush()

    for media_asset_id in body.media_asset_ids:
        db.add(ClientSelectionItem(selection_id=selection.id, media_asset_id=media_asset_id))

    db.commit()

    return SelectionResponse(
        selection_id=selection.id,
        version=selection.version,
        status=selection.status,
        selected_count=len(body.media_asset_ids),
    )


@router.post("/proof-galleries/{gallery_id}/selections/submit", response_model=SubmitSelectionResponse)
def submit_selection(
    gallery_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> SubmitSelectionResponse:
    gallery = db.get(ProofGallery, gallery_id)
    if not gallery:
        raise APIError(code="not_found", message="Gallery not found", status_code=404)
    if gallery.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only client can submit selection", status_code=403)

    selection = _latest_selection(db, gallery_id)
    if not selection or selection.status != SelectionStatus.draft:
        raise APIError(code="invalid_state", message="No draft selection to submit", status_code=409)

    selected_count = db.execute(
        select(func.count()).select_from(ClientSelectionItem).where(ClientSelectionItem.selection_id == selection.id)
    ).scalar_one()
    enforce_minimum_selection_count(selected_count)
    extras_count = max(0, selected_count - gallery.included_photos)

    gig = db.get(Gig, gallery.gig_id)

    difference_amount = Decimal("0.00")
    if gig and gig.niche_id and gig.entry_rate is not None:
        amount_final = compute_package_total(db, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=selected_count)
        gig.amount_final = amount_final
        difference_amount = max(Decimal("0.00"), (amount_final - gig.amount_minimum).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP))
    difference_required = difference_amount > 0

    selection.status = SelectionStatus.submitted
    included_unlock_count = min(gallery.included_photos, selected_count)
    upsert_gig_entitlement(
        db,
        gig_id=gallery.gig_id,
        user_id=gallery.client_user_id,
        entitlement_type=GigEntitlementType.download_finals,
        quantity_limit=included_unlock_count,
        metadata={"source": "selection_submit", "selection_id": str(selection.id)},
    )

    add_admin_audit_log(
        db,
        actor_user_id=user.user_id,
        target_type="gallery",
        target_id=str(gallery.id),
        action="selection_submitted",
        reason=None,
        metadata={
            "selection_id": str(selection.id),
            "selected_count": selected_count,
            "extras_count": extras_count,
            "difference_amount": str(difference_amount),
        },
    )

    difference_payment_intent_id: str | None = None
    difference_payment_intent_client_secret: str | None = None
    if difference_required and gig:
        difference_payment, difference_pi = create_or_get_gig_payment_intent(
            db,
            gig,
            amount_override=difference_amount,
            kind=StripePaymentKind.difference,
            extra_metadata={"selection_id": str(selection.id), "gallery_id": str(gallery.id)},
        )
        difference_payment_intent_id = difference_payment.stripe_payment_intent_id
        difference_payment_intent_client_secret = difference_pi.client_secret

    if extras_count > 0:
        cancel_proof_selection_reminders(db, gallery.client_user_id, gallery.id)
        purchase, client_secret, _ = _ensure_upsell_intent(db, gallery, selection, extras_count, points_to_spend=None)
        db.commit()
        return SubmitSelectionResponse(
            selection_id=selection.id,
            selected_count=selected_count,
            included_photos=gallery.included_photos,
            extras_count=extras_count,
            gallery_status=gallery.status,
            upsell_required=True,
            payment_intent_id=purchase.stripe_payment_intent_id,
            payment_intent_client_secret=client_secret,
            difference_required=difference_required,
            difference_amount=difference_amount if difference_required else None,
            difference_payment_intent_id=difference_payment_intent_id,
            difference_payment_intent_client_secret=difference_payment_intent_client_secret,
        )

    if difference_required:
        cancel_proof_selection_reminders(db, gallery.client_user_id, gallery.id)
        db.commit()
        return SubmitSelectionResponse(
            selection_id=selection.id,
            selected_count=selected_count,
            included_photos=gallery.included_photos,
            extras_count=0,
            gallery_status=gallery.status,
            upsell_required=False,
            difference_required=True,
            difference_amount=difference_amount,
            difference_payment_intent_id=difference_payment_intent_id,
            difference_payment_intent_client_secret=difference_payment_intent_client_secret,
        )

    # Neither extras nor a difference charge is pending - the booking closes now.
    if gig:
        finalize_gallery_and_complete_gig(db, gallery=gallery, gig=gig, selection=selection)
    else:
        gallery.status = ProofGalleryStatus.selection_submitted
        cancel_proof_selection_reminders(db, gallery.client_user_id, gallery.id)
    db.commit()
    observe_business_event("proof_selection_submitted")
    return SubmitSelectionResponse(
        selection_id=selection.id,
        selected_count=selected_count,
        included_photos=gallery.included_photos,
        extras_count=0,
        gallery_status=gallery.status,
        upsell_required=False,
        difference_required=False,
        difference_amount=None,
    )


@router.post("/proof-galleries/{gallery_id}/upsell/create-intent", response_model=UpsellCreateIntentResponse)
def create_upsell_intent(
    gallery_id: uuid.UUID,
    body: UpsellCreateIntentRequest | None = None,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> UpsellCreateIntentResponse:
    gallery = db.get(ProofGallery, gallery_id)
    if not gallery:
        raise APIError(code="not_found", message="Gallery not found", status_code=404)
    if gallery.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only client can create upsell intent", status_code=403)

    selection = _latest_selection(db, gallery_id)
    if not selection:
        raise APIError(code="invalid_state", message="No selection found", status_code=409)

    selected_count = db.execute(
        select(func.count()).select_from(ClientSelectionItem).where(ClientSelectionItem.selection_id == selection.id)
    ).scalar_one()
    extras_count = max(0, selected_count - gallery.included_photos)
    if extras_count <= 0:
        raise APIError(code="invalid_state", message="No extras to purchase", status_code=409)

    points_to_spend = body.points_to_spend if body else None
    purchase, client_secret, redemption = _ensure_upsell_intent(
        db,
        gallery,
        selection,
        extras_count,
        points_to_spend=points_to_spend,
        share_link_id=(body.share_link_id if body else None),
    )
    db.commit()
    return UpsellCreateIntentResponse(
        purchase_id=purchase.id,
        payment_intent_id=purchase.stripe_payment_intent_id or "",
        payment_intent_client_secret=client_secret,
        status=purchase.status,
        discount_amount=redemption.discount_amount if redemption else None,
        points_spent=redemption.points_spent if redemption else None,
    )


@router.get("/proof-galleries/{gallery_id}/downloads", response_model=DownloadsResponse)
def get_download_links(
    gallery_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> DownloadsResponse:
    gallery = db.get(ProofGallery, gallery_id)
    if not gallery:
        raise APIError(code="not_found", message="Gallery not found", status_code=404)

    is_admin = _is_admin(db, user.user_id)
    if not is_admin and user.user_id != gallery.client_user_id:
        raise APIError(code="forbidden", message="Only client or admin can download originals", status_code=403)

    _enforce_download_rate_limit(db, user.user_id, gallery.id)

    latest_submitted = db.execute(
        select(ClientSelection)
        .where(ClientSelection.gallery_id == gallery_id, ClientSelection.status.in_([SelectionStatus.submitted, SelectionStatus.locked]))
        .order_by(ClientSelection.version.desc())
    ).scalars().first()

    if not latest_submitted:
        raise APIError(code="invalid_state", message="Selection not submitted", status_code=409)

    selected_item_ids = db.execute(
        select(ClientSelectionItem.media_asset_id).where(ClientSelectionItem.selection_id == latest_submitted.id)
    ).scalars().all()
    if not selected_item_ids:
        return DownloadsResponse(gallery_id=gallery.id, urls={})

    unlocked_ids: list[uuid.UUID]
    if is_admin:
        unlocked_ids = list(selected_item_ids)
    else:
        extras_needed = max(0, len(selected_item_ids) - gallery.included_photos)
        purchase = db.execute(
            select(UpsellPurchase)
            .where(UpsellPurchase.gallery_id == gallery_id, UpsellPurchase.selection_id == latest_submitted.id)
            .order_by(UpsellPurchase.created_at.desc())
        ).scalars().first()

        if extras_needed > 0 and (not purchase or purchase.status != UpsellPurchaseStatus.succeeded):
            raise APIError(code="payment_required", message="Upsell purchase not completed", status_code=402)

        if extras_needed > 0:
            unlocked_ids = list(selected_item_ids)
        else:
            ordered_ids = _ordered_gallery_asset_ids(db, gallery.id)
            selected_set = set(selected_item_ids)
            unlocked_ids = [asset_id for asset_id in ordered_ids if asset_id in selected_set][: gallery.included_photos]

    urls: dict[str, str] = {}
    for asset_id in unlocked_ids:
        original = db.execute(
            select(MediaObject).where(
                MediaObject.media_asset_id == asset_id,
                MediaObject.variant == MediaVariant.original,
                MediaObject.status == ObjectStatus.ready,
            )
        ).scalar_one_or_none()
        if original:
            urls[str(asset_id)] = create_presigned_get(original.storage_key, expires_in=60)

    add_admin_audit_log(
        db,
        actor_user_id=user.user_id,
        target_type="gallery",
        target_id=str(gallery.id),
        action="downloads_generated",
        reason=None,
        metadata={"count": len(urls), "is_admin": is_admin},
    )
    db.commit()

    return DownloadsResponse(gallery_id=gallery.id, urls=urls)


def _ensure_upsell_intent(
    db: Session,
    gallery: ProofGallery,
    selection: ClientSelection,
    extras_count: int,
    points_to_spend: int | None,
    share_link_id: uuid.UUID | None = None,
) -> tuple[UpsellPurchase, str, DiscountRedemption | None]:
    gig = db.get(Gig, gallery.gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)

    configured_unit_price, applied_unit_price, policy_min, policy_max, tier = compute_extra_image_unit_price(
        db,
        gig=gig,
        gallery=gallery,
    )
    enforce_max_extra_images(db, gig=gig, tier=tier, extra_images=extras_count)
    if applied_unit_price != configured_unit_price:
        log_event(
            db,
            event_name="extra_images.price_clamped",
            user_id=gig.pro_user_id,
            properties={
                "gig_id": str(gig.id),
                "niche_id": str(gig.niche_id) if gig.niche_id else None,
                "tier": tier.value,
                "configured_unit_price": str(configured_unit_price),
                "applied_unit_price": str(applied_unit_price),
            },
        )

    subtotal = (applied_unit_price * Decimal(extras_count)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    existing = db.execute(
        select(UpsellPurchase)
        .where(UpsellPurchase.selection_id == selection.id)
        .order_by(UpsellPurchase.created_at.desc())
    ).scalars().first()

    if existing and existing.stripe_payment_intent_id:
        pi = stripe.PaymentIntent.retrieve(existing.stripe_payment_intent_id)
        redemption_existing = db.execute(
            select(DiscountRedemption).where(
                DiscountRedemption.user_id == gallery.client_user_id,
                DiscountRedemption.context_type == RedemptionContextType.upsell_purchase,
                DiscountRedemption.context_id == existing.id,
                DiscountRedemption.status.in_([DiscountRedemptionStatus.reserved, DiscountRedemptionStatus.applied]),
            )
        ).scalar_one_or_none()
        if redemption_existing:
            payable_existing = max(Decimal("0.01"), subtotal - redemption_existing.discount_amount)
            existing.amount = payable_existing
        else:
            existing.amount = subtotal
        existing.extra_count = extras_count
        existing.meta = {
            **existing.meta,
            "selection_version": selection.version,
            "unit_price_applied": str(applied_unit_price),
            "unit_price_configured": str(configured_unit_price),
            "policy_unit_price_min": str(policy_min),
            "policy_unit_price_max": str(policy_max) if policy_max is not None else None,
            "subtotal": str(subtotal),
            "share_link_id": str(share_link_id) if share_link_id else None,
        }
        upsert_extra_image_purchase_snapshot(
            db,
            gig=gig,
            gallery=gallery,
            selected_images=gallery.included_photos + extras_count,
            extra_images=extras_count,
            unit_price_configured=configured_unit_price,
            unit_price_applied=applied_unit_price,
            policy_min=policy_min,
            policy_max=policy_max,
            subtotal=subtotal,
            discounts_total=redemption_existing.discount_amount if redemption_existing else Decimal("0.00"),
            total=existing.amount,
            points_spent=redemption_existing.points_spent if redemption_existing else 0,
            stripe_payment_intent_id=existing.stripe_payment_intent_id,
            share_link_id=share_link_id,
        )
        return existing, pi.client_secret, redemption_existing

    selected_count = db.execute(
        select(func.count()).select_from(ClientSelectionItem).where(ClientSelectionItem.selection_id == selection.id)
    ).scalar_one()

    if existing:
        pi = stripe.PaymentIntent.create(
            amount=int((subtotal * Decimal("100")).quantize(Decimal("1"))),
            currency=gallery.currency.lower(),
            payment_method_types=["card"],
            metadata={
                "proof_gallery_id": str(gallery.id),
                "selection_id": str(selection.id),
                "type": "upsell",
                "share_link_id": str(share_link_id) if share_link_id else "",
            },
            automatic_payment_methods={"enabled": True},
            idempotency_key=f"gallery:{gallery.id}:selection:{selection.id}:upsell",
        )
        existing.extra_count = extras_count
        existing.amount = subtotal
        existing.currency = gallery.currency
        existing.status = UpsellPurchaseStatus.pending
        existing.stripe_payment_intent_id = pi.id
        existing.meta = {
            **existing.meta,
            "selection_version": selection.version,
            "unit_price_applied": str(applied_unit_price),
            "unit_price_configured": str(configured_unit_price),
            "policy_unit_price_min": str(policy_min),
            "policy_unit_price_max": str(policy_max) if policy_max is not None else None,
            "subtotal": str(subtotal),
            "share_link_id": str(share_link_id) if share_link_id else None,
        }
        purchase = existing
    else:
        pi = stripe.PaymentIntent.create(
            amount=int((subtotal * Decimal("100")).quantize(Decimal("1"))),
            currency=gallery.currency.lower(),
            payment_method_types=["card"],
            metadata={
                "proof_gallery_id": str(gallery.id),
                "selection_id": str(selection.id),
                "type": "upsell",
                "share_link_id": str(share_link_id) if share_link_id else "",
            },
            automatic_payment_methods={"enabled": True},
            idempotency_key=f"gallery:{gallery.id}:selection:{selection.id}:upsell",
        )
        purchase = UpsellPurchase(
            gallery_id=gallery.id,
            selection_id=selection.id,
            extra_count=extras_count,
            amount=subtotal,
            currency=gallery.currency,
            status=UpsellPurchaseStatus.pending,
            stripe_payment_intent_id=pi.id,
            meta={
                "selection_version": selection.version,
                "unit_price_applied": str(applied_unit_price),
                "unit_price_configured": str(configured_unit_price),
                "policy_unit_price_min": str(policy_min),
                "policy_unit_price_max": str(policy_max) if policy_max is not None else None,
                "subtotal": str(subtotal),
                "share_link_id": str(share_link_id) if share_link_id else None,
            },
        )
        db.add(purchase)
        db.flush()

    redemption = None
    payable_amount = subtotal
    if points_to_spend:
        redemption = reserve_points_for_discount(
            db,
            user_id=gallery.client_user_id,
            context_type=RedemptionContextType.upsell_purchase,
            context_id=purchase.id,
            points=points_to_spend,
            payment_amount=subtotal,
            currency=gallery.currency,
            metadata={"source": "upsell_create_intent"},
        )
        payable_amount = max(Decimal("0.01"), subtotal - redemption.discount_amount)
        purchase.amount = payable_amount
        log_event(
            db,
            event_name="reward.spent",
            user_id=gallery.client_user_id,
            properties={
                "context_type": "upsell_purchase",
                "context_id": str(purchase.id),
                "points_spent": redemption.points_spent,
                "discount_amount": str(redemption.discount_amount),
            },
        )
    else:
        purchase.amount = payable_amount

    upsert_extra_image_purchase_snapshot(
        db,
        gig=gig,
        gallery=gallery,
        selected_images=int(selected_count),
        extra_images=extras_count,
        unit_price_configured=configured_unit_price,
        unit_price_applied=applied_unit_price,
        policy_min=policy_min,
        policy_max=policy_max,
        subtotal=subtotal,
        discounts_total=redemption.discount_amount if redemption else Decimal("0.00"),
        total=payable_amount,
        points_spent=redemption.points_spent if redemption else 0,
        stripe_payment_intent_id=pi.id,
        share_link_id=share_link_id,
    )

    add_admin_audit_log(
        db,
        actor_user_id=gallery.client_user_id,
        target_type="gallery",
        target_id=str(gallery.id),
        action="upsell_intent_created",
        reason=None,
        metadata={
            "selection_id": str(selection.id),
            "extras_count": extras_count,
            "configured_unit_price": str(configured_unit_price),
            "applied_unit_price": str(applied_unit_price),
            "subtotal": str(subtotal),
            "total": str(payable_amount),
            "tier": tier.value,
        },
    )
    log_event(
        db,
        event_name="extra_images.purchased",
        user_id=gallery.client_user_id,
        properties={
            "gig_id": str(gig.id),
            "selection_id": str(selection.id),
            "extra_images": extras_count,
            "subtotal": str(subtotal),
            "total": str(payable_amount),
        },
    )
    pro_profile = db.get(ProProfile, gig.pro_user_id)
    log_event(
        db,
        event_name="client.extras_purchased",
        user_id=gallery.client_user_id,
        properties={
            "gig_id": str(gig.id),
            "selection_id": str(selection.id),
            "extra_images": extras_count,
            "country": pro_profile.country if pro_profile else None,
            "city": pro_profile.city if pro_profile else None,
        },
    )
    if share_link_id:
        increment_share_link_conversion(db, share_link_id=share_link_id, count=1)

    return purchase, pi.client_secret, redemption


def _latest_selection(db: Session, gallery_id: uuid.UUID) -> ClientSelection | None:
    return db.execute(
        select(ClientSelection).where(ClientSelection.gallery_id == gallery_id).order_by(ClientSelection.version.desc())
    ).scalars().first()


def _validate_selected_items_belong_to_gallery(db: Session, gallery_id: uuid.UUID, media_asset_ids: list[uuid.UUID]) -> None:
    if not media_asset_ids:
        return
    gallery_item_ids = set(
        db.execute(
            select(ProofGalleryItem.media_asset_id).where(ProofGalleryItem.gallery_id == gallery_id)
        ).scalars().all()
    )
    missing = [str(mid) for mid in media_asset_ids if mid not in gallery_item_ids]
    if missing:
        raise APIError(code="validation_error", message="Selection includes assets not in gallery", status_code=422, details={"missing": missing})


def _ordered_gallery_asset_ids(db: Session, gallery_id: uuid.UUID) -> list[uuid.UUID]:
    return db.execute(
        select(ProofGalleryItem.media_asset_id)
        .where(ProofGalleryItem.gallery_id == gallery_id)
        .order_by(ProofGalleryItem.sort_order.asc(), ProofGalleryItem.created_at.asc())
    ).scalars().all()


def _is_admin(db: Session, user_id: uuid.UUID) -> bool:
    roles = get_user_roles(db, user_id)
    return UserRoleType.admin in roles


def _gallery_to_response(gallery: ProofGallery) -> ProofGalleryResponse:
    return ProofGalleryResponse(
        id=gallery.id,
        gig_id=gallery.gig_id,
        pro_user_id=gallery.pro_user_id,
        client_user_id=gallery.client_user_id,
        included_photos=gallery.included_photos,
        extra_photo_price=gallery.extra_photo_price,
        currency=gallery.currency,
        status=gallery.status,
        published_at=gallery.published_at,
        created_at=gallery.created_at,
        updated_at=gallery.updated_at,
    )


def _enforce_download_rate_limit(db: Session, user_id: uuid.UUID, gallery_id: uuid.UUID, limit_per_minute: int = 20) -> None:
    since = datetime.now(timezone.utc) - timedelta(minutes=1)
    # Count via audit log table for this user/gallery action.
    from app.models.admin import AdminAuditLog

    count = db.execute(
        select(func.count())
        .select_from(AdminAuditLog)
        .where(
            AdminAuditLog.actor_user_id == user_id,
            AdminAuditLog.target_type == "gallery",
            AdminAuditLog.target_id == str(gallery_id),
            AdminAuditLog.action == "downloads_generated",
            AdminAuditLog.created_at >= since,
        )
    ).scalar_one()
    if count >= limit_per_minute:
        raise APIError(code="rate_limited", message="Too many download link generations", status_code=429)
