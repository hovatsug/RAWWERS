from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, get_optional_current_user, require_admin, require_not_banned
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.gig import Gig, GigStatus
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose
from app.models.review import Review, ReviewReply, ReviewStatus
from app.models.admin import UserRole, UserRoleType
from app.schemas.media import CurrentUser
from app.schemas.review import (
    CreateReviewReplyRequest,
    CreateReviewRequest,
    ModerateReviewActionRequest,
    ProReviewsResponse,
    ReviewReplyView,
    ReviewView,
)
from app.services.analytics import log_event
from app.services.audit import add_admin_audit_log
from app.services.reputation import recompute_pro_reputation
from app.tasks.discovery_tasks import rebuild_pro_index

settings = get_settings()
router = APIRouter(tags=["reviews"])


@router.post("/gigs/{gig_id}/review", response_model=ReviewView)
def create_review_for_gig(
    gig_id: uuid.UUID,
    body: CreateReviewRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ReviewView:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    if gig.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only the gig client can review this gig", status_code=403)
    if not _is_reviewable_gig(gig):
        raise APIError(code="invalid_state", message="Gig is not reviewable yet", status_code=409)

    existing = db.execute(select(Review).where(Review.gig_id == gig.id)).scalar_one_or_none()
    if existing:
        raise APIError(code="already_exists", message="A review already exists for this gig", status_code=409)

    if body.video_media_asset_id:
        _validate_review_video_asset(db, body.video_media_asset_id, user.user_id)

    review = Review(
        gig_id=gig.id,
        pro_user_id=gig.pro_user_id,
        client_user_id=gig.client_user_id,
        rating=body.rating,
        tags=_normalize_tags(body.tags),
        text=body.text,
        would_book_again=body.would_book_again,
        video_media_asset_id=body.video_media_asset_id,
        status=ReviewStatus.published,
    )
    db.add(review)
    db.flush()

    recompute_pro_reputation(db, gig.pro_user_id)
    log_event(
        db,
        event_name="review.created",
        user_id=user.user_id,
        properties={"review_id": str(review.id), "gig_id": str(gig.id), "pro_user_id": str(gig.pro_user_id)},
    )
    db.commit()
    db.refresh(review)

    rebuild_pro_index.delay(str(gig.pro_user_id))
    return _to_review_view(db, review, None)


@router.get("/pros/{pro_user_id}/reviews", response_model=ProReviewsResponse)
def list_pro_reviews(
    pro_user_id: uuid.UUID,
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    rating: int | None = Query(default=None, ge=1, le=5),
    _: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_session),
) -> ProReviewsResponse:
    stmt = select(Review).where(Review.pro_user_id == pro_user_id, Review.status == ReviewStatus.published)
    if rating is not None:
        stmt = stmt.where(Review.rating == rating)

    total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    reviews = db.execute(stmt.order_by(Review.created_at.desc()).offset(offset).limit(limit)).scalars().all()
    review_ids = [review.id for review in reviews]
    replies = (
        db.execute(select(ReviewReply).where(ReviewReply.review_id.in_(review_ids))).scalars().all() if review_ids else []
    )
    reply_by_review_id = {reply.review_id: reply for reply in replies}

    items = [_to_review_view(db, review, reply_by_review_id.get(review.id)) for review in reviews]
    return ProReviewsResponse(total=total, items=items)


