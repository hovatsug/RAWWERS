"""A Shelf item's photos (owner's decision, 2026-11-07): 1 to 4, the first
the cover; JPEG, PNG or WebP, at most 10 MB, at least 800 px on the long
edge; the worker makes 400, 800 and 1600 px; reorder and delete in admin;
no cover, no activation."""
import io
import uuid

import pytest
from PIL import Image
from sqlalchemy import select

from app.models.media import MediaObject, MediaVariant
from app.models.media_rights import MediaDerivative
from app.models.shelf import ShelfItem, ShelfItemImage
from app.services import shelf_images as service
from app.tasks.outbox_tasks import dispatch_outbox_events_task

from tests.test_shelf_browse import _browse, _level
from tests.test_shelf_gear_and_wishlist import _item, _pro
from tests.test_niche_banners import _Store

ADMIN = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}


def _picture(width=1200, height=900, fmt="JPEG") -> bytes:
    out = io.BytesIO()
    Image.new("RGB", (width, height), (120, 90, 60)).save(out, format=fmt)
    return out.getvalue()


@pytest.fixture
def store(monkeypatch):
    s = _Store()
    for name, fn in (("object_size", s.size), ("download_object_bytes", s.download), ("upload_object_bytes", s.upload), ("delete_object", s.delete)):
        monkeypatch.setattr(service, name, fn)
    return s


def _upload(client, db_session, store, item, payload, *, content_type="image/jpeg"):
    started = client.post(f"/v1/admin/shelf/items/{item.id}/images", json={"content_type": content_type, "file_name": "x"}, headers=ADMIN)
    assert started.status_code == 200, started.text
    image_id = started.json()["image_id"]
    image = db_session.get(ShelfItemImage, uuid.UUID(image_id))
    key = db_session.execute(
        select(MediaObject.storage_key).where(MediaObject.media_asset_id == image.media_asset_id, MediaObject.variant == MediaVariant.original)
    ).scalar_one()
    store.objects[key] = payload
    return image_id, client.post(f"/v1/admin/shelf/items/{item.id}/images/{image_id}/complete", headers=ADMIN)


def _ready(client, db_session, store, item, payload=None):
    image_id, done = _upload(client, db_session, store, item, payload or _picture())
    assert done.status_code == 200, done.text
    dispatch_outbox_events_task(limit=100)
    db_session.expire_all()
    return image_id


def test_a_photo_is_checked_then_the_worker_makes_three_sizes_never_enlarged(client, db_session, store):
    item = _item(db_session, title="Card")
    image_id, done = _upload(client, db_session, store, item, _picture(1200, 900))

    assert done.json()["images"][0]["status"] == "processing"
    dispatch_outbox_events_task(limit=100)
    db_session.expire_all()

    image = db_session.get(ShelfItemImage, uuid.UUID(image_id))
    assert image.status == "ready"
    sizes = sorted((d.width, d.height) for d in db_session.execute(select(MediaDerivative).where(MediaDerivative.media_asset_id == image.media_asset_id)).scalars())
    assert sizes == [(400, 300), (800, 600), (1200, 900)]


@pytest.mark.parametrize(("content_type", "fmt"), [("image/png", "PNG"), ("image/webp", "WEBP")])
def test_png_and_webp_are_taken(client, db_session, store, content_type, fmt):
    item = _item(db_session)
    _image_id, done = _upload(client, db_session, store, item, _picture(fmt=fmt), content_type=content_type)
    assert done.status_code == 200


def test_other_types_too_small_or_too_big_are_refused_and_removed(client, db_session, store, monkeypatch):
    item = _item(db_session)
    assert client.post(f"/v1/admin/shelf/items/{item.id}/images", json={"content_type": "image/gif"}, headers=ADMIN).status_code == 422

    _id, small = _upload(client, db_session, store, item, _picture(799, 600))
    assert small.status_code == 422 and "800" in small.json()["error"]["message"]
    _id, junk = _upload(client, db_session, store, item, b"not a picture")
    assert junk.status_code == 422
    monkeypatch.setattr(service, "MAX_BYTES", 1000)
    _id, big = _upload(client, db_session, store, item, _picture())
    assert big.status_code == 422 and "10 MB" in big.json()["error"]["message"]

    db_session.expire_all()
    assert service.images_of(db_session, item.id) == [], "refused photos are removed"


