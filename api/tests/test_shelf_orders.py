"""Ordering on The Shelf: every check, atomically; cancelling with the RAWW
back; the address encrypted on the server, and copied onto the order."""
import threading
import time
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from sqlalchemy import func, select

from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile
from app.models.communication import Notification
from app.models.prints import ShippingAddress
from app.models.risk import RiskActionType
from app.models.shelf import (
    ProRawwBalance,
    RawwEntryKind,
    ShelfItem,
    ShelfOrder,
    ShelfOrderEvent,
    ShelfOrderStatus,
    ShelfStockStatus,
)
from app.models.niche import SkillTier
from app.services import addresses, shelf_orders
from app.services import raww_ledger as ledger
from app.services.shelf_settings import shelf_settings
from app.tasks.outbox_tasks import dispatch_outbox_events_task

from tests.conftest import TestingSessionLocal
from tests.test_shelf_gear_and_wishlist import _cameras, _h, _item, _pro

ADDRESS = {"name": "Sam Reyes", "line1": "12 Rose Street", "city": "London", "postal_code": "E1 6AN", "country": "GB"}


def _ready_pro(db, *, raww=1000, tier=None, kyc=KYCStatus.approved, address=True):
    pro = _pro(db, tier)
    db.get(ProProfile, pro).kyc_status = kyc
    db.commit()
    if raww:
        ledger.post_entry(db, pro_user_id=pro, kind=RawwEntryKind.admin_adjust, amount=raww, source_type="admin", source_id=f"seed-{pro}", note="seed")
    if address:
        shelf_orders.save_address(db, pro_user_id=pro, fields=ADDRESS)
    db.commit()
    return pro


def _order(client, pro, item, request_id=None):
    return client.post("/v1/pro/shelf/orders", headers=_h(pro), json={"item_id": str(item.id), "client_request_id": request_id or str(uuid.uuid4())})


def _spendable(db, pro):
    db.expire_all()
    balance = db.get(ProRawwBalance, pro)
    assert (balance.spendable, balance.pending) == ledger.ledger_totals(db, pro)
    return balance.spendable


# --- the address -----------------------------------------------------------------------------


def test_the_address_is_stored_encrypted_and_read_back(client, db_session):
    pro = _pro(db_session)

    resp = client.put("/v1/pro/shelf/address", headers=_h(pro), json=ADDRESS)

    assert resp.status_code == 200, resp.text
    assert resp.json()["address"]["line1"] == "12 Rose Street"
    row = db_session.execute(select(ShippingAddress).where(ShippingAddress.user_id == pro)).scalar_one()
    assert "Rose" not in str(row.encrypted_fields) and set(row.encrypted_fields) == {"v", "token"}
    assert client.get("/v1/pro/shelf/address", headers=_h(pro)).json()["address"]["postal_code"] == "E1 6AN"


def test_a_client_sent_encrypted_address_is_refused(client, db_session):
    pro = _pro(db_session)
    resp = client.put("/v1/pro/shelf/address", headers=_h(pro), json={**ADDRESS, "encrypted_fields": {"line1": "x"}})
    # The schema has no such field for the Shelf: it is ignored, and the
    # plain fields are what is stored.
    assert resp.status_code == 200
    with pytest.raises(APIError):
        addresses.refuse_client_encrypted({"encrypted_fields": {"line1": "x"}})


def test_only_allowed_countries_and_complete_addresses(client, db_session):
    pro = _pro(db_session)
    assert client.put("/v1/pro/shelf/address", headers=_h(pro), json={**ADDRESS, "country": "PT"}).status_code == 422
    assert client.put("/v1/pro/shelf/address", headers=_h(pro), json={**ADDRESS, "line1": " "}).status_code == 422


# --- placing ---------------------------------------------------------------------------------


def test_an_order_takes_the_rawws_and_copies_what_priced_it(client, db_session):
    pro = _ready_pro(db_session)
    item = _item(db_session, title="Card")

    resp = _order(client, pro, item)

    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "placed" and resp.json()["can_cancel"] is True
    assert _spendable(db_session, pro) == 850
    order = db_session.get(ShelfOrder, uuid.UUID(resp.json()["id"]))
    assert (order.title, order.price_raww, str(order.raww_eur_value)) == ("Card", 150, "0.1000")
    assert addresses.decrypt(order.shipping_address)["line1"] == "12 Rose Street"
    assert order.country == "GB"


