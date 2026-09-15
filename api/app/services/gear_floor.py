"""Whether a photographer's verified gear clears the platform's floor.

The floor is universal and binary:

  - one full-frame body, and
  - one qualifying lens: a prime, or a zoom that holds its maximum aperture
    across its whole range.

A photographer needs one qualifying lens, not every lens they own. Owning a
consumer zoom alongside a 35mm prime disqualifies nobody.

Niches whose work is studio-lit by definition add lighting to that floor.
Weddings, product and food, confirmed; corporate is deliberately absent
because much of it is available-light environmental portraiture, and events
is absent until there is real data rather than a guess.

Only `verified` rows count. `pending_review` is a photographer waiting on a
human, which is neither a pass nor a rejection - treating it as either would
make the review queue meaningless in one direction or punitive in the other.
"""
from __future__ import annotations

from dataclasses import dataclass

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.gear_verification import (
    ApertureType,
    GearVerification,
    SensorSize,
    VerificationStatus,
)
from app.models.repair import GearCategory

#: Niches where lighting is a working necessity rather than a preference.
LIGHTING_REQUIRED_NICHES = frozenset({"weddings", "product", "food"})

QUALIFYING_APERTURE_TYPES = frozenset({ApertureType.prime, ApertureType.fixed_zoom})


@dataclass(frozen=True)
class GearFloor:
    """Where a photographer stands against the floor, and what is missing."""

    has_full_frame_body: bool
    has_qualifying_lens: bool
    has_lighting: bool
    lighting_required: bool

    #: Verifications a human still has to look at. Not failures - a
    #: photographer here is waiting on the platform, not on themselves, and
    #: the wording shown to them should say so.
    awaiting_review: int

    #: True when the lighting above is the photographer's word rather than
    #: anything proven, which every surface showing it has to say.
    lighting_is_declared: bool = False

    @property
    def meets_floor(self) -> bool:
        if not (self.has_full_frame_body and self.has_qualifying_lens):
            return False
        return self.has_lighting if self.lighting_required else True

    @property
    def missing(self) -> list[str]:
        gaps: list[str] = []
        if not self.has_full_frame_body:
            gaps.append("full_frame_body")
        if not self.has_qualifying_lens:
            gaps.append("qualifying_lens")
        if self.lighting_required and not self.has_lighting:
            gaps.append("lighting")
        return gaps


def lighting_required_for(niche_slugs: list[str] | set[str] | None) -> bool:
    return bool(set(niche_slugs or ()) & LIGHTING_REQUIRED_NICHES)


def evaluate_gear_floor(db: Session, pro_user_id, *, niche_slugs=None) -> GearFloor:
    rows = db.execute(
        select(GearVerification).where(GearVerification.pro_user_id == pro_user_id)
    ).scalars().all()

    # Body and lens must be EXIF-proven. Lighting is accepted as declared,
    # because nothing in a photograph identifies a strobe - a deliberate,
    # recorded unevenness rather than an oversight.
    verified = [r for r in rows if r.status == VerificationStatus.verified]
    declared_lighting = [
        r for r in rows
        if r.category == GearCategory.lighting
        and r.status in (VerificationStatus.verified, VerificationStatus.declared)
    ]
    awaiting = sum(1 for r in rows if r.status == VerificationStatus.pending_review)

    return GearFloor(
        has_full_frame_body=any(
            r.category == GearCategory.camera_body and r.sensor_size == SensorSize.full_frame
            for r in verified
        ),
        has_qualifying_lens=any(
            r.category == GearCategory.lens and r.aperture_type in QUALIFYING_APERTURE_TYPES
            for r in verified
        ),
        has_lighting=bool(declared_lighting),
        lighting_required=lighting_required_for(niche_slugs),
        lighting_is_declared=any(
            r.status == VerificationStatus.declared for r in declared_lighting
        ),
        awaiting_review=awaiting,
    )


def niche_slugs_for_pro(db: Session, pro_user_id) -> list[str]:
    """The niches a photographer has declared, for the lighting rule.

    Read from their selected niches rather than from their skill rows:
    `recompute_pro_niche_skills` writes a row for every active niche, so
    skills would say every photographer shoots weddings and require lighting
    of all of them.
    """
    from app.models.niche import Niche, ProNiche

    rows = db.execute(
        select(Niche.slug).join(ProNiche, ProNiche.niche_id == Niche.id).where(
            ProNiche.pro_user_id == pro_user_id
        )
    ).scalars().all()
    return list(rows)
