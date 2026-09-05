"""disputes refunds arbitration v1

Revision ID: 20260226_0022
Revises: 20260226_0021
Create Date: 2026-02-26 03:20:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260226_0022"
down_revision: Union[str, Sequence[str], None] = "20260226_0021"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


dispute_actor_type_enum = sa.Enum("client", "pro", "admin", "system", name="dispute_actor_type", native_enum=False)
refund_payment_scope_enum = sa.Enum("booking_payment", "extra_image_purchase", name="refund_payment_scope", native_enum=False)
entitlement_hold_type_enum = sa.Enum("downloads_frozen", "share_disabled", name="entitlement_hold_type", native_enum=False)
penalty_type_enum = sa.Enum("warning", "visibility_downrank", "temporary_suspension", name="pro_quality_penalty_type", native_enum=False)
penalty_severity_enum = sa.Enum("low", "medium", "high", name="pro_quality_penalty_severity", native_enum=False)
refund_policy_action_enum = sa.Enum("full_refund", "partial_refund", "no_refund", "admin_review", name="refund_policy_default_action", native_enum=False)


def upgrade() -> None:
    op.add_column("dispute", sa.Column("extra_purchase_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("dispute", sa.Column("against_user_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("dispute", sa.Column("requested_refund_amount", sa.Numeric(12, 2), nullable=True))
    op.add_column("dispute", sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"))
    op.add_column("dispute", sa.Column("reason", sa.Text(), nullable=True))
    op.add_column("dispute", sa.Column("opened_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")))
    op.add_column("dispute", sa.Column("due_response_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("dispute", sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("dispute", sa.Column("resolution", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")))
    op.add_column("dispute", sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")))
    op.create_index("ix_dispute_extra_purchase_id", "dispute", ["extra_purchase_id"])
    op.create_index("ix_dispute_against_user_id", "dispute", ["against_user_id"])
    op.create_index("ix_dispute_opened_at", "dispute", ["opened_at"])
    op.create_index("ix_dispute_status", "dispute", ["status"])

    op.add_column("refund_case", sa.Column("payment_scope", refund_payment_scope_enum, nullable=True))
    op.add_column("refund_case", sa.Column("reference_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("refund_case", sa.Column("stripe_payment_intent_id", sa.Text(), nullable=True))
    op.add_column("refund_case", sa.Column("amount_authorized", sa.Numeric(12, 2), nullable=True))
    op.add_column("refund_case", sa.Column("amount_refunded", sa.Numeric(12, 2), nullable=False, server_default="0.00"))
    op.create_index("ix_refund_case_reference_id", "refund_case", ["reference_id"])
    op.create_index("ix_refund_case_stripe_payment_intent_id", "refund_case", ["stripe_payment_intent_id"])

    op.create_table(
        "dispute_message",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("dispute_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("dispute.id"), nullable=False),
        sa.Column("sender_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("message", sa.Text(), nullable=False),
        sa.Column("evidence_media_asset_ids", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_dispute_message_dispute_id", "dispute_message", ["dispute_id"])
    op.create_index("ix_dispute_message_sender_user_id", "dispute_message", ["sender_user_id"])
    op.create_index("ix_dispute_message_created_at", "dispute_message", ["created_at"])

    op.create_table(
        "dispute_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("dispute_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("dispute.id"), nullable=False),
        sa.Column("from_status", sa.Text(), nullable=True),
        sa.Column("to_status", sa.Text(), nullable=False),
        sa.Column("actor_type", dispute_actor_type_enum, nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_dispute_event_dispute_id", "dispute_event", ["dispute_id"])
    op.create_index("ix_dispute_event_created_at", "dispute_event", ["created_at"])

    op.create_table(
        "refund_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("refund_case_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("refund_case.id"), nullable=False),
        sa.Column("type", sa.Text(), nullable=False),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_refund_event_refund_case_id", "refund_event", ["refund_case_id"])

    op.create_table(
        "gig_contract_snapshot",
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), primary_key=True, nullable=False),
        sa.Column("snapshot", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "delivery_sla_snapshot",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("proofs_due_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("finals_due_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("proofs_published_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("finals_delivered_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_delivery_sla_snapshot_gig_id", "delivery_sla_snapshot", ["gig_id"])

    op.create_table(
        "entitlement_hold",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("hold_type", entitlement_hold_type_enum, nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("released_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_entitlement_hold_gig_id", "entitlement_hold", ["gig_id"])
    op.create_index("ix_entitlement_hold_user_id", "entitlement_hold", ["user_id"])

    op.create_table(
        "pro_quality_penalty",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("dispute_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("dispute.id"), nullable=True),
        sa.Column("type", penalty_type_enum, nullable=False),
        sa.Column("severity", penalty_severity_enum, nullable=False),
        sa.Column("applied_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
    )
    op.create_index("ix_pro_quality_penalty_pro_user_id", "pro_quality_penalty", ["pro_user_id"])
    op.create_index("ix_pro_quality_penalty_dispute_id", "pro_quality_penalty", ["dispute_id"])

    op.create_table(
        "refund_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("category", sa.Enum(
            "no_show", "late_cancellation", "late_delivery", "deliverable_quality", "billing", "fraud", "quality", "harassment", "payment", "other",
            name="dispute_category", native_enum=False
        ), nullable=False, unique=True),
        sa.Column("default_action", refund_policy_action_enum, nullable=False),
        sa.Column("max_refund_percent", sa.Integer(), nullable=True),
        sa.Column("response_window_hours", sa.Integer(), nullable=False, server_default="72"),
        sa.Column("requires_evidence", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )


def downgrade() -> None:
    op.drop_table("refund_policy")

    op.drop_index("ix_pro_quality_penalty_dispute_id", table_name="pro_quality_penalty")
    op.drop_index("ix_pro_quality_penalty_pro_user_id", table_name="pro_quality_penalty")
    op.drop_table("pro_quality_penalty")

    op.drop_index("ix_entitlement_hold_user_id", table_name="entitlement_hold")
    op.drop_index("ix_entitlement_hold_gig_id", table_name="entitlement_hold")
    op.drop_table("entitlement_hold")

    op.drop_index("ix_delivery_sla_snapshot_gig_id", table_name="delivery_sla_snapshot")
    op.drop_table("delivery_sla_snapshot")

    op.drop_table("gig_contract_snapshot")

    op.drop_index("ix_refund_event_refund_case_id", table_name="refund_event")
    op.drop_table("refund_event")

    op.drop_index("ix_dispute_event_created_at", table_name="dispute_event")
    op.drop_index("ix_dispute_event_dispute_id", table_name="dispute_event")
    op.drop_table("dispute_event")

    op.drop_index("ix_dispute_message_created_at", table_name="dispute_message")
    op.drop_index("ix_dispute_message_sender_user_id", table_name="dispute_message")
    op.drop_index("ix_dispute_message_dispute_id", table_name="dispute_message")
    op.drop_table("dispute_message")

    op.drop_index("ix_refund_case_stripe_payment_intent_id", table_name="refund_case")
    op.drop_index("ix_refund_case_reference_id", table_name="refund_case")
    op.drop_column("refund_case", "amount_refunded")
    op.drop_column("refund_case", "amount_authorized")
    op.drop_column("refund_case", "stripe_payment_intent_id")
    op.drop_column("refund_case", "reference_id")
    op.drop_column("refund_case", "payment_scope")

    op.drop_index("ix_dispute_status", table_name="dispute")
    op.drop_index("ix_dispute_opened_at", table_name="dispute")
    op.drop_index("ix_dispute_against_user_id", table_name="dispute")
    op.drop_index("ix_dispute_extra_purchase_id", table_name="dispute")
    op.drop_column("dispute", "metadata")
    op.drop_column("dispute", "resolution")
    op.drop_column("dispute", "resolved_at")
    op.drop_column("dispute", "due_response_at")
    op.drop_column("dispute", "opened_at")
    op.drop_column("dispute", "reason")
    op.drop_column("dispute", "currency")
    op.drop_column("dispute", "requested_refund_amount")
    op.drop_column("dispute", "against_user_id")
    op.drop_column("dispute", "extra_purchase_id")

    refund_policy_action_enum.drop(op.get_bind(), checkfirst=True)
    penalty_severity_enum.drop(op.get_bind(), checkfirst=True)
    penalty_type_enum.drop(op.get_bind(), checkfirst=True)
    entitlement_hold_type_enum.drop(op.get_bind(), checkfirst=True)
    refund_payment_scope_enum.drop(op.get_bind(), checkfirst=True)
    dispute_actor_type_enum.drop(op.get_bind(), checkfirst=True)
