"""What each side of a conversation has not read, and what was said last.

A message is unread for one side when the other side sent it after that
side's read marker (ChatThread.pro_last_read_at / client_last_read_at). For
the photographer that is what the client wrote; for the client, what the
photographer or the assistant wrote. System notices are never unread: they
are not anyone talking.

Worked out from the messages themselves rather than kept as counters: every
place that writes a message (the client, the photographer, the assistant, a
booking notice) would otherwise have to remember to bump one, and the one
that forgot would be the bug.
"""
from __future__ import annotations

import uuid
from collections.abc import Sequence
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Literal

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.chat import ChatMessage, ChatSenderType, ChatThread

Side = Literal["pro", "client"]

_FROM_THE_OTHER_SIDE: dict[str, tuple[ChatSenderType, ...]] = {
    "pro": (ChatSenderType.client,),
    "client": (ChatSenderType.pro, ChatSenderType.ai),
}
_PREVIEW_CHARS = 140


@dataclass(frozen=True)
class InboxLine:
    unread_count: int
    last_message_at: datetime | None
    last_message_preview: str | None


def side_of(thread: ChatThread, user_id: uuid.UUID) -> Side | None:
    if user_id == thread.pro_user_id:
        return "pro"
    if thread.client_user_id is not None and user_id == thread.client_user_id:
        return "client"
    return None


def _marker(side: Side):
    return ChatThread.pro_last_read_at if side == "pro" else ChatThread.client_last_read_at


def inbox_lines(db: Session, threads: Sequence[ChatThread], side: Side) -> dict[uuid.UUID, InboxLine]:
    """Unread count and latest message for each thread, as `side` sees it.
    Two queries for the whole page, not two per thread."""
    ids = [t.id for t in threads]
    if not ids:
        return {}
    unread = dict(
        db.execute(
            select(ChatMessage.thread_id, func.count())
            .join(ChatThread, ChatThread.id == ChatMessage.thread_id)
            .where(
                ChatMessage.thread_id.in_(ids),
                ChatMessage.sender_type.in_(_FROM_THE_OTHER_SIDE[side]),
                (_marker(side).is_(None)) | (ChatMessage.created_at > _marker(side)),
            )
            .group_by(ChatMessage.thread_id)
        ).all()
    )
    latest = {
        thread_id: (created_at, content)
        for thread_id, created_at, content in db.execute(
            select(ChatMessage.thread_id, ChatMessage.created_at, ChatMessage.content)
            .where(ChatMessage.thread_id.in_(ids), ChatMessage.sender_type != ChatSenderType.system)
            .distinct(ChatMessage.thread_id)
            .order_by(ChatMessage.thread_id, ChatMessage.created_at.desc())
        ).all()
    }
    lines = {}
    for thread_id in ids:
        at, content = latest.get(thread_id, (None, None))
        preview = None if content is None else (content if len(content) <= _PREVIEW_CHARS else content[: _PREVIEW_CHARS - 1] + "…")
        lines[thread_id] = InboxLine(unread_count=int(unread.get(thread_id, 0)), last_message_at=at, last_message_preview=preview)
    return lines


def last_activity():
    """Latest message time per thread, for ordering an inbox: a conversation
    moves up when someone writes in it. Falls back to when it was opened."""
    return (
        select(func.coalesce(func.max(ChatMessage.created_at), ChatThread.created_at))
        .where(ChatMessage.thread_id == ChatThread.id, ChatMessage.sender_type != ChatSenderType.system)
        .correlate(ChatThread)
        .scalar_subquery()
    )


def mark_read(db: Session, thread: ChatThread, side: Side) -> None:
    now = datetime.now(timezone.utc)
    if side == "pro":
        thread.pro_last_read_at = now
    else:
        thread.client_last_read_at = now


def photographer_unread(db: Session, pro_user_id: uuid.UUID) -> tuple[int, int]:
    """(conversations with something unread, unread messages) - the badge."""
    rows = db.execute(
        select(ChatMessage.thread_id, func.count())
        .join(ChatThread, ChatThread.id == ChatMessage.thread_id)
        .where(
            ChatThread.pro_user_id == pro_user_id,
            ChatMessage.sender_type.in_(_FROM_THE_OTHER_SIDE["pro"]),
            (ChatThread.pro_last_read_at.is_(None)) | (ChatMessage.created_at > ChatThread.pro_last_read_at),
        )
        .group_by(ChatMessage.thread_id)
    ).all()
    return len(rows), sum(count for _, count in rows)
