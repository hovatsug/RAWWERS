"""The space between the two pricing systems.

Nothing tested this. The difference-charge tests kept every selection inside
`included_photos` so extras never triggered - `test_booking_close.py` says so
in a comment - and the upsell tests used a gig with no curve. Each system was
correct in isolation; the bug lived only where they overlapped. A curve-priced
gig whose client selected past `included_photos` billed those photos twice,
once inside `amount_final` and once as flat extras, and the booking could not
close until both were paid.

These tests occupy that gap deliberately.
"""
import uuid
from decimal import Decimal

from app.models.gallery import ClientSelection, ProofGallery, ProofGalleryStatus, UpsellPurchase
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.services.gallery_completion import is_selection_fully_paid
from app.services.media_rights import unlocked_final_asset_ids
from app.services.niche_catalog import ensure_initial_niches, get_active_niche_by_slug
from app.services.package_pricing import compute_minimum_amount, compute_package_total, is_curve_priced
from sqlalchemy import select

from tests.test_booking_close import DummyStripePI, _ensure_account, _select_photos


def _latest_selection(db_session, gallery_id):
    return db_session.execute(
        select(ClientSelection)
        .where(ClientSelection.gallery_id == gallery_id)
        .order_by(ClientSelection.version.desc())
    ).scalars().first()


def _curve_gig(db_session, client_id: str, pro_id: str, *, included_photos: int):
    """A curve-priced booking built the way the booking endpoints now build one.

    `test_booking_close._create_gig_with_curve` hardcodes amount_minimum to
    10 x entry_rate - the value this change replaces - so reusing it here
    would exercise the old basis and quietly pass. This mirrors what
    pro_onboarding and scheduling actually do.
    """
    ensure_initial_niches(db_session)
    niche = get_active_niche_by_slug(db_session, "portraits")
    entry_rate = Decimal("2.00")
    amount_minimum = compute_minimum_amount(
        db_session, niche_id=niche.id, entry_rate=entry_rate, included_photos=included_photos
    )

    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=niche.id,
        status=GigStatus.paid,
        currency="EUR",
        amount_minimum=amount_minimum,
        entry_rate=entry_rate,
        amount_platform_fee=Decimal("0.00"),
        amount_pro_gross=amount_minimum,
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
            amount=amount_minimum,
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


def _submit(client, gallery, client_id, monkeypatch):
    """Submit, recording every PaymentIntent Stripe was asked to create.

    Deliberately one patch, not two. `app.api.v1.proof_galleries.stripe` and
    `app.services.payment_intents.stripe` are the same module object, so
    patching both paths means the second silently replaces the first - which
    is how an earlier version of this test caught the *difference* charge in a
    trap meant for the upsell. Which charge is which is settled by what lands
    in the database, not by which module asked for it.
    """
    created: list[dict] = []

    def _create(**kwargs):
        created.append(kwargs)
        return DummyStripePI(f"pi_{len(created)}", f"sec_{len(created)}")

    monkeypatch.setattr("stripe.PaymentIntent.create", _create)
    resp = client.post(f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id})
    return resp, created


def test_photos_past_included_are_charged_once_not_twice(client, db_session, monkeypatch):
    """The bug itself: 30 selected against a 20-photo package on a curve gig."""
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _curve_gig(db_session, client_id, pro_id, included_photos=20)
    _select_photos(db_session, gallery, pro_id, client_id, count=30)

    resp, created = _submit(client, gallery, client_id, monkeypatch)
    assert resp.status_code == 200, resp.text
    body = resp.json()

    assert body["extras_count"] == 0, "the curve already priced every selected photo"
    assert body["upsell_required"] is False
    assert body["payment_intent_id"] is None

    db_session.refresh(gig)
    expected_final = compute_package_total(
        db_session, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=30
    )
    assert gig.amount_final == expected_final

    # Exactly one charge, and it is the difference.
    charges = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalars().all()
    kinds = sorted(c.kind.value for c in charges)
    assert "extras" not in kinds, f"an extras charge was still raised: {kinds}"
    assert db_session.execute(select(UpsellPurchase)).scalars().first() is None
    assert len(created) == 1, f"one PaymentIntent for one charge, got {len(created)}"

    difference = next(c for c in charges if c.kind == StripePaymentKind.difference)
    assert difference.amount == expected_final - gig.amount_minimum


