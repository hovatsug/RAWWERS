"""A photographer's wish list on The Shelf: up to `wishlist_max` items."""
from __future__ import annotations

import uuid

from sqlalchemy import delete, func, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.shelf import ShelfItem, ShelfWishlistItem
from app.services import raww_ledger as ledger
from app.services.shelf_settings import shelf_settings


def wishlist(db: Session, pro_user_id: uuid.UUID) -> list[ShelfWishlistItem]:
    return db.execute(
        select(ShelfWishlistItem).where(ShelfWishlistItem.pro_user_id == pro_user_id).order_by(ShelfWishlistItem.created_at)
    ).scalars().all()


def add(db: Session, *, pro_user_id: uuid.UUID, item_id: uuid.UUID, can_see) -> ShelfWishlistItem:
    """Add an item, once. Refused when the list is full, and for an item the
    photographer cannot see (`can_see(item)`), hidden or unknown. Counted
    under the photographer's lock, so two taps at once cannot overfill it."""
    item = db.get(ShelfItem, item_id)
    if item is None or not item.active or not can_see(item):
        raise APIError(code="not_found", message="Item not found", status_code=404)
    ledger.balance_locked(db, pro_user_id)
    existing = db.get(ShelfWishlistItem, (pro_user_id, item_id))
    if existing:
        return existing
    limit = shelf_settings(db).wishlist_max
    count = db.execute(select(func.count()).select_from(ShelfWishlistItem).where(ShelfWishlistItem.pro_user_id == pro_user_id)).scalar_one()
    if count >= limit:
        raise APIError(
            code="wishlist_full",
            message=f"Your wish list holds {limit} items. Take one off to add this.",
            status_code=409,
        )
    row = ShelfWishlistItem(pro_user_id=pro_user_id, item_id=item_id)
    db.add(row)
    db.flush()
    return row


def remove(db: Session, *, pro_user_id: uuid.UUID, item_id: uuid.UUID) -> None:
    db.execute(delete(ShelfWishlistItem).where(ShelfWishlistItem.pro_user_id == pro_user_id, ShelfWishlistItem.item_id == item_id))
    db.flush()
