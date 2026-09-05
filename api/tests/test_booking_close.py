import uuid
from datetime import datetime, timezone
from decimal import Decimal

from app.models.admin import UserAccount
from app.models.gallery import (
    ClientSelection,
    ClientSelectionItem,
    ProofGallery,
    ProofGalleryItem,
    ProofGalleryStatus,
    SelectionStatus,
)
from app.models.gig import Gig, GigStatus, GigTransition, PaymentStatus, StripePayment, StripePaymentKind
from app.models.media import (
    MediaAsset,
    MediaKind,
    MediaObject,
    MediaProvider,
    MediaPurpose,
    MediaStatus,
    MediaVariant,
    MediaVisibility,
    ObjectStatus,
)
from app.models.payouts import EarningsLedgerEntry, EarningsSourceType
from app.services.gallery_completion import is_selection_fully_paid
from app.services.gig_state import ALLOWED_TRANSITIONS
from app.services.niche_catalog import ensure_initial_niches, get_active_niche_by_slug
from app.services.package_pricing import compute_package_total
from app.services.payment_intents import list_succeeded_payments_for_gig
from app.tasks.outbox_tasks import dispatch_outbox_events_task
from sqlalchemy import select

ADMIN_USER_ID = "00000000-0000-0000-0000-0000000000aa"


class DummyStripePI:
    def __init__(self, pi_id: str, client_secret: str, status: str = "requires_payment_method"):
        self.id = pi_id
        self.client_secret = client_secret
        self.status = status


def _ensure_account(db_session, user_id: str):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()


def _create_photo_asset(db_session, owner_user_id: str) -> MediaAsset:
    asset = MediaAsset(
        owner_user_id=uuid.UUID(owner_user_id),
        kind=MediaKind.photo,
        purpose=MediaPurpose.proof,
        provider=MediaProvider.r2,
        status=MediaStatus.ready,
        visibility=MediaVisibility.owner_only,
        content_type="image/jpeg",
        meta={},
    )
    db_session.add(asset)
    db_session.flush()
    db_session.add(
        MediaObject(
            media_asset_id=asset.id,
            variant=MediaVariant.original,
            storage_key=f"users/{owner_user_id}/photo/{asset.id}_orig.jpg",
            status=ObjectStatus.ready,
            width=2000,
            height=1200,
        )
    )
    db_session.commit()
    db_session.refresh(asset)
    return asset


def _create_gig_with_curve(db_session, client_id: str, pro_id: str, *, included_photos: int) -> tuple[Gig, ProofGallery]:
    """Portrait-style (exponential) curve, entry_rate=2.00. amount_minimum
    = 10 * 2.00 = 20.00 (photos 1-10 are always flat at the entry rate)."""
    ensure_initial_niches(db_session)
    niche = get_active_niche_by_slug(db_session, "portraits")

    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=niche.id,
        status=GigStatus.paid,
        currency="EUR",
        amount_minimum=Decimal("20.00"),
        entry_rate=Decimal("2.00"),
        amount_platform_fee=Decimal("4.00"),
        amount_pro_gross=Decimal("16.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.flush()
    db_session.add(
        StripePayment(
            gig_id=gig.id,
            kind=StripePaymentKind.base,
            client_user_id=uuid.UUID(client_id),
            status=PaymentStatus.succeeded,
            stripe_payment_intent_id=f"pi_base_{gig.id}",
            amount=Decimal("20.00"),
            currency="EUR",
            meta={},
        )
    )

    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=gig.pro_user_id,
        client_user_id=gig.client_user_id,
        included_photos=included_photos,
        extra_photo_price=Decimal("10.00"),
        currency="EUR",
        status=ProofGalleryStatus.published,
    )
    db_session.add(gallery)
    db_session.commit()
    db_session.refresh(gig)
    db_session.refresh(gallery)
    return gig, gallery


def _select_photos(db_session, gallery: ProofGallery, pro_id: str, client_id: str, count: int) -> list[MediaAsset]:
    assets = [_create_photo_asset(db_session, pro_id) for _ in range(count)]
    for i, asset in enumerate(assets):
        db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=i + 1))
    db_session.flush()
    selection = ClientSelection(gallery_id=gallery.id, client_user_id=uuid.UUID(client_id), version=1, status=SelectionStatus.draft)
    db_session.add(selection)
    db_session.flush()
    for asset in assets:
        db_session.add(ClientSelectionItem(selection_id=selection.id, media_asset_id=asset.id))
    db_session.commit()
    return assets


# ---------------------------------------------------------------------------
# State machine: completed is now a reachable, guarded transition.
# ---------------------------------------------------------------------------


def test_completed_is_reachable_only_from_paid():
    assert GigStatus.completed in ALLOWED_TRANSITIONS[GigStatus.paid]
    assert ALLOWED_TRANSITIONS[GigStatus.completed] == set()
    assert GigStatus.completed not in ALLOWED_TRANSITIONS[GigStatus.payment_pending]


