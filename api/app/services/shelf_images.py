"""A Shelf item's photos (owner's decision, 2026-11-07).

Each item has 1 to 4 photos; the first is its cover, and an item cannot be
active without one. An admin uploads them the way niche banners are
uploaded (a presigned PUT to storage, then "complete"), and the upload is
checked: JPEG, PNG or WebP, at most 10 MB, at least 800 px on the long
edge. The worker then makes three sizes, 400, 800 and 1600 px on the long
edge (never enlarged), as public JPEGs: the card shows 400, the detail's
gallery 1600. Photos can be reordered and deleted.
"""
from __future__ import annotations

import io
import uuid
from dataclasses import dataclass

from PIL import Image, ImageOps, UnidentifiedImageError
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaProvider, MediaPurpose, MediaStatus, MediaVariant, MediaVisibility, ObjectStatus
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
from app.models.shelf import ShelfItem, ShelfItemImage
from app.services.storage import (
    delete_object,
    derivative_cache_control,
    download_object_bytes,
    generate_variant_key,
    object_size,
    stable_presigned_gets,
    upload_object_bytes,
)

MAX_IMAGES = 4
MAX_BYTES = 10 * 1024 * 1024
MIN_LONG_EDGE = 800
TYPES = {"image/jpeg": "JPEG", "image/png": "PNG", "image/webp": "WEBP"}
SIZES = ((MediaDerivativeKind.shelf_400, 400), (MediaDerivativeKind.shelf_800, 800), (MediaDerivativeKind.shelf_1600, 1600))
#: How long an image URL handed to an app or the admin stays valid.
URL_TTL_SECONDS = 6 * 3600


def _fail(message: str, status_code: int = 422, code: str = "validation_error") -> APIError:
    return APIError(code=code, message=message, status_code=status_code)


def _item(db: Session, item_id: uuid.UUID) -> ShelfItem:
    item = db.get(ShelfItem, item_id)
    if item is None:
        raise _fail("Item not found", 404, "not_found")
    return item


def images_of(db: Session, item_id: uuid.UUID) -> list[ShelfItemImage]:
    return list(
        db.execute(
            select(ShelfItemImage).where(ShelfItemImage.item_id == item_id).order_by(ShelfItemImage.position, ShelfItemImage.created_at)
        ).scalars()
    )


def has_cover(db: Session, item_id: uuid.UUID) -> bool:
    """A ready photo in first place."""
    first = next(iter(images_of(db, item_id)), None)
    return first is not None and first.status == "ready"


def start(db: Session, *, item_id: uuid.UUID, admin_user_id: uuid.UUID, content_type: str, file_name: str | None):
    """(image, upload instructions) for one more photo of this item."""
    from app.services.photo_uploads import begin_photo_upload

    item = _item(db, item_id)
    if (content_type or "").lower() not in TYPES:
        raise _fail("A photo must be a JPEG, PNG or WebP image.")
    if len(images_of(db, item.id)) >= MAX_IMAGES:
        raise _fail(f"An item has at most {MAX_IMAGES} photos. Delete one to add another.", 409, "invalid_state")
    asset, started = begin_photo_upload(
        db, owner_user_id=admin_user_id, purpose=MediaPurpose.shelf_item, visibility=MediaVisibility.public,
        content_type=content_type.lower(), file_name=file_name,
    )
    position = (db.execute(select(func.max(ShelfItemImage.position)).where(ShelfItemImage.item_id == item.id)).scalar_one() or -1) + 1
    image = ShelfItemImage(item_id=item.id, media_asset_id=asset.id, position=position, status="uploading")
    db.add(image)
    db.flush()
    return image, started


def _original(db: Session, asset_id: uuid.UUID) -> MediaObject:
    return db.execute(
        select(MediaObject).where(MediaObject.media_asset_id == asset_id, MediaObject.variant == MediaVariant.original)
    ).scalar_one()


