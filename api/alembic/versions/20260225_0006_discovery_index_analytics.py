"""discovery index and analytics events

Revision ID: 20260225_0006
Revises: 20260224_0005
Create Date: 2026-02-25 00:30:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0006"
down_revision: Union[str, Sequence[str], None] = "20260224_0005"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


kyc_status_enum = sa.Enum("unsubmitted", "pending", "approved", "rejected", name="kyc_status", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "pro_public_index",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("city", sa.Text(), nullable=True),
        sa.Column("country", sa.Text(), nullable=True),
        sa.Column("styles", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("min_package_price", sa.Numeric(12, 2), nullable=True),
        sa.Column("max_package_price", sa.Numeric(12, 2), nullable=True),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("is_accepting_bookings", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("kyc_status", kyc_status_enum, nullable=False, server_default="unsubmitted"),
        sa.Column("completeness_score", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("portfolio_photo_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("portfolio_video_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("gigs_completed", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("gigs_cancelled", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("disputes_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("avg_response_minutes", sa.Integer(), nullable=True),
        sa.Column("ranking_score", sa.Numeric(10, 4), nullable=False, server_default="0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_pro_public_index_is_accepting_bookings", "pro_public_index", ["is_accepting_bookings"])
    op.create_index("ix_pro_public_index_kyc_status", "pro_public_index", ["kyc_status"])
    op.create_index("ix_pro_public_index_completeness_score", "pro_public_index", ["completeness_score"])
    op.create_index("ix_pro_public_index_ranking_score", "pro_public_index", [sa.text("ranking_score DESC")])
    op.create_index("ix_pro_public_index_city_ranking", "pro_public_index", ["city", sa.text("ranking_score DESC")])
    op.create_index("ix_pro_public_index_min_package_price", "pro_public_index", ["min_package_price"])

    op.create_table(
        "analytics_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("session_id", sa.Text(), nullable=True),
        sa.Column("event_name", sa.Text(), nullable=False),
        sa.Column("properties", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_analytics_event_event_name", "analytics_event", ["event_name"])
    op.create_index("ix_analytics_event_created_at", "analytics_event", ["created_at"])
    op.create_index("ix_analytics_event_name_created", "analytics_event", ["event_name", sa.text("created_at DESC")])


def downgrade() -> None:
    op.drop_index("ix_analytics_event_name_created", table_name="analytics_event")
    op.drop_index("ix_analytics_event_created_at", table_name="analytics_event")
    op.drop_index("ix_analytics_event_event_name", table_name="analytics_event")
    op.drop_table("analytics_event")

    op.drop_index("ix_pro_public_index_min_package_price", table_name="pro_public_index")
    op.drop_index("ix_pro_public_index_city_ranking", table_name="pro_public_index")
    op.drop_index("ix_pro_public_index_ranking_score", table_name="pro_public_index")
    op.drop_index("ix_pro_public_index_completeness_score", table_name="pro_public_index")
    op.drop_index("ix_pro_public_index_kyc_status", table_name="pro_public_index")
    op.drop_index("ix_pro_public_index_is_accepting_bookings", table_name="pro_public_index")
    op.drop_table("pro_public_index")
