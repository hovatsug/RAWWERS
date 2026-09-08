"""What a client is actually served while choosing photos.

Three separate failures lived here, all invisible while galleries were only
ever rendered as small thumbnails:

  - the "watermarked preview" was written at the original's full size, so the
    thing handed out before payment was a near-original;
  - the mark was one line of corner text, removed by a crop - and, because no
    font is installed in this image, it was drawn at ~8px and so was not
    really there at all;
  - building the response cost two queries and two signatures per photo.

Each test below fails if its fix is reverted.
"""
import pathlib
import sys
import uuid
from decimal import Decimal

import pytest
from app.models.gallery import ProofGallery, ProofGalleryItem, ProofGalleryStatus
from sqlalchemy import select
from app.models.media import (
    MediaAsset,
    MediaKind,
    MediaProvider,
    MediaPurpose,
    MediaStatus,
    MediaVariant,
    MediaVisibility,
)
from app.services.media_urls import GALLERY_PREVIEW_URL_TTL_SECONDS
from app.tasks.media_tasks import (
    WATERMARK_PREVIEW_MAX_PX,
    _draw_watermark,
    downscale_for_preview,
    watermarked_preview,
)
from PIL import Image, ImageFont

from tests.test_proof_gallery import _create_gig, _create_photo_asset


class _NoProfileDB:
    """_draw_watermark only touches the db to look up a display name."""

    def get(self, *args, **kwargs):
        return None


def _asset(owner: uuid.UUID | None = None) -> MediaAsset:
    return MediaAsset(
        owner_user_id=owner or uuid.uuid4(),
        kind=MediaKind.photo,
        purpose=MediaPurpose.proof,
        provider=MediaProvider.r2,
        status=MediaStatus.ready,
        visibility=MediaVisibility.owner_only,
        meta={},
    )


def _photo(width: int = 4288, height: int = 2848) -> Image.Image:
    """Mid-grey rather than black: a mark has to show on ordinary tones."""
    return Image.new("RGB", (width, height), color=(128, 128, 128))


def _marked_fraction(before: Image.Image, after: Image.Image) -> float:
    """Share of pixels the mark changed."""
    assert before.size == after.size
    b, a = before.tobytes(), after.tobytes()
    changed = sum(1 for i in range(0, len(b), 3) if b[i : i + 3] != a[i : i + 3])
    return changed / (before.width * before.height)


# ---------------------------------------------------------------------------
# The preview is not a near-original.
# ---------------------------------------------------------------------------


def test_preview_is_downscaled_before_the_mark_goes_on():
    source = _photo(4288, 2848)
    preview = watermarked_preview(_NoProfileDB(), _asset(), source, include_powered_by=False)

    assert max(preview.size) <= WATERMARK_PREVIEW_MAX_PX
    assert preview.size == (1600, 1063)
    # The source is left alone - callers still write full_res from it.
    assert source.size == (4288, 2848)


def test_a_small_original_is_not_upscaled():
    preview = downscale_for_preview(_photo(900, 600))
    assert preview.size == (900, 600)


# ---------------------------------------------------------------------------
# The mark is really there, and a crop does not remove it.
# ---------------------------------------------------------------------------


def test_the_mark_covers_the_frame_rather_than_one_corner():
    source = _photo(1600, 1063)
    marked = _draw_watermark(_NoProfileDB(), _asset(), source, include_powered_by=False)

    # The old corner mark changed well under 1% of the frame. A tiled mark
    # covers a real share of it - and it must still leave the photo legible,
    # so this is bounded on both sides.
    fraction = _marked_fraction(source, marked)
    assert 0.05 < fraction < 0.60, f"mark covers {fraction:.1%} of the frame"


