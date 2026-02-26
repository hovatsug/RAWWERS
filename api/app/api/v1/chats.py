from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.api.v1.pro_onboarding import _booking_request_view, _ensure_pro_profile, _validate_availability
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.booking import BookingRequest, BookingRequestStatus, BookingRequestTransition, ProPackage
from app.models.chat import ChatHandoff, ChatMessage, ChatSenderType, ChatThread, ChatThreadStatus
from app.schemas.chat import (
    ChatCloseRequest,
    ChatCreateBookingRequestResponse,
    ChatHandoffRequest,
    ChatMessageCreateRequest,
    ChatMessagesAppendResponse,
    ChatMessageView,
    ChatThreadCreateResponse,
    ChatThreadView,
)
from app.schemas.media import CurrentUser
from app.schemas.onboarding import BookingRequestCreateRequest
from app.services.abuse import detect_chat_spam, strip_html
from app.services.analytics import log_event
from app.services.authz import get_user_roles
from app.services.chat_concierge import (
    build_llm_messages,
    estimate_prompt_tokens,
    generate_ai_reply,
    snapshot_pro_context,
)
from app.services.feature_flags import is_feature_enabled
from app.services.followups import schedule_followups
from app.services.rate_limit import enforce_named_rate_limit

settings = get_settings()
router = APIRouter(tags=["chats"])


