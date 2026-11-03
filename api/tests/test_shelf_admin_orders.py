"""The admin side of Shelf orders, and of a photographer's RAWW."""
import uuid

from sqlalchemy import select

from app.models.admin import AdminAuditLog
from app.models.shelf import ShelfItem, ShelfStockStatus

from tests.test_shelf_gear_and_wishlist import _h, _item
from tests.test_shelf_orders import _order, _ready_pro, _spendable

ADMIN = "00000000-0000-0000-0000-0000000000aa"
H = {"X-User-Id": ADMIN}


def _placed(client, db_session):
    pro = _ready_pro(db_session)
    item = _item(db_session, title="Card")
    order = _order(client, pro, item).json()
    return pro, item, order


def _post(client, order_id, step, body=None):
    return client.post(f"/v1/admin/shelf/orders/{order_id}/{step}", headers=H, json=body)


def test_the_list_shows_the_address_and_history_to_fulfil_it(client, db_session):
    _placed(client, db_session)

    [row] = client.get("/v1/admin/shelf/orders", headers=H, params={"status": "placed"}).json()["items"]

    assert row["address"]["line1"] == "12 Rose Street" and row["country"] == "GB"
    assert row["price_raww"] == 150 and row["price_eur"] == "15.00"
    assert [e["to_status"] for e in row["events"]] == ["placed"]


def test_an_order_moves_on_with_what_each_step_needs_and_each_step_is_logged(client, db_session):
    _, _, order = _placed(client, db_session)

    assert _post(client, order["id"], "ordered", {"supplier_order_ref": " "}).status_code == 422
    assert _post(client, order["id"], "shipped", {"tracking_code": "RM1"}).status_code == 409, "not ordered yet"
    ordered = _post(client, order["id"], "ordered", {"supplier_order_ref": "WEX-123"}).json()
    assert _post(client, order["id"], "shipped", {"tracking_code": ""}).status_code == 422
    shipped = _post(client, order["id"], "shipped", {"tracking_code": "RM123456GB"}).json()
    delivered = _post(client, order["id"], "delivered").json()

    assert (ordered["status"], shipped["status"], delivered["status"]) == ("ordered", "shipped", "delivered")
    assert delivered["supplier_order_ref"] == "WEX-123" and delivered["tracking_code"] == "RM123456GB"
    assert [e["to_status"] for e in delivered["events"]] == ["placed", "ordered", "shipped", "delivered"]
    actions = db_session.execute(select(AdminAuditLog.action).where(AdminAuditLog.target_id == order["id"])).scalars().all()
    assert sorted(actions) == ["shelf_order_delivered", "shelf_order_ordered", "shelf_order_shipped"]


def test_cancelling_before_shipping_refunds_every_raww_and_needs_a_reason(client, db_session):
    pro, _, order = _placed(client, db_session)
    _post(client, order["id"], "ordered", {"supplier_order_ref": "WEX-123"})

    assert _post(client, order["id"], "cancel", {"reason": "because"}).status_code == 422
    resp = _post(client, order["id"], "cancel", {"reason": "supplier_problem", "note": "discontinued"})

    assert resp.status_code == 200 and resp.json()["status"] == "refunded"
    assert resp.json()["cancel_reason"] == "supplier_problem: discontinued"
    assert _spendable(db_session, pro) == 1000


def test_out_of_stock_also_marks_the_item_out_of_stock(client, db_session):
    _, item, order = _placed(client, db_session)

    _post(client, order["id"], "cancel", {"reason": "out_of_stock"})

    db_session.expire_all()
    assert db_session.get(ShelfItem, item.id).stock_status == ShelfStockStatus.out_of_stock


def test_after_shipping_there_is_no_cancel(client, db_session):
    pro, _, order = _placed(client, db_session)
    _post(client, order["id"], "ordered", {"supplier_order_ref": "WEX-123"})
    _post(client, order["id"], "shipped", {"tracking_code": "RM1"})

    assert _post(client, order["id"], "cancel", {"reason": "other"}).status_code == 409
    assert _spendable(db_session, pro) == 850


def test_a_return_is_an_adjustment_with_a_note_and_the_ledger_shows_it(client, db_session):
    pro, _, _ = _placed(client, db_session)

    assert client.post(f"/v1/admin/shelf/raww/{pro}/adjust", headers=H, json={"amount": 150, "note": " "}).status_code == 422
    entry = client.post(f"/v1/admin/shelf/raww/{pro}/adjust", headers=H, json={"amount": 150, "note": "Returned damaged", "request_id": "r1"})
    again = client.post(f"/v1/admin/shelf/raww/{pro}/adjust", headers=H, json={"amount": 150, "note": "Returned damaged", "request_id": "r1"})

    assert entry.status_code == 200 and again.json()["id"] == entry.json()["id"], "a resubmitted form is one adjustment"
    ledger = client.get(f"/v1/admin/shelf/raww/{pro}", headers=H).json()
    assert ledger["spendable"] == 1000
    assert [i["kind"] for i in ledger["items"]][:2] == ["admin_adjust", "spend_order"]
    log = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.action == "raww_adjusted")).scalar_one()
    assert str(log.actor_user_id) == ADMIN and log.reason == "Returned damaged"


def test_only_admins(client, db_session):
    pro, _, order = _placed(client, db_session)
    assert client.get("/v1/admin/shelf/orders", headers=_h(pro)).status_code in (401, 403)
    assert client.post(f"/v1/admin/shelf/orders/{order['id']}/delivered", headers={"X-User-Id": str(uuid.uuid4())}).status_code in (401, 403)
