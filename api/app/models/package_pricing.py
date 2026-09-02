"""Platform-owned base-package pricing: per-niche decay curves and
per-(niche, tier) entry-price caps. Deliberately separate from
client_rewards_pricing.py's extras/upsell system (ExtraImagePricingPolicy,
ProExtraImagePrice) - different feature, different table, not merged.
"""
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, DateTime, Enum, ForeignKey, JSON, Numeric, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base
from app.models.niche import SkillTier


class PackageDecayCurve(Base):
    """One curve per niche - the shape (not the rate) is niche-owned.
    tiers is a marginal-pricing breakpoint list, e.g.:
        [{"upto": 10, "multiplier": "1.00"},
         {"upto": 25, "multiplier": "0.80"},
         {"upto": null, "multiplier": "0.55"}]
    Marginal: photos 1-10 cost entry_rate * 1.00 each, 11-25 cost
    entry_rate * 0.80 each, 26+ cost entry_rate * 0.55 each. The last
    entry's "upto" is null (open-ended). A single-entry curve with
    multiplier 1.00 means "no decay" (e.g. product/commercial niches).
    """

    __tablename__ = "package_decay_curve"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, unique=True, index=True)
    tiers: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
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