def test_every_quadrant_carries_the_mark_so_a_crop_cannot_remove_it():
    source = _photo(1600, 1063)
    marked = _draw_watermark(_NoProfileDB(), _asset(), source, include_powered_by=False)
    w, h = source.size

    quadrants = {
        "top-left": (0, 0, w // 2, h // 2),
        "top-right": (w // 2, 0, w, h // 2),
        "bottom-left": (0, h // 2, w // 2, h),
        "bottom-right": (w // 2, h // 2, w, h),
    }
    for name, box in quadrants.items():
        fraction = _marked_fraction(source.crop(box), marked.crop(box))
        assert fraction > 0.03, f"{name} keeps only {fraction:.1%} of the mark; a crop would strip it"


def test_the_mark_is_drawn_at_a_visible_size_without_system_fonts():
    """The regression that made every watermark ever produced a non-mark.

    No TrueType font is installed in this image, so _load_font always takes
    the fallback. The bare load_default() ignores the requested size and
    renders ~8px text; on a large photo that is a rounding error, not a
    watermark.
    """
    from app.tasks.media_tasks import _FONT_BOLD, _load_font
    from PIL import ImageDraw

    # Guard the premise: if a font package is ever added to the image this
    # test still holds, but it is no longer testing the fallback.
    with pytest.raises(OSError):
        ImageFont.truetype(_FONT_BOLD, 120)

    font = _load_font(_FONT_BOLD, 120)
    measure = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    box = measure.textbbox((0, 0), "RAWWERS", font=font)
    assert box[2] - box[0] > 300, "requested a 120px font and got a bitmap fallback"


# ---------------------------------------------------------------------------
# One response, a fixed number of queries.
# ---------------------------------------------------------------------------


def _published_gallery(db_session, client_id: str, pro_id: str, photo_count: int):
    gig = _create_gig(db_session, client_id, pro_id)
    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=uuid.UUID(pro_id),
        client_user_id=uuid.UUID(client_id),
        included_photos=10,
        extra_photo_price=Decimal("10.00"),
        currency="EUR",
        status=ProofGalleryStatus.published,
    )
    db_session.add(gallery)
    db_session.flush()
    for i in range(photo_count):
        asset = _create_photo_asset(db_session, pro_id, with_wm=True)
        db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=i + 1))
    db_session.commit()
    return gallery


def _count_queries(db_session):
    """Count statements issued through the request's session.

    Deliberately hooked on the Session rather than the Engine: an
    engine-level `before_cursor_execute` listener registered mid-test never
    fires, because SQLAlchemy resolves a Connection's event dispatch when the
    connection is created and the pool hands back one that predates the
    listener. That form silently counted zero for both galleries, which made
    this check pass against the very code it exists to reject.
    """
    from sqlalchemy import event

    counter = [0]

    def _on_execute(orm_execute_state):
        counter[0] += 1

    event.listen(db_session, "do_orm_execute", _on_execute)
    return counter, lambda: event.remove(db_session, "do_orm_execute", _on_execute)


def test_gallery_response_cost_does_not_grow_with_the_number_of_photos(client, db_session):
    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    small = _published_gallery(db_session, client_id, pro_id, photo_count=3)
    large = _published_gallery(db_session, client_id, pro_id, photo_count=18)

    counter, stop = _count_queries(db_session)
    try:
        counter[0] = 0
        assert client.get(f"/v1/proof-galleries/{small.id}", headers={"X-User-Id": client_id}).status_code == 200
        small_queries = counter[0]

        counter[0] = 0
        assert client.get(f"/v1/proof-galleries/{large.id}", headers={"X-User-Id": client_id}).status_code == 200
        large_queries = counter[0]
    finally:
        stop()

    # Six times the photos must not mean six times the queries. The old form
    # ran two per item, so this gap was 30 queries wide.
    assert large_queries - small_queries <= 2, (
        f"3 photos cost {small_queries} queries, 18 cost {large_queries}: still per-item"
    )


def test_gallery_urls_outlive_a_real_selection_sitting(client, db_session):
    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    gallery = _published_gallery(db_session, client_id, pro_id, photo_count=2)

    body = client.get(f"/v1/proof-galleries/{gallery.id}", headers={"X-User-Id": client_id}).json()
    assert body["items"], "no items to check"
    for item in body["items"]:
        for url in (item["thumbnail_url"], item["watermark_preview_url"]):
            assert url is not None
            assert f"X-Amz-Expires={GALLERY_PREVIEW_URL_TTL_SECONDS}" in url

    assert GALLERY_PREVIEW_URL_TTL_SECONDS >= 1800, "a 200-photo review outlives a short window"


def test_a_failed_asset_does_not_vanish_from_a_published_gallery(client, db_session):
    """The pro attached it and the client is mid-selection.

    Batching the URL lookup introduced a filter the per-item form did not
    have. An asset marked `failed` by a later re-run of process_photo_variants
    still has the ready objects the gallery was built on, so it must still
    render rather than silently disappearing from the grid.
    """
    from app.models.media import MediaAsset, MediaStatus

    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    gallery = _published_gallery(db_session, client_id, pro_id, photo_count=2)

    item = db_session.execute(
        select(ProofGalleryItem).where(ProofGalleryItem.gallery_id == gallery.id)
    ).scalars().first()
    asset = db_session.get(MediaAsset, item.media_asset_id)
    asset.status = MediaStatus.failed
    db_session.commit()

    body = client.get(f"/v1/proof-galleries/{gallery.id}", headers={"X-User-Id": client_id}).json()
    shown = {i["media_asset_id"]: i for i in body["items"]}
    assert str(asset.id) in shown, "the photo dropped out of the gallery"
    assert shown[str(asset.id)]["watermark_preview_url"] is not None


def test_the_backfill_refuses_to_write_over_an_original(db_session):
    """The one irreversible thing the backfill could do.

    `_upsert_derivative` stores the full_res derivative under the original's
    own storage key, so a full_res row and an original MediaObject share a
    key. If the backfill's filter ever widened to include full_res - or a
    preview row ever carried such a key - it would overwrite the
    photographer's master file, which is not recoverable. The guard has to be
    structural rather than a comment about the current query.
    """
    import uuid as _uuid

    from app.models.media import MediaObject, MediaVariant, ObjectStatus
    from app.models.media_rights import MediaDerivative, MediaDerivativeKind

    # Resolved from this file, not the working directory, so the test does
    # not depend on where pytest was invoked from.
    sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / "scripts"))
    from backfill_watermark_previews import _protected_keys

    owner = str(_uuid.uuid4())
    asset = _create_photo_asset(db_session, owner, with_wm=True)
    original = db_session.execute(
        select(MediaObject).where(
            MediaObject.media_asset_id == asset.id,
            MediaObject.variant == MediaVariant.original,
        )
    ).scalar_one()

    # The schema fact that makes the guard necessary.
    db_session.add(
        MediaDerivative(
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.full_res,
            storage_key=original.storage_key,
            content_type="image/jpeg",
            width=4288,
            height=2848,
            bytes=1234,
        )
    )
    db_session.add(
        MediaDerivative(
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.preview_watermarked,
            storage_key=f"{original.storage_key}_preview_watermarked.jpg",
            content_type="image/jpeg",
            width=4288,
            height=2848,
            bytes=1234,
        )
    )
    db_session.commit()

    protected = _protected_keys(db_session)
    assert original.storage_key in protected, "the original is writable - the backfill could destroy it"
    assert f"{original.storage_key}_preview_watermarked.jpg" not in protected, (
        "the preview is protected too, so the backfill could never do its job"
    )