def complete(db: Session, *, item_id: uuid.UUID, image_id: uuid.UUID) -> ShelfItemImage:
    """Check what arrived; the worker makes the sizes. A refused file is
    deleted and its photo removed, with the reason."""
    from app.services.outbox import enqueue_outbox_event

    image = db.get(ShelfItemImage, image_id)
    if image is None or image.item_id != item_id:
        raise _fail("Photo not found", 404, "not_found")
    if image.status != "uploading":
        raise _fail("This photo has already been completed", 409, "invalid_state")
    asset = db.get(MediaAsset, image.media_asset_id)
    original = _original(db, asset.id)

    def refuse(message: str) -> APIError:
        delete_object(original.storage_key)
        asset.status = MediaStatus.failed
        db.delete(image)
        db.commit()
        return _fail(message)

    size = object_size(original.storage_key)
    if size is None:
        raise _fail("The file has not been uploaded yet.")
    if size > MAX_BYTES:
        raise refuse(f"The photo is {size / 1024 / 1024:.1f} MB; the limit is 10 MB.")
    try:
        picture = Image.open(io.BytesIO(download_object_bytes(original.storage_key, max_bytes=MAX_BYTES + 1)))
        picture.load()
    except (UnidentifiedImageError, OSError):
        raise refuse("This file is not a JPEG, PNG or WebP image.") from None
    if picture.format not in TYPES.values():
        raise refuse("This file is not a JPEG, PNG or WebP image.")
    picture = ImageOps.exif_transpose(picture)
    if max(picture.width, picture.height) < MIN_LONG_EDGE:
        raise refuse(f"The photo is {picture.width}×{picture.height} pixels; its long edge must be at least {MIN_LONG_EDGE}.")

    original.status = ObjectStatus.ready
    asset.byte_size = size
    image.width, image.height = picture.width, picture.height
    image.status = "processing"
    enqueue_outbox_event(
        db, topic="shelf.image.process", payload={"image_id": str(image.id)},
        idempotency_key=f"shelf-image:{image.id}", idempotency_scope="shelf_images",
    )
    db.flush()
    return image


def process(db: Session, image_id: uuid.UUID) -> None:
    """The worker's part: the three sizes, never enlarged. Once."""
    image = db.get(ShelfItemImage, image_id)
    if image is None or image.status != "processing":
        return
    asset = db.get(MediaAsset, image.media_asset_id)
    original = _original(db, asset.id)
    try:
        picture = ImageOps.exif_transpose(Image.open(io.BytesIO(download_object_bytes(original.storage_key, max_bytes=MAX_BYTES + 1))))
        picture = picture.convert("RGB")
        cache = derivative_cache_control(MediaVisibility.public)
        for kind, edge in SIZES:
            copy = picture.copy()
            copy.thumbnail((edge, edge), Image.LANCZOS)
            out = io.BytesIO()
            copy.save(out, format="JPEG", quality=85)
            payload = out.getvalue()
            key = generate_variant_key(original.storage_key, kind.value)
            upload_object_bytes(key, payload, "image/jpeg", cache)
            db.add(MediaDerivative(media_asset_id=asset.id, kind=kind, storage_key=key, content_type="image/jpeg",
                                   width=copy.width, height=copy.height, bytes=len(payload)))
    except Exception as exc:  # a photo that cannot be sized is marked, not retried forever
        image.status = "failed"
        image.failure_reason = f"{type(exc).__name__}"
        asset.status = MediaStatus.failed
        db.flush()
        return
    image.status = "ready"
    asset.status = MediaStatus.ready
    db.flush()


def reorder(db: Session, *, item_id: uuid.UUID, image_ids: list[uuid.UUID]) -> list[ShelfItemImage]:
    """Put the photos in this order; the first becomes the cover."""
    current = images_of(db, _item(db, item_id).id)
    if sorted(map(str, image_ids)) != sorted(str(i.id) for i in current):
        raise _fail("Give every photo of this item, each once")
    by_id = {i.id: i for i in current}
    for position, image_id in enumerate(image_ids):
        by_id[image_id].position = position
    db.flush()
    return images_of(db, item_id)