# ---------------------------------------------------------------------------
# list_succeeded_payments_for_gig: kind filter used to avoid double-counting
# extras (which get their own earnings entry from the upsell webhook path).
# ---------------------------------------------------------------------------


def test_list_succeeded_payments_kind_filter(db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, _gallery = _create_gig_with_curve(db_session, client_id, pro_id, included_photos=25)
    db_session.add(
        StripePayment(
            gig_id=gig.id,
            kind=StripePaymentKind.extras,
            client_user_id=uuid.UUID(client_id),
            status=PaymentStatus.succeeded,
            stripe_payment_intent_id=f"pi_extras_{gig.id}",
            amount=Decimal("5.00"),
            currency="EUR",
            meta={},
        )
    )
    db_session.commit()

    all_payments = list_succeeded_payments_for_gig(db_session, gig.id)
    assert len(all_payments) == 2

    base_only = list_succeeded_payments_for_gig(db_session, gig.id, kinds=[StripePaymentKind.base, StripePaymentKind.difference])
    assert len(base_only) == 1
    assert base_only[0].kind == StripePaymentKind.base


# ---------------------------------------------------------------------------
# submit_selection: difference charge computed from the curve, gates
# completion until paid; no difference/extras closes the booking inline.
# ---------------------------------------------------------------------------


def test_submit_selection_with_markup_creates_difference_charge_and_defers_completion(client, db_session, monkeypatch):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    # included_photos=25 so all 25 selected stay within "included" - no extras.
    gig, gallery = _create_gig_with_curve(db_session, client_id, pro_id, included_photos=25)
    _select_photos(db_session, gallery, pro_id, client_id, count=25)

    monkeypatch.setattr(
        "app.services.payment_intents.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripePI("pi_diff_1", "sec_diff_1"),
    )

    expected_final = compute_package_total(db_session, niche_id=gig.niche_id, entry_rate=Decimal("2.00"), photo_count=25)
    expected_difference = expected_final - Decimal("20.00")
    assert expected_difference > 0  # sanity check the seeded curve actually decays past the minimum

    resp = client.post(f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id})
    assert resp.status_code == 200
    body = resp.json()
    assert body["difference_required"] is True
    assert Decimal(body["difference_amount"]) == expected_difference
    assert body["difference_payment_intent_id"] == "pi_diff_1"
    assert body["upsell_required"] is False

    db_session.refresh(gig)
    db_session.refresh(gallery)
    assert gig.amount_final == expected_final
    assert gig.status == GigStatus.paid  # not completed yet
    assert gallery.status != ProofGalleryStatus.selection_submitted

    difference_payment = db_session.execute(
        select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.difference)
    ).scalar_one()
    assert difference_payment.amount == expected_difference
    assert difference_payment.status == PaymentStatus.pending


def test_submit_selection_at_exact_curve_minimum_completes_immediately(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _create_gig_with_curve(db_session, client_id, pro_id, included_photos=10)
    _select_photos(db_session, gallery, pro_id, client_id, count=10)

    resp = client.post(f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id})
    assert resp.status_code == 200
    body = resp.json()
    assert body["difference_required"] is False
    assert body["upsell_required"] is False

    db_session.refresh(gig)
    db_session.refresh(gallery)
    assert gig.status == GigStatus.completed
    assert gallery.status == ProofGalleryStatus.selection_submitted

    transition = db_session.execute(
        select(GigTransition).where(GigTransition.gig_id == gig.id, GigTransition.to_status == GigStatus.completed)
    ).scalar_one()
    assert transition.from_status == GigStatus.paid

    earnings = db_session.execute(
        select(EarningsLedgerEntry).where(
            EarningsLedgerEntry.pro_user_id == gig.pro_user_id,
            EarningsLedgerEntry.source_type == EarningsSourceType.gig_base,
            EarningsLedgerEntry.source_id == gig.id,
        )
    ).scalar_one()
    assert earnings.gross_eur == Decimal("20.00")


def test_declined_difference_charge_leaves_gig_open(client, db_session, monkeypatch):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _create_gig_with_curve(db_session, client_id, pro_id, included_photos=25)
    _select_photos(db_session, gallery, pro_id, client_id, count=25)

    monkeypatch.setattr(
        "app.services.payment_intents.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripePI("pi_diff_declined", "sec_diff_declined"),
    )
    submit = client.post(f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id})
    assert submit.status_code == 200

    event = {
        "id": "evt_diff_failed_1",
        "type": "payment_intent.payment_failed",
        "data": {"object": {"id": "pi_diff_declined", "last_payment_error": {"message": "Your card was declined."}}},
    }
    monkeypatch.setattr("app.api.v1.webhooks.construct_stripe_event", lambda raw, sig: event)
    webhook_resp = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "sig"})
    assert webhook_resp.status_code == 200
    dispatch_outbox_events_task(limit=100)

    db_session.refresh(gig)
    db_session.refresh(gallery)
    assert gig.status == GigStatus.paid
    assert gallery.status != ProofGalleryStatus.selection_submitted

    difference_payment = db_session.execute(
        select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.difference)
    ).scalar_one()
    assert difference_payment.status == PaymentStatus.failed


