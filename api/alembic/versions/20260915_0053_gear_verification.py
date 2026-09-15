"""Gear proven to meet the platform's floor.

Kept apart from `gear_item`, which exists for theft and insurance records. A
photographer may legitimately log a crop body there; if verification read the
same rows, "I own this" and "this qualifies me to work" would be one
statement instead of two.

The serial uniqueness is partial - unique only while a claim is `verified` -
so releasing gear frees the serial for whoever owns it next. That is what
selling a camera should do, and a plain unique constraint would have made it
impossible.

Revision ID: 20260915_0053
Revises: 20260915_0052
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "20260915_0053"
down_revision = "20260915_0052"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "camera_model_reference",
        sa.Column("normalised_model", sa.Text(), primary_key=True),
        sa.Column("make", sa.Text(), nullable=True),
        sa.Column("display_name", sa.Text(), nullable=False),
        sa.Column("sensor_size", sa.String(64), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_table(
        "lens_model_reference",
        sa.Column("normalised_model", sa.Text(), primary_key=True),
        sa.Column("make", sa.Text(), nullable=True),
        sa.Column("display_name", sa.Text(), nullable=False),
        sa.Column("aperture_type", sa.String(64), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_table(
        "gear_verification",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "gear_item_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("gear_item.id", ondelete="SET NULL"),
            nullable=True,
        ),
        sa.Column("category", sa.String(64), nullable=False),
        sa.Column("status", sa.String(64), nullable=False, server_default="pending_review"),
        sa.Column("make", sa.Text(), nullable=True),
        sa.Column("model", sa.Text(), nullable=True),
        sa.Column("serial_number", sa.Text(), nullable=True),
        sa.Column("sensor_size", sa.String(64), nullable=True),
        sa.Column("aperture_type", sa.String(64), nullable=True),
        sa.Column("min_focal_mm", sa.Numeric(7, 2), nullable=True),
        sa.Column("max_focal_mm", sa.Numeric(7, 2), nullable=True),
        sa.Column("max_aperture", sa.Numeric(5, 2), nullable=True),
        sa.Column("review_reason", sa.Text(), nullable=True),
        sa.Column("evidence_media_asset_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("metadata", postgresql.JSONB(), nullable=False, server_default="{}"),
        sa.Column("verified_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_gear_verification_pro_user_id", "gear_verification", ["pro_user_id"])
    op.create_index("ix_gear_verification_gear_item_id", "gear_verification", ["gear_item_id"])
    op.create_index(
        "ix_gear_verification_pro_status", "gear_verification", ["pro_user_id", "status"]
    )
    op.create_index(
        "uq_gear_verification_live_serial",
        "gear_verification",
        ["serial_number"],
        unique=True,
        postgresql_where=sa.text("status = 'verified'"),
    )


def downgrade() -> None:
    op.drop_table("gear_verification")
    op.drop_table("lens_model_reference")
    op.drop_table("camera_model_reference")
