#!/usr/bin/env python3
"""Reference data for a new database: safe to run in production, and twice.

What it does, in plain words: after `alembic upgrade head` on an empty
database, it adds the rows the app needs that no migration creates. It only
ADDS what is missing. It never changes or deletes a row that is already
there (an admin may have edited it), and it creates no user, no photographer
and no booking. Running it a second time prints "skipped" for everything.

    docker compose --env-file /opt/rawwers/.env.production -f deploy/compose.prod.yml \
        run --rm api python scripts/bootstrap_reference_data.py            # do it
    ... python scripts/bootstrap_reference_data.py --dry-run               # only show
    ... python scripts/bootstrap_reference_data.py --skip-price-caps       # all but the caps

What it adds when missing:
  - the 12 niches;
  - the UK VAT row (country_tax_rule GB);
  - the five interview questions of "Meet the photographer";
  - the camera and lens reference (which bodies are full-frame);
  - the price caps, GBP and EUR, from api/data/price_caps/*.csv (the pound
    caps are PROVISIONAL, not approved by the owner: docs/PRICE_CAPS.md; the
    output says so on their line). A cap row that exists is
    left as it is, even when the file says something else ("differs").

Exit 0: done (or nothing to do). Exit 1: something failed and nothing was
written (one transaction).
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from sqlalchemy import func, select  # noqa: E402

import app.db.base  # noqa: E402,F401  every model registered
from app.db.session import SessionLocal  # noqa: E402
from app.models.gear_verification import CameraModelReference, LensModelReference, SensorSize  # noqa: E402
from app.models.meet import InterviewQuestion  # noqa: E402
from app.models.niche import Niche  # noqa: E402
from app.models.package_pricing import NichePackagePriceCap  # noqa: E402
from app.services.gear_verify import normalise_model  # noqa: E402
from app.services.meet import ensure_default_questions  # noqa: E402
from app.services.niche_catalog import ensure_initial_niches  # noqa: E402
from app.services.tax import DEFAULT_COUNTRY, ensure_uk_tax_rule  # noqa: E402

import seed_camera_reference as cameras  # noqa: E402
import seed_price_caps as caps  # noqa: E402


#: Currencies whose caps the owner has not approved yet (docs/PRICE_CAPS.md).
#: Every run says so on that currency's line. Remove a currency once approved.
PROVISIONAL_CAP_CURRENCIES = {"GBP"}


def _count(db, model) -> int:
    return db.execute(select(func.count()).select_from(model)).scalar_one()


def _report(name: str, created: int, skipped: int, extra: str = "") -> None:
    print(f"{name:<22} created {created:>4}   skipped {skipped:>4}{('   ' + extra) if extra else ''}")


def bootstrap(db, *, with_price_caps: bool = True) -> dict[str, int]:
    """Add every missing reference row; returns how many were created per kind."""
    from app.models.payouts import CountryTaxRule

    created: dict[str, int] = {}

    before = _count(db, Niche)
    ensure_initial_niches(db)
    db.flush()
    created["niches"] = _count(db, Niche) - before
    _report("niches", created["niches"], before)

    had_rule = db.get(CountryTaxRule, DEFAULT_COUNTRY) is not None
    ensure_uk_tax_rule(db)
    created["tax_rule"] = 0 if had_rule else 1
    _report(f"tax rule {DEFAULT_COUNTRY}", created["tax_rule"], int(had_rule))

    before = _count(db, InterviewQuestion)
    ensure_default_questions(db)
    db.flush()
    created["interview_questions"] = _count(db, InterviewQuestion) - before
    _report("interview questions", created["interview_questions"], before)

    bodies = (
        [(mk, m, d, SensorSize.full_frame) for mk, m, d in cameras.FULL_FRAME]
        + [(mk, m, d, SensorSize.medium_format) for mk, m, d in cameras.MEDIUM_FORMAT]
        + [(mk, m, d, SensorSize.crop) for mk, m, d in cameras.COMMON_CROP]
    )
    new = skipped = 0
    seen: set[str] = set()
    for make, model, display, sensor in bodies:
        key = normalise_model(model)
        if key in seen or db.get(CameraModelReference, key) is not None:
            skipped += 1
            continue
        seen.add(key)
        db.add(CameraModelReference(normalised_model=key, make=make, display_name=display, sensor_size=sensor))
        new += 1
    db.flush()
    created["camera_models"] = new
    _report("camera models", new, skipped)

    new = skipped = 0
    seen = set()
    for make, model, display, aperture in cameras.LENSES:
        key = normalise_model(model)
        if key in seen or db.get(LensModelReference, key) is not None:
            skipped += 1
            continue
        seen.add(key)
        db.add(LensModelReference(normalised_model=key, make=make, display_name=display, aperture_type=aperture))
        new += 1
    db.flush()
    created["lens_models"] = new
    _report("lens models", new, skipped)

    if with_price_caps:
        niches = {n.slug: n for n in db.execute(select(Niche)).scalars()}
        for currency in caps.CURRENCIES:
            new = skipped = differs = 0
            for slug, by_tier in caps.CAPS_BY_CURRENCY[currency].items():
                if slug not in niches:
                    raise RuntimeError(f"price caps name a niche that does not exist: {slug}")
                for tier, maximum in by_tier.items():
                    row = db.execute(
                        select(NichePackagePriceCap).where(
                            NichePackagePriceCap.niche_id == niches[slug].id,
                            NichePackagePriceCap.tier == tier,
                            NichePackagePriceCap.currency == currency,
                        )
                    ).scalar_one_or_none()
                    if row is not None:
                        skipped += 1
                        differs += int(row.entry_price_max != maximum)
                        continue
                    db.add(
                        NichePackagePriceCap(
                            niche_id=niches[slug].id,
                            tier=tier,
                            entry_price_min=caps.ENTRY_PRICE_MIN,
                            entry_price_max=maximum,
                            currency=currency,
                        )
                    )
                    new += 1
            db.flush()
            created[f"price_caps_{currency}"] = new
            notes = [f"{differs} differ from the file, left as they are"] if differs else []
            if currency in PROVISIONAL_CAP_CURRENCIES:
                notes.append("PROVISIONAL: not approved by the owner (docs/PRICE_CAPS.md)")
            _report(f"price caps {currency}", new, skipped, "; ".join(notes))
    else:
        print("price caps             not touched (--skip-price-caps)")
    return created


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dry-run", action="store_true", help="show what would be added, write nothing")
    parser.add_argument("--skip-price-caps", action="store_true", help="add everything except the price caps")
    args = parser.parse_args()

    db = SessionLocal()
    try:
        created = bootstrap(db, with_price_caps=not args.skip_price_caps)
        total = sum(created.values())
        if args.dry_run:
            db.rollback()
            print(f"\nDry run: {total} row(s) would be added. Nothing written.")
        else:
            db.commit()
            print(f"\nDone: {total} row(s) added." if total else "\nNothing to add: everything was already there.")
        return 0
    except Exception as exc:
        db.rollback()
        print(f"\nFAILED, nothing written: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 1
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