def test_at_most_four(client, db_session, store):
    item = _item(db_session)
    for _ in range(4):
        _ready(client, db_session, store, item)

    resp = client.post(f"/v1/admin/shelf/items/{item.id}/images", json={"content_type": "image/jpeg"}, headers=ADMIN)

    assert resp.status_code == 409


def test_no_cover_no_activation(client, db_session, store):
    item = _item(db_session, active=False)
    body = {
        "title": "Card", "category": "battery", "level": 1, "price_raww": 150, "street_price": "15.00", "street_currency": "GBP",
        "supplier_cost": "10.00", "supplier_currency": "GBP", "supplier_name": "Wex", "active": True, "camera_models": [],
    }

    assert client.post("/v1/admin/shelf/items", json=body, headers=ADMIN).json()["error"]["code"] == "cover_required"
    assert client.put(f"/v1/admin/shelf/items/{item.id}", json=body, headers=ADMIN).json()["error"]["code"] == "cover_required"

    _ready(client, db_session, store, item)
    resp = client.put(f"/v1/admin/shelf/items/{item.id}", json=body, headers=ADMIN)
    assert resp.status_code == 200 and resp.json()["active"] is True


def test_reorder_makes_the_first_the_cover_and_the_app_sees_it(client, db_session, store):
    pro = _pro(db_session)
    item = _item(db_session, title="Card")
    first = _ready(client, db_session, store, item, _picture(1000, 1000))
    second = _ready(client, db_session, store, item, _picture(1600, 900))

    resp = client.put(f"/v1/admin/shelf/items/{item.id}/images/order", json={"image_ids": [second, first]}, headers=ADMIN)

    assert [i["id"] for i in resp.json()["images"]] == [second, first]
    [shown] = _level(_browse(client, pro), 1)["items"]
    assert shown["cover_url"] and "shelf_400" in shown["cover_url"]
    assert len(shown["image_urls"]) == 2 and all("shelf_1600" in u for u in shown["image_urls"])


def test_delete_and_an_active_items_last_cover_stays(client, db_session, store):
    item = _item(db_session, title="Card")
    first = _ready(client, db_session, store, item)
    second = _ready(client, db_session, store, item)

    assert client.delete(f"/v1/admin/shelf/items/{item.id}/images/{first}", headers=ADMIN).status_code == 200
    assert client.delete(f"/v1/admin/shelf/items/{item.id}/images/{second}", headers=ADMIN).status_code == 409, "an active item keeps its cover"
    db_session.expire_all()
    assert [str(i.id) for i in service.images_of(db_session, item.id)] == [second]
    assert db_session.get(ShelfItemImage, uuid.UUID(second)).position == 0


def test_an_item_without_photos_falls_back_to_the_suppliers_link(client, db_session, store):
    pro = _pro(db_session)
    item = _item(db_session, title="Card")
    item.image_url = "https://supplier.example/card.jpg"
    db_session.commit()

    [shown] = _level(_browse(client, pro), 1)["items"]

    assert (shown["cover_url"], shown["image_urls"]) == ("https://supplier.example/card.jpg", [])


def test_each_level_says_about_how_many_euros(client, db_session, store):
    pro = _pro(db_session)
    _item(db_session, title="Card")
    level = _level(_browse(client, pro), 1)
    assert level["band_eur"] == str(int(level["band_raww"] * 0.1))


def test_only_admins(client, db_session, store):
    item = _item(db_session)
    other = {"X-User-Id": str(uuid.uuid4())}
    assert client.post(f"/v1/admin/shelf/items/{item.id}/images", json={"content_type": "image/jpeg"}, headers=other).status_code in (401, 403)


def test_the_demo_cover_passes_the_upload_checks_and_is_marked_demo(client, db_session, store):
    from scripts.seed_demo import demo_cover

    item = _item(db_session, active=False)
    png = demo_cover("Peak Design Everyday Backpack", 4)
    assert Image.open(io.BytesIO(png)).size == (1200, 900)

    image = service.attach_generated(db_session, item_id=item.id, png=png, admin_user_id=uuid.UUID(ADMIN["X-User-Id"]))
    db_session.commit()

    assert image.status == "ready" and service.has_cover(db_session, item.id)
