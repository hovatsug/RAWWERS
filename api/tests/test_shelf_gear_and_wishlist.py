"""My gear's link to the camera catalogue, and the wish list."""
import threading
import time
import uuid
from datetime import datetime, timezone

from sqlalchemy import func, select

from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.gear_verification import CameraModelReference, SensorSize
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.repair import GearItem
from app.models.shelf import ShelfItem, ShelfItemCompat, ShelfWishlistItem
from app.services import shelf_wishlist
from app.services.shelf_browse import can_see
from app.services.shelf_settings import shelf_settings

from tests.conftest import TestingSessionLocal


def _pro(db, tier: SkillTier | None = None) -> uuid.UUID:
    pro = uuid.uuid4()
    db.add(UserAccount(user_id=pro))
    db.flush()
    db.add(ProProfile(user_id=pro, display_name="Pro", city="London", country="GB"))
    db.add(UserRole(user_id=pro, role=UserRoleType.pro))
    if tier is not None:
        niche = db.execute(select(Niche)).scalars().first()
        db.add(ProNicheSkill(pro_user_id=pro, niche_id=niche.id, tier=tier))
    db.commit()
    return pro


def _cameras(db):
    for key, name in (("ilce7m4", "Sony A7 IV"), ("eosr6", "Canon EOS R6")):
        if db.get(CameraModelReference, key) is None:
            db.add(CameraModelReference(normalised_model=key, make=name.split()[0], display_name=name, sensor_size=SensorSize.full_frame, updated_at=datetime.now(timezone.utc)))
    db.commit()


def _item(db, *, level=1, cameras=(), active=True, title="Item") -> ShelfItem:
    item = ShelfItem(
        title=title, category="battery", level=level, price_raww=150, street_price=15, street_currency="GBP",
        supplier_cost=10, supplier_currency="GBP", supplier_name="Wex", active=active,
    )
    db.add(item)
    db.flush()
    for model in cameras:
        db.add(ShelfItemCompat(item_id=item.id, camera_model=model))
    db.commit()
    return item


def _h(pro):
    return {"X-User-Id": str(pro)}


# --- My gear ---------------------------------------------------------------------------------


def test_a_body_picked_from_the_catalogue_is_linked(client, db_session):
    _cameras(db_session)
    pro = _pro(db_session)

    resp = client.post("/v1/pro/me/gear-items", headers=_h(pro), json={"category": "camera_body", "brand": "Sony", "model": "A7 IV", "camera_model": "ilce7m4"})

    assert resp.status_code == 200, resp.text
    assert resp.json()["camera_model"] == "ilce7m4"


def test_a_body_typed_by_hand_is_linked_when_it_matches_the_catalogue(client, db_session):
    _cameras(db_session)
    pro = _pro(db_session)

    typed = client.post("/v1/pro/me/gear-items", headers=_h(pro), json={"category": "camera_body", "model": "ILCE-7M4"}).json()
    unknown = client.post("/v1/pro/me/gear-items", headers=_h(pro), json={"category": "camera_body", "model": "My old Leica"}).json()
    lens = client.post("/v1/pro/me/gear-items", headers=_h(pro), json={"category": "lens", "model": "ILCE-7M4"}).json()

    assert typed["camera_model"] == "ilce7m4"
    assert unknown["camera_model"] is None, "free text is still allowed"
    assert lens["camera_model"] is None, "only bodies are matched"


def test_a_camera_not_in_the_catalogue_cannot_be_picked(client, db_session):
    pro = _pro(db_session)
    resp = client.post("/v1/pro/me/gear-items", headers=_h(pro), json={"category": "camera_body", "camera_model": "nikonz9"})
    assert resp.status_code == 422


def test_changing_the_model_text_moves_the_link_with_it(client, db_session):
    _cameras(db_session)
    pro = _pro(db_session)
    item = client.post("/v1/pro/me/gear-items", headers=_h(pro), json={"category": "camera_body", "camera_model": "ilce7m4"}).json()

    moved = client.put(f"/v1/pro/me/gear-items/{item['id']}", headers=_h(pro), json={"model": "EOS R6"}).json()
    kept = client.put(f"/v1/pro/me/gear-items/{item['id']}", headers=_h(pro), json={"notes": "second body"}).json()

    assert moved["camera_model"] == "eosr6"
    assert kept["camera_model"] == "eosr6"


def test_the_catalogue_can_be_searched_by_name_or_model_code(client, db_session):
    _cameras(db_session)
    pro = _pro(db_session)

    by_name = client.get("/v1/pro/shelf/camera-models", headers=_h(pro), params={"q": "a7 iv"}).json()["items"]
    by_code = client.get("/v1/pro/shelf/camera-models", headers=_h(pro), params={"q": "ILCE-7M4"}).json()["items"]

    assert [i["normalised_model"] for i in by_name] == ["ilce7m4"]
    assert [i["display_name"] for i in by_code] == ["Sony A7 IV"]


