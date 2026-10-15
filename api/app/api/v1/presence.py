"""The pro app's presence: heartbeat while open, clear when backgrounded, and
whether clients see the dot. See app/services/presence.py."""
from __future__ import annotations

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.core.errors import APIError
from app.models.admin import ProProfile, UserRoleType
from app.schemas.media import CurrentUser
from app.services import presence
from app.services.authz import get_user_roles
from app.services.rate_limit import enforce_rate_limit

router = APIRouter(tags=["presence"])


class HeartbeatResponse(BaseModel):
    # Whether this beat was written; False when it came within the minimum
    # interval of the last one. Deliberately nothing about time.
    recorded: bool


class ClearResponse(BaseModel):
    cleared: bool = True


class PresenceVisibility(BaseModel):
    visible: bool


def _require_pro(db: Session, user: CurrentUser) -> None:
    if UserRoleType.pro not in get_user_roles(db, user.user_id):
        raise APIError(code="forbidden", message="Role pro required", status_code=403)


@router.post("/pro/presence/heartbeat", response_model=HeartbeatResponse)
def heartbeat(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> HeartbeatResponse:
    """The app is open. Sent at most once a minute while in the foreground."""
    _require_pro(db, user)
    # A token from a session that signed out stays valid until it expires;
    # it must not bring the dot back (presence.sign_out).
    if presence.session_closed(user.refresh_family_id):
        raise APIError(code="session_ended", message="This session has signed out.", status_code=401)
    # A ceiling on top of the minimum interval: a misbehaving client cannot
    # turn this into a write per request.
    enforce_rate_limit(f"presence-heartbeat:{user.user_id}", max_requests=10, window_seconds=60)
    return HeartbeatResponse(recorded=presence.record_heartbeat(db, user.user_id))


@router.delete("/pro/presence", response_model=ClearResponse)
def go_offline(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> ClearResponse:
    """The app went to the background. Best effort - if it never arrives, the
    key expires on its own."""
    _require_pro(db, user)
    presence.clear(user.user_id)
    return ClearResponse()


@router.get("/pro/presence/visibility", response_model=PresenceVisibility)
def get_visibility(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> PresenceVisibility:
    _require_pro(db, user)
    profile = db.get(ProProfile, user.user_id)
    return PresenceVisibility(visible=bool(profile and profile.presence_visible))


@router.put("/pro/presence/visibility", response_model=PresenceVisibility)
def put_visibility(
    body: PresenceVisibility,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PresenceVisibility:
    """Show or hide the dot. Takes effect on the next request anywhere."""
    _require_pro(db, user)
    profile = db.get(ProProfile, user.user_id)
    if profile is None:
        raise APIError(code="not_found", message="Profile not found", status_code=404)
    profile.presence_visible = body.visible
    db.commit()
    presence.copy_visibility_to_key(user.user_id, body.visible)
    return PresenceVisibility(visible=body.visible)