def test_difference_charge_succeeding_via_webhook_completes_the_booking(client, db_session, monkeypatch):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _create_gig_with_curve(db_session, client_id, pro_id, included_photos=25)
    _select_photos(db_session, gallery, pro_id, client_id, count=25)
    expected_final = compute_package_total(db_session, niche_id=gig.niche_id, entry_rate=Decimal("2.00"), photo_count=25)

    monkeypatch.setattr(
        "app.services.payment_intents.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripePI("pi_diff_ok", "sec_diff_ok"),
    )
    submit = client.post(f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id})
    assert submit.status_code == 200

    event = {
        "id": "evt_diff_succeeded_1",
        "type": "payment_intent.succeeded",
        "data": {"object": {"id": "pi_diff_ok"}},
    }
    monkeypatch.setattr("app.api.v1.webhooks.construct_stripe_event", lambda raw, sig: event)
    webhook_resp = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "sig"})
    assert webhook_resp.status_code == 200
    dispatch_outbox_events_task(limit=100)

    db_session.refresh(gig)
    db_session.refresh(gallery)
    assert gig.status == GigStatus.completed
    assert gallery.status == ProofGalleryStatus.selection_submitted

    earnings = db_session.execute(
        select(EarningsLedgerEntry).where(
            EarningsLedgerEntry.pro_user_id == gig.pro_user_id,
            EarningsLedgerEntry.source_type == EarningsSourceType.gig_base,
            EarningsLedgerEntry.source_id == gig.id,
        )
    ).scalar_one()
    assert earnings.gross_eur == expected_final  # base (20.00) + difference, summed


# ---------------------------------------------------------------------------
# is_selection_fully_paid unit coverage.
# ---------------------------------------------------------------------------


def test_is_selection_fully_paid_gates_on_pending_difference(db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _create_gig_with_curve(db_session, client_id, pro_id, included_photos=25)
    assets = _select_photos(db_session, gallery, pro_id, client_id, count=25)
    selection = db_session.execute(
        select(ClientSelection).where(ClientSelection.gallery_id == gallery.id)
    ).scalar_one()

    gig.amount_final = Decimal("50.00")
    db_session.commit()

    assert is_selection_fully_paid(db_session, gig=gig, gallery=gallery, selection=selection) is False

    db_session.add(
        StripePayment(
            gig_id=gig.id,
            kind=StripePaymentKind.difference,
            client_user_id=uuid.UUID(client_id),
            status=PaymentStatus.succeeded,
            stripe_payment_intent_id=f"pi_diff_{gig.id}",
            amount=Decimal("30.00"),
            currency="EUR",
            meta={},
        )
    )
    db_session.commit()
    assert is_selection_fully_paid(db_session, gig=gig, gallery=gallery, selection=selection) is True


# ---------------------------------------------------------------------------
# Admin force-complete now goes through the same guarded transition.
# ---------------------------------------------------------------------------


def test_admin_complete_rejected_from_non_paid_status(client, db_session):
    _ensure_account(db_session, ADMIN_USER_ID)
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, _gallery = _create_gig_with_curve(db_session, client_id, pro_id, included_photos=25)
    gig.status = GigStatus.payment_pending
    db_session.commit()

    resp = client.post(
        f"/v1/admin/gigs/{gig.id}/status",
        headers={"X-User-Id": ADMIN_USER_ID},
        json={"status": "completed", "reason": "test"},
    )
    assert resp.status_code == 409


def test_admin_complete_from_paid_uses_kind_aware_earnings(client, db_session):
    _ensure_account(db_session, ADMIN_USER_ID)
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, _gallery = _create_gig_with_curve(db_session, client_id, pro_id, included_photos=25)
    db_session.add(
        StripePayment(
            gig_id=gig.id,
            kind=StripePaymentKind.extras,
            client_user_id=uuid.UUID(client_id),
            status=PaymentStatus.succeeded,
            stripe_payment_intent_id=f"pi_extras_admin_{gig.id}",
            amount=Decimal("5.00"),
            currency="EUR",
            meta={},
        )
    )
    db_session.commit()

    resp = client.post(
        f"/v1/admin/gigs/{gig.id}/status",
        headers={"X-User-Id": ADMIN_USER_ID},
        json={"status": "completed", "reason": "test"},
    )
    assert resp.status_code == 200

    db_session.refresh(gig)
    assert gig.status == GigStatus.completed

    earnings = db_session.execute(
        select(EarningsLedgerEntry).where(
            EarningsLedgerEntry.pro_user_id == gig.pro_user_id,
            EarningsLedgerEntry.source_type == EarningsSourceType.gig_base,
            EarningsLedgerEntry.source_id == gig.id,
        )
    ).scalar_one()
    assert earnings.gross_eur == Decimal("20.00")  # base only, extras excluded
