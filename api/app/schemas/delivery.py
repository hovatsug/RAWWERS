"""Pairing a Lightroom plugin, and what a delivery token may read.

Every field here is new and additive: nothing an existing client reads
changes. What a token may learn about a client is exactly what is listed in
DeliveryGigView - a first name and initial, the shoot date, the package -
and nothing else (no email, phone, address, messages, payments or
earnings); tests/test_delivery_scope.py holds it to that.
"""
from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

# --- the pro app -------------------------------------------------------------------


class PairingCodeResponse(BaseModel):
    #: ABCD-EFGH. Shown once; only its hash is kept.
    code: str
    expires_at: datetime
    valid_minutes: int


class DeliveryDeviceView(BaseModel):
    id: uuid.UUID
    device_name: str
    #: The token's first characters, to tell two devices apart.
    token_prefix: str
    plugin_version: str | None = None
    created_at: datetime
    last_used_at: datetime


class DeliveryDevicesResponse(BaseModel):
    items: list[DeliveryDeviceView]
    max_devices: int


# --- the plugin --------------------------------------------------------------------


class PairRequest(BaseModel):
    code: str = Field(min_length=1, max_length=32)
    #: How the plugin names the machine, e.g. "Ana's MacBook Pro".
    device_name: str = Field(min_length=1, max_length=120)
    plugin_version: str | None = Field(default=None, max_length=32)


class PairResponse(BaseModel):
    #: Shown to the plugin once; keep it in the system keychain.
    token: str
    device_id: uuid.UUID
    photographer_name: str
    update_available: bool | None = None
    latest_version: str


class DeliveryMeResponse(BaseModel):
    photographer_name: str
    device_id: uuid.UUID
    update_available: bool | None = None
    latest_version: str
