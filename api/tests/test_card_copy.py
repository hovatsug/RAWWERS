"""The card copy of a portfolio photo (owner, 2026-11-18; built 2026-11-20).

A WebP covering 1200 x 800, made by the same processing job as the other
copies, for every portfolio photo - from the app or published from
Lightroom - and never for a client's proof. A photo is ready only with every
copy it needs. Cards use it, falling back to the web copy, then the
thumbnail. A client cannot fetch it through a booking, and a share link
gives previews only.
"""
import io
import uuid

import pytest
from celery.exceptions import Retry
from PIL import Image
from sqlalchemy import select

import app.tasks.media_tasks as tasks
from app.models.media import MediaAsset, MediaObject, MediaPurpose, MediaStatus, MediaVariant, MediaVisibility, ObjectStatus
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
from app.models.gallery import ProofGalleryItem
from app.services.lightroom_portfolio import LIGHTROOM_NICHE_KEY
from tests.test_photo_processing import _asset, _jpeg, _run, store  # noqa: F401  (fixture)


def _derivatives(db, asset_id) -> dict:
    db.expire_all()
    return {d.kind: d for d in db.execute(select(MediaDerivative).where(MediaDerivative.media_asset_id == asset_id)).scalars()}


def _portfolio(db, store, *, width=3000, height=2000, meta=None):
    asset_id = _asset(db, store, visibility=MediaVisibility.public, purpose=MediaPurpose.portfolio_reel)
    original = db.execute(select(MediaObject).where(MediaObject.media_asset_id == asset_id)).scalar_one()
    store.objects[original.storage_key] = _jpeg(width, height)
    if meta:
        db.get(MediaAsset, asset_id).meta = meta
    db.commit()
    return asset_id


@pytest.mark.parametrize(("size", "card"), [((3000, 2000), (1200, 800)), ((2000, 3000), (1200, 1800)), ((800, 600), (800, 600))])
def test_a_portfolio_upload_gets_a_webp_card_copy_covering_1200_by_800(db_session, store, size, card):
    asset_id = _portfolio(db_session, store, width=size[0], height=size[1])
    _run(asset_id)
    made = _derivatives(db_session, asset_id)
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.ready
    row = made.get(MediaDerivativeKind.card)
    assert row is not None, "a new upload without its card copy"
    assert row.content_type == "image/webp" and row.storage_key.endswith("_card.webp")
    assert (row.width, row.height) == card, "covers the 3:2 card box, never enlarged"
    image = Image.open(io.BytesIO(store.objects[row.storage_key]))
    assert image.format == "WEBP" and image.size == card
    assert row.bytes == len(store.objects[row.storage_key])
    assert {MediaDerivativeKind.web_res, MediaDerivativeKind.thumbnail, MediaDerivativeKind.full_res} <= made.keys(), "the other copies stay"


def test_a_photo_published_from_lightroom_gets_one_too(db_session, store):
    asset_id = _portfolio(db_session, store, meta={LIGHTROOM_NICHE_KEY: "portraits"})
    _run(asset_id)
    assert MediaDerivativeKind.card in _derivatives(db_session, asset_id)


def test_a_clients_proof_never_gets_one(db_session, store):
    """It would be an unwatermarked 1200 px copy of a photo not yet paid for."""
    asset_id = _asset(db_session, store)
    _run(asset_id)
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.ready
    assert MediaDerivativeKind.card not in _derivatives(db_session, asset_id)


def test_a_photo_is_not_ready_without_its_card_copy(db_session, store):
    asset_id = _portfolio(db_session, store)
    store.fail_suffixes = {"_card.webp"}
    with pytest.raises(Retry):
        _run(asset_id, retries=0)
    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.processing
    _run(asset_id, retries=tasks.process_photo_variants.max_retries)
    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.failed, "never shown half-made"


def test_ready_is_refused_when_a_copy_is_missing_whatever_the_cause(db_session, store, monkeypatch):
    """The check itself, not one upload failing: a copy that is simply not
    made (a code change that drops one) keeps the photo from being ready."""
    real = tasks._upsert_derivative

    def skip_web(db, **kwargs):
        if kwargs["kind"] != MediaDerivativeKind.web_res:
            real(db, **kwargs)

    monkeypatch.setattr(tasks, "_upsert_derivative", skip_web)
    asset_id = _portfolio(db_session, store)
    _run(asset_id, retries=tasks.process_photo_variants.max_retries)
    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.failed


