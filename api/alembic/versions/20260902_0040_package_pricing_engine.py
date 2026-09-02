"""base package pricing engine: decay curves, entry-price caps, gig amount split

Revision ID: 20260902_0040
Revises: 20260902_0039
Create Date: 2026-09-02 00:00:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260902_0040"
down_revision: Union[str, Sequence[str], None] = "20260902_0039"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

skill_tier_enum = sa.Enum(
    "rookie",
    "skilled",
    "pro",
    "elite",
    "master",
    name="skill_tier",
    native_enum=False,
)


def upgrade() -> None:
    op.alter_column("gig", "amount_total", new_column_name="amount_minimum")
    op.add_column("gig", sa.Column("amount_final", sa.Numeric(12, 2), nullable=True))

    op.create_table(
        "package_decay_curve",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False, unique=True),
        sa.Column("tiers", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_package_decay_curve_niche_id", "package_decay_curve", ["niche_id"])

    op.create_table(
        "niche_package_price_cap",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("tier", skill_tier_enum, nullable=False),
        sa.Column("entry_price_min", sa.Numeric(12, 2), nullable=False, server_default="0.00"),
        sa.Column("entry_price_max", sa.Numeric(12, 2), nullable=True),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("niche_id", "tier", name="uq_niche_package_price_cap_niche_tier"),
    )
    op.create_index("ix_niche_package_price_cap_niche_id", "niche_package_price_cap", ["niche_id"])


def downgrade() -> None:
    op.drop_table("niche_package_price_cap")
    op.drop_table("package_decay_curve")
    op.drop_column("gig", "amount_final")
    op.alter_column("gig", "amount_minimum", new_column_name="amount_total")
