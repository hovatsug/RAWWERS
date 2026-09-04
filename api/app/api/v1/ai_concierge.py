from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy import and_, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_read_session, get_db_session, get_optional_current_user, require_admin, require_not_banned
from app.api.v1.chats import _booking_request_view, _create_booking_request_from_body
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.chat import AIInteractionLog, ChatMessage, ChatSenderType, ChatThread, ChatThreadStatus
from app.models.launch_ops import RolloutCity
from app.models.ops import FeatureFlagScope
from app.schemas.ai_concierge import (
    AIDraftRequest,
    AIDraftResponse,
    AIInteractionLogListResponse,
    AIInteractionLogView,
    ChatMessageCreateV1Request,
    ChatMessageV1View,
    ChatThreadCreateRequest,
    ChatThreadDetailResponse,
    ChatThreadListResponse,
    ChatThreadSummary,
    CreateBookingFromChatRequest,
    CreateBookingFromChatResponse,
    ProAIProfileUpdateRequest,
    ProAIProfileView,
)
from app.schemas.media import CurrentUser
from app.schemas.onboarding import BookingRequestCreateRequest
from app.services.ai_concierge import generate_ai_reply_for_thread, get_or_create_lead_profile, get_or_create_pro_ai_profile, redact_text
from app.services.analytics import log_event
from app.services.authz import get_user_roles
from app.services.chat_concierge import snapshot_pro_context
from app.services.feature_flags import is_feature_enabled, upsert_feature_flag
from app.services.outbox import enqueue_outbox_event
from app.services.pagination import DEFAULT_LIMIT, MAX_LIMIT, apply_keyset, build_page
from app.services.rate_limit import enforce_named_rate_limit

router = APIRouter(tags=["ai_concierge"])


@router.post("/chat/threads", response_model=ChatThreadSummary)
def create_chat_thread_v1(
    body: ChatThreadCreateRequest,
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_session),
) -> ChatThreadSummary:
    _enforce_ai_chat_enabled(db, pro_user_id=body.pro_user_id, user_id=user.user_id if user else None)
    principal = str(user.user_id) if user else f"guest:{body.session_id or 'anon'}"
    enforce_named_rate_limit("thread_creations", principal=principal)
    if not user and not body.session_id:
        raise APIError(code="validation_error", message="session_id is required for guest chat", status_code=422)

    if user:
        existing = db.execute(
            select(ChatThread).where(
                ChatThread.pro_user_id == body.pro_user_id,
                ChatThread.client_user_id == user.user_id,
            )
        ).scalar_one_or_none()
        if existing:
            return ChatThreadSummary.model_validate(existing, from_attributes=True)

    thread = ChatThread(
        pro_user_id=body.pro_user_id,
        client_user_id=user.user_id if user else None,
        session_id=body.session_id if not user else None,
        status=ChatThreadStatus.open,
        context_snapshot=snapshot_pro_context(db, body.pro_user_id),
    )
    db.add(thread)
    db.flush()
    get_or_create_lead_profile(db, thread_id=thread.id)
    get_or_create_pro_ai_profile(db, pro_user_id=body.pro_user_id)

    db.add(
        ChatMessage(
            thread_id=thread.id,
            sender_type=ChatSenderType.system,
            sender_user_id=None,
            content="You are chatting with an AI assistant for this photographer.",
            content_redacted="You are chatting with an AI assistant for this photographer.",
            meta={"type": "disclaimer"},
        )
    )
    if _should_auto_ai_reply(db, thread):
        enqueue_outbox_event(
            db,
            topic="ai.reply.generate",
            payload={"thread_id": str(thread.id)},
            idempotency_key=f"ai-reply-initial:{thread.id}",
            idempotency_scope="ai_reply",
        )
    log_event(db, event_name="chat.thread_created", user_id=user.user_id if user else None, properties={"thread_id": str(thread.id), "pro_user_id": str(body.pro_user_id)})
    db.commit()
    return ChatThreadSummary.model_validate(thread, from_attributes=True)


