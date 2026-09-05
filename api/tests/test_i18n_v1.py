from __future__ import annotations

import uuid

import pytest

from app.core.errors import APIError
from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.i18n import I18nBundle
from app.services.i18n import (
    DEFAULT_LOCALE,
    activate_bundle,
    get_active_bundle,
    get_user_locale_preference,
    resolve_effective_locale,
    t,
    upsert_user_locale_preference,
)
from app.services.notifications import render_template


def _seed_user(db_session, user_id: str, roles: list[UserRoleType]) -> uuid.UUID:
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid, email=f"{user_id}@example.com"))
    for role in roles:
        exists = db_session.query(UserRole).filter_by(user_id=uid, role=role).one_or_none()
        if not exists:
            db_session.add(UserRole(user_id=uid, role=role))
    db_session.flush()
    return uid


def test_locale_resolution_priority(db_session):
    user_id = _seed_user(db_session, "00000000-0000-0000-0000-000000000401", [UserRoleType.client])
    upsert_user_locale_preference(db_session, user_id=user_id, locale="pt-PT")

    assert resolve_effective_locale(
        db_session,
        user_id=user_id,
        accept_language="es-ES,es;q=0.9",
        request_locale=DEFAULT_LOCALE,
    ) == "pt-PT"
    assert resolve_effective_locale(
        db_session,
        user_id=None,
        accept_language="es-ES,es;q=0.9",
        request_locale=DEFAULT_LOCALE,
    ) == "es-ES"
    assert resolve_effective_locale(
        db_session,
        user_id=None,
        accept_language=None,
        request_locale=None,
    ) == "en-GB"


def test_fallback_to_en_gb_for_missing_locale_key(db_session):
    # `core.action.save` exists only in default seed bundle, not in pt-PT seed.
    value = t(db_session, "core.action.save", locale="pt-PT", namespace="core")
    assert value == "Save"


def test_placeholder_validation(db_session):
    # Seed a custom key in a new en-GB core bundle and activate it.
    bundle = get_active_bundle(db_session, locale="en-GB", namespace="core")
    row = I18nBundle(
        locale="en-GB",
        namespace="core",
        version=int(bundle.version) + 1,
        content={"core.hello": "Hello {name}"},
        is_active=False,
    )
    db_session.add(row)
    db_session.flush()
    activate_bundle(db_session, bundle_id=row.id)

    with pytest.raises(APIError):
        t(db_session, "core.hello", locale="en-GB", namespace="core")


def test_notification_render_uses_user_locale(db_session):
    user_id = _seed_user(db_session, "00000000-0000-0000-0000-000000000402", [UserRoleType.client])
    upsert_user_locale_preference(db_session, user_id=user_id, locale="pt-PT")

    rendered = render_template(db_session, "booking.request_received", payload={}, locale=get_user_locale_preference(db_session, user_id=user_id))
    assert rendered.subject == "Novo pedido de reserva"


def test_bundle_activation_and_fetch_endpoint(client, db_session):
    admin_id = _seed_user(db_session, "00000000-0000-0000-0000-0000000000aa", [UserRoleType.admin])
    _seed_user(db_session, "00000000-0000-0000-0000-000000000403", [UserRoleType.client])
    db_session.commit()

    create = client.post(
        "/v1/admin/i18n/bundles",
        headers={"X-User-Id": str(admin_id)},
        json={
            "locale": "en-GB",
            "namespace": "core",
            "version": 99,
            "content": {"core.action.save": "Store"},
            "is_active": False,
        },
    )
    assert create.status_code == 200
    bundle_id = create.json()["id"]

    activate = client.post(
        f"/v1/admin/i18n/bundles/{bundle_id}/activate",
        headers={"X-User-Id": str(admin_id)},
    )
    assert activate.status_code == 200

    fetch = client.get("/v1/i18n/bundles", params={"locale": "en-GB", "namespace": "core"})
    assert fetch.status_code == 200
    payload = fetch.json()
    assert payload["version"] == 99
    assert payload["content"]["core.action.save"] == "Store"


def test_me_locale_pref_overrides_accept_language(client, db_session):
    user_id = _seed_user(db_session, "00000000-0000-0000-0000-000000000404", [UserRoleType.client])
    db_session.commit()

    put_resp = client.put(
        "/v1/me/locale",
        headers={"X-User-Id": str(user_id), "Accept-Language": "es-ES"},
        json={"locale": "pt-PT"},
    )
    assert put_resp.status_code == 200
    assert put_resp.json()["locale"] == "pt-PT"

    me_resp = client.get("/v1/me", headers={"X-User-Id": str(user_id), "Accept-Language": "es-ES"})
    assert me_resp.status_code == 200
    assert me_resp.json()["locale"] == "pt-PT"
