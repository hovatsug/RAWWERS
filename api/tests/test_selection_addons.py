"""Adding photos after the selection closed (owner's decision, 2026-11-07).

The window opens when the selection closes, for `selection_addon_days`
stamped on the booking. Already chosen photos stay chosen; the rest may be
added, priced total(chosen + added) - total(chosen) on the booking's curve,
paid through the selection-difference payment path. Each add-on is its own
extras earning, created once; its photos download at once; nothing else
about the booking moves and the photographer is not told."""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.api.v1.webhooks import _apply_stripe_event
from app.models.admin import AdminAuditLog
from app.models.client_rewards_pricing import ExtraImagePurchase, ExtraImagePurchaseStatus
from app.models.communication import Notification
from app.models.gig import Gig, GigStatus, GigTransition, StripePayment, StripePaymentKind
from app.models.media import MediaAsset, MediaStatus
from app.models.payouts import EarningsLedgerEntry, EarningsSourceType
from app.services import selection_addons
from app.services.media_rights import unlocked_final_asset_ids
from app.services.price_reduction import delivery_review_policy
from app.services.selection_quote import selection_total
from app.tasks.outbox_tasks import dispatch_outbox_events_task

from tests.test_download_payment_gate import FakeStripe, _downloads, _save, _setup, _submit

ADMIN = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}


@pytest.fixture(autouse=True)
def rated(monkeypatch):
    monkeypatch.setattr("app.services.download_gate.has_rated_or_reported", lambda db, gig: True)


@pytest.fixture
def fake_stripe(monkeypatch) -> FakeStripe:
    fake = FakeStripe()
    for name in ("create", "retrieve", "modify", "cancel"):
        monkeypatch.setattr(f"stripe.PaymentIntent.{name}", getattr(fake, name))
    return fake


def _finished(client, db_session, *, chosen=20, photos=30):
    """A booking whose client chose `chosen` of `photos` (covered by the
    deposit, so the booking closed at once)."""
    client_id, gig, gallery, assets = _setup(db_session, included=chosen, photos=photos)
    assert _save(client, gallery, client_id, assets[:chosen]).status_code == 200
    assert _submit(client, gallery, client_id).status_code == 200
    db_session.expire_all()
    gig = db_session.get(Gig, gig.id)
    assert gig.status == GigStatus.completed
    return client_id, gig, gallery, assets


def _h(user):
    return {"X-User-Id": str(user)}


def _quote(client, gallery, client_id, adding):
    return client.get(f"/v1/proof-galleries/{gallery.id}/addon-quote", params={"adding": adding}, headers=_h(client_id))


def _start(client, gallery, client_id, asset_ids, request_id=None):
    return client.post(
        f"/v1/proof-galleries/{gallery.id}/addons",
        json={"media_asset_ids": asset_ids, "client_request_id": request_id or str(uuid.uuid4())},
        headers=_h(client_id),
    )


def _pay(db_session, fake, addon_id):
    purchase = db_session.get(ExtraImagePurchase, uuid.UUID(addon_id))
    pi = fake.pis[purchase.stripe_payment_intent_id]
    _apply_stripe_event(db_session, "payment_intent.succeeded", {"id": pi.id, "amount_received": pi.amount})
    db_session.commit()


def test_the_window_opens_when_the_selection_closes_and_keeps_its_end(client, db_session, fake_stripe):
    before = datetime.now(timezone.utc)
    client_id, gig, gallery, _ = _finished(client, db_session)

    assert before + timedelta(days=7) <= gig.addon_window_ends_at <= datetime.now(timezone.utc) + timedelta(days=7)
    stamped = gig.addon_window_ends_at
    delivery_review_policy(db_session).selection_addon_days = 1
    db_session.commit()
    # The booking closing again (a webhook replayed) keeps the first stamp.
    from app.models.gallery import ClientSelection
    from app.services.gallery_completion import finalize_gallery_and_complete_gig

    selection = db_session.execute(select(ClientSelection).where(ClientSelection.gallery_id == gallery.id)).scalars().first()
    finalize_gallery_and_complete_gig(db_session, gallery=gallery, gig=gig, selection=selection)
    db_session.commit()

    detail = client.get(f"/v1/proof-galleries/{gallery.id}", headers=_h(client_id)).json()
    db_session.expire_all()
    assert db_session.get(Gig, gig.id).addon_window_ends_at == stamped, "a later setting never moves it"
    assert detail["addon_open"] is True and len(detail["chosen_media_asset_ids"]) == 20