@router.get("/chat/threads", response_model=ChatThreadListResponse)
def list_my_chat_threads(
    status: ChatThreadStatus | None = Query(default=None),
    cursor: str | None = Query(default=None),
    limit: int = Query(default=DEFAULT_LIMIT, ge=1, le=MAX_LIMIT),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_read_session),
) -> ChatThreadListResponse:
    """The authenticated client's own chat threads, newest first.

    Mirrors `GET /v1/pro/chat/threads` for the other side of the same
    threads. Without it a client can only reach a thread whose id they
    already hold, so "ask a photographer a question before booking" is a
    one-way door - fine from the pro's inbox, unreachable from the client's.

    Ordered and paginated on `created_at`, not `updated_at`, despite
    last-activity being the more natural sort for a message list. A keyset
    cursor needs a stable sort key, and `updated_at` changes every time a
    message arrives - a thread could move across a page boundary mid-scroll
    and be skipped or repeated. Thread counts per client are small (you chat
    with a handful of photographers, not hundreds), so the ordering costs
    little in practice and the pagination stays correct.

    Guest threads (`session_id` set, no `client_user_id`) are not reachable
    here by design: they have no authenticated owner to scope to.
    """
    query = select(ChatThread).where(ChatThread.client_user_id == user.user_id)
    if status is not None:
        query = query.where(ChatThread.status == status)

    rows = list(db.execute(apply_keyset(query, ChatThread, cursor, limit)).scalars().all())
    page, next_cursor = build_page(rows, limit)
    return ChatThreadListResponse(
        items=[ChatThreadSummary.model_validate(row, from_attributes=True) for row in page],
        next_cursor=next_cursor,
    )


