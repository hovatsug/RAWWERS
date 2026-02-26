import uuid

from app.models.admin import UserRole, UserRoleType
from app.models.auth import EmailVerification, PasswordReset, SessionRefreshToken
from app.models.outbox import OutboxEvent


def _auth_headers(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


def test_register_verify_and_login(client, db_session):
    email = "newuser@example.com"
    password = "S3curePass!"

    reg = client.post("/v1/auth/register", json={"email": email, "password": password})
    assert reg.status_code == 201

    login = client.post("/v1/auth/login", json={"email": email, "password": password})
    assert login.status_code == 200

    verify_event = (
        db_session.query(EmailVerification)
        .order_by(EmailVerification.created_at.desc())
        .first()
    )
    assert verify_event is not None

    outbox_row = db_session.query(OutboxEvent).filter_by(topic="email.verify.send").order_by(OutboxEvent.created_at.desc()).first()
    assert outbox_row is not None
    code = outbox_row.payload["code"]

    confirm = client.post("/v1/auth/verify-email/confirm", json={"code": code})
    assert confirm.status_code == 204


def test_refresh_rotation_and_reuse_detection(client, db_session):
    email = "rotate@example.com"
    password = "S3curePass!"
    client.post("/v1/auth/register", json={"email": email, "password": password})

    login = client.post("/v1/auth/login", json={"email": email, "password": password}).json()
    refresh_1 = login["refresh_token"]

    rotated = client.post("/v1/auth/refresh", json={"refresh_token": refresh_1})
    assert rotated.status_code == 200

    reuse = client.post("/v1/auth/refresh", json={"refresh_token": refresh_1})
    assert reuse.status_code == 401

    rows = db_session.query(SessionRefreshToken).all()
    assert rows
    family = rows[0].family_id
    family_rows = db_session.query(SessionRefreshToken).filter_by(family_id=family).all()
    assert all(item.revoked_at is not None for item in family_rows)


def test_logout_revokes_refresh_token(client):
    email = "logout@example.com"
    password = "S3curePass!"
    client.post("/v1/auth/register", json={"email": email, "password": password})
    login = client.post("/v1/auth/login", json={"email": email, "password": password}).json()

    logout = client.post("/v1/auth/logout", json={"refresh_token": login["refresh_token"]}, headers=_auth_headers(login["access_token"]))
    assert logout.status_code == 204

    refresh = client.post("/v1/auth/refresh", json={"refresh_token": login["refresh_token"]})
    assert refresh.status_code == 401


def test_password_reset_revokes_sessions(client, db_session):
    email = "reset@example.com"
    password = "S3curePass!"
    client.post("/v1/auth/register", json={"email": email, "password": password})
    login = client.post("/v1/auth/login", json={"email": email, "password": password}).json()

    req = client.post("/v1/auth/password-reset/request", json={"email": email})
    assert req.status_code == 204

    outbox_row = db_session.query(OutboxEvent).filter_by(topic="email.reset.send").order_by(OutboxEvent.created_at.desc()).first()
    assert outbox_row is not None
    code = outbox_row.payload["code"]

    confirm = client.post("/v1/auth/password-reset/confirm", json={"code": code, "new_password": "N3wStrongPass!"})
    assert confirm.status_code == 204

    refresh = client.post("/v1/auth/refresh", json={"refresh_token": login["refresh_token"]})
    assert refresh.status_code == 401


def test_rbac_blocks_non_admin(client):
    email = "rbac@example.com"
    password = "S3curePass!"
    client.post("/v1/auth/register", json={"email": email, "password": password})
    login = client.post("/v1/auth/login", json={"email": email, "password": password}).json()

    resp = client.get("/v1/admin/users", headers=_auth_headers(login["access_token"]))
    assert resp.status_code == 403


def test_admin_impersonation_flow(client, db_session):
    admin_email = "admin@example.com"
    target_email = "target@example.com"
    password = "S3curePass!"

    admin_reg = client.post("/v1/auth/register", json={"email": admin_email, "password": password}).json()
    target_reg = client.post("/v1/auth/register", json={"email": target_email, "password": password}).json()

    admin_user_id = uuid.UUID(admin_reg["user_id"])
    target_user_id = uuid.UUID(target_reg["user_id"])
    db_session.add(UserRole(user_id=admin_user_id, role=UserRoleType.admin))
    db_session.commit()

    admin_login = client.post("/v1/auth/login", json={"email": admin_email, "password": password}).json()
    start = client.post(
        "/v1/admin/impersonate/start",
        json={"target_user_id": str(target_user_id), "reason": "support case"},
        headers=_auth_headers(admin_login["access_token"]),
    )
    assert start.status_code == 200
    imp_token = start.json()["access_token"]

    me = client.get("/v1/me", headers=_auth_headers(imp_token))
    assert me.status_code == 200
    assert me.json()["is_impersonating"] is True
