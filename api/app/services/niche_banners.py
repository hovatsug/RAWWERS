"""Niche banners: what an admin uploads, what is kept, and what the screens are sent.

A niche's banner is data on the niche, never in the apps: its style ("image"
or "text"), an optional tagline, and - for "image" - the current NicheBanner.
Every image a niche has used is kept; replacing, removing and reverting move
images between `current`, `previous` and `past`, never delete one.

Uploads go straight from the admin's browser to the bucket through the same
presigned path the app uses. Completing one checks the object itself (format,
size, dimensions), makes the tile, hero and placeholder derivatives under keys
of their own, and measures how dark the title scrim must be on this image.

Every change bumps the public index version, which the home and niche
responses are cached under, so the next load shows it.
"""
from __future__ import annotations

import base64
import io
import uuid
from dataclasses import dataclass
from decimal import Decimal

from PIL import Image, ImageFilter, ImageOps, UnidentifiedImageError
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.media import MediaAsset, MediaObject, MediaPurpose, MediaStatus, MediaVariant, MediaVisibility, ObjectStatus
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
from app.models.niche import Niche, NicheBanner
from app.schemas.niche_banners import NicheBannerImageView, NicheBannerView
from app.services.audit import add_admin_audit_log
from app.services.cache import bump_public_index_version
from app.services.photo_uploads import begin_photo_upload
from app.services.storage import (
    delete_object,
    derivative_cache_control,
    download_object_bytes,
    generate_variant_key,
    object_size,
    stable_presigned_gets,
    upload_object_bytes,
)

settings = get_settings()

STYLES = ("image", "text")
SOURCES = ("owner", "stock")
#: What Pillow calls the formats the MIME types allow.
_FORMATS = {"image/jpeg": "JPEG", "image/png": "PNG", "image/webp": "WEBP"}
_LABELS = {"image/jpeg": "JPEG", "image/png": "PNG", "image/webp": "WebP"}


def _fail(message: str, status_code: int = 422, code: str = "validation_error") -> APIError:
    return APIError(code=code, message=message, status_code=status_code)


def _allowed_names() -> str:
    """"JPEG, PNG or WebP", from whatever the settings allow."""
    names = [_LABELS.get(t, t) for t in sorted(settings.niche_banner_mime_type_set())]
    return names[0] if len(names) == 1 else ", ".join(names[:-1]) + " or " + names[-1]


def _megabytes(n: int) -> str:
    return f"{n / 1_000_000:.0f} MB" if n >= 1_000_000 else f"{n / 1_000_000:.2f} MB"


# --- Contrast -------------------------------------------------------------------------


