"""The access routes no test called: roles, impersonation, the dispute status
routes, private video playback, becoming a photographer.

For each, who may call it and the rule it keeps. Three of them did not keep
theirs:
- ending an impersonation left its token working until it expired;
- the playback token signed whatever playback id the caller sent, so access
  to one video gave a token for any other whose id was known; and a banned
  account could still get one;
- the dispute status routes set "resolved with a refund" with no refund -
  a money outcome that only the resolve route, which makes the refund, may
  record.
"""
import uuid

import pytest
from app.models.admin import AdminAuditLog, Dispute, DisputeStatus, UserRole, UserRoleType
from app.models.auth import ImpersonationSession
from app.models.gig import GigStatus
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from sqlalchemy import select

from tests.test_logout_presence import _photographer, _sign_in
from tests.test_refund_caps import _dispute
from tests.test_refund_routes import _account, _paid_booking

ADMIN = "00000000-0000-0000-0000-0000000000aa"  # the suite's admin (conftest)


def _as(user_id):
    return {"X-User-Id": str(user_id)}


def _audits(db_session, target_id, action):
    db_session.expire_all()
    return db_session.execute(
        select(AdminAuditLog).where(AdminAuditLog.target_id == str(target_id), AdminAuditLog.action == action)
    ).scalars().all()


def _roles(db_session, user_id):
    db_session.expire_all()
    return {r.role for r in db_session.execute(select(UserRole).where(UserRole.user_id == uuid.UUID(str(user_id)))).scalars()}


def _ban(client, user_id):
    return client.post(f"/v1/admin/users/{user_id}/ban", headers=_as(ADMIN), json={"action": "banned", "reason": "Terms"})


# --- roles ----------------------------------------------------------------------------------


def test_roles_only_an_admin_changes_them(client, db_session):
    someone, target = _account(db_session), _account(db_session)

    resp = client.post(f"/v1/admin/users/{target}/roles", headers=_as(someone), json={"add": ["admin"], "remove": [], "reason": "x"})

    assert resp.status_code == 403
    assert UserRoleType.admin not in _roles(db_session, target)


def test_roles_an_admin_grants_and_removes_and_it_is_audited(client, db_session):
    target = _account(db_session)

    add = client.post(f"/v1/admin/users/{target}/roles", headers=_as(ADMIN), json={"add": ["pro"], "remove": [], "reason": "Onboarding"})
    assert add.status_code == 200, add.text
    assert UserRoleType.pro in _roles(db_session, target)

    remove = client.post(f"/v1/admin/users/{target}/roles", headers=_as(ADMIN), json={"add": [], "remove": ["pro"], "reason": "Left"})
    assert remove.status_code == 200
    assert UserRoleType.pro not in _roles(db_session, target)
    assert len(_audits(db_session, target, "update_roles")) == 2


def test_roles_the_last_admin_cannot_be_removed(client, db_session):
    """The suite's admin is one by configuration, not by a role row; this
    account is the only admin row there is."""
    only = _account(db_session)
    db_session.add(UserRole(user_id=uuid.UUID(only), role=UserRoleType.admin))
    db_session.commit()
    assert [str(r.user_id) for r in db_session.execute(select(UserRole).where(UserRole.role == UserRoleType.admin)).scalars()] == [only]

    resp = client.post(f"/v1/admin/users/{only}/roles", headers=_as(only), json={"add": [], "remove": ["admin"], "reason": "x"})

    assert resp.status_code == 409
    assert UserRoleType.admin in _roles(db_session, only)


def test_roles_a_banned_admin_cannot_change_them(client, db_session):
    other = _account(db_session)
    db_session.add(UserRole(user_id=uuid.UUID(other), role=UserRoleType.admin))
    db_session.commit()
    _ban(client, other)
    target = _account(db_session)

    resp = client.post(f"/v1/admin/users/{target}/roles", headers=_as(other), json={"add": ["admin"], "remove": [], "reason": "x"})

    assert resp.status_code == 403
    assert UserRoleType.admin not in _roles(db_session, target)


# --- impersonation ----------------------------------------------------------------------------


def _impersonate(client, target):
    return client.post("/v1/admin/impersonate/start", headers=_as(ADMIN), json={"target_user_id": str(target), "reason": "Support ticket"})


def _bearer(token):
    return {"Authorization": f"Bearer {token}"}


def test_impersonation_only_an_admin_starts_it(client, db_session):
    someone, target = _account(db_session), _account(db_session)

    resp = client.post("/v1/admin/impersonate/start", headers=_as(someone), json={"target_user_id": target, "reason": "x"})

    assert resp.status_code == 403


def test_impersonation_acts_as_the_target_and_is_audited(client, db_session):
    target = _account(db_session)

    started = _impersonate(client, target)

    assert started.status_code == 200, started.text
    me = client.get("/v1/me", headers=_bearer(started.json()["access_token"])).json()
    assert me["user_id"] == target
    assert len(_audits(db_session, started.json()["impersonation_session_id"], "impersonation_started")) == 1


def test_impersonation_ended_its_token_stops_working(client, db_session):
    target = _account(db_session)
    started = _impersonate(client, target).json()
    token = started["access_token"]

    assert client.post("/v1/admin/impersonate/end", headers=_bearer(token)).status_code == 204

    db_session.expire_all()
    assert db_session.get(ImpersonationSession, uuid.UUID(started["impersonation_session_id"])).ended_at is not None
    assert len(_audits(db_session, started["impersonation_session_id"], "impersonation_ended")) == 1
    assert client.get("/v1/me", headers=_bearer(token)).status_code == 401, "an ended impersonation must not go on acting"