@router.get("/chat/threads/{thread_id}", response_model=ChatThreadDetailResponse)
def get_chat_thread_v1(
    thread_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ChatThreadDetailResponse:
    thread = db.get(ChatThread, thread_id)
    if not thread:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    _ensure_thread_access(db, user.user_id, thread)
    return _thread_detail(db, thread)


@router.post("/chat/threads/{thread_id}/messages", response_model=ChatMessageV1View)
def post_chat_message_v1(
    thread_id: uuid.UUID,
    body: ChatMessageCreateV1Request,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ChatMessageV1View:
    enforce_named_rate_limit("chat_messages", principal=str(user.user_id))
    thread = db.get(ChatThread, thread_id)
    if not thread:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    _ensure_thread_access(db, user.user_id, thread)
    if thread.status == ChatThreadStatus.closed:
        raise APIError(code="invalid_state", message="Thread is closed", status_code=409)

    sender_type = ChatSenderType.pro if user.user_id == thread.pro_user_id else ChatSenderType.client
    if sender_type == ChatSenderType.pro:
        thread.status = ChatThreadStatus.pro_active

    message = ChatMessage(
        thread_id=thread.id,
        sender_type=sender_type,
        sender_user_id=user.user_id,
        content=body.content.strip(),
        content_redacted=redact_text(body.content.strip()),
        meta={},
    )
    db.add(message)
    db.flush()

    log_event(db, event_name="chat.message_sent", user_id=user.user_id, properties={"thread_id": str(thread.id), "sender_type": sender_type.value})
    if sender_type == ChatSenderType.client and _should_auto_ai_reply(db, thread):
        enqueue_outbox_event(
            db,
            topic="ai.reply.generate",
            payload={"thread_id": str(thread.id)},
            idempotency_key=f"ai-reply:{thread.id}:{message.id}",
            idempotency_scope="ai_reply",
        )
    db.commit()
    return ChatMessageV1View(
        id=message.id,
        thread_id=message.thread_id,
        sender_type=message.sender_type,
        sender_user_id=message.sender_user_id,
        content=message.content,
        metadata=message.meta,
        created_at=message.created_at,
    )


@router.post("/chat/threads/{thread_id}/create-booking", response_model=CreateBookingFromChatResponse)
def create_booking_from_chat(
    thread_id: uuid.UUID,
    body: CreateBookingFromChatRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CreateBookingFromChatResponse:
    thread = db.get(ChatThread, thread_id)
    if not thread:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    if thread.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only thread client can create booking", status_code=403)

    booking = _create_booking_request_from_body(
        db,
        thread.pro_user_id,
        user.user_id,
        BookingRequestCreateRequest(
            package_id=body.package_id,
            requested_start=body.requested_start,
            requested_end=body.requested_end,
            location_text=body.location_text,
            notes=body.notes,
        ),
    )
    db.add(
        ChatMessage(
            thread_id=thread.id,
            sender_type=ChatSenderType.system,
            sender_user_id=user.user_id,
            content="Booking request created from chat.",
            content_redacted="Booking request created from chat.",
            meta={"booking_request_id": str(booking.id)},
        )
    )
    log_event(db, event_name="booking.created_from_chat", user_id=user.user_id, properties={"thread_id": str(thread.id), "booking_request_id": str(booking.id)})
    db.commit()
    return CreateBookingFromChatResponse(booking_request=_booking_request_view(booking))


@router.get("/pro/chat/threads", response_model=list[ChatThreadSummary])
def list_pro_threads(
    status: ChatThreadStatus | None = None,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> list[ChatThreadSummary]:
    _require_role(db, user.user_id, UserRoleType.pro)
    stmt = select(ChatThread).where(ChatThread.pro_user_id == user.user_id).order_by(ChatThread.updated_at.desc())
    if status:
        stmt = stmt.where(ChatThread.status == status)
    rows = db.execute(stmt.limit(200)).scalars().all()
    return [ChatThreadSummary.model_validate(row, from_attributes=True) for row in rows]


@router.get("/pro/chat/threads/{thread_id}", response_model=ChatThreadDetailResponse)
def get_pro_thread(
    thread_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ChatThreadDetailResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    thread = db.get(ChatThread, thread_id)
    if not thread or thread.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    return _thread_detail(db, thread)


@router.post("/pro/chat/threads/{thread_id}/messages", response_model=ChatMessageV1View)
def post_pro_message(
    thread_id: uuid.UUID,
    body: ChatMessageCreateV1Request,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ChatMessageV1View:
    _require_role(db, user.user_id, UserRoleType.pro)
    thread = db.get(ChatThread, thread_id)
    if not thread or thread.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    thread.status = ChatThreadStatus.pro_active
    msg = ChatMessage(
        thread_id=thread.id,
        sender_type=ChatSenderType.pro,
        sender_user_id=user.user_id,
        content=body.content.strip(),
        content_redacted=redact_text(body.content.strip()),
        meta={},
    )
    db.add(msg)
    db.commit()
    return ChatMessageV1View(
        id=msg.id,
        thread_id=msg.thread_id,
        sender_type=msg.sender_type,
        sender_user_id=msg.sender_user_id,
        content=msg.content,
        metadata=msg.meta,
        created_at=msg.created_at,
    )


@router.post("/pro/chat/threads/{thread_id}/ai-draft", response_model=AIDraftResponse)
def ai_draft_for_pro(
    thread_id: uuid.UUID,
    body: AIDraftRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> AIDraftResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    thread = db.get(ChatThread, thread_id)
    if not thread or thread.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Chat thread not found", status_code=404)
    _, log_row = generate_ai_reply_for_thread(db, thread=thread, draft_only=True)
    content = ((log_row.output_summary or {}).get("actions") or [{}])[0].get("payload", {}).get("notes")
    if not content:
        content = "Draft: thank the client, confirm details, and propose next booking step."
    db.commit()
    return AIDraftResponse(content=content, metadata={"request_id": log_row.request_id})


@router.get("/admin/ai/logs", response_model=AIInteractionLogListResponse)
def admin_list_ai_logs(
    thread_id: uuid.UUID | None = None,
    pro_user_id: uuid.UUID | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AIInteractionLogListResponse:
    stmt = select(AIInteractionLog).order_by(AIInteractionLog.created_at.desc())
    if thread_id:
        stmt = stmt.where(AIInteractionLog.thread_id == thread_id)
    if pro_user_id:
        stmt = stmt.join(ChatThread, ChatThread.id == AIInteractionLog.thread_id).where(ChatThread.pro_user_id == pro_user_id)
    rows = db.execute(stmt.limit(500)).scalars().all()
    return AIInteractionLogListResponse(items=[AIInteractionLogView.model_validate(row, from_attributes=True) for row in rows])


@router.put("/admin/pros/{pro_user_id}/ai-profile", response_model=ProAIProfileView)
def admin_put_ai_profile(
    pro_user_id: uuid.UUID,
    body: ProAIProfileUpdateRequest,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ProAIProfileView:
    row = get_or_create_pro_ai_profile(db, pro_user_id=pro_user_id)
    row.is_enabled = body.is_enabled
    row.tone = body.tone
    row.faq = body.faq
    row.do_not_say = body.do_not_say
    row.preferred_packages = body.preferred_packages
    db.commit()
    db.refresh(row)
    return ProAIProfileView.model_validate(row, from_attributes=True)


@router.put("/admin/ai/feature-flags")
def admin_ai_feature_flags(
    body: dict,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    updates = 0
    for key in ["ai_chat_enabled_global", "ai_chat_enabled_city", "ai_chat_enabled_pro", "ai_chat_kill_switch"]:
        if key not in body:
            continue
        upsert_feature_flag(db, key=key, is_enabled=bool(body[key]), scope=FeatureFlagScope.global_scope, rules={})
        updates += 1
    db.commit()
    return {"updated": updates}


def _thread_detail(db: Session, thread: ChatThread) -> ChatThreadDetailResponse:
    messages = db.execute(select(ChatMessage).where(ChatMessage.thread_id == thread.id).order_by(ChatMessage.created_at.asc())).scalars().all()
    lead = get_or_create_lead_profile(db, thread_id=thread.id)
    return ChatThreadDetailResponse(
        thread=ChatThreadSummary.model_validate(thread, from_attributes=True),
        messages=[
            ChatMessageV1View(
                id=item.id,
                thread_id=item.thread_id,
                sender_type=item.sender_type,
                sender_user_id=item.sender_user_id,
                content=item.content,
                metadata=item.meta,
                created_at=item.created_at,
            )
            for item in messages
        ],
        lead_profile={
            "thread_id": str(lead.thread_id),
            "niche_slug": lead.niche_slug,
            "desired_date": lead.desired_date.isoformat() if lead.desired_date else None,
            "date_flex_days": lead.date_flex_days,
            "location": lead.location or {},
            "budget_min": str(lead.budget_min) if lead.budget_min is not None else None,
            "budget_max": str(lead.budget_max) if lead.budget_max is not None else None,
            "style_tags": lead.style_tags or [],
            "notes": lead.notes,
        },
    )


def _ensure_thread_access(db: Session, user_id: uuid.UUID, thread: ChatThread) -> None:
    roles = get_user_roles(db, user_id)
    if UserRoleType.admin in roles:
        return
    if user_id == thread.pro_user_id:
        return
    if thread.client_user_id and user_id == thread.client_user_id:
        return
    raise APIError(code="forbidden", message="Not allowed", status_code=403)


def _should_auto_ai_reply(db: Session, thread: ChatThread) -> bool:
    if thread.status != ChatThreadStatus.open:
        return False
    if is_feature_enabled(db, "ai_chat_kill_switch", user_id=thread.client_user_id):
        return False
    if not is_feature_enabled(db, "ai_chat_enabled_global", user_id=thread.client_user_id):
        return False
    ai_profile = get_or_create_pro_ai_profile(db, pro_user_id=thread.pro_user_id)
    return ai_profile.is_enabled


def _require_role(db: Session, user_id: uuid.UUID, role: UserRoleType) -> None:
    roles = get_user_roles(db, user_id)
    if role not in roles:
        raise APIError(code="forbidden", message=f"Role {role.value} required", status_code=403)


def _enforce_ai_chat_enabled(db: Session, *, pro_user_id: uuid.UUID, user_id: uuid.UUID | None) -> None:
    if is_feature_enabled(db, "ai_chat_kill_switch", user_id=user_id):
        raise APIError(code="feature_disabled", message="AI chat is disabled", status_code=503)
    if not is_feature_enabled(db, "ai_chat_enabled_global", user_id=user_id):
        raise APIError(code="feature_disabled", message="AI chat is disabled", status_code=503)

    city_row = db.execute(select(RolloutCity).where(RolloutCity.is_client_browsing_enabled.is_(True))).scalar_one_or_none()
    if not city_row and not is_feature_enabled(db, "ai_chat_enabled_city", user_id=user_id):
        raise APIError(code="feature_disabled", message="AI chat is disabled for this city", status_code=503)
    ai_profile = get_or_create_pro_ai_profile(db, pro_user_id=pro_user_id)
    if not ai_profile.is_enabled and not is_feature_enabled(db, "ai_chat_enabled_pro", user_id=user_id):
        raise APIError(code="feature_disabled", message="AI chat disabled for this pro", status_code=503)
