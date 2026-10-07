from __future__ import annotations

import io
import logging
import functools
import math
import uuid
from concurrent.futures import ThreadPoolExecutor

from PIL import Image, ImageDraw, ImageFont
from sqlalchemy import select

from app.core.config import get_settings
from app.db.session import SessionLocal
from app.models.admin import ProProfile
from app.models.media import MediaAsset, MediaObject, MediaStatus, MediaVariant, ObjectStatus
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
from app.services.storage import (
    derivative_cache_control,
    download_object_bytes,
    generate_variant_key,
    upload_object_bytes,
)
from app.tasks.celery_app import celery_app

logger = logging.getLogger(__name__)
settings = get_settings()


#: Waits before each retry of a photo whose processing failed: almost always a
#: dropped connection to R2, which a minute later is usually back.
_RETRY_DELAYS_SECONDS = (10, 30, 90)


@celery_app.task(name="app.tasks.media_tasks.process_photo_variants", bind=True, max_retries=len(_RETRY_DELAYS_SECONDS))
def process_photo_variants(self, media_asset_id: str) -> None:
    db = SessionLocal()
    try:
        asset = db.get(MediaAsset, uuid.UUID(media_asset_id))
        if not asset:
            logger.error("media_asset_not_found", extra={"media_asset_id": media_asset_id})
            return

        original_obj = db.execute(
            select(MediaObject).where(
                MediaObject.media_asset_id == asset.id,
                MediaObject.variant == MediaVariant.original,
            )
        ).scalar_one_or_none()

        if not original_obj:
            asset.status = MediaStatus.failed
            asset.meta = {**asset.meta, "failure_reason": "Missing original object"}
            db.commit()
            return

        blob = download_object_bytes(original_obj.storage_key)
        image = Image.open(io.BytesIO(blob)).convert("RGB")

        # The watermarked preview first, and on its own: it is the one variant
        # delivery waits for (a gallery item needs a ready watermark_preview),
        # and it used to become usable only after all four derivatives had
        # been made and uploaded one after another. Committing its row now
        # lets the photo attach while the rest are still being made.
        wm = watermarked_preview(db, asset, image, include_powered_by=False)
        wm_key = generate_variant_key(original_obj.storage_key, "watermark_preview")
        wm_bytes = io.BytesIO()
        wm.save(wm_bytes, format="JPEG", quality=85)
        upload_object_bytes(wm_key, wm_bytes.getvalue(), content_type="image/jpeg", cache_control=derivative_cache_control(asset.visibility))
        _upsert_variant(db, asset.id, MediaVariant.watermark_preview, wm_key, wm.width, wm.height)
        # In the same commit, the full_res row: once a photo can join a
        # gallery its final must be downloadable, and this row is only a
        # pointer to the original, already in R2 - nothing to upload. Written
        # at the end instead, a failure in between left a photo a client
        # could select and pay for, with no final to download.
        _upsert_derivative(
            db,
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.full_res,
            storage_key=original_obj.storage_key,
            content_type=asset.content_type or "image/jpeg",
            width=image.width,
            height=image.height,
            bytes_size=asset.byte_size,
        )
        db.commit()

        thumb = image.copy()
        thumb.thumbnail((512, 512))
        thumb_key = generate_variant_key(original_obj.storage_key, "thumbnail")
        thumb_bytes = io.BytesIO()
        thumb.save(thumb_bytes, format="JPEG", quality=85)

        wm_share = watermarked_preview(db, asset, image, include_powered_by=True)
        wm_share_key = generate_variant_key(original_obj.storage_key, "preview_watermarked")
        wm_share_bytes = io.BytesIO()
        wm_share.save(wm_share_bytes, format="JPEG", quality=85)

        web = image.copy()
        if web.width > 2048:
            web.thumbnail((2048, 2048))
        web_key = generate_variant_key(original_obj.storage_key, "web_res")
        web_bytes = io.BytesIO()
        web.save(web_bytes, format="JPEG", quality=88)

        # The other three go up together rather than one after another: each
        # is a separate round trip to R2, and none depends on another.
        _upload_all(
            [
                (thumb_key, thumb_bytes.getvalue()),
                (wm_share_key, wm_share_bytes.getvalue()),
                (web_key, web_bytes.getvalue()),
            ],
            cache_control=derivative_cache_control(asset.visibility),
        )

        _upsert_variant(db, asset.id, MediaVariant.thumbnail, thumb_key, thumb.width, thumb.height)

        _upsert_derivative(
            db,
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.thumbnail,
            storage_key=thumb_key,
            content_type="image/jpeg",
            width=thumb.width,
            height=thumb.height,
            bytes_size=len(thumb_bytes.getvalue()),
        )
        _upsert_derivative(
            db,
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.preview_watermarked,
            storage_key=wm_share_key,
            content_type="image/jpeg",
            width=wm_share.width,
            height=wm_share.height,
            bytes_size=len(wm_share_bytes.getvalue()),
        )
        _upsert_derivative(
            db,
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.web_res,
            storage_key=web_key,
            content_type="image/jpeg",
            width=web.width,
            height=web.height,
            bytes_size=len(web_bytes.getvalue()),
        )
        original_obj.status = ObjectStatus.ready
        asset.status = MediaStatus.ready
        db.commit()
    except Exception as exc:
        db.rollback()
        if self.request.retries < self.max_retries:
            logger.warning(
                "process_photo_variants_retrying",
                extra={"media_asset_id": media_asset_id, "attempt": self.request.retries + 1, "error": str(exc)},
            )
            raise self.retry(exc=exc, countdown=_RETRY_DELAYS_SECONDS[self.request.retries])
        asset = db.get(MediaAsset, uuid.UUID(media_asset_id))
        if asset:
            asset.status = MediaStatus.failed
            asset.meta = {**asset.meta, "failure_reason": str(exc)}
            db.commit()
        logger.exception("process_photo_variants_failed", extra={"media_asset_id": media_asset_id})
    finally:
        db.close()


