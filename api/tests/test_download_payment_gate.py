"""Finals are released for money received, and for the amount that was owed.

Three defects with one root, found by tracing what re-entry does rather than
the happy path:

  1. Downloads for a curve-priced gig never checked payment. Submitting a
     selection granted the entitlement and marked the selection submitted
     *before* the difference PaymentIntent was paid, and the download paths
     only asked whether a selection had been submitted.
  2. `create_or_get_gig_payment_intent` returned any existing difference
     payment without looking at its amount, so a client who re-selected got
     the old intent back - the app quoted one price and Stripe charged another.
  3. `save_selection` still accepted a gallery whose booking had already
     completed, so a client could submit a larger selection, be handed the
     already-succeeded intent, and have `is_selection_fully_paid` agree that it
     was paid - 100 photographs for a 25-photograph payment.

The existing `test_declined_difference_charge_leaves_gig_open` asserts the gig
and gallery status and never asks whether a download is refused, so it would
have passed with the gate wide open. Every test here asks the download.

The fake Stripe below enforces the rules verified against test mode: an
intent's amount can be changed only while it is `requires_payment_method`,
and an unconfirmed-but-attached one (`requires_action`) has to be replaced.
"""
import uuid
from decimal import Decimal

import pytest
import stripe
from sqlalchemy import select

from app.models.gallery import ClientSelection, ProofGalleryItem, ProofGalleryStatus, SelectionStatus
from app.models.gig import GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.services.gallery_completion import is_selection_fully_paid
from app.services.media_rights import unlocked_final_asset_ids
from app.services.package_pricing import compute_package_total
from app.tasks.outbox_tasks import dispatch_outbox_events_task

from tests.test_booking_close import _ensure_account, _select_photos
from tests.test_selection_pricing_regimes import _curve_gig


class FakePI:
    def __init__(self, pi_id: str, secret: str, amount: int):
        self.id = pi_id
        self.client_secret = secret
        self.status = "requires_payment_method"
        self.amount = amount
        self.amount_received = 0


class FakeStripe:
    """Records what the code asked Stripe to do, and refuses what Stripe refuses."""

    def __init__(self):
        self.pis: dict[str, FakePI] = {}
        self.creates: list[dict] = []
        self.modifies: list[tuple[str, int]] = []
        self.cancels: list[str] = []

    def create(self, **kwargs):
        n = len(self.creates) + 1
        pi = FakePI(f"pi_{n}", f"sec_{n}", kwargs["amount"])
        self.pis[pi.id] = pi
        self.creates.append(kwargs)
        return pi

    def retrieve(self, pi_id, **_kwargs):
        return self.pis[pi_id]

    def modify(self, pi_id, **kwargs):
        pi = self.pis[pi_id]
        if pi.status != "requires_payment_method":
            raise stripe.InvalidRequestError(
                f"This PaymentIntent's amount could not be updated because it has a status of {pi.status}.", "amount"
            )
        pi.amount = kwargs["amount"]
        self.modifies.append((pi_id, kwargs["amount"]))
        return pi

    def cancel(self, pi_id, **_kwargs):
        self.pis[pi_id].status = "canceled"
        self.cancels.append(pi_id)
        return self.pis[pi_id]


@pytest.fixture
def fake_stripe(monkeypatch) -> FakeStripe:
    fake = FakeStripe()
    monkeypatch.setattr("stripe.PaymentIntent.create", fake.create)
    monkeypatch.setattr("stripe.PaymentIntent.retrieve", fake.retrieve)
    monkeypatch.setattr("stripe.PaymentIntent.modify", fake.modify)
    monkeypatch.setattr("stripe.PaymentIntent.cancel", fake.cancel)
    return fake


def _cents(amount: Decimal) -> int:
    return int((amount * Decimal("100")).quantize(Decimal("1")))


def _setup(db_session, *, included: int = 20, photos: int = 30):
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _curve_gig(db_session, client_id, pro_id, included_photos=included)
    assets = _select_photos(db_session, gallery, pro_id, client_id, count=photos)
    return client_id, gig, gallery, [str(a.id) for a in assets]


def _balance(db_session, gig, photo_count: int) -> Decimal:
    total = compute_package_total(db_session, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=photo_count)
    return total - gig.amount_minimum


