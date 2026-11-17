"""Emails about new chat messages (BETA_SCOPE #69, owner's decision 2026-11-17).

With the chat assistant off, nothing told anyone that a message was waiting.
Now:

- a client's message emails the photographer ("chat.message_received");
- a photographer's reply emails the client ("chat.reply_received").

Each message queues a check on the outbox for `CHAT_ASSISTANT_HOLD_SECONDS`
later (120 by default). When it runs it sends only if:

- the message is still unread by the recipient (their read marker is older);
- no chat email went to that recipient about this conversation in the last
  15 minutes; if one did, the check moves to the end of that window and
  sends then, if something is still unread;
- the recipient's account is active and not banned or suspended.

The email itself goes through the usual email path (`notify.send_email`):
the approved texts in `email_texts`, the dev allowlist, the suppression
list, the failed-emails list. It names the people by first name only and
never carries the message's text or a link.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.admin import ProProfile, UserAccount, UserAccountStatus
from app.models.chat import ChatMessage, ChatSenderType, ChatThread
from app.models.outbox import OutboxEvent
from app.services.outbox import enqueue_outbox_event

TOPIC = "chat.message_email"
WINDOW = timedelta(minutes=15)
#: The email for each recipient side, and who is writing to them.
KIND_FOR_RECIPIENT = {"pro": "chat.message_received", "client": "chat.reply_received"}
_SENDER_FOR_RECIPIENT = {"pro": ChatSenderType.client, "client": ChatSenderType.pro}


def _delay() -> timedelta:
    return timedelta(seconds=get_settings().chat_assistant_hold_seconds)


def recipient_side(message: ChatMessage) -> str | None:
    """Who a message should be emailed to: the other person, for a message
    a person wrote. The assistant and system notices email nobody."""
    if message.sender_type == ChatSenderType.client:
        return "pro"
    if message.sender_type == ChatSenderType.pro:
        return "client"
    return None


def queue_chat_email(db: Session, thread: ChatThread, message: ChatMessage) -> None:
    """Called when a message is written; the decision is made later."""
    side = recipient_side(message)
    if side is None or (side == "client" and thread.client_user_id is None):
        return
    _enqueue_check(db, thread.id, side, message.id, at=datetime.now(timezone.utc) + _delay(), key=f"chat-email:{message.id}")


def _enqueue_check(db: Session, thread_id: uuid.UUID, side: str, message_id: uuid.UUID, *, at: datetime, key: str) -> None:
    enqueue_outbox_event(
        db,
        topic=TOPIC,
        payload={"thread_id": str(thread_id), "side": side, "message_id": str(message_id)},
        idempotency_key=key,
        idempotency_scope="chat_email",
        available_at=at,
    )


def _first_name(db: Session, user_id: uuid.UUID | None, *, pro: bool) -> str | None:
    if user_id is None:
        return None
    names = []
    if pro:
        profile = db.get(ProProfile, user_id)
        names.append(profile.display_name if profile else None)
    account = db.get(UserAccount, user_id)
    names.append(account.display_name if account else None)
    for name in names:
        if name and name.strip():
            return name.strip().split()[0]
    return None


def _can_be_emailed(db: Session, user_id: uuid.UUID) -> bool:
    from app.services.pro_standing import is_shut_out, latest_ban_action

    account = db.get(UserAccount, user_id)
    if account is None or not account.email or account.status != UserAccountStatus.active:
        return False
    return not is_shut_out(latest_ban_action(db, user_id))


def _last_chat_email_at(db: Session, *, recipient: uuid.UUID, kind: str, thread_id: uuid.UUID) -> datetime | None:
    """When the last chat email about this conversation was queued for this
    recipient. Read from the outbox, where the email is queued in the same
    transaction as this decision, so a burst decided in one batch sees it."""
    return db.execute(
        select(func.max(OutboxEvent.created_at)).where(
            OutboxEvent.topic == "notify.send_email",
            OutboxEvent.payload["type"].astext == kind,
            OutboxEvent.payload["user_id"].astext == str(recipient),
            OutboxEvent.payload["reference_id"].astext == str(thread_id),
        )
    ).scalar_one()


def process_chat_email(db: Session, payload: dict) -> str:
    """The delayed check. Returns what it did, for the log and the tests."""
    thread = db.get(ChatThread, uuid.UUID(payload["thread_id"]))
    message = db.get(ChatMessage, uuid.UUID(payload["message_id"]))
    side = payload.get("side")
    if thread is None or message is None or side not in KIND_FOR_RECIPIENT:
        return "gone"
    if message.sender_type != _SENDER_FOR_RECIPIENT[side]:
        return "not_for_this_side"
    recipient = thread.pro_user_id if side == "pro" else thread.client_user_id
    sender = thread.client_user_id if side == "pro" else thread.pro_user_id
    if recipient is None:
        return "no_recipient"
    kind = KIND_FOR_RECIPIENT[side]

    # One decision at a time per conversation and direction.
    db.execute(select(func.pg_advisory_xact_lock(func.hashtext(f"chat-email:{thread.id}:{side}"))))
    db.refresh(thread)

    read_at = thread.pro_last_read_at if side == "pro" else thread.client_last_read_at
    if read_at is not None and read_at >= message.created_at:
        return "read"
    if not _can_be_emailed(db, recipient):
        return "recipient_unavailable"

    now = datetime.now(timezone.utc)
    last = _last_chat_email_at(db, recipient=recipient, kind=kind, thread_id=thread.id)
    if last is not None and now - last < WINDOW:
        # Told recently: look again when the window ends, once per window.
        _enqueue_check(db, thread.id, side, message.id, at=last + WINDOW, key=f"chat-email-window:{thread.id}:{side}:{last.isoformat()}")
        return "window"

    from app.services.notifications import topic_for_type

    names = {
        "recipient_first_name": _first_name(db, recipient, pro=side == "pro"),
        "sender_first_name": _first_name(db, sender, pro=side == "client"),
    }
    dedupe = f"chat-email:{thread.id}:{side}:{message.id}"
    enqueue_outbox_event(
        db,
        topic="notify.send_email",
        payload={
            "user_id": str(recipient),
            "type": kind,
            "topic": topic_for_type(kind),
            "payload": names,
            "reference_type": "chat_thread",
            "reference_id": str(thread.id),
            "severity": "info",
            "dedupe_key": dedupe,
        },
        idempotency_key=f"notify-email:{dedupe}",
        idempotency_scope="notifications",
    )
    return "queued"
