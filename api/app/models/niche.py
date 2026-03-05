import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import DateTime, Enum, ForeignKey, Integer, JSON, Numeric, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

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
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ProNiche(Base):
    __tablename__ = "pro_niche"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    declared_level: Mapped[DeclaredLevel | None] = mapped_column(
        Enum(DeclaredLevel, name="declared_level", native_enum=False), nullable=True
    )
    is_primary: Mapped[bool] = mapped_column(nullable=False, default=False)
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
        Enum(SkillTier, name="skill_tier", native_enum=False), nullable=False, default=SkillTier.rookie
    )
    score: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    verified: Mapped[bool] = mapped_column(nullable=False, default=False, index=True)
    gigs_completed: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    avg_rating: Mapped[Decimal] = mapped_column(Numeric(3, 2), nullable=False, default=Decimal("0.00"))
    review_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    last_promotion_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    last_demotion_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    evidence_gigs: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    evidence_reviews: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    evidence_portfolio: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    breakdown: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
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
        Enum(ProNicheSkillEventType, name="pro_niche_skill_event_type", native_enum=False),
        nullable=False,
        index=True,
    )
    from_tier: Mapped[str | None] = mapped_column(Text, nullable=True)
    to_tier: Mapped[str | None] = mapped_column(Text, nullable=True)
    score_before: Mapped[int | None] = mapped_column(Integer, nullable=True)
    score_after: Mapped[int | None] = mapped_column(Integer, nullable=True)
    reasons: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    actor_type: Mapped[ProNicheSkillActorType] = mapped_column(
        Enum(ProNicheSkillActorType, name="pro_niche_skill_actor_type", native_enum=False),
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
    thresholds: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
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