def _save(client, gallery, client_id, asset_ids):
    return client.post(
        f"/v1/proof-galleries/{gallery.id}/selections",
        json={"media_asset_ids": asset_ids},
        headers={"X-User-Id": client_id},
    )


def _submit(client, gallery, client_id):
    return client.post(f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id})


def _downloads(client, gallery, client_id):
    return client.get(f"/v1/proof-galleries/{gallery.id}/downloads", headers={"X-User-Id": client_id})


def _signed_final(client, gig, asset_id, client_id):
    return client.get(
        f"/v1/gigs/{gig.id}/media/{asset_id}/download",
        params={"kind": "full_res"},
        headers={"X-User-Id": client_id},
    )


def _webhook(client, monkeypatch, event_type: str, pi_id: str, **object_fields):
    event = {
        "id": f"evt_{event_type}_{pi_id}_{len(object_fields)}",
        "type": event_type,
        "data": {"object": {"id": pi_id, **object_fields}},
    }
    monkeypatch.setattr("app.api.v1.webhooks.construct_stripe_event", lambda raw, sig: event)
    resp = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "sig"})
    assert resp.status_code == 200, resp.text
    dispatch_outbox_events_task(limit=100)


def _difference_rows(db_session, gig):
    db_session.expire_all()
    return db_session.execute(
        select(StripePayment)
        .where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.difference)
        .order_by(StripePayment.created_at.asc())
    ).scalars().all()


# ---------------------------------------------------------------------------
# 1. Nothing is released until the difference has been paid.
# ---------------------------------------------------------------------------


def test_downloads_endpoint_refuses_while_the_difference_is_unpaid(client, db_session, fake_stripe):
    client_id, gig, gallery, _assets = _setup(db_session)
    assert _submit(client, gallery, client_id).status_code == 200

    resp = _downloads(client, gallery, client_id)

    assert resp.status_code == 402, f"finals were released for an unpaid difference: {resp.status_code} {resp.text[:120]}"


