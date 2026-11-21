"""One-off, for the local dev database only: give every ready portfolio photo
its card copy (and a web copy where it has none), as processing now makes
them for every new upload (2026-11-20).

Production needs none of this: it had no photos when the card copy was added.
The script refuses to run anywhere but a development environment whose
database is on this machine or in the local compose network.

    docker compose exec api python scripts/backfill_card_copies.py --dry-run
    docker compose exec api python scripts/backfill_card_copies.py
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from urllib.parse import urlparse

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

LOCAL_HOSTS = frozenset({"postgres", "localhost", "127.0.0.1", "::1"})
DEV_ENVIRONMENTS = frozenset({"development", "dev", "local"})


def assert_local_dev_database(app_env: str, database_url: str) -> None:
    env = (app_env or "").strip().lower()
    host = (urlparse(database_url or "").hostname or "").lower()
    if env not in DEV_ENVIRONMENTS or host not in LOCAL_HOSTS:
        raise RuntimeError(
            f"Refusing to backfill: APP_ENV={env or '(unset)'}, database host={host or '(unknown)'}. "
            "This script is for the local dev database only."
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--dry-run", action="store_true", help="count what would be made, change nothing")
    args = parser.parse_args()

    from app.core.config import get_settings

    settings = get_settings()
    assert_local_dev_database(settings.app_env, settings.database_url)

    import app.db.base  # noqa: F401  (every model, for the relationships)
    from sqlalchemy import exists, select

    from app.db.session import SessionLocal
    from app.models.media import MediaAsset, MediaKind, MediaObject, MediaPurpose, MediaStatus, MediaVariant, ObjectStatus
    from app.models.media_rights import MediaDerivative, MediaDerivativeKind
    from app.services.cache import bump_public_index_version
    from app.tasks.media_tasks import ensure_display_copies

    db = SessionLocal()
    lacking_card = ~exists().where(MediaDerivative.media_asset_id == MediaAsset.id, MediaDerivative.kind == MediaDerivativeKind.card)
    has_original = exists().where(
        MediaObject.media_asset_id == MediaAsset.id,
        MediaObject.variant == MediaVariant.original,
        MediaObject.status == ObjectStatus.ready,
    )
    ids = db.execute(
        select(MediaAsset.id).where(
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
            lacking_card,
            has_original,
        ).order_by(MediaAsset.created_at)
    ).scalars().all()
    print(f"photos lacking a card copy: {len(ids)}", flush=True)
    if args.dry_run:
        return 0

    made = {"card": 0, "web_res": 0}
    failed: list[str] = []
    for n, asset_id in enumerate(ids, 1):
        try:
            for kind in ensure_display_copies(db, db.get(MediaAsset, asset_id)):
                made[kind] += 1
            db.commit()
        except Exception as exc:  # one bad file must not stop the rest
            db.rollback()
            failed.append(f"{asset_id}: {exc}")
        if n % 50 == 0:
            print(f"  {n}/{len(ids)}", flush=True)
    bump_public_index_version()
    print(f"made: {made['card']} card copies, {made['web_res']} web copies; failed: {len(failed)}", flush=True)
    for line in failed:
        print("  failed", line, flush=True)
    return 0 if not failed else 1


if __name__ == "__main__":
    raise SystemExit(main())
