import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CheckConstraint, DateTime, Enum, ForeignKey, Index, Integer, Numeric, Text, UniqueConstraint, text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.media import Base


class DeclaredLevel(str, enum.Enum):
    beginner = "beginner"
    intermediate = "intermediate"
    advanced = "advanced"
    expert = "expert"


class SkillTier(str, enum.Enum):
    rookie = "rookie"
    skilled = "skilled"
    pro = "pro"
    elite = "elite"
    master = "master"


class Niche(Base):
    __tablename__ = "niche"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    slug: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    name_key: Mapped[str | None] = mapped_column(Text, nullable=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    # How the niche's banner is drawn: "image" (the current NicheBanner, or a
    # neutral ground while there is none) or "text" - a deliberate typographic
    # banner with no image at all. Switching keeps every image on file.
    banner_style: Mapped[str] = mapped_column(Text, nullable=False, default="image", server_default="image")
    # One short line under the name on a banner. Localised the way the name
    # is: the text here, and a key slot for when niche copy is translated.
    banner_tagline: Mapped[str | None] = mapped_column(Text, nullable=True)
    banner_tagline_key: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (CheckConstraint("banner_style in ('image', 'text')", name="ck_niche_banner_style"),)


class NicheBanner(Base):
    """One image a niche's banner has used, kept for good.

    `state` is where it stands: the `current` banner, the `previous` one (what
    a revert goes back to), or `past`. At most one of each of the first two
    per niche, held by the database. Removing the current image makes it the
    previous one, so a removal can be reverted like a replacement.
    """

    __tablename__ = "niche_banner"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    media_asset_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=False)
    state: Mapped[str] = mapped_column(Text, nullable=False)
    alt_text: Mapped[str] = mapped_column(Text, nullable=False)
    # What must stay visible, as fractions of the width and height: every
    # crop of the banner is placed around it.
    focal_x: Mapped[Decimal] = mapped_column(Numeric(4, 3), nullable=False, default=Decimal("0.5"))
    focal_y: Mapped[Decimal] = mapped_column(Numeric(4, 3), nullable=False, default=Decimal("0.5"))
    # "owner" (the platform's own upload) or "stock"; a stock image carries
    # its credit, licence and where it came from.
    source: Mapped[str] = mapped_column(Text, nullable=False)
    credit: Mapped[str | None] = mapped_column(Text, nullable=True)
    licence: Mapped[str | None] = mapped_column(Text, nullable=True)
    source_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    width: Mapped[int] = mapped_column(Integer, nullable=False)
    height: Mapped[int] = mapped_column(Integer, nullable=False)
    # How dark the title scrim must be for white text to stay legible on
    # this image, measured when it was uploaded.
    scrim_opacity: Mapped[Decimal] = mapped_column(Numeric(3, 2), nullable=False)
    # A tiny blurred copy, inline, drawn while the real one loads.
    placeholder: Mapped[str] = mapped_column(Text, nullable=False)
    created_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    niche: Mapped[Niche] = relationship(Niche)

    __table_args__ = (
        CheckConstraint("state in ('current', 'previous', 'past')", name="ck_niche_banner_state"),
        CheckConstraint("source in ('owner', 'stock')", name="ck_niche_banner_source"),
        Index("uq_niche_banner_current", "niche_id", unique=True, postgresql_where=text("state = 'current'")),
        Index("uq_niche_banner_previous", "niche_id", unique=True, postgresql_where=text("state = 'previous'")),
    )


class ProNiche(Base):
    __tablename__ = "pro_niche"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    declared_level: Mapped[DeclaredLevel | None] = mapped_column(
        Enum(DeclaredLevel, name="declared_level", native_enum=False, length=64), nullable=True
    )
    is_primary: Mapped[bool] = mapped_column(nullable=False, default=False)
    # What this photographer says about this particular kind of work.
    #
    # Nullable on purpose: most photographers will never write one, and the
    # profile falls back to their general bio rather than showing an empty
    # section under a niche tab. A blank string and "not written" are the same
    # thing to the reader, so the fallback treats them alike.
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (UniqueConstraint("pro_user_id", "niche_id", name="uq_pro_niche_pro_niche"),)


