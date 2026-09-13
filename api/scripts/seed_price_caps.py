#!/usr/bin/env python3
"""Per-tier, per-niche entry-price caps.

`niche_package_price_cap` and the code enforcing it were built earlier, but
the table has always been empty - and an empty table means
`enforce_entry_price_cap` returns on its first line, every time. The ceiling
has never existed: a rookie could charge master rates, and every tier was
effectively uncapped.

The cap applies to `entry_price`, the per-photo rate (`ProPackage.price`) -
the same field whose display was just corrected. Per-photo rates invert
day-rate intuition: a wedding photographer delivers hundreds of frames from
one long day, so the rate per photo is low and the volume high; a product
shoot delivers a handful of heavily-produced frames, so the rate is high and
the volume low. These numbers sit on that axis.

Master is uncapped. `entry_price_max` is nullable and the enforcement reads
`if cap.entry_price_max is not None`, so a NULL row is genuinely unlimited
with no sentinel value and no code change. A master row still exists so the
minimum can be enforced later if that is ever wanted.

Minimums are 0.00 everywhere for now. A floor is a separate policy decision -
it stops undercutting but also stops a newcomer competing on price - and
landing two untested mechanisms at once is how neither gets understood.

    docker compose exec api python scripts/seed_price_caps.py --dry-run
    docker compose exec api python scripts/seed_price_caps.py
"""
from __future__ import annotations

import argparse
import sys
from decimal import Decimal
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from _seed_common import assert_environment_is_seedable  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.db.session import SessionLocal  # noqa: E402
from app.models.niche import Niche, SkillTier  # noqa: E402
from app.models.package_pricing import NichePackagePriceCap  # noqa: E402
from app.services.niche_catalog import ensure_initial_niches  # noqa: E402

# Maximum entry price per photo, in EUR. None means uncapped.
#
# Ordered cheapest to dearest per photo, which is roughly the inverse of how
# these jobs are priced per day:
#   weddings/family/events - high volume, hundreds of delivered frames
#   portraits              - smaller sets, more direction per frame
#   real_estate            - equipment and correction, ~25 frames
#   food                   - styling and a kitchen's time
#   corporate/product      - studio, lighting setups, 10-20 licensed frames
#
# Tiers scale about 1.7x per step, ~5x from rookie to elite: wide enough that
# promotion is worth something, not so wide that a rookie cannot trade.
CAPS: dict[str, dict[SkillTier, Decimal | None]] = {
    "weddings": {
        SkillTier.rookie: Decimal("4.00"),
        SkillTier.skilled: Decimal("7.00"),
        SkillTier.pro: Decimal("12.00"),
        SkillTier.elite: Decimal("20.00"),
        SkillTier.master: None,
    },
    "family": {
        SkillTier.rookie: Decimal("5.00"),
        SkillTier.skilled: Decimal("8.00"),
        SkillTier.pro: Decimal("13.00"),
        SkillTier.elite: Decimal("23.00"),
        SkillTier.master: None,
    },
    "portraits": {
        SkillTier.rookie: Decimal("6.00"),
        SkillTier.skilled: Decimal("10.00"),
        SkillTier.pro: Decimal("17.00"),
        SkillTier.elite: Decimal("28.00"),
        SkillTier.master: None,
    },
    "events_nightlife": {
        SkillTier.rookie: Decimal("5.00"),
        SkillTier.skilled: Decimal("8.00"),
        SkillTier.pro: Decimal("14.00"),
        SkillTier.elite: Decimal("24.00"),
        SkillTier.master: None,
    },
    "real_estate": {
        SkillTier.rookie: Decimal("8.00"),
        SkillTier.skilled: Decimal("13.00"),
        SkillTier.pro: Decimal("22.00"),
        SkillTier.elite: Decimal("37.00"),
        SkillTier.master: None,
    },
    "food": {
        SkillTier.rookie: Decimal("12.00"),
        SkillTier.skilled: Decimal("18.00"),
        SkillTier.pro: Decimal("30.00"),
        SkillTier.elite: Decimal("50.00"),
        SkillTier.master: None,
    },
    "corporate": {
        SkillTier.rookie: Decimal("13.00"),
        SkillTier.skilled: Decimal("22.00"),
        SkillTier.pro: Decimal("35.00"),
        SkillTier.elite: Decimal("58.00"),
        SkillTier.master: None,
    },
    "product": {
        SkillTier.rookie: Decimal("15.00"),
        SkillTier.skilled: Decimal("25.00"),
        SkillTier.pro: Decimal("40.00"),
        SkillTier.elite: Decimal("67.00"),
        SkillTier.master: None,
    },
}

ENTRY_PRICE_MIN = Decimal("0.00")


def apply_caps(db, *, dry_run: bool = False, verbose: bool = False) -> tuple[int, int, int]:
    """Write the cap table. Returns (created, updated, unchanged).

    Separate from `main` so the base environment seed can call it. A dev
    database with photographers but no caps is not a neutral starting point:
    it is the state this project was already in, where enforcement returned on
    its first line and the ceiling did not exist. Seeding the caps alongside
    the accounts keeps the two consistent, so nobody discovers months later
    that the accounts were priced against rules that were not loaded.
    """
    ensure_initial_niches(db)
    niches = {n.slug: n for n in db.execute(select(Niche)).scalars().all()}

    missing = [slug for slug in CAPS if slug not in niches]
    if missing:
        raise RuntimeError(f"unknown niche slugs {missing}")

    created = updated = unchanged = 0
    if verbose:
        print(f"{'niche':<18} {'tier':<9} {'max EUR/photo':>14}")
    for slug, by_tier in CAPS.items():
        for tier, maximum in by_tier.items():
            existing = db.execute(
                select(NichePackagePriceCap).where(
                    NichePackagePriceCap.niche_id == niches[slug].id,
                    NichePackagePriceCap.tier == tier,
                )
            ).scalar_one_or_none()

            if existing is None:
                created += 1
                if not dry_run:
                    db.add(
                        NichePackagePriceCap(
                            niche_id=niches[slug].id,
                            tier=tier,
                            entry_price_min=ENTRY_PRICE_MIN,
                            entry_price_max=maximum,
                            currency="EUR",
                        )
                    )
            elif existing.entry_price_max != maximum or existing.entry_price_min != ENTRY_PRICE_MIN:
                updated += 1
                if not dry_run:
                    existing.entry_price_max = maximum
                    existing.entry_price_min = ENTRY_PRICE_MIN
            else:
                unchanged += 1
            if verbose:
                shown = "uncapped" if maximum is None else f"{maximum}"
                print(f"{slug:<18} {tier.value:<9} {shown:>14}")

    if not dry_run:
        db.flush()
    return created, updated, unchanged


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Report what would change, write nothing")
    args = parser.parse_args()

    assert_environment_is_seedable()

    db = SessionLocal()
    try:
        try:
            created, updated, unchanged = apply_caps(db, dry_run=args.dry_run, verbose=True)
        except RuntimeError as exc:
            print(f"Refusing to seed: {exc}")
            return 1

        if args.dry_run:
            print(f"\nDry run: would create {created}, update {updated}, leave {unchanged}. Nothing written.")
            return 0

        db.commit()
        total = db.execute(select(NichePackagePriceCap)).scalars().all()
        print(f"\ncreated {created}, updated {updated}, unchanged {unchanged}")
        print(f"rows in niche_package_price_cap: {len(total)}")
        return 0
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
