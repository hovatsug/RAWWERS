from __future__ import annotations

import uuid
from datetime import date, datetime, time

from pydantic import BaseModel, Field

from app.models.booking import AvailabilityLocationMode, ConfirmedSlotStatus


class SchedulingPolicyView(BaseModel):
    pro_user_id: uuid.UUID
    slot_length_minutes: int
    buffer_before_minutes: int
    buffer_after_minutes: int
    advance_notice_hours: int
    max_bookings_per_day: int | None = None
    updated_at: datetime


class SchedulingPolicyUpdateRequest(BaseModel):
    slot_length_minutes: int = Field(default=60, ge=15, le=480)
    buffer_before_minutes: int = Field(default=15, ge=0, le=240)
    buffer_after_minutes: int = Field(default=15, ge=0, le=240)
    advance_notice_hours: int = Field(default=24, ge=0, le=720)
    max_bookings_per_day: int | None = Field(default=None, ge=1, le=24)


class AvailabilityRuleItem(BaseModel):
    weekday: int = Field(ge=0, le=6)
    start_local: time
    end_local: time
    timezone: str
    location_mode: AvailabilityLocationMode = AvailabilityLocationMode.both


class AvailabilityRuleView(AvailabilityRuleItem):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    created_at: datetime
    updated_at: datetime


class AvailabilityRulesReplaceRequest(BaseModel):
    rules: list[AvailabilityRuleItem] = Field(default_factory=list)


class AvailabilityRulesResponse(BaseModel):
    items: list[AvailabilityRuleView] = Field(default_factory=list)


class AvailabilityExceptionItem(BaseModel):
    start_at_utc: datetime
    end_at_utc: datetime
    reason: str | None = None


class AvailabilityExceptionView(AvailabilityExceptionItem):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    created_at: datetime


class AvailabilityExceptionsReplaceRequest(BaseModel):
    items: list[AvailabilityExceptionItem] = Field(default_factory=list)


class AvailabilityExceptionsResponse(BaseModel):
    items: list[AvailabilityExceptionView] = Field(default_factory=list)


class SchedulingSlotView(BaseModel):
    start_at_utc: datetime
    end_at_utc: datetime
    timezone: str
    start_local: str
    end_local: str


class SchedulingSlotsResponse(BaseModel):
    slots: list[SchedulingSlotView] = Field(default_factory=list)


class TimeWindowItem(BaseModel):
    start_at_utc: datetime
    end_at_utc: datetime


class BookingTimeWindowsRequest(BaseModel):
    client_timezone: str
    windows: list[TimeWindowItem] = Field(default_factory=list)


class BookingTimeWindowsResponse(BaseModel):
    booking_request_id: uuid.UUID
    id: uuid.UUID
    client_timezone: str
    windows: list[TimeWindowItem] = Field(default_factory=list)


class ConfirmSlotRequest(BaseModel):
    start_at_utc: datetime
    end_at_utc: datetime


class ConfirmedSlotView(BaseModel):
    id: uuid.UUID
    gig_id: uuid.UUID
    pro_user_id: uuid.UUID
    client_user_id: uuid.UUID
    start_at_utc: datetime
    end_at_utc: datetime
    status: ConfirmedSlotStatus
    cancellation_reason: str | None = None
    created_at: datetime
    updated_at: datetime


class CancelSlotRequest(BaseModel):
    reason: str | None = None


class RescheduleRequest(BaseModel):
    client_timezone: str
    proposed_windows: list[TimeWindowItem] = Field(default_factory=list)


class AdminSchedulingConflictResponse(BaseModel):
    items: list[dict] = Field(default_factory=list)


class SchedulingRangeQuery(BaseModel):
    from_date: date
    to_date: date
