"""Photographer accountability: findings, the policy they follow, and the
booking pause.

A finding is an admin's recorded fault on a booking whose price came down
because photos were not delivered. It has a life the photographer can see:
pending (told, able to respond), then confirmed or withdrawn by an admin,
and - only once the window to respond has passed - in effect, with the
consequence the ladder gave it. The numbers are one admin-editable policy
row. The booking pause is a flag of its own, set and lifted by admins only.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class AccountabilityPolicy(Base):
    """One row. Every number the ladder uses."""

    __tablename__ = "accountability_policy"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, default=1)
    #: Days the photographer has to respond, from when they first see it.
    contest_window_days: Mapped[int] = mapped_column(Integer, nullable=False, default=7)
    #: If they never open it, the window starts this many days after it was recorded.
    unseen_grace_days: Mapped[int] = mapped_column(Integer, nullable=False, default=14)
    #: Strikes count back this far.
    rolling_window_months: Mapped[int] = mapped_column(Integer, nullable=False, default=12)
    #: The strike number at which each consequence starts.
    pause_at: Mapped[int] = mapped_column(Integer, nullable=False, default=2)
    suspension_review_at: Mapped[int] = mapped_column(Integer, nullable=False, default=3)
    updated_by_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class PhotographerFinding(Base):
    __tablename__ = "photographer_finding"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    reduction_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("price_reduction.id"), nullable=False)
    #: The reason the photographer is shown - the reduction line's code.
    reason_code: Mapped[str] = mapped_column(Text, nullable=False)
    recorded_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    note: Mapped[str] = mapped_column(Text, nullable=False)
    severe: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    severe_note: Mapped[str | None] = mapped_column(Text, nullable=True)
    #: pending -> confirmed | withdrawn
    status: Mapped[str] = mapped_column(Text, nullable=False, default="pending", index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    first_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    response: Mapped[str | None] = mapped_column(Text, nullable=True)
    responded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    decided_by_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    decided_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    decision_note: Mapped[str | None] = mapped_column(Text, nullable=True)
    #: When a confirmed finding took effect (never before the window ended).
    effective_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True, index=True)
    #: warning | booking_pause | suspension_review, once in effect.
    consequence: Mapped[str | None] = mapped_column(Text, nullable=True)
    strike_number: Mapped[int | None] = mapped_column(Integer, nullable=True)


class BookingPause(Base):
    """New bookings paused by an admin decision. The photographer cannot
    switch it off; only an admin lifts it."""

    __tablename__ = "booking_pause"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    reason: Mapped[str] = mapped_column(Text, nullable=False)
    finding_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("photographer_finding.id"), nullable=True)
    created_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    lifted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    lifted_by_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    lift_note: Mapped[str | None] = mapped_column(Text, nullable=True)
