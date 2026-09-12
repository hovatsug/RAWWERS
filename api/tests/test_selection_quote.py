"""Pricing a selection before committing to it.

The client is choosing photographs and spending money at the same time, so
these numbers are on screen while they decide. The one that matters most is
not the total but the agreement: what the quote says and what Stripe takes
have to be the same arithmetic, not two implementations that match today.
"""
import uuid
from decimal import Decimal

from app.models.gig import StripePayment, StripePaymentKind
from app.services.package_pricing import MINIMUM_PHOTOS, compute_package_total
from sqlalchemy import select

from tests.test_booking_close import DummyStripePI, _ensure_account, _select_photos
from tests.test_selection_pricing_regimes import _curve_gig


def _quote(client, gallery, client_id, count=None):
    url = f"/v1/proof-galleries/{gallery.id}/selection-quote"
    if count is not None:
        url += f"?selected_count={count}"
    resp = client.get(url, headers={"X-User-Id": client_id})
    assert resp.status_code == 200, resp.text
    return resp.json()


def _setup(db_session, *, included=20, photos=30):
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _curve_gig(db_session, client_id, pro_id, included_photos=included)
    _select_photos(db_session, gallery, pro_id, client_id, count=photos)
    return client_id, pro_id, gig, gallery


# ---------------------------------------------------------------------------
# The rule: one function, two callers.
# ---------------------------------------------------------------------------


def test_the_quote_matches_what_is_actually_charged(client, db_session, monkeypatch):
    """The failure this exists to prevent: the app shows one price and Stripe
    takes another. Quote 30 photos, then submit 30, and compare."""
    client_id, _pro_id, gig, gallery = _setup(db_session, included=20, photos=30)

    quoted = _quote(client, gallery, client_id, count=30)

    created: list[dict] = []

    def _create(**kwargs):
        created.append(kwargs)
        return DummyStripePI("pi_q", "sec_q")

    monkeypatch.setattr("stripe.PaymentIntent.create", _create)
    submitted = client.post(
        f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id}
    )
    assert submitted.status_code == 200, submitted.text

    charge = db_session.execute(
        select(StripePayment).where(
            StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.difference
        )
    ).scalar_one()

    assert Decimal(quoted["amount_due"]) == charge.amount, "quoted one price, charged another"
    db_session.refresh(gig)
    assert Decimal(quoted["amount_total"]) == gig.amount_final


def test_money_crosses_the_wire_as_a_string_not_a_float(client, db_session):
    """A float here rounds someone's bill. Decimal end to end, per the rule."""
    client_id, _pro, _gig, gallery = _setup(db_session)
    body = _quote(client, gallery, client_id, count=25)
    for field in ("amount_total", "amount_paid", "amount_due", "next_photo_price"):
        assert isinstance(body[field], str), f"{field} came back as {type(body[field]).__name__}"
        Decimal(body[field])  # parses exactly


# ---------------------------------------------------------------------------
# The marginal price is the change in the charge, not the curve's p(n+1).
# ---------------------------------------------------------------------------


def test_another_photo_is_free_while_the_total_is_under_what_was_paid(client, db_session):
    """Under the included count the client owes nothing, so one more photo
    adds nothing. Quoting the curve's price for that photo would be quoting a
    number nobody is ever charged."""
    client_id, _pro, _gig, gallery = _setup(db_session, included=20, photos=30)

    body = _quote(client, gallery, client_id, count=12)
    assert Decimal(body["amount_due"]) == Decimal("0.00")
    assert Decimal(body["next_photo_price"]) == Decimal("0.00"), "charged for a photo that is free"


def test_past_the_paid_total_the_next_photo_has_a_real_price(client, db_session):
    client_id, _pro, gig, gallery = _setup(db_session, included=20, photos=30)

    body = _quote(client, gallery, client_id, count=28)
    assert Decimal(body["amount_due"]) > 0
    assert Decimal(body["next_photo_price"]) > 0

    # And it is exactly the difference between the two charges.
    nxt = _quote(client, gallery, client_id, count=29)
    assert Decimal(body["next_photo_price"]) == Decimal(nxt["amount_due"]) - Decimal(body["amount_due"])


def test_the_marginal_price_falls_as_more_photos_are_chosen(client, db_session):
    """The decay curve, visible to the client as the thing it is."""
    client_id, _pro, _gig, gallery = _setup(db_session, included=10, photos=30)

    prices = [Decimal(_quote(client, gallery, client_id, count=n)["next_photo_price"]) for n in (15, 20, 25)]
    assert prices[0] > prices[1] > prices[2], f"curve is not decaying: {prices}"


def test_no_next_price_when_the_gallery_has_no_more_photos(client, db_session):
    client_id, _pro, _gig, gallery = _setup(db_session, included=20, photos=30)
    body = _quote(client, gallery, client_id, count=30)
    assert body["next_photo_price"] is None, "priced a photo that does not exist"


# ---------------------------------------------------------------------------
# The gate, and the copy the screen needs.
# ---------------------------------------------------------------------------


