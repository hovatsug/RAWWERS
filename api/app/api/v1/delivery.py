"""The routes a delivery token can call - the Lightroom plugin's whole API.

Pairing (`POST /delivery/pair`) is the one call without a token. Everything
else here takes `Authorization: Bearer rwd_...` and acts for that token's
photographer only. Every other route in the API refuses the token: they read
a signed access token, which this is not (tests/test_delivery_scope.py).

The plugin sends its version in `X-Rawwers-Plugin-Version`; every answer
carries `X-Rawwers-Update-Available` when a newer plugin exists (decision 10).
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass

from fastapi import APIRouter, Depends, Header, Request, Response
from sqlalchemy.orm import Session

from app.api.deps import get_db_session
from app.core.config import get_settings
from app.schemas.delivery import DeliveryMeResponse, PairRequest, PairResponse
from app.services.delivery_access import authenticate, exchange_pairing_code, photographer_name, update_available
from app.services.rate_limit import enforce_named_rate_limit

router = APIRouter(prefix="/delivery", tags=["delivery"])

PLUGIN_VERSION_HEADER = "X-Rawwers-Plugin-Version"
UPDATE_HEADER = "X-Rawwers-Update-Available"


@dataclass(frozen=True)
class DeliveryDevice:
    """Who a delivery call is for: one photographer, through one device."""

    pro_user_id: uuid.UUID
    device_id: uuid.UUID
    plugin_version: str | None


def _say_if_outdated(response: Response, plugin_version: str | None) -> None:
    newer = update_available(plugin_version)
    if newer is not None:
        response.headers[UPDATE_HEADER] = "true" if newer else "false"


def require_delivery_device(
    response: Response,
    authorization: str | None = Header(default=None, alias="Authorization"),
    plugin_version: str | None = Header(default=None, alias=PLUGIN_VERSION_HEADER),
    db: Session = Depends(get_db_session),
) -> DeliveryDevice:
    raw = authorization.split(" ", 1)[1].strip() if authorization and authorization.lower().startswith("bearer ") else None
    token = authenticate(db, raw, plugin_version=plugin_version)
    _say_if_outdated(response, plugin_version)
    return DeliveryDevice(pro_user_id=token.pro_user_id, device_id=token.id, plugin_version=plugin_version)


def _request_ip(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


@router.post("/pair", response_model=PairResponse)
def pair(body: PairRequest, request: Request, response: Response, db: Session = Depends(get_db_session)) -> PairResponse:
    """A pairing code from the pro app, for a delivery token."""
    enforce_named_rate_limit("delivery_pair_all", principal="all")
    enforce_named_rate_limit("delivery_pair_ip", principal=_request_ip(request))
    token, device = exchange_pairing_code(db, code=body.code, device_name=body.device_name, plugin_version=body.plugin_version)
    name = photographer_name(db, device.pro_user_id)
    db.commit()
    _say_if_outdated(response, body.plugin_version)
    return PairResponse(
        token=token,
        device_id=device.id,
        photographer_name=name,
        update_available=update_available(body.plugin_version),
        latest_version=get_settings().lightroom_plugin_latest_version,
    )


@router.get("/me", response_model=DeliveryMeResponse)
def me(device: DeliveryDevice = Depends(require_delivery_device), db: Session = Depends(get_db_session)) -> DeliveryMeResponse:
    """Who the plugin is connected as: "Connected as <name>"."""
    return DeliveryMeResponse(
        photographer_name=photographer_name(db, device.pro_user_id),
        device_id=device.device_id,
        update_available=update_available(device.plugin_version),
        latest_version=get_settings().lightroom_plugin_latest_version,
    )
