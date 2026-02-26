from __future__ import annotations

import uuid
from datetime import datetime, time

from pydantic import BaseModel, Field

from app.models.communication import EmailMessageStatus, NotificationDigestMode, NotificationSeverity


class NotificationAction(BaseModel):
    label: str | None = None
    url: str | None = None


class NotificationView(BaseModel):
    id: uuid.UUID
    topic: str
    type: str
    title: str
    body: str
    action: NotificationAction = Field(default_factory=NotificationAction)
    severity: NotificationSeverity
    read_at: datetime | None
    created_at: datetime
    metadata: dict = Field(default_factory=dict)


class NotificationListResponse(BaseModel):
    items: list[NotificationView]
    next_cursor: str | None = None


class NotificationPreferenceView(BaseModel):
    timezone: str
    quiet_hours_enabled: bool
    quiet_start_local: time | None = None
    quiet_end_local: time | None = None
    channel_email_enabled: bool
    channel_inapp_enabled: bool
    digest_mode: NotificationDigestMode


class NotificationPreferenceUpdate(BaseModel):
    timezone: str | None = None
    quiet_hours_enabled: bool | None = None
    quiet_start_local: time | None = None
    quiet_end_local: time | None = None
    channel_email_enabled: bool | None = None
    channel_inapp_enabled: bool | None = None
    digest_mode: NotificationDigestMode | None = None


class NotificationTopicPreferenceView(BaseModel):
    topic: str
    email_enabled: bool
    inapp_enabled: bool


class NotificationTopicPreferenceUpsert(BaseModel):
    topic: str
    email_enabled: bool = True
    inapp_enabled: bool = True


class NotificationTopicPreferenceBulkUpdate(BaseModel):
    items: list[NotificationTopicPreferenceUpsert]


class AdminNotificationLogItem(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID | None = None
    to_email: str
    template_key: str
    subject: str
    status: EmailMessageStatus
    dedupe_key: str
    error: str | None = None
    created_at: datetime
    updated_at: datetime


class AdminNotificationLogResponse(BaseModel):
    items: list[AdminNotificationLogItem]


class AdminNotificationResendRequest(BaseModel):
    email_message_id: uuid.UUID
