from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.communication import EmailMessage, EmailMessageStatus
from app.schemas.media import CurrentUser
from app.schemas.notifications import (
    AdminNotificationLogItem,
    AdminNotificationLogResponse,
    AdminNotificationResendRequest,
    NotificationListResponse,
    NotificationPreferenceUpdate,
    NotificationPreferenceView,
    NotificationTopicPreferenceBulkUpdate,
    NotificationTopicPreferenceView,
    NotificationView,
)
from app.services.audit import add_admin_audit_log
from app.services.notifications import (
    get_or_create_preferences,
    list_notifications,
    list_topic_preferences,
    mark_all_notifications_read,
    mark_notification_read,
    resend_email_message,
    upsert_topic_preference,
)

router = APIRouter(tags=["notifications"])


@router.get("/me/notifications", response_model=NotificationListResponse)
def get_my_notifications(
    unread_only: bool = Query(default=False),
    limit: int = Query(default=20, ge=1, le=100),
    cursor: str | None = Query(default=None),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> NotificationListResponse:
    items, next_cursor = list_notifications(db, user_id=user.user_id, unread_only=unread_only, limit=limit, cursor=cursor)
    db.commit()
    return NotificationListResponse(
        items=[
            NotificationView(
                id=item.id,
                topic=item.topic,
                type=item.type,
                title=item.title,
                body=item.body,
                action=item.action or {},
                severity=item.severity,
                read_at=item.read_at,
                created_at=item.created_at,
                metadata=item.meta or {},
            )
            for item in items
        ],
        next_cursor=next_cursor,
    )


@router.post("/me/notifications/{notification_id}/read", status_code=status.HTTP_204_NO_CONTENT)
def read_notification(
    notification_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> Response:
    updated = mark_notification_read(db, user_id=user.user_id, notification_id=notification_id)
    db.commit()
    if not updated:
        raise APIError(code="not_found", message="Notification not found", status_code=404)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/me/notifications/read-all", status_code=status.HTTP_204_NO_CONTENT)
def read_all_notifications(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> Response:
    mark_all_notifications_read(db, user_id=user.user_id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/me/notification-preferences", response_model=NotificationPreferenceView)
def get_my_notification_preferences(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> NotificationPreferenceView:
    pref = get_or_create_preferences(db, user.user_id)
    db.commit()
    return NotificationPreferenceView(
        timezone=pref.timezone_name,
        quiet_hours_enabled=pref.quiet_hours_enabled,
        quiet_start_local=pref.quiet_start_local,
        quiet_end_local=pref.quiet_end_local,
        channel_email_enabled=pref.channel_email_enabled,
        channel_inapp_enabled=pref.channel_inapp_enabled,
        digest_mode=pref.digest_mode,
    )


@router.put("/me/notification-preferences", response_model=NotificationPreferenceView)
def put_my_notification_preferences(
    body: NotificationPreferenceUpdate,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> NotificationPreferenceView:
    pref = get_or_create_preferences(db, user.user_id)
    if body.timezone is not None:
        pref.timezone_name = body.timezone
    if body.quiet_hours_enabled is not None:
        pref.quiet_hours_enabled = body.quiet_hours_enabled
    if body.quiet_start_local is not None:
        pref.quiet_start_local = body.quiet_start_local
    if body.quiet_end_local is not None:
        pref.quiet_end_local = body.quiet_end_local
    if body.channel_email_enabled is not None:
        pref.channel_email_enabled = body.channel_email_enabled
    if body.channel_inapp_enabled is not None:
        pref.channel_inapp_enabled = body.channel_inapp_enabled
    if body.digest_mode is not None:
        pref.digest_mode = body.digest_mode
    if pref.quiet_hours_enabled and ((pref.quiet_start_local is None) or (pref.quiet_end_local is None)):
        raise APIError(code="validation_error", message="quiet_start_local and quiet_end_local are required when quiet hours are enabled", status_code=422)
    db.commit()
    return NotificationPreferenceView(
        timezone=pref.timezone_name,
        quiet_hours_enabled=pref.quiet_hours_enabled,
        quiet_start_local=pref.quiet_start_local,
        quiet_end_local=pref.quiet_end_local,
        channel_email_enabled=pref.channel_email_enabled,
        channel_inapp_enabled=pref.channel_inapp_enabled,
        digest_mode=pref.digest_mode,
    )


@router.get("/me/notification-topic-preferences", response_model=list[NotificationTopicPreferenceView])
def get_my_topic_preferences(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> list[NotificationTopicPreferenceView]:
    rows = list_topic_preferences(db, user.user_id)
    db.commit()
    return [
        NotificationTopicPreferenceView(topic=row.topic, email_enabled=row.email_enabled, inapp_enabled=row.inapp_enabled)
        for row in rows
    ]


@router.put("/me/notification-topic-preferences", response_model=list[NotificationTopicPreferenceView])
def put_my_topic_preferences(
    body: NotificationTopicPreferenceBulkUpdate,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> list[NotificationTopicPreferenceView]:
    for item in body.items:
        upsert_topic_preference(
            db,
            user_id=user.user_id,
            topic=item.topic,
            email_enabled=item.email_enabled,
            inapp_enabled=item.inapp_enabled,
        )
    rows = list_topic_preferences(db, user.user_id)
    db.commit()
    return [
        NotificationTopicPreferenceView(topic=row.topic, email_enabled=row.email_enabled, inapp_enabled=row.inapp_enabled)
        for row in rows
    ]


@router.get("/admin/notifications/logs", response_model=AdminNotificationLogResponse)
def admin_notification_logs(
    status_filter: str | None = Query(default=None, alias="status"),
    user_id: uuid.UUID | None = Query(default=None),
    template_key: str | None = Query(default=None),
    limit: int = Query(default=100, ge=1, le=500),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminNotificationLogResponse:
    query = select(EmailMessage).order_by(EmailMessage.created_at.desc()).limit(limit)
    if status_filter:
        try:
            query = query.where(EmailMessage.status == EmailMessageStatus(status_filter))
        except ValueError as exc:
            raise APIError(code="validation_error", message="Invalid status filter", status_code=422) from exc
    if user_id:
        query = query.where(EmailMessage.user_id == user_id)
    if template_key:
        query = query.where(EmailMessage.template_key == template_key)
    rows = db.execute(query).scalars().all()
    db.commit()
    return AdminNotificationLogResponse(
        items=[
            AdminNotificationLogItem(
                id=row.id,
                user_id=row.user_id,
                to_email=row.to_email,
                template_key=row.template_key,
                subject=row.subject,
                status=row.status,
                dedupe_key=row.dedupe_key,
                error=row.error,
                created_at=row.created_at,
                updated_at=row.updated_at,
            )
            for row in rows
        ]
    )


@router.post("/admin/notifications/resend", status_code=status.HTTP_202_ACCEPTED)
def admin_notification_resend(
    body: AdminNotificationResendRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    row = db.get(EmailMessage, body.email_message_id)
    if not row:
        raise APIError(code="not_found", message="Email log not found", status_code=404)
    resend_email_message(db, row)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="email_message",
        target_id=str(row.id),
        action="notification_resend",
        metadata={"template_key": row.template_key, "status": row.status.value},
    )
    db.commit()
    return {"ok": True}
