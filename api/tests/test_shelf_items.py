"""The Shelf's items, for admins: the typed RAWW price, the price helper,
compatibility with the camera catalogue, and the audit log."""
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import select

from app.models.admin import AdminAuditLog
from app.models.gear_verification import CameraModelReference, SensorSize

ADMIN = "00000000-0000-0000-0000-0000000000aa"
H = {"X-User-Id": ADMIN}
D = Decimal


def _cameras(db):
    for key, name in (("ilce7m4", "Sony A7 IV"), ("eosr6", "Canon EOS R6")):
        db.add(CameraModelReference(normalised_model=key, make=name.split()[0], display_name=name, sensor_size=SensorSize.full_frame, updated_at=datetime.now(timezone.utc)))
    db.commit()


def _item(**over):
    body = {
        "title": "NP-FZ100 battery", "brand": "Sony", "category": "Battery", "level": 2, "price_raww": 650,
        "street_price": "65.00", "street_currency": "GBP", "supplier_cost": "48.00", "supplier_currency": "GBP",
        "supplier_name": "Wex", "supplier_sku": "NPFZ100", "camera_models": ["ilce7m4"],
    }
    body.update(over)
    return body


def _create(client, **over):
    resp = client.post("/v1/admin/shelf/items", headers=H, json=_item(**over))
    assert resp.status_code == 200, resp.text
    return resp.json()


def test_the_admin_types_the_price_and_the_helper_advises(client, db_session):
    _cameras(db_session)
    item = _create(client)

    helper = item["helper"]
    # 65 GBP x 1.17 = 76.05 EUR, less 10% = 68.445, / 0.10 = 684 RAWW (nearest)
    assert D(helper["street_price_eur"]) == D("76.05")
    assert helper["suggested_price_raww"] == 684
    assert item["price_raww"] == 650, "the typed price, not the suggestion"
    assert D(helper["price_eur"]) == D("65.00")
    assert D(helper["supplier_cost_eur"]) == D("56.16")
    assert D(helper["margin_eur"]) == D("8.84")
    assert helper["band_warning"] is None, "650 is within level 2 (300 up to 1000)"


def test_a_price_outside_its_band_is_warned_about_not_refused(client, db_session):
    _cameras(db_session)
    low = _create(client, level=3, price_raww=650)
    high = _create(client, level=1, price_raww=300)
    top = _create(client, level=5, price_raww=90000, camera_models=[])

    assert "Below level 3" in low["helper"]["band_warning"]
    assert "level 2" in high["helper"]["band_warning"]
    assert top["helper"]["band_warning"] is None, "the top level has no ceiling"


def test_the_helper_works_on_an_unsaved_form(client, db_session):
    resp = client.post("/v1/admin/shelf/items/price-helper", headers=H, json={
        "level": 1, "price_raww": 120, "street_price": "15.00", "street_currency": "EUR", "supplier_cost": "9.00", "supplier_currency": "EUR",
    })
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["suggested_price_raww"] == 135 and D(body["margin_eur"]) == D("3.00")


def test_compatibility_comes_from_the_camera_catalogue(client, db_session):
    _cameras(db_session)
    assert client.post("/v1/admin/shelf/items", headers=H, json=_item(camera_models=["nikonz9"])).status_code == 422

    item = _create(client, camera_models=["eosr6", "ilce7m4"])
    assert item["camera_models"] == ["eosr6", "ilce7m4"]

    universal = _create(client, title="128GB CFexpress card", category="card", camera_models=[])
    assert universal["camera_models"] == []


def test_an_edit_is_logged_with_what_changed(client, db_session):
    _cameras(db_session)
    item = _create(client)

    resp = client.put(f"/v1/admin/shelf/items/{item['id']}", headers=H, json=_item(price_raww=700, stock_status="out_of_stock", camera_models=["ilce7m4", "eosr6"]))

    assert resp.status_code == 200, resp.text
    assert (resp.json()["price_raww"], resp.json()["stock_status"]) == (700, "out_of_stock")
    log = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.action == "shelf_item_updated")).scalar_one()
    assert log.meta["changes"]["price_raww"] == {"from": 650, "to": 700}
    assert log.meta["changes"]["camera_models"] == {"from": ["ilce7m4"], "to": ["eosr6", "ilce7m4"]}
    assert "title" not in log.meta["changes"]
    assert db_session.execute(select(AdminAuditLog).where(AdminAuditLog.action == "shelf_item_created")).scalar_one()


def test_bad_items_are_refused(client, db_session):
    _cameras(db_session)
    for over in ({"level": 6}, {"price_raww": 0}, {"title": " "}, {"street_currency": "USD"}, {"supplier_cost": "-1"}, {"stock_status": "maybe"}):
        assert client.post("/v1/admin/shelf/items", headers=H, json=_item(**over)).status_code == 422, over


def test_only_an_admin_manages_items(client, db_session):
    assert client.get("/v1/admin/shelf/items", headers={"X-User-Id": str(uuid.uuid4())}).status_code in (401, 403)


def test_a_camera_taken_off_an_item_no_longer_fits(client, db_session):
    _cameras(db_session)
    item = _create(client, camera_models=["eosr6", "ilce7m4"])

    resp = client.put(f"/v1/admin/shelf/items/{item['id']}", headers=H, json=_item(camera_models=["ilce7m4"]))

    assert resp.json()["camera_models"] == ["ilce7m4"]