def relative_luminance(rgb: tuple[int, int, int]) -> float:
    """WCAG relative luminance of an sRGB colour."""

    def channel(c: int) -> float:
        v = c / 255
        return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4

    r, g, b = (channel(c) for c in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def scrim_for(image: Image.Image) -> Decimal:
    """How dark the bottom scrim must be for a white title to stay legible.

    Measured where the title sits - the bottom 45% - at its bright end (the
    90th percentile, so a few specular highlights do not dictate it), then the
    least black overlay that brings white text to the minimum contrast,
    within the floor and ceiling.
    """
    small = image.convert("RGB").resize((96, max(1, round(96 * image.height / image.width))))
    region = small.crop((0, int(small.height * 0.55), small.width, small.height))
    values = sorted(relative_luminance(px) for px in region.getdata())
    bright = values[int(len(values) * 0.9)] if values else 0.0
    # White on a background of luminance L: (1.0 + 0.05) / (L + 0.05).
    most = 1.05 / settings.niche_banner_min_contrast - 0.05
    needed = 0.0 if bright <= most else 1 - most / bright
    clamped = min(settings.niche_banner_scrim_ceiling, max(settings.niche_banner_scrim_floor, needed))
    # Rounded up, so rounding never takes it below what was needed.
    return (Decimal(str(clamped)) * 100).to_integral_value(rounding="ROUND_CEILING") / 100


# --- Upload -----------------------------------------------------------------------------


def start_upload(db: Session, *, admin_user_id: uuid.UUID, content_type: str, file_name: str | None):
    if content_type.lower() not in settings.niche_banner_mime_type_set():
        raise _fail(f"A banner must be a {_allowed_names()} image.")
    _asset, started = begin_photo_upload(
        db,
        owner_user_id=admin_user_id,
        purpose=MediaPurpose.niche_banner,
        visibility=MediaVisibility.public,
        content_type=content_type.lower(),
        file_name=file_name,
    )
    db.commit()
    return started


@dataclass
class Completed:
    media_asset_id: uuid.UUID
    width: int
    height: int
    scrim_opacity: float
    placeholder: str
    warnings: list[str]


def complete_upload(db: Session, *, media_asset_id: uuid.UUID) -> Completed:
    asset = db.get(MediaAsset, media_asset_id)
    if asset is None or asset.purpose != MediaPurpose.niche_banner:
        raise _fail("Upload not found", 404, "not_found")
    if asset.status != MediaStatus.uploading:
        raise _fail("This upload has already been completed", 409, "invalid_state")
    original = db.execute(
        select(MediaObject).where(MediaObject.media_asset_id == asset.id, MediaObject.variant == MediaVariant.original)
    ).scalar_one()

    def refuse(message: str) -> APIError:
        delete_object(original.storage_key)
        asset.status = MediaStatus.failed
        asset.meta = {**asset.meta, "failure_reason": message}
        db.commit()
        return _fail(message)

    size = object_size(original.storage_key)
    if size is None:
        raise _fail("The file has not been uploaded yet.")
    if size > settings.niche_banner_max_bytes:
        raise refuse(f"The image is {_megabytes(size)}; the limit is {_megabytes(settings.niche_banner_max_bytes)}.")

    try:
        image = Image.open(io.BytesIO(download_object_bytes(original.storage_key, max_bytes=settings.niche_banner_max_bytes + 1)))
        image.load()
    except (UnidentifiedImageError, OSError):
        raise refuse(f"This file is not a {_allowed_names()} image.") from None
    allowed = {_FORMATS[t] for t in settings.niche_banner_mime_type_set() if t in _FORMATS}
    if image.format not in allowed:
        raise refuse(f"This file is not a {_allowed_names()} image.")
    image = ImageOps.exif_transpose(image).convert("RGB")
    if image.width < settings.niche_banner_min_width or image.height < settings.niche_banner_min_height:
        raise refuse(
            f"The image is {image.width}×{image.height} pixels; a full-width banner needs at least "
            f"{settings.niche_banner_min_width}×{settings.niche_banner_min_height}."
        )

    warnings = []
    if image.height > image.width:
        warnings.append("This image is portrait. Banners are wide, so most of it will be cropped away - check both previews.")

    cache_control = derivative_cache_control(MediaVisibility.public)
    placeholder_bytes = b""
    for kind, width, blur in (
        (MediaDerivativeKind.banner_tile, settings.niche_banner_tile_width, False),
        (MediaDerivativeKind.banner_hero, settings.niche_banner_hero_width, False),
        (MediaDerivativeKind.banner_placeholder, settings.niche_banner_placeholder_width, True),
    ):
        copy = image.resize((width, max(1, round(width * image.height / image.width))), Image.LANCZOS) if image.width > width else image.copy()
        if blur:
            copy = copy.filter(ImageFilter.GaussianBlur(radius=1))
        out = io.BytesIO()
        copy.save(out, format="JPEG", quality=50 if blur else 85)
        payload = out.getvalue()
        # The asset's own id is in the original's key, so each upload's
        # derivatives have keys no earlier banner ever used.
        key = generate_variant_key(original.storage_key, kind.value)
        upload_object_bytes(key, payload, "image/jpeg", cache_control)
        db.add(MediaDerivative(media_asset_id=asset.id, kind=kind, storage_key=key, content_type="image/jpeg",
                               width=copy.width, height=copy.height, bytes=len(payload)))
        if blur:
            placeholder_bytes = payload

    original.status = ObjectStatus.ready
    asset.byte_size = size
    asset.status = MediaStatus.ready
    asset.meta = {
        **asset.meta,
        "width": image.width,
        "height": image.height,
        "scrim_opacity": str(scrim_for(image)),
        "placeholder": "data:image/jpeg;base64," + base64.b64encode(placeholder_bytes).decode(),
    }
    db.commit()
    return Completed(media_asset_id=asset.id, width=image.width, height=image.height,
                     scrim_opacity=float(asset.meta["scrim_opacity"]), placeholder=asset.meta["placeholder"], warnings=warnings)


# --- What a niche shows -----------------------------------------------------------------


def _current(db: Session, niche: Niche) -> NicheBanner | None:
    return db.execute(select(NicheBanner).where(NicheBanner.niche_id == niche.id, NicheBanner.state == "current")).scalar_one_or_none()


def _previous(db: Session, niche: Niche) -> NicheBanner | None:
    return db.execute(select(NicheBanner).where(NicheBanner.niche_id == niche.id, NicheBanner.state == "previous")).scalar_one_or_none()


def image_urls(db: Session, banners: list[NicheBanner], expires_in: int) -> dict[uuid.UUID, dict[MediaDerivativeKind, str]]:
    kinds = (MediaDerivativeKind.banner_tile, MediaDerivativeKind.banner_hero)
    rows = db.execute(
        select(MediaDerivative.media_asset_id, MediaDerivative.kind, MediaDerivative.storage_key).where(
            MediaDerivative.media_asset_id.in_([b.media_asset_id for b in banners]), MediaDerivative.kind.in_(kinds)
        )
    ).all() if banners else []
    signed = stable_presigned_gets((key for _, _, key in rows), expires_in)
    out: dict[uuid.UUID, dict[MediaDerivativeKind, str]] = {}
    for asset_id, kind, key in rows:
        if key in signed:
            out.setdefault(asset_id, {})[MediaDerivativeKind(kind)] = signed[key]
    return out


def image_view(banner: NicheBanner, urls: dict[MediaDerivativeKind, str]) -> NicheBannerImageView | None:
    tile, hero = urls.get(MediaDerivativeKind.banner_tile), urls.get(MediaDerivativeKind.banner_hero)
    if not tile or not hero:
        return None
    return NicheBannerImageView(
        media_asset_id=banner.media_asset_id,
        tile_url=tile,
        hero_url=hero,
        placeholder=banner.placeholder,
        alt_text=banner.alt_text,
        focal_x=float(banner.focal_x),
        focal_y=float(banner.focal_y),
        scrim_opacity=float(banner.scrim_opacity),
        width=banner.width,
        height=banner.height,
    )


def banner_views(db: Session, niches: list[Niche], *, expires_in: int) -> dict[str, NicheBannerView]:
    """Each niche's banner as the screens draw it, in two queries for any number.

    A text-only niche is sent no image at all, so the app has nothing to
    fetch; an image niche with none uploaded is sent none, and the app draws
    the neutral ground.
    """
    if not niches:
        return {}
    image_niches = [n for n in niches if n.banner_style == "image"]
    current = db.execute(
        select(NicheBanner).where(NicheBanner.niche_id.in_([n.id for n in image_niches]), NicheBanner.state == "current")
    ).scalars().all() if image_niches else []
    by_niche = {b.niche_id: b for b in current}
    urls = image_urls(db, list(current), expires_in)
    views = {}
    for niche in niches:
        banner = by_niche.get(niche.id)
        views[niche.slug] = NicheBannerView(
            style=niche.banner_style,
            name=niche.name,
            tagline=niche.banner_tagline,
            image=image_view(banner, urls.get(banner.media_asset_id, {})) if banner else None,
        )
    return views


def status_of(niche: Niche, has_current: bool) -> str:
    if niche.banner_style == "text":
        return "text_only"
    return "image_set" if has_current else "image_missing"


# --- Changes ----------------------------------------------------------------------------


def _record(banner: NicheBanner | None) -> dict | None:
    if banner is None:
        return None
    return {
        "banner_id": str(banner.id), "media_asset_id": str(banner.media_asset_id), "alt_text": banner.alt_text,
        "focal_x": float(banner.focal_x), "focal_y": float(banner.focal_y), "source": banner.source,
        "credit": banner.credit, "licence": banner.licence, "source_url": banner.source_url,
    }


def _changed(db: Session, *, admin_user_id: uuid.UUID, niche: Niche, action: str, metadata: dict) -> None:
    add_admin_audit_log(db, actor_user_id=admin_user_id, target_type="niche_banner", target_id=niche.slug, action=action,
                        metadata={"niche": niche.slug, **metadata})
    db.commit()
    bump_public_index_version()


def _check_source(source: str, credit: str | None, licence: str | None, source_url: str | None) -> None:
    if source not in SOURCES:
        raise _fail("Source must be an owner upload or a stock image.")
    if source == "stock":
        missing = [name for name, value in (("credit", credit), ("licence", licence), ("source URL", source_url)) if not (value or "").strip()]
        if missing:
            raise _fail(f"A stock image needs its photographer credit, licence and source URL (missing: {', '.join(missing)}).")


def _check_alt(alt_text: str | None) -> str:
    alt = (alt_text or "").strip()
    if not alt:
        raise _fail("Alt text is required: describe what the image shows, for people who cannot see it.")
    if len(alt) > settings.niche_banner_alt_max:
        raise _fail(f"Alt text can be at most {settings.niche_banner_alt_max} characters.")
    return alt


def _check_focal(value: float | None, axis: str) -> Decimal:
    if value is None or not 0 <= value <= 1:
        raise _fail(f"The focal point's {axis} must be between 0 and 1.")
    return Decimal(str(round(value, 3)))


def set_banner(
    db: Session,
    niche: Niche,
    *,
    admin_user_id: uuid.UUID,
    media_asset_id: uuid.UUID,
    alt_text: str,
    focal_x: float,
    focal_y: float,
    source: str,
    credit: str | None = None,
    licence: str | None = None,
    source_url: str | None = None,
) -> NicheBanner:
    alt = _check_alt(alt_text)
    fx, fy = _check_focal(focal_x, "x"), _check_focal(focal_y, "y")
    _check_source(source, credit, licence, source_url)
    asset = db.get(MediaAsset, media_asset_id)
    if asset is None or asset.purpose != MediaPurpose.niche_banner:
        raise _fail("That upload is not a banner image.", 404, "not_found")
    if asset.status != MediaStatus.ready:
        raise _fail("That upload has not finished processing.", 409, "invalid_state")

    old_current, old_previous = _current(db, niche), _previous(db, niche)
    if old_previous is not None:
        old_previous.state = "past"
        db.flush()
    if old_current is not None:
        old_current.state = "previous"
        db.flush()
    banner = NicheBanner(
        niche_id=niche.id, media_asset_id=asset.id, state="current", alt_text=alt, focal_x=fx, focal_y=fy,
        source=source, credit=(credit or "").strip() or None, licence=(licence or "").strip() or None,
        source_url=(source_url or "").strip() or None, width=int(asset.meta["width"]), height=int(asset.meta["height"]),
        scrim_opacity=Decimal(asset.meta["scrim_opacity"]), placeholder=asset.meta["placeholder"], created_by_user_id=admin_user_id,
    )
    db.add(banner)
    db.flush()
    _changed(db, admin_user_id=admin_user_id, niche=niche, action="niche_banner_set",
             metadata={"from": _record(old_current), "to": _record(banner)})
    return banner


_EDITABLE = ("alt_text", "focal_x", "focal_y", "source", "credit", "licence", "source_url")


def edit_banner(db: Session, niche: Niche, *, admin_user_id: uuid.UUID, changes: dict) -> NicheBanner:
    banner = _current(db, niche)
    if banner is None:
        raise _fail("This niche has no image to edit.", 404, "not_found")
    before = _record(banner)
    proposed = {**before, **{k: v for k, v in changes.items() if k in _EDITABLE}}
    alt = _check_alt(proposed["alt_text"])
    fx, fy = _check_focal(proposed["focal_x"], "x"), _check_focal(proposed["focal_y"], "y")
    _check_source(proposed["source"], proposed["credit"], proposed["licence"], proposed["source_url"])
    banner.alt_text, banner.focal_x, banner.focal_y, banner.source = alt, fx, fy, proposed["source"]
    for field in ("credit", "licence", "source_url"):
        setattr(banner, field, (proposed[field] or "").strip() or None)
    db.flush()
    after = _record(banner)
    diff = {k: {"from": before[k], "to": after[k]} for k in _EDITABLE if before[k] != after[k]}
    _changed(db, admin_user_id=admin_user_id, niche=niche, action="niche_banner_edited", metadata=diff)
    return banner


def remove_banner(db: Session, niche: Niche, *, admin_user_id: uuid.UUID) -> None:
    current = _current(db, niche)
    if current is None:
        raise _fail("This niche has no image to remove.", 404, "not_found")
    previous = _previous(db, niche)
    if previous is not None:
        previous.state = "past"
        db.flush()
    current.state = "previous"
    db.flush()
    _changed(db, admin_user_id=admin_user_id, niche=niche, action="niche_banner_removed", metadata={"from": _record(current), "to": None})


def revert_banner(db: Session, niche: Niche, *, admin_user_id: uuid.UUID) -> None:
    previous = _previous(db, niche)
    if previous is None:
        raise _fail("There is no previous image to go back to.", 409, "invalid_state")
    current = _current(db, niche)
    # Through `past` for a moment: one current and one previous per niche is
    # held by the database at every flush.
    previous.state = "past"
    db.flush()
    if current is not None:
        current.state = "previous"
        db.flush()
    previous.state = "current"
    db.flush()
    _changed(db, admin_user_id=admin_user_id, niche=niche, action="niche_banner_reverted",
             metadata={"from": _record(current), "to": _record(previous)})


def update_niche(db: Session, niche: Niche, *, admin_user_id: uuid.UUID, changes: dict) -> Niche:
    diff = {}
    if "banner_style" in changes and changes["banner_style"] is not None:
        style = changes["banner_style"]
        if style not in STYLES:
            raise _fail("Banner style must be Image or Text only.")
        if style != niche.banner_style:
            diff["banner_style"] = {"from": niche.banner_style, "to": style}
            niche.banner_style = style
    if "banner_tagline" in changes:
        tagline = (changes["banner_tagline"] or "").strip() or None
        if tagline and len(tagline) > settings.niche_banner_tagline_max:
            raise _fail(f"The tagline can be at most {settings.niche_banner_tagline_max} characters (this one is {len(tagline)}).")
        if tagline != niche.banner_tagline:
            diff["banner_tagline"] = {"from": niche.banner_tagline, "to": tagline}
            niche.banner_tagline = tagline
    if diff:
        action = "niche_banner_style_changed" if "banner_style" in diff else "niche_banner_tagline_changed"
        _changed(db, admin_user_id=admin_user_id, niche=niche, action=action, metadata=diff)
    return niche


def history(db: Session, niche: Niche) -> list[NicheBanner]:
    return list(db.execute(
        select(NicheBanner).where(NicheBanner.niche_id == niche.id).order_by(NicheBanner.created_at.desc())
    ).scalars().all())


def limits() -> dict:
    return {
        "mime_types": sorted(settings.niche_banner_mime_type_set()),
        "max_bytes": settings.niche_banner_max_bytes,
        "min_width": settings.niche_banner_min_width,
        "min_height": settings.niche_banner_min_height,
        "tagline_max": settings.niche_banner_tagline_max,
        "alt_max": settings.niche_banner_alt_max,
        "min_contrast": settings.niche_banner_min_contrast,
    }
