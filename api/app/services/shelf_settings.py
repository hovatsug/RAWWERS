"""The Shelf's settings: the one row, its defaults and its rules.

Seeded on first read. `shelf_enabled` starts on everywhere but production.
In production The Shelf is open only while `shelf_enabled` is on AND the
terms have been approved; the seeded terms are a draft placeholder, so a
fresh production database keeps it shut until the lawyer's text is in.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.niche import SkillTier
from app.models.shelf import SHELF_TERMS_PLACEHOLDER, ShelfSettings

LEVELS = 5

DEFAULTS = {
    "raww_eur_value": Decimal("0.10"),
    "gbp_eur_rate": Decimal("1.17"),
    "shelf_discount_percent": 10,
    "inactivity_months": 24,
    "warning_days": 30,
    "level_band_raww": [100, 300, 1000, 3000, 6000],
    "tier_max_level": {"rookie": 3, "skilled": 4, "pro": 4, "elite": 5, "master": 5},
    "wishlist_max": 3,
    "max_orders_per_month": 3,
    "same_item_cooldown_days": 90,
    "allowed_countries": ["GB"],
    "free_shipping": True,
}

#: What an admin may change with PUT; the terms go through their own calls.
EDITABLE = (*DEFAULTS.keys(), "shelf_enabled")


def _is_production() -> bool:
    return get_settings().app_env == "production"


def shelf_settings(db: Session) -> ShelfSettings:
    row = db.get(ShelfSettings, 1)
    if row is None:
        row = ShelfSettings(
            id=1,
            **DEFAULTS,
            shelf_enabled=not _is_production(),
            terms_text=SHELF_TERMS_PLACEHOLDER,
        )
        db.add(row)
        db.flush()
    return row


def terms_are_draft(row: ShelfSettings) -> bool:
    return row.terms_approved_at is None


def shelf_open(db: Session) -> bool:
    """Whether photographers can use The Shelf now."""
    row = shelf_settings(db)
    if not row.shelf_enabled:
        return False
    return not (_is_production() and terms_are_draft(row))


def _refuse(message: str) -> APIError:
    return APIError(code="validation_error", message=message, status_code=422)


def validate(values: dict) -> dict:
    """The settings as they would be stored, or a 422 naming the problem."""
    out = dict(values)
    for key in ("raww_eur_value", "gbp_eur_rate"):
        out[key] = Decimal(str(out[key]))
        if out[key] <= 0 or out[key] > 100:
            raise _refuse(f"{key} must be above 0")
    ranges = {
        "shelf_discount_percent": (0, 90),
        "inactivity_months": (1, 120),
        "warning_days": (1, 365),
        "wishlist_max": (0, 20),
        "max_orders_per_month": (0, 50),
        "same_item_cooldown_days": (0, 3650),
    }
    for key, (low, high) in ranges.items():
        value = out[key]
        if isinstance(value, bool) or not isinstance(value, int) or not low <= value <= high:
            raise _refuse(f"{key} must be a whole number from {low} to {high}")
    if out["warning_days"] >= out["inactivity_months"] * 30:
        raise _refuse("The warning must come before the RAWWS expire")
    bands = out["level_band_raww"]
    if (
        not isinstance(bands, list)
        or len(bands) != LEVELS
        or any(isinstance(b, bool) or not isinstance(b, int) or b <= 0 for b in bands)
        or any(a >= b for a, b in zip(bands, bands[1:]))
    ):
        raise _refuse(f"level_band_raww must be {LEVELS} whole RAWWS amounts, each above the one before")
    tiers = out["tier_max_level"]
    if not isinstance(tiers, dict) or set(tiers) != {t.value for t in SkillTier}:
        raise _refuse("tier_max_level must give a level for every tier: " + ", ".join(t.value for t in SkillTier))
    if any(isinstance(v, bool) or not isinstance(v, int) or not 1 <= v <= LEVELS for v in tiers.values()):
        raise _refuse(f"Each tier's highest level must be from 1 to {LEVELS}")
    countries = out["allowed_countries"]
    if not isinstance(countries, list) or not countries or any(not isinstance(c, str) or len(c) != 2 or not c.isalpha() for c in countries):
        raise _refuse("allowed_countries must be two-letter country codes")
    out["allowed_countries"] = sorted({c.upper() for c in countries})
    return out


def update_settings(db: Session, *, values: dict, actor_user_id: uuid.UUID) -> tuple[ShelfSettings, dict]:
    """Apply an admin's edit. Returns the row and what changed (old, new)."""
    row = shelf_settings(db)
    current = {key: getattr(row, key) for key in EDITABLE}
    merged = validate({**current, **{k: v for k, v in values.items() if k in EDITABLE}})
    changes = {}
    for key, value in merged.items():
        if getattr(row, key) != value:
            changes[key] = {"from": _plain(getattr(row, key)), "to": _plain(value)}
            setattr(row, key, value)
    row.updated_by_user_id = actor_user_id
    row.updated_at = datetime.now(timezone.utc)
    db.flush()
    return row, changes


def set_terms(db: Session, *, text: str, actor_user_id: uuid.UUID) -> ShelfSettings:
    """New terms text: a draft again until it is approved."""
    text = (text or "").strip()
    if not text:
        raise _refuse("The terms cannot be empty")
    row = shelf_settings(db)
    row.terms_text = text
    row.terms_approved_at = None
    row.terms_reviewed_by = None
    row.terms_review_note = None
    row.terms_approved_by_user_id = None
    row.updated_by_user_id = actor_user_id
    db.flush()
    return row


def approve_terms(db: Session, *, reviewed_by: str, note: str, actor_user_id: uuid.UUID) -> ShelfSettings:
    reviewed_by, note = (reviewed_by or "").strip(), (note or "").strip()
    if not reviewed_by or not note:
        raise _refuse("Say who reviewed the terms, and add a note")
    row = shelf_settings(db)
    if row.terms_text.strip() == SHELF_TERMS_PLACEHOLDER:
        raise APIError(code="invalid_state", message="The placeholder terms cannot be approved; paste the reviewed text first", status_code=409)
    row.terms_approved_at = datetime.now(timezone.utc)
    row.terms_reviewed_by = reviewed_by
    row.terms_review_note = note
    row.terms_approved_by_user_id = actor_user_id
    db.flush()
    return row


def _plain(value):
    return str(value) if isinstance(value, Decimal) else value
