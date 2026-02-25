import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.core.config import get_settings
from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import BookingRequest, BookingRequestStatus, ProPackage
from app.models.gig import Gig, StripePayment
from app.models.niche import Niche

ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"


class DummyStripePI:
    def __init__(self, pi_id="pi_br_1", client_secret="sec_br_1", status="requires_payment_method"):
        self.id = pi_id
        self.client_secret = client_secret
        self.status = status


def _ensure_user_role(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()
    exists = db_session.query(UserRole).filter_by(user_id=uid, role=role).first()
    if not exists:
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()


def _seed_pro_profile(db_session, pro_id: str, kyc: KYCStatus = KYCStatus.unsubmitted):
    pid = uuid.UUID(pro_id)
    profile = db_session.get(ProProfile, pid)
    if not profile:
        profile = ProProfile(user_id=pid)
        db_session.add(profile)
    profile.kyc_status = kyc
    profile.display_name = "Pro"
    profile.headline = "Portrait"
    profile.bio = "Long bio"
    profile.city = "Lisbon"
    profile.country = "PT"
    profile.languages = ["en"]
    profile.styles = ["editorial"]
    profile.gear = {"camera": "A7"}
    profile.completeness_score = 100
    db_session.commit()


def _create_package(client, pro_id: str):
    resp = client.post(
        "/v1/pro/me/packages",
        headers={"X-User-Id": pro_id},
        json={
            "title": "Mini Session",
            "niche_slug": "portraits",
            "duration_minutes": 60,
            "price": "120.00",
            "currency": "EUR",
            "included_photos": 10,
            "extra_photo_price": "8.00",
            "proofs_sla_days": 3,
            "finals_sla_days": 7,
            "addons": [],
        },
    )
    assert resp.status_code == 200
    return resp.json()["id"]


def test_pro_cannot_activate_without_kyc_in_production(client, db_session):
    pro_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _seed_pro_profile(db_session, pro_id, KYCStatus.pending)
    _create_package(client, pro_id)

    settings = get_settings()
    orig_env = settings.app_env
    orig_allow = settings.allow_unverified_pro
    settings.app_env = "production"
    settings.allow_unverified_pro = False

    try:
        resp = client.post("/v1/pro/me/activate", headers={"X-User-Id": pro_id})
        assert resp.status_code == 409
    finally:
        settings.app_env = orig_env
        settings.allow_unverified_pro = orig_allow


def test_booking_request_rejected_outside_availability_or_blackout(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _ensure_user_role(db_session, client_id, UserRoleType.client)
    _seed_pro_profile(db_session, pro_id, KYCStatus.approved)

    # Monday 09:00-17:00
    rule_resp = client.post(
        "/v1/pro/me/availability/rules",
        headers={"X-User-Id": pro_id},
        json={"rules": [{"day_of_week": 0, "start_time": "09:00:00", "end_time": "17:00:00"}]},
    )
    assert rule_resp.status_code == 200

    pkg_id = _create_package(client, pro_id)
    client.post("/v1/pro/me/activate", headers={"X-User-Id": pro_id})

    # Sunday request (outside availability)
    sunday_start = datetime(2026, 3, 1, 10, 0, tzinfo=timezone.utc)
    sunday_end = sunday_start + timedelta(hours=1)
    outside = client.post(
        f"/v1/pros/{pro_id}/booking-requests",
        headers={"X-User-Id": client_id},
        json={
            "package_id": pkg_id,
            "requested_start": sunday_start.isoformat(),
            "requested_end": sunday_end.isoformat(),
        },
    )
    assert outside.status_code == 409

    # Monday valid slot, but blackout overlaps
    monday_start = datetime(2026, 3, 2, 10, 0, tzinfo=timezone.utc)
    monday_end = monday_start + timedelta(hours=1)
    blackout = client.post(
        "/v1/pro/me/availability/blackouts",
        headers={"X-User-Id": pro_id},
        json={"start_at": monday_start.isoformat(), "end_at": monday_end.isoformat(), "reason": "busy"},
    )
    assert blackout.status_code == 200

    blocked = client.post(
        f"/v1/pros/{pro_id}/booking-requests",
        headers={"X-User-Id": client_id},
        json={
            "package_id": pkg_id,
            "requested_start": monday_start.isoformat(),
            "requested_end": monday_end.isoformat(),
        },
    )
    assert blocked.status_code == 409


def test_accept_creates_gig_and_payment_once(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _ensure_user_role(db_session, client_id, UserRoleType.client)
    _seed_pro_profile(db_session, pro_id, KYCStatus.approved)

    client.post(
        "/v1/pro/me/availability/rules",
        headers={"X-User-Id": pro_id},
        json={"rules": [{"day_of_week": 0, "start_time": "09:00:00", "end_time": "17:00:00"}]},
    )
    pkg_id = _create_package(client, pro_id)
    client.post("/v1/pro/me/activate", headers={"X-User-Id": pro_id})

    req_start = datetime(2026, 3, 2, 11, 0, tzinfo=timezone.utc)
    req_end = req_start + timedelta(hours=1)
    br = client.post(
        f"/v1/pros/{pro_id}/booking-requests",
        headers={"X-User-Id": client_id},
        json={"package_id": pkg_id, "requested_start": req_start.isoformat(), "requested_end": req_end.isoformat()},
    )
    assert br.status_code == 200
    br_id = br.json()["id"]

    monkeypatch.setattr("app.services.payment_intents.stripe.PaymentIntent.create", lambda **kwargs: DummyStripePI("pi_accept_1", "sec_accept_1"))
    monkeypatch.setattr("app.services.payment_intents.stripe.PaymentIntent.retrieve", lambda pi_id: DummyStripePI(pi_id, "sec_accept_1"))

    first = client.post(f"/v1/booking-requests/{br_id}/accept", headers={"X-User-Id": pro_id})
    assert first.status_code == 200
    second = client.post(f"/v1/booking-requests/{br_id}/accept", headers={"X-User-Id": pro_id})
    assert second.status_code == 200

    gigs = db_session.query(Gig).all()
    assert len(gigs) == 1
    payments = db_session.query(StripePayment).all()
    assert len(payments) == 1


def test_client_cannot_accept_or_decline(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _ensure_user_role(db_session, client_id, UserRoleType.client)
    _seed_pro_profile(db_session, pro_id, KYCStatus.approved)

    client.post(
        "/v1/pro/me/availability/rules",
        headers={"X-User-Id": pro_id},
        json={"rules": [{"day_of_week": 0, "start_time": "09:00:00", "end_time": "17:00:00"}]},
    )
    pkg_id = _create_package(client, pro_id)
    client.post("/v1/pro/me/activate", headers={"X-User-Id": pro_id})

    req_start = datetime(2026, 3, 2, 12, 0, tzinfo=timezone.utc)
    req_end = req_start + timedelta(hours=1)
    br_id = client.post(
        f"/v1/pros/{pro_id}/booking-requests",
        headers={"X-User-Id": client_id},
        json={"package_id": pkg_id, "requested_start": req_start.isoformat(), "requested_end": req_end.isoformat()},
    ).json()["id"]

    accept = client.post(f"/v1/booking-requests/{br_id}/accept", headers={"X-User-Id": client_id})
    decline = client.post(f"/v1/booking-requests/{br_id}/decline", headers={"X-User-Id": client_id}, json={"reason": "x"})
    assert accept.status_code == 403
    assert decline.status_code == 403


def test_expiration_marks_pending_to_expired(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _ensure_user_role(db_session, client_id, UserRoleType.client)
    _ensure_user_role(db_session, ADMIN_ID, UserRoleType.admin)

    pkg = ProPackage(
        pro_user_id=uuid.UUID(pro_id),
        niche_id=db_session.query(Niche).filter_by(slug="portraits").first().id,
        title="Pkg",
        duration_minutes=60,
        price=Decimal("100.00"),
        currency="EUR",
        included_photos=10,
        extra_photo_price=Decimal("10.00"),
        proofs_sla_days=3,
        finals_sla_days=7,
        addons=[],
        is_active=True,
    )
    db_session.add(pkg)
    db_session.flush()

    req = BookingRequest(
        pro_user_id=uuid.UUID(pro_id),
        client_user_id=uuid.UUID(client_id),
        package_id=pkg.id,
        requested_start=datetime.now(timezone.utc),
        requested_end=datetime.now(timezone.utc) + timedelta(hours=1),
        status=BookingRequestStatus.pending,
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=5),
    )
    db_session.add(req)
    db_session.commit()

    resp = client.post("/v1/admin/jobs/expire-booking-requests", headers={"X-User-Id": ADMIN_ID})
    assert resp.status_code == 200
    db_session.refresh(req)
    assert req.status == BookingRequestStatus.expired
