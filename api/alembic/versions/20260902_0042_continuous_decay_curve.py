"""package_decay_curve: replace bracket-based tiers with a continuous
per-photo price function (curve_type + shape_param + floor_pct), to
remove the discontinuity in the marginal rate at each bracket boundary

Revision ID: 20260902_0042
Revises: 20260902_0041
Create Date: 2026-09-02 00:00:00.000000
"""
from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "20260902_0042"
down_revision: Union[str, Sequence[str], None] = "20260902_0041"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

curve_type_enum = sa.Enum("flat", "power", "exponential", name="package_curve_type", native_enum=False)

# (curve_type, shape_param, floor_pct) per niche slug - see the B-4 seed
# values in app/services/package_pricing.py for the reasoning.
NICHE_CURVE_PARAMS: dict[str, tuple[str, str | None, str]] = {
    "weddings": ("power", "0.35", "0.20"),
    "events_nightlife": ("power", "0.35", "0.20"),
    "sports": ("power", "0.35", "0.20"),
    "portraits": ("exponential", "0.08", "0.15"),
    "family": ("exponential", "0.08", "0.15"),
    "maternity": ("exponential", "0.08", "0.15"),
    "product": ("flat", None, "1.0000"),
    "corporate": ("flat", None, "1.0000"),
    "real_estate": ("flat", None, "1.0000"),
    "food": ("flat", None, "1.0000"),
    "automotive": ("flat", None, "1.0000"),
    "architecture": ("flat", None, "1.0000"),
}


def upgrade() -> None:
    op.add_column("package_decay_curve", sa.Column("curve_type", curve_type_enum, nullable=False, server_default="flat"))
    op.add_column("package_decay_curve", sa.Column("shape_param", sa.Numeric(6, 4), nullable=True))
    op.add_column("package_decay_curve", sa.Column("floor_pct", sa.Numeric(5, 4), nullable=False, server_default="1.0000"))
    op.drop_column("package_decay_curve", "tiers")

    connection = op.get_bind()
    for slug, (curve_type, shape_param, floor_pct) in NICHE_CURVE_PARAMS.items():
        connection.execute(
            sa.text(
                """
                UPDATE package_decay_curve
                SET curve_type = :curve_type, shape_param = :shape_param, floor_pct = :floor_pct
                FROM niche
                WHERE package_decay_curve.niche_id = niche.id AND niche.slug = :slug
                """
            ),
            {"curve_type": curve_type, "shape_param": shape_param, "floor_pct": floor_pct, "slug": slug},
        )


def downgrade() -> None:
    op.add_column("package_decay_curve", sa.Column("tiers", sa.JSON(), nullable=False, server_default="[]"))
    op.drop_column("package_decay_curve", "floor_pct")
    op.drop_column("package_decay_curve", "shape_param")
    op.drop_column("package_decay_curve", "curve_type")
