"""Collection endpoints for booking requests, gigs and client bookings.

These three routes did not exist until now (see docs/BACKEND_GAPS.md): the
API only had fetch-by-id, so no client could enumerate a pro's work queue
or a client's bookings. The tests below cover the parts most likely to
break quietly - scoping, filters, and the keyset cursor.
"""

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.booking import BookingRequest, BookingRequestStatus, ProPackage
from app.models.gig import Gig, GigStatus
from app.models.niche import Niche

PRO_A = "00000000-0000-0000-0000-00000000f6a1"
PRO_B = "00000000-0000-0000-0000-00000000f6b2"
CLIENT_A = "00000000-0000-0000-0000-00000000f6c3"


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _seed_package(db_session, pro_id: uuid.UUID) -> ProPackage:
    niche = db_session.query(Niche).first()
    if not niche:
        niche = Niche(id=uuid.uuid4(), slug="portrait-f6", name="Portrait")
        db_session.add(niche)
        db_session.flush()
    package = ProPackage(
        pro_user_id=pro_id,
        niche_id=niche.id,
        title="Session",
        duration_minutes=60,
        price=Decimal("120.00"),
        included_photos=10,
        extra_photo_price=Decimal("8.00"),
    )
    db_session.add(package)
    db_session.flush()
    return package


def _seed_request(
    db_session,
    *,
    pro_id: str,
    client_id: str,
    status: BookingRequestStatus = BookingRequestStatus.pending,
    created_at: datetime | None = None,
    expires_in_hours: int = 48,
) -> BookingRequest:
    pro_uuid = uuid.UUID(pro_id)
    package = _seed_package(db_session, pro_uuid)
    row = BookingRequest(
        pro_user_id=pro_uuid,
        client_user_id=uuid.UUID(client_id),
        package_id=package.id,
        requested_start=_now() + timedelta(days=3),
        requested_end=_now() + timedelta(days=3, hours=1),
        status=status,
        expires_at=_now() + timedelta(hours=expires_in_hours),
    )
    db_session.add(row)
    db_session.flush()
    if created_at is not None:
        row.created_at = created_at
    db_session.commit()
    return row


def _seed_gig(db_session, *, pro_id: str, client_id: str, status: GigStatus, scheduled_start: datetime | None) -> Gig:
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        status=status,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("10.00"),
        amount_pro_gross=Decimal("90.00"),
        scheduled_start=scheduled_start,
        meta={},
    )
    db_session.add(gig)
    db_session.commit()
    return gig


def test_booking_requests_are_scoped_to_the_calling_pro(client, db_session):
    _seed_request(db_session, pro_id=PRO_A, client_id=CLIENT_A)
    _seed_request(db_session, pro_id=PRO_B, client_id=CLIENT_A)

    resp = client.get("/v1/booking-requests", headers={"X-User-Id": PRO_A})
    assert resp.status_code == 200
    items = resp.json()["items"]
    assert len(items) == 1
    assert items[0]["pro_user_id"] == PRO_A


def test_booking_requests_filter_by_status(client, db_session):
    _seed_request(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=BookingRequestStatus.pending)
    _seed_request(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=BookingRequestStatus.declined)

    resp = client.get("/v1/booking-requests", params={"status": "declined"}, headers={"X-User-Id": PRO_A})
    assert resp.status_code == 200
    items = resp.json()["items"]
    assert len(items) == 1
    assert items[0]["status"] == "declined"


def test_pending_request_carries_a_countdown_and_settled_ones_do_not(client, db_session):
    _seed_request(db_session, pro_id=PRO_A, client_id=CLIENT_A, expires_in_hours=48)
    _seed_request(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=BookingRequestStatus.accepted)

    resp = client.get("/v1/booking-requests", headers={"X-User-Id": PRO_A})
    by_status = {item["status"]: item for item in resp.json()["items"]}

    pending = by_status["pending"]
    # ~48h, allowing for the seconds spent between seeding and asserting.
    assert 47 * 3600 < pending["seconds_until_expiry"] <= 48 * 3600
    assert pending["expires_at"] is not None

    # A settled request has a deadline in the past or irrelevant - sending a
    # countdown would invite a UI that ticks down on a decided request.
    assert by_status["accepted"]["seconds_until_expiry"] is None


def test_expired_deadline_reports_negative_rather_than_clamping(client, db_session):
    _seed_request(db_session, pro_id=PRO_A, client_id=CLIENT_A, expires_in_hours=-2)

    resp = client.get("/v1/booking-requests", headers={"X-User-Id": PRO_A})
    seconds = resp.json()["items"][0]["seconds_until_expiry"]
    assert seconds < 0, "a passed deadline must be distinguishable from one with no time left"


