"""Who may create a gig, and when a gallery may be created, filled and sent.

Four holes, all reproduced before anything was changed:

  - `POST /v1/gigs` let any authenticated user create a gig for any photographer
    - including one that does not exist - at any price. Even a validated, correctly
    priced gig would have been wrong: it commits a photographer to a booking they
    never accepted. The three legitimate creators (accept, confirm-slot, the
    legacy shoot) all carry the photographer's consent and derive price from the
    package; nothing needed this one, and it had no caller.
  - A gallery could be created for a cancelled gig, with whatever included-photo
    count and extras price the caller typed.
  - Publishing set `status = published` unconditionally, so re-publishing a
    completed booking's gallery flipped it back open and the client could save a
    new selection on a booking that was already paid - the reselection hole the
    payment gate closed, reopened through a different door.
  - A second publish reset `published_at`, which the dispute SLA snapshot reads.
"""
import uuid
from decimal import Decimal

import pytest
from app.models.gallery import ProofGallery, ProofGalleryStatus
from app.models.gig import Gig, GigStatus
from sqlalchemy import select

from tests.test_booking_close import _ensure_account, _select_photos
from tests.test_selection_pricing_regimes import _curve_gig


def _h(user_id) -> dict:
    return {"X-User-Id": str(user_id)}


def _bare_gig(db_session, *, status: GigStatus = GigStatus.paid, meta: dict | None = None):
    """A booking with no gallery yet, and who is who."""
    client_id, pro_id = uuid.uuid4(), uuid.uuid4()
    _ensure_account(db_session, str(client_id))
    _ensure_account(db_session, str(pro_id))
    gig = Gig(
        client_user_id=client_id,
        pro_user_id=pro_id,
        status=status,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta=meta or {},
    )
    db_session.add(gig)
    db_session.commit()
    db_session.refresh(gig)
    return gig


def _create_gallery(client, gig, *, included=10, extra="5.00"):
    return client.post(
        f"/v1/gigs/{gig.id}/proof-gallery",
        headers=_h(gig.pro_user_id),
        json={"included_photos": included, "extra_photo_price": extra},
    )


# ---------------------------------------------------------------------------
# 1. Nobody creates a gig on their own.
# ---------------------------------------------------------------------------


def test_a_client_cannot_create_a_gig_for_a_photographer_who_does_not_exist(client, db_session):
    stranger, ghost = uuid.uuid4(), uuid.uuid4()
    _ensure_account(db_session, str(stranger))

    resp = client.post(
        "/v1/gigs",
        headers=_h(stranger),
        json={"pro_user_id": str(ghost), "amount_total": "0.01", "currency": "EUR"},
    )

    assert resp.status_code in (404, 405), f"a gig was created for a photographer who does not exist: {resp.status_code}"
    made = db_session.execute(select(Gig).where(Gig.pro_user_id == ghost)).scalars().all()
    assert made == [], "a gig row exists for a photographer who never accepted anything"


def test_a_client_cannot_create_a_gig_at_a_price_they_choose_for_a_real_photographer(client, db_session):
    """Removing the endpoint is the fix, not validating it: a correctly priced
    gig created this way would still commit the photographer without their consent."""
    real_pro, buyer = uuid.uuid4(), uuid.uuid4()
    _ensure_account(db_session, str(real_pro))
    _ensure_account(db_session, str(buyer))

    resp = client.post(
        "/v1/gigs",
        headers=_h(buyer),
        json={"pro_user_id": str(real_pro), "amount_total": "0.01", "currency": "EUR"},
    )

    assert resp.status_code in (404, 405)
    assert db_session.execute(select(Gig).where(Gig.client_user_id == buyer)).scalars().all() == []


# ---------------------------------------------------------------------------
# 2. A gallery is created only for work that can be delivered.
# ---------------------------------------------------------------------------


@pytest.mark.parametrize("status", [GigStatus.paid, GigStatus.scheduled, GigStatus.shoot_done])
def test_a_gallery_can_be_created_for_a_paid_booking(client, db_session, status):
    gig = _bare_gig(db_session, status=status)

    resp = _create_gallery(client, gig)

    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "draft"