def test_the_same_request_twice_is_one_order(client, db_session):
    pro = _ready_pro(db_session)
    item = _item(db_session)

    first, again = _order(client, pro, item, "tap-1"), _order(client, pro, item, "tap-1")

    assert first.json()["id"] == again.json()["id"]
    assert _spendable(db_session, pro) == 850


@pytest.mark.parametrize(
    ("setup", "code"),
    [
        ("not_enough", "insufficient_raww"),
        ("negative", "insufficient_raww"),
        ("no_kyc", "kyc_required"),
        ("frozen", "raww_frozen"),
        ("out_of_stock", "out_of_stock"),
        ("hidden", "not_found"),
        ("above_tier", "not_found"),
        ("wrong_camera", "not_found"),
        ("no_address", "address_required"),
        ("closed", "shelf_closed"),
    ],
)
def test_each_check_refuses_and_spends_nothing(client, db_session, setup, code):
    _cameras(db_session)
    pro = _ready_pro(
        db_session,
        raww=100 if setup == "not_enough" else 1000,
        kyc=KYCStatus.pending if setup == "no_kyc" else KYCStatus.approved,
        address=setup != "no_address",
    )
    item = _item(
        db_session,
        level=5 if setup == "above_tier" else 1,
        active=setup != "hidden",
        cameras=["eosr6"] if setup == "wrong_camera" else (),
    )
    if setup == "negative":
        ledger.post_entry(db_session, pro_user_id=pro, kind=RawwEntryKind.admin_adjust, amount=-1100, source_type="admin", source_id="neg", note="refund after spend")
    if setup == "out_of_stock":
        item.stock_status = ShelfStockStatus.out_of_stock
    if setup == "frozen":
        from app.models.risk import RiskAction

        db_session.add(RiskAction(user_id=pro, action_type=RiskActionType.freeze_rewards, reason="test"))
    if setup == "closed":
        shelf_settings(db_session).shelf_enabled = False
    db_session.commit()
    before = _spendable(db_session, pro)

    resp = _order(client, pro, item)

    assert resp.status_code in (403, 404, 409, 422), resp.text
    assert resp.json()["error"]["code"] == code
    assert _spendable(db_session, pro) == before
    assert db_session.execute(select(func.count()).select_from(ShelfOrder)).scalar_one() == 0


def test_a_country_no_longer_allowed_is_refused_at_order(client, db_session):
    pro = _ready_pro(db_session)
    item = _item(db_session)
    shelf_settings(db_session).allowed_countries = ["IE"]
    db_session.commit()

    assert _order(client, pro, item).json()["error"]["code"] == "country_not_allowed"


def test_at_most_three_orders_a_month(client, db_session):
    pro = _ready_pro(db_session)
    items = [_item(db_session, title=f"Item {n}") for n in range(4)]

    codes = [_order(client, pro, item).status_code for item in items]

    assert codes == [200, 200, 200, 409]


def test_a_cancelled_order_does_not_count_against_the_month(client, db_session):
    pro = _ready_pro(db_session)
    items = [_item(db_session, title=f"Item {n}") for n in range(4)]
    first = _order(client, pro, items[0]).json()
    client.post(f"/v1/pro/shelf/orders/{first['id']}/cancel", headers=_h(pro))

    assert [_order(client, pro, item).status_code for item in items[1:]] == [200, 200, 200]


def test_last_months_orders_do_not_count(client, db_session):
    pro = _ready_pro(db_session)
    items = [_item(db_session, title=f"Item {n}") for n in range(4)]
    for item in items[:3]:
        _order(client, pro, item)
    db_session.expire_all()
    for order in db_session.execute(select(ShelfOrder)).scalars():
        order.placed_at = order.placed_at.replace(day=1) - timedelta(days=2)
    shelf_settings(db_session).same_item_cooldown_days = 0
    db_session.commit()

    assert _order(client, pro, items[3]).status_code == 200


def test_the_same_item_waits_for_its_cooldown(client, db_session):
    pro = _ready_pro(db_session)
    item = _item(db_session)
    _order(client, pro, item)

    again = _order(client, pro, item)
    assert again.json()["error"]["code"] == "same_item_cooldown"

    db_session.expire_all()
    order = db_session.execute(select(ShelfOrder)).scalar_one()
    order.placed_at = datetime.now(timezone.utc) - timedelta(days=91)
    db_session.commit()
    assert _order(client, pro, item).status_code == 200


