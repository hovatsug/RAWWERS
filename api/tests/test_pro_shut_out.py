"""A banned or suspended photographer is out of discovery and cannot take
bookings; lifting the ban, or the suspension running out, puts them back.

A ban used to stop only the photographer's own requests: they stayed listed
on Discover, clients could still send them requests, and whether they could
accept depended on BAN_ENFORCEMENT_MODE. Now one rule - pro_standing - says
whether a photographer may take bookings, and the discovery index, both
booking-request routes and both answer paths ask it, whatever that mode and
whatever the dev override says. Bookings already paid are not touched: they
are listed for an admin to handle.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.core.errors import APIError
from app.models.admin import BanAction, MoneyAttentionItem, UserRole, UserRoleType
from app.models.booking import BookingRequest, BookingRequestStatus, ProPackage
from app.models.discovery import ProPublicIndex
from app.models.gig import Gig, GigStatus
from app.models.niche import Niche
from app.services.booking_answer import ensure_request_can_be_booked
from app.services.discovery_index import recompute_pro_public_index
from app.services.pro_standing import relist_after_suspensions
from tests.test_discovery import _seed_pro

ADMIN = "00000000-0000-0000-0000-0000000000aa"  # the suite's admin (conftest)


@pytest.fixture(autouse=True)
def _clear_discover_cache():
    from app.services.cache import get_redis_client

    def flush():
        try:
            client = get_redis_client()
            for pattern in ("client:home:*", "client:discover:*", "discover:pros:*"):
                for key in list(client.scan_iter(match=pattern)):
                    client.delete(key)
        except Exception:
            pass

    flush()
    yield
    flush()


def _listed_pro(db_session) -> uuid.UUID:
    pro = uuid.UUID(_seed_pro(db_session, approved=True, accepting=True, completeness=90))
    niche = db_session.execute(select(Niche).where(Niche.slug == "portraits")).scalar_one()
    db_session.add(ProPackage(
        pro_user_id=pro, niche_id=niche.id, title="Pkg", duration_minutes=60, price=Decimal("100.00"), currency="EUR",
        included_photos=10, extra_photo_price=Decimal("10.00"), proofs_sla_days=3, finals_sla_days=7, addons=[], is_active=True,
    ))
    db_session.commit()
    recompute_pro_public_index(db_session, pro)
    db_session.commit()
    return pro


def _ban(client, user_id, action="banned", ends_at=None):
    body = {"action": action, "reason": "Terms violation"}
    if ends_at:
        body["ends_at"] = ends_at.isoformat()
    resp = client.post(f"/v1/admin/users/{user_id}/ban", headers={"X-User-Id": ADMIN}, json=body)
    assert resp.status_code == 200, resp.text
    return resp


def _discoverable(client, pro) -> bool:
    resp = client.get("/v1/discover/pros?city=Lisbon&limit=50")
    assert resp.status_code == 200, resp.text
    return str(pro) in {item["pro_user_id"] for item in resp.json()["items"]}


def _index_flag(db_session, pro) -> bool:
    db_session.expire_all()
    return db_session.get(ProPublicIndex, pro).is_accepting_bookings


# --- discovery ----------------------------------------------------------------------------


def test_a_banned_photographer_leaves_discovery(client, db_session):
    pro = _listed_pro(db_session)
    assert _discoverable(client, pro)

    _ban(client, pro)

    assert _index_flag(db_session, pro) is False
    assert not _discoverable(client, pro)


def test_a_suspended_photographer_leaves_discovery_and_lifting_restores_them(client, db_session):
    pro = _listed_pro(db_session)
    _ban(client, pro, action="suspended", ends_at=datetime.now(timezone.utc) + timedelta(days=3))
    assert not _discoverable(client, pro)

    # A second ban action used to break every later request (two rows for
    # a lookup that expected one), so a lift could never work.
    _ban(client, pro, action="none")

    assert _index_flag(db_session, pro) is True
    assert _discoverable(client, pro)


def test_a_suspension_that_runs_out_puts_them_back(client, db_session):
    pro = _listed_pro(db_session)
    _ban(client, pro, action="suspended", ends_at=datetime.now(timezone.utc) + timedelta(hours=1))
    assert _index_flag(db_session, pro) is False

    for row in db_session.execute(select(BanAction).where(BanAction.user_id == pro)).scalars():
        row.ends_at = datetime.now(timezone.utc) - timedelta(minutes=1)
    db_session.commit()
    assert relist_after_suspensions(db_session) == 1
    db_session.commit()

    assert _index_flag(db_session, pro) is True


def test_a_warning_leaves_them_listed(client, db_session):
    pro = _listed_pro(db_session)
    _ban(client, pro, action="warning")
    assert _index_flag(db_session, pro) is True


def test_the_suspension_sweep_runs_on_beat():
    from app.tasks.celery_app import celery_app

    tasks = {entry["task"] for entry in celery_app.conf.beat_schedule.values()}
    assert "app.tasks.scheduled.relist_after_suspensions" in tasks


# --- taking bookings ----------------------------------------------------------------------


def _client_user(db_session) -> uuid.UUID:
    from app.models.admin import UserAccount

    uid = uuid.uuid4()
    db_session.add(UserAccount(user_id=uid))
    db_session.flush()
    db_session.add(UserRole(user_id=uid, role=UserRoleType.client))
    db_session.commit()
    return uid


def test_clients_cannot_send_a_request_to_a_banned_photographer_even_with_the_dev_override(client, db_session, monkeypatch):
    pro = _listed_pro(db_session)
    _ban(client, pro)
    monkeypatch.setattr("app.api.v1.pro_onboarding.settings.allow_unverified_pro", True)
    monkeypatch.setattr("app.api.v1.pro_onboarding.settings.app_env", "development")
    package = db_session.execute(select(ProPackage).where(ProPackage.pro_user_id == pro)).scalar_one()
    start = datetime.now(timezone.utc) + timedelta(days=10)

    resp = client.post(
        f"/v1/pros/{pro}/booking-requests",
        headers={"X-User-Id": str(_client_user(db_session))},
        json={"package_id": str(package.id), "requested_start": start.isoformat(), "requested_end": (start + timedelta(hours=1)).isoformat()},
    )

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "pro_unavailable"


def _pending_request(db_session, pro) -> BookingRequest:
    package = db_session.execute(select(ProPackage).where(ProPackage.pro_user_id == pro)).scalar_one()
    start = datetime.now(timezone.utc) + timedelta(days=10)
    request = BookingRequest(
        pro_user_id=pro, client_user_id=_client_user(db_session), package_id=package.id, requested_start=start,
        requested_end=start + timedelta(hours=1), status=BookingRequestStatus.pending,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=12),
    )
    db_session.add(request)
    db_session.commit()
    return request


def test_a_banned_photographer_cannot_accept_whatever_the_enforcement_mode(client, db_session, monkeypatch):
    pro = _listed_pro(db_session)
    request = _pending_request(db_session, pro)
    ensure_request_can_be_booked(db_session, request)  # fine before the ban

    _ban(client, pro)
    monkeypatch.setattr("app.services.authz.settings.ban_enforcement_mode", "log")

    with pytest.raises(APIError) as refused:
        ensure_request_can_be_booked(db_session, request)
    assert refused.value.code == "pro_shut_out"


def test_lifting_the_ban_lets_them_accept_again(client, db_session):
    pro = _listed_pro(db_session)
    request = _pending_request(db_session, pro)
    _ban(client, pro)
    _ban(client, pro, action="none")

    ensure_request_can_be_booked(db_session, request)


# --- bookings already paid ----------------------------------------------------------------


def _gig(db_session, pro, status) -> Gig:
    gig = Gig(
        client_user_id=_client_user(db_session), pro_user_id=pro, status=status, currency="EUR",
        amount_minimum=Decimal("100.00"), amount_platform_fee=Decimal("20.00"), amount_pro_gross=Decimal("80.00"), meta={},
    )
    db_session.add(gig)
    db_session.commit()
    return gig


def _items(db_session, pro):
    db_session.expire_all()
    return db_session.execute(
        select(MoneyAttentionItem).where(MoneyAttentionItem.kind == "pro_shut_out_booking").order_by(MoneyAttentionItem.created_at)
    ).scalars().all()


def test_a_ban_lists_the_photographers_open_paid_bookings_for_an_admin(client, db_session):
    pro = _listed_pro(db_session)
    paid = _gig(db_session, pro, GigStatus.paid)
    disputed = _gig(db_session, pro, GigStatus.disputed)
    _gig(db_session, pro, GigStatus.completed)
    _gig(db_session, pro, GigStatus.payment_pending)

    _ban(client, pro, action="suspended", ends_at=datetime.now(timezone.utc) + timedelta(days=3))

    items = _items(db_session, pro)
    assert {i.gig_id for i in items} == {paid.id, disputed.id}
    assert all(i.status == "open" and i.amount == Decimal("100.00") for i in items)
    # Untouched: listed, not cancelled.
    db_session.expire_all()
    assert db_session.get(Gig, paid.id).status == GigStatus.paid


def test_banning_again_does_not_list_a_booking_twice(client, db_session):
    pro = _listed_pro(db_session)
    _gig(db_session, pro, GigStatus.paid)
    _ban(client, pro, action="suspended", ends_at=datetime.now(timezone.utc) + timedelta(days=3))
    _ban(client, pro)

    assert len(_items(db_session, pro)) == 1


def test_a_warning_lists_nothing(client, db_session):
    pro = _listed_pro(db_session)
    _gig(db_session, pro, GigStatus.paid)
    _ban(client, pro, action="warning")

    assert _items(db_session, pro) == []


def test_the_chat_booking_path_refuses_a_banned_photographer_too(client, db_session):
    from app.api.v1.chats import _create_booking_request_from_body
    from app.schemas.onboarding import BookingRequestCreateRequest

    pro = _listed_pro(db_session)
    _ban(client, pro)
    package = db_session.execute(select(ProPackage).where(ProPackage.pro_user_id == pro)).scalar_one()
    start = datetime.now(timezone.utc) + timedelta(days=10)

    with pytest.raises(APIError) as refused:
        _create_booking_request_from_body(
            db_session, pro, _client_user(db_session),
            BookingRequestCreateRequest(package_id=package.id, requested_start=start, requested_end=start + timedelta(hours=1)),
        )
    assert refused.value.code == "pro_unavailable"
