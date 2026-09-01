"""scheduling availability v1

Revision ID: 20260226_0026
Revises: 20260226_0025
Create Date: 2026-02-26 14:00:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260226_0026"
down_revision: Union[str, Sequence[str], None] = "20260226_0025"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


availability_location_mode_enum = sa.Enum("on_site", "studio", "both", name="availability_location_mode", native_enum=False)
confirmed_slot_status_enum = sa.Enum("reserved", "confirmed", "cancelled", "completed", name="confirmed_slot_status", native_enum=False)


def upgrade() -> None:
    op.add_column("pro_availability_rule", sa.Column("timezone", sa.Text(), nullable=False, server_default="UTC"))
    op.add_column("pro_availability_rule", sa.Column("location_mode", availability_location_mode_enum, nullable=False, server_default="both"))
    op.add_column("pro_availability_rule", sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")))

    op.create_table(
        "pro_availability_exception",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("start_at_utc", sa.DateTime(timezone=True), nullable=False),
        sa.Column("end_at_utc", sa.DateTime(timezone=True), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_pro_availability_exception_pro_user_id", "pro_availability_exception", ["pro_user_id"])

    op.create_table(
        "pro_scheduling_policy",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("slot_length_minutes", sa.Integer(), nullable=False, server_default="60"),
        sa.Column("buffer_before_minutes", sa.Integer(), nullable=False, server_default="15"),
        sa.Column("buffer_after_minutes", sa.Integer(), nullable=False, server_default="15"),
        sa.Column("advance_notice_hours", sa.Integer(), nullable=False, server_default="24"),
        sa.Column("max_bookings_per_day", sa.Integer(), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "booking_time_request",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("booking_request_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("booking_request.id"), nullable=False),
        sa.Column("client_timezone", sa.Text(), nullable=False),
        sa.Column("windows", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_booking_time_request_booking_request_id", "booking_time_request", ["booking_request_id"])

    op.create_table(
        "confirmed_slot",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False, unique=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("start_at_utc", sa.DateTime(timezone=True), nullable=False),
        sa.Column("end_at_utc", sa.DateTime(timezone=True), nullable=False),
        sa.Column("status", confirmed_slot_status_enum, nullable=False, server_default="confirmed"),
        sa.Column("cancellation_reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("pro_user_id", "start_at_utc", "end_at_utc", name="uq_confirmed_slot_pro_time"),
    )
    op.create_index("ix_confirmed_slot_gig_id", "confirmed_slot", ["gig_id"])
    op.create_index("ix_confirmed_slot_pro_user_id", "confirmed_slot", ["pro_user_id"])
    op.create_index("ix_confirmed_slot_client_user_id", "confirmed_slot", ["client_user_id"])

    op.create_table(
        "cancellation_policy_snapshot",
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), primary_key=True, nullable=False),
        sa.Column("snapshot", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        op.execute("CREATE EXTENSION IF NOT EXISTS btree_gist")
        op.execute(
            """
            ALTER TABLE confirmed_slot
            ADD CONSTRAINT confirmed_slot_no_overlap
            EXCLUDE USING gist (
                pro_user_id WITH =,
                tstzrange(start_at_utc, end_at_utc, '[)') WITH &&
            )
            """
        )


def downgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        op.execute("ALTER TABLE confirmed_slot DROP CONSTRAINT IF EXISTS confirmed_slot_no_overlap")

    op.drop_table("cancellation_policy_snapshot")

    op.drop_index("ix_confirmed_slot_client_user_id", table_name="confirmed_slot")
    op.drop_index("ix_confirmed_slot_pro_user_id", table_name="confirmed_slot")
    op.drop_index("ix_confirmed_slot_gig_id", table_name="confirmed_slot")
    op.drop_table("confirmed_slot")

    op.drop_index("ix_booking_time_request_booking_request_id", table_name="booking_time_request")
    op.drop_table("booking_time_request")

    op.drop_table("pro_scheduling_policy")

    op.drop_index("ix_pro_availability_exception_pro_user_id", table_name="pro_availability_exception")
    op.drop_table("pro_availability_exception")

    op.drop_column("pro_availability_rule", "updated_at")
    op.drop_column("pro_availability_rule", "location_mode")
    op.drop_column("pro_availability_rule", "timezone")

    confirmed_slot_status_enum.drop(op.get_bind(), checkfirst=True)
    availability_location_mode_enum.drop(op.get_bind(), checkfirst=True)
