from __future__ import annotations

import math
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.admin import KYCStatus, ProFaultEvent, ProProfile
from app.models.booking import ProPackage
from app.models.discovery import ProPublicIndex
from app.models.gig import Gig, GigStatus
from app.models.media import MediaAsset, MediaKind, MediaPurpose, MediaStatus
from app.models.niche import Niche
from app.models.review import ProReputation
from app.services.niche_catalog import ensure_initial_niches
from app.services.gamification import queue_evaluate_user_milestones
from app.services.cache import bump_public_index_version
from app.services.pro_standing import booking_block_reason
from app.services.niche_skills import get_top_niches_for_index
from app.services.niche_skills import get_niche_tier_map_for_index, get_verified_niches_for_index
from app.services.response_time import bucket_for, response_median_minutes
from app.services.package_pricing import MINIMUM_PHOTOS, compute_minimum_amount
from app.services.niche_skills import recompute_pro_niche_skills
from app.services.search_indexing import enqueue_pro_index_upsert


def recompute_pro_public_index(db: Session, pro_user_id: uuid.UUID) -> ProPublicIndex:
    ensure_initial_niches(db)
    recompute_pro_niche_skills(db, pro_user_id)
    profile = db.get(ProProfile, pro_user_id)
    packages = db.execute(
        select(ProPackage).where(ProPackage.pro_user_id == pro_user_id, ProPackage.is_active.is_(True))
    ).scalars().all()

    # What a client would actually pay, not what one photograph costs.
    #
    # These were min/max of ProPackage.price - the per-photo entry rate -
    # presented on Discover cards as "from EUR 243". The real minimum for that
    # package is EUR 6,075. The field is read by more than the cards: it gates
    # discoverability (null means hidden), backs the min_price/max_price
    # budget filter, and drives price_asc/price_desc sorting. So the filter
    # was comparing budgets against per-photo rates, which matched everyone
    # and meant nothing.
    #
    # Fixing it here rather than at each of the six readers is the point: a
    # value with two meanings in two places is how the pricing double-charge
    # happened. Changing it does rescale the budget filter by 10-25x, which is
    # the filter becoming meaningful for the first time rather than a side
    # effect.
    #
    # compute_minimum_amount() rather than entry_rate * photos: photos past
    # the tenth follow the niche's decay curve, so multiplying overstates a
    # portrait package by EUR 1,679 while looking correct on flat niches.
    package_minimums = [
        compute_minimum_amount(
            db,
            niche_id=package.niche_id,
            entry_rate=package.price,
            included_photos=package.included_photos,
        )
        for package in packages
    ]
    min_price = min(package_minimums, default=None)
    max_price = max(package_minimums, default=None)

    # The entry rate and photo count belonging to the cheapest package, found
    # by index rather than by taking min() over the rates. The package with
    # the lowest rate is not always the package with the lowest total - a low
    # rate over many photos beats a high rate over ten - and mixing the two
    # would advertise a pairing that no package offers.
    min_entry_rate = None
    min_entry_photos = None
    if package_minimums:
        cheapest = packages[package_minimums.index(min_price)]
        min_entry_rate = cheapest.price
        min_entry_photos = max(MINIMUM_PHOTOS, cheapest.included_photos)

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
    # The photographer's own cancellations only: a client cancelling is not
    # something the photographer did.
    gigs_cancelled = db.execute(
        select(func.count())
        .select_from(Gig)
        .where(Gig.pro_user_id == pro_user_id, Gig.status == GigStatus.cancelled_by_pro)
    ).scalar_one()

    # A dispute counts only with a recorded finding that the photographer
    # was at fault - not every dispute opened on their bookings, whoever
    # opened it and however it ended. The one place fault events are read.
    disputes_count = db.execute(
        select(func.count(func.distinct(ProFaultEvent.dispute_id))).where(
            ProFaultEvent.pro_user_id == pro_user_id,
            ProFaultEvent.kind == "dispute_at_fault",
            ProFaultEvent.dispute_id.is_not(None),
        )
    ).scalar_one()

    # A label for clients, never an input to ranking: ordering photographers
    # by how fast they reply would bury anyone whose app was closed when a
    # request came in - and until alerts exist, nothing tells them it did.
    response_median, _ = response_median_minutes(db, pro_user_id)

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
    index.min_entry_rate = min_entry_rate
    index.min_entry_photos = min_entry_photos
    index.currency = currency
    # The photographer's own switch, and never while banned or suspended.
    index.is_accepting_bookings = bool(profile and profile.is_accepting_bookings) and booking_block_reason(db, pro_user_id) is None
    index.kyc_status = profile.kyc_status if profile else KYCStatus.unsubmitted
    index.completeness_score = completeness
    index.portfolio_photo_count = portfolio_photos
    index.portfolio_video_count = portfolio_videos
    index.gigs_completed = gigs_completed
    index.gigs_cancelled = gigs_cancelled
    index.disputes_count = disputes_count
    index.response_median_minutes = response_median
    index.response_bucket = bucket_for(response_median).value
    index.avg_rating = avg_rating
    index.review_count = review_count
    top_niches = get_top_niches_for_index(db, pro_user_id, limit=3)
    if top_niches:
        top_tier = str(top_niches[0].get("tier") or "rookie")
        tier_rank_value = {"rookie": 0, "skilled": 1, "pro": 2, "elite": 3, "master": 4}.get(top_tier, 0)
        ranking_score = (ranking_score + Decimal(str(tier_rank_value * 8))).quantize(Decimal("0.0001"))
    index.ranking_score = ranking_score
    index.top_niches = top_niches
    index.niche_tiers = get_niche_tier_map_for_index(db, pro_user_id)
    index.verified_niches = get_verified_niches_for_index(db, pro_user_id)
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


