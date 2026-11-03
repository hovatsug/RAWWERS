"""The Shelf's settings: defaults, validation, audit, and the production guard."""
import uuid
from decimal import Decimal

from sqlalchemy import select

from app.core.config import get_settings
from app.models.admin import AdminAuditLog
from app.models.shelf import SHELF_TERMS_PLACEHOLDER, ShelfSettings
from app.services import shelf_settings as ss

ADMIN = "00000000-0000-0000-0000-0000000000aa"
H = {"X-User-Id": ADMIN}


def test_the_defaults_are_the_owners(client, db_session):
    body = client.get("/v1/admin/shelf/settings", headers=H).json()

    assert Decimal(body["raww_eur_value"]) == Decimal("0.10")
    assert body["inactivity_months"] == 24 and body["warning_days"] == 30
    assert body["level_band_raww"] == [100, 300, 1000, 3000, 6000]
    assert body["tier_max_level"] == {"rookie": 3, "skilled": 4, "pro": 4, "elite": 5, "master": 5}
    assert (body["wishlist_max"], body["max_orders_per_month"], body["same_item_cooldown_days"]) == (3, 3, 90)
    assert body["allowed_countries"] == ["GB"] and body["free_shipping"] is True
    assert body["shelf_enabled"] is True and body["shelf_open"] is True, "on outside production"
    assert body["terms_draft"] is True and body["terms_text"] == SHELF_TERMS_PLACEHOLDER


def test_production_starts_shut(db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "app_env", "production")
    row = ss.shelf_settings(db_session)
    assert row.shelf_enabled is False
    assert ss.shelf_open(db_session) is False


def test_in_production_it_needs_approved_terms_as_well(db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "app_env", "production")
    admin = uuid.uuid4()
    ss.update_settings(db_session, values={"shelf_enabled": True}, actor_user_id=admin)
    assert ss.shelf_open(db_session) is False, "terms are still the draft"

    ss.set_terms(db_session, text="The reviewed terms.", actor_user_id=admin)
    ss.approve_terms(db_session, reviewed_by="Dr. Ana Costa", note="Reviewed for the beta", actor_user_id=admin)
    assert ss.shelf_open(db_session) is True

    ss.set_terms(db_session, text="A changed clause.", actor_user_id=admin)
    assert ss.shelf_open(db_session) is False, "new text is a draft again"


def test_the_placeholder_cannot_be_approved(client, db_session):
    resp = client.post("/v1/admin/shelf/settings/terms/approve", headers=H, json={"reviewed_by": "Lawyer", "note": "ok"})
    assert resp.status_code == 409


def test_approving_needs_who_reviewed_and_a_note(client, db_session):
    client.put("/v1/admin/shelf/settings/terms", headers=H, json={"text": "Reviewed text"})
    assert client.post("/v1/admin/shelf/settings/terms/approve", headers=H, json={"reviewed_by": " ", "note": "ok"}).status_code == 422
    assert client.post("/v1/admin/shelf/settings/terms/approve", headers=H, json={"reviewed_by": "Lawyer", "note": ""}).status_code == 422
    ok = client.post("/v1/admin/shelf/settings/terms/approve", headers=H, json={"reviewed_by": "Lawyer", "note": "Reviewed"})
    assert ok.status_code == 200 and ok.json()["terms_draft"] is False


def test_an_edit_is_saved_and_logged_with_what_changed(client, db_session):
    resp = client.put("/v1/admin/shelf/settings", headers=H, json={"raww_eur_value": "0.12", "wishlist_max": 5})

    assert resp.status_code == 200, resp.text
    assert Decimal(resp.json()["raww_eur_value"]) == Decimal("0.12")
    log = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.action == "shelf_settings_updated")).scalar_one()
    assert str(log.actor_user_id) == ADMIN
    change = log.meta["changes"]["raww_eur_value"]
    assert (Decimal(change["from"]), Decimal(change["to"])) == (Decimal("0.10"), Decimal("0.12"))
    assert log.meta["changes"]["wishlist_max"] == {"from": 3, "to": 5}
    assert "inactivity_months" not in log.meta["changes"]


def test_bad_values_are_refused_and_nothing_changes(client, db_session):
    bad = [
        {"raww_eur_value": "0"},
        {"level_band_raww": [100, 300, 300, 3000, 6000]},
        {"level_band_raww": [100, 300, 1000]},
        {"tier_max_level": {"rookie": 3, "skilled": 4}},
        {"tier_max_level": {"rookie": 6, "skilled": 4, "pro": 4, "elite": 5, "master": 5}},
        {"allowed_countries": ["GBR"]},
        {"warning_days": 800},
        {"inactivity_months": 1, "warning_days": 31},
        {"shelf_discount_percent": 95},
    ]
    for body in bad:
        assert client.put("/v1/admin/shelf/settings", headers=H, json=body).status_code == 422, body
    db_session.expire_all()
    row = db_session.get(ShelfSettings, 1)
    assert row.raww_eur_value == Decimal("0.10") and row.level_band_raww == [100, 300, 1000, 3000, 6000]


def test_only_an_admin_sees_the_settings(client, db_session):
    assert client.get("/v1/admin/shelf/settings", headers={"X-User-Id": str(uuid.uuid4())}).status_code in (401, 403)
