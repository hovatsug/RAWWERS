from __future__ import annotations

import math
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.admin import Dispute, KYCStatus, ProProfile
from app.models.booking import BookingRequest, BookingRequestStatus, BookingRequestTransition, ProPackage
from app.models.discovery import ProPublicIndex
from app.models.gig import Gig, GigStatus
from app.models.media import MediaAsset, MediaKind, MediaPurpose, MediaStatus
from app.models.niche import Niche
from app.models.review import ProReputation
from app.services.niche_catalog import ensure_initial_niches
from app.services.gamification import queue_evaluate_user_milestones
from app.services.cache import bump_public_index_version
from app.services.niche_skills import get_top_niches_for_index
from app.services.niche_skills import recompute_pro_niche_skills
from app.services.search_indexing import enqueue_pro_index_upsert


def recompute_pro_public_index(db: Session, pro_user_id: uuid.UUID) -> ProPublicIndex:
    ensure_initial_niches(db)
    recompute_pro_niche_skills(db, pro_user_id)
    profile = db.get(ProProfile, pro_user_id)
    packages = db.execute(
        select(ProPackage).where(ProPackage.pro_user_id == pro_user_id, ProPackage.is_active.is_(True))
    ).scalars().all()

    min_price = min((p.price for p in packages), default=None)
    max_price = max((p.price for p in packages), default=None)
    currency = packages[0].currency if packages else "EUR"

    portfolio_photos = db.execute(
        select(func.count())
        .select_from(MediaAsset)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
        )
    ).scalar_one()

    portfolio_videos = db.execute(
        select(func.count())
        .select_from(MediaAsset)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.kind == MediaKind.video,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
        )
    ).scalar_one()

    gigs_completed = db.execute(
        select(func.count()).select_from(Gig).where(Gig.pro_user_id == pro_user_id, Gig.status == GigStatus.completed)
    ).scalar_one()
    gigs_cancelled = db.execute(
        select(func.count())
        .select_from(Gig)
        .where(
            Gig.pro_user_id == pro_user_id,
            Gig.status.in_([GigStatus.cancelled_by_client, GigStatus.cancelled_by_pro]),
        )
    ).scalar_one()

    disputes_count = db.execute(
        select(func.count())
        .select_from(Dispute)
        .join(Gig, Gig.id == Dispute.gig_id)
        .where(Gig.pro_user_id == pro_user_id)
    ).scalar_one()

    decision_transitions = db.execute(
        select(BookingRequestTransition.created_at, BookingRequest.created_at)
        .join(BookingRequest, BookingRequest.id == BookingRequestTransition.booking_request_id)
        .where(
            BookingRequest.pro_user_id == pro_user_id,
            BookingRequestTransition.from_status == BookingRequestStatus.pending,
            BookingRequestTransition.to_status.in_([BookingRequestStatus.accepted, BookingRequestStatus.declined]),
        )
    ).all()

    avg_response_minutes = None
    if decision_transitions:
        deltas = []
        for transition_time, request_time in decision_transitions:
            delta = int((transition_time - request_time).total_seconds() // 60)
            if delta >= 0:
                deltas.append(delta)
        if deltas:
            avg_response_minutes = int(sum(deltas) / len(deltas))

    completeness = profile.completeness_score if profile else 0
    reputation = db.get(ProReputation, pro_user_id)
    avg_rating = reputation.avg_rating if reputation else Decimal("0.00")
    review_count = reputation.review_count if reputation else 0
    ranking_score = _compute_ranking_score(
        completeness_score=completeness,
        portfolio_total=portfolio_photos + portfolio_videos,
        gigs_completed=gigs_completed,
        gigs_cancelled=gigs_cancelled,
        disputes_count=disputes_count,
        avg_response_minutes=avg_response_minutes,
        avg_rating=float(avg_rating),
        review_count=review_count,
    )

    index = db.get(ProPublicIndex, pro_user_id)
    if not index:
        index = ProPublicIndex(pro_user_id=pro_user_id)
        db.add(index)

    index.city = profile.city if profile else None
    index.country = profile.country if profile else None
    index.styles = profile.styles if profile else []
    index.min_package_price = min_price
    index.max_package_price = max_price
    index.currency = currency
    index.is_accepting_bookings = profile.is_accepting_bookings if profile else False
    index.kyc_status = profile.kyc_status if profile else KYCStatus.unsubmitted
    index.completeness_score = completeness
    index.portfolio_photo_count = portfolio_photos
    index.portfolio_video_count = portfolio_videos
    index.gigs_completed = gigs_completed
    index.gigs_cancelled = gigs_cancelled
    index.disputes_count = disputes_count
    index.avg_response_minutes = avg_response_minutes
    index.avg_rating = avg_rating
    index.review_count = review_count
    index.ranking_score = ranking_score
    top_niches = get_top_niches_for_index(db, pro_user_id, limit=3)
    index.top_niches = top_niches
    index.primary_niche_id = None
    if top_niches:
        primary = db.execute(select(Niche.id).where(Niche.slug == top_niches[0]["slug"])).scalar_one_or_none()
        index.primary_niche_id = primary
    index.updated_at = datetime.now(timezone.utc)

    db.flush()
    bump_public_index_version()
    enqueue_pro_index_upsert(db, pro_user_id, idempotency_suffix=index.updated_at.isoformat() if index.updated_at else "now")
    queue_evaluate_user_milestones(pro_user_id)
    return index


def recompute_all_pro_public_indexes(db: Session) -> int:
    pro_ids = db.execute(select(ProProfile.user_id)).scalars().all()
    for pro_id in pro_ids:
        recompute_pro_public_index(db, pro_id)
    db.flush()
    return len(pro_ids)


def _compute_ranking_score(
    completeness_score: int,
    portfolio_total: int,
    gigs_completed: int,
    gigs_cancelled: int,
    disputes_count: int,
    avg_response_minutes: int | None,
    avg_rating: float = 0.0,
    review_count: int = 0,
) -> Decimal:
    score = 100.0
    score += completeness_score * 0.5
    score += math.log1p(max(portfolio_total, 0)) * 10.0
    score += gigs_completed * 1.0
    score -= gigs_cancelled * 2.0
    score -= disputes_count * 5.0

    if avg_response_minutes is not None:
        if avg_response_minutes < 60:
            score += 10.0
        elif avg_response_minutes < 180:
            score += 5.0

    # Keep reputation impact modest for new pros and scale confidence gradually until 5 reviews.
    if review_count > 0:
        confidence = min(review_count, 5) / 5.0
        rating_bonus = (avg_rating - 4.0) * 20.0 * math.log1p(review_count) * confidence
        score += rating_bonus

    score = max(0.0, min(1000.0, score))
    return Decimal(f"{score:.4f}")
