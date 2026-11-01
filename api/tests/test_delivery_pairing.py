"""Pairing a Lightroom plugin: one-time codes and delivery tokens.

Decision 7 and the brief: the pro app shows a code (ten minutes, one use);
the plugin exchanges it for a token without ever seeing the password. Only
hashes are kept. A token works for one photographer, stops at once when
revoked, after 90 days unused, on a password reset or a sign-out
everywhere; three at most per photographer. Exchanging codes is limited per
address and overall; issuing them per photographer.
"""
import re
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from sqlalchemy import select, text

from app.core.config import get_settings
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.delivery_access import DeliveryPairingCode, DeliveryToken
from app.schemas.media import CurrentUser
from app.services import rate_limit
from app.services.cache import get_redis_client
from app.services.delivery_access import CODE_ALPHABET, update_available


@pytest.fixture(autouse=True)
def roomy_pairing_limits(monkeypatch):
    # Counters live in Redis for the whole run; tests that are not about the
    # limits must not trip over each other's pairings.
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pair_ip", (100_000, 600))
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pair_all", (100_000, 600))
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pairing_issue", (100_000, 3600))


def _pro(db_session, name="Ana Lens") -> uuid.UUID:
    user_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=user_id))
    db_session.flush()
    db_session.add(UserRole(user_id=user_id, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=user_id, display_name=name))
    db_session.commit()
    return user_id


def _h(user_id):
    return {"X-User-Id": str(user_id)}


def _ip():
    return {"X-Forwarded-For": f"10.{uuid.uuid4().int % 250}.{uuid.uuid4().int % 250}.{uuid.uuid4().int % 250}"}


def _code(client, pro) -> str:
    response = client.post("/v1/pro/lightroom/pairing-code", headers=_h(pro))
    assert response.status_code == 200, response.text
    return response.json()["code"]


def _pair(client, code, *, device="Ana's MacBook Pro", version="1.0.0", headers=None):
    return client.post(
        "/v1/delivery/pair",
        headers={**_ip(), **(headers or {})},
        json={"code": code, "device_name": device, "plugin_version": version},
    )


def _token(client, pro, **kwargs) -> str:
    response = _pair(client, _code(client, pro), **kwargs)
    assert response.status_code == 200, response.text
    return response.json()["token"]


def _bearer(token, version="1.0.0"):
    return {"Authorization": f"Bearer {token}", "X-Rawwers-Plugin-Version": version}


# --- codes ---------------------------------------------------------------------------


def test_a_photographer_gets_a_short_code_valid_ten_minutes(client, db_session):
    pro = _pro(db_session)
    response = client.post("/v1/pro/lightroom/pairing-code", headers=_h(pro))

    assert response.status_code == 200
    body = response.json()
    assert re.fullmatch(rf"[{CODE_ALPHABET}]{{4}}-[{CODE_ALPHABET}]{{4}}", body["code"])
    assert body["valid_minutes"] == 10
    expires = datetime.fromisoformat(body["expires_at"])
    assert timedelta(minutes=9) < expires - datetime.now(timezone.utc) <= timedelta(minutes=10)


def test_the_code_alphabet_has_nothing_easily_misread():
    assert not set("0O1IL") & set(CODE_ALPHABET)


def test_only_a_photographer_gets_a_code(client, db_session):
    someone = uuid.uuid4()
    db_session.add(UserAccount(user_id=someone))
    db_session.commit()
    assert client.post("/v1/pro/lightroom/pairing-code", headers=_h(someone)).status_code == 403


def test_an_impersonating_admin_cannot_issue_a_code(db_session):
    from app.api.v1.lightroom import create_pairing_code
    from app.core.errors import APIError

    pro = _pro(db_session)
    with pytest.raises(APIError) as refused:
        create_pairing_code(user=CurrentUser(user_id=pro, roles=[UserRoleType.pro], is_impersonating=True), db=db_session)
    assert refused.value.status_code == 403


def test_issuing_codes_is_limited_per_photographer(client, db_session, monkeypatch):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pairing_issue", (2, 3600))
    pro = _pro(db_session)
    codes = [client.post("/v1/pro/lightroom/pairing-code", headers=_h(pro)).status_code for _ in range(3)]
    assert codes == [200, 200, 429]


# --- exchanging a code ---------------------------------------------------------------


def test_a_code_becomes_a_token_for_that_photographer(client, db_session):
    pro = _pro(db_session, name="Ana Lens")
    response = _pair(client, _code(client, pro))

    assert response.status_code == 200, response.text
    body = response.json()
    assert body["token"].startswith("rwd_") and len(body["token"]) > 40
    assert body["photographer_name"] == "Ana Lens"
    device = db_session.get(DeliveryToken, uuid.UUID(body["device_id"]))
    assert device.pro_user_id == pro
    assert device.device_name == "Ana's MacBook Pro"
    assert device.plugin_version == "1.0.0"


