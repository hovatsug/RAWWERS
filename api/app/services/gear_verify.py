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
from dataclasses import dataclass
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
    return _verify_facts(
        db,
        pro_user_id=pro_user_id,
        category=category,
        facts=_read_or_refuse(data),
        evidence_media_asset_id=evidence_media_asset_id,
    )


def _read_or_refuse(data: bytes) -> ExifFacts:
    try:
        return read_exif(data)
    except ExifUnreadable as exc:
        raise APIError(
            code="validation_error",
            message=f"Could not read camera data from that file: {exc}",
            status_code=422,
        ) from None


def _verify_facts(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    category: GearCategory,
    facts: ExifFacts,
    evidence_media_asset_id: uuid.UUID | None = None,
) -> GearVerification:
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


# ---------------------------------------------------------------------------
# One frame proves the body and the lens it was shot on.
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class FrameResult:
    rows: list[GearVerification]
    #: Things the photographer should be told that are not errors - a frame
    #: that carried no lens information, for one.
    notes: list[str]


def _has_lens_info(facts: ExifFacts) -> bool:
    return bool(facts.lens_model) or facts.min_focal_mm is not None


def _same_gear(
    db: Session, *, pro_user_id: uuid.UUID, category: GearCategory, facts: ExifFacts
) -> GearVerification | None:
    """The photographer's existing row for this same physical gear, if any.

    A second frame from the same camera must not create a second claim on it.
    That matters most for a body that publishes no serial - every real Sony
    tried - where a second lens's frame would otherwise put the same camera back
    in the review queue, once per lens. Any status counts, including a
    rejection: the way past that is to release the row, not to resubmit it.
    """
    rows = db.execute(
        select(GearVerification).where(
            GearVerification.pro_user_id == pro_user_id, GearVerification.category == category
        )
    ).scalars().all()

    if category == GearCategory.camera_body:
        serial = facts.body_serial
        for row in rows:
            if serial and row.serial_number == serial:
                return row
            if not serial and row.serial_number is None and row.make == facts.make and row.model == facts.model:
                return row
    else:
        serial = facts.lens_serial
        for row in rows:
            if serial and row.serial_number == serial:
                return row
            if (
                not serial
                and row.serial_number is None
                and row.model == facts.lens_model
                and row.min_focal_mm == facts.min_focal_mm
                and row.max_focal_mm == facts.max_focal_mm
            ):
                return row
    return None


def verify_frame(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    data: bytes,
    evidence_media_asset_id: uuid.UUID | None = None,
) -> FrameResult:
    """Read one frame and verify what it proves: the body, and the lens if it says.

    A photograph carries both, so asking a photographer to upload one frame per
    piece of kit would make them prove the same camera again for every lens.
    Idempotent: gear already on record is returned as it stands.
    """
    facts = _read_or_refuse(data)
    rows: list[GearVerification] = []
    notes: list[str] = []

    body = _same_gear(db, pro_user_id=pro_user_id, category=GearCategory.camera_body, facts=facts) or _verify_facts(
        db, pro_user_id=pro_user_id, category=GearCategory.camera_body, facts=facts,
        evidence_media_asset_id=evidence_media_asset_id,
    )
    rows.append(body)

    if _has_lens_info(facts):
        lens = _same_gear(db, pro_user_id=pro_user_id, category=GearCategory.lens, facts=facts) or _verify_facts(
            db, pro_user_id=pro_user_id, category=GearCategory.lens, facts=facts,
            evidence_media_asset_id=evidence_media_asset_id,
        )
        rows.append(lens)
    else:
        notes.append(
            "This file carries no lens information. Send a frame shot on the lens you want to verify."
        )
    return FrameResult(rows=rows, notes=notes)


def declare_lighting(
    db: Session, *, pro_user_id: uuid.UUID, make: str | None, model: str, notes: str | None = None
) -> GearVerification:
    """Record lighting the photographer says they own.

    No photograph identifies a strobe, so there is nothing to read and nothing
    to check: it is what they typed, stored as `declared` and never as
    `verified`. (This used to run through the EXIF reader, which recorded the
    *camera's* lens model as the lighting's model.)
    """
    model = (model or "").strip()
    make = (make or "").strip() or None
    if not model:
        raise APIError(code="validation_error", message="Say which lighting you use", status_code=422)

    for row in db.execute(
        select(GearVerification).where(
            GearVerification.pro_user_id == pro_user_id, GearVerification.category == GearCategory.lighting
        )
    ).scalars():
        if (row.model or "").casefold() == model.casefold() and (row.make or "").casefold() == (make or "").casefold():
            return row

    row = GearVerification(
        pro_user_id=pro_user_id,
        category=GearCategory.lighting,
        status=VerificationStatus.declared,
        make=make,
        model=model,
        review_reason="Recorded from your own description; lighting cannot be checked from a photo",
        exif_snapshot={"declared_notes": (notes or "").strip() or None},
        verified_at=datetime.now(timezone.utc),
    )
    db.add(row)
    db.flush()
    return row


