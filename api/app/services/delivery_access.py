"""Pairing codes and delivery tokens (owner's decision 7).

A pairing code is eight characters from an alphabet with nothing easily
misread (no 0/O, 1/I/L), shown as ABCD-EFGH, valid ten minutes, usable once.
Exchanging it gives the plugin a delivery token: random, stored only as a
hash, scoped to the one photographer, and refused by every route but the
delivery ones. A token stops when the photographer revokes it, when 90 days
pass without it being used, when their password is reset, or when they are
signed out everywhere (a ban does that too). At most three are active per
photographer: a fourth device has to wait for one to be revoked, so a code
that leaks cannot push the photographer's own Mac out.
"""
from __future__ import annotations

import re
import secrets
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import ProProfile, UserAccount
from app.models.delivery_access import DeliveryPairingCode, DeliveryToken
from app.services.auth_tokens import hash_one_time_code, hash_refresh_token

PAIRING_CODE_TTL = timedelta(minutes=10)
TOKEN_IDLE_LIMIT = timedelta(days=90)
MAX_ACTIVE_DEVICES = 3
#: last_used_at is written at most this often: a 400-photo export would
#: otherwise write the token row a thousand times.
LAST_USED_RESOLUTION = timedelta(minutes=1)

CODE_ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
CODE_LENGTH = 8
TOKEN_PREFIX = "rwd_"


def _now() -> datetime:
    return datetime.now(timezone.utc)


def normalise_code(raw: str) -> str:
    """What was typed, as it was issued: case, spaces and the dash ignored."""
    return re.sub(r"[^A-Z0-9]", "", (raw or "").upper())


def _display(code: str) -> str:
    return f"{code[:4]}-{code[4:]}"


def photographer_name(db: Session, pro_user_id: uuid.UUID) -> str:
    """The name the photographer works under, as the plugin shows it."""
    profile = db.get(ProProfile, pro_user_id)
    if profile and profile.display_name:
        return profile.display_name
    account = db.get(UserAccount, pro_user_id)
    return (account.display_name if account else None) or "your RAWWERS account"


def issue_pairing_code(db: Session, pro_user_id: uuid.UUID) -> tuple[str, datetime]:
    """A fresh code for the photographer, retiring any they had not used."""
    now = _now()
    db.execute(
        update(DeliveryPairingCode)
        .where(DeliveryPairingCode.pro_user_id == pro_user_id, DeliveryPairingCode.used_at.is_(None))
        .values(used_at=now)
    )
    code = "".join(secrets.choice(CODE_ALPHABET) for _ in range(CODE_LENGTH))
    row = DeliveryPairingCode(pro_user_id=pro_user_id, code_hash=hash_one_time_code(code), expires_at=now + PAIRING_CODE_TTL)
    db.add(row)
    db.flush()
    return _display(code), row.expires_at


def is_active(token: DeliveryToken, now: datetime | None = None) -> bool:
    now = now or _now()
    return token.revoked_at is None and token.last_used_at > now - TOKEN_IDLE_LIMIT


def active_tokens(db: Session, pro_user_id: uuid.UUID) -> list[DeliveryToken]:
    now = _now()
    rows = db.execute(
        select(DeliveryToken)
        .where(DeliveryToken.pro_user_id == pro_user_id, DeliveryToken.revoked_at.is_(None))
        .order_by(DeliveryToken.last_used_at.desc())
    ).scalars()
    return [row for row in rows if is_active(row, now)]


_INVALID_CODE = "This code is not valid any more. Get a new one in the RAWWERS Pro app: Settings > Connect Lightroom."


def exchange_pairing_code(
    db: Session, *, code: str, device_name: str, plugin_version: str | None
) -> tuple[str, DeliveryToken]:
    """The token for a valid, unused, unexpired code. Every refusal says the
    same thing, so a guess learns nothing about which codes exist."""
    normalised = normalise_code(code)
    row = None
    if len(normalised) == CODE_LENGTH:
        row = db.execute(
            select(DeliveryPairingCode).where(DeliveryPairingCode.code_hash == hash_one_time_code(normalised)).with_for_update()
        ).scalar_one_or_none()
    now = _now()
    if row is None or row.used_at is not None or row.expires_at <= now:
        raise APIError(code="invalid_pairing_code", message=_INVALID_CODE, status_code=400)

    from app.services.authz import enforce_not_banned

    enforce_not_banned(db, row.pro_user_id)
    if len(active_tokens(db, row.pro_user_id)) >= MAX_ACTIVE_DEVICES:
        # The code stays usable: revoking a device in the app and trying
        # again within the ten minutes should just work.
        raise APIError(
            code="too_many_devices",
            message=(
                f"{MAX_ACTIVE_DEVICES} devices are connected already. Revoke one in the RAWWERS Pro app "
                "(Settings > Connect Lightroom), then try this code again."
            ),
            status_code=409,
        )

    row.used_at = now
    token = TOKEN_PREFIX + secrets.token_urlsafe(32)
    device = DeliveryToken(
        pro_user_id=row.pro_user_id,
        token_hash=hash_refresh_token(token),
        token_prefix=token[: len(TOKEN_PREFIX) + 4],
        device_name=(device_name or "").strip()[:120] or "Lightroom Classic",
        plugin_version=(plugin_version or None),
        created_at=now,
        last_used_at=now,
    )
    db.add(device)
    db.flush()
    return token, device


