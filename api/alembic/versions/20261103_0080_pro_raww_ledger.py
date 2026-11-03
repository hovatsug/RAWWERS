"""The Shelf: a photographer's RAWW ledger and balance.

New tables only. Separate from the reward ledger clients share.

Revision ID: 20261103_0080
Revises: 20261103_0079
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261103_0080"
down_revision = "20261103_0079"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "pro_raww_ledger_entry",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("kind", sa.String(length=32), nullable=False),
        sa.Column("amount", sa.BigInteger(), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("source_type", sa.Text(), nullable=False),
        sa.Column("source_id", sa.Text(), nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("raww_eur_value", sa.Numeric(10, 4), nullable=True),
        sa.Column("eur_basis", sa.Numeric(12, 2), nullable=True),
        sa.Column("spendable_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("metadata", postgresql.JSONB(), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("pro_user_id", "kind", "source_type", "source_id", name="uq_pro_raww_entry_source"),
        sa.CheckConstraint("amount <> 0", name="ck_pro_raww_entry_amount"),
    )
    op.create_index("ix_pro_raww_ledger_entry_pro_user_id", "pro_raww_ledger_entry", ["pro_user_id"])
    op.create_index("ix_pro_raww_ledger_entry_gig_id", "pro_raww_ledger_entry", ["gig_id"])
    op.create_index("ix_pro_raww_ledger_entry_created_at", "pro_raww_ledger_entry", ["created_at"])
    op.create_index("ix_pro_raww_entry_pro_created", "pro_raww_ledger_entry", ["pro_user_id", sa.text("created_at DESC")])
    op.create_table(
        "pro_raww_balance",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("spendable", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("pending", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("last_activity_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("expiry_warned_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )


def downgrade() -> None:
    op.drop_table("pro_raww_balance")
    op.drop_index("ix_pro_raww_entry_pro_created", table_name="pro_raww_ledger_entry")
    op.drop_index("ix_pro_raww_ledger_entry_created_at", table_name="pro_raww_ledger_entry")
    op.drop_index("ix_pro_raww_ledger_entry_gig_id", table_name="pro_raww_ledger_entry")
    op.drop_index("ix_pro_raww_ledger_entry_pro_user_id", table_name="pro_raww_ledger_entry")
    op.drop_table("pro_raww_ledger_entry")
