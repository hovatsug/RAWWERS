from __future__ import annotations

import io
import logging
import uuid

from PIL import Image, ImageDraw, ImageFont
from sqlalchemy import select

from app.core.config import get_settings
from app.db.session import SessionLocal
from app.models.admin import ProProfile
from app.models.media import MediaAsset, MediaObject, MediaStatus, MediaVariant, ObjectStatus
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
from app.services.storage import download_object_bytes, generate_variant_key, upload_object_bytes
from app.tasks.celery_app import celery_app

logger = logging.getLogger(__name__)
settings = get_settings()


@celery_app.task(name="app.tasks.media_tasks.process_photo_variants")
def process_photo_variants(media_asset_id: str) -> None:
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

        thumb = image.copy()
        thumb.thumbnail((512, 512))
        thumb_key = generate_variant_key(original_obj.storage_key, "thumbnail")
        thumb_bytes = io.BytesIO()
        thumb.save(thumb_bytes, format="JPEG", quality=85)
        upload_object_bytes(thumb_key, thumb_bytes.getvalue(), content_type="image/jpeg")

        wm = image.copy()
        _draw_watermark(db, asset, wm, include_powered_by=False)
        wm_key = generate_variant_key(original_obj.storage_key, "watermark_preview")
        wm_bytes = io.BytesIO()
        wm.save(wm_bytes, format="JPEG", quality=85)
        upload_object_bytes(wm_key, wm_bytes.getvalue(), content_type="image/jpeg")

        wm_share = image.copy()
        _draw_watermark(db, asset, wm_share, include_powered_by=True)
        wm_share_key = generate_variant_key(original_obj.storage_key, "preview_watermarked")
        wm_share_bytes = io.BytesIO()
        wm_share.save(wm_share_bytes, format="JPEG", quality=85)
        upload_object_bytes(wm_share_key, wm_share_bytes.getvalue(), content_type="image/jpeg")

        web = image.copy()
        if web.width > 2048:
            web.thumbnail((2048, 2048))
        web_key = generate_variant_key(original_obj.storage_key, "web_res")
        web_bytes = io.BytesIO()
        web.save(web_bytes, format="JPEG", quality=88)
        upload_object_bytes(web_key, web_bytes.getvalue(), content_type="image/jpeg")

        _upsert_variant(db, asset.id, MediaVariant.thumbnail, thumb_key, thumb.width, thumb.height)
        _upsert_variant(db, asset.id, MediaVariant.watermark_preview, wm_key, wm.width, wm.height)

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

        original_obj.status = ObjectStatus.ready
        asset.status = MediaStatus.ready
        db.commit()
    except Exception as exc:
        db.rollback()
        asset = db.get(MediaAsset, uuid.UUID(media_asset_id))
        if asset:
            asset.status = MediaStatus.failed
            asset.meta = {**asset.meta, "failure_reason": str(exc)}
            db.commit()
        logger.exception("process_photo_variants_failed", extra={"media_asset_id": media_asset_id})
    finally:
        db.close()


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
        wm = image.copy()
        _draw_watermark(db, asset, wm, include_powered_by=True)

        wm_key = generate_variant_key(original_obj.storage_key, "preview_watermarked")
        wm_bytes = io.BytesIO()
        wm.save(wm_bytes, format="JPEG", quality=85)
        payload = wm_bytes.getvalue()
        upload_object_bytes(wm_key, payload, content_type="image/jpeg")

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
        upload_object_bytes(web_key, payload, content_type="image/jpeg")

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
        upload_object_bytes(thumb_key, payload, content_type="image/jpeg")

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


def _draw_watermark(db, asset: MediaAsset, image: Image.Image, *, include_powered_by: bool) -> None:
    draw = ImageDraw.Draw(image)
    text = settings.media_watermark_text_template or "RAWWERS"
    if settings.media_watermark_include_pro_name:
        profile = db.get(ProProfile, asset.owner_user_id)
        display = profile.display_name if profile and profile.display_name else None
        if display:
            text = f"RAWWERS • {display}"

    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", max(24, image.width // 22))
    except OSError:
        font = ImageFont.load_default()
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]

    pad_x = max(16, int(image.width * 0.02))
    pad_y = max(16, int(image.height * 0.02))
    x = max(12, image.width - tw - pad_x)
    y = max(12, image.height - th - pad_y)
    draw.text((x, y), text, fill=(255, 255, 255), font=font)

    if include_powered_by:
        footer_text = "Powered by RAWWERS"
        try:
            footer_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", max(14, image.width // 56))
        except OSError:
            footer_font = ImageFont.load_default()
        footer_bbox = draw.textbbox((0, 0), footer_text, font=footer_font)
        fw, fh = footer_bbox[2] - footer_bbox[0], footer_bbox[3] - footer_bbox[1]
        fx = max(12, image.width - fw - pad_x)
        fy = max(12, image.height - fh - pad_y // 3)
        draw.text((fx, fy), footer_text, fill=(245, 245, 245), font=footer_font)


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
