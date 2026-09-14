"""How one booking's 20% and 80% divide further.

The platform's take does not change. What these columns add is the structure
inside it: 15% retained and 5% back to the photographer as $RAWW credit, plus
whatever share of their own cash the photographer chooses to pass to the
client.

The four columns on `gig` record the rates a booking was created under rather
than leaving an invoice to look them up later. The refund path already worked
this way, reading the fee percentage stamped on the earnings entry, and for
the same reason: changing the platform's rate must never rewrite money that
has already settled. They are nullable because every existing gig predates
them, and an invoice for one falls back to the policy of its time rather than
claiming a split it was not created under.

Revision ID: 20260914_0051
Revises: 20260914_0050
"""
from alembic import op
import sqlalchemy as sa

revision = "20260914_0051"
down_revision = "20260914_0050"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("platform_fee_policy", sa.Column("retained_percent", sa.Integer(), nullable=False, server_default="15"))
    op.add_column("platform_fee_policy", sa.Column("pro_raww_percent", sa.Integer(), nullable=False, server_default="5"))
    op.add_column(
        "platform_fee_policy",
        sa.Column("max_client_credit_percent", sa.Integer(), nullable=False, server_default="10"),
    )
    op.add_column("pro_profile", sa.Column("client_credit_percent", sa.Integer(), nullable=False, server_default="0"))
    for column in ("fee_percent", "retained_percent", "pro_raww_percent", "client_credit_percent"):
        op.add_column("gig", sa.Column(column, sa.Integer(), nullable=True))


def downgrade() -> None:
    for column in ("client_credit_percent", "pro_raww_percent", "retained_percent", "fee_percent"):
        op.drop_column("gig", column)
    op.drop_column("pro_profile", "client_credit_percent")
    op.drop_column("platform_fee_policy", "max_client_credit_percent")
    op.drop_column("platform_fee_policy", "pro_raww_percent")
    op.drop_column("platform_fee_policy", "retained_percent")
