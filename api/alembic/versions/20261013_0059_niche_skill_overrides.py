"""Keep an admin's tier decision, and what the evidence says, side by side.

An admin override was written into the skill's `breakdown` under a key the
recompute never read, and the recompute then replaced `breakdown` entirely:
once the hysteresis window had passed, the next recompute of any kind put
the evidence tier back. It is now a set of columns the recompute reads -
the tier (and, as before, optionally score and verified), who set it, when
and why - and it lasts until an admin removes it. `evidence_tier` is what
the evidence alone gives, so the admin page can show where they disagree.

Backfill: `evidence_tier` from the current tier. An override still present
in `breakdown.admin_override` - one the recompute has not erased yet - is
carried into the columns exactly. One already erased cannot be recovered
from this row; the deploy checklist lists them from the event log for an
admin to re-apply.

Revision ID: 20261013_0059
Revises: 20261012_0058
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "20261013_0059"
down_revision = "20261012_0058"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("pro_niche_skill", sa.Column("evidence_tier", sa.String(length=64), nullable=True))
    op.add_column("pro_niche_skill", sa.Column("override_tier", sa.String(length=64), nullable=True))
    op.add_column("pro_niche_skill", sa.Column("override_score", sa.Integer(), nullable=True))
    op.add_column("pro_niche_skill", sa.Column("override_verified", sa.Boolean(), nullable=True))
    op.add_column("pro_niche_skill", sa.Column("override_by", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("pro_niche_skill", sa.Column("override_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("pro_niche_skill", sa.Column("override_reason", sa.Text(), nullable=True))
    op.execute("UPDATE pro_niche_skill SET evidence_tier = tier")
    op.execute(
        """
        UPDATE pro_niche_skill
        SET override_tier = breakdown->'admin_override'->>'tier',
            override_score = (breakdown->'admin_override'->>'score')::int,
            override_verified = (breakdown->'admin_override'->>'verified')::boolean,
            override_by = (breakdown->'admin_override'->>'actor_user_id')::uuid,
            override_at = (breakdown->'admin_override'->>'at')::timestamptz,
            override_reason = breakdown->'admin_override'->>'note'
        WHERE breakdown ? 'admin_override'
        """
    )


def downgrade() -> None:
    for column in ("override_reason", "override_at", "override_by", "override_verified", "override_score", "override_tier", "evidence_tier"):
        op.drop_column("pro_niche_skill", column)
