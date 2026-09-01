import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import (
    BookingRequest,
    BookingRequestStatus,
    ConfirmedSlot,
    ProAvailabilityException,
    ProAvailabilityRule,
    ProPackage,
    ProSchedulingPolicy,
)
from app.models.niche import Niche
from app.models.gig import Gig
from app.models.communication import FollowupJob


def _seed_user(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid, email=f"{user_id}@example.com"))
    if not db_session.query(UserRole).filter_by(user_id=uid, role=role).first():
        db_session.add(UserRole(user_id=uid, role=role))
    db_session.commit()


def _seed_pro_and_booking(db_session, pro_id: str, client_id: str):
    _seed_user(db_session, pro_id, UserRoleType.pro)
    _seed_user(db_session, client_id, UserRoleType.client)
    pro_uuid = uuid.UUID(pro_id)
    client_uuid = uuid.UUID(client_id)

    profile = db_session.get(ProProfile, pro_uuid) or ProProfile(user_id=pro_uuid)
    profile.display_name = "Pro"
    profile.city = "Lisbon"
    profile.country = "PT"
    profile.kyc_status = KYCStatus.approved
    profile.is_accepting_bookings = True
    profile.completeness_score = 90
    db_session.add(profile)

    niche = db_session.query(Niche).filter_by(slug="portraits").first()
    pkg = ProPackage(
        pro_user_id=pro_uuid,
        niche_id=niche.id,
        title="Session",
        duration_minutes=60,
        price=Decimal("120.00"),
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
    start = datetime.now(timezone.utc) + timedelta(days=3)
    booking = BookingRequest(
        pro_user_id=pro_uuid,
        client_user_id=client_uuid,
        package_id=pkg.id,
        requested_start=start,
        requested_end=start + timedelta(hours=1),
        status=BookingRequestStatus.pending,
        expires_at=start + timedelta(days=1),
    )
    db_session.add(booking)
    db_session.flush()
    policy = db_session.get(ProSchedulingPolicy, pro_uuid)
    if not policy:
        db_session.add(
            ProSchedulingPolicy(
                pro_user_id=pro_uuid,
                slot_length_minutes=60,
                buffer_before_minutes=15,
                buffer_after_minutes=15,
                advance_notice_hours=24,
                max_bookings_per_day=None,
            )
        )
    existing_rule = (
        db_session.query(ProAvailabilityRule)
        .filter_by(pro_user_id=pro_uuid, day_of_week=start.weekday(), timezone="UTC")
        .first()
    )
    if not existing_rule:
        db_session.add(
            ProAvailabilityRule(
                pro_user_id=pro_uuid,
                day_of_week=start.weekday(),
                start_time=start.astimezone(timezone.utc).time().replace(minute=0, second=0, microsecond=0),
                end_time=(start + timedelta(hours=6)).astimezone(timezone.utc).time().replace(minute=0, second=0, microsecond=0),
                timezone="UTC",
                location_mode="both",
            )
        )
    db_session.commit()
    return booking.id, start


def test_availability_and_exceptions_respected(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _, start = _seed_pro_and_booking(db_session, pro_id, client_id)
    pro_uuid = uuid.UUID(pro_id)

    db_session.add(
        ProAvailabilityException(
            pro_user_id=pro_uuid,
            start_at_utc=start,
            end_at_utc=start + timedelta(hours=1),
            reason="busy",
        )
    )
    db_session.commit()

    resp = client.get(
        "/v1/pro/scheduling/slots",
        headers={"X-User-Id": pro_id},
        params={"from": start.date().isoformat(), "to": start.date().isoformat()},
    )
    assert resp.status_code == 200
    slots = resp.json()["slots"]
    assert all(not (item["start_at_utc"].startswith(start.replace(minute=0, second=0, microsecond=0).isoformat()[:13])) for item in slots)


def test_advance_notice_enforced(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    booking_id, _ = _seed_pro_and_booking(db_session, pro_id, client_id)

    near_start = datetime.now(timezone.utc) + timedelta(hours=2)
    window_resp = client.post(
        f"/v1/client/bookings/{booking_id}/time-windows",
        headers={"X-User-Id": client_id},
        json={"client_timezone": "UTC", "windows": [{"start_at_utc": near_start.isoformat(), "end_at_utc": (near_start + timedelta(hours=1)).isoformat()}]},
    )
    assert window_resp.status_code == 200

    confirm = client.post(
        f"/v1/pro/bookings/{booking_id}/confirm-slot",
        headers={"X-User-Id": pro_id},
        json={"start_at_utc": near_start.isoformat(), "end_at_utc": (near_start + timedelta(hours=1)).isoformat()},
    )
    assert confirm.status_code == 409


def test_confirm_slot_fails_cleanly_on_conflict(client, db_session):
    pro_id = str(uuid.uuid4())
    client_a = str(uuid.uuid4())
    booking_a, start = _seed_pro_and_booking(db_session, pro_id, client_a)
    client_b = str(uuid.uuid4())
    booking_b, _ = _seed_pro_and_booking(db_session, pro_id, client_b)

    for booking_id, client_id in [(booking_a, client_a), (booking_b, client_b)]:
        client.post(
            f"/v1/client/bookings/{booking_id}/time-windows",
            headers={"X-User-Id": client_id},
            json={"client_timezone": "UTC", "windows": [{"start_at_utc": start.isoformat(), "end_at_utc": (start + timedelta(hours=1)).isoformat()}]},
        )

    first = client.post(
        f"/v1/pro/bookings/{booking_a}/confirm-slot",
        headers={"X-User-Id": pro_id},
        json={"start_at_utc": start.isoformat(), "end_at_utc": (start + timedelta(hours=1)).isoformat()},
    )
    assert first.status_code == 200

    second = client.post(
        f"/v1/pro/bookings/{booking_b}/confirm-slot",
        headers={"X-User-Id": pro_id},
        json={"start_at_utc": start.isoformat(), "end_at_utc": (start + timedelta(hours=1)).isoformat()},
    )
    assert second.status_code == 409


def test_reminders_scheduled_on_confirm(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    booking_id, start = _seed_pro_and_booking(db_session, pro_id, client_id)

    client.post(
        f"/v1/client/bookings/{booking_id}/time-windows",
        headers={"X-User-Id": client_id},
        json={"client_timezone": "UTC", "windows": [{"start_at_utc": start.isoformat(), "end_at_utc": (start + timedelta(hours=1)).isoformat()}]},
    )
    confirm = client.post(
        f"/v1/pro/bookings/{booking_id}/confirm-slot",
        headers={"X-User-Id": pro_id},
        json={"start_at_utc": start.isoformat(), "end_at_utc": (start + timedelta(hours=1)).isoformat()},
    )
    assert confirm.status_code == 200
    jobs = db_session.query(FollowupJob).all()
    assert any(job.rule_code == "slot_reminder_24h" for job in jobs)
