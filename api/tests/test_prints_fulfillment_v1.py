import uuid
from decimal import Decimal
from types import SimpleNamespace

import pytest
from sqlalchemy import select

from app.core.errors import APIError
from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.gig import Gig, GigStatus
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaProvider, MediaPurpose, MediaStatus, MediaVariant, MediaVisibility, ObjectStatus
from app.models.media_rights import GigEntitlementType
from app.models.outbox import OutboxEvent
from app.models.prints import PrintEvent, PrintExportJob, PrintOrder, PrintOrderStatus
from app.services.media_rights import upsert_gig_entitlement
from app.services.prints_fulfillment import (
    admin_set_print_tracking,
    create_print_order,
    create_print_payment_intent,
    ensure_default_print_catalog,
    on_print_payment_succeeded,
    on_print_refund_event,
    run_print_export_job,
)


def _ensure_user(db_session, user_id: uuid.UUID, *, email: str, roles: list[UserRoleType]) -> None:
    row = db_session.get(UserAccount, user_id)
    if row is None:
        db_session.add(UserAccount(user_id=user_id, email=email))
    for role in roles:
        existing = db_session.query(UserRole).filter_by(user_id=user_id, role=role).first()
        if not existing:
            db_session.add(UserRole(user_id=user_id, role=role))
    db_session.commit()


def _build_gig_with_ready_media(db_session, *, client_user_id: uuid.UUID) -> tuple[Gig, uuid.UUID]:
    gig = Gig(
        client_user_id=client_user_id,
        pro_user_id=uuid.uuid4(),
        niche_id=None,
        status=GigStatus.final_delivered,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.flush()

    from app.models.gallery import ProofGallery, ProofGalleryItem, ProofGalleryStatus
    from app.models.media_rights import MediaDerivative, MediaDerivativeKind

    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=gig.pro_user_id,
        client_user_id=gig.client_user_id,
        included_photos=5,
        extra_photo_price=Decimal("10.00"),
        currency="EUR",
        status=ProofGalleryStatus.delivered,
    )
    db_session.add(gallery)
    db_session.flush()

    asset = MediaAsset(
        owner_user_id=gig.pro_user_id,
        kind=MediaKind.photo,
        purpose=MediaPurpose.final_delivery,
        provider=MediaProvider.r2,
        status=MediaStatus.ready,
        visibility=MediaVisibility.client_only,
        meta={},
    )
    db_session.add(asset)
    db_session.flush()

    db_session.add(
        MediaObject(
            media_asset_id=asset.id,
            variant=MediaVariant.original,
            storage_key=f"media/original/{asset.id}.jpg",
            status=ObjectStatus.ready,
        )
    )
    db_session.add(
        MediaDerivative(
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.full_res,
            storage_key=f"media/fullres/{asset.id}.jpg",
            content_type="image/jpeg",
            bytes=1000,
        )
    )
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=0))
    db_session.flush()
    return gig, asset.id


def _mock_stripe(monkeypatch):
    def _create(**kwargs):
        return SimpleNamespace(id=f"pi_{uuid.uuid4().hex[:8]}", client_secret="cs_test", amount=kwargs.get("amount", 0), status="requires_payment_method")

    def _retrieve(intent_id):
        return SimpleNamespace(id=intent_id, client_secret="cs_test", amount=1000, status="requires_payment_method")

    monkeypatch.setattr("app.services.prints_fulfillment.stripe.PaymentIntent.create", _create)
    monkeypatch.setattr("app.services.prints_fulfillment.stripe.PaymentIntent.retrieve", _retrieve)


def test_entitlement_required_for_print_orders(db_session):
    client_id = uuid.uuid4()
    _ensure_user(db_session, client_id, email="prints1@example.com", roles=[UserRoleType.client])
    partner, products = ensure_default_print_catalog(db_session)
    gig, media_id = _build_gig_with_ready_media(db_session, client_user_id=client_id)

    with pytest.raises(APIError) as exc:
        create_print_order(
            db_session,
            client_user_id=client_id,
            gig_id=gig.id,
            partner_id=partner.id,
            items=[
                {
                    "product_id": str(products[0].id),
                    "quantity": 1,
                    "selected_media": [{"media_asset_id": str(media_id)}],
                    "options_snapshot": {"size": "A4"},
                }
            ],
            shipping_address_payload={
                "encrypted_fields": {"line1": "Street"},
                "country": "PT",
                "postal_code": "1000-001",
            },
        )
    assert exc.value.status_code == 403


def test_totals_calculation_correct(db_session):
    client_id = uuid.uuid4()
    _ensure_user(db_session, client_id, email="prints2@example.com", roles=[UserRoleType.client])
    partner, products = ensure_default_print_catalog(db_session)
    gig, media_id = _build_gig_with_ready_media(db_session, client_user_id=client_id)
    upsert_gig_entitlement(db_session, gig_id=gig.id, user_id=client_id, entitlement_type=GigEntitlementType.download_finals)

    order = create_print_order(
        db_session,
        client_user_id=client_id,
        gig_id=gig.id,
        partner_id=partner.id,
        items=[
            {
                "product_id": str(products[0].id),
                "quantity": 2,
                "selected_media": [{"media_asset_id": str(media_id)}],
                "options_snapshot": {"size": "A4"},
            }
        ],
        shipping_address_payload={
            "encrypted_fields": {"line1": "Street"},
            "country": "PT",
            "postal_code": "1000-001",
        },
    )
    db_session.commit()

    assert order.subtotal_eur == Decimal(products[0].retail_price_eur) * 2
    assert order.shipping_eur == Decimal("7.90")
    assert order.total_eur == order.subtotal_eur + order.shipping_eur