def _upload_all(objects: list[tuple[str, bytes]], cache_control: str) -> None:
    """Upload several derivatives at once; raises if any upload failed."""
    with ThreadPoolExecutor(max_workers=len(objects)) as pool:
        for future in [pool.submit(upload_object_bytes, key, payload, "image/jpeg", cache_control) for key, payload in objects]:
            future.result()


@celery_app.task(name="app.tasks.media_tasks.generate_media_derivative")
def generate_media_derivative_task(media_asset_id: str, kind: str) -> None:
    db = SessionLocal()
    try:
        asset = db.get(MediaAsset, uuid.UUID(media_asset_id))
        if not asset:
            return
        if kind == MediaDerivativeKind.preview_watermarked.value:
            generate_watermarked_preview(media_asset_id)
            return
        if kind == MediaDerivativeKind.web_res.value:
            generate_web_res(media_asset_id)
            return
        if kind == MediaDerivativeKind.thumbnail.value:
            generate_thumbnail(media_asset_id)
            return
        if kind == MediaDerivativeKind.full_res.value:
            generate_full_res(media_asset_id)
            return
    finally:
        db.close()


def generate_watermarked_preview(media_asset_id: str) -> None:
    db = SessionLocal()
    try:
        asset, original_obj, image = _load_source_image(db, media_asset_id)
        if not asset or not original_obj or image is None:
            return
        wm = watermarked_preview(db, asset, image, include_powered_by=True)

        wm_key = generate_variant_key(original_obj.storage_key, "preview_watermarked")
        wm_bytes = io.BytesIO()
        wm.save(wm_bytes, format="JPEG", quality=85)
        payload = wm_bytes.getvalue()
        upload_object_bytes(wm_key, payload, content_type="image/jpeg", cache_control=derivative_cache_control(asset.visibility))

        _upsert_derivative(
            db,
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.preview_watermarked,
            storage_key=wm_key,
            content_type="image/jpeg",
            width=wm.width,
            height=wm.height,
            bytes_size=len(payload),
        )
        db.commit()
    except Exception:
        db.rollback()
        logger.exception("generate_watermarked_preview_failed", extra={"media_asset_id": media_asset_id})
    finally:
        db.close()


def generate_web_res(media_asset_id: str) -> None:
    db = SessionLocal()
    try:
        asset, original_obj, image = _load_source_image(db, media_asset_id)
        if not asset or not original_obj or image is None:
            return
        web = image.copy()
        if web.width > 2048:
            web.thumbnail((2048, 2048))

        web_key = generate_variant_key(original_obj.storage_key, "web_res")
        web_bytes = io.BytesIO()
        web.save(web_bytes, format="JPEG", quality=88)
        payload = web_bytes.getvalue()
        upload_object_bytes(web_key, payload, content_type="image/jpeg", cache_control=derivative_cache_control(asset.visibility))

        _upsert_derivative(
            db,
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.web_res,
            storage_key=web_key,
            content_type="image/jpeg",
            width=web.width,
            height=web.height,
            bytes_size=len(payload),
        )
        db.commit()
    except Exception:
        db.rollback()
        logger.exception("generate_web_res_failed", extra={"media_asset_id": media_asset_id})
    finally:
        db.close()


