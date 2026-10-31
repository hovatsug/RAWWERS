"""The pro app's side of pairing a Lightroom plugin: a code, and the devices.

Settings > Connect Lightroom shows a one-time code to type into the plugin,
and the devices already paired with their last use and a Revoke button.
"""
import uuid

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.schemas.media import CurrentUser
from app.schemas.delivery import DeliveryDevicesResponse, DeliveryDeviceView, PairingCodeResponse
from app.services.authz import get_user_roles
from app.services.delivery_access import (
    MAX_ACTIVE_DEVICES,
    PAIRING_CODE_TTL,
    active_tokens,
    issue_pairing_code,
    revoke_token,
)
from app.services.rate_limit import enforce_named_rate_limit

router = APIRouter(prefix="/pro/lightroom", tags=["lightroom"])


def _require_pro(db: Session, user: CurrentUser) -> None:
    if UserRoleType.pro not in get_user_roles(db, user.user_id):
        raise APIError(code="forbidden", message="Pro role required", status_code=403)
    # An impersonating admin must not be able to hand a desktop the
    # photographer's delivery rights.
    if user.is_impersonating:
        raise APIError(code="forbidden", message="Not while impersonating", status_code=403)


@router.post("/pairing-code", response_model=PairingCodeResponse)
def create_pairing_code(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> PairingCodeResponse:
    _require_pro(db, user)
    enforce_named_rate_limit("delivery_pairing_issue", principal=str(user.user_id))
    code, expires_at = issue_pairing_code(db, user.user_id)
    db.commit()
    return PairingCodeResponse(code=code, expires_at=expires_at, valid_minutes=int(PAIRING_CODE_TTL.total_seconds() // 60))


@router.get("/devices", response_model=DeliveryDevicesResponse)
def list_devices(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> DeliveryDevicesResponse:
    _require_pro(db, user)
    return DeliveryDevicesResponse(
        items=[DeliveryDeviceView.model_validate(row, from_attributes=True) for row in active_tokens(db, user.user_id)],
        max_devices=MAX_ACTIVE_DEVICES,
    )


@router.delete("/devices/{device_id}", status_code=status.HTTP_204_NO_CONTENT)
def revoke_device(device_id: uuid.UUID, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> Response:
    """Stops the device at once: its next call is refused."""
    _require_pro(db, user)
    revoke_token(db, pro_user_id=user.user_id, token_id=device_id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
