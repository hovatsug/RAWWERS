"""Base-package pricing engine: per-niche decay curves + per-(niche, tier)
entry-price caps. Deliberately separate from the extras/upsell pricing
in client_rewards_pricing.py (ExtraImagePricingPolicy) - different
feature, not merged.

The curve is a continuous per-photo price function p(n), not a stepped
bracket table - no discontinuity in the marginal rate at a boundary.
Photos up to the anchor are always priced at exactly the entry rate each;
the curve only shapes photos beyond it, and is always floored at a
niche-configured fraction of the entry rate so per-photo price never
reaches zero.

The anchor is the package's size (owner's decision, 2026-11-01): a package
of N photos costs N x the entry rate, and extras decay from the (N+1)th.
Every booking stores the anchor and the curve's shape when it is made
(`pricing_snapshot["curve"]`), so editing a niche's curve afterwards changes
no booking already made. Bookings made before that carry no stored curve
and keep the behaviour they were made under: anchor 10, the niche's curve
as it is now. `package_anchor` is the one place the anchor is decided. Totals are computed
numerically (summing p(i) for i in 1..n) rather than via a closed form,
since the floor's max() makes the per-photo function piecewise.
"""
from __future__ import annotations

import math
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.package_pricing import NichePackagePriceCap, PackageCurveType, PackageDecayCurve

# The platform's own lower limit on a selection, whatever the package; and
# the anchor of every booking made before the anchor was stored with it.
MINIMUM_PHOTOS = 10
LEGACY_ANCHOR = MINIMUM_PHOTOS

# Photo counts the curve is sampled at when showing someone what the
# decay actually does. Shared by the public preview and the pro-side one
# so a photographer and their client are never shown different points.
PRICING_PREVIEW_PHOTO_COUNTS = (10, 25, 50, 100, 200)

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


def package_anchor(included_photos: int) -> int:
    """The last photo priced at the full entry rate: the package's size. The
    one place this is decided. At least 1, since a package's size is not
    bounded where it is saved."""
    return max(1, int(included_photos))


def minimum_selection_for(included_photos: int) -> int:
    """The fewest photos a client may submit: the package's size, never below
    the platform's own lower limit."""
    return max(MINIMUM_PHOTOS, int(included_photos))


def price_at_photo(
    n: int,
    entry_rate: Decimal,
    *,
    curve_type: PackageCurveType,
    shape_param: Decimal | None,
    floor_pct: Decimal,
    anchor: int = LEGACY_ANCHOR,
) -> Decimal:
    """p(n): the price of the n-th photo. Photos up to the anchor always cost
    exactly entry_rate - the curve only shapes photos beyond it."""
    if n <= anchor or curve_type == PackageCurveType.flat:
        return entry_rate

    floor = entry_rate * floor_pct
    shape = float(shape_param or 0)
    entry = float(entry_rate)

    if curve_type == PackageCurveType.power:
        raw = entry * ((n / float(anchor)) ** (-shape))
    elif curve_type == PackageCurveType.exponential:
        raw = entry * math.exp(-shape * (n - anchor))
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
    anchor: int = LEGACY_ANCHOR,
) -> Decimal:
    """Total for `photo_count` photos at `entry_rate`, computed numerically
    as the sum of p(1)..p(photo_count) under the given curve."""
    if photo_count <= 0:
        return Decimal("0.00")

    if photo_count <= anchor or curve_type == PackageCurveType.flat:
        total = entry_rate * photo_count
    else:
        total = entry_rate * anchor
        for n in range(anchor + 1, photo_count + 1):
            total += price_at_photo(
                n, entry_rate, curve_type=curve_type, shape_param=shape_param, floor_pct=floor_pct, anchor=anchor
            )

    return total.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


@dataclass(frozen=True)
class PricingCurve:
    """Everything a photo count is priced by, apart from the entry rate."""

    anchor: int
    curve_type: PackageCurveType = PackageCurveType.flat
    shape_param: Decimal | None = None
    floor_pct: Decimal = Decimal("1.0000")

    def total(self, entry_rate: Decimal, photo_count: int) -> Decimal:
        return compute_total_for_photo_count(
            entry_rate,
            photo_count,
            curve_type=self.curve_type,
            shape_param=self.shape_param,
            floor_pct=self.floor_pct,
            anchor=self.anchor,
        )

    def as_snapshot(self) -> dict:
        return {
            "anchor": self.anchor,
            "curve_type": self.curve_type.value,
            "shape_param": None if self.shape_param is None else str(self.shape_param),
            "floor_pct": str(self.floor_pct),
        }

    @classmethod
    def from_snapshot(cls, value) -> PricingCurve | None:
        if not isinstance(value, dict) or not isinstance(value.get("anchor"), int) or isinstance(value.get("anchor"), bool):
            return None
        shape = value.get("shape_param")
        return cls(
            anchor=value["anchor"],
            curve_type=PackageCurveType(value["curve_type"]),
            shape_param=None if shape is None else Decimal(shape),
            floor_pct=Decimal(value["floor_pct"]),
        )


