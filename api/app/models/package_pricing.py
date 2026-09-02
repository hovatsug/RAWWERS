"""Platform-owned base-package pricing: per-niche decay curves and
per-(niche, tier) entry-price caps. Deliberately separate from
client_rewards_pricing.py's extras/upsell system (ExtraImagePricingPolicy,
ProExtraImagePrice) - different feature, different table, not merged.
"""
import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, DateTime, Enum, ForeignKey, Numeric, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base
from app.models.niche import SkillTier


class PackageCurveType(str, enum.Enum):
    flat = "flat"
    power = "power"
    exponential = "exponential"


class PackageDecayCurve(Base):
    """One curve per niche - the shape (not the rate) is niche-owned.
    Continuous per-photo price function, not a stepped bracket table, so
    the marginal rate never jumps at a boundary:

        power:       p(n) = max(floor, p0 * (n/10) ** (-shape_param))
        exponential: p(n) = max(floor, p0 * exp(-shape_param * (n-10)))
        flat:        p(n) = p0

    p0 is the photographer's entry_rate; floor = floor_pct * p0. Photos
    1-10 are always priced at exactly p0 each (the minimum bundle never
    decays); the curve only shapes photos beyond the 10th. shape_param
    is "a" for power, "k" for exponential, and unused (null) for flat.
    """

    __tablename__ = "package_decay_curve"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, unique=True, index=True)
    curve_type: Mapped[PackageCurveType] = mapped_column(
        Enum(PackageCurveType, name="package_curve_type", native_enum=False), nullable=False, default=PackageCurveType.flat
    )
    shape_param: Mapped[Decimal | None] = mapped_column(Numeric(6, 4), nullable=True)
    floor_pct: Mapped[Decimal] = mapped_column(Numeric(5, 4), nullable=False, default=Decimal("1.0000"))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class NichePackagePriceCap(Base):
    """The cap a photographer's entry (per-photo) price is clamped/validated
    against, keyed by (niche, tier) - mirrors ExtraImagePricingPolicy's
    shape for the extras system, kept as a separate table on purpose."""

    __tablename__ = "niche_package_price_cap"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    tier: Mapped[SkillTier] = mapped_column(Enum(SkillTier, name="skill_tier", native_enum=False), nullable=False)
    entry_price_min: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    entry_price_max: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (UniqueConstraint("niche_id", "tier", name="uq_niche_package_price_cap_niche_tier"),)
