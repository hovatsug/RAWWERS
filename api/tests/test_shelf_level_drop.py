"""A photographer whose tier drops (owner's decision, 2026-11-03): open
orders stand, and wish-list items above the new level show as locked
teasers they can still take off the list."""
from sqlalchemy import select

from app.models.niche import ProNicheSkill, SkillTier
from app.models.shelf import ShelfOrder, ShelfOrderStatus

from tests.test_shelf_browse import _browse, _level
from tests.test_shelf_gear_and_wishlist import _h, _item
from tests.test_shelf_orders import _order, _ready_pro

ADMIN = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}


def _drop_to_rookie(db, pro):
    for skill in db.execute(select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro)).scalars():
        skill.tier = SkillTier.rookie
    db.commit()


def _skilled_with_a_wish_and_an_order(client, db_session):
    pro = _ready_pro(db_session, tier=SkillTier.skilled)
    wished = _item(db_session, level=4, title="Gimbal")
    ordered = _item(db_session, level=4, title="Light")
    assert client.put(f"/v1/pro/shelf/wishlist/{wished.id}", headers=_h(pro)).status_code == 200
    order = _order(client, pro, ordered)
    assert order.status_code == 200, order.text
    _drop_to_rookie(db_session, pro)
    return pro, wished, ordered, order.json()


def test_an_open_order_stands_and_moves_on_after_the_drop(client, db_session):
    pro, _, _, order = _skilled_with_a_wish_and_an_order(client, db_session)

    [mine] = client.get("/v1/pro/shelf/orders", headers=_h(pro)).json()["items"]
    assert (mine["id"], mine["status"]) == (order["id"], "placed")
    resp = client.post(f"/v1/admin/shelf/orders/{order['id']}/ordered", headers=ADMIN, json={"supplier_order_ref": "WEX-1"})
    assert resp.status_code == 200 and resp.json()["status"] == "ordered"
    db_session.expire_all()
    assert db_session.get(ShelfOrder, order["id"]).status == ShelfOrderStatus.ordered


def test_they_can_still_cancel_an_order_for_an_item_now_above_them(client, db_session):
    pro, _, _, order = _skilled_with_a_wish_and_an_order(client, db_session)

    resp = client.post(f"/v1/pro/shelf/orders/{order['id']}/cancel", headers=_h(pro))

    assert resp.status_code == 200 and resp.json()["status"] == "refunded"


def test_a_wished_item_above_the_new_level_is_a_locked_teaser_still_on_the_list(client, db_session):
    pro, wished, ordered, _ = _skilled_with_a_wish_and_an_order(client, db_session)

    level4 = _level(_browse(client, pro), 4)

    assert level4["locked"] is True and level4["unlocks_at_tier"] == "skilled"
    [teaser] = [i for i in level4["items"] if i["id"] == str(wished.id)]
    assert (teaser["locked"], teaser["wished"]) == (True, True)
    assert client.get("/v1/pro/shelf/wishlist", headers=_h(pro)).json()["item_ids"] == [str(wished.id)]
    assert _order(client, pro, wished).status_code == 404, "a locked item cannot be ordered"


def test_a_locked_wish_can_be_taken_off_but_not_put_back(client, db_session):
    pro, wished, _, _ = _skilled_with_a_wish_and_an_order(client, db_session)

    off = client.delete(f"/v1/pro/shelf/wishlist/{wished.id}", headers=_h(pro))
    back = client.put(f"/v1/pro/shelf/wishlist/{wished.id}", headers=_h(pro))

    assert off.status_code == 200 and off.json()["item_ids"] == []
    assert back.status_code == 404
