"""Delivery uploads: the gallery a proof is for, and one live photo per file per gallery.

media_asset.delivery_gallery_id names the gallery a proof was uploaded for;
media_asset.checksum (there since the start, never written until now) holds
the SHA-256 of the original. A partial unique index keeps one live photo per
file per gallery; failed and deleted photos do not count. Existing rows have
neither value and are unaffected.

Revision ID: 20261029_0074
Revises: 20261023_0073
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261029_0074"
down_revision = "20261023_0073"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "media_asset",
        sa.Column("delivery_gallery_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("proof_gallery.id"), nullable=True),
    )
    op.create_index(
        "ux_media_asset_delivery_file",
        "media_asset",
        ["delivery_gallery_id", "checksum"],
        unique=True,
        postgresql_where=sa.text("delivery_gallery_id IS NOT NULL AND checksum IS NOT NULL AND status NOT IN ('failed', 'deleted')"),
    )


def downgrade() -> None:
    op.drop_index("ux_media_asset_delivery_file", table_name="media_asset")
    op.drop_column("media_asset", "delivery_gallery_id")