def test_cursor_pagination_returns_every_row_exactly_once_despite_identical_timestamps(client, db_session):
    # The failure this guards against: a timestamp-only cursor silently drops
    # rows that share a created_at. Bulk seeds produce exactly that.
    shared = _now() - timedelta(hours=1)
    for _ in range(5):
        _seed_request(db_session, pro_id=PRO_A, client_id=CLIENT_A, created_at=shared)

    seen: list[str] = []
    cursor = None
    for _ in range(10):  # bounded so a broken cursor loops finitely, not forever
        params = {"limit": 2}
        if cursor:
            params["cursor"] = cursor
        resp = client.get("/v1/booking-requests", params=params, headers={"X-User-Id": PRO_A})
        assert resp.status_code == 200
        body = resp.json()
        seen.extend(item["id"] for item in body["items"])
        cursor = body["next_cursor"]
        if not cursor:
            break

    assert cursor is None, "pagination did not terminate"
    assert len(seen) == 5
    assert len(set(seen)) == 5, "a row was returned on more than one page"


def test_malformed_cursor_restarts_rather_than_erroring(client, db_session):
    _seed_request(db_session, pro_id=PRO_A, client_id=CLIENT_A)

    resp = client.get("/v1/booking-requests", params={"cursor": "not-a-real-cursor"}, headers={"X-User-Id": PRO_A})
    assert resp.status_code == 200
    assert len(resp.json()["items"]) == 1


def test_gigs_are_visible_to_both_sides_of_the_same_gig(client, db_session):
    _seed_gig(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=GigStatus.paid, scheduled_start=_now())

    as_pro = client.get("/v1/gigs", headers={"X-User-Id": PRO_A}).json()["items"]
    as_client = client.get("/v1/gigs", headers={"X-User-Id": CLIENT_A}).json()["items"]
    as_stranger = client.get("/v1/gigs", headers={"X-User-Id": PRO_B}).json()["items"]

    assert len(as_pro) == 1
    assert len(as_client) == 1
    assert as_pro[0]["id"] == as_client[0]["id"]
    assert as_stranger == []


def test_gigs_filter_by_status_and_scheduled_range(client, db_session):
    soon = _now() + timedelta(days=1)
    later = _now() + timedelta(days=30)
    _seed_gig(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=GigStatus.paid, scheduled_start=soon)
    _seed_gig(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=GigStatus.paid, scheduled_start=later)
    _seed_gig(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=GigStatus.completed, scheduled_start=soon)
    # Unscheduled: must be excluded whenever a date bound is supplied.
    _seed_gig(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=GigStatus.paid, scheduled_start=None)

    by_status = client.get("/v1/gigs", params={"status": "completed"}, headers={"X-User-Id": PRO_A}).json()["items"]
    assert len(by_status) == 1

    in_window = client.get(
        "/v1/gigs",
        params={
            "scheduled_from": (_now() - timedelta(hours=1)).isoformat(),
            "scheduled_to": (_now() + timedelta(days=7)).isoformat(),
        },
        headers={"X-User-Id": PRO_A},
    ).json()["items"]
    assert len(in_window) == 2, "expected only the two gigs scheduled inside the window"
    assert all(item["scheduled_start"] is not None for item in in_window)


def test_money_stays_a_decimal_string_in_list_rows(client, db_session):
    _seed_gig(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=GigStatus.paid, scheduled_start=_now())

    item = client.get("/v1/gigs", headers={"X-User-Id": PRO_A}).json()["items"][0]
    assert isinstance(item["amount_minimum"], str), "money must never serialize as a float"
    assert item["amount_minimum"] == "100.00"


def test_client_bookings_are_scoped_to_the_calling_client(client, db_session):
    _seed_request(db_session, pro_id=PRO_A, client_id=CLIENT_A)

    as_client = client.get("/v1/client/bookings", headers={"X-User-Id": CLIENT_A}).json()["items"]
    as_pro = client.get("/v1/client/bookings", headers={"X-User-Id": PRO_A}).json()["items"]

    assert len(as_client) == 1
    assert as_client[0]["booking_status"] == "pending"
    assert as_pro == [], "the pro side is served by /v1/booking-requests, not this route"


def test_client_booking_row_rolls_up_gig_status(client, db_session):
    request = _seed_request(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=BookingRequestStatus.accepted)
    gig = _seed_gig(db_session, pro_id=PRO_A, client_id=CLIENT_A, status=GigStatus.paid, scheduled_start=_now())
    gig.meta = {"booking_request_id": str(request.id)}
    db_session.commit()

    item = client.get("/v1/client/bookings", headers={"X-User-Id": CLIENT_A}).json()["items"][0]
    assert item["gig_id"] == str(gig.id)
    assert item["gig_status"] == "paid"
