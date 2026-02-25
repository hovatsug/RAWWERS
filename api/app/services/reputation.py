from __future__ import annotations

import uuid
from collections import Counter
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.review import ProReputation, Review, ReviewStatus


def recompute_pro_reputation(db: Session, pro_user_id: uuid.UUID) -> ProReputation:
    rows = db.execute(
        select(Review.rating, Review.would_book_again, Review.tags, Review.created_at).where(
            Review.pro_user_id == pro_user_id,
            Review.status == ReviewStatus.published,
        )
    ).all()

    review_count = len(rows)
    avg_rating = Decimal("0.00")
    would_book_again_rate = Decimal("0.00")
    last_review_at = None
    tag_counter: Counter[str] = Counter()

    if review_count > 0:
        rating_sum = sum(rating for rating, _, _, _ in rows)
        avg_rating = (Decimal(rating_sum) / Decimal(review_count)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

        would_book_true = sum(1 for _, would_book_again, _, _ in rows if would_book_again)
        would_book_again_rate = (
            (Decimal(would_book_true) * Decimal("100.00") / Decimal(review_count)).quantize(
                Decimal("0.01"), rounding=ROUND_HALF_UP
            )
        )

        last_review_at = max(created_at for _, _, _, created_at in rows)

        for _, _, tags, _ in rows:
            if isinstance(tags, list):
                for tag in tags:
                    if isinstance(tag, str):
                        normalized = tag.strip().lower()
                        if normalized:
                            tag_counter[normalized] += 1

    reputation = db.get(ProReputation, pro_user_id)
    if reputation is None:
        reputation = ProReputation(pro_user_id=pro_user_id)
        db.add(reputation)

    reputation.avg_rating = avg_rating
    reputation.review_count = review_count
    reputation.would_book_again_rate = would_book_again_rate
    reputation.tag_counts = dict(sorted(tag_counter.items()))
    reputation.last_review_at = last_review_at
    reputation.updated_at = datetime.now(timezone.utc)
    db.flush()
    return reputation