def test_neither_the_code_nor_the_token_is_stored(client, db_session):
    pro = _pro(db_session)
    code = _code(client, pro)
    token = _pair(client, code).json()["token"]

    raw_code = code.replace("-", "")
    for table in ("delivery_pairing_code", "delivery_token"):
        dump = " ".join(str(row) for row in db_session.execute(text(f"select * from {table}")).all())
        assert raw_code not in dump and code not in dump
        assert token not in dump and token[4:] not in dump


def test_a_code_works_once(client, db_session):
    pro = _pro(db_session)
    code = _code(client, pro)
    assert _pair(client, code).status_code == 200
    again = _pair(client, code)
    assert again.status_code == 400
    assert again.json()["error"]["code"] == "invalid_pairing_code"


def test_a_code_expires_after_ten_minutes(client, db_session):
    pro = _pro(db_session)
    code = _code(client, pro)
    row = db_session.execute(select(DeliveryPairingCode).where(DeliveryPairingCode.pro_user_id == pro)).scalar_one()
    row.expires_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    db_session.commit()

    assert _pair(client, code).status_code == 400


def test_a_new_code_retires_the_one_before(client, db_session):
    pro = _pro(db_session)
    first = _code(client, pro)
    second = _code(client, pro)
    assert _pair(client, first).status_code == 400
    assert _pair(client, second).status_code == 200


def test_a_code_may_be_typed_in_lower_case_with_spaces(client, db_session):
    pro = _pro(db_session)
    code = _code(client, pro)
    assert _pair(client, f"  {code.lower().replace('-', ' ')} ").status_code == 200


def test_a_wrong_code_is_refused_exactly_as_a_used_one(client, db_session):
    pro = _pro(db_session)
    code = _code(client, pro)
    _pair(client, code)
    said = lambda response: (response.status_code, response.json()["error"]["code"], response.json()["error"]["message"])
    used = said(_pair(client, code))
    assert used == said(_pair(client, "ZZZZ-ZZZZ")) == said(_pair(client, "AB"))


def test_exchanging_codes_is_limited_per_address(client, db_session, monkeypatch):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pair_ip", (2, 600))
    address = _ip()
    codes = [_pair(client, "ZZZZ-ZZZZ", headers=address).status_code for _ in range(3)]
    assert codes == [400, 400, 429]


def test_exchanging_codes_is_limited_overall_whatever_the_address(client, db_session, monkeypatch):
    # The address comes from X-Forwarded-For, which a guesser can set; this
    # limit does not depend on it.
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pair_all", (2, 600))
    get_redis_client().delete("ratelimit:delivery_pair_all:all:600")
    codes = [_pair(client, "ZZZZ-ZZZZ").status_code for _ in range(3)]
    assert codes == [400, 400, 429]


# --- three devices at most -----------------------------------------------------------


def test_a_fourth_device_waits_for_one_to_be_revoked(client, db_session):
    pro = _pro(db_session)
    for n in range(3):
        _token(client, pro, device=f"Mac {n}")
    code = _code(client, pro)

    fourth = _pair(client, code)
    assert fourth.status_code == 409
    assert "Revoke one" in fourth.json()["error"]["message"]

    devices = client.get("/v1/pro/lightroom/devices", headers=_h(pro)).json()["items"]
    assert client.delete(f"/v1/pro/lightroom/devices/{devices[0]['id']}", headers=_h(pro)).status_code == 204
    assert _pair(client, code).status_code == 200, "the same code, still inside its ten minutes"


# --- using the token -----------------------------------------------------------------


def test_the_plugin_learns_who_it_is_connected_as(client, db_session):
    pro = _pro(db_session, name="Ana Lens")
    token = _token(client, pro)
    me = client.get("/v1/delivery/me", headers=_bearer(token))
    assert me.status_code == 200
    assert me.json()["photographer_name"] == "Ana Lens"


@pytest.mark.parametrize(("version", "flag"), [("0.9.0", "true"), ("1.0.0", "false"), ("1.0", "false")])
def test_an_older_plugin_is_told_an_update_is_available(client, db_session, monkeypatch, version, flag):
    # Only the newest version is under test here; 0.9.0 is below the minimum
    # supported (1.0.0), which test_plugin_versions.py covers.
    monkeypatch.setattr(get_settings(), "lightroom_plugin_min_version", "0.0.0")
    token = _token(client, _pro(db_session))
    me = client.get("/v1/delivery/me", headers=_bearer(token, version=version))
    assert me.headers["X-Rawwers-Update-Available"] == flag
    assert me.json()["update_available"] is (flag == "true")
    assert me.json()["latest_version"] == "1.0.0"


