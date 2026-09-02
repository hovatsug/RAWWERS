"""Base-package pricing engine: per-niche decay curves + per-(niche, tier)
entry-price caps. Deliberately separate from the extras/upsell pricing
in client_rewards_pricing.py (ExtraImagePricingPolicy) - different
feature, not merged.

The curve is a continuous per-photo price function p(n), not a stepped
bracket table - no discontinuity in the marginal rate at a boundary.
Photos 1-10 are always priced at exactly the entry rate each (the
minimum bundle never decays); the curve only shapes photos beyond the
10th, and is always floored at a niche-configured fraction of the
entry rate so per-photo price never reaches zero. Totals are computed
numerically (summing p(i) for i in 1..n) rather than via a closed form,
since the floor's max() makes the per-photo function piecewise.
"""
from __future__ import annotations

import math
import uuid
from datetime import datetime, timezone
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.niche import Niche, SkillTier
from app.models.package_pricing import NichePackagePriceCap, PackageCurveType, PackageDecayCurve

MINIMUM_PHOTOS = 10

# Default per-niche curve shapes, seeded idempotently by
# ensure_default_package_decay_curves(). Admins can edit/override any of
# these afterwards via the PackageDecayCurve admin endpoints - this only
# fills in a sane starting point per niche category.
#
# power (long, gentle tail - weddings/events/sports): a=0.35. At entry_rate
# 1.00 that's ~45% of entry by photo 100, ~30% by photo 300, ~25% by photo
# 500 - still meaningfully above the 20% floor at the top of the range.
#
# exponential (steep early, then flat - portraits/family/maternity): k=0.08.
# Drops to ~30% of entry by photo 25 (typical selection ceiling for these
# niches) and reaches the 15% floor by around photo 34, staying flat after.
#
# flat (product/corporate/real_estate/food/automotive/architecture):
# unchanged - p(n) = entry rate for every photo, no decay at all.
DEFAULT_CURVE_PARAMS_BY_SLUG: dict[str, tuple[PackageCurveType, Decimal | None, Decimal]] = {
    "weddings": (PackageCurveType.power, Decimal("0.35"), Decimal("0.20")),
    "events_nightlife": (PackageCurveType.power, Decimal("0.35"), Decimal("0.20")),
    "sports": (PackageCurveType.power, Decimal("0.35"), Decimal("0.20")),
    "portraits": (PackageCurveType.exponential, Decimal("0.08"), Decimal("0.15")),
    "family": (PackageCurveType.exponential, Decimal("0.08"), Decimal("0.15")),
    "maternity": (PackageCurveType.exponential, Decimal("0.08"), Decimal("0.15")),
    "product": (PackageCurveType.flat, None, Decimal("1.0000")),
    "corporate": (PackageCurveType.flat, None, Decimal("1.0000")),
    "real_estate": (PackageCurveType.flat, None, Decimal("1.0000")),
    "food": (PackageCurveType.flat, None, Decimal("1.0000")),
    "automotive": (PackageCurveType.flat, None, Decimal("1.0000")),
    "architecture": (PackageCurveType.flat, None, Decimal("1.0000")),
}


def ensure_default_package_decay_curves(db: Session) -> None:
    """Idempotently seed a PackageDecayCurve row for any known niche that
    doesn't have one yet. Safe to call repeatedly - existing rows (including
    ones an admin has since edited) are left untouched."""
    niches = db.execute(
        select(Niche).where(Niche.slug.in_(DEFAULT_CURVE_PARAMS_BY_SLUG.keys()))
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
        curve_type, shape_param, floor_pct = DEFAULT_CURVE_PARAMS_BY_SLUG[niche.slug]
        db.add(
            PackageDecayCurve(
                niche_id=niche.id,
                curve_type=curve_type,
                shape_param=shape_param,
                floor_pct=floor_pct,
                updated_at=now,
            )
        )
    db.flush()


def get_curve_for_niche(db: Session, niche_id: uuid.UUID) -> PackageDecayCurve | None:
    return db.execute(select(PackageDecayCurve).where(PackageDecayCurve.niche_id == niche_id)).scalar_one_or_none()


def price_at_photo(
    n: int, entry_rate: Decimal, *, curve_type: PackageCurveType, shape_param: Decimal | None, floor_pct: Decimal
) -> Decimal:
    """p(n): the price of the n-th photo. Photos 1-10 always cost exactly
    entry_rate - the curve only shapes photos beyond the minimum bundle."""
    if n <= MINIMUM_PHOTOS or curve_type == PackageCurveType.flat:
        return entry_rate

    floor = entry_rate * floor_pct
    shape = float(shape_param or 0)
    entry = float(entry_rate)

    if curve_type == PackageCurveType.power:
        raw = entry * ((n / 10.0) ** (-shape))
    elif curve_type == PackageCurveType.exponential:
        raw = entry * math.exp(-shape * (n - MINIMUM_PHOTOS))
    else:
        raw = entry

    return max(floor, Decimal(str(raw)))


def compute_total_for_photo_count(
    entry_rate: Decimal,
    photo_count: int,
    *,
    curve_type: PackageCurveType = PackageCurveType.flat,
    shape_param: Decimal | None = None,
    floor_pct: Decimal = Decimal("1.0000"),
) -> Decimal:
    """Total for `photo_count` photos at `entry_rate`, computed numerically
    as the sum of p(1)..p(photo_count) under the given curve."""
    if photo_count <= 0:
        return Decimal("0.00")

    if photo_count <= MINIMUM_PHOTOS or curve_type == PackageCurveType.flat:
        total = entry_rate * photo_count
    else:
        total = entry_rate * MINIMUM_PHOTOS
        for n in range(MINIMUM_PHOTOS + 1, photo_count + 1):
            total += price_at_photo(n, entry_rate, curve_type=curve_type, shape_param=shape_param, floor_pct=floor_pct)

    return total.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def compute_package_total(db: Session, *, niche_id: uuid.UUID, entry_rate: Decimal, photo_count: int) -> Decimal:
    curve = get_curve_for_niche(db, niche_id)
    if not curve:
        return compute_total_for_photo_count(entry_rate, photo_count)
    return compute_total_for_photo_count(
        entry_rate, photo_count, curve_type=curve.curve_type, shape_param=curve.shape_param, floor_pct=curve.floor_pct
    )


def compute_minimum_amount(db: Session, *, niche_id: uuid.UUID, entry_rate: Decimal) -> Decimal:
    """amount_minimum = 10 x entry rate. Photos 1-10 are always flat at the
    entry rate regardless of curve type, so this holds for every niche."""
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
