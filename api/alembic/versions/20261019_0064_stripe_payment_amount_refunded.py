"""How much of each payment has been refunded; a partial refund no longer
makes a payment look unpaid.

Adds stripe_payment.amount_refunded (0 by default). Fully refunded payments
get their whole amount. And it repairs what the old admin refund left: it
marked a payment `pending` - the status of a payment not yet made - as soon
as any refund was asked for, so a part-refunded booking looked unpaid to
every refund route and to the finals gate. A payment that was captured
(metadata paid_at) and sits at `pending` with a refund case against it goes
back to `succeeded` - `refunded` if the refunds that settled add up to all
of it - with those refunds as its amount refunded.
DEPLOY_CHECKLIST.md has the query that counts them first.

The downgrade drops the column; it does not put repaired payments back to
`pending`.

Revision ID: 20261019_0064
Revises: 20261018_0063
"""
import sqlalchemy as sa
from alembic import op

revision = "20261019_0064"
down_revision = "20261018_0063"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("stripe_payment", sa.Column("amount_refunded", sa.Numeric(12, 2), nullable=False, server_default="0"))
    op.execute("UPDATE stripe_payment SET amount_refunded = amount WHERE status = 'refunded'")
    op.execute(
        """
        WITH settled AS (
            SELECT p.id, LEAST(p.amount, COALESCE((
                SELECT sum(c.amount) FROM refund_case c
                WHERE (c.stripe_payment_intent_id = p.stripe_payment_intent_id OR c.metadata->>'stripe_payment_id' = p.id::text)
                  AND c.status IN ('refunded', 'succeeded')
            ), 0)) AS back
            FROM stripe_payment p
        )
        UPDATE stripe_payment p
        SET amount_refunded = s.back,
            status = CASE WHEN s.back >= p.amount THEN 'refunded' ELSE 'succeeded' END
        FROM settled s
        WHERE s.id = p.id
          AND p.status = 'pending'
          AND p.metadata ? 'paid_at'
          AND EXISTS (
            SELECT 1 FROM refund_case c
            WHERE c.stripe_payment_intent_id = p.stripe_payment_intent_id OR c.metadata->>'stripe_payment_id' = p.id::text
          )
        """
    )


def downgrade() -> None:
    op.drop_column("stripe_payment", "amount_refunded")
