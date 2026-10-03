"""Gear proven to meet the platform's floor.

Deliberately separate from `gear_item`, which exists for theft and insurance
records. A photographer may legitimately log a crop-sensor body there - it is
theirs and they want it recoverable if stolen - and if verification read the
same rows, "I own this" and "this qualifies me to work" would be the same
statement. They are not, and two purposes sharing one table is a mistake this
codebase has already paid for.

A verification may reference the gear item it corresponds to, so a
photographer sees one list rather than two, but the qualifying decision lives
only here.
"""
from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, DateTime, Enum, ForeignKey, Index, Numeric, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base
from app.models.repair import GearCategory


class SensorSize(str, enum.Enum):
    full_frame = "full_frame"
    crop = "crop"
    medium_format = "medium_format"


class ApertureType(str, enum.Enum):
    """Whether a lens holds its maximum aperture across its range."""

    prime = "prime"
    fixed_zoom = "fixed_zoom"
    variable_zoom = "variable_zoom"


class VerificationStatus(str, enum.Enum):
    #: Proved from EXIF against the reference table. Counts toward the floor.
    verified = "verified"
    #: Recorded on the photographer's word, because nothing in a photograph
    #: identifies the equipment that lit it. Lighting only. Kept distinct from
    #: `verified` rather than folded into it: a gate that is unevenly
    #: enforced and presented as uniform is worse than one that says where it
    #: is weaker, and every surface showing this must say "declared".
    declared = "declared"
    #: Something a human has to look at: a model not in the reference table,
    #: or a body that published no serial. Does not count toward the floor,
    #: and is not a rejection.
    pending_review = "pending_review"
    rejected = "rejected"


class GearVerification(Base):
    __tablename__ = "gear_verification"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)

    #: The theft record this corresponds to, when there is one. Nullable on
    #: purpose: verifying gear must not require also logging it for insurance.
    gear_item_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("gear_item.id", ondelete="SET NULL"), nullable=True, index=True
    )

    category: Mapped[GearCategory] = mapped_column(
        Enum(GearCategory, name="gear_category", native_enum=False, length=64), nullable=False
    )
    status: Mapped[VerificationStatus] = mapped_column(
        Enum(VerificationStatus, name="gear_verification_status", native_enum=False, length=64),
        nullable=False,
        default=VerificationStatus.pending_review,
    )

    #: Exactly as EXIF reported them, not as anybody typed them.
    make: Mapped[str | None] = mapped_column(Text, nullable=True)
    model: Mapped[str | None] = mapped_column(Text, nullable=True)
    serial_number: Mapped[str | None] = mapped_column(Text, nullable=True)

    sensor_size: Mapped[SensorSize | None] = mapped_column(
        Enum(SensorSize, name="sensor_size", native_enum=False, length=64), nullable=True
    )
    aperture_type: Mapped[ApertureType | None] = mapped_column(
        Enum(ApertureType, name="aperture_type", native_enum=False, length=64), nullable=True
    )
    min_focal_mm: Mapped[Decimal | None] = mapped_column(Numeric(7, 2), nullable=True)
    max_focal_mm: Mapped[Decimal | None] = mapped_column(Numeric(7, 2), nullable=True)
    max_aperture: Mapped[Decimal | None] = mapped_column(Numeric(5, 2), nullable=True)

    #: Why a human needs to look, in words an admin can act on.
    review_reason: Mapped[str | None] = mapped_column(Text, nullable=True)

    #: The frame that proved it, kept so a decision can be re-examined.
    evidence_media_asset_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    exif_snapshot: Mapped[dict] = mapped_column("metadata", JSONB, nullable=False, default=dict)

    verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    #: Who decided a `pending_review` row, when, and why. Empty for anything a
    #: machine decided, which is itself worth being able to see.
    reviewed_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    review_note: Mapped[str | None] = mapped_column(Text, nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class CameraModelReference(Base):
    """Model name to sensor size.

    An allowlist of full-frame bodies rather than a denylist of crop ones:
    roughly ninety models covers everything full-frame sold since 2005, while
    the crop list runs to several hundred and would never be complete. A model
    absent from here is unknown, not disqualified - it routes to review.

    Matched on a normalised model string, because EXIF writes the same body as
    "ILCE-7M4", "ILCE-7M4 " or "Sony A7 IV" depending on who wrote the firmware.
    """

    __tablename__ = "camera_model_reference"

    normalised_model: Mapped[str] = mapped_column(Text, primary_key=True)
    make: Mapped[str | None] = mapped_column(Text, nullable=True)
    display_name: Mapped[str] = mapped_column(Text, nullable=False)
    sensor_size: Mapped[SensorSize] = mapped_column(
        Enum(SensorSize, name="sensor_size", native_enum=False, length=64), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )


class LensModelReference(Base):
    """Model name to aperture type.

    A fallback, not the primary test. `LensSpecification` answers this from
    the frame itself for most modern bodies, and this covers the ones that
    omit the tag - older bodies, and some third-party lenses that report a
    model name and nothing else.
    """

    __tablename__ = "lens_model_reference"

    normalised_model: Mapped[str] = mapped_column(Text, primary_key=True)
    make: Mapped[str | None] = mapped_column(Text, nullable=True)
    display_name: Mapped[str] = mapped_column(Text, nullable=False)
    aperture_type: Mapped[ApertureType] = mapped_column(
        Enum(ApertureType, name="aperture_type", native_enum=False, length=64), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )


# One account per serial, and only while the claim stands. A partial index so
# releasing gear - which moves the row out of `verified` - frees the serial for
# whoever legitimately owns it next, exactly as selling a body should.
Index(
    "uq_gear_verification_live_serial",
    GearVerification.serial_number,
    unique=True,
    postgresql_where=GearVerification.status == VerificationStatus.verified,
)
Index("ix_gear_verification_pro_status", GearVerification.pro_user_id, GearVerification.status)