def generate_thumbnail(media_asset_id: str) -> None:
    db = SessionLocal()
    try:
        asset, original_obj, image = _load_source_image(db, media_asset_id)
        if not asset or not original_obj or image is None:
            return
        thumb = image.copy()
        thumb.thumbnail((512, 512))

        thumb_key = generate_variant_key(original_obj.storage_key, "thumbnail")
        thumb_bytes = io.BytesIO()
        thumb.save(thumb_bytes, format="JPEG", quality=85)
        payload = thumb_bytes.getvalue()
        upload_object_bytes(thumb_key, payload, content_type="image/jpeg", cache_control=derivative_cache_control(asset.visibility))

        _upsert_derivative(
            db,
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.thumbnail,
            storage_key=thumb_key,
            content_type="image/jpeg",
            width=thumb.width,
            height=thumb.height,
            bytes_size=len(payload),
        )
        db.commit()
    except Exception:
        db.rollback()
        logger.exception("generate_thumbnail_failed", extra={"media_asset_id": media_asset_id})
    finally:
        db.close()


def generate_full_res(media_asset_id: str) -> None:
    db = SessionLocal()
    try:
        asset = db.get(MediaAsset, uuid.UUID(media_asset_id))
        if not asset:
            return
        original_obj = db.execute(
            select(MediaObject).where(
                MediaObject.media_asset_id == asset.id,
                MediaObject.variant == MediaVariant.original,
            )
        ).scalar_one_or_none()
        if not original_obj:
            return

        _upsert_derivative(
            db,
            media_asset_id=asset.id,
            kind=MediaDerivativeKind.full_res,
            storage_key=original_obj.storage_key,
            content_type=asset.content_type or "image/jpeg",
            width=original_obj.width,
            height=original_obj.height,
            bytes_size=asset.byte_size,
        )
        db.commit()
    except Exception:
        db.rollback()
        logger.exception("generate_full_res_failed", extra={"media_asset_id": media_asset_id})
    finally:
        db.close()


def _load_source_image(db, media_asset_id: str):
    asset = db.get(MediaAsset, uuid.UUID(media_asset_id))
    if not asset:
        return None, None, None
    original_obj = db.execute(
        select(MediaObject).where(
            MediaObject.media_asset_id == asset.id,
            MediaObject.variant == MediaVariant.original,
        )
    ).scalar_one_or_none()
    if not original_obj:
        return asset, None, None
    blob = download_object_bytes(original_obj.storage_key)
    image = Image.open(io.BytesIO(blob)).convert("RGB")
    return asset, original_obj, image


# Previews are downscaled before the mark goes on. A watermarked preview used
# to be written at the original's full size - 4288px wide for a modern body -
# so the "preview" a client browsed before paying was a near-original with a
# label on it. 1600px is enough to judge a photograph on any phone or laptop
# and is not a deliverable. `web_res` (2048px) stays larger because it is only
# ever served once the client holds the entitlement for it.
WATERMARK_PREVIEW_MAX_PX = 1600

# The mark is tiled across the whole frame at an angle rather than set once in
# a corner, because a corner mark is removed by a crop and the crop costs the
# thief almost nothing. Rows are offset by half a step so no crop can land
# between them, and the angle stops the text being sliced off along a single
# horizontal band.
_WATERMARK_ANGLE = 30
_WATERMARK_FILL_ALPHA = 68
_WATERMARK_STROKE_ALPHA = 52

_FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
_FONT_REGULAR = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"


def _load_font(path: str, size: int):
    """A font at `size`, whether or not the image ships system fonts.

    The bare `ImageFont.load_default()` this used to fall back to ignores
    `size` and renders a ~8px bitmap face: on a 4288px photo that is a 50px
    line of text, which is why the corner mark was effectively invisible in
    every image the pipeline has ever produced. No font package is installed
    in this image, so that fallback was the only path ever taken. Pillow's
    default face is scalable when a size is passed, so the fallback now
    produces a mark of the intended size rather than a silent non-mark.
    """
    try:
        return ImageFont.truetype(path, size)
    except OSError:
        return ImageFont.load_default(size=size)


def _watermark_text(db, asset: MediaAsset) -> str:
    text = settings.media_watermark_text_template or "RAWWERS"
    if settings.media_watermark_include_pro_name:
        profile = db.get(ProProfile, asset.owner_user_id)
        display = profile.display_name if profile and profile.display_name else None
        if display:
            text = f"RAWWERS \u2022 {display}"
    return text


def downscale_for_preview(image: Image.Image) -> Image.Image:
    """A copy bounded to WATERMARK_PREVIEW_MAX_PX on its long edge."""
    preview = image.copy()
    if max(preview.width, preview.height) > WATERMARK_PREVIEW_MAX_PX:
        preview.thumbnail((WATERMARK_PREVIEW_MAX_PX, WATERMARK_PREVIEW_MAX_PX))
    return preview


