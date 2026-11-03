"""The Shelf, for photographers: their RAWW, and (later steps) the shelf."""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.api.v1.payouts import _ensure_pro_user
from app.core.errors import APIError
from app.models.gear_verification import CameraModelReference
from app.schemas.media import CurrentUser
from app.schemas.shelf import (
    ProRawwView,
    RawwEntryView,
    RawwHistoryResponse,
    ShelfCameraModelsResponse,
    ShelfCameraModelView,
    ShelfWishlistResponse,
)
from app.services import raww_wallet, shelf_wishlist
from app.services.gear_verify import normalise_model
from app.services.shelf_settings import shelf_open, shelf_settings

router = APIRouter(prefix="/pro", tags=["shelf"])


@router.get("/raww", response_model=ProRawwView)
def my_raww(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> ProRawwView:
    _ensure_pro_user(db, user.user_id)
    view = ProRawwView(**raww_wallet.wallet(db, user.user_id))
    db.commit()
    return view


@router.get("/raww/history", response_model=RawwHistoryResponse)
def my_raww_history(
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> RawwHistoryResponse:
    _ensure_pro_user(db, user.user_id)
    total, rows = raww_wallet.history(db, user.user_id, limit=limit, offset=offset)
    return RawwHistoryResponse(
        total=total,
        items=[
            RawwEntryView(
                id=r.id, kind=r.kind.value, amount=r.amount, status=r.status.value, gig_id=r.gig_id,
                source_type=r.source_type, note=r.note, created_at=r.created_at,
            )
            for r in rows
        ],
    )


def _require_open(db: Session) -> None:
    if not shelf_open(db):
        raise APIError(code="shelf_closed", message="The Shelf is not open yet.", status_code=403)


def _visible(db: Session, pro_user_id: uuid.UUID):
    """What this photographer may see on The Shelf (the browse rules)."""
    from app.services.shelf_browse import can_see

    return lambda item: can_see(db, pro_user_id, item)


@router.get("/shelf/camera-models", response_model=ShelfCameraModelsResponse)
def search_camera_models(
    q: str = Query(min_length=1, max_length=100),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ShelfCameraModelsResponse:
    """The camera catalogue, for picking a body in My gear."""
    _ensure_pro_user(db, user.user_id)
    key = normalise_model(q)
    rows = db.execute(
        select(CameraModelReference)
        .where(or_(CameraModelReference.normalised_model.contains(key), CameraModelReference.display_name.ilike(f"%{q.strip()}%")))
        .order_by(CameraModelReference.display_name)
        .limit(20)
    ).scalars().all()
    return ShelfCameraModelsResponse(
        items=[ShelfCameraModelView(normalised_model=r.normalised_model, make=r.make, display_name=r.display_name) for r in rows]
    )


def _wishlist_view(db: Session, pro_user_id: uuid.UUID) -> ShelfWishlistResponse:
    return ShelfWishlistResponse(
        item_ids=[row.item_id for row in shelf_wishlist.wishlist(db, pro_user_id)], limit=shelf_settings(db).wishlist_max
    )


@router.get("/shelf/wishlist", response_model=ShelfWishlistResponse)
def my_wishlist(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> ShelfWishlistResponse:
    _ensure_pro_user(db, user.user_id)
    _require_open(db)
    return _wishlist_view(db, user.user_id)


@router.put("/shelf/wishlist/{item_id}", response_model=ShelfWishlistResponse)
def wish_for(item_id: uuid.UUID, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> ShelfWishlistResponse:
    _ensure_pro_user(db, user.user_id)
    _require_open(db)
    shelf_wishlist.add(db, pro_user_id=user.user_id, item_id=item_id, can_see=_visible(db, user.user_id))
    db.commit()
    return _wishlist_view(db, user.user_id)


@router.delete("/shelf/wishlist/{item_id}", response_model=ShelfWishlistResponse)
def unwish(item_id: uuid.UUID, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> ShelfWishlistResponse:
    _ensure_pro_user(db, user.user_id)
    _require_open(db)
    shelf_wishlist.remove(db, pro_user_id=user.user_id, item_id=item_id)
    db.commit()
    return _wishlist_view(db, user.user_id)