@router.post("/reviews/{review_id}/reply", response_model=ReviewReplyView)
def create_review_reply(
    review_id: uuid.UUID,
    body: CreateReviewReplyRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ReviewReplyView:
    review = db.get(Review, review_id)
    if not review:
        raise APIError(code="not_found", message="Review not found", status_code=404)
    if review.pro_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only the reviewed pro can reply", status_code=403)
    if review.status != ReviewStatus.published:
        raise APIError(code="invalid_state", message="Cannot reply to a hidden or removed review", status_code=409)

    existing = db.execute(select(ReviewReply).where(ReviewReply.review_id == review.id)).scalar_one_or_none()
    if existing:
        raise APIError(code="already_exists", message="Review reply already exists", status_code=409)

    reply_text = body.text.strip()
    if not reply_text:
        raise APIError(code="validation_error", message="Reply text cannot be empty", status_code=422)

    reply = ReviewReply(review_id=review.id, pro_user_id=user.user_id, text=reply_text)
    db.add(reply)
    log_event(
        db,
        event_name="review.reply_created",
        user_id=user.user_id,
        properties={"review_id": str(review.id), "pro_user_id": str(review.pro_user_id)},
    )
    db.commit()
    db.refresh(reply)
    return ReviewReplyView.model_validate(reply, from_attributes=True)


@router.post("/admin/reviews/{review_id}/moderate", response_model=ReviewView)
def moderate_review(
    review_id: uuid.UUID,
    body: ModerateReviewActionRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ReviewView:
    review = db.get(Review, review_id)
    if not review:
        raise APIError(code="not_found", message="Review not found", status_code=404)

    review.status = body.action
    db.flush()

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="review",
        target_id=str(review.id),
        action=f"review_{body.action.value}",
        reason=body.reason,
        metadata={"pro_user_id": str(review.pro_user_id), "client_user_id": str(review.client_user_id)},
    )
    recompute_pro_reputation(db, review.pro_user_id)
    if body.action in {ReviewStatus.hidden, ReviewStatus.removed}:
        log_event(
            db,
            event_name=f"review.{body.action.value}",
            user_id=actor.user_id,
            properties={"review_id": str(review.id), "pro_user_id": str(review.pro_user_id)},
        )
    db.commit()
    db.refresh(review)

    rebuild_pro_index.delay(str(review.pro_user_id))

    reply = db.execute(select(ReviewReply).where(ReviewReply.review_id == review.id)).scalar_one_or_none()
    return _to_review_view(db, review, reply)


def _is_reviewable_gig(gig: Gig) -> bool:
    if gig.status in {GigStatus.completed, GigStatus.final_delivered}:
        return True
    if gig.status == GigStatus.paid and settings.app_env.lower() in {"dev", "development"}:
        return bool((gig.meta or {}).get("reviewable_override"))
    return False


def _validate_review_video_asset(db: Session, media_asset_id: uuid.UUID, client_user_id: uuid.UUID) -> None:
    asset = db.get(MediaAsset, media_asset_id)
    if not asset:
        raise APIError(code="not_found", message="Media asset not found", status_code=404)
    if asset.kind != MediaKind.video or asset.purpose != MediaPurpose.video_review or asset.provider != MediaProvider.mux:
        raise APIError(code="validation_error", message="video_media_asset_id must be a Mux video_review asset", status_code=422)

    owner_ok = asset.owner_user_id == client_user_id or _is_admin_user(db, asset.owner_user_id)
    if not owner_ok:
        raise APIError(code="forbidden", message="Cannot attach a review video owned by another user", status_code=403)


def _is_admin_user(db: Session, user_id: uuid.UUID) -> bool:
    role_row = db.execute(
        select(UserRole).where(UserRole.user_id == user_id, UserRole.role == UserRoleType.admin)
    ).scalar_one_or_none()
    return role_row is not None


def _normalize_tags(tags: list[str]) -> list[str]:
    normalized: list[str] = []
    seen: set[str] = set()
    for tag in tags:
        tag_norm = tag.strip().lower()
        if not tag_norm or tag_norm in seen:
            continue
        seen.add(tag_norm)
        normalized.append(tag_norm)
    return normalized


def _to_review_view(db: Session, review: Review, reply: ReviewReply | None) -> ReviewView:
    playback_id = None
    if review.video_media_asset_id:
        asset = db.get(MediaAsset, review.video_media_asset_id)
        if asset:
            playback_id = (asset.meta or {}).get("playback_id")

    return ReviewView(
        id=review.id,
        gig_id=review.gig_id,
        pro_user_id=review.pro_user_id,
        client_user_id=review.client_user_id,
        rating=review.rating,
        tags=review.tags or [],
        text=review.text,
        would_book_again=review.would_book_again,
        video_media_asset_id=review.video_media_asset_id,
        video_playback_id=playback_id,
        status=review.status,
        created_at=review.created_at,
        updated_at=review.updated_at,
        reply=ReviewReplyView.model_validate(reply, from_attributes=True) if reply else None,
    )
