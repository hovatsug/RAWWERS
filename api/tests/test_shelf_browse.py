"""The Shelf as a photographer sees it (GET /v1/pro/shelf)."""
from sqlalchemy import select

from app.models.niche import SkillTier
from app.models.repair import GearItem
from app.models.shelf import RawwEntryKind
from app.services import raww_ledger as ledger
from app.services.shelf_settings import shelf_settings

from tests.test_shelf_gear_and_wishlist import _cameras, _h, _item, _pro


def _browse(client, pro):
    resp = client.get("/v1/pro/shelf", headers=_h(pro))
    assert resp.status_code == 200, resp.text
    return resp.json()


def _level(body, n):
    return next(level for level in body["levels"] if level["level"] == n)


def test_levels_above_their_tier_are_locked_teasers_that_say_what_unlocks_them(client, db_session):
    pro = _pro(db_session, SkillTier.rookie)
    _item(db_session, level=3, title="Light")
    _item(db_session, level=4, title="Gimbal")
    _item(db_session, level=5, title="Lens")

    body = _browse(client, pro)

    assert (body["tier"], body["max_level"]) == ("rookie", 3)
    assert _level(body, 3)["locked"] is False and _level(body, 3)["items"][0]["locked"] is False
    assert (_level(body, 4)["locked"], _level(body, 4)["unlocks_at_tier"]) == (True, "skilled")
    assert (_level(body, 5)["locked"], _level(body, 5)["unlocks_at_tier"]) == (True, "elite")
    assert _level(body, 5)["items"][0]["title"] == "Lens" and _level(body, 5)["items"][0]["locked"] is True


def test_items_for_cameras_they_do_not_own_are_left_out_and_theirs_come_first(client, db_session):
    _cameras(db_session)
    pro = _pro(db_session)
    db_session.add(GearItem(pro_user_id=pro, category="camera_body", camera_model="ilce7m4", meta={}))
    db_session.commit()
    _item(db_session, title="Card")
    _item(db_session, title="Sony battery", cameras=["ilce7m4"])
    _item(db_session, title="Canon battery", cameras=["eosr6"])

    body = _browse(client, pro)

    titles = [i["title"] for i in _level(body, 1)["items"]]
    assert titles == ["Sony battery", "Card"]
    assert _level(body, 1)["items"][0]["fits_your_gear"] is True
    assert body["has_camera"] is True


def test_with_no_camera_yet_they_see_universal_items_and_the_prompt(client, db_session):
    _cameras(db_session)
    pro = _pro(db_session)
    _item(db_session, title="Card")
    _item(db_session, title="Sony battery", cameras=["ilce7m4"])

    body = _browse(client, pro)

    assert body["has_camera"] is False
    assert [i["title"] for i in _level(body, 1)["items"]] == ["Card"]


def test_each_item_says_if_it_is_wished_for_affordable_and_in_stock(client, db_session):
    pro = _pro(db_session)
    cheap, dear = _item(db_session, title="Cheap"), _item(db_session, title="Dear")
    dear.price_raww = 999
    from app.models.shelf import ShelfStockStatus

    dear.stock_status = ShelfStockStatus.out_of_stock
    db_session.commit()
    ledger.post_entry(db_session, pro_user_id=pro, kind=RawwEntryKind.admin_adjust, amount=200, source_type="admin", source_id="seed", note="seed")
    db_session.commit()
    client.put(f"/v1/pro/shelf/wishlist/{cheap.id}", headers=_h(pro))

    items = {i["title"]: i for i in _level(_browse(client, pro), 1)["items"]}

    assert (items["Cheap"]["wished"], items["Cheap"]["affordable"], items["Cheap"]["in_stock"]) == (True, True, True)
    assert (items["Dear"]["wished"], items["Dear"]["affordable"], items["Dear"]["in_stock"]) == (False, False, False)


def test_hidden_items_never_show(client, db_session):
    pro = _pro(db_session, SkillTier.master)
    _item(db_session, title="Hidden", active=False)
    assert all(not level["items"] for level in _browse(client, pro)["levels"])


def test_the_terms_come_with_the_shelf_marked_draft_until_approved(client, db_session):
    pro = _pro(db_session)
    body = _browse(client, pro)
    assert body["terms_draft"] is True and "DRAFT" in body["terms_text"]


def test_closed_with_the_shelf(client, db_session):
    pro = _pro(db_session)
    shelf_settings(db_session).shelf_enabled = False
    db_session.commit()
    assert client.get("/v1/pro/shelf", headers=_h(pro)).status_code == 403
