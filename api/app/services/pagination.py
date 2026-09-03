"""Keyset cursor pagination shared by the collection endpoints.

One convention, used identically by every list route that adopts it:
`?cursor=<opaque>&limit=<n>` in, `{items: [...], next_cursor: <opaque>|null}`
out, newest first.

The cursor is a keyset on `(created_at, id)`, not on `created_at` alone.
A timestamp-only cursor drops rows whenever two records share a
`created_at` — the tied rows straddle the boundary and the ones after the
cut are skipped forever. That is not hypothetical here: seeded fixtures and
any bulk insert produce identical timestamps routinely. Including the
primary key as a tiebreaker makes the ordering total, so every row is
returned exactly once.

The cursor is base64 of "<iso8601>|<uuid>" purely so callers treat it as
opaque and don't build logic on its contents; it is not a security
boundary and carries nothing the caller can't already see.
"""

from __future__ import annotations

import base64
import binascii
import uuid
from datetime import datetime, timezone
from typing import Any, NamedTuple

from sqlalchemy import and_, or_
from sqlalchemy.sql import Select

MAX_LIMIT = 100
DEFAULT_LIMIT = 20


class Cursor(NamedTuple):
    created_at: datetime
    id: uuid.UUID


def encode_cursor(created_at: datetime, row_id: uuid.UUID) -> str:
    raw = f"{created_at.isoformat()}|{row_id}"
    return base64.urlsafe_b64encode(raw.encode()).decode()


def decode_cursor(cursor: str | None) -> Cursor | None:
    """Returns None for anything unparseable.

    A malformed cursor means "start from the beginning", never a 500. It is
    almost always a truncated URL or a stale client, and failing the whole
    request over it helps nobody.
    """
    if not cursor:
        return None
    try:
        raw = base64.urlsafe_b64decode(cursor.encode()).decode()
        stamp, _, row_id = raw.partition("|")
        parsed = datetime.fromisoformat(stamp)
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=timezone.utc)
        return Cursor(created_at=parsed, id=uuid.UUID(row_id))
    except (ValueError, binascii.Error, UnicodeDecodeError):
        return None


def clamp_limit(limit: int | None) -> int:
    if not limit:
        return DEFAULT_LIMIT
    return max(1, min(MAX_LIMIT, limit))


def apply_keyset(query: Select, model: Any, cursor: str | None, limit: int | None) -> Select:
    """Applies newest-first ordering, the keyset predicate, and the limit.

    Fetches one row beyond the limit so the caller can tell "there is a next
    page" from "this page happened to be exactly full" without a second
    count query - see `build_page`.
    """
    parsed = decode_cursor(cursor)
    if parsed is not None:
        query = query.where(
            or_(
                model.created_at < parsed.created_at,
                and_(model.created_at == parsed.created_at, model.id < parsed.id),
            )
        )
    return query.order_by(model.created_at.desc(), model.id.desc()).limit(clamp_limit(limit) + 1)


def build_page(rows: list[Any], limit: int | None) -> tuple[list[Any], str | None]:
    """Splits the over-fetched row set into (page, next_cursor).

    `next_cursor` is None on the last page rather than a cursor that would
    return nothing, so clients can stop on the null instead of paging into
    an empty response to discover the end.
    """
    capped = clamp_limit(limit)
    has_more = len(rows) > capped
    page = rows[:capped]
    if not has_more or not page:
        return page, None
    last = page[-1]
    return page, encode_cursor(last.created_at, last.id)
