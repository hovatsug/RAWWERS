"""Base-package pricing engine: per-niche decay curves + per-(niche, tier)
entry-price caps. Deliberately separate from the extras/upsell pricing
in client_rewards_pricing.py (ExtraImagePricingPolicy) - different
feature, not merged.

The curve is marginal, not bracket: each photo is priced according to
whichever bracket it falls in, so the total always strictly increases
with photo count and there's no cliff where selecting more photos
costs the photographer money.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.niche import Niche, SkillTier
from app.models.package_pricing import NichePackagePriceCap, PackageDecayCurve

MINIMUM_PHOTOS = 10

# Fallback curve for any niche without a configured PackageDecayCurve row -
# no decay (flat rate), so an unconfigured niche never errors, just behaves
# as if the platform hasn't decided to discount it yet.
_FLAT_CURVE_TIERS: list[dict] = [{"upto": None, "multiplier": "1.00"}]

# Short tail: clients typically pick 10-25 photos and the value is
# concentrated there, so the discount ramps down fast.
_SHORT_TAIL_CURVE_TIERS: list[dict] = [
    {"upto": 25, "multiplier": "1.00"},
    {"upto": 50, "multiplier": "0.50"},
    {"upto": None, "multiplier": "0.25"},
]

# Long, gentle decay across 100-300 photos for niches where clients pick
# from large batches (weddings, events, sports galleries).
_LONG_GENTLE_CURVE_TIERS: list[dict] = [
    {"upto": 50, "multiplier": "1.00"},
    {"upto": 150, "multiplier": "0.75"},
    {"upto": 300, "multiplier": "0.50"},
    {"upto": None, "multiplier": "0.30"},
]

# Default per-niche curve shapes, seeded idempotently by
# ensure_default_package_decay_curves(). Admins can edit/override any of
# these afterwards via the PackageDecayCurve admin endpoints - this only
# fills in a sane starting point per niche category.
DEFAULT_DECAY_CURVE_TIERS_BY_SLUG: dict[str, list[dict]] = {
    "weddings": _LONG_GENTLE_CURVE_TIERS,
    "events_nightlife": _LONG_GENTLE_CURVE_TIERS,
    "sports": _LONG_GENTLE_CURVE_TIERS,
    "portraits": _SHORT_TAIL_CURVE_TIERS,
    "family": _SHORT_TAIL_CURVE_TIERS,
    "maternity": _SHORT_TAIL_CURVE_TIERS,
    "product": _FLAT_CURVE_TIERS,
    "corporate": _FLAT_CURVE_TIERS,
    "real_estate": _FLAT_CURVE_TIERS,
    "food": _FLAT_CURVE_TIERS,
    "automotive": _FLAT_CURVE_TIERS,
    "architecture": _FLAT_CURVE_TIERS,
}


def ensure_default_package_decay_curves(db: Session) -> None:
    """Idempotently seed a PackageDecayCurve row for any known niche that
    doesn't have one yet. Safe to call repeatedly - existing rows (including
    ones an admin has since edited) are left untouched."""
    niches = db.execute(
        select(Niche).where(Niche.slug.in_(DEFAULT_DECAY_CURVE_TIERS_BY_SLUG.keys()))
    ).scalars().all()
    if not niches:
        return
    existing_niche_ids = {
        row[0]
        for row in db.execute(
            select(PackageDecayCurve.niche_id).where(
                PackageDecayCurve.niche_id.in_([niche.id for niche in niches])
            )
        ).all()
    }
    now = datetime.now(timezone.utc)
    for niche in niches:
        if niche.id in existing_niche_ids:
            continue
        db.add(
            PackageDecayCurve(
                niche_id=niche.id,
                tiers=DEFAULT_DECAY_CURVE_TIERS_BY_SLUG[niche.slug],
                updated_at=now,
            )
        )
    db.flush()


def get_curve_tiers_for_niche(db: Session, niche_id: uuid.UUID) -> list[dict]:
    curve = db.execute(select(PackageDecayCurve).where(PackageDecayCurve.niche_id == niche_id)).scalar_one_or_none()
    if not curve or not curve.tiers:
        return _FLAT_CURVE_TIERS
    return curve.tiers


def compute_total_for_photo_count(entry_rate: Decimal, photo_count: int, curve_tiers: list[dict]) -> Decimal:
    """Marginal total for `photo_count` photos at `entry_rate`, per `curve_tiers`.

    curve_tiers: ordered list of {"upto": int | None, "multiplier": str | Decimal},
    "upto" is the cumulative photo count where that bracket ends (None = open-ended,
    must be last). Each bracket's own photos are priced at entry_rate * multiplier.
    """
    if photo_count <= 0:
        return Decimal("0.00")

    total = Decimal("0.00")
    previous_upto = 0
    for tier in curve_tiers:
        upto = tier.get("upto")
        multiplier = Decimal(str(tier["multiplier"]))
        bracket_end = photo_count if upto is None else min(int(upto), photo_count)
        photos_in_bracket = max(0, bracket_end - previous_upto)
        if photos_in_bracket:
            total += Decimal(photos_in_bracket) * entry_rate * multiplier
        previous_upto = bracket_end
        if previous_upto >= photo_count:
            break

    return total.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def compute_package_total(db: Session, *, niche_id: uuid.UUID, entry_rate: Decimal, photo_count: int) -> Decimal:
    curve_tiers = get_curve_tiers_for_niche(db, niche_id)
    return compute_total_for_photo_count(entry_rate, photo_count, curve_tiers)


def compute_minimum_amount(db: Session, *, niche_id: uuid.UUID, entry_rate: Decimal) -> Decimal:
    """amount_minimum = 10 x entry rate, run through the curve (bracket 1
    is always the entry rate at multiplier 1.00 in every seeded curve, but
    computing it through the curve rather than a bare multiply keeps this
    correct even for a curve whose first bracket doesn't start at 1.00)."""
    return compute_package_total(db, niche_id=niche_id, entry_rate=entry_rate, photo_count=MINIMUM_PHOTOS)


def get_price_cap(db: Session, *, niche_id: uuid.UUID, tier: SkillTier) -> NichePackagePriceCap | None:
    return db.execute(
        select(NichePackagePriceCap).where(NichePackagePriceCap.niche_id == niche_id, NichePackagePriceCap.tier == tier)
    ).scalar_one_or_none()


def enforce_entry_price_cap(db: Session, *, niche_id: uuid.UUID, tier: SkillTier, entry_price: Decimal) -> None:
    """Raises a 422 if entry_price is outside the platform's cap for this
    (niche, tier). No cap configured for a niche+tier means no restriction -
    matches the "unconfigured niche behaves as if not yet decided" stance
    taken for curves."""
    cap = get_price_cap(db, niche_id=niche_id, tier=tier)
    if not cap:
        return
    if entry_price < cap.entry_price_min:
        raise APIError(
            code="validation_error",
            message=f"Entry price must be at least {cap.entry_price_min} for this niche and tier",
            status_code=422,
        )
    if cap.entry_price_max is not None and entry_price > cap.entry_price_max:
        raise APIError(
            code="validation_error",
            message=f"Entry price must be at most {cap.entry_price_max} for this niche and tier",
            status_code=422,
        )


def enforce_minimum_selection_count(photo_count: int) -> None:
    if photo_count < MINIMUM_PHOTOS:
        raise APIError(
            code="validation_error",
            message=f"Minimum selection is {MINIMUM_PHOTOS} photos",
            status_code=422,
        )