class ProNicheSkill(Base):
    __tablename__ = "pro_niche_skill"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    capability_score: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    certification_score: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    confidence: Mapped[Decimal] = mapped_column(Numeric(3, 2), nullable=False, default=Decimal("0.00"))
    tier: Mapped[SkillTier] = mapped_column(
        Enum(SkillTier, name="skill_tier", native_enum=False, length=64), nullable=False, default=SkillTier.rookie
    )
    score: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    verified: Mapped[bool] = mapped_column(nullable=False, default=False, index=True)
    gigs_completed: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    avg_rating: Mapped[Decimal] = mapped_column(Numeric(3, 2), nullable=False, default=Decimal("0.00"))
    review_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    last_promotion_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    last_demotion_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    # What the evidence alone gives, after hysteresis. `tier` is the effective
    # tier: the override's when there is one, otherwise this. None until the
    # first recompute, which then reads `tier` as the previous evidence - a
    # row written with a tier and no evidence yet must not read as rookie.
    evidence_tier: Mapped[SkillTier | None] = mapped_column(Enum(SkillTier, name="skill_tier", native_enum=False, length=64), nullable=True)
    # An admin's decision, kept until an admin removes it. Any of the three
    # values may be set; the others follow the evidence. See
    # app/services/niche_skills.py.
    override_tier: Mapped[SkillTier | None] = mapped_column(Enum(SkillTier, name="skill_tier", native_enum=False, length=64), nullable=True)
    override_score: Mapped[int | None] = mapped_column(Integer, nullable=True)
    override_verified: Mapped[bool | None] = mapped_column(nullable=True)
    override_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    override_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    override_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    evidence_gigs: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    evidence_reviews: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    evidence_portfolio: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    breakdown: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (UniqueConstraint("pro_user_id", "niche_id", name="uq_pro_niche_skill_pro_niche"),)


class CertificationRecord(Base):
    __tablename__ = "certification_record"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    cert_code: Mapped[str] = mapped_column(Text, nullable=False)
    score: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    __table_args__ = (UniqueConstraint("pro_user_id", "niche_id", "cert_code", name="uq_cert_record_pro_niche_code"),)


class ProNicheSkillEventType(str, enum.Enum):
    recalculated = "recalculated"
    promoted = "promoted"
    demoted = "demoted"
    admin_override = "admin_override"
    override_removed = "override_removed"
    verified_set = "verified_set"


class ProNicheSkillActorType(str, enum.Enum):
    system = "system"
    admin = "admin"


class ProNicheSkillEvent(Base):
    __tablename__ = "pro_niche_skill_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    event_type: Mapped[ProNicheSkillEventType] = mapped_column(
        Enum(ProNicheSkillEventType, name="pro_niche_skill_event_type", native_enum=False, length=64),
        nullable=False,
        index=True,
    )
    from_tier: Mapped[str | None] = mapped_column(Text, nullable=True)
    to_tier: Mapped[str | None] = mapped_column(Text, nullable=True)
    score_before: Mapped[int | None] = mapped_column(Integer, nullable=True)
    score_after: Mapped[int | None] = mapped_column(Integer, nullable=True)
    reasons: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    actor_type: Mapped[ProNicheSkillActorType] = mapped_column(
        Enum(ProNicheSkillActorType, name="pro_niche_skill_actor_type", native_enum=False, length=64),
        nullable=False,
    )
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True
    )


class NicheTierPolicy(Base):
    __tablename__ = "niche_tier_policy"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True, unique=True)
    thresholds: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class Badge(Base):
    __tablename__ = "badge"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    code: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    name_key: Mapped[str] = mapped_column(Text, nullable=False)
    description_key: Mapped[str] = mapped_column(Text, nullable=False)
    icon_ref: Mapped[str | None] = mapped_column(Text, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class UserBadge(Base):
    __tablename__ = "user_badge"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    badge_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("badge.id"), nullable=False, index=True)
    awarded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    source: Mapped[str] = mapped_column(Text, nullable=False, default="niche_skill")
    __table_args__ = (UniqueConstraint("user_id", "badge_id", name="uq_user_badge_user_badge"),)
