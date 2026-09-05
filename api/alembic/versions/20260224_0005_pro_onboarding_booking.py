"""pro onboarding, packages, availability, booking requests

Revision ID: 20260224_0005
Revises: 20260224_0004
Create Date: 2026-02-24 23:55:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260224_0005"
down_revision: Union[str, Sequence[str], None] = "20260224_0004"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


booking_request_status_enum = sa.Enum(
    "pending",
    "accepted",
    "declined",
    "expired",
    "cancelled",
    name="booking_request_status",
    native_enum=False,
)


def upgrade() -> None:
    op.add_column("pro_profile", sa.Column("display_name", sa.Text(), nullable=True))
    op.add_column("pro_profile", sa.Column("headline", sa.Text(), nullable=True))
    op.add_column("pro_profile", sa.Column("bio", sa.Text(), nullable=True))
    op.add_column("pro_profile", sa.Column("city", sa.Text(), nullable=True))
    op.add_column("pro_profile", sa.Column("country", sa.Text(), nullable=True))
    op.add_column("pro_profile", sa.Column("languages", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")))
    op.add_column("pro_profile", sa.Column("styles", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")))
    op.add_column("pro_profile", sa.Column("gear", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")))
    op.add_column("pro_profile", sa.Column("is_accepting_bookings", sa.Boolean(), nullable=False, server_default=sa.false()))
    op.add_column("pro_profile", sa.Column("completeness_score", sa.Integer(), nullable=False, server_default="0"))

    op.create_table(
        "pro_package",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("duration_minutes", sa.Integer(), nullable=False),
        sa.Column("price", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("included_photos", sa.Integer(), nullable=False),
        sa.Column("extra_photo_price", sa.Numeric(12, 2), nullable=False),
        sa.Column("proofs_sla_days", sa.Integer(), nullable=False, server_default="3"),
        sa.Column("finals_sla_days", sa.Integer(), nullable=False, server_default="7"),
        sa.Column("addons", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_pro_package_pro_user_id", "pro_package", ["pro_user_id"])

    op.create_table(
        "pro_availability_rule",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("day_of_week", sa.Integer(), nullable=False),
        sa.Column("start_time", sa.Time(), nullable=False),
        sa.Column("end_time", sa.Time(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_pro_availability_rule_pro_user_id", "pro_availability_rule", ["pro_user_id"])

    op.create_table(
        "pro_blackout_date",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("start_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("end_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_pro_blackout_date_pro_user_id", "pro_blackout_date", ["pro_user_id"])

    op.create_table(
        "booking_request",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("package_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("pro_package.id"), nullable=False),
        sa.Column("requested_start", sa.DateTime(timezone=True), nullable=False),
        sa.Column("requested_end", sa.DateTime(timezone=True), nullable=False),
        sa.Column("location_text", sa.Text(), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("status", booking_request_status_enum, nullable=False, server_default="pending"),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_booking_request_pro_user_id", "booking_request", ["pro_user_id"])
    op.create_index("ix_booking_request_client_user_id", "booking_request", ["client_user_id"])
    op.create_index("ix_booking_request_package_id", "booking_request", ["package_id"])

    op.create_table(
        "booking_request_transition",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("booking_request_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("booking_request.id"), nullable=False),
        sa.Column("from_status", booking_request_status_enum, nullable=False),
        sa.Column("to_status", booking_request_status_enum, nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_booking_request_transition_booking_request_id", "booking_request_transition", ["booking_request_id"])


def downgrade() -> None:
    op.drop_index("ix_booking_request_transition_booking_request_id", table_name="booking_request_transition")
    op.drop_table("booking_request_transition")

    op.drop_index("ix_booking_request_package_id", table_name="booking_request")
    op.drop_index("ix_booking_request_client_user_id", table_name="booking_request")
    op.drop_index("ix_booking_request_pro_user_id", table_name="booking_request")
    op.drop_table("booking_request")

    op.drop_index("ix_pro_blackout_date_pro_user_id", table_name="pro_blackout_date")
    op.drop_table("pro_blackout_date")

    op.drop_index("ix_pro_availability_rule_pro_user_id", table_name="pro_availability_rule")
    op.drop_table("pro_availability_rule")

    op.drop_index("ix_pro_package_pro_user_id", table_name="pro_package")
    op.drop_table("pro_package")

    op.drop_column("pro_profile", "completeness_score")
    op.drop_column("pro_profile", "is_accepting_bookings")
    op.drop_column("pro_profile", "gear")
    op.drop_column("pro_profile", "styles")
    op.drop_column("pro_profile", "languages")
    op.drop_column("pro_profile", "country")
    op.drop_column("pro_profile", "city")
    op.drop_column("pro_profile", "bio")
    op.drop_column("pro_profile", "headline")
    op.drop_column("pro_profile", "display_name")
