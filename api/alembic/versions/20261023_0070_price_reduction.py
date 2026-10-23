"""Price reductions after payment, their reasons, and the delivery review policy.

price_reduction_reason: the reason codes, admin-editable, seeded with the
five agreed ones. price_reduction: one row per reduction, with its breakdown
by reason and the refund it caused, unique by the event that caused it.
delivery_review_policy: one row, the shortfall that flags a booking for an
admin (default 1 photo).

Revision ID: 20261023_0070
Revises: 20261023_0069
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261023_0070"
down_revision = "20261023_0069"
branch_labels = None
depends_on = None

_REASONS = (
    ("photographer_non_delivery", "Photos not delivered", "Fewer photos were delivered than your package included.", True, 10),
    ("client_selected_fewer", "Client selected fewer photos", "You chose fewer photos than your deposit covered.", False, 20),
    ("mutual_agreement", "Agreed lower price", "You and your photographer agreed a lower price.", False, 30),
    ("admin_goodwill", "Goodwill", "A goodwill reduction from RAWWERS.", False, 40),
    ("dispute_resolution", "Dispute resolution", "The price was lowered to resolve a dispute.", False, 50),
)


def upgrade() -> None:
    reasons = op.create_table(
        "price_reduction_reason",
        sa.Column("code", sa.Text(), primary_key=True),
        sa.Column("label", sa.Text(), nullable=False),
        sa.Column("client_wording", sa.Text(), nullable=False),
        sa.Column("may_carry_fault", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("sort_order", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.bulk_insert(reasons, [
        {"code": c, "label": label, "client_wording": w, "may_carry_fault": f, "is_active": True, "sort_order": o}
        for c, label, w, f, o in _REASONS
    ])
    op.create_table(
        "price_reduction",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("idempotency_key", sa.Text(), nullable=False, unique=True),
        sa.Column("source", sa.Text(), nullable=False),
        sa.Column("from_amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("to_amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("lines", postgresql.JSONB(), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("refund_amount", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("currency", sa.CHAR(3), nullable=False),
        sa.Column("note", sa.Text(), nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_price_reduction_gig_id", "price_reduction", ["gig_id"])
    policy = op.create_table(
        "delivery_review_policy",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("shortfall_min_photos", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("updated_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.bulk_insert(policy, [{"id": 1, "shortfall_min_photos": 1}])


def downgrade() -> None:
    op.drop_table("delivery_review_policy")
    op.drop_index("ix_price_reduction_gig_id", table_name="price_reduction")
    op.drop_table("price_reduction")
    op.drop_table("price_reduction_reason")