def remove(db: Session, *, item_id: uuid.UUID, image_id: uuid.UUID) -> None:
    """Delete a photo and its files. An active item keeps a cover: the last
    ready photo of an active item cannot go."""
    item = _item(db, item_id)
    image = db.get(ShelfItemImage, image_id)
    if image is None or image.item_id != item.id:
        raise _fail("Photo not found", 404, "not_found")
    others_ready = [i for i in images_of(db, item.id) if i.id != image.id and i.status == "ready"]
    if item.active and image.status == "ready" and not others_ready:
        raise _fail("An active item needs a cover. Add another photo, or deactivate the item first.", 409, "invalid_state")
    keys = [d.storage_key for d in db.execute(select(MediaDerivative).where(MediaDerivative.media_asset_id == image.media_asset_id)).scalars()]
    keys.append(_original(db, image.media_asset_id).storage_key)
    for key in keys:
        try:
            delete_object(key)
        except Exception:
            pass  # a file left behind costs storage, not correctness
    db.delete(image)
    db.flush()
    for position, rest in enumerate(images_of(db, item.id)):
        rest.position = position
    db.flush()


@dataclass
class ImageUrls:
    id: uuid.UUID
    status: str
    small: str | None
    medium: str | None
    large: str | None


def urls_for(db: Session, item_ids: list[uuid.UUID], *, ready_only: bool = True) -> dict[uuid.UUID, list[ImageUrls]]:
    """Each item's photos in order, with signed URLs for their three sizes."""
    images = db.execute(
        select(ShelfItemImage)
        .where(ShelfItemImage.item_id.in_(item_ids or [uuid.uuid4()]))
        .order_by(ShelfItemImage.item_id, ShelfItemImage.position, ShelfItemImage.created_at)
    ).scalars().all()
    if ready_only:
        images = [i for i in images if i.status == "ready"]
    derivatives = db.execute(
        select(MediaDerivative.media_asset_id, MediaDerivative.kind, MediaDerivative.storage_key).where(
            MediaDerivative.media_asset_id.in_([i.media_asset_id for i in images] or [uuid.uuid4()]),
            MediaDerivative.kind.in_([k for k, _ in SIZES]),
        )
    ).all()
    signed = stable_presigned_gets((key for _, _, key in derivatives), URL_TTL_SECONDS)
    by_asset: dict[uuid.UUID, dict[str, str]] = {}
    for asset_id, kind, key in derivatives:
        if key in signed:
            by_asset.setdefault(asset_id, {})[MediaDerivativeKind(kind).value] = signed[key]
    out: dict[uuid.UUID, list[ImageUrls]] = {i: [] for i in item_ids}
    for image in images:
        sizes = by_asset.get(image.media_asset_id, {})
        out.setdefault(image.item_id, []).append(
            ImageUrls(image.id, image.status, sizes.get("shelf_400"), sizes.get("shelf_800"), sizes.get("shelf_1600"))
        )
    return out


def attach_generated(db: Session, *, item_id: uuid.UUID, png: bytes, admin_user_id: uuid.UUID) -> ShelfItemImage:
    """A photo made here rather than uploaded (the demo seed's placeholders):
    stored as an original, then sized like any other."""
    from app.services.storage import generate_photo_storage_key

    key = generate_photo_storage_key(str(admin_user_id), "demo.png")
    upload_object_bytes(key, png, "image/png", derivative_cache_control(MediaVisibility.public))
    asset = MediaAsset(
        owner_user_id=admin_user_id, kind=MediaKind.photo, purpose=MediaPurpose.shelf_item, provider=MediaProvider.r2,
        status=MediaStatus.uploading, visibility=MediaVisibility.public, content_type="image/png", meta={"generated": "demo"},
    )
    db.add(asset)
    db.flush()
    db.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.original, storage_key=key, status=ObjectStatus.created))
    position = (db.execute(select(func.max(ShelfItemImage.position)).where(ShelfItemImage.item_id == item_id)).scalar_one() or -1) + 1
    image = ShelfItemImage(item_id=item_id, media_asset_id=asset.id, position=position, status="uploading")
    db.add(image)
    db.flush()
    complete(db, item_id=item_id, image_id=image.id)
    process(db, image.id)
    return image