def authenticate(db: Session, raw: str | None, *, plugin_version: str | None = None) -> DeliveryToken:
    """The device behind a delivery token, or a 401 that tells the plugin to
    ask for a new pairing code (`code` is what it reads, not the text)."""
    if not raw or not raw.startswith(TOKEN_PREFIX):
        raise APIError(code="delivery_token_invalid", message="Connect Lightroom again with a new pairing code.", status_code=401)
    token = db.execute(select(DeliveryToken).where(DeliveryToken.token_hash == hash_refresh_token(raw))).scalar_one_or_none()
    if token is None:
        raise APIError(code="delivery_token_invalid", message="Connect Lightroom again with a new pairing code.", status_code=401)
    now = _now()
    if token.revoked_at is not None:
        raise APIError(
            code="delivery_token_revoked",
            message="This device was disconnected. Connect Lightroom again with a new pairing code.",
            status_code=401,
        )
    if not is_active(token, now):
        token.revoked_at = now
        token.revoked_reason = "expired"
        db.commit()
        raise APIError(
            code="delivery_token_expired",
            message="This connection expired after 90 days without use. Connect Lightroom again with a new pairing code.",
            status_code=401,
        )

    from app.services.authz import enforce_not_banned

    enforce_not_banned(db, token.pro_user_id)
    changed = False
    if now - token.last_used_at >= LAST_USED_RESOLUTION:
        token.last_used_at = now
        changed = True
    if plugin_version and plugin_version != token.plugin_version:
        token.plugin_version = plugin_version[:32]
        changed = True
    if changed:
        db.commit()
    return token


def revoke_token(db: Session, *, pro_user_id: uuid.UUID, token_id: uuid.UUID) -> None:
    token = db.get(DeliveryToken, token_id)
    if token is None or token.pro_user_id != pro_user_id:
        raise APIError(code="not_found", message="Device not found", status_code=404)
    if token.revoked_at is None:
        token.revoked_at = _now()
        token.revoked_reason = "photographer"


def revoke_all_delivery_tokens(db: Session, user_id: uuid.UUID, *, reason: str) -> None:
    db.execute(
        update(DeliveryToken)
        .where(DeliveryToken.pro_user_id == user_id, DeliveryToken.revoked_at.is_(None))
        .values(revoked_at=_now(), revoked_reason=reason)
    )


def _version(value: str | None) -> tuple[int, ...] | None:
    if not value or not re.fullmatch(r"\d+(\.\d+){0,3}", value.strip()):
        return None
    return tuple(int(part) for part in value.strip().split("."))


def _older(a: tuple[int, ...], b: tuple[int, ...]) -> bool:
    width = max(len(a), len(b))
    return a + (0,) * (width - len(a)) < b + (0,) * (width - len(b))


def update_available(plugin_version: str | None) -> bool | None:
    """Whether a newer plugin exists; None when the plugin did not say which
    it is (decision 10)."""
    current = _version(plugin_version)
    latest = _version(get_settings().lightroom_plugin_latest_version)
    if current is None or latest is None:
        return None
    return _older(current, latest)


def _minimum() -> tuple[int, ...] | None:
    """The oldest plugin still supported - never above the newest, so a
    minimum set too high cannot refuse the very plugin it points people to."""
    settings = get_settings()
    minimum = _version(settings.lightroom_plugin_min_version)
    latest = _version(settings.lightroom_plugin_latest_version)
    if minimum is not None and latest is not None and _older(latest, minimum):
        return latest
    return minimum


def plugin_supported(plugin_version: str | None) -> bool:
    """False for a plugin older than LIGHTROOM_PLUGIN_MIN_VERSION, which is
    raised only for a breaking change (owner's decision 7).

    A plugin that does not say its version is not refused: every RAWWERS
    plugin sends it, so its absence is not an old plugin, and the token alone
    decides what the caller may do."""
    current, minimum = _version(plugin_version), _minimum()
    if current is None or minimum is None:
        return True
    return not _older(current, minimum)


def require_supported_plugin(plugin_version: str | None) -> None:
    """A 426 that says where the new plugin is. Nothing is revoked: updating
    the plugin is all it takes."""
    if plugin_supported(plugin_version):
        return
    settings = get_settings()
    minimum = ".".join(str(part) for part in _minimum() or ())
    raise APIError(
        code="plugin_outdated",
        message=(
            f"This RAWWERS plug-in ({plugin_version.strip()}) is too old: version {minimum} or newer is needed. "
            f"Get version {settings.lightroom_plugin_latest_version} from Settings > Connect Lightroom in the RAWWERS Pro app."
        ),
        status_code=426,
        details={"minimum_version": minimum, "latest_version": settings.lightroom_plugin_latest_version},
    )
