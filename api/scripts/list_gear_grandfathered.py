"""Photographers who went live before the gear requirement existed.

Read-only. Lists every publicly listed photographer whose gear does not meet
the floor today.

The gear floor is enforced at activation and at approval, so nobody new can
reach a public listing without it. That makes this list the grandfathered set
*by construction*: it can only contain people who were already live when the
gate arrived, and it shrinks as they verify. There is deliberately no table
recording it - a table would be one more thing that nothing reads, and would
drift from the truth the moment somebody verified.

Use it when the requirement changes (a new niche needing lighting, a stricter
lens rule) to see who is affected, and to decide whether to ask them to verify.

    docker compose run --rm --no-deps -v "$PWD/app:/app/app" -v "$PWD/scripts:/app/scripts" \
        api python scripts/list_gear_grandfathered.py
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.db.session import SessionLocal  # noqa: E402
from app.models.admin import ProProfile  # noqa: E402
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus  # noqa: E402
from app.services.gear_floor import evaluate_gear_floor, niche_slugs_for_pro  # noqa: E402
from sqlalchemy import select  # noqa: E402


def main() -> int:
    db = SessionLocal()
    try:
        live = db.execute(
            select(ProOnboarding.pro_user_id).where(ProOnboarding.status == ProOnboardingStatus.approved_public)
        ).scalars().all()

        rows = []
        for pro_id in live:
            floor = evaluate_gear_floor(db, pro_id, niche_slugs=niche_slugs_for_pro(db, pro_id))
            if floor.meets_floor:
                continue
            profile = db.get(ProProfile, pro_id)
            rows.append((str(pro_id), (profile.display_name if profile else None) or "-", ", ".join(floor.missing)))

        print(f"{len(live)} publicly listed; {len(rows)} do not meet the gear floor (grandfathered)\n")
        for pro_id, name, missing in sorted(rows, key=lambda r: r[1].lower()):
            print(f"{pro_id}  {name:32}  missing: {missing}")
        return 0
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
