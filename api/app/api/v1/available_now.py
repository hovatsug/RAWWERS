"""The photographer's "Available now" toggle. See app/services/available_now.py."""
from __future__ import annotations

import uuid
from datetime import datetime

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.schemas.media import CurrentUser
from app.services import available_now
from app.services.authz import get_user_roles
from app.services.scheduling import get_or_create_scheduling_policy

router = APIRouter(tags=["available_now"])


class AvailableNowView(BaseModel):
    # Switched on, until when. The photographer's own state - never shown to
    # clients as a time. (Not `on`: a reserved word in the app's language.)
    switched_on: bool
    available_until: datetime | None = None
    # Whether clients can book at short notice right now: switched on AND the
    # app checked in within the last two minutes.
    effective: bool
    prep_hours: int
    # Packages that may be booked at short notice. Empty means switching on
    # would do nothing - the app asks the photographer to choose some first.
    eligible_package_ids: list[uuid.UUID] = Field(default_factory=list)
    lasts_hours: int


class AvailableNowUpdate(BaseModel):
    switched_on: bool
    prep_hours: int | None = Field(default=None, ge=available_now.PREP_HOURS_MIN, le=available_now.PREP_HOURS_MAX)


def _require_pro(db: Session, user: CurrentUser) -> None:
    if UserRoleType.pro not in get_user_roles(db, user.user_id):
        raise APIError(code="forbidden", message="Role pro required", status_code=403)


def _view(db: Session, policy) -> AvailableNowView:
    return AvailableNowView(
        switched_on=available_now.is_switched_on(policy),
        available_until=policy.available_until if available_now.is_switched_on(policy) else None,
        effective=available_now.short_notice_hours(policy, policy.pro_user_id) is not None,
        prep_hours=policy.short_notice_prep_hours,
        eligible_package_ids=available_now.eligible_package_ids(db, policy.pro_user_id),
        lasts_hours=get_settings().available_now_hours,
    )


@router.get("/pro/available-now", response_model=AvailableNowView)
def get_available_now(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> AvailableNowView:
    _require_pro(db, user)
    policy = get_or_create_scheduling_policy(db, pro_user_id=user.user_id)
    db.commit()
    return _view(db, policy)


@router.put("/pro/available-now", response_model=AvailableNowView)
def put_available_now(
    body: AvailableNowUpdate,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> AvailableNowView:
    """Switch on (for AVAILABLE_NOW_HOURS) or off, optionally setting the
    preparation time. Refused with no_short_notice_packages when nothing
    could be booked that way."""
    _require_pro(db, user)
    policy = get_or_create_scheduling_policy(db, pro_user_id=user.user_id)
    available_now.switch(db, policy, on=body.switched_on, prep_hours=body.prep_hours)
    db.commit()
    # After the commit: the copy never gets ahead of the truth.
    available_now.copy_to_redis(policy)
    return _view(db, policy)
