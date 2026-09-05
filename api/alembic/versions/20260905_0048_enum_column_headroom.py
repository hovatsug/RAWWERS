"""Give every non-native enum column room to grow.

`Enum(..., native_enum=False)` sizes its VARCHAR to the longest enum
*member name* at the moment the migration is generated, and nothing
resizes it when a longer value is added later. Two columns had already
outgrown their width and returned a 500 on the most likely dispute
category in a photography marketplace; 162 more were sitting exactly at
their limit, one new enum value away from the same failure.

The models now pin `length=64` explicitly, so the size is a decision
rather than a side effect of whichever names happened to exist when the
column was created. This brings the database to match.

Widening a varchar in Postgres is a catalog-only change - no table
rewrite, no lock beyond a brief ACCESS EXCLUSIVE - so this is cheap even
on large tables.

Verified against enum *values*, which is what is stored. Alembic compares
against member names and over-reports: `feature_flag.scope` and
`milestone.scope` hold 'global' (6) but their member is `global_scope`
(12), and a mechanical make-the-database-match-the-model pass would have
widened them for no reason.

Revision ID: 20260905_0048
Revises: 20260905_0047
Create Date: 2026-09-05 00:00:00.000000
"""
from __future__ import annotations

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "20260905_0048"
down_revision: Union[str, Sequence[str], None] = "20260905_0047"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