def test_payment_success_triggers_export_job(db_session, monkeypatch):
    _mock_stripe(monkeypatch)
    client_id = uuid.uuid4()
    _ensure_user(db_session, client_id, email="prints3@example.com", roles=[UserRoleType.client])
    partner, products = ensure_default_print_catalog(db_session)
    gig, media_id = _build_gig_with_ready_media(db_session, client_user_id=client_id)
    upsert_gig_entitlement(db_session, gig_id=gig.id, user_id=client_id, entitlement_type=GigEntitlementType.download_finals)

    order = create_print_order(
        db_session,
        client_user_id=client_id,
        gig_id=gig.id,
        partner_id=partner.id,
        items=[{"product_id": str(products[0].id), "quantity": 1, "selected_media": [{"media_asset_id": str(media_id)}], "options_snapshot": {}}],
        shipping_address_payload={"encrypted_fields": {"line1": "Street"}, "country": "PT", "postal_code": "1000-001"},
    )
    _, intent = create_print_payment_intent(db_session, order=order)
    on_print_payment_succeeded(db_session, payment_intent_id=intent.id)
    db_session.commit()

    job = db_session.execute(select(PrintExportJob).where(PrintExportJob.print_order_id == order.id)).scalar_one_or_none()
    assert job is not None
    outbox = db_session.execute(select(OutboxEvent).where(OutboxEvent.topic == "print.export.run")).scalars().all()
    assert outbox


def test_export_job_generates_output_files(db_session, monkeypatch):
    _mock_stripe(monkeypatch)
    client_id = uuid.uuid4()
    _ensure_user(db_session, client_id, email="prints4@example.com", roles=[UserRoleType.client])
    partner, products = ensure_default_print_catalog(db_session)
    gig, media_id = _build_gig_with_ready_media(db_session, client_user_id=client_id)
    upsert_gig_entitlement(db_session, gig_id=gig.id, user_id=client_id, entitlement_type=GigEntitlementType.download_finals)

    order = create_print_order(
        db_session,
        client_user_id=client_id,
        gig_id=gig.id,
        partner_id=partner.id,
        items=[{"product_id": str(products[0].id), "quantity": 1, "selected_media": [{"media_asset_id": str(media_id)}], "options_snapshot": {"size": "A4"}}],
        shipping_address_payload={"encrypted_fields": {"line1": "Street"}, "country": "PT", "postal_code": "1000-001"},
    )
    _, intent = create_print_payment_intent(db_session, order=order)
    on_print_payment_succeeded(db_session, payment_intent_id=intent.id)
    job = db_session.execute(select(PrintExportJob).where(PrintExportJob.print_order_id == order.id)).scalar_one()

    run_print_export_job(db_session, print_export_job_id=job.id)
    db_session.commit()
    db_session.refresh(order)
    db_session.refresh(job)

    assert job.status.value == "done"
    assert len(job.output_files) >= 1
    assert order.status == PrintOrderStatus.in_production


def test_admin_status_tracking_logged(db_session):
    client_id = uuid.uuid4()
    _ensure_user(db_session, client_id, email="prints5@example.com", roles=[UserRoleType.client])
    partner, products = ensure_default_print_catalog(db_session)
    gig, media_id = _build_gig_with_ready_media(db_session, client_user_id=client_id)
    upsert_gig_entitlement(db_session, gig_id=gig.id, user_id=client_id, entitlement_type=GigEntitlementType.download_finals)

    order = create_print_order(
        db_session,
        client_user_id=client_id,
        gig_id=gig.id,
        partner_id=partner.id,
        items=[{"product_id": str(products[0].id), "quantity": 1, "selected_media": [{"media_asset_id": str(media_id)}], "options_snapshot": {}}],
        shipping_address_payload={"encrypted_fields": {"line1": "Street"}, "country": "PT", "postal_code": "1000-001"},
    )
    order.status = PrintOrderStatus.in_production
    admin_set_print_tracking(db_session, order=order, tracking_code="TRACK123")
    db_session.commit()

    events = db_session.execute(select(PrintEvent).where(PrintEvent.print_order_id == order.id)).scalars().all()
    assert any(event.note == "tracking_updated" for event in events)


def test_refund_policy_for_in_production_requires_admin_review(db_session):
    client_id = uuid.uuid4()
    _ensure_user(db_session, client_id, email="prints6@example.com", roles=[UserRoleType.client])
    partner, products = ensure_default_print_catalog(db_session)
    gig, media_id = _build_gig_with_ready_media(db_session, client_user_id=client_id)
    upsert_gig_entitlement(db_session, gig_id=gig.id, user_id=client_id, entitlement_type=GigEntitlementType.download_finals)

    order = create_print_order(
        db_session,
        client_user_id=client_id,
        gig_id=gig.id,
        partner_id=partner.id,
        items=[{"product_id": str(products[0].id), "quantity": 1, "selected_media": [{"media_asset_id": str(media_id)}], "options_snapshot": {}}],
        shipping_address_payload={"encrypted_fields": {"line1": "Street"}, "country": "PT", "postal_code": "1000-001"},
    )
    order.status = PrintOrderStatus.in_production
    order.stripe_payment_intent_id = f"pi_{uuid.uuid4().hex[:8]}"
    db_session.flush()

    on_print_refund_event(db_session, payment_intent_id=order.stripe_payment_intent_id, refund_ref="re_123")
    db_session.commit()

    db_session.refresh(order)
    assert order.status == PrintOrderStatus.in_production
    latest = db_session.execute(
        select(PrintEvent).where(PrintEvent.print_order_id == order.id).order_by(PrintEvent.created_at.desc())
    ).scalars().first()
    assert latest is not None
    assert bool((latest.payload or {}).get("admin_review")) is True
