"""A content pack's cover and previews are the creator's own uploads (ownership audit 2026-11-18).

The pack routes kept any media id they were sent. Another photographer's
photo named in a pack is also "used in a content pack", which stopped its
real owner from removing it from their portfolio (lightroom_portfolio.depended_on).
"""

import uuid

from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.models.studioverse import ContentPack
from tests.test_studioverse_v1 import _seed_approved_pro


def _asset(db, owner: uuid.UUID, *, status=MediaStatus.ready, kind=MediaKind.photo) -> uuid.UUID:
    asset = MediaAsset(
        owner_user_id=owner,
        kind=kind,
        purpose=MediaPurpose.portfolio_reel,
        provider=MediaProvider.r2,
        status=status,
        visibility=MediaVisibility.public,
        meta={},
    )
    db.add(asset)
    db.commit()
    return asset.id


def _pair(db):
    creator, other = str(uuid.uuid4()), str(uuid.uuid4())
    _seed_approved_pro(db, creator)
    _seed_approved_pro(db, other)
    return creator, other


def _create(client, creator, **media):
    body = {
        "title": "Preset Bundle",
        "description": "Curated presets",
        "category": "preset",
        "price_eur": "15.00",
        "currency": "EUR",
        "pack_file_storage_key": "studioverse/packs/preset-bundle.zip",
        "license_code": "standard_commercial",
        "sources": [],
        **{k: (str(v) if isinstance(v, uuid.UUID) else [str(i) for i in v]) for k, v in media.items()},
    }
    return client.post("/v1/studioverse/packs", headers={"X-User-Id": creator}, json=body)


def _packs_of(db, creator) -> int:
    return db.query(ContentPack).filter(ContentPack.creator_user_id == uuid.UUID(creator)).count()


def test_own_cover_and_previews_are_kept(client, db_session):
    creator, _ = _pair(db_session)
    cover, preview = _asset(db_session, uuid.UUID(creator)), _asset(db_session, uuid.UUID(creator))
    resp = _create(client, creator, cover_media_asset_id=cover, preview_media_asset_ids=[preview])
    assert resp.status_code == 200, resp.text
    assert resp.json()["cover_media_asset_id"] == str(cover)
    assert resp.json()["preview_media_asset_ids"] == [str(preview)]


def test_another_photographers_photo_cannot_be_the_cover(client, db_session):
    creator, other = _pair(db_session)
    theirs = _asset(db_session, uuid.UUID(other))
    resp = _create(client, creator, cover_media_asset_id=theirs)
    assert resp.status_code == 404, resp.text
    assert _packs_of(db_session, creator) == 0


def test_another_photographers_photo_cannot_be_a_preview(client, db_session):
    creator, other = _pair(db_session)
    mine, theirs = _asset(db_session, uuid.UUID(creator)), _asset(db_session, uuid.UUID(other))
    resp = _create(client, creator, preview_media_asset_ids=[mine, theirs])
    assert resp.status_code == 404, resp.text
    assert _packs_of(db_session, creator) == 0


def test_an_unknown_or_removed_upload_is_refused(client, db_session):
    creator, _ = _pair(db_session)
    removed = _asset(db_session, uuid.UUID(creator), status=MediaStatus.deleted)
    assert _create(client, creator, cover_media_asset_id=uuid.uuid4()).status_code == 404
    assert _create(client, creator, preview_media_asset_ids=[removed]).status_code == 404


def test_the_cover_is_a_photo(client, db_session):
    creator, _ = _pair(db_session)
    video = _asset(db_session, uuid.UUID(creator), kind=MediaKind.video)
    assert _create(client, creator, cover_media_asset_id=video).status_code == 422


def test_an_update_cannot_name_another_photographers_photo(client, db_session):
    creator, other = _pair(db_session)
    mine, theirs = _asset(db_session, uuid.UUID(creator)), _asset(db_session, uuid.UUID(other))
    pack_id = _create(client, creator, cover_media_asset_id=mine).json()["id"]

    for body in ({"cover_media_asset_id": str(theirs)}, {"preview_media_asset_ids": [str(theirs)]}):
        resp = client.put(f"/v1/studioverse/packs/{pack_id}", headers={"X-User-Id": creator}, json=body)
        assert resp.status_code == 404, resp.text

    db_session.expire_all()
    pack = db_session.get(ContentPack, uuid.UUID(pack_id))
    assert pack.cover_media_asset_id == mine
    assert not pack.preview_media_asset_ids

    second = _asset(db_session, uuid.UUID(creator))
    resp = client.put(
        f"/v1/studioverse/packs/{pack_id}", headers={"X-User-Id": creator},
        json={"cover_media_asset_id": str(second), "preview_media_asset_ids": [str(mine)]},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["cover_media_asset_id"] == str(second)
