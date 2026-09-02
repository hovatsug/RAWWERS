from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.niche import Niche
from app.services.package_pricing import ensure_default_package_decay_curves

INITIAL_NICHES: list[dict[str, str]] = [
    {"slug": "weddings", "name": "Weddings"},
    {"slug": "portraits", "name": "Portraits"},
    {"slug": "family", "name": "Family"},
    {"slug": "corporate", "name": "Corporate"},
    {"slug": "events_nightlife", "name": "Events & Nightlife"},
    {"slug": "product", "name": "Product"},
    {"slug": "real_estate", "name": "Real Estate"},
    {"slug": "food", "name": "Food"},
    {"slug": "automotive", "name": "Automotive"},
    {"slug": "sports", "name": "Sports"},
    {"slug": "maternity", "name": "Maternity"},
    {"slug": "architecture", "name": "Architecture"},
]


def ensure_initial_niches(db: Session) -> None:
    now = datetime.now(timezone.utc)
    existing = {
        row.slug: row
        for row in db.execute(select(Niche).where(Niche.slug.in_([item["slug"] for item in INITIAL_NICHES]))).scalars().all()
    }
    for item in INITIAL_NICHES:
        if item["slug"] in existing:
            continue
        db.add(
            Niche(
                slug=item["slug"],
                name=item["name"],
                description=None,
                is_active=True,
                created_at=now,
                updated_at=now,
            )
        )
    db.flush()
    ensure_default_package_decay_curves(db)


def get_active_niche_by_slug(db: Session, slug: str) -> Niche | None:
    return db.execute(select(Niche).where(Niche.slug == slug, Niche.is_active.is_(True))).scalar_one_or_none()


def get_niche_by_slug(db: Session, slug: str) -> Niche | None:
    return db.execute(select(Niche).where(Niche.slug == slug)).scalar_one_or_none()


def get_niche_map_by_slugs(db: Session, slugs: list[str]) -> dict[str, Niche]:
    unique = sorted(set(slugs))
    if not unique:
        return {}
    rows = db.execute(select(Niche).where(Niche.slug.in_(unique), Niche.is_active.is_(True))).scalars().all()
    return {row.slug: row for row in rows}


def get_niche_map_by_ids(db: Session, niche_ids: list[uuid.UUID]) -> dict[uuid.UUID, Niche]:
    unique = list(set(niche_ids))
    if not unique:
        return {}
    rows = db.execute(select(Niche).where(Niche.id.in_(unique))).scalars().all()
    return {row.id: row for row in rows}
