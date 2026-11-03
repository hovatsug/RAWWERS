"""The Shelf, for photographers: their RAWW, and (later steps) the shelf."""
from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.api.v1.payouts import _ensure_pro_user
from app.schemas.media import CurrentUser
from app.schemas.shelf import ProRawwView, RawwEntryView, RawwHistoryResponse
from app.services import raww_wallet

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