def test_signed_url_refuses_while_the_difference_is_unpaid(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _setup(db_session)
    assert _submit(client, gallery, client_id).status_code == 200

    resp = _signed_final(client, gig, assets[0], client_id)

    assert resp.status_code == 403, f"a final was signed for an unpaid difference: {resp.status_code}"


def test_a_declined_difference_charge_then_a_download_attempt_is_refused(client, db_session, fake_stripe, monkeypatch):
    client_id, gig, gallery, assets = _setup(db_session)
    assert _submit(client, gallery, client_id).status_code == 200
    pi_id = _difference_rows(db_session, gig)[0].stripe_payment_intent_id

    _webhook(client, monkeypatch, "payment_intent.payment_failed", pi_id, last_payment_error={"message": "declined"})

    assert _difference_rows(db_session, gig)[0].status == PaymentStatus.failed
    assert _downloads(client, gallery, client_id).status_code == 402
    assert _signed_final(client, gig, assets[0], client_id).status_code == 403


def test_paying_the_difference_unlocks_every_selected_photo(client, db_session, fake_stripe, monkeypatch):
    """The other direction: a gate that refuses everything is as useless as
    one that refuses nothing."""
    client_id, gig, gallery, assets = _setup(db_session)
    assert _submit(client, gallery, client_id).status_code == 200
    row = _difference_rows(db_session, gig)[0]

    _webhook(
        client, monkeypatch, "payment_intent.succeeded", row.stripe_payment_intent_id,
        amount_received=_cents(row.amount),
    )

    resp = _downloads(client, gallery, client_id)
    assert resp.status_code == 200, resp.text
    assert len(resp.json()["urls"]) == 30
    assert _signed_final(client, gig, assets[0], client_id).status_code == 200


def test_nothing_owed_downloads_immediately(client, db_session, fake_stripe):
    """A selection the deposit already covers owes nothing, so there is
    nothing further to wait for."""
    client_id, gig, gallery, assets = _setup(db_session, photos=12)
    resp = _submit(client, gallery, client_id)
    assert resp.status_code == 200
    assert resp.json()["difference_required"] is False

    assert _downloads(client, gallery, client_id).status_code == 200
    assert _signed_final(client, gig, assets[0], client_id).status_code == 200


# ---------------------------------------------------------------------------
# 2. The intent follows the selection.
# ---------------------------------------------------------------------------


def test_a_stale_intent_is_brought_to_the_new_amount(client, db_session, fake_stripe):
    """The bug: submit 25, abandon, come back, submit 30 - and be handed the
    25-photo intent for a 30-photo selection."""
    client_id, gig, gallery, assets = _setup(db_session)
    first = _save(client, gallery, client_id, assets[:25])
    assert first.status_code == 200
    r1 = _submit(client, gallery, client_id)
    assert r1.status_code == 200, r1.text

    assert _save(client, gallery, client_id, assets[:30]).status_code == 200
    r2 = _submit(client, gallery, client_id)
    assert r2.status_code == 200, r2.text

    owed = _balance(db_session, gig, 30)
    rows = _difference_rows(db_session, gig)
    assert len(rows) == 1, "a second payment row was created for the same charge"
    assert rows[0].amount == owed, f"row still says {rows[0].amount}, selection owes {owed}"
    assert fake_stripe.pis[rows[0].stripe_payment_intent_id].amount == _cents(owed), "Stripe would charge the old amount"
    assert Decimal(r2.json()["difference_amount"]) == owed
    # Changed in place, so the secret the app may already hold stays valid.
    assert r2.json()["difference_payment_intent_client_secret"] == r1.json()["difference_payment_intent_client_secret"]
    assert len(fake_stripe.creates) == 1


def test_an_intent_stripe_will_not_modify_is_replaced(client, db_session, fake_stripe):
    """Once a card has been attached and 3DS is pending, Stripe moves the
    intent to requires_confirmation on an amount change - a state the payment
    sheet is not assumed to handle. It is cancelled and replaced instead."""
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    old_id = _difference_rows(db_session, gig)[0].stripe_payment_intent_id
    fake_stripe.pis[old_id].status = "requires_action"

    _save(client, gallery, client_id, assets[:30])
    r2 = _submit(client, gallery, client_id)
    assert r2.status_code == 200, r2.text

    owed = _balance(db_session, gig, 30)
    assert fake_stripe.cancels == [old_id]
    assert len(fake_stripe.creates) == 2
    assert fake_stripe.creates[0]["idempotency_key"] != fake_stripe.creates[1]["idempotency_key"], (
        "Stripe rejects a reused key with different parameters"
    )
    rows = _difference_rows(db_session, gig)
    open_rows = [r for r in rows if r.status not in (PaymentStatus.cancelled, PaymentStatus.succeeded)]
    assert len(open_rows) == 1 and open_rows[0].amount == owed
    assert r2.json()["difference_payment_intent_id"] == open_rows[0].stripe_payment_intent_id


def test_a_payment_that_is_clearing_cannot_be_changed(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    pi_id = _difference_rows(db_session, gig)[0].stripe_payment_intent_id
    fake_stripe.pis[pi_id].status = "processing"

    _save(client, gallery, client_id, assets[:30])
    resp = _submit(client, gallery, client_id)

    assert resp.status_code == 409, resp.text
    assert not fake_stripe.modifies and not fake_stripe.cancels and len(fake_stripe.creates) == 1


# ---------------------------------------------------------------------------
# 3. A completed booking's selection is final.
# ---------------------------------------------------------------------------


def test_reselecting_after_completion_is_refused(client, db_session, fake_stripe, monkeypatch):
    """The theft path: pay for 25, then submit 100 and be believed."""
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    row = _difference_rows(db_session, gig)[0]
    _webhook(
        client, monkeypatch, "payment_intent.succeeded", row.stripe_payment_intent_id,
        amount_received=_cents(row.amount),
    )
    db_session.refresh(gig)
    db_session.refresh(gallery)
    assert gig.status == GigStatus.completed
    assert gallery.status == ProofGalleryStatus.selection_submitted

    saved = _save(client, gallery, client_id, assets[:30])
    assert saved.status_code == 409, f"a completed booking accepted a new selection: {saved.status_code}"
    assert _submit(client, gallery, client_id).status_code == 409

    # And what they paid for is still exactly what they can download.
    assert len(_downloads(client, gallery, client_id).json()["urls"]) == 25


# ---------------------------------------------------------------------------
# 4. "Fully paid" means the amount owed, not that some payment exists.
# ---------------------------------------------------------------------------


def _submitted_selection(db_session, gallery):
    selection = db_session.execute(
        select(ClientSelection).where(ClientSelection.gallery_id == gallery.id).order_by(ClientSelection.version.desc())
    ).scalars().first()
    selection.status = SelectionStatus.submitted
    db_session.commit()
    return selection


def _difference_payment(db_session, gig, amount: Decimal, *, status=PaymentStatus.succeeded, suffix="a"):
    db_session.add(
        StripePayment(
            gig_id=gig.id,
            kind=StripePaymentKind.difference,
            client_user_id=gig.client_user_id,
            status=status,
            stripe_payment_intent_id=f"pi_unit_{gig.id}_{suffix}",
            amount=amount,
            currency="EUR",
            meta={},
        )
    )
    db_session.commit()


def test_a_smaller_payment_than_owed_is_not_full_payment(db_session):
    client_id, gig, gallery, _assets = _setup(db_session)
    gig.amount_final = compute_package_total(db_session, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=30)
    db_session.commit()
    selection = _submitted_selection(db_session, gallery)
    owed = gig.amount_final - gig.amount_minimum

    _difference_payment(db_session, gig, owed - Decimal("1.00"))

    assert is_selection_fully_paid(db_session, gig=gig, gallery=gallery, selection=selection) is False
    assert unlocked_final_asset_ids(db_session, gallery=gallery) == []


def test_payments_summing_to_the_amount_owed_are_full_payment(db_session):
    client_id, gig, gallery, _assets = _setup(db_session)
    gig.amount_final = compute_package_total(db_session, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=30)
    db_session.commit()
    selection = _submitted_selection(db_session, gallery)
    owed = gig.amount_final - gig.amount_minimum

    _difference_payment(db_session, gig, owed, suffix="whole")

    assert is_selection_fully_paid(db_session, gig=gig, gallery=gallery, selection=selection) is True
    assert len(unlocked_final_asset_ids(db_session, gallery=gallery)) == 30


def test_a_booking_whose_base_payment_never_succeeded_releases_nothing(db_session):
    """The quote's `amount_paid` assumes the deposit was collected; the gate
    has to check it rather than assume it."""
    client_id, gig, gallery, _assets = _setup(db_session)
    gig.amount_final = compute_package_total(db_session, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=30)
    selection = _submitted_selection(db_session, gallery)
    owed = gig.amount_final - gig.amount_minimum
    _difference_payment(db_session, gig, owed, suffix="whole")
    base = db_session.execute(
        select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.base)
    ).scalar_one()
    base.status = PaymentStatus.failed
    db_session.commit()

    assert is_selection_fully_paid(db_session, gig=gig, gallery=gallery, selection=selection) is False
    assert unlocked_final_asset_ids(db_session, gallery=gallery) == []


# ---------------------------------------------------------------------------
# 5. The ledger records what Stripe received.
# ---------------------------------------------------------------------------


def test_the_webhook_records_what_stripe_actually_received(client, db_session, fake_stripe, monkeypatch):
    """The observability this whole class of bug lacked: our row said one
    amount, Stripe collected another, and nothing compared them."""
    client_id, gig, gallery, assets = _setup(db_session)
    assert _submit(client, gallery, client_id).status_code == 200
    row = _difference_rows(db_session, gig)[0]
    expected = row.amount
    received = expected - Decimal("1.00")

    _webhook(
        client, monkeypatch, "payment_intent.succeeded", row.stripe_payment_intent_id,
        amount_received=_cents(received),
    )

    row = _difference_rows(db_session, gig)[0]
    assert row.amount == received, "the row kept the amount we intended, not the amount Stripe took"
    assert row.meta.get("amount_mismatch") == {"expected": str(expected), "received": str(received)}
    # An underpayment is not a paid booking.
    assert _downloads(client, gallery, client_id).status_code == 402


def test_a_matching_amount_leaves_no_mismatch_note(client, db_session, fake_stripe, monkeypatch):
    client_id, gig, gallery, _assets = _setup(db_session)
    assert _submit(client, gallery, client_id).status_code == 200
    row = _difference_rows(db_session, gig)[0]

    _webhook(
        client, monkeypatch, "payment_intent.succeeded", row.stripe_payment_intent_id,
        amount_received=_cents(row.amount),
    )

    row = _difference_rows(db_session, gig)[0]
    assert "amount_mismatch" not in row.meta
    assert row.status == PaymentStatus.succeeded


# ---------------------------------------------------------------------------
# 6. Entitlement follows payment, and a shortfall can be made good.
# ---------------------------------------------------------------------------


def test_the_finals_entitlement_is_granted_when_paid_not_when_submitted(client, db_session, fake_stripe, monkeypatch):
    """`list_gig_media` advertises full-resolution derivatives to anyone who
    holds this entitlement, so granting it at submit made the listing promise
    files the download paths would then refuse."""
    from app.models.media_rights import GigEntitlementType
    from app.services.media_rights import has_valid_entitlement

    client_id, gig, gallery, _assets = _setup(db_session)
    holds = lambda: has_valid_entitlement(  # noqa: E731
        db_session, gig_id=gig.id, user_id=gig.client_user_id, entitlement_type=GigEntitlementType.download_finals
    )
    assert _submit(client, gallery, client_id).status_code == 200
    assert holds() is False, "finals were promised before the difference was paid"

    row = _difference_rows(db_session, gig)[0]
    _webhook(
        client, monkeypatch, "payment_intent.succeeded", row.stripe_payment_intent_id,
        amount_received=_cents(row.amount),
    )

    assert holds() is True


def test_an_underpayment_shows_the_shortfall_and_can_be_topped_up(client, db_session, fake_stripe, monkeypatch):
    """The ledger records what Stripe took, so a short payment leaves the
    booking open with a real balance. The quote must name that balance - not
    the whole difference - and submit must charge exactly it, or the client
    is shown one price and charged another all over again."""
    client_id, gig, gallery, assets = _setup(db_session)
    assert _submit(client, gallery, client_id).status_code == 200
    first = _difference_rows(db_session, gig)[0]
    short = Decimal("1.00")

    _webhook(
        client, monkeypatch, "payment_intent.succeeded", first.stripe_payment_intent_id,
        amount_received=_cents(first.amount - short),
    )
    db_session.refresh(gallery)
    assert gallery.status == ProofGalleryStatus.published, "a short payment closed the booking"

    quote = client.get(
        f"/v1/proof-galleries/{gallery.id}/selection-quote",
        params={"selected_count": 30},
        headers={"X-User-Id": client_id},
    )
    assert quote.status_code == 200, quote.text
    assert Decimal(quote.json()["amount_due"]) == short, "the quote named the whole difference, not the shortfall"

    _save(client, gallery, client_id, assets)
    top_up = _submit(client, gallery, client_id)
    assert top_up.status_code == 200, top_up.text
    assert Decimal(top_up.json()["difference_amount"]) == short
    rows = _difference_rows(db_session, gig)
    assert [r.status for r in rows] == [PaymentStatus.succeeded, PaymentStatus.pending]
    assert fake_stripe.pis[rows[1].stripe_payment_intent_id].amount == _cents(short)
    assert fake_stripe.creates[0]["idempotency_key"] != fake_stripe.creates[1]["idempotency_key"]

    _webhook(
        client, monkeypatch, "payment_intent.succeeded", rows[1].stripe_payment_intent_id,
        amount_received=_cents(short),
    )

    db_session.refresh(gig)
    assert gig.status == GigStatus.completed
    assert len(_downloads(client, gallery, client_id).json()["urls"]) == 30


def test_a_draft_saved_before_completion_cannot_be_submitted_after_it(client, db_session, fake_stripe, monkeypatch):
    """The other way in: while a payment is still pending the gallery is open,
    so a larger draft can be saved. When the payment then lands and the booking
    closes, that draft is still sitting there waiting to be submitted."""
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    assert _save(client, gallery, client_id, assets[:30]).status_code == 200  # still open: unpaid

    row = _difference_rows(db_session, gig)[0]
    _webhook(
        client, monkeypatch, "payment_intent.succeeded", row.stripe_payment_intent_id,
        amount_received=_cents(row.amount),
    )
    db_session.refresh(gallery)
    assert gallery.status == ProofGalleryStatus.selection_submitted

    assert _submit(client, gallery, client_id).status_code == 409, "a completed booking accepted a queued larger selection"
    assert len(_downloads(client, gallery, client_id).json()["urls"]) == 25