COLUMNS: list[tuple[str, str]] = [
    ("abuse_signal", "severity"),
    ("abuse_signal", "status"),
    ("ban_action", "action"),
    ("booking_request", "status"),
    ("booking_request_transition", "from_status"),
    ("booking_request_transition", "to_status"),
    ("call_session", "direction"),
    ("call_session", "outcome"),
    ("call_session", "purpose"),
    ("call_session", "status"),
    ("certificate", "certificate_type"),
    ("chat_message", "sender_type"),
    ("chat_thread", "status"),
    ("client_preference", "consent_default"),
    ("client_selection", "status"),
    ("client_waitlist", "status"),
    ("commerce_partner", "api_type"),
    ("confirmed_slot", "status"),
    ("consent_reward_policy", "consent_level"),
    ("contact_consent", "channel"),
    ("contact_consent", "scope"),
    ("content_pack", "category"),
    ("content_pack", "status"),
    ("content_pack_order", "payment_method"),
    ("content_pack_order", "status"),
    ("content_pack_review", "decision"),
    ("conversion_attribution", "conversion_type"),
    ("course", "level"),
    ("course", "pricing_mode"),
    ("course", "status"),
    ("course_module", "type"),
    ("course_review", "decision"),
    ("course_sale", "status"),
    ("curriculum_requirement", "requirement_type"),
    ("discount_redemption", "context_type"),
    ("discount_redemption", "status"),
    ("dispute", "status"),
    ("dispute_event", "actor_type"),
    ("dispute_evidence", "kind"),
    ("earnings_hold", "reason"),
    ("earnings_ledger_entry", "source_type"),
    ("earnings_ledger_entry", "status"),
    ("email_message", "status"),
    ("enrollment", "status"),
    ("entitlement_hold", "hold_type"),
    ("extra_image_pricing_policy", "tier"),
    ("extra_image_purchase", "status"),
    ("feature_flag", "scope"),
    ("followup_job", "status"),
    ("followup_rule", "channel"),
    ("gear_benefit_policy", "min_tier_any_niche"),
    ("gear_item", "category"),
    ("gig", "status"),
    ("gig_media_entitlement", "entitlement_type"),
    ("gig_transition", "from_status"),
    ("gig_transition", "to_status"),
    ("gig_usage_consent", "consent_level"),
    ("i18n_key_audit", "status"),
    ("instructor_profile", "status"),
    ("invite_code", "status"),
    ("invite_wave", "allowed_role"),
    ("learning_partner", "status"),
    ("ledger_entry", "entry_type"),
    ("legacy_booking", "payment_mode"),
    ("legacy_booking", "status"),
    ("legacy_brief", "privacy_level"),
    ("legacy_brief", "tone"),
    ("legacy_review", "client_response"),
    ("legacy_review", "stage"),
    ("lesson", "content_type"),
    ("lesson_progress", "status"),
    ("loaner_event", "actor_type"),
    ("loaner_request", "category"),
    ("loaner_request", "status"),
    ("media_access_log", "action"),
    ("media_asset", "kind"),
    ("media_asset", "provider"),
    ("media_asset", "purpose"),
    ("media_asset", "status"),
    ("media_asset", "visibility"),
    ("media_derivative", "kind"),
    ("media_object", "status"),
    ("media_object", "variant"),
    ("milestone", "audience"),
    ("milestone", "difficulty"),
    ("milestone", "scope"),
    ("milestone_progress", "status"),
    ("module_progress", "status"),
    ("niche_package_price_cap", "tier"),
    ("niche_program_requirement", "requirement_type"),
    ("niche_program_requirement", "tier_target"),
    ("notification", "severity"),
    ("notification", "status"),
    ("notification_event", "channel"),
    ("notification_preference", "digest_mode"),
    ("order", "status"),
    ("order_payment", "status"),
    ("outbox_event", "status"),
    ("pack_source_reference", "requires_consent_level"),
    ("pack_source_reference", "source_type"),
    ("package_decay_curve", "curve_type"),
    ("payout_account", "payout_method"),
    ("payout_account", "status"),
    ("payout_request", "status"),
    ("price_rule", "applies_to"),
    ("price_rule", "discount_type"),
    ("price_rule", "min_tier"),
    ("print_event", "actor_type"),
    ("print_export_job", "status"),
    ("print_order", "status"),
    ("print_partner", "mode"),
    ("print_product", "type"),
    ("pro_ai_profile", "tone"),
    ("pro_availability_rule", "location_mode"),
    ("pro_credential", "mode"),
    ("pro_credential", "tier"),
    ("pro_niche", "declared_level"),
    ("pro_niche_skill", "tier"),
    ("pro_niche_skill_event", "actor_type"),
    ("pro_niche_skill_event", "event_type"),
    ("pro_onboarding", "status"),
    ("pro_onboarding_event", "actor_type"),
    ("pro_profile", "kyc_status"),
    ("pro_public_index", "kyc_status"),
    ("pro_quality_penalty", "severity"),
    ("pro_quality_penalty", "type"),
    ("product", "stock_status"),
    ("proof_gallery", "status"),
    ("raww_issuance_cap", "scope"),
    ("raww_issuance_rule", "event_type"),
    ("raww_mint_event", "status"),
    ("referral_attribution", "attribution_type"),
    ("referral_code", "role"),
    ("referral_link", "status"),
    ("refund_case", "payment_scope"),
    ("refund_policy", "category"),
    ("refund_policy", "default_action"),
    ("reminder_job", "kind"),
    ("reminder_job", "status"),
    ("repair_event", "actor_type"),
    ("repair_ticket", "outcome"),
    ("repair_ticket", "status"),
    ("repair_ticket", "urgency"),
    ("review", "status"),
    ("reward_ledger_entry", "entry_type"),
    ("risk_action", "action_type"),
    ("risk_action", "status"),
    ("risk_profile", "risk_level"),
    ("royalty_ledger_entry", "status"),
    ("scheduled_notification", "channel"),
    ("share_link", "scope"),
    ("share_reward_threshold", "metric"),
    ("store_access_policy", "min_tier_any_niche"),
    ("stripe_payment", "kind"),
    ("stripe_payment", "status"),
    ("upsell_purchase", "status"),
    ("user_account", "status"),
    ("user_role", "role"),
    ("vault_access_log", "action"),
    ("vault_item", "status"),
    ("vault_item", "type"),
    ("webhook_event", "provider"),
]


def upgrade() -> None:
    for table, column in COLUMNS:
        op.alter_column(table, column, type_=sa.String(length=64), existing_nullable=None)


def downgrade() -> None:
    # Deliberately a no-op. Narrowing back would truncate any value written
    # in the meantime, and the original widths were an accident of naming
    # rather than a constraint anyone chose.
    pass