def test_the_finish_quote_says_how_many_days(client, db_session, fake_stripe):
    client_id, _gig, gallery, _assets = _setup(db_session, included=20, photos=30)
    quote = client.get(f"/v1/proof-galleries/{gallery.id}/selection-quote", params={"selected_count": 20}, headers=_h(client_id))
    assert quote.json()["addon_days"] == 7


def test_the_price_is_the_curve_difference_and_batches_add_up_to_the_same(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _finished(client, db_session)
    t = lambda n: selection_total(db_session, gig=gig, gallery=gallery, photo_count=n)  # noqa: E731

    at_once = Decimal(_quote(client, gallery, client_id, 7).json()["amount"])
    assert at_once == t(27) - t(20)

    first = _start(client, gallery, client_id, assets[20:23]).json()
    assert Decimal(first["amount"]) == t(23) - t(20)
    _pay(db_session, fake_stripe, first["addon_id"])
    second = _start(client, gallery, client_id, assets[23:27]).json()
    assert Decimal(second["amount"]) == t(27) - t(23)

    assert Decimal(first["amount"]) + Decimal(second["amount"]) == at_once


def test_the_add_on_is_paid_through_the_difference_path_as_extras(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _finished(client, db_session)

    started = _start(client, gallery, client_id, assets[20:23]).json()

    assert started["payment_intent_client_secret"] and started["status"] == "pending"
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.extras)).scalar_one()
    assert payment.amount == Decimal(started["amount"])
    assert fake_stripe.creates[-1]["metadata"]["addon_id"] == started["addon_id"]


