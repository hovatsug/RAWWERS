from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import JSON, DateTime, Enum, ForeignKey, Integer, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class InviteAllowedRole(str, enum.Enum):
    pro = "pro"
    client = "client"
    both = "both"


class InviteCodeStatus(str, enum.Enum):
    issued = "issued"
    redeemed = "redeemed"
    revoked = "revoked"
    expired = "expired"


class ProOnboardingStatus(str, enum.Enum):
    started = "started"
    profile_completed = "profile_completed"
    portfolio_uploaded = "portfolio_uploaded"
    packages_configured = "packages_configured"
    niches_selected = "niches_selected"
    kyc_submitted = "kyc_submitted"
    kyc_approved = "kyc_approved"
    ready_for_review = "ready_for_review"
    approved_public = "approved_public"
    rejected = "rejected"


class ProOnboardingActorType(str, enum.Enum):
    pro = "pro"
    admin = "admin"
    system = "system"


class RolloutCity(Base):
    __tablename__ = "rollout_city"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    country: Mapped[str] = mapped_column(Text, nullable=False)
    city: Mapped[str] = mapped_column(Text, nullable=False)
    is_pro_onboarding_enabled: Mapped[bool] = mapped_column(nullable=False, default=False)
    is_client_browsing_enabled: Mapped[bool] = mapped_column(nullable=False, default=False)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (UniqueConstraint("country", "city", name="uq_rollout_city_country_city"),)


class RolloutFlagOverride(Base):
    __tablename__ = "rollout_flag_override"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, unique=True, index=True)
    can_access_pro_onboarding: Mapped[bool] = mapped_column(nullable=False, default=False)
    can_access_client_app: Mapped[bool] = mapped_column(nullable=False, default=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    granted_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    granted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class InviteWave(Base):
    __tablename__ = "invite_wave"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    code_prefix: Mapped[str] = mapped_column(Text, nullable=False)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    max_invites: Mapped[int] = mapped_column(Integer, nullable=False)
    used_invites: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    allowed_role: Mapped[InviteAllowedRole] = mapped_column(
        Enum(InviteAllowedRole, name="invite_allowed_role", native_enum=False),
        nullable=False,
        default=InviteAllowedRole.pro,
    )
    allowed_cities: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class InviteCode(Base):
    __tablename__ = "invite_code"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    wave_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("invite_wave.id"), nullable=False, index=True)
    code: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    issued_to_email: Mapped[str | None] = mapped_column(Text, nullable=True)
    issued_by_admin_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    redeemed_by_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    redeemed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    status: Mapped[InviteCodeStatus] = mapped_column(
        Enum(InviteCodeStatus, name="invite_code_status", native_enum=False),
        nullable=False,
        default=InviteCodeStatus.issued,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ProOnboarding(Base):
    __tablename__ = "pro_onboarding"

    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    status: Mapped[ProOnboardingStatus] = mapped_column(
        Enum(ProOnboardingStatus, name="pro_onboarding_status", native_enum=False),
        nullable=False,
        default=ProOnboardingStatus.started,
    )
    current_city: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    invite_code_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("invite_code.id"), nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ProOnboardingEvent(Base):
    __tablename__ = "pro_onboarding_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    from_status: Mapped[str | None] = mapped_column(Text, nullable=True)
    to_status: Mapped[str] = mapped_column(Text, nullable=False)
    actor_type: Mapped[ProOnboardingActorType] = mapped_column(
        Enum(ProOnboardingActorType, name="pro_onboarding_actor_type", native_enum=False),
        nullable=False,
    )
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class OnboardingRequirement(Base):
    __tablename__ = "onboarding_requirement"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    key: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    value: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
