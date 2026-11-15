"""A photographer's niches: the rules every way of changing them shares.

Two callers: the app's PUT /v1/pro/me/niches (the whole list at once) and
the Lightroom plug-in's POST /v1/delivery/portfolio/niches (add one). Both
go through here, so a rule is written once:

- only an active niche can be chosen;
- at most `niches_max` niches (an onboarding requirement next to
  `niches_min`, default 3; the owner's decision of 2026-11-15). A
  photographer already above it, from before it existed, can keep or
  shrink their list but not grow it;
- adding a niche recomputes that niche's skill row and the photographer's
  public (search) index, as the app always has.

The plug-in can only add: it cannot remove a niche or change the main one
(docs/LIGHTROOM_PORTFOLIO.md). The first niche a photographer gets from it
becomes their main niche, so the default Lightroom collection has somewhere
to publish.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.admin import ProProfile
from app.models.niche import Niche, ProNiche
from app.services.audit import add_admin_audit_log
from app.services.discovery_index import recompute_pro_public_index
from app.services.launch_ops import requirement_value
from app.services.niche_catalog import ensure_initial_niches, get_niche_map_by_slugs
from app.services.niche_skills import recompute_pro_niche_skills

NICHES_MAX_KEY = "niches_max"
NICHES_MAX_DEFAULT = 3


def niches_max(db: Session) -> int:
    return int(requirement_value(db, NICHES_MAX_KEY, {"count": NICHES_MAX_DEFAULT}).get("count", NICHES_MAX_DEFAULT))


def require_within_max(db: Session, *, current: int, new: int) -> None:
    """Refuse a change that grows the list beyond the maximum."""
    limit = niches_max(db)
    if new > limit and new > current:
        raise APIError(
            code="niche_limit_reached",
            message=f"You can have at most {limit} niches, and you have {current}. "
            "To change one, remove a niche in the RAWWERS Pro app first.",
            status_code=422,
        )


def own_niches(db: Session, pro_user_id: uuid.UUID) -> list[ProNiche]:
    return list(db.execute(select(ProNiche).where(ProNiche.pro_user_id == pro_user_id)).scalars().all())


def add_niche(
    db: Session,
    pro_user_id: uuid.UUID,
    slug: str,
    *,
    source: str,
    device_id: uuid.UUID | None = None,
) -> tuple[Niche, bool]:
    """Adds one niche to this photographer's own profile. Returns the niche
    and whether it became the main one. Flushes; the caller commits."""
    ensure_initial_niches(db)
    # One add at a time per photographer, so two at once cannot both pass
    # the maximum.
    db.execute(select(ProProfile.user_id).where(ProProfile.user_id == pro_user_id).with_for_update()).first()
    niche = get_niche_map_by_slugs(db, [slug]).get(slug)
    if niche is None:
        raise APIError(code="unknown_niche", message=f'There is no niche called "{slug}".', status_code=422)
    rows = own_niches(db, pro_user_id)
    if any(row.niche_id == niche.id for row in rows):
        raise APIError(code="niche_already_yours", message=f"{niche.name} is already one of your niches.", status_code=409)
    require_within_max(db, current=len(rows), new=len(rows) + 1)
    primary = not any(row.is_primary for row in rows)
    db.add(
        ProNiche(
            pro_user_id=pro_user_id,
            niche_id=niche.id,
            declared_level=None,
            is_primary=primary,
            created_at=datetime.now(timezone.utc),
        )
    )
    db.flush()
    recompute_pro_niche_skills(db, pro_user_id, niche.id)
    recompute_pro_public_index(db, pro_user_id)
    add_admin_audit_log(
        db,
        actor_user_id=pro_user_id,
        target_type="pro_niche",
        target_id=f"{pro_user_id}:{niche.slug}",
        action="niche_added",
        metadata={"source": source, "device_id": str(device_id) if device_id else None, "primary": primary},
    )
    return niche, primary
