"""Which image a photographer's cover is sent as, and its shape (cover follow-up 2026-11-18).

The Discover card, the listing preview and the client profile header span
the phone's width: they get the 2048 px web copy (the card had the 512 px
thumbnail, soft at 3x; the header had the original, many times larger). A
home tile is small and keeps the thumbnail. Each carries the photo's width
and height so the app leans a portrait's crop up; both are optional, so an
app that does not know them keeps working, and a photo whose size was never
recorded is sent without them.
"""

import uuid

from app.api.v1.client_launch import _with_niche_cover
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
from app.models.media import MediaObject, MediaVariant
from app.schemas.client_launch import ClientDiscoverCard
from app.services.media_urls import resolve_niche_cover_images, resolve_sized_image_urls
from tests.test_client_launch import _enable_city_and_flags
from tests.test_profile_cover import _city, _main, _photo, _preview, _pro
from tests.test_profile_cover import generous_limits, no_storage_deletes  # noqa: F401  (autouse fixtures)
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)


def _sized(db, asset_id, *, width, height, web=True):
    """The shapes processing records: the thumbnail's, and the web copy's."""
    thumb = db.query(MediaObject).filter_by(media_asset_id=asset_id, variant=MediaVariant.thumbnail).one()
    scale = 512 / max(width, height)
    thumb.width, thumb.height = round(width * scale), round(height * scale)
    if web:
        db.add(MediaDerivative(media_asset_id=asset_id, kind=MediaDerivativeKind.web_res, storage_key=f"p/{asset_id}/w.jpg",
                               content_type="image/jpeg", bytes=400_000, width=width, height=height))
    db.commit()


def _discover_card(client, pro, city):
    answer = client.get("/v1/client/discover", params={"country": "PT", "city": city, "niche_slug": "portraits"})
    assert answer.status_code == 200, answer.text
    return next(c for c in answer.json()["items"] if c["pro_user_id"] == str(pro))


def _live(db):
    _enable_city_and_flags(db, city=(city := _city()), country="PT")
    pro = _pro(db, city=city)
    _main(db, pro, "portraits")
    return pro, city


def test_the_discover_card_uses_the_web_copy_with_the_photo_shape(client, db_session):
    pro, city = _live(db_session)
    photo = _photo(db_session, pro)
    _sized(db_session, photo, width=1702, height=2550)
    card = _discover_card(client, pro, city)
    assert f"p/{photo}/w.jpg" in card["cover_url"], "the card still sends the 512 px thumbnail"
    assert (card["cover_width"], card["cover_height"]) == (1702, 2550)


def test_without_a_web_copy_the_card_falls_back_to_the_thumbnail(client, db_session):
    pro, city = _live(db_session)
    photo = _photo(db_session, pro)
    _sized(db_session, photo, width=3000, height=2000, web=False)
    card = _discover_card(client, pro, city)
    assert f"p/{photo}/t.jpg" in card["cover_url"]
    assert (card["cover_width"], card["cover_height"]) == (512, 341)


def test_a_photo_without_a_recorded_size_is_sent_without_one(client, db_session):
    pro, city = _live(db_session)
    photo = _photo(db_session, pro)
    card = _discover_card(client, pro, city)
    assert f"p/{photo}/t.jpg" in card["cover_url"]
    assert card["cover_width"] is None and card["cover_height"] is None


def test_the_listing_preview_is_the_discover_card(client, db_session):
    pro, _ = _live(db_session)
    photo = _photo(db_session, pro)
    _sized(db_session, photo, width=1702, height=2550)
    card = _preview(client, pro)["card"]
    assert f"p/{photo}/w.jpg" in card["cover_url"]
    assert (card["cover_width"], card["cover_height"]) == (1702, 2550)


def test_the_profile_header_uses_the_web_copy_not_the_original(client, db_session):
    pro, city = _live(db_session)
    photo = _photo(db_session, pro)
    _sized(db_session, photo, width=2048, height=1365)
    from app.models.admin import UserRoleType
    from tests.test_client_launch import _seed_user

    viewer = str(uuid.uuid4())
    _seed_user(db_session, viewer, [UserRoleType.client])
    profile = client.get(f"/v1/client/pros/{pro}", params={"country": "PT", "city": city}, headers={"X-User-Id": viewer}).json()
    assert f"p/{photo}/w.jpg" in profile["cover_url"], "the header still sends the original"
    assert (profile["cover_width"], profile["cover_height"]) == (2048, 1365)


def test_a_home_tile_keeps_the_thumbnail_with_its_own_photo_shape(db_session):
    pro = _pro(db_session)
    landscape = _photo(db_session, pro, minutes=0, tags=("portraits",))
    portrait = _photo(db_session, pro, minutes=5, tags=("portraits",))
    _sized(db_session, landscape, width=3000, height=2000)
    _sized(db_session, portrait, width=1702, height=2550)
    image = resolve_niche_cover_images(db_session, [pro], niche_slug="portraits")[pro]
    assert f"p/{portrait}/t.jpg" in image.url, "a tile is small: the thumbnail"
    assert (image.width, image.height) == (1702, 2550), "the shape of the photo the tile shows"


def test_a_tile_showing_a_niche_photo_carries_that_photos_shape():
    card = ClientDiscoverCard(
        pro_user_id=(pro := uuid.uuid4()), currency="GBP", avg_rating=0, review_count=0, portfolio_photo_count=1, portfolio_video_count=0,
        cover_url="https://x/cover", cover_width=3000, cover_height=2000,
    )
    from app.services.media_urls import SizedImage

    shown = _with_niche_cover(card, {pro: SizedImage("https://x/niche", 1702, 2550)})
    assert (shown.cover_url, shown.cover_width, shown.cover_height) == ("https://x/niche", 1702, 2550)
    assert _with_niche_cover(card, {}) is card


def test_the_sized_resolver_skips_what_is_not_ready(db_session):
    pro = _pro(db_session)
    processing = _photo(db_session, pro, objects_ready=False)
    assert resolve_sized_image_urls(db_session, [processing, None], sharp=True) == {}
