"""Admin: every review, in any status.

The public list shows published reviews only and needs a photographer id, so
a moderator could neither find a review to act on nor see one already
hidden. This lists all of them, newest first, with who wrote each about
whom and the last decision made on it. Decisions are made through
`POST /admin/reviews/{id}/moderate` (app/api/v1/reviews.py).
"""
from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin
from app.models.admin import AdminAuditLog, ProProfile, UserAccount
from app.models.niche import Niche
from app.models.review import Review, ReviewReply, ReviewStatus
from app.schemas.admin_review import AdminReviewListResponse, AdminReviewModeration, AdminReviewRow
from app.schemas.media import CurrentUser

router = APIRouter(prefix="/admin/reviews", tags=["admin"])


@router.get("", response_model=AdminReviewListResponse)
def list_reviews(
    status: ReviewStatus | None = None,
    rating_max: int | None = Query(default=None, ge=1, le=5),
    q: str | None = Query(default=None, max_length=200),
    limit: int = Query(default=50, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminReviewListResponse:
    query = (
        select(Review, ProProfile.display_name, UserAccount.email, Niche.name)
        .outerjoin(ProProfile, ProProfile.user_id == Review.pro_user_id)
        .outerjoin(UserAccount, UserAccount.user_id == Review.client_user_id)
        .outerjoin(Niche, Niche.id == Review.niche_id)
    )
    if status is not None:
        query = query.where(Review.status == status)
    if rating_max is not None:
        query = query.where(Review.rating <= rating_max)
    text = (q or "").strip()
    if text:
        like = f"%{text}%"
        query = query.where(
            or_(Review.text.ilike(like), ProProfile.display_name.ilike(like), UserAccount.email.ilike(like))
        )

    total = db.execute(select(func.count()).select_from(query.subquery())).scalar_one()
    rows = db.execute(query.order_by(Review.created_at.desc(), Review.id).limit(limit).offset(offset)).all()

    ids = [review.id for review, *_ in rows]
    replies = (
        {r.review_id: r.text for r in db.execute(select(ReviewReply).where(ReviewReply.review_id.in_(ids))).scalars()}
        if ids
        else {}
    )
    decisions: dict[str, AdminAuditLog] = {}
    if ids:
        for entry in db.execute(
            select(AdminAuditLog)
            .where(AdminAuditLog.target_type == "review", AdminAuditLog.target_id.in_([str(i) for i in ids]))
            .order_by(AdminAuditLog.created_at.desc())
        ).scalars():
            decisions.setdefault(entry.target_id, entry)

    counts = {s.value: 0 for s in ReviewStatus}
    for value, n in db.execute(select(Review.status, func.count()).group_by(Review.status)).all():
        counts[value.value] = n

    return AdminReviewListResponse(
        items=[
            AdminReviewRow(
                id=review.id,
                status=review.status,
                rating=review.rating,
                text=review.text,
                tags=list(review.tags or []),
                would_book_again=review.would_book_again,
                has_video=review.video_media_asset_id is not None,
                niche_name=niche_name,
                gig_id=review.gig_id,
                pro_user_id=review.pro_user_id,
                pro_display_name=pro_name,
                client_user_id=review.client_user_id,
                client_email=client_email,
                reply_text=replies.get(review.id),
                created_at=review.created_at,
                last_moderation=_decision(decisions.get(str(review.id))),
            )
            for review, pro_name, client_email, niche_name in rows
        ],
        total=total,
        counts=counts,
    )


def _decision(entry: AdminAuditLog | None) -> AdminReviewModeration | None:
    if entry is None:
        return None
    return AdminReviewModeration(
        action=entry.action.removeprefix("review_"),
        reason=entry.reason,
        at=entry.created_at,
        actor_user_id=entry.actor_user_id,
    )
