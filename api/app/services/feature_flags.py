from __future__ import annotations

import hashlib
import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.ops import FeatureFlag, FeatureFlagScope

DEFAULT_FLAG_KEYS = {
    "ai_calls_enabled",
    "rewards_spend_enabled",
    "ecom_enabled",
    "loaners_enabled",
    "video_uploads_enabled",
    "search_enabled",
    "search_force_db_fallback",
    "public_share_enabled",
    "downloads_enabled",
    "client_browsing_enabled",
    "client_browsing_enabled_global",
    "client_booking_enabled",
    "guest_discovery_enabled",
    "pro_onboarding_enabled",
    "ai_chat_enabled_global",
    "ai_chat_enabled_city",
    "ai_chat_enabled_pro",
    "ai_chat_kill_switch",
    "raww_minting_enabled",
    "raww_minting_event_gig_completed_enabled",
    "raww_minting_event_pack_sold_enabled",
}

DEFAULT_FLAG_STATE: dict[str, bool] = {
    "search_force_db_fallback": False,
    "guest_discovery_enabled": False,
    "ai_chat_kill_switch": False,
}


def is_feature_enabled(db: Session, key: str, user_id: uuid.UUID | None = None) -> bool:
    row = db.execute(select(FeatureFlag).where(FeatureFlag.key == key)).scalar_one_or_none()
    if not row:
        return DEFAULT_FLAG_STATE.get(key, True)

    if not row.is_enabled:
        allowlist = set((row.rules or {}).get("allowlist_user_ids", []))
        if user_id and str(user_id) in allowlist:
            return True
        return False

    rules = row.rules or {}
    allowlist = set(rules.get("allowlist_user_ids", []))
    if user_id and str(user_id) in allowlist:
        return True

    if user_id and "percentage_rollout" in rules:
        pct = int(rules.get("percentage_rollout", 100))
        if pct <= 0:
            return False
        if pct >= 100:
            return True
        token = hashlib.sha256(f"{key}:{user_id}".encode("utf-8")).hexdigest()
        bucket = int(token[:8], 16) % 100
        return bucket < pct

    if row.scope == FeatureFlagScope.global_scope:
        return True
    return user_id is not None


def upsert_feature_flag(
    db: Session,
    *,
    key: str,
    is_enabled: bool,
    scope: FeatureFlagScope,
    rules: dict | None,
) -> FeatureFlag:
    row = db.execute(select(FeatureFlag).where(FeatureFlag.key == key)).scalar_one_or_none()
    if not row:
        row = FeatureFlag(key=key, is_enabled=is_enabled, scope=scope, rules=rules or {})
        db.add(row)
        db.flush()
        return row

    row.is_enabled = is_enabled
    row.scope = scope
    row.rules = rules or {}
    db.flush()
    return row
