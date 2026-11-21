from __future__ import annotations

import hashlib
import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
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
    "studioverse_enabled",
}

DEFAULT_FLAG_STATE: dict[str, bool] = {
    "search_force_db_fallback": False,
    "guest_discovery_enabled": False,
    "ai_chat_kill_switch": False,
    # Off (owner, 2026-11-03): photographers earn RAWW on The Shelf's own
    # ledger from the 5% credit. Event minting into the shared reward
    # ledger stays in the code, dormant; balances it already paid are kept.
    "raww_minting_enabled": False,
    # The old commerce store (api/v1/store.py) is dormant: The Shelf
    # replaces it. Its user routes answer 404 unless this is switched on.
    "ecom_enabled": False,
}

#: The chat assistant and the other LLM features (owner, 2026-11-17: OFF
#: for the beta). Outside development these are their defaults when no
#: flag row exists: no assistant reply in the apps' chat
#: (`ai_chat_enabled_global`, `ai_chat_kill_switch`), none on the older chat
#: routes and no AI call summary (`ai_calls_enabled`). Development and the
#: test suite keep the assistant on, as before. A flag row set by an admin
#: (`PUT /v1/admin/ai/feature-flags`) overrides either way.
AI_DEFAULTS_OUTSIDE_DEVELOPMENT: dict[str, bool] = {
    "ai_chat_enabled_global": False,
    "ai_chat_kill_switch": True,
    "ai_calls_enabled": False,
}
#: Features not in the beta, on in development, off elsewhere unless an
#: admin writes a flag row (owner, 2026-11-18). Studioverse: its creator,
#: marketplace and checkout routes answer as unmounted routes do, because a
#: pack's file is a storage key taken as the creator sends it
#: (MEDIA_OWNERSHIP_AUDIT.md) - to be fixed before it ever opens.
#:
#: Loaners and the older points spending (owner, 2026-11-21): no app asks
#: for a loaner. `rewards_spend_enabled` gates only `POST /v1/rewards/spend`
#: and `points_to_spend` on a gig's payment intent, which no app sends.
#: Client credit at checkout (`use_credit` on the client's booking payment,
#: services/client_credit.py) never reads it and keeps working
#: (tests/test_beta_switches.py). `video_uploads_enabled` stays on.
OFF_OUTSIDE_DEVELOPMENT: dict[str, bool] = {
    "studioverse_enabled": False,
    "loaners_enabled": False,
    "rewards_spend_enabled": False,
}
DEVELOPMENT_ENVS = frozenset({"development", "dev", "local", "test"})


def default_flag_state(key: str) -> bool:
    """A flag's value when no row exists."""
    for outside_development in (AI_DEFAULTS_OUTSIDE_DEVELOPMENT, OFF_OUTSIDE_DEVELOPMENT):
        if key in outside_development:
            env = (get_settings().app_env or "").strip().lower()
            if env not in DEVELOPMENT_ENVS:
                return outside_development[key]
    return DEFAULT_FLAG_STATE.get(key, True)


def is_feature_enabled(db: Session, key: str, user_id: uuid.UUID | None = None) -> bool:
    row = db.execute(select(FeatureFlag).where(FeatureFlag.key == key)).scalar_one_or_none()
    if not row:
        return default_flag_state(key)

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