def test_below_the_minimum_the_quote_says_how_many_more(client, db_session):
    client_id, _pro, _gig, gallery = _setup(db_session, included=20, photos=30)
    body = _quote(client, gallery, client_id, count=7)
    assert body["minimum_photos"] == MINIMUM_PHOTOS
    assert body["can_submit"] is False
    assert body["photos_still_needed"] == 3


def test_at_the_minimum_it_can_be_submitted(client, db_session):
    client_id, _pro, _gig, gallery = _setup(db_session, included=20, photos=30)
    body = _quote(client, gallery, client_id, count=10)
    assert body["can_submit"] is True
    assert body["photos_still_needed"] == 0


def test_the_quote_defaults_to_what_is_saved(client, db_session):
    client_id, _pro, _gig, gallery = _setup(db_session, included=20, photos=30)
    # _select_photos saves a draft selection of every photo.
    assert _quote(client, gallery, client_id)["selected_count"] == 30


def test_a_selection_larger_than_the_gallery_is_refused(client, db_session):
    client_id, _pro, _gig, gallery = _setup(db_session, included=20, photos=30)
    resp = client.get(
        f"/v1/proof-galleries/{gallery.id}/selection-quote?selected_count=31",
        headers={"X-User-Id": client_id},
    )
    assert resp.status_code == 422, resp.text


def test_only_the_client_can_price_their_selection(client, db_session):
    client_id, pro_id, _gig, gallery = _setup(db_session, included=20, photos=30)
    resp = client.get(
        f"/v1/proof-galleries/{gallery.id}/selection-quote", headers={"X-User-Id": pro_id}
    )
    assert resp.status_code == 403, resp.text


def test_the_total_is_the_curve_not_a_flat_rate(client, db_session):
    """Guards against the quote quietly reverting to entry_rate * count."""
    client_id, _pro, gig, gallery = _setup(db_session, included=20, photos=30)
    body = _quote(client, gallery, client_id, count=30)

    expected = compute_package_total(
        db_session, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=30
    )
    assert Decimal(body["amount_total"]) == expected
    assert Decimal(body["amount_total"]) < gig.entry_rate * 30, "flat pricing, not the curve"


# ---------------------------------------------------------------------------
# Downloading the finals, after paying.
# ---------------------------------------------------------------------------


def test_download_links_outlive_a_share_sheet(client, db_session, monkeypatch):
    """60 seconds was tap, share sheet, pick a destination, wait for the write
    - easily over a minute on a slow connection, and a 403 there lands right
    after the client has paid."""
    from app.models.gig import PaymentStatus
    from app.services.media_urls import FINALS_DOWNLOAD_URL_TTL_SECONDS

    client_id, _pro_id, gig, gallery = _setup(db_session, included=20, photos=12)

    created: list[dict] = []
    monkeypatch.setattr(
        "stripe.PaymentIntent.create",
        lambda **kwargs: (created.append(kwargs), DummyStripePI("pi_d", "sec_d"))[1],
    )
    assert client.post(
        f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id}
    ).status_code == 200

    # Settle whatever the submit raised, so the finals are unlocked.
    for payment in db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalars():
        payment.status = PaymentStatus.succeeded
    db_session.commit()

    resp = client.get(f"/v1/proof-galleries/{gallery.id}/downloads", headers={"X-User-Id": client_id})
    assert resp.status_code == 200, resp.text
    urls = resp.json()["urls"]
    assert urls, "no download links came back"

    for url in urls.values():
        assert f"X-Amz-Expires={FINALS_DOWNLOAD_URL_TTL_SECONDS}" in url
    assert FINALS_DOWNLOAD_URL_TTL_SECONDS >= 300, "too tight for a real save"
    # Still far shorter than a preview: this is the photograph itself.
    from app.services.media_urls import GALLERY_PREVIEW_URL_TTL_SECONDS

    assert FINALS_DOWNLOAD_URL_TTL_SECONDS < GALLERY_PREVIEW_URL_TTL_SECONDS


def test_download_links_cost_a_fixed_number_of_queries(client, db_session, monkeypatch):
    """The last per-item presign loop, on the path a client uses after paying."""
    from app.models.gig import PaymentStatus

    from tests.test_gallery_media_delivery import _count_queries

    client_id, _pro_id, gig, gallery = _setup(db_session, included=20, photos=25)
    monkeypatch.setattr("stripe.PaymentIntent.create", lambda **kwargs: DummyStripePI("pi_d", "sec_d"))
    client.post(f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id})
    for payment in db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalars():
        payment.status = PaymentStatus.succeeded
    db_session.commit()

    counter, stop = _count_queries(db_session)
    try:
        counter[0] = 0
        assert client.get(
            f"/v1/proof-galleries/{gallery.id}/downloads", headers={"X-User-Id": client_id}
        ).status_code == 200
        queries = counter[0]
    finally:
        stop()

    # 25 photos. A per-item loop would be 25 queries on its own, before the
    # rest of the handler's work.
    assert queries < 20, f"{queries} queries for 25 photos: still per-item"
