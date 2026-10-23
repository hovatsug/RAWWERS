"""What a booking earned, stamped on it.

gig gains final_gross, final_platform_retained, final_pro_raww,
final_client_raww, final_pro_cash and final_stamped_at: the booking's final
price net of refunds, split by the invoice method, written by
photographer_money when earnings are recorded. Existing bookings have none
until their earnings are recomputed (scripts/recompute_earnings.py); until
then the invoice computes the same split from the final price.

Revision ID: 20261023_0069
Revises: 20261022_0068
"""
import sqlalchemy as sa
from alembic import op

revision = "20261023_0069"
down_revision = "20261022_0068"
branch_labels = None
depends_on = None

_AMOUNTS = ("final_gross", "final_platform_retained", "final_pro_raww", "final_client_raww", "final_pro_cash")


def upgrade() -> None:
    for name in _AMOUNTS:
        op.add_column("gig", sa.Column(name, sa.Numeric(12, 2), nullable=True))
    op.add_column("gig", sa.Column("final_stamped_at", sa.DateTime(timezone=True), nullable=True))


def downgrade() -> None:
    op.drop_column("gig", "final_stamped_at")
    for name in reversed(_AMOUNTS):
        op.drop_column("gig", name)