@router.post("/pros/{pro_user_id}/chats", response_model=ChatThreadCreateResponse)
def create_chat_thread(
    pro_user_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ChatThreadCreateResponse:
    roles = get_user_roles(db, user.user_id)
    if UserRoleType.client not in roles:
        raise APIError(code="forbidden", message="Only clients can create chats", status_code=403)

    _ensure_pro_profile(db, pro_user_id)
    context_snapshot = snapshot_pro_context(db, pro_user_id)
    thread = ChatThread(
        pro_user_id=pro_user_id,
        client_user_id=user.user_id,
        status=ChatThreadStatus.open,
        context_snapshot=context_snapshot,
    )
    db.add(thread)
    db.flush()
    log_event(
        db,
        event_name="chat.started",
        user_id=user.user_id,
        properties={"thread_id": str(thread.id), "pro_user_id": str(pro_user_id)},
    )
    db.commit()
    return ChatThreadCreateResponse(thread_id=thread.id, status=thread.status)


@router.get("/chats/{thread_id}", response_model=ChatThreadView)
def get_chat_thread(
    thread_id: uuid.UUID,
    limit: int = Query(default=50, ge=1, le=200),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ChatThreadView:
    thread = db.get(ChatThread, thread_id)
    if not thread:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    _ensure_thread_access(db, user.user_id, thread)

    messages = db.execute(
        select(ChatMessage)
        .where(ChatMessage.thread_id == thread_id)
        .order_by(ChatMessage.created_at.desc())
        .limit(limit)
    ).scalars().all()
    messages.reverse()
    return _thread_view(thread, messages)


@router.post("/chats/{thread_id}/messages", response_model=ChatMessagesAppendResponse)
def append_chat_message(
    thread_id: uuid.UUID,
    body: ChatMessageCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
    request: Request | None = None,
) -> ChatMessagesAppendResponse:
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
    enforce_named_rate_limit("chat_messages", principal=str(user.user_id))

    thread = db.get(ChatThread, thread_id)
    if not thread:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    sender_type = _resolve_sender_type(db, user.user_id, thread)
    if thread.status == ChatThreadStatus.closed:
        raise APIError(code="invalid_state", message="Thread is closed", status_code=409)

    cleaned_content = strip_html(body.content).strip()
    if not cleaned_content:
        raise APIError(code="validation_error", message="Message cannot be empty", status_code=422)
    if len(cleaned_content) > settings.max_chat_message_length:
        raise APIError(code="validation_error", message="Message too long", status_code=422)

    spam_signal = detect_chat_spam(
        db,
        thread=thread,
        user_id=user.user_id,
        content=cleaned_content,
        ip=_request_ip(request),
    )
    if spam_signal:
        raise APIError(code="rate_limited", message="Message blocked by anti-spam controls", status_code=429)

    message = ChatMessage(
        thread_id=thread.id,
        sender_type=sender_type,
        sender_user_id=user.user_id,
        content=cleaned_content,
        meta={},
    )
    db.add(message)
    db.flush()

    log_event(
        db,
        event_name="chat.message_sent",
        user_id=user.user_id,
        properties={"thread_id": str(thread.id), "sender_type": sender_type.value},
    )

    appended = [_message_view(message)]
    if sender_type == ChatSenderType.client and thread.status == ChatThreadStatus.open:
        ai_message = _maybe_generate_ai_reply(db, thread)
        if ai_message:
            appended.append(_message_view(ai_message))

    db.commit()
    return ChatMessagesAppendResponse(thread_id=thread.id, status=thread.status, appended=appended)


@router.post("/chats/{thread_id}/takeover", response_model=ChatThreadView)
def pro_takeover(
    thread_id: uuid.UUID,
    body: ChatHandoffRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ChatThreadView:
    thread = db.get(ChatThread, thread_id)
    if not thread:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    if user.user_id != thread.pro_user_id:
        raise APIError(code="forbidden", message="Only pro can takeover", status_code=403)

    if thread.status != ChatThreadStatus.pro_takeover:
        thread.status = ChatThreadStatus.pro_takeover
        db.add(ChatHandoff(thread_id=thread.id, reason=body.reason))
        log_event(
            db,
            event_name="chat.handoff",
            user_id=user.user_id,
            properties={"thread_id": str(thread.id), "reason": body.reason or "manual_takeover"},
        )
    db.commit()
    messages = db.execute(select(ChatMessage).where(ChatMessage.thread_id == thread.id).order_by(ChatMessage.created_at.asc())).scalars().all()
    return _thread_view(thread, messages)


@router.post("/chats/{thread_id}/close", response_model=ChatThreadView)
def close_chat(
    thread_id: uuid.UUID,
    body: ChatCloseRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ChatThreadView:
    thread = db.get(ChatThread, thread_id)
    if not thread:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    if user.user_id not in {thread.pro_user_id, thread.client_user_id}:
        raise APIError(code="forbidden", message="Not allowed", status_code=403)

    thread.status = ChatThreadStatus.closed
    if body.reason:
        db.add(
            ChatMessage(
                thread_id=thread.id,
                sender_type=ChatSenderType.system,
                sender_user_id=user.user_id,
                content=f"Thread closed: {body.reason}",
                meta={},
            )
        )
    db.commit()
    messages = db.execute(select(ChatMessage).where(ChatMessage.thread_id == thread.id).order_by(ChatMessage.created_at.asc())).scalars().all()
    return _thread_view(thread, messages)


@router.post("/chats/{thread_id}/create-booking-request", response_model=ChatCreateBookingRequestResponse)
def create_booking_request_from_chat(
    thread_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ChatCreateBookingRequestResponse:
    thread = db.get(ChatThread, thread_id)
    if not thread:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    if user.user_id != thread.client_user_id:
        raise APIError(code="forbidden", message="Only thread client can create booking request", status_code=403)

    draft = (thread.context_snapshot or {}).get("booking_request_draft")
    if not draft:
        raise APIError(code="validation_error", message="No booking draft found in thread", status_code=409)

    try:
        body = BookingRequestCreateRequest(
            package_id=uuid.UUID(draft["package_id"]),
            requested_start=datetime.fromisoformat(draft["requested_start"]),
            requested_end=datetime.fromisoformat(draft["requested_end"]),
            location_text=draft.get("location_text"),
            notes=draft.get("notes"),
        )
    except (KeyError, ValueError, TypeError) as exc:
        raise APIError(code="validation_error", message="Invalid booking draft", status_code=422) from exc

    booking_request = _create_booking_request_from_body(db, thread.pro_user_id, user.user_id, body)
    log_event(
        db,
        event_name="chat.booking_request_created",
        user_id=user.user_id,
        properties={"thread_id": str(thread.id), "booking_request_id": str(booking_request.id)},
    )
    db.commit()
    return ChatCreateBookingRequestResponse(booking_request=_booking_request_view(booking_request))


def _maybe_generate_ai_reply(db: Session, thread: ChatThread) -> ChatMessage | None:
    if not is_feature_enabled(db, "ai_calls_enabled", user_id=thread.client_user_id):
        return _handoff_due_to_limit(db, thread, reason="ai_calls_disabled")

    total_messages = db.execute(
        select(func.count()).select_from(ChatMessage).where(ChatMessage.thread_id == thread.id)
    ).scalar_one()
    if total_messages > settings.llm_max_messages_per_thread:
        return _handoff_due_to_limit(db, thread, reason="message_limit_exceeded")

    history = db.execute(
        select(ChatMessage).where(ChatMessage.thread_id == thread.id).order_by(ChatMessage.created_at.asc())
    ).scalars().all()
    prompt_messages = build_llm_messages(thread, history)
    estimated_prompt = estimate_prompt_tokens(prompt_messages)
    if thread.token_budget_used + estimated_prompt > settings.llm_max_tokens_per_thread:
        return _handoff_due_to_limit(db, thread, reason="token_limit_exceeded")

    generation = generate_ai_reply(thread, history)
    if thread.token_budget_used + estimated_prompt + generation.usage_tokens > settings.llm_max_tokens_per_thread:
        return _handoff_due_to_limit(db, thread, reason="token_limit_exceeded")

    thread.token_budget_used += estimated_prompt + generation.usage_tokens
    ai_metadata: dict = {"usage_tokens": generation.usage_tokens}
    for call in generation.tool_calls:
        if call.name == "booking_request_draft":
            snapshot = dict(thread.context_snapshot or {})
            snapshot["booking_request_draft"] = call.arguments
            thread.context_snapshot = snapshot
            ai_metadata["booking_request_draft"] = call.arguments
            log_event(
                db,
                event_name="chat.booking_draft_created",
                user_id=thread.client_user_id,
                properties={"thread_id": str(thread.id)},
            )

    ai_message = ChatMessage(
        thread_id=thread.id,
        sender_type=ChatSenderType.ai,
        sender_user_id=None,
        content=generation.content,
        meta=ai_metadata,
    )
    db.add(ai_message)
    log_event(
        db,
        event_name="chat.ai_replied",
        user_id=thread.client_user_id,
        properties={"thread_id": str(thread.id)},
    )
    return ai_message


def _handoff_due_to_limit(db: Session, thread: ChatThread, reason: str) -> ChatMessage:
    thread.status = ChatThreadStatus.pro_takeover
    db.add(ChatHandoff(thread_id=thread.id, reason=reason))
    message = ChatMessage(
        thread_id=thread.id,
        sender_type=ChatSenderType.ai,
        sender_user_id=None,
        content="I reached my assistant limit for this thread and asked the photographer to take over.",
        meta={"handoff_reason": reason},
    )
    db.add(message)
    log_event(
        db,
        event_name="chat.handoff",
        user_id=thread.client_user_id,
        properties={"thread_id": str(thread.id), "reason": reason},
    )
    return message


def _create_booking_request_from_body(
    db: Session,
    pro_user_id: uuid.UUID,
    client_user_id: uuid.UUID,
    body: BookingRequestCreateRequest,
) -> BookingRequest:
    if body.requested_end <= body.requested_start:
        raise APIError(code="validation_error", message="requested_end must be after requested_start", status_code=422)

    profile = _ensure_pro_profile(db, pro_user_id)
    is_dev_override = settings.app_env.lower() in {"dev", "development"} and settings.allow_unverified_pro
    if not profile.is_accepting_bookings and not is_dev_override:
        raise APIError(code="validation_error", message="Pro is not accepting bookings", status_code=409)

    package = db.get(ProPackage, body.package_id)
    if not package or package.pro_user_id != pro_user_id or not package.is_active:
        raise APIError(code="validation_error", message="Invalid package", status_code=422)

    _validate_availability(db, pro_user_id, body.requested_start, body.requested_end)

    request = BookingRequest(
        pro_user_id=pro_user_id,
        client_user_id=client_user_id,
        package_id=package.id,
        requested_start=body.requested_start,
        requested_end=body.requested_end,
        location_text=body.location_text,
        notes=body.notes,
        status=BookingRequestStatus.pending,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=24),
    )
    db.add(request)
    db.flush()
    db.add(
        BookingRequestTransition(
            booking_request_id=request.id,
            from_status=BookingRequestStatus.pending,
            to_status=BookingRequestStatus.pending,
            actor_user_id=client_user_id,
            reason="Booking request created from chat draft",
        )
    )
    log_event(
        db,
        event_name="booking.request_created",
        user_id=client_user_id,
        properties={"booking_request_id": str(request.id), "pro_user_id": str(pro_user_id), "package_id": str(package.id)},
    )
    schedule_followups(
        db,
        trigger="booking_request.pending.client",
        user_id=request.client_user_id,
        target_type="booking_request",
        target_id=request.id,
    )
    schedule_followups(
        db,
        trigger="booking_request.pending.pro",
        user_id=request.pro_user_id,
        target_type="booking_request",
        target_id=request.id,
    )
    return request


def _resolve_sender_type(db: Session, user_id: uuid.UUID, thread: ChatThread) -> ChatSenderType:
    if user_id == thread.client_user_id:
        return ChatSenderType.client
    if user_id == thread.pro_user_id:
        return ChatSenderType.pro

    roles = get_user_roles(db, user_id)
    if UserRoleType.admin in roles:
        raise APIError(code="forbidden", message="Admins cannot send chat messages", status_code=403)
    raise APIError(code="forbidden", message="Not allowed", status_code=403)


def _ensure_thread_access(db: Session, user_id: uuid.UUID, thread: ChatThread) -> None:
    if user_id in {thread.pro_user_id, thread.client_user_id}:
        return
    roles = get_user_roles(db, user_id)
    if UserRoleType.admin not in roles:
        raise APIError(code="forbidden", message="Not allowed", status_code=403)


def _thread_view(thread: ChatThread, messages: list[ChatMessage]) -> ChatThreadView:
    return ChatThreadView(
        id=thread.id,
        pro_user_id=thread.pro_user_id,
        client_user_id=thread.client_user_id,
        status=thread.status,
        context_snapshot=thread.context_snapshot or {},
        token_budget_used=thread.token_budget_used,
        created_at=thread.created_at,
        updated_at=thread.updated_at,
        messages=[_message_view(item) for item in messages],
    )


def _message_view(item: ChatMessage) -> ChatMessageView:
    return ChatMessageView(
        id=item.id,
        thread_id=item.thread_id,
        sender_type=item.sender_type,
        sender_user_id=item.sender_user_id,
        content=item.content,
        metadata=item.meta or {},
        created_at=item.created_at,
    )


def _request_ip(request: Request | None) -> str | None:
    if not request:
        return None
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None
