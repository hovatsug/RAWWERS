"""When the photographer's assistant answers a client, and when it stays out.

The assistant answers for a photographer who is not there. While they are
online it waits - CHAT_ASSISTANT_HOLD_SECONDS, two minutes - so a person gets
the first chance; if nobody answers it does, labelled as the assistant
(sender_type "ai"; the apps name it "<photographer>'s assistant", never the
photographer). Whether they are online is presence.photographer_is_online,
which says no until presence exists.

Whether it should still answer is asked twice when the moment comes: before
the model is called, so a conversation a person has picked up costs
nothing, and again just before posting, because the model can take seconds
and the photographer may answer in them.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.chat import ChatMessage, ChatSenderType, ChatThread, ChatThreadStatus
from app.services.ai_concierge import get_or_create_pro_ai_profile
from app.services.feature_flags import is_feature_enabled
from app.services.outbox import enqueue_outbox_event
from app.services import presence


def assistant_enabled(db: Session, thread: ChatThread) -> bool:
    """Switched on for this conversation at all: the platform's flags and the
    photographer's own assistant setting."""
    if is_feature_enabled(db, "ai_chat_kill_switch", user_id=thread.client_user_id):
        return False
    if not is_feature_enabled(db, "ai_chat_enabled_global", user_id=thread.client_user_id):
        return False
    return get_or_create_pro_ai_profile(db, pro_user_id=thread.pro_user_id).is_enabled


def assistant_should_answer(db: Session, thread: ChatThread, after_message_id: str | None) -> bool:
    """Still the assistant's turn: it is on, nobody has taken the conversation
    over or closed it, and the photographer has not written since the
    client's message it would be answering (or at all, for the greeting)."""
    db.refresh(thread)
    if thread.status != ChatThreadStatus.open or not assistant_enabled(db, thread):
        return False
    since = None
    if after_message_id:
        trigger = db.get(ChatMessage, uuid.UUID(after_message_id))
        if trigger is None:
            return False
        since = trigger.created_at
    query = select(ChatMessage.id).where(ChatMessage.thread_id == thread.id, ChatMessage.sender_type == ChatSenderType.pro)
    if since is not None:
        query = query.where(ChatMessage.created_at >= since)
    return db.execute(query.limit(1)).first() is None


def queue_assistant_reply(db: Session, thread: ChatThread, *, after_message: ChatMessage | None, idempotency_key: str) -> None:
    """Ask the assistant to answer - now, or after the hold if the
    photographer is online."""
    if not assistant_enabled(db, thread) or thread.status != ChatThreadStatus.open:
        return
    hold = timedelta(seconds=get_settings().chat_assistant_hold_seconds) if presence.photographer_is_online(db, thread.pro_user_id) else timedelta(0)
    enqueue_outbox_event(
        db,
        topic="ai.reply.generate",
        payload={"thread_id": str(thread.id), "after_message_id": str(after_message.id) if after_message else None},
        idempotency_key=idempotency_key,
        idempotency_scope="ai_reply",
        available_at=datetime.now(timezone.utc) + hold,
    )