def test_two_orders_at_once_cannot_spend_more_than_there_is():
    setup = TestingSessionLocal()
    try:
        pro = _ready_pro(setup, raww=200)
        first_item, second_item = _item(setup, title="A").id, _item(setup, title="B").id
    finally:
        setup.close()

    held, other = TestingSessionLocal(), TestingSessionLocal()
    outcome = {}

    def second():
        try:
            shelf_orders.place_order(other, pro_user_id=pro, item_id=second_item, client_request_id="b")
            other.commit()
            outcome["second"] = "placed"
        except APIError as error:
            other.rollback()
            outcome["second"] = error.code

    try:
        shelf_orders.place_order(held, pro_user_id=pro, item_id=first_item, client_request_id="a")
        thread = threading.Thread(target=second)
        thread.start()
        time.sleep(0.6)
        held.commit()
        thread.join(timeout=20)
    finally:
        held.close()
        other.close()

    check = TestingSessionLocal()
    try:
        assert outcome["second"] == "insufficient_raww"
        assert _spendable(check, pro) == 50
        assert check.execute(select(func.count()).select_from(ShelfOrder)).scalar_one() == 1
    finally:
        check.close()


def test_a_double_tap_at_once_is_one_order():
    setup = TestingSessionLocal()
    try:
        pro = _ready_pro(setup, raww=1000)
        item_id = _item(setup).id
    finally:
        setup.close()

    held, other = TestingSessionLocal(), TestingSessionLocal()
    outcome = {}

    def second():
        try:
            outcome["second"] = shelf_orders.place_order(other, pro_user_id=pro, item_id=item_id, client_request_id="tap").id
            other.commit()
        except APIError as error:
            other.rollback()
            outcome["second"] = error.code

    try:
        first = shelf_orders.place_order(held, pro_user_id=pro, item_id=item_id, client_request_id="tap").id
        thread = threading.Thread(target=second)
        thread.start()
        time.sleep(0.6)
        held.commit()
        thread.join(timeout=20)
    finally:
        held.close()
        other.close()

    check = TestingSessionLocal()
    try:
        assert outcome["second"] == first
        assert _spendable(check, pro) == 850
    finally:
        check.close()


# --- cancelling ------------------------------------------------------------------------------


def test_the_photographer_can_cancel_while_placed_and_gets_every_raww_back(client, db_session):
    pro = _ready_pro(db_session)
    order = _order(client, pro, _item(db_session)).json()

    resp = client.post(f"/v1/pro/shelf/orders/{order['id']}/cancel", headers=_h(pro))

    assert resp.status_code == 200 and resp.json()["status"] == "refunded"
    assert _spendable(db_session, pro) == 1000
    events = db_session.execute(select(ShelfOrderEvent.to_status).order_by(ShelfOrderEvent.created_at)).scalars().all()
    assert events == ["placed", "cancelled", "refunded"]


def test_once_ordered_the_photographer_cannot_cancel(client, db_session):
    pro = _ready_pro(db_session)
    order = _order(client, pro, _item(db_session)).json()
    shelf_orders.admin_mark_ordered(db_session, order_id=uuid.UUID(order["id"]), supplier_order_ref="WEX-1", admin_user_id=uuid.uuid4())
    db_session.commit()

    assert client.post(f"/v1/pro/shelf/orders/{order['id']}/cancel", headers=_h(pro)).status_code == 409
    assert _spendable(db_session, pro) == 850


def test_each_change_sends_an_in_app_notification(client, db_session):
    pro = _ready_pro(db_session)
    order = _order(client, pro, _item(db_session, title="Card")).json()
    client.post(f"/v1/pro/shelf/orders/{order['id']}/cancel", headers=_h(pro))

    dispatch_outbox_events_task()

    db_session.expire_all()
    titles = db_session.execute(select(Notification.title).where(Notification.user_id == pro).order_by(Notification.created_at)).scalars().all()
    assert titles == ["Order placed", "Order cancelled", "RAWW back"]


def test_my_orders_lists_newest_first(client, db_session):
    pro = _ready_pro(db_session)
    for n in range(2):
        _order(client, pro, _item(db_session, title=f"Item {n}"))

    body = client.get("/v1/pro/shelf/orders", headers=_h(pro)).json()

    assert [o["title"] for o in body["items"]] == ["Item 1", "Item 0"]


def test_another_photographers_order_cannot_be_cancelled(client, db_session):
    pro, other = _ready_pro(db_session), _ready_pro(db_session)
    order = _order(client, pro, _item(db_session)).json()
    assert client.post(f"/v1/pro/shelf/orders/{order['id']}/cancel", headers=_h(other)).status_code == 404