def test_an_old_photo_is_repaired_with_the_copies_it_lacks(db_session, store):
    """The backfill's work (and the dev seed's): a ready photo made before
    the card copy existed, or written by the seed with no web copy."""
    asset_id = _portfolio(db_session, store)
    original = db_session.execute(select(MediaObject).where(MediaObject.media_asset_id == asset_id)).scalar_one()
    asset = db_session.get(MediaAsset, asset_id)
    asset.status = MediaStatus.ready
    original.status = ObjectStatus.ready
    db_session.commit()

    made = tasks.ensure_display_copies(db_session, asset)
    db_session.commit()
    assert sorted(made) == ["card", "web_res"]
    assert {MediaDerivativeKind.card, MediaDerivativeKind.web_res} <= _derivatives(db_session, asset_id).keys()
    assert tasks.ensure_display_copies(db_session, db_session.get(MediaAsset, asset_id)) == [], "running it again makes nothing"


@pytest.mark.parametrize(("env", "url"), [
    ("production", "postgresql://u:p@postgres:5432/rawwers"),
    ("staging", "postgresql://u:p@localhost:5432/rawwers"),
    ("development", "postgresql://u:p@db.example.com:5432/rawwers"),
    ("", "postgresql://u:p@localhost:5432/rawwers"),
])
def test_the_backfill_refuses_anything_but_the_local_dev_database(env, url):
    import sys
    from pathlib import Path

    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
    from backfill_card_copies import assert_local_dev_database

    with pytest.raises(RuntimeError, match="Refusing to backfill"):
        assert_local_dev_database(env, url)
    assert_local_dev_database("development", "postgresql://u:p@postgres:5432/rawwers") is None


# --- who may fetch it ---------------------------------------------------------------------------------


def _booking_with_portfolio_photo(client, db_session, monkeypatch):
    """A photographer puts one of their portfolio photos (with a card copy)
    in a client's gallery - add_gallery_items takes any of their own photos."""
    from tests.test_media_rights import _create_gallery, _create_gig, _create_photo_asset

    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    gallery = _create_gallery(db_session, gig)
    asset = _create_photo_asset(db_session, pro_id, with_wm=True)
    asset.purpose = MediaPurpose.portfolio_reel
    db_session.add(MediaDerivative(media_asset_id=asset.id, kind=MediaDerivativeKind.card, storage_key=f"p/{asset.id}_card.webp",
                                   content_type="image/webp", width=1200, height=800, bytes=90_000))
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=1))
    db_session.commit()
    assert client.post(f"/v1/proof-galleries/{gallery.id}/publish", headers={"X-User-Id": pro_id}).status_code == 200
    monkeypatch.setattr("app.api.v1.media_rights.create_presigned_get", lambda key, expires_in=120: f"https://signed/{key}")
    return gig, asset, pro_id, client_id


def test_a_client_cannot_fetch_the_card_copy_through_a_booking(client, db_session, monkeypatch):
    gig, asset, _pro, client_id = _booking_with_portfolio_photo(client, db_session, monkeypatch)
    url = f"/v1/gigs/{gig.id}/media/{asset.id}/signed-url"
    preview = client.get(url, headers={"X-User-Id": client_id}, params={"kind": "preview_watermarked"})
    assert preview.status_code == 200, preview.text
    card = client.get(url, headers={"X-User-Id": client_id}, params={"kind": "card"})
    assert card.status_code == 403, "an unwatermarked copy with no entitlement checked"


def test_a_share_link_gives_previews_only(client, db_session, monkeypatch):
    gig, asset, pro_id, client_id = _booking_with_portfolio_photo(client, db_session, monkeypatch)
    token = client.post(f"/v1/gigs/{gig.id}/share-links", headers={"X-User-Id": pro_id}, json={"scope": "proofs"}).json()["token"]
    url = f"/v1/gigs/{gig.id}/media/{asset.id}/signed-url"
    ok = client.get(url, headers={"X-User-Id": client_id}, params={"kind": "preview_watermarked", "share_token": token})
    assert ok.status_code == 200, ok.text
    for kind in ("full_res", "web_res", "card"):
        refused = client.get(url, headers={"X-User-Id": client_id}, params={"kind": kind, "share_token": token})
        assert refused.status_code == 403, f"a share link fetched the {kind} copy unpaid"