def test_impersonation_ending_needs_an_impersonation_token(client, db_session):
    someone = _account(db_session)

    assert client.post("/v1/admin/impersonate/end", headers=_as(someone)).status_code == 400


def test_impersonation_can_be_ended_even_when_the_target_is_banned(client, db_session):
    """The ban check is skipped here on purpose: the admin must be able to leave."""
    target = _account(db_session)
    token = _impersonate(client, target).json()["access_token"]
    _ban(client, target)

    assert client.post("/v1/admin/impersonate/end", headers=_bearer(token)).status_code == 204


# --- dispute status routes ------------------------------------------------------------------


@pytest.mark.parametrize("route", ["status", "set-status"])
def test_dispute_status_only_an_admin(client, db_session, route):
    gig, client_id, _pro = _paid_booking(db_session, status=GigStatus.disputed)
    dispute = _dispute(db_session, gig, client_id)

    resp = client.post(f"/v1/admin/disputes/{dispute.id}/{route}", headers=_as(client_id), json={"status": "in_review"})

    assert resp.status_code == 403
    db_session.expire_all()
    assert db_session.get(Dispute, dispute.id).status == DisputeStatus.awaiting_admin


@pytest.mark.parametrize("route, action", [("status", "dispute_status_update"), ("set-status", "dispute_set_status")])
def test_dispute_status_an_admin_moves_it_and_it_is_audited(client, db_session, route, action):
    gig, client_id, _pro = _paid_booking(db_session, status=GigStatus.disputed)
    dispute = _dispute(db_session, gig, client_id)

    resp = client.post(f"/v1/admin/disputes/{dispute.id}/{route}", headers=_as(ADMIN), json={"status": "in_review"})

    assert resp.status_code == 200, resp.text
    db_session.expire_all()
    assert db_session.get(Dispute, dispute.id).status == DisputeStatus.in_review
    assert len(_audits(db_session, dispute.id, action)) == 1


@pytest.mark.parametrize("route", ["status", "set-status"])
@pytest.mark.parametrize("money_outcome", ["resolved_refund", "resolved_partial_refund"])
def test_dispute_status_a_refund_outcome_only_through_resolve(client, db_session, route, money_outcome):
    gig, client_id, _pro = _paid_booking(db_session, status=GigStatus.disputed)
    dispute = _dispute(db_session, gig, client_id)

    resp = client.post(f"/v1/admin/disputes/{dispute.id}/{route}", headers=_as(ADMIN), json={"status": money_outcome})

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "money_state_has_its_own_route"
    db_session.expire_all()
    assert db_session.get(Dispute, dispute.id).status == DisputeStatus.awaiting_admin


# --- private video playback -------------------------------------------------------------------


@pytest.fixture
def signed(monkeypatch):
    monkeypatch.setattr("app.api.v1.media.create_mux_playback_token", lambda playback_id, **kw: f"signed:{playback_id}")


def _video(db_session, owner, playback_id, visibility=MediaVisibility.owner_only) -> MediaAsset:
    asset = MediaAsset(
        owner_user_id=uuid.UUID(str(owner)),
        kind=MediaKind.video,
        purpose=MediaPurpose.portfolio_reel,
        provider=MediaProvider.mux,
        status=MediaStatus.ready,
        visibility=visibility,
        meta={"playback_id": playback_id},
    )
    db_session.add(asset)
    db_session.commit()
    return asset


def _token(client, asset, user_id, playback_id=None):
    body = {"playback_id": playback_id} if playback_id else {}
    return client.post(f"/v1/media/videos/{asset.id}/playback-token", headers=_as(user_id), json=body)


def test_playback_the_owner_gets_a_token_for_their_video(client, db_session, signed):
    owner = _account(db_session)
    asset = _video(db_session, owner, "pb_own")

    resp = _token(client, asset, owner)

    assert resp.status_code == 200, resp.text
    assert resp.json()["token"] == "signed:pb_own"


def test_playback_someone_else_cannot(client, db_session, signed):
    owner, other = _account(db_session), _account(db_session)
    asset = _video(db_session, owner, "pb_private")

    assert _token(client, asset, other).status_code == 403


def test_playback_access_to_one_video_is_not_a_token_for_another(client, db_session, signed):
    owner, other = _account(db_session), _account(db_session)
    _video(db_session, owner, "pb_private_of_owner")
    public = _video(db_session, other, "pb_public", visibility=MediaVisibility.public)

    resp = _token(client, public, other, playback_id="pb_private_of_owner")

    assert resp.status_code in (403, 422), resp.text
    assert "pb_private_of_owner" not in resp.text


def test_playback_a_banned_account_gets_no_token(client, db_session, signed):
    owner = _account(db_session)
    asset = _video(db_session, owner, "pb_banned")
    _ban(client, owner)

    assert _token(client, asset, owner).status_code == 403


# --- becoming a photographer ------------------------------------------------------------------


def test_upgrade_a_signed_in_client_becomes_a_photographer_once(client, db_session):
    email, _pro = _photographer(client)  # registers, signs in and upgrades through the real routes
    tokens = _sign_in(client, email)
    headers = _bearer(tokens["access_token"])

    again = client.post("/v1/me/upgrade-to-pro", headers=headers)

    assert again.status_code == 200
    assert again.json() == {"ok": True, "role_added": False}
    assert UserRoleType.pro in _roles(db_session, _pro)


def test_upgrade_a_banned_account_cannot(client, db_session):
    someone = _account(db_session)
    _ban(client, someone)

    assert client.post("/v1/me/upgrade-to-pro", headers=_as(someone)).status_code == 403
    assert UserRoleType.pro not in _roles(db_session, someone)


def test_upgrade_nobody_signed_in_cannot(client, db_session):
    assert client.post("/v1/me/upgrade-to-pro").status_code == 401
