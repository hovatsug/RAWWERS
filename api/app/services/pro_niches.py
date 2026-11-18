"""A photographer's niches: the rules every way of changing them shares.

Two callers: the app's PUT /v1/pro/me/niches (the whole list at once, the
Pro app's niches screen) and the Lightroom plug-in's POST
/v1/delivery/portfolio/niches (add one). Both go through here, so a rule is
written once:

- only an active niche can be chosen;
- at most `niches_max` niches (an onboarding requirement next to
  `niches_min`, default 3; the owner's decision of 2026-11-15). A
  photographer already above it, from before it existed, can keep or
  shrink their list but not grow it;
- at least `niches_min` (default 1): a change cannot take the list below
  it (a photographer already below it may still add);
- exactly one main niche, one of the list (replace_niches);
- a niche with a booking that is not finished, or a booking request still
  waiting, cannot be removed (niche_in_use);
- adding or removing a niche recomputes that niche's skill row and the
  photographer's public (search) index, as the app always has.

Removing a niche keeps everything else (owner's request of 2026-11-17, B4):
the photos tagged with it keep their tag, the packages in it stay as they
are, its skill row (evidence: gigs, reviews, certificates) stays. See
docs/LIGHTROOM_PORTFOLIO.md for what the plug-in does with a collection
whose niche was removed.

The plug-in can only add: it cannot remove a niche or change the main one.
The first niche a photographer gets from it becomes their main niche, so
the default Lightroom collection has somewhere to publish.
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
NICHES_MIN_KEY = "niches_min"
NICHES_MIN_DEFAULT = 1


def niches_max(db: Session) -> int:
    return int(requirement_value(db, NICHES_MAX_KEY, {"count": NICHES_MAX_DEFAULT}).get("count", NICHES_MAX_DEFAULT))


def niches_min(db: Session) -> int:
    return int(requirement_value(db, NICHES_MIN_KEY, {"count": NICHES_MIN_DEFAULT}).get("count", NICHES_MIN_DEFAULT))


def require_within_min(db: Session, *, current: int, new: int) -> None:
    """Refuse a change that takes the list below the minimum."""
    minimum = niches_min(db)
    if new < minimum and new < current:
        raise APIError(
            code="niche_minimum",
            message=f"You need at least {minimum} {'niche' if minimum == 1 else 'niches'}. "
            "Add another niche first, then remove this one.",
            status_code=422,
        )


def why_niche_in_use(db: Session, pro_user_id: uuid.UUID, niche: Niche) -> str | None:
    """Why this niche cannot be removed now, in plain words, or None.

    A booking that is not finished (any gig status but completed, cancelled
    or refunded: a dispute is not finished) or a booking request still
    waiting for an answer, in this niche: removing it would leave a client's
    booking in a niche the photographer says they do not shoot."""
    from app.models.booking import BookingRequest, BookingRequestStatus, ProPackage
    from app.models.gig import Gig
    from app.services.gig_state import TERMINAL_GIG_STATUSES

    gig = db.execute(
        select(Gig.id).where(
            Gig.pro_user_id == pro_user_id,
            Gig.niche_id == niche.id,
            Gig.status.not_in(list(TERMINAL_GIG_STATUSES)),
        ).limit(1)
    ).first()
    if gig is not None:
        return f"You have a booking in {niche.name} that is not finished. You can remove {niche.name} once it is completed or cancelled."
    request = db.execute(
        select(BookingRequest.id)
        .join(ProPackage, ProPackage.id == BookingRequest.package_id)
        .where(
            BookingRequest.pro_user_id == pro_user_id,
            ProPackage.niche_id == niche.id,
            BookingRequest.status == BookingRequestStatus.pending,
        )
        .limit(1)
    ).first()
    if request is not None:
        return f"A client's booking request in {niche.name} is waiting for your answer. Answer it first, then remove {niche.name}."
    return None


def require_within_max(db: Session, *, current: int, new: int) -> None:
    """Refuse a change that grows the list beyond the maximum."""
    limit = niches_max(db)
    if new > limit and new > current:
        raise APIError(
            code="niche_limit_reached",
            message=f"You can have at most {limit} niches, and you have {current}. "
            "To change one, remove a niche in the RAWWERS Pro app first (Settings > Your niches).",
            status_code=422,
        )


def own_niches(db: Session, pro_user_id: uuid.UUID) -> list[ProNiche]:
    return list(db.execute(select(ProNiche).where(ProNiche.pro_user_id == pro_user_id)).scalars().all())


def _lock(db: Session, pro_user_id: uuid.UUID) -> None:
    """One change of a photographer's niches at a time, so two at once
    cannot both pass the maximum or the minimum."""
    db.execute(select(ProProfile.user_id).where(ProProfile.user_id == pro_user_id).with_for_update()).first()


def replace_niches(
    db: Session,
    pro_user_id: uuid.UUID,
    *,
    items: list[tuple[str, object, bool]],
    primary_slug: str | None,
    source: str,
) -> None:
    """Sets this photographer's whole list: `items` = (slug, declared_level,
    is_primary). The main niche is `primary_slug` or the one item marked
    main, which must agree: two different main niches, or none for a list
    that is not empty, is refused. A main niche outside `items` is added to
    the list, as the route always has. Every rule of this module is checked
    before anything is written. Flushes; the caller commits."""
    ensure_initial_niches(db)
    _lock(db, pro_user_id)

    mains = {slug for slug, _level, is_primary in items if is_primary} | ({primary_slug} if primary_slug else set())
    if len(mains) > 1:
        raise APIError(code="one_main_niche", message="Choose one main niche, not " + str(len(mains)) + ".", status_code=422)
    primary_slug = next(iter(mains), None)
    items = [(slug, level) for slug, level, _is_primary in items]

    slugs = [slug for slug, _level in items] + ([primary_slug] if primary_slug else [])
    by_slug = get_niche_map_by_slugs(db, slugs)
    missing = sorted(set(slugs) - set(by_slug))
    if missing:
        raise APIError(code="validation_error", message=f"Unknown niche slug(s): {', '.join(missing)}", status_code=422)

    rows = own_niches(db, pro_user_id)
    current = {row.niche_id: row for row in rows}
    levels: dict[uuid.UUID, object] = {}
    for slug, level in items:
        levels[by_slug[slug].id] = level
    if primary_slug:
        levels.setdefault(by_slug[primary_slug].id, current[by_slug[primary_slug].id].declared_level if by_slug[primary_slug].id in current else None)
    final = set(levels)

    if final and not primary_slug:
        raise APIError(code="main_niche_required", message="Choose your main niche.", status_code=422)

    require_within_max(db, current=len(current), new=len(final))
    require_within_min(db, current=len(current), new=len(final))

    removed = [row for niche_id, row in current.items() if niche_id not in final]
    if removed:
        names = {n.id: n for n in db.execute(select(Niche).where(Niche.id.in_([r.niche_id for r in removed]))).scalars()}
        for row in removed:
            reason = why_niche_in_use(db, pro_user_id, names[row.niche_id])
            if reason:
                raise APIError(code="niche_in_use", message=reason, status_code=409)

    primary_id = by_slug[primary_slug].id if primary_slug else None
    before_primary = next((row.niche_id for row in rows if row.is_primary), None)
    for row in removed:
        db.delete(row)
    added = []
    for niche_id in final:
        row = current.get(niche_id)
        if row is None:
            row = ProNiche(pro_user_id=pro_user_id, niche_id=niche_id, created_at=datetime.now(timezone.utc))
            db.add(row)
            added.append(niche_id)
        row.declared_level = levels[niche_id]
        row.is_primary = niche_id == primary_id
    db.flush()

    for niche_id in set(added) | {row.niche_id for row in removed} | final:
        recompute_pro_niche_skills(db, pro_user_id, niche_id)
    recompute_pro_public_index(db, pro_user_id)

    slug_of = {n.id: n.slug for n in by_slug.values()}
    if removed:
        slug_of.update({n.id: n.slug for n in db.execute(select(Niche).where(Niche.id.in_([r.niche_id for r in removed]))).scalars()})
    if before_primary and before_primary not in slug_of:
        main = db.get(Niche, before_primary)
        if main is not None:
            slug_of[main.id] = main.slug
    if added or removed or before_primary != primary_id:
        add_admin_audit_log(
            db,
            actor_user_id=pro_user_id,
            target_type="pro_niche",
            target_id=str(pro_user_id),
            action="niches_changed",
            metadata={
                "source": source,
                "added": sorted(slug_of[i] for i in added),
                "removed": sorted(slug_of[r.niche_id] for r in removed),
                "main_before": slug_of.get(before_primary) if before_primary else None,
                "main_after": primary_slug,
            },
        )


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
    _lock(db, pro_user_id)
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