@pytest.mark.parametrize(
    "status",
    [
        GigStatus.draft,
        GigStatus.requested,
        GigStatus.accepted,
        GigStatus.payment_pending,
        GigStatus.cancelled_by_client,
        GigStatus.cancelled_by_pro,
        GigStatus.refunded,
        GigStatus.disputed,
        GigStatus.completed,
    ],
)
def test_a_gallery_cannot_be_created_for_a_booking_that_cannot_be_delivered(client, db_session, status):
    gig = _bare_gig(db_session, status=status)

    resp = _create_gallery(client, gig)

    assert resp.status_code == 409, f"a gallery was created for a {status.value} booking"
    assert db_session.execute(select(ProofGallery).where(ProofGallery.gig_id == gig.id)).scalars().all() == []


def test_an_existing_gallery_stays_viewable_on_a_finished_booking(client, db_session):
    """The pro app's delivery screen calls this to *look at* a gallery, so the
    guard is on creating one, not on reading the one that exists."""
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _curve_gig(db_session, client_id, pro_id, included_photos=20)
    gig.status = GigStatus.completed
    db_session.commit()

    resp = client.post(
        f"/v1/gigs/{gig.id}/proof-gallery", headers=_h(pro_id), json={"included_photos": 20, "extra_photo_price": "5.00"}
    )

    assert resp.status_code == 200, resp.text
    assert resp.json()["id"] == str(gallery.id)


def test_only_the_photographer_on_the_booking_can_create_its_gallery(client, db_session):
    gig = _bare_gig(db_session)

    resp = client.post(
        f"/v1/gigs/{gig.id}/proof-gallery",
        headers=_h(gig.client_user_id),
        json={"included_photos": 10, "extra_photo_price": "5.00"},
    )

    assert resp.status_code == 403


# ---------------------------------------------------------------------------
# 3. What was agreed is what the gallery says, not what the caller types.
# ---------------------------------------------------------------------------


def test_the_gallerys_terms_come_from_the_agreed_package_not_the_request(client, db_session):
    gig = _bare_gig(
        db_session,
        meta={"pricing_snapshot": {"included_photos": 15, "extra_photo_price": "7.50"}},
    )

    resp = _create_gallery(client, gig, included=999, extra="0.00")

    assert resp.status_code == 200, resp.text
    assert resp.json()["included_photos"] == 15, "the photographer set their own included-photo count"
    assert Decimal(resp.json()["extra_photo_price"]) == Decimal("7.50"), "the photographer set their own extras price"


def test_without_a_snapshot_the_request_is_all_there_is(client, db_session):
    """Gigs built by confirm-slot carry no pricing snapshot (recorded separately).
    Until that is fixed the request has to stand in for it."""
    gig = _bare_gig(db_session)

    resp = _create_gallery(client, gig, included=12, extra="4.00")

    assert resp.json()["included_photos"] == 12
    assert Decimal(resp.json()["extra_photo_price"]) == Decimal("4.00")


def test_a_malformed_snapshot_falls_back_rather_than_failing(client, db_session):
    gig = _bare_gig(db_session, meta={"pricing_snapshot": {"included_photos": "lots", "extra_photo_price": None}})

    resp = _create_gallery(client, gig, included=12, extra="4.00")

    assert resp.status_code == 200, resp.text
    assert resp.json()["included_photos"] == 12


# ---------------------------------------------------------------------------
# 4. Adding photos and sending them, only when that makes sense.
# ---------------------------------------------------------------------------


def _draft_gallery(client, db_session, status: GigStatus = GigStatus.paid):
    gig = _bare_gig(db_session, status=status)
    gallery_id = _create_gallery(client, gig).json()["id"]
    return gig, gallery_id


