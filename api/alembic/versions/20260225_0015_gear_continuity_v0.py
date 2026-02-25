"""gear continuity v0 repairs + loaners

Revision ID: 20260225_0015
Revises: 20260225_0014
Create Date: 2026-02-26 00:20:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0015"
down_revision: Union[str, Sequence[str], None] = "20260225_0014"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


gear_category_enum = sa.Enum("camera_body", "lens", "lighting", "audio", "tripod", "drone", "accessory", name="gear_category", native_enum=False)
repair_urgency_enum = sa.Enum("low", "normal", "high", name="repair_urgency", native_enum=False)
repair_ticket_status_enum = sa.Enum(
    "submitted",
    "partner_assigned",
    "awaiting_quote",
    "quote_sent",
    "quote_approved",
    "quote_declined",
    "in_repair",
    "ready_for_return",
    "shipped_back",
    "closed",
    "cancelled",
    name="repair_ticket_status",
    native_enum=False,
)
repair_outcome_enum = sa.Enum("fixed", "not_fixed", "replaced", "unknown", name="repair_outcome", native_enum=False)
loaner_request_status_enum = sa.Enum(
    "requested",
    "approved",
    "declined",
    "ready_for_pickup",
    "shipped_to_pro",
    "in_use",
    "return_due",
    "returned",
    "closed",
    "cancelled",
    name="loaner_request_status",
    native_enum=False,
)
repair_actor_type_enum = sa.Enum("pro", "admin", "partner", "system", name="repair_actor_type", native_enum=False)
skill_tier_enum = sa.Enum("rookie", "skilled", "pro", "elite", "master", name="skill_tier", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "gear_item",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("category", gear_category_enum, nullable=False),
        sa.Column("brand", sa.Text(), nullable=True),
        sa.Column("model", sa.Text(), nullable=True),
        sa.Column("serial_number", sa.Text(), nullable=True),
        sa.Column("purchase_date", sa.Date(), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_gear_item_pro_user_id", "gear_item", ["pro_user_id"])
    op.create_index("ix_gear_item_pro_category_brand", "gear_item", ["pro_user_id", "category", "brand"])

    op.create_table(
        "repair_partner",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("country", sa.Text(), nullable=False),
        sa.Column("city", sa.Text(), nullable=False),
        sa.Column("address", sa.Text(), nullable=True),
        sa.Column("service_radius_km", sa.Integer(), nullable=True),
        sa.Column("shipping_supported", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("pickup_supported", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("brands_supported", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("categories_supported", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("sla_quote_hours", sa.Integer(), nullable=True),
        sa.Column("sla_turnaround_days", sa.Integer(), nullable=True),
        sa.Column("loaner_supported", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("loaner_categories", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("contact", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("partner_terms", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_repair_partner_country_city", "repair_partner", ["country", "city"])
    op.create_index("ix_repair_partner_is_active", "repair_partner", ["is_active"])

    op.create_table(
        "gear_benefit_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("require_kyc_approved", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("min_tier_any_niche", skill_tier_enum, nullable=False, server_default="skilled"),
        sa.Column("require_not_banned", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )

    op.create_table(
        "gear_benefit_override",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False, unique=True),
        sa.Column("is_allowed", sa.Boolean(), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("granted_by", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("granted_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_gear_benefit_override_pro_user_id", "gear_benefit_override", ["pro_user_id"])

    op.create_table(
        "repair_ticket",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("gear_item_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gear_item.id"), nullable=True),
        sa.Column("partner_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("repair_partner.id"), nullable=True),
        sa.Column("status", repair_ticket_status_enum, nullable=False, server_default="submitted"),
        sa.Column("urgency", repair_urgency_enum, nullable=False, server_default="normal"),
        sa.Column("issue_description", sa.Text(), nullable=False),
        sa.Column("evidence_media_asset_ids", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("quote_amount", sa.Numeric(12, 2), nullable=True),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("quote_notes", sa.Text(), nullable=True),
        sa.Column("quote_sent_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("quote_approved_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("repair_started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("repair_completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("return_shipped_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("closed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("shipping", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("outcome", repair_outcome_enum, nullable=False, server_default="unknown"),
        sa.Column("reopened_from_ticket_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_repair_ticket_pro_user_id", "repair_ticket", ["pro_user_id"])
    op.create_index("ix_repair_ticket_gear_item_id", "repair_ticket", ["gear_item_id"])
    op.create_index("ix_repair_ticket_partner_id", "repair_ticket", ["partner_id"])

    op.create_table(
        "repair_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("ticket_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("repair_ticket.id"), nullable=False),
        sa.Column("from_status", sa.Text(), nullable=True),
        sa.Column("to_status", sa.Text(), nullable=False),
        sa.Column("actor_type", repair_actor_type_enum, nullable=False),
        sa.Column("actor_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_repair_event_ticket_id", "repair_event", ["ticket_id"])
    op.create_index("ix_repair_event_created_at", "repair_event", ["created_at"])

    op.create_table(
        "loaner_request",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("ticket_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("repair_ticket.id"), nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("partner_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("repair_partner.id"), nullable=True),
        sa.Column("status", loaner_request_status_enum, nullable=False, server_default="requested"),
        sa.Column("category", gear_category_enum, nullable=False),
        sa.Column("terms_snapshot", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("deposit_required", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("deposit_amount", sa.Numeric(12, 2), nullable=True),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("deposit_reference", sa.Text(), nullable=True),
        sa.Column("max_days", sa.Integer(), nullable=True),
        sa.Column("start_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("due_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("shipping", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_loaner_request_ticket_id", "loaner_request", ["ticket_id"])
    op.create_index("ix_loaner_request_pro_user_id", "loaner_request", ["pro_user_id"])
    op.create_index("ix_loaner_request_partner_id", "loaner_request", ["partner_id"])

    op.create_table(
        "loaner_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("loaner_request_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("loaner_request.id"), nullable=False),
        sa.Column("from_status", sa.Text(), nullable=True),
        sa.Column("to_status", sa.Text(), nullable=False),
        sa.Column("actor_type", repair_actor_type_enum, nullable=False),
        sa.Column("actor_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_loaner_event_loaner_request_id", "loaner_event", ["loaner_request_id"])
    op.create_index("ix_loaner_event_created_at", "loaner_event", ["created_at"])

    op.create_table(
        "repair_partner_score",
        sa.Column("partner_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("repair_partner.id"), primary_key=True, nullable=False),
        sa.Column("tickets_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("avg_quote_hours", sa.Numeric(10, 2), nullable=True),
        sa.Column("avg_turnaround_days", sa.Numeric(10, 2), nullable=True),
        sa.Column("reopen_rate", sa.Numeric(5, 2), nullable=True),
        sa.Column("dispute_rate", sa.Numeric(5, 2), nullable=True),
        sa.Column("loaner_fulfillment_rate", sa.Numeric(5, 2), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table("repair_partner_score")

    op.drop_index("ix_loaner_event_created_at", table_name="loaner_event")
    op.drop_index("ix_loaner_event_loaner_request_id", table_name="loaner_event")
    op.drop_table("loaner_event")

    op.drop_index("ix_loaner_request_partner_id", table_name="loaner_request")
    op.drop_index("ix_loaner_request_pro_user_id", table_name="loaner_request")
    op.drop_index("ix_loaner_request_ticket_id", table_name="loaner_request")
    op.drop_table("loaner_request")

    op.drop_index("ix_repair_event_created_at", table_name="repair_event")
    op.drop_index("ix_repair_event_ticket_id", table_name="repair_event")
    op.drop_table("repair_event")

    op.drop_index("ix_repair_ticket_partner_id", table_name="repair_ticket")
    op.drop_index("ix_repair_ticket_gear_item_id", table_name="repair_ticket")
    op.drop_index("ix_repair_ticket_pro_user_id", table_name="repair_ticket")
    op.drop_table("repair_ticket")

    op.drop_index("ix_gear_benefit_override_pro_user_id", table_name="gear_benefit_override")
    op.drop_table("gear_benefit_override")
    op.drop_table("gear_benefit_policy")

    op.drop_index("ix_repair_partner_is_active", table_name="repair_partner")
    op.drop_index("ix_repair_partner_country_city", table_name="repair_partner")
    op.drop_table("repair_partner")

    op.drop_index("ix_gear_item_pro_category_brand", table_name="gear_item")
    op.drop_index("ix_gear_item_pro_user_id", table_name="gear_item")
    op.drop_table("gear_item")