@dataclass(frozen=True)
class RebuildResult:
    rows: int
    # Admin tier overrides in force after the rebuild - every one of them
    # still the effective tier. Reported because rebuild-all is exactly what
    # used to erase them.
    overrides_preserved: int
    # Photographers clients can see afterwards (listed_photographer_count).
    # `rows` counts every profile, test accounts and unfinished ones
    # included; this is the number a deploy check compares.
    listed: int = 0


def listed_photographer_count(db: Session) -> int:
    """Photographers who pass the five gates every client list applies -
    approved for the public, KYC approved, accepting bookings, a profile at
    least 60% complete, and a price. The same five as client_launch's
    _row_base_query and discovery's list, without a city."""
    from app.models.launch_ops import ProOnboarding, ProOnboardingStatus

    return db.execute(
        select(func.count())
        .select_from(ProPublicIndex)
        .join(ProOnboarding, ProOnboarding.pro_user_id == ProPublicIndex.pro_user_id)
        .where(
            ProOnboarding.status == ProOnboardingStatus.approved_public,
            ProPublicIndex.kyc_status == KYCStatus.approved,
            ProPublicIndex.is_accepting_bookings.is_(True),
            ProPublicIndex.completeness_score >= 60,
            ProPublicIndex.min_package_price.is_not(None),
        )
    ).scalar_one()


def recompute_all_pro_public_indexes(db: Session) -> RebuildResult:
    from app.models.niche import ProNicheSkill

    pro_ids = db.execute(select(ProProfile.user_id)).scalars().all()
    for pro_id in pro_ids:
        recompute_pro_public_index(db, pro_id)
    db.flush()
    preserved = db.execute(
        select(func.count())
        .select_from(ProNicheSkill)
        .where(ProNicheSkill.override_tier.is_not(None), ProNicheSkill.tier == ProNicheSkill.override_tier)
    ).scalar_one()
    return RebuildResult(rows=len(pro_ids), overrides_preserved=int(preserved), listed=listed_photographer_count(db))


def _compute_ranking_score(
    completeness_score: int,
    portfolio_total: int,
    gigs_completed: int,
    gigs_cancelled: int,
    disputes_count: int,
    avg_rating: float = 0.0,
    review_count: int = 0,
) -> Decimal:
    score = 100.0
    score += completeness_score * 0.5
    score += math.log1p(max(portfolio_total, 0)) * 10.0
    score += gigs_completed * 1.0
    score -= gigs_cancelled * 2.0
    score -= disputes_count * 5.0

    # Keep reputation impact modest for new pros and scale confidence gradually until 5 reviews.
    if review_count > 0:
        confidence = min(review_count, 5) / 5.0
        rating_bonus = (avg_rating - 4.0) * 20.0 * math.log1p(review_count) * confidence
        score += rating_bonus

    score = max(0.0, min(1000.0, score))
    return Decimal(f"{score:.4f}")
