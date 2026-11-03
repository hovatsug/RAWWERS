"""Reward ledger: one entry per idempotency reference.

A unique index on (user_id, entry_type, reference_type, reference_id) for
entries that have a reference. The same event arriving twice can then never
credit twice, whatever the timing (services/rewards.py also re-checks after
taking the balance lock).

Nothing is deleted. Existing duplicates, if any, are reported and the
upgrade stops, so a person decides what to do with them; the index cannot
be created while they exist.

Revision ID: 20261103_0079
Revises: 20261102_0078
"""
import sqlalchemy as sa
from alembic import op

revision = "20261103_0079"
down_revision = "20261102_0078"
branch_labels = None
depends_on = None

INDEX = "uq_reward_ledger_idempotency"


def upgrade() -> None:
    duplicates = op.get_bind().execute(
        sa.text(
            """
            SELECT user_id, entry_type, reference_type, reference_id, count(*) AS n,
                   sum(amount) AS total, min(created_at) AS first_at, max(created_at) AS last_at
            FROM reward_ledger_entry
            WHERE reference_type IS NOT NULL AND reference_id IS NOT NULL
            GROUP BY user_id, entry_type, reference_type, reference_id
            HAVING count(*) > 1
            ORDER BY last_at DESC
            """
        )
    ).all()
    if duplicates:
        lines = [
            f"  user {d.user_id} {d.entry_type} {d.reference_type}={d.reference_id}: "
            f"{d.n} entries, {d.total} points in all, {d.first_at:%Y-%m-%d %H:%M} to {d.last_at:%Y-%m-%d %H:%M}"
            for d in duplicates
        ]
        raise RuntimeError(
            f"reward_ledger_entry has {len(duplicates)} duplicated idempotency references; nothing was changed "
            "or deleted. Decide what to do with each (a reversing adjustment, usually) and run the upgrade "
            "again:\n" + "\n".join(lines)
        )
    op.create_index(
        INDEX,
        "reward_ledger_entry",
        ["user_id", "entry_type", "reference_type", "reference_id"],
        unique=True,
        postgresql_where=sa.text("reference_type IS NOT NULL AND reference_id IS NOT NULL"),
    )


def downgrade() -> None:
    op.drop_index(INDEX, table_name="reward_ledger_entry")
