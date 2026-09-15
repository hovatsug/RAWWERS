"""Turning one RAW frame into a verification decision.

The decision has three outcomes, not two. `verified` and `rejected` are the
obvious ones; `pending_review` exists because two common, innocent situations
cannot be resolved automatically:

  - a camera model absent from the reference table, which means new or
    unusual rather than disqualified, and
  - a body that publishes no serial number, which is a firmware decision the
    photographer may not know they made.

Rejecting either would turn away real photographers for reasons that are not
their fault. Passing either silently would make the exclusivity rule a
suggestion. So a human looks, and the review queue has to actually be worked -
an ignored queue is a slower rejection with worse manners.
"""
from __future__ import annotations

import re
import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.gear_verification import (
    ApertureType,
    CameraModelReference,
    GearVerification,
    LensModelReference,
    SensorSize,
    VerificationStatus,
)
from app.models.repair import GearCategory
from app.services.gear_exif import ExifFacts, ExifUnreadable, read_exif


def normalise_model(value: str | None) -> str:
    """One spelling for a model that EXIF writes several ways.

    "ILCE-7M4", "ilce 7m4" and "ILCE7M4  " are the same body. Lowercased with
    every separator dropped, so the lookup does not depend on which firmware
    engineer wrote the string.
    """
    if not value:
        return ""
    return re.sub(r"[^a-z0-9]", "", value.lower())


def _aperture_type_from(facts: ExifFacts) -> ApertureType | None:
    """From LensSpecification, when the body published it."""
    if facts.is_prime:
        return ApertureType.prime
    fixed = facts.is_fixed_aperture
    if fixed is None:
        return None
    return ApertureType.fixed_zoom if fixed else ApertureType.variable_zoom


def _serial_already_claimed(db: Session, serial: str, *, by_other_than) -> bool:
    row = db.execute(
        select(GearVerification).where(
            GearVerification.serial_number == serial,
            GearVerification.status == VerificationStatus.verified,
            GearVerification.pro_user_id != by_other_than,
        )
    ).scalars().first()
    return row is not None


def verify_from_raw(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    category: GearCategory,
    data: bytes,
    evidence_media_asset_id: uuid.UUID | None = None,
) -> GearVerification:
    """Read a frame, decide, and record the decision with its evidence."""
    try:
        facts = read_exif(data)
    except ExifUnreadable as exc:
        raise APIError(
            code="validation_error",
            message=f"Could not read camera data from that file: {exc}",
            status_code=422,
        ) from None

    status = VerificationStatus.verified
    reasons: list[str] = []
    sensor_size: SensorSize | None = None
    aperture_type: ApertureType | None = None

    if category == GearCategory.camera_body:
        reference = db.get(CameraModelReference, normalise_model(facts.model))
        if reference is None:
            status = VerificationStatus.pending_review
            reasons.append(f"Camera model not in our reference list: {facts.model or 'unnamed'}")
        else:
            sensor_size = reference.sensor_size
            if sensor_size != SensorSize.full_frame:
                # A known crop body is a decision, not a question. This is the
                # one case that rejects outright rather than asking a human.
                status = VerificationStatus.rejected
                reasons.append(f"{reference.display_name} is not a full-frame body")

        if facts.body_serial is None:
            # Not a rejection. The exclusivity rule gets a narrow, recorded
            # exception rather than a photographer getting turned away for a
            # firmware setting.
            if status == VerificationStatus.verified:
                status = VerificationStatus.pending_review
            reasons.append("This body published no serial number, so it cannot be claimed exclusively")

    elif category == GearCategory.lens:
        aperture_type = _aperture_type_from(facts)
        if aperture_type is None:
            # The frame did not say. Fall back to the lens table, which exists
            # only for bodies that omit LensSpecification.
            reference = db.get(LensModelReference, normalise_model(facts.lens_model))
            if reference is None:
                status = VerificationStatus.pending_review
                reasons.append(
                    f"Could not tell this lens's aperture from the file: {facts.lens_model or 'unnamed'}"
                )
            else:
                aperture_type = reference.aperture_type

        if aperture_type == ApertureType.variable_zoom:
            status = VerificationStatus.rejected
            reasons.append("A variable-aperture zoom does not meet the lens requirement")

    if category not in (GearCategory.camera_body, GearCategory.lens):
        # Nothing in a photograph identifies the strobe that lit it, so this
        # is the photographer's word. Recorded as `declared` rather than
        # `verified` so no surface can present it with the weight of the EXIF
        # checks above - see the gap doc, where the limitation is written down
        # rather than dressed up.
        status = VerificationStatus.declared
        reasons.append("Recorded from your own description; lighting cannot be checked from a photo")

    serial = facts.body_serial if category == GearCategory.camera_body else facts.lens_serial
    if serial and status == VerificationStatus.verified:
        if _serial_already_claimed(db, serial, by_other_than=pro_user_id):
            raise APIError(
                code="conflict",
                message="That equipment is already registered to another photographer",
                status_code=409,
            )

    row = GearVerification(
        pro_user_id=pro_user_id,
        category=category,
        status=status,
        make=facts.make,
        model=facts.model if category == GearCategory.camera_body else facts.lens_model,
        serial_number=serial,
        sensor_size=sensor_size,
        aperture_type=aperture_type,
        min_focal_mm=facts.min_focal_mm,
        max_focal_mm=facts.max_focal_mm,
        max_aperture=facts.max_aperture_at_min_focal,
        review_reason="; ".join(reasons) or None,
        evidence_media_asset_id=evidence_media_asset_id,
        exif_snapshot={
            "make": facts.make,
            "model": facts.model,
            "lens_model": facts.lens_model,
            "shot_at": facts.shot_at,
            "shot_aperture": str(facts.shot_aperture) if facts.shot_aperture else None,
            "had_body_serial": facts.body_serial is not None,
        },
        verified_at=datetime.now(timezone.utc)
        if status in (VerificationStatus.verified, VerificationStatus.declared)
        else None,
    )
    db.add(row)
    db.flush()
    return row


def release_verification(db: Session, *, pro_user_id: uuid.UUID, verification_id: uuid.UUID) -> None:
    """Give up a claim, freeing its serial for whoever owns the gear next.

    Deleted rather than marked, because a photographer who has sold a body
    should not keep a record implying they still shoot on it - and the partial
    unique index keys on `verified`, so leaving a tombstone would either hold
    the serial hostage or require a second status nobody reads.
    """
    row = db.get(GearVerification, verification_id)
    if row is None or row.pro_user_id != pro_user_id:
        raise APIError(code="not_found", message="Gear not found", status_code=404)
    db.delete(row)
    db.flush()