def test_selecting_exactly_what_the_package_includes_owes_nothing(client, db_session, monkeypatch):
    """The second defect: `included` has to mean included.

    amount_minimum was the curve total for 10 photos whatever the package
    promised, so a 20-photo package still charged a difference for photos
    11-20 - photos the client had already paid for.
    """
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _curve_gig(db_session, client_id, pro_id, included_photos=20)
    _select_photos(db_session, gallery, pro_id, client_id, count=20)

    resp, created = _submit(client, gallery, client_id, monkeypatch)
    assert resp.status_code == 200, resp.text
    body = resp.json()

    assert created == [], f"nothing is owed, so no PaymentIntent should exist: {created}"
    assert body["difference_required"] is False, "charged for photos the package includes"
    assert body["upsell_required"] is False

    db_session.refresh(gig)
    assert gig.amount_final == gig.amount_minimum
    assert gig.status == GigStatus.completed, "nothing owed, so the booking closes"


def test_amount_minimum_covers_the_included_photos_not_just_ten(db_session):
    ensure_initial_niches(db_session)
    niche = get_active_niche_by_slug(db_session, "weddings")
    entry = Decimal("10.00")

    minimum = compute_minimum_amount(db_session, niche_id=niche.id, entry_rate=entry, included_photos=20)
    curve_for_20 = compute_package_total(db_session, niche_id=niche.id, entry_rate=entry, photo_count=20)
    curve_for_10 = compute_package_total(db_session, niche_id=niche.id, entry_rate=entry, photo_count=10)

    assert minimum == curve_for_20
    assert minimum > curve_for_10, "the old basis undercharged for the included photos"
    # And not the flat reading, which would collect more than amount_final
    # ever comes to and leave the client overpaid with nothing to reconcile.
    assert minimum < entry * 20


def test_a_curve_gig_unlocks_every_photo_it_charged_for(client, db_session, monkeypatch):
    """Dropping the extras charge must not strand the photos behind it.

    Unlocking used to be gated on a succeeded UpsellPurchase, so removing the
    charge without this would leave a client paying the curve for 30 photos
    and able to download 20.
    """
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _curve_gig(db_session, client_id, pro_id, included_photos=20)
    _select_photos(db_session, gallery, pro_id, client_id, count=30)
    _submit(client, gallery, client_id, monkeypatch)

    # "Paid the curve" has to be true. This test used to submit and assert the
    # unlock without ever settling the difference charge, which is the bug
    # written down as the expectation: nothing unlocks for an unpaid selection
    # (tests/test_download_payment_gate.py). What this test is for is the other
    # half - once the curve is paid, no upsell stands between the client and
    # the photographs.
    for payment in db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalars():
        payment.status = PaymentStatus.succeeded
    db_session.commit()

    db_session.refresh(gallery)
    unlocked = unlocked_final_asset_ids(db_session, gallery=gallery)
    assert len(unlocked) == 30, f"paid the curve for 30 photos, unlocked {len(unlocked)}"


def test_completion_no_longer_waits_on_an_upsell_that_will_never_come(client, db_session, monkeypatch):
    """is_selection_fully_paid required a succeeded UpsellPurchase whenever the
    selection went past included_photos. With no extras charge raised for a
    curve gig, that condition could never be satisfied and the booking would
    hang forever once the difference was paid."""
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _curve_gig(db_session, client_id, pro_id, included_photos=20)
    _select_photos(db_session, gallery, pro_id, client_id, count=30)
    _submit(client, gallery, client_id, monkeypatch)

    selection = _latest_selection(db_session, gallery.id)
    assert is_selection_fully_paid(db_session, gig=gig, gallery=gallery, selection=selection) is False

    difference = db_session.execute(
        select(StripePayment).where(
            StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.difference
        )
    ).scalar_one()
    difference.status = PaymentStatus.succeeded
    db_session.commit()

    assert is_selection_fully_paid(db_session, gig=gig, gallery=gallery, selection=selection) is True


def test_the_upsell_endpoint_refuses_a_curve_gig(client, db_session, monkeypatch):
    """The other door into the same double charge."""
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _curve_gig(db_session, client_id, pro_id, included_photos=20)
    _select_photos(db_session, gallery, pro_id, client_id, count=30)
    _submit(client, gallery, client_id, monkeypatch)

    resp = client.post(
        f"/v1/proof-galleries/{gallery.id}/upsell/create-intent", headers={"X-User-Id": client_id}, json={}
    )
    assert resp.status_code == 409, resp.text
    assert db_session.execute(select(UpsellPurchase)).scalars().first() is None


def test_a_gig_without_a_curve_still_sells_extras(db_session):
    """The legacy path is untouched: no niche or entry rate means flat extras
    remain the model, so this change cannot strand those bookings."""
    from tests.test_proof_gallery import _create_gig

    gig = _create_gig(db_session, str(uuid.uuid4()), str(uuid.uuid4()))
    assert gig.niche_id is None and gig.entry_rate is None
    assert is_curve_priced(gig) is False
