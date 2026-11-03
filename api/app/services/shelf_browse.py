"""What a photographer may see on The Shelf.

- Level: their best niche tier decides the highest level they see
  (`tier_max_level`); a photographer with no tier yet counts as rookie.
- Compatibility: an item with cameras listed is for owners of one of them
  (My gear, linked to the camera catalogue); an item with none fits
  everyone and always shows.
"""
from __future__ import annotations

import uuid

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
