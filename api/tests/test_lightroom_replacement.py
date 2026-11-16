"""What the automatic removal of an edited photo's old version can reach (1.2.4).

When a photo is edited in Lightroom and published again, the new version is
uploaded and the old one goes. Since 1.2.4 the server removes it itself when
the new one is finished, and only if it is, all at once: the same
photographer's, published from Lightroom, in the same niche, the same
Lightroom photo (same key; or, for a photo from before keys, the one
Lightroom names), on the server, and used by nothing else (the cover, a gig
gallery, a client's selection, a banner, any row pointing at it).
"""
import hashlib
import uuid
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models.admin import ProProfile
from app.models.gallery import ProofGallery, ProofGalleryItem, ProofGalleryStatus
from app.models.gig import Gig, GigStatus
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.services import rate_limit
from tests.test_delivery_gigs import _pro, _token
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)
from tests.test_lightroom_portfolio import _niches, two_niches  # noqa: F401  (fixture)

V = "1.2.4"
KEY = "lr:UUID-P1:collection-1"


@pytest.fixture(autouse=True)
def generous_limits(monkeypatch):
    for name in ("uploads", "auth_mutation", "delivery_token_daily", "plugin_portfolio_uploads"):
        monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, name, (100_000, 3600))


def _h(token):
    return {"Authorization": f"Bearer {token}", "X-Rawwers-Plugin-Version": V}


def _sha(text):
    return hashlib.sha256(text.encode()).hexdigest()


def _publish(client, token, slug, *, picture, key=KEY, previous_id=None, ready=True, db_session=None):
    body = {"file_name": "P1.jpg", "content_type": "image/jpeg", "byte_size": 400_000, "sha256": _sha(picture + " file"),
            "image_sha256": _sha(picture), "niche_slug": slug}
    if key:
        body["publish_key"] = key
    if previous_id:
        body["previous_id"] = str(previous_id)
    started = client.post("/v1/delivery/portfolio/uploads", headers=_h(token), json=body)
    assert started.status_code == 200, started.text
    started = started.json()
    finished = client.post(f"/v1/delivery/uploads/{started['media_asset_id']}/complete", headers=_h(token),
                           json={"byte_size": 400_000, "sha256": _sha(picture + " file")})
    assert finished.status_code == 200, finished.text
    if ready and db_session is not None:
        asset = db_session.get(MediaAsset, uuid.UUID(started["media_asset_id"]))
        db_session.refresh(asset)
        asset.status = MediaStatus.ready
        db_session.commit()
    return started, finished.json()


def _status(db_session, asset_id):
    db_session.expire_all()
    return db_session.get(MediaAsset, uuid.UUID(str(asset_id))).status


def _setup(client, db_session, niches):
    pro = _pro(db_session)
    _niches(db_session, pro, niches[0], niches[1], primary=niches[0])
    return pro, _token(client, pro)


