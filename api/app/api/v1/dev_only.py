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

from fastapi import APIRouter, Depends, Response
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