# --- seeing items ----------------------------------------------------------------------------


def test_the_best_tier_decides_the_highest_level(db_session):
    rookie, master, untiered = _pro(db_session, SkillTier.rookie), _pro(db_session, SkillTier.master), _pro(db_session)
    level4, level5 = _item(db_session, level=4), _item(db_session, level=5)

    assert not can_see(db_session, rookie, level4)
    assert can_see(db_session, master, level5)
    assert not can_see(db_session, untiered, level4), "no tier yet counts as rookie (levels 1-3)"
    shelf_settings(db_session).tier_max_level = {**shelf_settings(db_session).tier_max_level, "rookie": 4}
    assert can_see(db_session, rookie, level4)


def test_an_item_for_some_cameras_is_seen_only_by_their_owners(db_session):
    _cameras(db_session)
    owner, other = _pro(db_session), _pro(db_session)
    db_session.add(GearItem(pro_user_id=owner, category="camera_body", camera_model="ilce7m4", meta={}))
    db_session.commit()
    battery, card = _item(db_session, cameras=["ilce7m4"]), _item(db_session)

    assert can_see(db_session, owner, battery) and not can_see(db_session, other, battery)
    assert can_see(db_session, other, card), "an item with no cameras fits everyone"


def test_a_hidden_item_is_seen_by_no_one(db_session):
    pro = _pro(db_session, SkillTier.master)
    assert not can_see(db_session, pro, _item(db_session, active=False))


# --- the wish list ---------------------------------------------------------------------------


def test_the_wish_list_adds_removes_and_stops_at_its_size(client, db_session):
    pro = _pro(db_session)
    items = [_item(db_session, title=f"Item {n}") for n in range(4)]

    for item in items[:3]:
        assert client.put(f"/v1/pro/shelf/wishlist/{item.id}", headers=_h(pro)).status_code == 200
    again = client.put(f"/v1/pro/shelf/wishlist/{items[0].id}", headers=_h(pro))
    full = client.put(f"/v1/pro/shelf/wishlist/{items[3].id}", headers=_h(pro))

    assert again.status_code == 200 and len(again.json()["item_ids"]) == 3, "the same item twice is one entry"
    assert full.status_code == 409 and full.json()["error"]["code"] == "wishlist_full"
    after = client.delete(f"/v1/pro/shelf/wishlist/{items[0].id}", headers=_h(pro)).json()
    assert len(after["item_ids"]) == 2 and after["limit"] == 3


def test_an_item_they_cannot_see_cannot_be_wished_for(client, db_session):
    _cameras(db_session)
    pro = _pro(db_session, SkillTier.rookie)
    for item in (_item(db_session, level=5), _item(db_session, cameras=["eosr6"]), _item(db_session, active=False)):
        assert client.put(f"/v1/pro/shelf/wishlist/{item.id}", headers=_h(pro)).status_code == 404


def test_the_wish_list_is_closed_with_the_shelf(client, db_session):
    pro = _pro(db_session)
    item = _item(db_session)
    shelf_settings(db_session).shelf_enabled = False
    db_session.commit()

    assert client.put(f"/v1/pro/shelf/wishlist/{item.id}", headers=_h(pro)).status_code == 403


def test_two_taps_at_once_cannot_overfill_the_wish_list():
    setup = TestingSessionLocal()
    try:
        pro = _pro(setup)
        items = [_item(setup, title=f"Item {n}").id for n in range(4)]
        for item_id in items[:2]:
            shelf_wishlist.add(setup, pro_user_id=pro, item_id=item_id, can_see=lambda _: True)
        setup.commit()
    finally:
        setup.close()

    held, other = TestingSessionLocal(), TestingSessionLocal()
    outcome = {}

    def second():
        try:
            shelf_wishlist.add(other, pro_user_id=pro, item_id=items[3], can_see=lambda _: True)
            other.commit()
            outcome["second"] = "added"
        except Exception as error:  # noqa: BLE001
            other.rollback()
            outcome["second"] = getattr(error, "code", repr(error))

    try:
        shelf_wishlist.add(held, pro_user_id=pro, item_id=items[2], can_see=lambda _: True)
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
        count = check.execute(select(func.count()).select_from(ShelfWishlistItem).where(ShelfWishlistItem.pro_user_id == pro)).scalar_one()
    finally:
        check.close()
    assert outcome["second"] == "wishlist_full"
    assert count == 3
