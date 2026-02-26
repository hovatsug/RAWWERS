"""i18n and multilanguage v1

Revision ID: 20260226_0031
Revises: 20260226_0030
Create Date: 2026-02-26 23:10:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260226_0031"
down_revision: Union[str, Sequence[str], None] = "20260226_0030"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


i18n_key_audit_status = sa.Enum("present", "missing", "unused", name="i18n_key_audit_status", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "user_locale_preference",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("locale", sa.Text(), nullable=False, server_default="en-GB"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "i18n_bundle",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("locale", sa.Text(), nullable=False),
        sa.Column("namespace", sa.Text(), nullable=False),
        sa.Column("version", sa.Integer(), nullable=False),
        sa.Column("content", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("locale", "namespace", "version", name="uq_i18n_bundle_locale_namespace_version"),
    )
    op.create_index("ix_i18n_bundle_locale", "i18n_bundle", ["locale"])
    op.create_index("ix_i18n_bundle_namespace", "i18n_bundle", ["namespace"])

    op.create_table(
        "i18n_key_audit",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("locale", sa.Text(), nullable=False),
        sa.Column("namespace", sa.Text(), nullable=False),
        sa.Column("key", sa.Text(), nullable=False),
        sa.Column("status", i18n_key_audit_status, nullable=False, server_default="present"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("locale", "namespace", "key", name="uq_i18n_key_audit_locale_namespace_key"),
    )
    op.create_index("ix_i18n_key_audit_locale", "i18n_key_audit", ["locale"])
    op.create_index("ix_i18n_key_audit_namespace", "i18n_key_audit", ["namespace"])
    op.create_index("ix_i18n_key_audit_key", "i18n_key_audit", ["key"])

    op.create_table(
        "localized_text",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("entity_type", sa.Text(), nullable=False),
        sa.Column("entity_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("locale", sa.Text(), nullable=False),
        sa.Column("fields", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("entity_type", "entity_id", "locale", name="uq_localized_text_entity_locale"),
    )
    op.create_index("ix_localized_text_entity_type", "localized_text", ["entity_type"])
    op.create_index("ix_localized_text_entity_id", "localized_text", ["entity_id"])
    op.create_index("ix_localized_text_locale", "localized_text", ["locale"])
    op.create_index("ix_localized_text_entity", "localized_text", ["entity_type", "entity_id"])

    op.add_column("milestone", sa.Column("name_key", sa.Text(), nullable=True))
    op.add_column("milestone", sa.Column("description_key", sa.Text(), nullable=True))
    op.create_index("ix_milestone_name_key", "milestone", ["name_key"])
    op.create_index("ix_milestone_description_key", "milestone", ["description_key"])

    op.add_column("performance_cycle", sa.Column("name_key", sa.Text(), nullable=True))
    op.create_index("ix_performance_cycle_name_key", "performance_cycle", ["name_key"])


def downgrade() -> None:
    op.drop_index("ix_performance_cycle_name_key", table_name="performance_cycle")
    op.drop_column("performance_cycle", "name_key")

    op.drop_index("ix_milestone_description_key", table_name="milestone")
    op.drop_index("ix_milestone_name_key", table_name="milestone")
    op.drop_column("milestone", "description_key")
    op.drop_column("milestone", "name_key")

    op.drop_index("ix_localized_text_entity", table_name="localized_text")
    op.drop_index("ix_localized_text_locale", table_name="localized_text")
    op.drop_index("ix_localized_text_entity_id", table_name="localized_text")
    op.drop_index("ix_localized_text_entity_type", table_name="localized_text")
    op.drop_table("localized_text")

    op.drop_index("ix_i18n_key_audit_key", table_name="i18n_key_audit")
    op.drop_index("ix_i18n_key_audit_namespace", table_name="i18n_key_audit")
    op.drop_index("ix_i18n_key_audit_locale", table_name="i18n_key_audit")
    op.drop_table("i18n_key_audit")

    op.drop_index("ix_i18n_bundle_namespace", table_name="i18n_bundle")
    op.drop_index("ix_i18n_bundle_locale", table_name="i18n_bundle")
    op.drop_table("i18n_bundle")

    op.drop_table("user_locale_preference")
