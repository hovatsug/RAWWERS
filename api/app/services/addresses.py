"""Shipping addresses, encrypted on the server.

The client sends the address in plain fields over TLS; it is validated and
encrypted here, and only ever stored encrypted (`ShippingAddress.
encrypted_fields` holds {"v": 1, "token": <Fernet token>}). A client-sent
"encrypted" blob was trusted before (prints): anything sent that way is
refused now, because the server cannot know what it holds.

Keys: ADDRESS_ENCRYPTION_KEYS, newest first. Required in production. In
development and tests a fixed key derived from a public string is used, so
dev data stays readable across restarts; it protects nothing and is never
used in production.
"""
from __future__ import annotations

import base64
import hashlib
import hmac
import json
import uuid
from datetime import datetime, timezone

from cryptography.fernet import Fernet, InvalidToken, MultiFernet
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.prints import ShippingAddress

FIELDS = ("name", "line1", "line2", "city", "region", "postal_code", "country", "phone")
REQUIRED = ("name", "line1", "city", "postal_code", "country")
_DEV_KEY_SEED = b"rawwers-development-address-key-not-a-secret"


def _fernet() -> MultiFernet:
    settings = get_settings()
    keys = [k.strip() for k in (settings.address_encryption_keys or "").split(",") if k.strip()]
    if not keys:
        if settings.app_env == "production":
            raise RuntimeError("ADDRESS_ENCRYPTION_KEYS is required in production")
        keys = [base64.urlsafe_b64encode(hashlib.sha256(_DEV_KEY_SEED).digest()).decode()]
    return MultiFernet([Fernet(k) for k in keys])


def encrypt(fields: dict) -> dict:
    return {"v": 1, "token": _fernet().encrypt(json.dumps(fields, sort_keys=True).encode()).decode()}


def decrypt(stored: dict | None) -> dict | None:
    """The address, or None when there is none or it cannot be read (a
    legacy client-sent blob, or a key no longer held)."""
    if not stored or stored.get("v") != 1 or not stored.get("token"):
        return None
    try:
        return json.loads(_fernet().decrypt(stored["token"].encode()))
    except (InvalidToken, ValueError):
        return None


def clean(fields: dict, *, allowed_countries: list[str] | tuple[str, ...]) -> dict:
    out = {key: (str(fields.get(key) or "").strip() or None) for key in FIELDS}
    missing = [key for key in REQUIRED if not out[key]]
    if missing:
        raise APIError(
            code="validation_error",
            message="The address needs " + ", ".join(m.replace("_", " ") for m in missing),
            status_code=422,
        )
    out["country"] = out["country"].upper()
    if out["country"] not in allowed_countries:
        raise APIError(
            code="validation_error",
            message=f"We ship to {', '.join(allowed_countries)} only for now",
            status_code=422,
        )
    if any(len(v) > 200 for v in out.values() if v):
        raise APIError(code="validation_error", message="An address line is too long", status_code=422)
    return out


def postal_hash(postal_code: str | None) -> str | None:
    """A keyed hash of the postcode, for matching without decrypting."""
    if not postal_code:
        return None
    keys = [k.strip() for k in (get_settings().address_encryption_keys or "").split(",") if k.strip()]
    secret = keys[0].encode() if keys else _DEV_KEY_SEED
    return hmac.new(secret, "".join(postal_code.split()).upper().encode(), hashlib.sha256).hexdigest()


def save(
    db: Session,
    *,
    user_id: uuid.UUID,
    fields: dict,
    allowed_countries: list[str] | tuple[str, ...],
    address_id: uuid.UUID | None = None,
) -> ShippingAddress:
    """Validate and store an address (a new row, or the user's own row
    `address_id`), encrypted."""
    cleaned = clean(fields, allowed_countries=allowed_countries)
    row = db.get(ShippingAddress, address_id) if address_id else None
    if row is not None and row.user_id != user_id:
        raise APIError(code="forbidden", message="Cannot reuse another user's shipping address", status_code=403)
    if row is None:
        row = ShippingAddress(user_id=user_id, encrypted_fields={}, country=cleaned["country"])
        db.add(row)
    row.encrypted_fields = encrypt(cleaned)
    row.country = cleaned["country"]
    row.postal_code_hash = postal_hash(cleaned["postal_code"])
    row.updated_at = datetime.now(timezone.utc)
    db.flush()
    return row


def refuse_client_encrypted(payload: dict | None) -> None:
    """A client may not send its own "encrypted" address."""
    if payload and payload.get("encrypted_fields"):
        raise APIError(
            code="validation_error",
            message="Send the address fields; addresses are encrypted on the server",
            status_code=422,
        )
