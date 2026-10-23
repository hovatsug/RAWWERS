"""Niche banners: a style per niche, a tagline, and every banner image kept.

niche gains banner_style ('image' by default, which is what every niche has
been: an image or, with none uploaded, the neutral ground), banner_tagline
and banner_tagline_key. niche_banner keeps each image a niche has used, with
its alt text, focal point, source record, measured scrim and placeholder;
the database allows one current and one previous per niche. Nothing is
created for existing niches: they start with no image, as now.

Revision ID: 20261023_0072
Revises: 20261023_0071
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261023_0072"
down_revision = "20261023_0071"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("niche", sa.Column("banner_style", sa.Text(), nullable=False, server_default="image"))
    op.add_column("niche", sa.Column("banner_tagline", sa.Text(), nullable=True))
    op.add_column("niche", sa.Column("banner_tagline_key", sa.Text(), nullable=True))
    op.create_check_constraint("ck_niche_banner_style", "niche", "banner_style in ('image', 'text')")

    op.create_table(
        "niche_banner",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=False),
        sa.Column("state", sa.Text(), nullable=False),
        sa.Column("alt_text", sa.Text(), nullable=False),
        sa.Column("focal_x", sa.Numeric(4, 3), nullable=False),
        sa.Column("focal_y", sa.Numeric(4, 3), nullable=False),
        sa.Column("source", sa.Text(), nullable=False),
        sa.Column("credit", sa.Text(), nullable=True),
        sa.Column("licence", sa.Text(), nullable=True),
        sa.Column("source_url", sa.Text(), nullable=True),
        sa.Column("width", sa.Integer(), nullable=False),
        sa.Column("height", sa.Integer(), nullable=False),
        sa.Column("scrim_opacity", sa.Numeric(3, 2), nullable=False),
        sa.Column("placeholder", sa.Text(), nullable=False),
        sa.Column("created_by_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.CheckConstraint("state in ('current', 'previous', 'past')", name="ck_niche_banner_state"),
        sa.CheckConstraint("source in ('owner', 'stock')", name="ck_niche_banner_source"),
    )
    op.create_index("ix_niche_banner_niche_id", "niche_banner", ["niche_id"])
    op.create_index("uq_niche_banner_current", "niche_banner", ["niche_id"], unique=True, postgresql_where=sa.text("state = 'current'"))
    op.create_index("uq_niche_banner_previous", "niche_banner", ["niche_id"], unique=True, postgresql_where=sa.text("state = 'previous'"))


def downgrade() -> None:
    op.drop_index("uq_niche_banner_previous", table_name="niche_banner")
    op.drop_index("uq_niche_banner_current", table_name="niche_banner")
    op.drop_index("ix_niche_banner_niche_id", table_name="niche_banner")
    op.drop_table("niche_banner")
    op.drop_constraint("ck_niche_banner_style", "niche", type_="check")
    op.drop_column("niche", "banner_tagline_key")
    op.drop_column("niche", "banner_tagline")
    op.drop_column("niche", "banner_style")
