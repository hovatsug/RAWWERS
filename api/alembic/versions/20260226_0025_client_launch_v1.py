"""client launch v1 gating matching funnel

Revision ID: 20260226_0025
Revises: 20260226_0023
Create Date: 2026-02-26 12:10:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260226_0025"
down_revision: Union[str, Sequence[str], None] = "20260226_0023"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


client_waitlist_status_enum = sa.Enum("pending", "invited", "converted", name="client_waitlist_status", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "client_waitlist",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("email", sa.Text(), nullable=False),
        sa.Column("country", sa.Text(), nullable=False),
        sa.Column("city", sa.Text(), nullable=False),
        sa.Column("niche_slug", sa.Text(), nullable=True),
        sa.Column("status", client_waitlist_status_enum, nullable=False, server_default="pending"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("email", "country", "city", name="uq_client_waitlist_email_country_city"),
    )
    op.create_index("ix_client_waitlist_email", "client_waitlist", ["email"])

    op.create_table(
        "client_preference",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), primary_key=True, nullable=False),
        sa.Column("preferred_niches", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("budget_min", sa.Numeric(12, 2), nullable=True),
        sa.Column("budget_max", sa.Numeric(12, 2), nullable=True),
        sa.Column("style_tags", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("location", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("consent_default", sa.Enum("none", "pro_marketing_only", "rawwers_marketing_only", "both_pro_and_rawwers", name="gig_consent_level", native_enum=False), nullable=False, server_default="none"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "match_request",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("country", sa.Text(), nullable=False),
        sa.Column("city", sa.Text(), nullable=False),
        sa.Column("niche_slug", sa.Text(), nullable=False),
        sa.Column("budget_min", sa.Numeric(12, 2), nullable=True),
        sa.Column("budget_max", sa.Numeric(12, 2), nullable=True),
        sa.Column("style_tags", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_match_request_user_id", "match_request", ["user_id"])
    op.create_index("ix_match_request_created_at", "match_request", ["created_at"])

    op.create_table(
        "match_result",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("match_request_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("match_request.id"), nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("rank", sa.Integer(), nullable=False),
        sa.Column("score", sa.Numeric(10, 4), nullable=False),
        sa.Column("score_breakdown", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_match_result_match_request_id", "match_result", ["match_request_id"])
    op.create_index("ix_match_result_pro_user_id", "match_result", ["pro_user_id"])


def downgrade() -> None:
    op.drop_index("ix_match_result_pro_user_id", table_name="match_result")
    op.drop_index("ix_match_result_match_request_id", table_name="match_result")
    op.drop_table("match_result")

    op.drop_index("ix_match_request_created_at", table_name="match_request")
    op.drop_index("ix_match_request_user_id", table_name="match_request")
    op.drop_table("match_request")

    op.drop_table("client_preference")

    op.drop_index("ix_client_waitlist_email", table_name="client_waitlist")
    op.drop_table("client_waitlist")

    client_waitlist_status_enum.drop(op.get_bind(), checkfirst=True)