def test_photos_cannot_be_added_to_a_gallery_whose_booking_has_been_cancelled(client, db_session):
    gig, gallery_id = _draft_gallery(client, db_session)
    gig.status = GigStatus.cancelled_by_client
    db_session.commit()

    resp = client.post(
        f"/v1/proof-galleries/{gallery_id}/items",
        headers=_h(gig.pro_user_id),
        json={"media_asset_ids": [str(uuid.uuid4())]},
    )

    assert resp.status_code == 409, resp.text


def test_photos_cannot_be_added_once_the_selection_is_made(client, db_session):
    gig, gallery_id = _draft_gallery(client, db_session)
    gallery = db_session.get(ProofGallery, uuid.UUID(gallery_id))
    gallery.status = ProofGalleryStatus.selection_submitted
    db_session.commit()

    resp = client.post(
        f"/v1/proof-galleries/{gallery_id}/items",
        headers=_h(gig.pro_user_id),
        json={"media_asset_ids": [str(uuid.uuid4())]},
    )

    assert resp.status_code == 409, resp.text


def _publishable(client, db_session):
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    gig, gallery = _curve_gig(db_session, client_id, pro_id, included_photos=20)
    gallery.status = ProofGalleryStatus.draft
    _select_photos(db_session, gallery, pro_id, client_id, count=12)
    db_session.commit()
    return gig, gallery, client_id, pro_id


def test_publishing_sends_a_draft(client, db_session):
    _gig, gallery, _client_id, pro_id = _publishable(client, db_session)

    resp = client.post(f"/v1/proof-galleries/{gallery.id}/publish", headers=_h(pro_id))

    assert resp.status_code == 200, resp.text
    db_session.refresh(gallery)
    assert gallery.status == ProofGalleryStatus.published and gallery.published_at is not None


def test_publishing_twice_changes_nothing_the_second_time(client, db_session):
    """Tapping send twice used to reset `published_at` - which the dispute SLA
    snapshot reads - and re-schedule every reminder to the client."""
    _gig, gallery, _client_id, pro_id = _publishable(client, db_session)
    client.post(f"/v1/proof-galleries/{gallery.id}/publish", headers=_h(pro_id))
    db_session.refresh(gallery)
    first = gallery.published_at

    again = client.post(f"/v1/proof-galleries/{gallery.id}/publish", headers=_h(pro_id))

    assert again.status_code == 200, again.text
    db_session.refresh(gallery)
    assert gallery.published_at == first, "a second publish moved the timestamp the SLA is measured from"


def test_republishing_a_completed_gallery_does_not_reopen_the_selection(client, db_session):
    """The reselection-after-payment hole, reached through the photographer
    instead of the client: publish set the status back to `published`."""
    _gig, gallery, client_id, pro_id = _publishable(client, db_session)
    gallery.status = ProofGalleryStatus.selection_submitted
    db_session.commit()

    resp = client.post(f"/v1/proof-galleries/{gallery.id}/publish", headers=_h(pro_id))

    assert resp.status_code == 409, f"a completed booking's gallery was re-published: {resp.status_code}"
    db_session.refresh(gallery)
    assert gallery.status == ProofGalleryStatus.selection_submitted, "the selection was reopened"
    saved = client.post(
        f"/v1/proof-galleries/{gallery.id}/selections", headers=_h(client_id), json={"media_asset_ids": []}
    )
    assert saved.status_code == 409, "the client can save a new selection on a booking that was already paid"


def test_a_cancelled_booking_cannot_send_a_gallery(client, db_session):
    gig, gallery, _client_id, pro_id = _publishable(client, db_session)
    gig.status = GigStatus.cancelled_by_client
    db_session.commit()

    resp = client.post(f"/v1/proof-galleries/{gallery.id}/publish", headers=_h(pro_id))

    assert resp.status_code == 409, resp.text
    db_session.refresh(gallery)
    assert gallery.status == ProofGalleryStatus.draft


def test_an_empty_gallery_still_cannot_be_sent(client, db_session):
    gig = _bare_gig(db_session)
    gallery_id = _create_gallery(client, gig).json()["id"]

    resp = client.post(f"/v1/proof-galleries/{gallery_id}/publish", headers=_h(gig.pro_user_id))

    assert resp.status_code == 422, resp.text
