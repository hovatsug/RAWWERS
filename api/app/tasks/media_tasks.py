from __future__ import annotations

import io
import logging
import uuid

from PIL import Image, ImageDraw, ImageFont
from sqlalchemy import select

from app.db.session import SessionLocal
from app.models.media import MediaAsset, MediaObject, MediaStatus, MediaVariant, ObjectStatus
from app.services.storage import download_object_bytes, generate_variant_key, upload_object_bytes
from app.tasks.celery_app import celery_app

logger = logging.getLogger(__name__)


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
        draw = ImageDraw.Draw(wm)
        text = "RAWWERS"
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", max(24, wm.width // 20))
        except OSError:
            font = ImageFont.load_default()
        bbox = draw.textbbox((0, 0), text, font=font)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        pos = (max(12, wm.width - tw - 24), max(12, wm.height - th - 24))
        draw.text(pos, text, fill=(255, 255, 255), font=font)

        wm_key = generate_variant_key(original_obj.storage_key, "watermark_preview")
        wm_bytes = io.BytesIO()
        wm.save(wm_bytes, format="JPEG", quality=85)
        upload_object_bytes(wm_key, wm_bytes.getvalue(), content_type="image/jpeg")

        _upsert_variant(db, asset.id, MediaVariant.thumbnail, thumb_key, thumb.width, thumb.height)
        _upsert_variant(db, asset.id, MediaVariant.watermark_preview, wm_key, wm.width, wm.height)

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
