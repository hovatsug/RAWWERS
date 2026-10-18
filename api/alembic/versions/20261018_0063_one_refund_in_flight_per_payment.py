"""One refund in flight per payment, held by the database.

A partial unique index on refund_case(stripe_payment_intent_id) over the
statuses still in flight - pending, requested, approved, refund_initiated,
processing. Two requests at the same moment each saw nothing in flight and
each asked Stripe; now the second insert fails, and every path writes its
refund case before asking Stripe, so the loser never reaches the money.
Finished, failed, cancelled and rejected cases are outside the index: a
later refund of what is left stays possible.

If two in-flight cases already share a payment, building the index fails.
This migration does not pick one to cancel - a refund record is money, and
which one is real is a person's call. It stops instead, listing them; the
duplicates query is in DEPLOY_CHECKLIST.md.

Revision ID: 20261018_0063
Revises: 20261014_0062
"""
import sqlalchemy as sa
from alembic import op

revision = "20261018_0063"
down_revision = "20261014_0062"
branch_labels = None
depends_on = None

IN_FLIGHT = "('pending', 'requested', 'approved', 'refund_initiated', 'processing')"


def upgrade() -> None:
    duplicates = op.get_bind().execute(
        sa.text(
            "SELECT stripe_payment_intent_id, count(*), string_agg(id::text || ':' || status, ', ') "
            "FROM refund_case "
            f"WHERE stripe_payment_intent_id IS NOT NULL AND status IN {IN_FLIGHT} "
            "GROUP BY stripe_payment_intent_id HAVING count(*) > 1"
        )
    ).fetchall()
    if duplicates:
        listed = "; ".join(f"{pi} ({n}: {cases})" for pi, n, cases in duplicates)
        raise RuntimeError(
            "More than one refund in flight on the same payment - resolve these by hand "
            f"(see DEPLOY_CHECKLIST.md), then migrate again: {listed}"
        )
    op.execute(
        "CREATE UNIQUE INDEX IF NOT EXISTS uq_refund_case_one_in_flight_per_payment "
        "ON refund_case (stripe_payment_intent_id) "
        f"WHERE stripe_payment_intent_id IS NOT NULL AND status IN {IN_FLIGHT}"
    )


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS uq_refund_case_one_in_flight_per_payment")
