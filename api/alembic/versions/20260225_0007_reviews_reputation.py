"""reviews reputation and moderation

Revision ID: 20260225_0007
Revises: 20260225_0006
Create Date: 2026-02-25 01:20:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0007"
down_revision: Union[str, Sequence[str], None] = "20260225_0006"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


review_status_enum = sa.Enum("published", "hidden", "removed", name="review_status", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "review",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False, unique=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("rating", sa.Integer(), nullable=False),
        sa.Column("tags", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("text", sa.Text(), nullable=True),
        sa.Column("would_book_again", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("video_media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=True),
        sa.Column("status", review_status_enum, nullable=False, server_default="published"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.CheckConstraint("rating >= 1 AND rating <= 5", name="ck_review_rating_1_5"),
    )
    op.create_index("ix_review_gig_id", "review", ["gig_id"], unique=True)
    op.create_index("ix_review_pro_user_id", "review", ["pro_user_id"])
    op.create_index("ix_review_client_user_id", "review", ["client_user_id"])
    op.create_index("ix_review_status", "review", ["status"])

    op.create_table(
        "review_reply",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("review_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("review.id"), nullable=False, unique=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("text", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_review_reply_review_id", "review_reply", ["review_id"], unique=True)
    op.create_index("ix_review_reply_pro_user_id", "review_reply", ["pro_user_id"])

    op.create_table(
        "pro_reputation",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("avg_rating", sa.Numeric(3, 2), nullable=False, server_default="0"),
        sa.Column("review_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("would_book_again_rate", sa.Numeric(5, 2), nullable=False, server_default="0"),
        sa.Column("tag_counts", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("last_review_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )

    op.add_column("pro_public_index", sa.Column("avg_rating", sa.Numeric(3, 2), nullable=False, server_default="0"))
    op.add_column("pro_public_index", sa.Column("review_count", sa.Integer(), nullable=False, server_default="0"))


def downgrade() -> None:
    op.drop_column("pro_public_index", "review_count")
    op.drop_column("pro_public_index", "avg_rating")

    op.drop_table("pro_reputation")

    op.drop_index("ix_review_reply_pro_user_id", table_name="review_reply")
    op.drop_index("ix_review_reply_review_id", table_name="review_reply")
    op.drop_table("review_reply")

    op.drop_index("ix_review_status", table_name="review")
    op.drop_index("ix_review_client_user_id", table_name="review")
    op.drop_index("ix_review_pro_user_id", table_name="review")
    op.drop_index("ix_review_gig_id", table_name="review")
    op.drop_table("review")
