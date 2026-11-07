"""What a photographer may see on The Shelf.

- Level: their best niche tier decides the highest level they see
  (`tier_max_level`); a photographer with no tier yet counts as rookie.
- Compatibility: an item with cameras listed is for owners of one of them
  (My gear, linked to the camera catalogue); an item with none fits
  everyone and always shows.
"""
from __future__ import annotations

import uuid
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.niche import SkillTier
from app.models.repair import GearItem
from app.models.shelf import ShelfItem, ShelfItemCompat
from app.services.shelf_settings import shelf_settings
from app.services.store import get_best_niche_tier


def tier_of(db: Session, pro_user_id: uuid.UUID) -> SkillTier:
    return get_best_niche_tier(db, pro_user_id) or SkillTier.rookie


def max_level(db: Session, pro_user_id: uuid.UUID) -> int:
    return int(shelf_settings(db).tier_max_level[tier_of(db, pro_user_id).value])


def owned_cameras(db: Session, pro_user_id: uuid.UUID) -> set[str]:
    return set(
        db.execute(
            select(GearItem.camera_model).where(GearItem.pro_user_id == pro_user_id, GearItem.camera_model.is_not(None))
        ).scalars()
    )


def fits(db: Session, pro_user_id: uuid.UUID, item: ShelfItem, owned: set[str] | None = None) -> bool:
    cameras = set(db.execute(select(ShelfItemCompat.camera_model).where(ShelfItemCompat.item_id == item.id)).scalars())
    if not cameras:
        return True
    return bool(cameras & (owned if owned is not None else owned_cameras(db, pro_user_id)))


def can_see(db: Session, pro_user_id: uuid.UUID, item: ShelfItem) -> bool:
    """Shown to them, unlocked: active, within their level, and fitting."""
    return item.active and item.level <= max_level(db, pro_user_id) and fits(db, pro_user_id, item)


_TIERS_IN_ORDER = (SkillTier.rookie, SkillTier.skilled, SkillTier.pro, SkillTier.elite, SkillTier.master)


def unlocks_at(level: int, tier_max_level: dict) -> SkillTier | None:
    """The first tier that sees `level`, or None when no tier does."""
    return next((t for t in _TIERS_IN_ORDER if int(tier_max_level[t.value]) >= level), None)


def browse(db: Session, pro_user_id: uuid.UUID) -> dict:
    """The Shelf as this photographer sees it, by level.

    Levels above theirs show as locked teasers with the tier that unlocks
    them. Items for cameras they do not own are left out; universal ones
    always show. Within a level, items made for their gear come first."""
    from app.models.shelf import ShelfWishlistItem
    from app.services import raww_ledger as ledger
    from app.services import shelf_orders

    settings = shelf_settings(db)
    now = shelf_orders._now()
    tier = tier_of(db, pro_user_id)
    highest = int(settings.tier_max_level[tier.value])
    owned = owned_cameras(db, pro_user_id)
    items = db.execute(select(ShelfItem).where(ShelfItem.active.is_(True))).scalars().all()
    compat: dict[uuid.UUID, set[str]] = {}
    for item_id, model in db.execute(select(ShelfItemCompat.item_id, ShelfItemCompat.camera_model)):
        compat.setdefault(item_id, set()).add(model)
    wished = set(db.execute(select(ShelfWishlistItem.item_id).where(ShelfWishlistItem.pro_user_id == pro_user_id)).scalars())
    from app.models.gear_verification import CameraModelReference
    from app.services.shelf_images import urls_for

    photos = urls_for(db, [i.id for i in items])
    names = dict(db.execute(select(CameraModelReference.normalised_model, CameraModelReference.display_name)).all()) if compat else {}
    balance = ledger.get_balance(db, pro_user_id)
    spendable = balance.spendable if balance else 0

    levels = []
    for level in range(1, len(settings.level_band_raww) + 1):
        locked = level > highest
        shown = []
        for item in items:
            if item.level != level:
                continue
            cameras = compat.get(item.id, set())
            if cameras and not (cameras & owned):
                continue
            shown.append(
                {
                    "id": item.id,
                    "title": item.title,
                    "brand": item.brand,
                    "category": item.category,
                    "description": item.description,
                    "image_url": item.image_url,
                    "level": item.level,
                    "price_raww": item.price_raww,
                    "in_stock": item.stock_status.value == "in_stock",
                    "fits_your_gear": bool(cameras),
                    "wished": item.id in wished,
                    "affordable": spendable >= item.price_raww,
                    "locked": locked,
                    "cover_url": next((p.small for p in photos.get(item.id, []) if p.small), None) or item.image_url,
                    "image_urls": [p.large for p in photos.get(item.id, []) if p.large],
                    "camera_names": sorted(names.get(m, m) for m in cameras),
                }
            )
        shown.sort(key=lambda i: (not i["fits_your_gear"], i["price_raww"], i["title"]))
        unlock = unlocks_at(level, settings.tier_max_level) if locked else None
        levels.append(
            {
                "level": level,
                "band_raww": settings.level_band_raww[level - 1],
                "band_eur": (Decimal(settings.level_band_raww[level - 1]) * Decimal(settings.raww_eur_value)).quantize(Decimal("1")),
                "locked": locked,
                "unlocks_at_tier": unlock.value if unlock else None,
                "items": shown,
            }
        )
    return {
        "tier": tier.value,
        "max_level": highest,
        "spendable": spendable,
        "has_camera": bool(owned),
        "wishlist_max": settings.wishlist_max,
        "orders_this_month": shelf_orders.orders_this_month(db, pro_user_id, now),
        "max_orders_per_month": settings.max_orders_per_month,
        "orders_reset_at": shelf_orders.month_resets_at(now),
        "terms_text": settings.terms_text,
        "terms_draft": settings.terms_approved_at is None,
        "levels": levels,
    }
