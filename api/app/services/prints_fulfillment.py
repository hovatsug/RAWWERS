from __future__ import annotations

import hashlib
import uuid
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

import stripe
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.gig import Gig, GigStatus
from app.models.gallery import ProofGallery, ProofGalleryItem
from app.models.media import MediaObject, MediaVariant, ObjectStatus
from app.models.media_rights import GigEntitlementType, MediaDerivative, MediaDerivativeKind
from app.models.prints import (
    PrintEvent,
    PrintEventActorType,
    PrintExportJob,
    PrintExportStatus,
    PrintOrder,
    PrintOrderItem,
    PrintOrderStatus,
    PrintPartner,
    PrintPartnerMode,
    PrintProduct,
    PrintProductType,
    ShippingAddress,
)
from app.models.risk import RiskActionType
from app.services.analytics import log_event
from app.services.media_rights import has_valid_entitlement
from app.services.notifications import enqueue_notification
from app.services.outbox import enqueue_outbox_event
from app.services.stripe_service import to_cents
from app.services.trust_safety import has_active_risk_action

settings = get_settings()

EU_COUNTRIES = {
    "AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV",
    "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE",
}


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _q2(value: Decimal | int | float | str) -> Decimal:
    return Decimal(str(value)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def _postal_hash(postal_code: str | None) -> str | None:
    if not postal_code:
        return None
    return hashlib.sha256(f"{postal_code}|{settings.auth_jwt_secret}".encode("utf-8")).hexdigest()


def _add_print_event(
    db: Session,
    *,
    order: PrintOrder,
    from_status: str | None,
    to_status: str,
    actor_type: PrintEventActorType,
    note: str | None,
    payload: dict | None = None,
) -> PrintEvent:
    row = PrintEvent(
        print_order_id=order.id,
        from_status=from_status,
        to_status=to_status,
        actor_type=actor_type,
        note=note,
        payload=payload or {},
    )
    db.add(row)
    db.flush()
    return row


def ensure_default_print_catalog(db: Session) -> tuple[PrintPartner, list[PrintProduct]]:
    partner = db.execute(select(PrintPartner).where(PrintPartner.name == "EU Print Lab")).scalar_one_or_none()
    if not partner:
        partner = PrintPartner(name="EU Print Lab", mode=PrintPartnerMode.manual, is_active=True)
        db.add(partner)
        db.flush()

    defaults = [
        {
            "sku": "PRINT-A4-LUSTER",
            "type": PrintProductType.print,
            "name_key": "prints.product.print_a4_luster.name",
            "description_key": "prints.product.print_a4_luster.description",
            "options": {"sizes": ["A4", "A3"], "paper": ["luster", "matte"], "finish": ["standard"]},
            "base_cost_eur": Decimal("8.50"),
            "markup_percent": 40,
            "production_specs": {"dpi": 300, "color_profile": "sRGB", "bleed_mm": 0},
        },
        {
            "sku": "FRAME-30x40-BLACK",
            "type": PrintProductType.frame,
            "name_key": "prints.product.frame_30x40_black.name",
            "description_key": "prints.product.frame_30x40_black.description",
            "options": {"sizes": ["30x40"], "frame_color": ["black", "oak"], "glass": ["standard", "museum"]},
            "base_cost_eur": Decimal("32.00"),
            "markup_percent": 45,
            "production_specs": {"dpi": 300, "color_profile": "sRGB", "bleed_mm": 3},
        },
        {
            "sku": "ALBUM-20P-30x30",
            "type": PrintProductType.album,
            "name_key": "prints.product.album_20p_30x30.name",
            "description_key": "prints.product.album_20p_30x30.description",
            "options": {"pages": [20, 30, 40], "cover": ["linen", "leatherette"], "size": ["30x30"]},
            "base_cost_eur": Decimal("55.00"),
            "markup_percent": 50,
            "production_specs": {"dpi": 300, "color_profile": "sRGB", "bleed_mm": 5},
        },
    ]

    rows: list[PrintProduct] = []
    for item in defaults:
        row = db.execute(select(PrintProduct).where(PrintProduct.partner_id == partner.id, PrintProduct.sku == item["sku"])).scalar_one_or_none()
        retail = _q2(item["base_cost_eur"] * (Decimal("1.00") + (Decimal(item["markup_percent"]) / Decimal("100"))))
        if not row:
            row = PrintProduct(
                partner_id=partner.id,
                sku=item["sku"],
                name_key=item["name_key"],
                description_key=item["description_key"],
                type=item["type"],
                options=item["options"],
                base_cost_eur=item["base_cost_eur"],
                markup_percent=item["markup_percent"],
                retail_price_eur=retail,
                production_specs=item["production_specs"],
                is_active=True,
            )
            db.add(row)
        rows.append(row)
    db.flush()
    return partner, rows


def list_print_catalog(db: Session) -> list[PrintProduct]:
    ensure_default_print_catalog(db)
    return db.execute(
        select(PrintProduct)
        .join(PrintPartner, PrintPartner.id == PrintProduct.partner_id)
        .where(PrintProduct.is_active.is_(True), PrintPartner.is_active.is_(True))
        .order_by(PrintProduct.sku.asc())
    ).scalars().all()


def _assert_client_can_order(db: Session, *, gig: Gig, client_user_id: uuid.UUID) -> None:
    if gig.client_user_id != client_user_id:
        raise APIError(code="forbidden", message="Only gig client can order prints", status_code=403)
    if gig.status not in {GigStatus.final_delivered, GigStatus.completed}:
        raise APIError(code="invalid_state", message="Print orders are only available after delivery", status_code=409)
    if not has_valid_entitlement(db, gig_id=gig.id, user_id=client_user_id, entitlement_type=GigEntitlementType.download_finals):
        raise APIError(code="forbidden", message="Final download entitlement required for print ordering", status_code=403)


def upsert_shipping_address(
    db: Session,
    *,
    user_id: uuid.UUID,
    encrypted_fields: dict,
    country: str,
    postal_code: str | None,
    address_id: uuid.UUID | None = None,
) -> ShippingAddress:
    if (country or "").upper() not in EU_COUNTRIES:
        raise APIError(code="validation_error", message="Only EU shipping is supported in v1", status_code=422)

    row = db.get(ShippingAddress, address_id) if address_id else None
    if row and row.user_id != user_id:
        raise APIError(code="forbidden", message="Cannot reuse another user's shipping address", status_code=403)
    if not row:
        row = ShippingAddress(user_id=user_id, encrypted_fields={}, country=country.upper(), postal_code_hash=None)
        db.add(row)
    row.encrypted_fields = encrypted_fields or {}
    row.country = (country or "").upper()
    row.postal_code_hash = _postal_hash(postal_code)
    row.updated_at = _now()
    db.flush()
    return row


def _validate_selected_media(db: Session, *, gig_id: uuid.UUID, selected_media: list[dict]) -> None:
    media_ids: list[uuid.UUID] = []
    for item in selected_media or []:
        raw = item.get("media_asset_id")
        try:
            media_ids.append(uuid.UUID(str(raw)))
        except Exception as exc:
            raise APIError(code="validation_error", message="Invalid media_asset_id in selected_media", status_code=422) from exc

    if not media_ids:
        raise APIError(code="validation_error", message="selected_media cannot be empty", status_code=422)

    gig_asset_ids = set(
        db.execute(
            select(ProofGalleryItem.media_asset_id)
            .join(ProofGallery, ProofGallery.id == ProofGalleryItem.gallery_id)
            .where(ProofGallery.gig_id == gig_id)
        ).scalars().all()
    )
    if not gig_asset_ids:
        raise APIError(code="validation_error", message="Gig gallery is not available for prints", status_code=422)

    ready_full_res_ids = set(
        db.execute(
            select(MediaDerivative.media_asset_id)
            .join(MediaObject, MediaObject.media_asset_id == MediaDerivative.media_asset_id)
            .where(
                MediaDerivative.kind == MediaDerivativeKind.full_res,
                MediaObject.variant == MediaVariant.original,
                MediaObject.status == ObjectStatus.ready,
            )
        ).scalars().all()
    )
    for media_id in media_ids:
        if media_id not in gig_asset_ids:
            raise APIError(code="validation_error", message="Selected media does not belong to this gig gallery", status_code=422)
        if media_id not in ready_full_res_ids:
            raise APIError(code="validation_error", message="Selected media is not ready for print export", status_code=422)


def _risk_review_required(db: Session, *, client_user_id: uuid.UUID) -> bool:
    return any(
        has_active_risk_action(db, user_id=client_user_id, action_type=action)
        for action in (RiskActionType.freeze_payouts, RiskActionType.freeze_rewards, RiskActionType.require_verification)
    )


def _recalc_order_totals(db: Session, order: PrintOrder) -> None:
    items = db.execute(select(PrintOrderItem).where(PrintOrderItem.print_order_id == order.id)).scalars().all()
    subtotal = _q2(sum((item.line_total_eur for item in items), start=Decimal("0.00")))
    shipping = _q2(Decimal("7.90") if subtotal > Decimal("0") else Decimal("0.00"))
    order.subtotal_eur = subtotal
    order.shipping_eur = shipping
    order.total_eur = _q2(subtotal + shipping)
    order.updated_at = _now()


def create_print_order(
    db: Session,
    *,
    client_user_id: uuid.UUID,
    gig_id: uuid.UUID,
    partner_id: uuid.UUID,
    items: list[dict],
    shipping_address_payload: dict,
) -> PrintOrder:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    _assert_client_can_order(db, gig=gig, client_user_id=client_user_id)

    partner = db.get(PrintPartner, partner_id)
    if not partner or not partner.is_active:
        raise APIError(code="validation_error", message="Print partner unavailable", status_code=422)

    address = upsert_shipping_address(
        db,
        user_id=client_user_id,
        encrypted_fields=shipping_address_payload.get("encrypted_fields") or {},
        country=str(shipping_address_payload.get("country") or "").upper(),
        postal_code=shipping_address_payload.get("postal_code"),
        address_id=uuid.UUID(shipping_address_payload["address_id"]) if shipping_address_payload.get("address_id") else None,
    )

    order = PrintOrder(
        client_user_id=client_user_id,
        gig_id=gig_id,
        partner_id=partner_id,
        status=PrintOrderStatus.pending_payment,
        shipping_address_id=address.id,
        currency="EUR",
        meta={},
    )
    db.add(order)
    db.flush()

    for item in items or []:
        product_id = uuid.UUID(str(item.get("product_id")))
        product = db.get(PrintProduct, product_id)
        if not product or not product.is_active:
            raise APIError(code="validation_error", message="Invalid print product", status_code=422)
        quantity = int(item.get("quantity") or 0)
        if quantity <= 0:
            raise APIError(code="validation_error", message="Quantity must be > 0", status_code=422)
        selected_media = list(item.get("selected_media") or [])
        _validate_selected_media(db, gig_id=gig_id, selected_media=selected_media)

        unit_price = _q2(product.retail_price_eur)
        line_total = _q2(unit_price * quantity)
        db.add(
            PrintOrderItem(
                print_order_id=order.id,
                product_id=product.id,
                quantity=quantity,
                selected_media=selected_media,
                options_snapshot=item.get("options_snapshot") or {},
                unit_price_eur=unit_price,
                line_total_eur=line_total,
            )
        )

    db.flush()
    _recalc_order_totals(db, order)
    risk_review = _risk_review_required(db, client_user_id=client_user_id)
    if risk_review:
        order.meta = {**(order.meta or {}), "risk_review_required": True}
        for admin_user_id in settings.admin_user_id_set():
            enqueue_notification(
                db,
                user_id=admin_user_id,
                notification_type="prints.order.risk_review",
                payload={"title": "Print order flagged", "body": "A print order requires trust & safety review."},
                reference_type="print_order",
                reference_id=str(order.id),
            )
    _add_print_event(
        db,
        order=order,
        from_status=None,
        to_status=order.status.value,
        actor_type=PrintEventActorType.client,
        note="order_created",
        payload={"gig_id": str(gig_id)},
    )
    log_event(db, event_name="prints.order_created", user_id=client_user_id, properties={"print_order_id": str(order.id), "gig_id": str(gig_id), "total_eur": str(order.total_eur)})
    return order


def update_print_order(
    db: Session,
    *,
    order_id: uuid.UUID,
    client_user_id: uuid.UUID,
    items: list[dict] | None,
    shipping_address_payload: dict | None,
) -> PrintOrder:
    order = db.get(PrintOrder, order_id)
    if not order or order.client_user_id != client_user_id:
        raise APIError(code="not_found", message="Print order not found", status_code=404)
    if order.status not in {PrintOrderStatus.draft, PrintOrderStatus.pending_payment}:
        raise APIError(code="invalid_state", message="Order can no longer be edited", status_code=409)

    if shipping_address_payload:
        address = upsert_shipping_address(
            db,
            user_id=client_user_id,
            encrypted_fields=shipping_address_payload.get("encrypted_fields") or {},
            country=str(shipping_address_payload.get("country") or "").upper(),
            postal_code=shipping_address_payload.get("postal_code"),
            address_id=uuid.UUID(shipping_address_payload["address_id"]) if shipping_address_payload.get("address_id") else None,
        )
        order.shipping_address_id = address.id

    if items is not None:
        rows = db.execute(select(PrintOrderItem).where(PrintOrderItem.print_order_id == order.id)).scalars().all()
        for row in rows:
            db.delete(row)
        db.flush()
        for item in items:
            product = db.get(PrintProduct, uuid.UUID(str(item.get("product_id"))))
            if not product or not product.is_active:
                raise APIError(code="validation_error", message="Invalid print product", status_code=422)
            quantity = int(item.get("quantity") or 0)
            if quantity <= 0:
                raise APIError(code="validation_error", message="Quantity must be > 0", status_code=422)
            selected_media = list(item.get("selected_media") or [])
            _validate_selected_media(db, gig_id=order.gig_id, selected_media=selected_media)
            unit_price = _q2(product.retail_price_eur)
            db.add(
                PrintOrderItem(
                    print_order_id=order.id,
                    product_id=product.id,
                    quantity=quantity,
                    selected_media=selected_media,
                    options_snapshot=item.get("options_snapshot") or {},
                    unit_price_eur=unit_price,
                    line_total_eur=_q2(unit_price * quantity),
                )
            )
        db.flush()

    _recalc_order_totals(db, order)
    return order


def create_print_payment_intent(db: Session, *, order: PrintOrder) -> tuple[PrintOrder, object]:
    if order.status not in {PrintOrderStatus.draft, PrintOrderStatus.pending_payment, PrintOrderStatus.failed}:
        raise APIError(code="invalid_state", message="Order cannot be paid in current status", status_code=409)
    if order.total_eur <= Decimal("0"):
        raise APIError(code="validation_error", message="Order total must be > 0", status_code=422)

    if order.stripe_payment_intent_id:
        intent = stripe.PaymentIntent.retrieve(order.stripe_payment_intent_id)
        return order, intent

    intent = stripe.PaymentIntent.create(
        amount=to_cents(_q2(order.total_eur)),
        currency=(order.currency or "EUR").lower(),
        automatic_payment_methods={"enabled": True},
        metadata={
            "type": "print_order",
            "print_order_id": str(order.id),
            "gig_id": str(order.gig_id),
            "client_user_id": str(order.client_user_id),
        },
        idempotency_key=f"print-order:{order.id}:pi",
    )
    order.stripe_payment_intent_id = intent.id
    order.status = PrintOrderStatus.pending_payment
    order.updated_at = _now()
    _add_print_event(
        db,
        order=order,
        from_status=PrintOrderStatus.draft.value,
        to_status=PrintOrderStatus.pending_payment.value,
        actor_type=PrintEventActorType.client,
        note="payment_intent_created",
        payload={"payment_intent_id": intent.id},
    )
    return order, intent


def on_print_payment_succeeded(db: Session, *, payment_intent_id: str) -> PrintOrder | None:
    order = db.execute(select(PrintOrder).where(PrintOrder.stripe_payment_intent_id == payment_intent_id)).scalar_one_or_none()
    if not order:
        return None
    prev = order.status.value
    order.status = PrintOrderStatus.paid
    order.updated_at = _now()
    _add_print_event(
        db,
        order=order,
        from_status=prev,
        to_status=PrintOrderStatus.paid.value,
        actor_type=PrintEventActorType.system,
        note="payment_succeeded",
        payload={"payment_intent_id": payment_intent_id},
    )

    export = PrintExportJob(print_order_id=order.id, status=PrintExportStatus.queued, output_files=[])
    db.add(export)
    db.flush()
    enqueue_outbox_event(
        db,
        topic="print.export.run",
        payload={"print_export_job_id": str(export.id)},
        idempotency_key=f"print-export-run:{export.id}",
        idempotency_scope="print_export",
    )
    log_event(db, event_name="prints.paid", user_id=order.client_user_id, properties={"print_order_id": str(order.id)})
    return order


def on_print_payment_failed(db: Session, *, payment_intent_id: str, reason: str | None = None) -> PrintOrder | None:
    order = db.execute(select(PrintOrder).where(PrintOrder.stripe_payment_intent_id == payment_intent_id)).scalar_one_or_none()
    if not order:
        return None
    prev = order.status.value
    order.status = PrintOrderStatus.failed
    order.updated_at = _now()
    _add_print_event(
        db,
        order=order,
        from_status=prev,
        to_status=PrintOrderStatus.failed.value,
        actor_type=PrintEventActorType.system,
        note="payment_failed",
        payload={"reason": reason or "payment_failed"},
    )
    return order


def on_print_refund_event(db: Session, *, payment_intent_id: str, refund_ref: str | None = None) -> PrintOrder | None:
    order = db.execute(select(PrintOrder).where(PrintOrder.stripe_payment_intent_id == payment_intent_id)).scalar_one_or_none()
    if not order:
        return None
    prev = order.status.value
    if order.status in {PrintOrderStatus.pending_payment, PrintOrderStatus.paid}:
        order.status = PrintOrderStatus.refunded
        to_status = PrintOrderStatus.refunded.value
        payload = {"refund_ref": refund_ref, "policy": "cancel_or_refund"}
    elif order.status in {PrintOrderStatus.in_production, PrintOrderStatus.shipped, PrintOrderStatus.delivered}:
        to_status = order.status.value
        payload = {"refund_ref": refund_ref, "policy": "admin_review_required", "admin_review": True}
    else:
        to_status = order.status.value
        payload = {"refund_ref": refund_ref}
    order.updated_at = _now()
    _add_print_event(
        db,
        order=order,
        from_status=prev,
        to_status=to_status,
        actor_type=PrintEventActorType.system,
        note="refund_event",
        payload=payload,
    )
    return order


def _resolve_source_storage_key(db: Session, media_asset_id: uuid.UUID) -> str | None:
    full_res = db.execute(
        select(MediaDerivative).where(
            MediaDerivative.media_asset_id == media_asset_id,
            MediaDerivative.kind == MediaDerivativeKind.full_res,
        )
    ).scalar_one_or_none()
    if full_res:
        return full_res.storage_key
    original = db.execute(
        select(MediaObject).where(
            MediaObject.media_asset_id == media_asset_id,
            MediaObject.variant == MediaVariant.original,
            MediaObject.status == ObjectStatus.ready,
        )
    ).scalar_one_or_none()
    return original.storage_key if original else None


def run_print_export_job(db: Session, *, print_export_job_id: uuid.UUID) -> PrintExportJob | None:
    job = db.get(PrintExportJob, print_export_job_id)
    if not job:
        return None
    order = db.get(PrintOrder, job.print_order_id)
    if not order:
        job.status = PrintExportStatus.failed
        job.failure_reason = "order_not_found"
        return job

    job.status = PrintExportStatus.processing
    job.updated_at = _now()

    items = db.execute(select(PrintOrderItem).where(PrintOrderItem.print_order_id == order.id)).scalars().all()
    output_files: list[dict] = []
    try:
        for item in items:
            product = db.get(PrintProduct, item.product_id)
            specs = (product.production_specs or {}) if product else {}
            for idx, media in enumerate(item.selected_media or []):
                media_asset_id = uuid.UUID(str(media.get("media_asset_id")))
                source_key = _resolve_source_storage_key(db, media_asset_id)
                if not source_key:
                    continue
                export_key = f"prints/orders/{order.id}/exports/{job.id}/{item.id}-{idx}.jpg"
                output_files.append(
                    {
                        "print_order_item_id": str(item.id),
                        "media_asset_id": str(media_asset_id),
                        "source_storage_key": source_key,
                        "storage_key": export_key,
                        "options": item.options_snapshot,
                        "production_specs": specs,
                        "dpi_policy": int(specs.get("dpi", 300) or 300),
                        "color_profile": str(specs.get("color_profile", "sRGB")),
                    }
                )

        job.status = PrintExportStatus.done
        job.output_files = output_files
        job.failure_reason = None
        job.updated_at = _now()

        prev = order.status.value
        order.status = PrintOrderStatus.in_production
        order.updated_at = _now()
        _add_print_event(
            db,
            order=order,
            from_status=prev,
            to_status=PrintOrderStatus.in_production.value,
            actor_type=PrintEventActorType.system,
            note="export_done",
            payload={"print_export_job_id": str(job.id), "files": len(output_files)},
        )
        log_event(db, event_name="prints.export_done", user_id=order.client_user_id, properties={"print_order_id": str(order.id), "print_export_job_id": str(job.id), "files": len(output_files)})

        for admin_user_id in settings.admin_user_id_set():
            enqueue_notification(
                db,
                user_id=admin_user_id,
                notification_type="prints.export.ready",
                payload={"title": "Print export ready", "body": "A print order export bundle is ready for partner production."},
                reference_type="print_order",
                reference_id=str(order.id),
            )
    except Exception as exc:
        job.status = PrintExportStatus.failed
        job.failure_reason = str(exc)
        job.updated_at = _now()
    db.flush()
    return job


def list_my_print_orders(db: Session, *, client_user_id: uuid.UUID) -> list[PrintOrder]:
    return db.execute(
        select(PrintOrder)
        .where(PrintOrder.client_user_id == client_user_id)
        .order_by(PrintOrder.created_at.desc())
    ).scalars().all()


def get_my_print_order(db: Session, *, client_user_id: uuid.UUID, order_id: uuid.UUID) -> PrintOrder:
    row = db.get(PrintOrder, order_id)
    if not row or row.client_user_id != client_user_id:
        raise APIError(code="not_found", message="Print order not found", status_code=404)
    return row


def list_admin_print_orders(
    db: Session,
    *,
    status: PrintOrderStatus | None,
    partner_id: uuid.UUID | None,
    limit: int,
) -> list[PrintOrder]:
    stmt = select(PrintOrder).order_by(PrintOrder.created_at.desc())
    if status:
        stmt = stmt.where(PrintOrder.status == status)
    if partner_id:
        stmt = stmt.where(PrintOrder.partner_id == partner_id)
    return db.execute(stmt.limit(limit)).scalars().all()


def admin_set_print_order_status(
    db: Session,
    *,
    order: PrintOrder,
    to_status: PrintOrderStatus,
    note: str | None,
    actor_type: PrintEventActorType,
) -> PrintOrder:
    prev = order.status.value
    order.status = to_status
    order.updated_at = _now()
    _add_print_event(
        db,
        order=order,
        from_status=prev,
        to_status=to_status.value,
        actor_type=actor_type,
        note=note,
    )
    if to_status == PrintOrderStatus.shipped:
        log_event(db, event_name="prints.shipped", user_id=order.client_user_id, properties={"print_order_id": str(order.id)})
    if to_status == PrintOrderStatus.delivered:
        log_event(db, event_name="prints.delivered", user_id=order.client_user_id, properties={"print_order_id": str(order.id)})
    return order


def admin_set_print_tracking(db: Session, *, order: PrintOrder, tracking_code: str, note: str | None = None) -> PrintOrder:
    prev = order.status.value
    order.tracking_code = tracking_code
    if order.status in {PrintOrderStatus.in_production, PrintOrderStatus.paid}:
        order.status = PrintOrderStatus.shipped
    order.updated_at = _now()
    _add_print_event(
        db,
        order=order,
        from_status=prev,
        to_status=order.status.value,
        actor_type=PrintEventActorType.admin,
        note=note or "tracking_updated",
        payload={"tracking_code": tracking_code},
    )
    enqueue_notification(
        db,
        user_id=order.client_user_id,
        notification_type="prints.shipment.updated",
        payload={"title": "Print order shipped", "body": "Your print order has shipped.", "tracking_code": tracking_code},
        reference_type="print_order",
        reference_id=str(order.id),
    )
    return order


def list_print_order_items(db: Session, *, order_id: uuid.UUID) -> list[PrintOrderItem]:
    return db.execute(select(PrintOrderItem).where(PrintOrderItem.print_order_id == order_id)).scalars().all()


def list_print_events(db: Session, *, order_id: uuid.UUID) -> list[PrintEvent]:
    return db.execute(select(PrintEvent).where(PrintEvent.print_order_id == order_id).order_by(PrintEvent.created_at.asc())).scalars().all()


def list_print_partners(db: Session) -> list[PrintPartner]:
    ensure_default_print_catalog(db)
    return db.execute(select(PrintPartner).order_by(PrintPartner.created_at.asc())).scalars().all()


def upsert_print_partner(
    db: Session,
    *,
    partner_id: uuid.UUID | None,
    name: str,
    mode: PrintPartnerMode,
    api_base_url: str | None,
    api_key_ref: str | None,
    is_active: bool,
) -> PrintPartner:
    row = db.get(PrintPartner, partner_id) if partner_id else None
    if not row:
        row = PrintPartner(name=name, mode=mode, api_base_url=api_base_url, api_key_ref=api_key_ref, is_active=is_active)
        db.add(row)
    else:
        row.name = name
        row.mode = mode
        row.api_base_url = api_base_url
        row.api_key_ref = api_key_ref
        row.is_active = is_active
        row.updated_at = _now()
    db.flush()
    return row


def upsert_print_product(
    db: Session,
    *,
    product_id: uuid.UUID | None,
    partner_id: uuid.UUID,
    sku: str,
    name_key: str,
    description_key: str,
    type: PrintProductType,
    options: dict,
    base_cost_eur: Decimal,
    markup_percent: int,
    production_specs: dict,
    is_active: bool,
) -> PrintProduct:
    row = db.get(PrintProduct, product_id) if product_id else None
    retail = _q2(_q2(base_cost_eur) * (Decimal("1.00") + Decimal(max(0, int(markup_percent))) / Decimal("100")))
    if not row:
        row = PrintProduct(
            partner_id=partner_id,
            sku=sku,
            name_key=name_key,
            description_key=description_key,
            type=type,
            options=options or {},
            base_cost_eur=_q2(base_cost_eur),
            markup_percent=max(0, int(markup_percent)),
            retail_price_eur=retail,
            production_specs=production_specs or {},
            is_active=is_active,
        )
        db.add(row)
    else:
        row.partner_id = partner_id
        row.sku = sku
        row.name_key = name_key
        row.description_key = description_key
        row.type = type
        row.options = options or {}
        row.base_cost_eur = _q2(base_cost_eur)
        row.markup_percent = max(0, int(markup_percent))
        row.retail_price_eur = retail
        row.production_specs = production_specs or {}
        row.is_active = is_active
        row.updated_at = _now()
    db.flush()
    return row
