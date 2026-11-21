"""Routes for the app's integration tests. Development and test only.

The app's integration tests run against a local backend. Before running they
ask it which environment it is, and refuse anything but development or test.
When done, the test deletes the account it registered, so a run leaves
nothing behind. In any other environment these routes answer 404 - they are
not merely refused, they are not there - and they are left out of the
published API, so no client is generated for them.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Request, Response
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db_session
from app.core.config import get_settings
from app.core.errors import APIError
from app.db.base import Base
from app.models.admin import UserAccount
from app.schemas.media import CurrentUser

DEV_ENVIRONMENTS = frozenset({"development", "dev", "local", "test"})
TEST_EMAIL_SUFFIX = "@rawwers.test"
DELETABLE_FOR = timedelta(hours=1)
# An account touching any of these is not a throwaway: it has a booking or
# money attached, and deleting it would take that record with it.
MONEY_TABLES = ("booking_request", "gig", "stripe_payment", "ledger_entry", "payout_request", "earnings_entry")


def _require_dev() -> None:
    if (get_settings().app_env or "").strip().lower() not in DEV_ENVIRONMENTS:
        raise APIError(code="not_found", message="Not found", status_code=404)


# Checked before anything else - before authentication - so outside
# development a request learns nothing, not even that the route needs a login.
router = APIRouter(tags=["dev_only"], include_in_schema=False, dependencies=[Depends(_require_dev)])


def _uuid_columns(table) -> list:
    columns = []
    for column in table.columns:
        try:
            if column.type.python_type is uuid.UUID:
                columns.append(column)
        except NotImplementedError:
            continue
    return columns


@router.get("/dev/environment")
def dev_environment() -> dict[str, str]:
    return {"environment": get_settings().app_env}


@router.delete("/dev/test-accounts/me", status_code=204)
def delete_my_test_account(
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db_session),
) -> Response:
    """Delete the caller's account and every row that names it - only a
    throwaway (@rawwers.test) made within the hour with no booking or money
    attached."""
    account = db.get(UserAccount, user.user_id)
    if account is None:
        raise APIError(code="not_found", message="Account not found", status_code=404)
    if not (account.email or "").lower().endswith(TEST_EMAIL_SUFFIX):
        raise APIError(code="forbidden", message="Only a test account can delete itself here.", status_code=403)
    if account.created_at < datetime.now(timezone.utc) - DELETABLE_FOR:
        raise APIError(code="conflict", message="Only an account made in the last hour can delete itself here.", status_code=409)

    tables = [t for t in reversed(Base.metadata.sorted_tables)]
    for table in tables:
        if table.name not in MONEY_TABLES:
            continue
        for column in _uuid_columns(table):
            if db.execute(table.select().where(column == user.user_id).limit(1)).first():
                raise APIError(code="conflict", message=f"This account has rows in {table.name}; not deleting.", status_code=409)

    # Children before parents, so no foreign key stands in the way.
    for table in tables:
        for column in _uuid_columns(table):
            db.execute(table.delete().where(column == user.user_id))
    db.commit()
    return Response(status_code=204)


# --- The fake Mux (services/mux_fake.py): development and tests only, and only
# with MUX_FAKE on. Outside development this whole router answers 404 first.


def _fake_on() -> None:
    from app.services.mux_fake import fake_mux_allowed

    if not fake_mux_allowed():
        raise APIError(code="not_found", message="Not found", status_code=404)


@router.put("/dev/fake-mux/uploads/{upload_id}", dependencies=[Depends(_fake_on)])
async def fake_mux_receive(upload_id: str, request: Request, db: Session = Depends(get_db_session)) -> dict[str, str]:
    """Where the Pro app sends the file when the fake is on, as it would PUT
    it to Mux's upload URL."""
    from app.services.mux_fake import receive_file
    from app.services.presentation_video import MAX_BYTES

    body = await request.body()
    if len(body) > MAX_BYTES:
        raise APIError(code="video_too_large", message="The file is larger than the upload allows.", status_code=413)
    accepted, message = receive_file(db, upload_id, body)
    if not accepted:
        raise APIError(code="not_found", message=message, status_code=404)
    db.commit()
    try:
        from app.tasks.outbox_tasks import dispatch_outbox_events_task

        dispatch_outbox_events_task.delay()
    except Exception:
        pass
    return {"status": message}


def _fake_file(name: str, media_type: str, playback_id: str, token: str | None, audience: str, range_header: str | None = None) -> Response:
    """The file, or the byte range asked for: iOS's player reads a video in
    ranges and will not play one served whole without them."""
    import re
    from pathlib import Path

    from app.services.mux_fake import fake_token_ok

    if not fake_token_ok(token, playback_id, audience):
        raise APIError(code="forbidden", message="This link has expired. Open the video again.", status_code=403)
    data = (Path(__file__).resolve().parents[2] / "dev_assets" / name).read_bytes()
    match = re.fullmatch(r"bytes=(\d*)-(\d*)", (range_header or "").strip())
    if match and (match.group(1) or match.group(2)):
        start = int(match.group(1)) if match.group(1) else max(0, len(data) - int(match.group(2)))
        end = int(match.group(2)) if match.group(1) and match.group(2) else len(data) - 1
        end = min(end, len(data) - 1)
        if start > end:
            return Response(status_code=416, headers={"Content-Range": f"bytes */{len(data)}"})
        return Response(content=data[start:end + 1], status_code=206, media_type=media_type,
                        headers={"Content-Range": f"bytes {start}-{end}/{len(data)}", "Accept-Ranges": "bytes"})
    return Response(content=data, media_type=media_type, headers={"Accept-Ranges": "bytes"})


@router.get("/dev/fake-mux/play/{playback_id}.mp4", dependencies=[Depends(_fake_on)])
def fake_mux_play(playback_id: str, request: Request, token: str | None = None) -> Response:
    """The "playback": the bundled sample clip, whatever was uploaded."""
    return _fake_file("fake_mux_sample.mp4", "video/mp4", playback_id, token, "v", request.headers.get("range"))


@router.get("/dev/fake-mux/poster/{playback_id}.jpg", dependencies=[Depends(_fake_on)])
def fake_mux_poster(playback_id: str, token: str | None = None) -> Response:
    return _fake_file("fake_mux_poster.jpg", "image/jpeg", playback_id, token, "t")


@router.get("/dev/fake-mux/status", dependencies=[Depends(_fake_on)])
def fake_mux_status() -> dict[str, str]:
    """200 means the fake is on (MUX_FAKE=true in a development environment)."""
    return {"fake_mux": "on"}