@functools.lru_cache(maxsize=4)
def _watermark_layer(text: str, width: int, height: int) -> Image.Image:
    """The repeating mark for one text at one image size, ready to composite.

    Cached because it depends on nothing else: drawing the tiles and rotating
    a layer the size of the image's diagonal was most of the CPU a photo
    cost, and it was done twice per photo (the plain preview and the
    "Powered by" one) and again for every photo of the same size from the
    same photographer. Callers composite onto it and never modify it.
    Four entries is a few photographers or orientations at once, about 7 MB
    each at preview size.
    """
    font_size = max(16, width // 30)
    font = _load_font(_FONT_BOLD, font_size)
    measure = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
    bbox = measure.textbbox((0, 0), text, font=font)
    text_w, text_h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    step_x = text_w + int(text_w * 0.6)
    step_y = text_h + int(text_h * 3.5)
    # The layer is squared off at the image's diagonal so that rotating it and
    # cropping back to size never exposes an unmarked corner.
    span = int(math.hypot(width, height)) + step_x + step_y
    layer = Image.new("RGBA", (span, span), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    stroke = max(1, font_size // 24)
    for row, y in enumerate(range(0, span, step_y)):
        offset = (row % 2) * (step_x // 2)
        for x in range(-step_x, span, step_x):
            draw.text(
                (x + offset, y),
                text,
                font=font,
                fill=(255, 255, 255, _WATERMARK_FILL_ALPHA),
                stroke_width=stroke,
                stroke_fill=(0, 0, 0, _WATERMARK_STROKE_ALPHA),
            )
    layer = layer.rotate(_WATERMARK_ANGLE, resample=Image.BICUBIC)
    left, top = (span - width) // 2, (span - height) // 2
    return layer.crop((left, top, left + width, top + height))


def _draw_watermark(db, asset: MediaAsset, image: Image.Image, *, include_powered_by: bool) -> Image.Image:
    """Return `image` with the repeating mark composited over it.

    Returns a new image rather than mutating in place: compositing a
    translucent layer is not a draw operation on the original pixels.
    """
    text = _watermark_text(db, asset)
    base = image.convert("RGBA")
    width, height = base.size
    layer = _watermark_layer(text, width, height)
    marked = Image.alpha_composite(base, layer)

    if include_powered_by:
        footer_text = "Powered by RAWWERS"
        footer_font = _load_font(_FONT_REGULAR, max(14, width // 56))
        footer_draw = ImageDraw.Draw(marked)
        footer_bbox = footer_draw.textbbox((0, 0), footer_text, font=footer_font)
        fw, fh = footer_bbox[2] - footer_bbox[0], footer_bbox[3] - footer_bbox[1]
        pad_x = max(16, int(width * 0.02))
        pad_y = max(16, int(height * 0.02))
        footer_draw.text(
            (max(12, width - fw - pad_x), max(12, height - fh - pad_y)),
            footer_text,
            fill=(245, 245, 245, 235),
            font=footer_font,
            stroke_width=max(1, fh // 12),
            stroke_fill=(0, 0, 0, 120),
        )

    return marked.convert("RGB")


def watermarked_preview(db, asset: MediaAsset, image: Image.Image, *, include_powered_by: bool) -> Image.Image:
    """Downscale first, then mark. The order matters: marking a 4288px image
    and shipping it is the bug this pair exists to prevent."""
    return _draw_watermark(db, asset, downscale_for_preview(image), include_powered_by=include_powered_by)


def _upsert_variant(
    db,
    media_asset_id: uuid.UUID,
    variant: MediaVariant,
    storage_key: str,
    width: int,
    height: int,
) -> None:
    obj = db.execute(
        select(MediaObject).where(MediaObject.media_asset_id == media_asset_id, MediaObject.variant == variant)
    ).scalar_one_or_none()
    if not obj:
        obj = MediaObject(
            media_asset_id=media_asset_id,
            variant=variant,
            storage_key=storage_key,
            width=width,
            height=height,
            status=ObjectStatus.ready,
        )
        db.add(obj)
    else:
        obj.storage_key = storage_key
        obj.width = width
        obj.height = height
        obj.status = ObjectStatus.ready


def _upsert_derivative(
    db,
    *,
    media_asset_id: uuid.UUID,
    kind: MediaDerivativeKind,
    storage_key: str,
    content_type: str,
    width: int | None,
    height: int | None,
    bytes_size: int | None,
) -> None:
    row = db.execute(
        select(MediaDerivative).where(MediaDerivative.media_asset_id == media_asset_id, MediaDerivative.kind == kind)
    ).scalar_one_or_none()
    if row is None:
        row = MediaDerivative(
            media_asset_id=media_asset_id,
            kind=kind,
            storage_key=storage_key,
            content_type=content_type,
            width=width,
            height=height,
            bytes=bytes_size,
        )
        db.add(row)
        return

    row.storage_key = storage_key
    row.content_type = content_type
    row.width = width
    row.height = height
    row.bytes = bytes_size