def mask_serial(serial: str | None) -> str | None:
    """The last four characters, enough to recognise a camera by."""
    if not serial:
        return None
    return f"\u2022\u2022\u2022\u2022 {serial[-4:]}"


# ---------------------------------------------------------------------------
# A person decides what a machine could not.
# ---------------------------------------------------------------------------


def _pending(db: Session, verification_id: uuid.UUID) -> GearVerification:
    row = db.get(GearVerification, verification_id)
    if row is None:
        raise APIError(code="not_found", message="Gear verification not found", status_code=404)
    if row.status != VerificationStatus.pending_review:
        raise APIError(
            code="invalid_state",
            message=f"This is already {row.status.value}; only items awaiting review can be decided",
            status_code=409,
        )
    return row


def approve_verification(
    db: Session,
    *,
    verification_id: uuid.UUID,
    admin_user_id: uuid.UUID,
    sensor_size: SensorSize | None = None,
    aperture_type: ApertureType | None = None,
    note: str | None = None,
    add_to_reference: bool = False,
) -> GearVerification:
    """Approve, providing whatever the machine could not determine.

    An approved row has to be able to satisfy the floor, so the fact that
    decides that - full-frame for a body, a prime or fixed-aperture zoom for a
    lens - must be known and must qualify. Anything that does not qualify is a
    rejection, not an approval, and is refused here rather than producing a
    verified row that still leaves the photographer short.
    """
    row = _pending(db, verification_id)

    if row.category == GearCategory.camera_body:
        sensor = sensor_size or row.sensor_size
        if sensor is None:
            raise APIError(
                code="validation_error",
                message="This model is not in the reference list: say what its sensor size is",
                status_code=422,
            )
        if sensor != SensorSize.full_frame:
            raise APIError(
                code="validation_error",
                message="Only a full-frame body meets the floor. Reject this one instead.",
                status_code=422,
            )
        row.sensor_size = sensor
    elif row.category == GearCategory.lens:
        aperture = aperture_type or row.aperture_type
        if aperture is None:
            raise APIError(
                code="validation_error",
                message="Say whether this lens is a prime, a fixed-aperture zoom or a variable-aperture zoom",
                status_code=422,
            )
        if aperture not in (ApertureType.prime, ApertureType.fixed_zoom):
            raise APIError(
                code="validation_error",
                message="A variable-aperture zoom does not meet the floor. Reject this one instead.",
                status_code=422,
            )
        row.aperture_type = aperture
    else:
        raise APIError(code="validation_error", message="Only bodies and lenses are reviewed", status_code=422)

    if row.serial_number and _serial_already_claimed(db, row.serial_number, by_other_than=row.pro_user_id):
        raise APIError(
            code="conflict",
            message="That equipment is already registered to another photographer",
            status_code=409,
        )

    now = datetime.now(timezone.utc)
    row.status = VerificationStatus.verified
    row.verified_at = now
    row.reviewed_by = admin_user_id
    row.reviewed_at = now
    row.review_note = (note or "").strip() or None

    if add_to_reference and row.model:
        _teach_reference(db, row)
    db.flush()
    return row


def reject_verification(
    db: Session, *, verification_id: uuid.UUID, admin_user_id: uuid.UUID, reason: str
) -> GearVerification:
    reason = (reason or "").strip()
    if not reason:
        raise APIError(code="validation_error", message="A rejection needs a reason the photographer can read", status_code=422)
    row = _pending(db, verification_id)
    now = datetime.now(timezone.utc)
    row.status = VerificationStatus.rejected
    row.review_reason = reason
    row.reviewed_by = admin_user_id
    row.reviewed_at = now
    row.review_note = reason
    db.flush()
    return row


def _teach_reference(db: Session, row: GearVerification) -> None:
    """Add the model to the reference table, so the next one needs no review.

    Never overwrites an existing entry: a reviewer's one-off call about one
    photographer's camera should not silently redefine what the table says
    about that model for everyone.
    """
    key = normalise_model(row.model)
    if not key:
        return
    if row.category == GearCategory.camera_body and row.sensor_size is not None:
        if db.get(CameraModelReference, key) is None:
            db.add(
                CameraModelReference(
                    normalised_model=key, make=row.make, display_name=row.model, sensor_size=row.sensor_size
                )
            )
    elif row.category == GearCategory.lens and row.aperture_type is not None:
        if db.get(LensModelReference, key) is None:
            db.add(
                LensModelReference(
                    normalised_model=key, make=row.make, display_name=row.model, aperture_type=row.aperture_type
                )
            )
