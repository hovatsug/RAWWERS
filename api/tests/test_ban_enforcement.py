"""A ban stops everything at once, admins included.

Admin routes checked the role but never the ban, so a banned admin kept
every admin power. And a ban only blocked new requests: refresh tokens kept
minting new sessions until each request was refused, and the online dot and
"Available now" stayed up until presence expired. Now a ban or an active
suspension also revokes every refresh token, takes the person offline and
switches Available now off. A warning does none of that.
"""
import uuid
from datetime import datetime, timedelta, timezone

from app.models.admin import UserRole, UserRoleType
from app.models.booking import ProSchedulingPolicy
from app.services import presence

from tests.test_logout_presence import _beat, _photographer, _sign_in
from tests.test_presence import _no_presence_left_over  # noqa: F401 - autouse

ADMIN = "00000000-0000-0000-0000-0000000000aa"  # the suite's admin (conftest)


def _ban(client, user_id, action="banned", ends_at=None, actor=ADMIN):
    body = {"action": action, "reason": "Terms violation"}
    if ends_at:
        body["ends_at"] = ends_at.isoformat()
    return client.post(f"/v1/admin/users/{user_id}/ban", headers={"X-User-Id": actor}, json=body)


def _second_admin(db_session) -> str:
    from app.models.admin import UserAccount

    uid = uuid.uuid4()
    db_session.add(UserAccount(user_id=uid))
    db_session.flush()
    db_session.add(UserRole(user_id=uid, role=UserRoleType.admin))
    db_session.commit()
    return str(uid)


# --- admins -------------------------------------------------------------------------------


def test_a_banned_admin_loses_admin_routes(client, db_session):
    other = _second_admin(db_session)
    assert client.get("/v1/admin/payouts", headers={"X-User-Id": other}).status_code == 200

    assert _ban(client, other).status_code == 200

    resp = client.get("/v1/admin/payouts", headers={"X-User-Id": other})
    assert resp.status_code == 403, resp.text


def test_a_suspended_admin_is_back_when_the_suspension_ends(client, db_session):
    other = _second_admin(db_session)
    _ban(client, other, action="suspended", ends_at=datetime.now(timezone.utc) + timedelta(hours=1))
    assert client.get("/v1/admin/payouts", headers={"X-User-Id": other}).status_code == 403

    from app.models.admin import BanAction
    from sqlalchemy import select

    db_session.expire_all()
    for row in db_session.execute(select(BanAction).where(BanAction.user_id == uuid.UUID(other))).scalars():
        row.ends_at = datetime.now(timezone.utc) - timedelta(minutes=1)
    db_session.commit()

    assert client.get("/v1/admin/payouts", headers={"X-User-Id": other}).status_code == 200


# --- sessions and presence ------------------------------------------------------------------


def test_a_ban_revokes_every_session(client, db_session):
    email, pro = _photographer(client)
    phone, laptop = _sign_in(client, email), _sign_in(client, email)

    assert _ban(client, pro).status_code == 200

    for session in (phone, laptop):
        resp = client.post("/v1/auth/refresh", json={"refresh_token": session["refresh_token"]})
        assert resp.status_code == 401, resp.text


def test_a_ban_takes_the_photographer_offline_and_off_available_now(client, db_session):
    email, pro = _photographer(client)
    session = _sign_in(client, email)
    assert _beat(client, session).status_code == 200
    policy = db_session.get(ProSchedulingPolicy, pro) or ProSchedulingPolicy(pro_user_id=pro)
    policy.available_until = datetime.now(timezone.utc) + timedelta(hours=2)
    db_session.add(policy)
    db_session.commit()
    assert presence.photographer_is_online(db_session, pro)

    assert _ban(client, pro).status_code == 200

    assert not presence.photographer_is_online(db_session, pro)
    db_session.expire_all()
    assert db_session.get(ProSchedulingPolicy, pro).available_until is None
    assert _beat(client, session).status_code in (401, 403), "and the heartbeat cannot bring it back"
    assert not presence.photographer_is_online(db_session, pro)


def test_a_suspension_does_the_same(client, db_session):
    email, pro = _photographer(client)
    session = _sign_in(client, email)
    _beat(client, session)

    assert _ban(client, pro, action="suspended", ends_at=datetime.now(timezone.utc) + timedelta(days=3)).status_code == 200

    assert not presence.photographer_is_online(db_session, pro)
    assert client.post("/v1/auth/refresh", json={"refresh_token": session["refresh_token"]}).status_code == 401


def test_a_warning_changes_nothing_about_sessions_or_presence(client, db_session):
    email, pro = _photographer(client)
    session = _sign_in(client, email)
    _beat(client, session)

    assert _ban(client, pro, action="warning").status_code == 200

    assert presence.photographer_is_online(db_session, pro)
    assert client.post("/v1/auth/refresh", json={"refresh_token": session["refresh_token"]}).status_code == 200


def test_only_an_admin_can_ban(client, db_session):
    email, pro = _photographer(client)

    assert _ban(client, pro, actor=str(pro)).status_code == 403
    assert client.post("/v1/auth/refresh", json={"refresh_token": _sign_in(client, email)["refresh_token"]}).status_code == 200
