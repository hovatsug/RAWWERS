"""How a client reaches their own photographs.

Every proof-gallery route is keyed by gallery id, and the only route that
creates one is pro-only. Until this field existed there was no path at all
from "my booking" to "my photos": a client who had paid could not reach what
they had paid for.
"""
import uuid
from decimal import Decimal

from datetime import datetime, timedelta, timezone

from app.models.booking import BookingRequest, BookingRequestStatus, ProPackage
from app.models.gallery import ProofGallery, ProofGalleryStatus
from app.models.gig import Gig, GigStatus
from app.services.niche_catalog import ensure_initial_niches, get_active_niche_by_slug

from tests.test_booking_close import _ensure_account


def _package(db_session, pro_id: str) -> ProPackage:
    ensure_initial_niches(db_session)
    niche = get_active_niche_by_slug(db_session, "portraits")
    pkg = ProPackage(
        pro_user_id=uuid.UUID(pro_id),
        niche_id=niche.id,
        title="Session",
        duration_minutes=60,
        price=Decimal("120.00"),
        currency="EUR",
        included_photos=20,
        extra_photo_price=Decimal("10.00"),
        proofs_sla_days=3,
        finals_sla_days=7,
        addons=[],
        is_active=True,
    )
    db_session.add(pkg)
    db_session.flush()
    return pkg


def _booking_with_gig(db_session, client_id: str, pro_id: str, *, gig_status=GigStatus.paid):
    now = datetime.now(timezone.utc)
    pkg = _package(db_session, pro_id)
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        status=gig_status,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.flush()

    booking = BookingRequest(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        package_id=pkg.id,
        status=BookingRequestStatus.accepted,
        requested_start=now + timedelta(days=3),
        requested_end=now + timedelta(days=3, hours=2),
        expires_at=now + timedelta(days=1),
    )
    db_session.add(booking)
    db_session.flush()
    gig.meta = {**(gig.meta or {}), "booking_request_id": str(booking.id)}
    db_session.commit()
    db_session.refresh(gig)
    db_session.refresh(booking)
    return booking, gig


def _add_gallery(db_session, gig, status: ProofGalleryStatus):
    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=gig.pro_user_id,
        client_user_id=gig.client_user_id,
        included_photos=20,
        extra_photo_price=Decimal("10.00"),
        currency="EUR",
        status=status,
    )
    db_session.add(gallery)
    db_session.commit()
    db_session.refresh(gallery)
    return gallery


def _status(client, booking_id, client_id):
    resp = client.get(f"/v1/client/bookings/{booking_id}", headers={"X-User-Id": client_id})
    assert resp.status_code == 200, resp.text
    return resp.json()


def test_a_published_gallery_gives_the_client_a_way_in(client, db_session):
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    booking, gig = _booking_with_gig(db_session, client_id, pro_id)
    gallery = _add_gallery(db_session, gig, ProofGalleryStatus.published)

    body = _status(client, booking.id, client_id)
    assert body["proof_gallery_id"] == str(gallery.id)
    assert body["proof_gallery_status"] == "published"


def test_the_status_says_which_screen_to_open(client, db_session):
    """Selection or downloads, without fetching the gallery to find out."""
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    booking, gig = _booking_with_gig(db_session, client_id, pro_id)
    gallery = _add_gallery(db_session, gig, ProofGalleryStatus.selection_submitted)

    body = _status(client, booking.id, client_id)
    assert body["proof_gallery_status"] == "selection_submitted"
    assert body["proof_gallery_id"] == str(gallery.id)


def test_a_draft_gallery_is_not_offered(client, db_session):
    """The photographer is still filling it, and get_gallery refuses a draft
    to the client anyway - surfacing it would put a door on the screen that
    opens onto a 403."""
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    booking, gig = _booking_with_gig(db_session, client_id, pro_id)
    _add_gallery(db_session, gig, ProofGalleryStatus.draft)

    body = _status(client, booking.id, client_id)
    assert body["proof_gallery_id"] is None
    assert body["proof_gallery_status"] is None
    assert "await_delivery" in body["next_actions"]


def test_no_gallery_yet_reads_as_waiting(client, db_session):
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    booking, _gig = _booking_with_gig(db_session, client_id, pro_id)

    body = _status(client, booking.id, client_id)
    assert body["proof_gallery_id"] is None
    assert body["next_actions"] == ["await_delivery"]


# ---------------------------------------------------------------------------
# next_actions used to say "await_delivery" whether or not the photos had
# arrived, and never pointed anywhere.
# ---------------------------------------------------------------------------


def test_next_actions_names_the_action_once_there_is_one(client, db_session):
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    booking, gig = _booking_with_gig(db_session, client_id, pro_id)
    _add_gallery(db_session, gig, ProofGalleryStatus.published)

    body = _status(client, booking.id, client_id)
    assert "choose_photos" in body["next_actions"]
    assert "await_delivery" not in body["next_actions"], "still waiting on photos that have arrived"


def test_a_submitted_selection_points_at_the_photos_not_at_choosing(client, db_session):
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    booking, gig = _booking_with_gig(db_session, client_id, pro_id)
    _add_gallery(db_session, gig, ProofGalleryStatus.selection_submitted)

    body = _status(client, booking.id, client_id)
    assert "view_photos" in body["next_actions"]
    assert "choose_photos" not in body["next_actions"]