def test_paid_photos_download_at_once_and_the_booking_does_not_move(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _finished(client, db_session)
    transitions = db_session.execute(select(GigTransition).where(GigTransition.gig_id == gig.id)).scalars().all()
    started = _start(client, gallery, client_id, assets[20:23]).json()

    _pay(db_session, fake_stripe, started["addon_id"])

    db_session.expire_all()
    assert set(map(str, unlocked_final_asset_ids(db_session, gallery=gallery))) == set(assets[:23])
    resp = _downloads(client, gallery, client_id)
    assert resp.status_code == 200 and set(resp.json()["urls"]) == set(assets[:23])
    assert db_session.get(Gig, gig.id).status == GigStatus.completed
    assert len(db_session.execute(select(GigTransition).where(GigTransition.gig_id == gig.id)).scalars().all()) == len(transitions)


def test_each_add_on_is_one_extras_earning_even_if_the_webhook_comes_twice(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _finished(client, db_session)
    started = _start(client, gallery, client_id, assets[20:22]).json()

    _pay(db_session, fake_stripe, started["addon_id"])
    _pay(db_session, fake_stripe, started["addon_id"])

    [entry] = db_session.execute(
        select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_type == EarningsSourceType.extra_images)
    ).scalars().all()
    assert (entry.source_id, entry.gross_eur, entry.pro_user_id) == (uuid.UUID(started["addon_id"]), Decimal(started["amount"]), gig.pro_user_id)
    assert entry.pro_raww_eur is not None, "with its RAWW credit, as extras earn"


def test_the_photographer_is_not_told(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _finished(client, db_session)
    dispatch_outbox_events_task(limit=200)
    before = db_session.query(Notification).filter_by(user_id=gig.pro_user_id).count()
    started = _start(client, gallery, client_id, assets[20:22]).json()

    _pay(db_session, fake_stripe, started["addon_id"])
    dispatch_outbox_events_task(limit=200)

    assert db_session.query(Notification).filter_by(user_id=gig.pro_user_id).count() == before


def test_chosen_photos_cannot_be_added_again_and_strangers_cannot_add(client, db_session, fake_stripe):
    client_id, _gig, gallery, assets = _finished(client, db_session)

    assert _start(client, gallery, client_id, assets[:2]).status_code == 409
    assert _start(client, gallery, client_id, [str(uuid.uuid4())]).status_code == 422
    assert _start(client, gallery, str(uuid.uuid4()), assets[20:21]).status_code == 403


def test_a_second_tap_is_the_same_add_on(client, db_session, fake_stripe):
    client_id, _gig, gallery, assets = _finished(client, db_session)

    a = _start(client, gallery, client_id, assets[20:22], request_id="tap-1").json()
    b = _start(client, gallery, client_id, assets[20:22], request_id="tap-1").json()

    assert a["addon_id"] == b["addon_id"] and len(fake_stripe.creates) == 1


def test_after_the_window_nothing_can_be_added_but_a_started_payment_completes(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _finished(client, db_session)
    started = _start(client, gallery, client_id, assets[20:22]).json()
    gig.addon_window_ends_at = datetime.now(timezone.utc) - timedelta(minutes=1)
    db_session.commit()

    assert _quote(client, gallery, client_id, 1).status_code == 409
    assert _start(client, gallery, client_id, assets[22:23]).status_code == 409
    detail = client.get(f"/v1/proof-galleries/{gallery.id}", headers=_h(client_id)).json()
    assert detail["addon_open"] is False

    _pay(db_session, fake_stripe, started["addon_id"])
    db_session.expire_all()
    assert db_session.get(ExtraImagePurchase, uuid.UUID(started["addon_id"])).status == ExtraImagePurchaseStatus.paid


def test_the_window_boundary(db_session):
    gig = Gig(status=GigStatus.completed, addon_window_ends_at=datetime(2026, 11, 14, 12, tzinfo=timezone.utc))
    assert selection_addons.window_open(gig, now=datetime(2026, 11, 14, 11, 59, 59, tzinfo=timezone.utc)) is True
    assert selection_addons.window_open(gig, now=datetime(2026, 11, 14, 12, tzinfo=timezone.utc)) is False
    gig.status = GigStatus.refunded
    assert selection_addons.window_open(gig, now=datetime(2026, 11, 13, tzinfo=timezone.utc)) is False


def test_no_add_ons_on_a_cancelled_or_refunded_booking(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _finished(client, db_session)
    gig.status = GigStatus.refunded
    db_session.commit()

    assert _start(client, gallery, client_id, assets[20:21]).status_code == 409


def test_one_reminder_two_days_before_if_photos_are_left(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _finished(client, db_session)
    now = datetime.now(timezone.utc)

    gig.addon_window_ends_at = now + timedelta(days=3)
    db_session.commit()
    assert selection_addons.send_closing_reminders(db_session, now=now) == 0, "not yet"

    gig.addon_window_ends_at = now + timedelta(days=1, hours=20)
    db_session.commit()
    selection_addons.send_closing_reminders(db_session, now=now)
    selection_addons.send_closing_reminders(db_session, now=now + timedelta(hours=1))
    db_session.commit()
    dispatch_outbox_events_task(limit=200)

    notes = db_session.execute(select(Notification).where(Notification.user_id == uuid.UUID(client_id), Notification.type == "proofs.addon_closing")).scalars().all()
    assert len(notes) == 1 and "10 photos" in notes[0].body


def test_no_reminder_when_nothing_is_left_to_add(client, db_session, fake_stripe):
    client_id, gig, gallery, _assets = _finished(client, db_session, chosen=20, photos=20)
    gig.addon_window_ends_at = datetime.now(timezone.utc) + timedelta(days=1)
    db_session.commit()

    assert selection_addons.send_closing_reminders(db_session) == 0


def test_unchosen_photos_are_kept_while_the_window_is_open(client, db_session, fake_stripe):
    from app.services.unfinished_uploads import remove_unfinished_uploads

    client_id, gig, gallery, assets = _finished(client, db_session)

    remove_unfinished_uploads(db_session, now=datetime.now(timezone.utc) + timedelta(days=30))
    db_session.commit()

    db_session.expire_all()
    for asset_id in assets[20:]:
        assert db_session.get(MediaAsset, uuid.UUID(asset_id)).status == MediaStatus.ready


def test_an_admin_extends_the_window_with_a_note(client, db_session, fake_stripe):
    client_id, gig, gallery, _assets = _finished(client, db_session)
    ends = gig.addon_window_ends_at

    assert client.post(f"/v1/admin/gigs/{gig.id}/selection-window/extend", json={"days": 3, "note": " "}, headers=ADMIN).status_code == 422
    assert client.post(f"/v1/admin/gigs/{gig.id}/selection-window/extend", json={"days": 3, "note": "x"}, headers=_h(client_id)).status_code in (401, 403)
    resp = client.post(f"/v1/admin/gigs/{gig.id}/selection-window/extend", json={"days": 3, "note": "Client was travelling"}, headers=ADMIN)

    assert resp.status_code == 200
    db_session.expire_all()
    assert db_session.get(Gig, gig.id).addon_window_ends_at == ends + timedelta(days=3)
    log = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.action == "selection_window_extended")).scalar_one()
    assert log.reason == "Client was travelling" and log.meta["days"] == 3


def test_a_closed_window_extends_from_now(client, db_session, fake_stripe):
    client_id, gig, gallery, _assets = _finished(client, db_session)
    gig.addon_window_ends_at = datetime.now(timezone.utc) - timedelta(days=5)
    db_session.commit()

    client.post(f"/v1/admin/gigs/{gig.id}/selection-window/extend", json={"days": 2, "note": "Reopened"}, headers=ADMIN)

    db_session.expire_all()
    assert db_session.get(Gig, gig.id).addon_window_ends_at > datetime.now(timezone.utc) + timedelta(days=1, hours=23)


def test_the_setting_is_an_admin_one(client, db_session):
    resp = client.put("/v1/admin/policies/delivery-review", json={"selection_addon_days": 10}, headers=ADMIN)

    assert resp.status_code == 200 and resp.json()["selection_addon_days"] == 10
    assert client.get("/v1/admin/policies/delivery-review", headers=ADMIN).json()["selection_addon_days"] == 10


def test_a_refunded_add_on_takes_its_photos_and_earning_back(client, db_session, fake_stripe, monkeypatch):
    from app.services.refund_reconcile import reconcile_payment_refunds

    client_id, gig, gallery, assets = _finished(client, db_session)
    started = _start(client, gallery, client_id, assets[20:22]).json()
    _pay(db_session, fake_stripe, started["addon_id"])
    purchase = db_session.get(ExtraImagePurchase, uuid.UUID(started["addon_id"]))
    cents = int(Decimal(started["amount"]) * 100)
    monkeypatch.setattr(
        "app.services.refund_reconcile.fetch_refunds", lambda pi: [{"id": "re_1", "status": "succeeded", "amount": cents}]
    )

    assert reconcile_payment_refunds(db_session, purchase.stripe_payment_intent_id, trigger="test") is True
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(ExtraImagePurchase, purchase.id).status == ExtraImagePurchaseStatus.refunded
    [entry] = db_session.execute(select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_type == EarningsSourceType.extra_images)).scalars().all()
    assert entry.reversed_at is not None
    assert set(map(str, unlocked_final_asset_ids(db_session, gallery=gallery))) == set(assets[:20])
    assert db_session.get(Gig, gig.id).status == GigStatus.completed, "the booking is not touched"