def niche_curve(db: Session, niche_id: uuid.UUID, *, anchor: int) -> PricingCurve:
    """The niche's curve as an admin has it now, from `anchor`. No curve row
    prices every photo at the entry rate."""
    row = get_curve_for_niche(db, niche_id)
    if not row:
        return PricingCurve(anchor=anchor)
    return PricingCurve(anchor=anchor, curve_type=row.curve_type, shape_param=row.shape_param, floor_pct=row.floor_pct)


def package_curve(db: Session, *, niche_id: uuid.UUID, included_photos: int) -> PricingCurve:
    """What a booking of this package would be priced by, if made now."""
    return niche_curve(db, niche_id, anchor=package_anchor(included_photos))


def booking_pricing_snapshot(db: Session, *, niche_id: uuid.UUID, included_photos: int) -> dict:
    """What a new booking stores so that its prices never move afterwards: the
    curve (anchor and shape) and the fewest photos its client may submit."""
    return {
        "curve": package_curve(db, niche_id=niche_id, included_photos=included_photos).as_snapshot(),
        "minimum_selection": minimum_selection_for(included_photos),
    }


def _gig_snapshot(gig) -> dict:
    snapshot = (getattr(gig, "meta", None) or {}).get("pricing_snapshot")
    return snapshot if isinstance(snapshot, dict) else {}


def gig_curve(db: Session, gig) -> PricingCurve:
    """The curve this booking is priced by: the one stored when it was made,
    or, for a booking made before curves were stored, the niche's curve now
    from photo 10 - exactly as it was priced until then."""
    stored = PricingCurve.from_snapshot(_gig_snapshot(gig).get("curve"))
    if stored is not None:
        return stored
    return niche_curve(db, gig.niche_id, anchor=LEGACY_ANCHOR)


def gig_total(db: Session, gig, photo_count: int) -> Decimal:
    """What `photo_count` photos come to on this booking."""
    return gig_curve(db, gig).total(gig.entry_rate, photo_count)


def gig_minimum_selection(gig) -> int:
    """The fewest photos this booking's client may submit, as agreed when it
    was made; 10 for a booking made before that was stored."""
    stored = _gig_snapshot(gig).get("minimum_selection")
    if isinstance(stored, int) and not isinstance(stored, bool):
        return stored
    return MINIMUM_PHOTOS


def compute_package_total(
    db: Session, *, niche_id: uuid.UUID, entry_rate: Decimal, photo_count: int, anchor: int = LEGACY_ANCHOR
) -> Decimal:
    """`photo_count` photos at `entry_rate` on the niche's curve as it is now,
    from `anchor`. A booking is priced by gig_total, never by this."""
    return niche_curve(db, niche_id, anchor=anchor).total(entry_rate, photo_count)


def compute_minimum_amount(
    db: Session, *, niche_id: uuid.UUID, entry_rate: Decimal, included_photos: int
) -> Decimal:
    """What a booking charges up front: the smallest selection its client may
    submit, priced from the package's own anchor.

    For a package of 10 or more that is the package itself, every photo at the
    entry rate (owner's decision: N photos cost N x the rate), so choosing
    exactly what was included owes nothing more. A package under the
    platform's 10 still has to be chosen up to 10: those photos are past its
    anchor and decay, and are collected here rather than as a difference the
    client owes just to reach the minimum - which is also what makes this the
    honest "from" price on Discover.

    It used to be the curve total for max(10, included) from photo 10, so the
    included photos past the tenth were already decayed.
    """
    curve = package_curve(db, niche_id=niche_id, included_photos=included_photos)
    return curve.total(entry_rate, minimum_selection_for(included_photos))


def is_curve_priced(gig) -> bool:
    """Whether this gig's photos are priced by the package decay curve.

    A curve-priced gig charges for *every* selected photo through
    `amount_final`, so the flat per-extra upsell must not also apply to it -
    photos past `included_photos` were billed twice, once by the curve and
    once by the upsell, and both charges gated the booking from closing.

    One predicate, used by everything that asks the question, so the pricing
    path and the unlocking path cannot drift apart again. Gigs without a niche
    or an entry rate (the legacy shoot path) keep the flat extras model.
    """
    return bool(gig is not None and gig.niche_id is not None and gig.entry_rate is not None)


def resolve_pro_tier_for_niche(db: Session, pro_user_id: uuid.UUID, niche_id: uuid.UUID) -> SkillTier:
    """The tier a photographer holds in one niche, which is the tier their
    cap is read against.

    Tier is per-niche: a master in weddings who has never shot product is a
    rookie in product and is capped as one. No skill row means rookie, the
    strictest cap, so a brand-new account cannot price as a master.

    Lives here rather than in the router that used to own it because the cap
    it selects is enforced here. A second copy of this three-line query is
    how the caller and the enforcement drift apart, and a seed priced against
    the wrong tier produces packages the API then refuses to let anyone edit.
    """
    skill = db.execute(
        select(ProNicheSkill).where(
            ProNicheSkill.pro_user_id == pro_user_id, ProNicheSkill.niche_id == niche_id
        )
    ).scalar_one_or_none()
    return skill.tier if skill else SkillTier.rookie


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


def enforce_minimum_selection_count(photo_count: int, minimum: int = MINIMUM_PHOTOS) -> None:
    if photo_count < minimum:
        raise APIError(
            code="validation_error",
            message=f"Minimum selection is {minimum} photos",
            status_code=422,
        )