def test_versions_compare_as_numbers():
    assert update_available("0.10.0") is True
    assert update_available("1.0.1") is False
    assert update_available("2.0") is False
    assert update_available("1.0.0-beta") is None
    assert update_available(None) is None


@pytest.mark.parametrize("authorization", [None, "Bearer rwd_not-a-real-token", "Bearer something-else", "Basic abc"])
def test_no_token_or_an_unknown_one_asks_for_a_new_code(client, authorization):
    headers = {"Authorization": authorization} if authorization else {}
    response = client.get("/v1/delivery/me", headers=headers)
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "delivery_token_invalid"


def test_a_revoked_device_is_refused_at_once(client, db_session):
    pro = _pro(db_session)
    token = _token(client, pro)
    (device,) = client.get("/v1/pro/lightroom/devices", headers=_h(pro)).json()["items"]

    assert client.delete(f"/v1/pro/lightroom/devices/{device['id']}", headers=_h(pro)).status_code == 204

    refused = client.get("/v1/delivery/me", headers=_bearer(token))
    assert refused.status_code == 401
    assert refused.json()["error"]["code"] == "delivery_token_revoked"
    assert client.get("/v1/pro/lightroom/devices", headers=_h(pro)).json()["items"] == []


def test_a_photographer_cannot_revoke_someone_elses_device(client, db_session):
    owner, other = _pro(db_session), _pro(db_session)
    token = _token(client, owner)
    (device,) = client.get("/v1/pro/lightroom/devices", headers=_h(owner)).json()["items"]

    assert client.delete(f"/v1/pro/lightroom/devices/{device['id']}", headers=_h(other)).status_code == 404
    assert client.get("/v1/delivery/me", headers=_bearer(token)).status_code == 200


def test_the_devices_list_shows_only_this_photographers_with_last_use(client, db_session):
    owner, other = _pro(db_session), _pro(db_session)
    token = _token(client, owner, device="Studio iMac")
    _token(client, other)

    (device,) = client.get("/v1/pro/lightroom/devices", headers=_h(owner)).json()["items"]
    assert device["device_name"] == "Studio iMac"
    assert token.startswith(device["token_prefix"]) and len(device["token_prefix"]) == 8
    assert device["last_used_at"] and device["plugin_version"] == "1.0.0"
    assert set(device) == {"id", "device_name", "token_prefix", "plugin_version", "created_at", "last_used_at"}


def test_ninety_days_unused_and_the_token_expires(client, db_session):
    pro = _pro(db_session)
    token = _token(client, pro)
    device = db_session.execute(select(DeliveryToken).where(DeliveryToken.pro_user_id == pro)).scalar_one()
    device.last_used_at = datetime.now(timezone.utc) - timedelta(days=90, minutes=1)
    db_session.commit()

    refused = client.get("/v1/delivery/me", headers=_bearer(token))
    assert refused.status_code == 401
    assert refused.json()["error"]["code"] == "delivery_token_expired"
    db_session.expire_all()
    assert db_session.get(DeliveryToken, device.id).revoked_reason == "expired"


def test_using_the_token_keeps_it_alive(client, db_session):
    pro = _pro(db_session)
    token = _token(client, pro)
    device = db_session.execute(select(DeliveryToken).where(DeliveryToken.pro_user_id == pro)).scalar_one()
    device.last_used_at = datetime.now(timezone.utc) - timedelta(days=89)
    db_session.commit()

    assert client.get("/v1/delivery/me", headers=_bearer(token, version="1.0.1")).status_code == 200
    db_session.expire_all()
    refreshed = db_session.get(DeliveryToken, device.id)
    assert datetime.now(timezone.utc) - refreshed.last_used_at < timedelta(minutes=1)
    assert refreshed.plugin_version == "1.0.1"


def test_ending_every_session_disconnects_lightroom_too(client, db_session):
    # A password reset, a sign-out everywhere and a ban all end every
    # session through this one function.
    from app.services.auth_service import revoke_all_user_sessions

    pro = _pro(db_session)
    token = _token(client, pro)
    revoke_all_user_sessions(db_session, pro)
    db_session.commit()

    refused = client.get("/v1/delivery/me", headers=_bearer(token))
    assert refused.status_code == 401
    assert refused.json()["error"]["code"] == "delivery_token_revoked"