def test_an_edit_replaces_its_old_version_when_the_new_one_is_finished(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    v1, _ = _publish(client, token, two_niches[0], picture="v1", db_session=db_session)
    started = client.post("/v1/delivery/portfolio/uploads", headers=_h(token), json={
        "file_name": "P1.jpg", "content_type": "image/jpeg", "byte_size": 400_000, "sha256": _sha("v2 file"),
        "image_sha256": _sha("v2"), "niche_slug": two_niches[0], "publish_key": KEY, "previous_id": v1["media_asset_id"]}).json()
    assert started["replaces"] == v1["media_asset_id"]
    assert _status(db_session, v1["media_asset_id"]) == MediaStatus.ready, "removed before the new version was in"
    finished = client.post(f"/v1/delivery/uploads/{started['media_asset_id']}/complete", headers=_h(token),
                           json={"byte_size": 400_000, "sha256": _sha("v2 file")}).json()
    assert finished["replaced"] == v1["media_asset_id"]
    assert _status(db_session, v1["media_asset_id"]) == MediaStatus.deleted


def test_another_photographers_photo_is_never_removed(client, db_session, two_niches):
    _pro_a, token_a = _setup(client, db_session, two_niches)
    _pro_b, token_b = _setup(client, db_session, two_niches)
    theirs, _ = _publish(client, token_b, two_niches[0], picture="theirs", db_session=db_session)
    _publish(client, token_a, two_niches[0], picture="mine v1", db_session=db_session)
    started, finished = _publish(client, token_a, two_niches[0], picture="mine v2", previous_id=theirs["media_asset_id"], db_session=db_session)
    assert finished["replaced"] != theirs["media_asset_id"]
    assert _status(db_session, theirs["media_asset_id"]) == MediaStatus.ready


def test_a_different_lightroom_photo_is_never_removed(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    other, _ = _publish(client, token, two_niches[0], picture="other photo", key="lr:UUID-P2:collection-1", db_session=db_session)
    _started, finished = _publish(client, token, two_niches[0], picture="p1 v1", previous_id=other["media_asset_id"], db_session=db_session)
    assert finished["replaced"] is None
    assert _status(db_session, other["media_asset_id"]) == MediaStatus.ready


def test_a_photo_in_another_niche_is_never_removed(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    elsewhere, _ = _publish(client, token, two_niches[1], picture="p1 v1", db_session=db_session)
    _started, finished = _publish(client, token, two_niches[0], picture="p1 v2", previous_id=elsewhere["media_asset_id"], db_session=db_session)
    assert finished["replaced"] is None
    assert _status(db_session, elsewhere["media_asset_id"]) == MediaStatus.ready


def _deliver_to_a_client(db_session, pro, asset_id):
    gig = Gig(client_user_id=uuid.uuid4(), pro_user_id=pro, status=GigStatus.paid, currency="EUR",
              amount_minimum=Decimal("100.00"), amount_platform_fee=Decimal("20.00"), amount_pro_gross=Decimal("80.00"), meta={})
    db_session.add(gig)
    db_session.flush()
    gallery = ProofGallery(gig_id=gig.id, pro_user_id=pro, client_user_id=gig.client_user_id, included_photos=10,
                           extra_photo_price=Decimal("5.00"), currency="EUR", status=ProofGalleryStatus.published)
    db_session.add(gallery)
    db_session.flush()
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=uuid.UUID(str(asset_id)), sort_order=1))
    db_session.commit()


def test_a_photo_a_client_can_see_through_a_delivery_is_kept_and_said_so(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    v1, _ = _publish(client, token, two_niches[0], picture="v1", db_session=db_session)
    _deliver_to_a_client(db_session, pro, v1["media_asset_id"])
    _started, finished = _publish(client, token, two_niches[0], picture="v2", previous_id=v1["media_asset_id"], db_session=db_session)
    assert finished["replaced"] is None
    assert "kept" in (finished["old_kept"] or _started.get("old_kept") or "")
    assert _status(db_session, v1["media_asset_id"]) == MediaStatus.ready


def test_the_cover_is_kept_even_if_it_became_the_cover_after_the_start(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    v1, _ = _publish(client, token, two_niches[0], picture="v1", db_session=db_session)
    started = client.post("/v1/delivery/portfolio/uploads", headers=_h(token), json={
        "file_name": "P1.jpg", "content_type": "image/jpeg", "byte_size": 400_000, "sha256": _sha("v2 file"),
        "image_sha256": _sha("v2"), "niche_slug": two_niches[0], "publish_key": KEY, "previous_id": v1["media_asset_id"]}).json()
    db_session.get(ProProfile, pro).cover_media_asset_id = uuid.UUID(v1["media_asset_id"])
    db_session.commit()
    finished = client.post(f"/v1/delivery/uploads/{started['media_asset_id']}/complete", headers=_h(token),
                           json={"byte_size": 400_000, "sha256": _sha("v2 file")}).json()
    assert finished["replaced"] is None and "profile cover" in finished["old_kept"]
    assert _status(db_session, v1["media_asset_id"]) == MediaStatus.ready


def test_a_photo_from_before_keys_is_replaced_only_when_lightroom_names_it(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    legacy, _ = _publish(client, token, two_niches[0], picture="legacy v1", key=None, db_session=db_session)
    other_legacy, _ = _publish(client, token, two_niches[0], picture="another legacy", key=None, db_session=db_session)
    _started, finished = _publish(client, token, two_niches[0], picture="legacy v2", previous_id=legacy["media_asset_id"], db_session=db_session)
    assert finished["replaced"] == legacy["media_asset_id"]
    assert _status(db_session, other_legacy["media_asset_id"]) == MediaStatus.ready


def test_a_photo_added_in_the_app_is_never_removed(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    app_photo = MediaAsset(owner_user_id=pro, kind=MediaKind.photo, purpose=MediaPurpose.portfolio_reel, provider=MediaProvider.r2,
                           status=MediaStatus.ready, visibility=MediaVisibility.public, niche_tags=[two_niches[0]], meta={})
    db_session.add(app_photo)
    db_session.commit()
    _started, finished = _publish(client, token, two_niches[0], picture="v1", previous_id=app_photo.id, db_session=db_session)
    assert finished["replaced"] is None
    assert _status(db_session, app_photo.id) == MediaStatus.ready


def test_a_delivery_photo_is_never_removed_by_a_portfolio_publish(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    v1, _ = _publish(client, token, two_niches[0], picture="v1", db_session=db_session)
    asset = db_session.get(MediaAsset, uuid.UUID(v1["media_asset_id"]))
    asset.delivery_gallery_id = None
    asset.purpose = MediaPurpose.proof
    db_session.commit()
    _started, finished = _publish(client, token, two_niches[0], picture="v2", previous_id=v1["media_asset_id"], db_session=db_session)
    assert finished["replaced"] is None
    assert _status(db_session, v1["media_asset_id"]) == MediaStatus.ready


def test_removing_a_photo_a_client_can_see_is_refused_in_plain_words(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    v1, _ = _publish(client, token, two_niches[0], picture="v1", db_session=db_session)
    _deliver_to_a_client(db_session, pro, v1["media_asset_id"])
    refused = client.delete(f"/v1/delivery/portfolio/{v1['media_asset_id']}", headers=_h(token))
    assert refused.status_code == 409 and "kept in your portfolio" in refused.json()["error"]["message"]
    assert _status(db_session, v1["media_asset_id"]) == MediaStatus.ready
