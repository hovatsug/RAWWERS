"""niches taxonomy and per-niche skills

Revision ID: 20260225_0011
Revises: 20260225_0010
Create Date: 2026-02-25 18:00:00.000000
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0011"
down_revision: Union[str, Sequence[str], None] = "20260225_0010"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


declared_level_enum = sa.Enum("beginner", "intermediate", "advanced", "expert", name="declared_level", native_enum=False)
skill_tier_enum = sa.Enum("rookie", "skilled", "pro", "elite", "master", name="skill_tier", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "niche",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("slug", sa.Text(), nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_niche_slug", "niche", ["slug"], unique=True)

    op.create_table(
        "pro_niche",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("declared_level", declared_level_enum, nullable=True),
        sa.Column("is_primary", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("pro_user_id", "niche_id", name="uq_pro_niche_pro_niche"),
    )
    op.create_index("ix_pro_niche_pro_user_id", "pro_niche", ["pro_user_id"])
    op.create_index("ix_pro_niche_niche_id", "pro_niche", ["niche_id"])

    op.add_column("pro_package", sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=True))
    op.create_index("ix_pro_package_niche_id", "pro_package", ["niche_id"])

    op.add_column("gig", sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=True))
    op.create_index("ix_gig_niche_id", "gig", ["niche_id"])

    op.add_column("review", sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=True))
    op.create_index("ix_review_niche_id", "review", ["niche_id"])

    op.add_column(
        "media_asset",
        sa.Column(
            "niche_tags",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'[]'::jsonb"),
        ),
    )

    op.create_table(
        "pro_niche_skill",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("capability_score", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("certification_score", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("confidence", sa.Numeric(3, 2), nullable=False, server_default="0.00"),
        sa.Column("tier", skill_tier_enum, nullable=False, server_default="rookie"),
        sa.Column("evidence_gigs", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("evidence_reviews", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("evidence_portfolio", sa.Integer(), nullable=False, server_default="0"),
        sa.Column(
            "breakdown",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("pro_user_id", "niche_id", name="uq_pro_niche_skill_pro_niche"),
    )
    op.create_index("ix_pro_niche_skill_pro_user_id", "pro_niche_skill", ["pro_user_id"])
    op.create_index("ix_pro_niche_skill_niche_id", "pro_niche_skill", ["niche_id"])

    op.create_table(
        "certification_record",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("cert_code", sa.Text(), nullable=False),
        sa.Column("score", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.UniqueConstraint("pro_user_id", "niche_id", "cert_code", name="uq_cert_record_pro_niche_code"),
    )
    op.create_index("ix_certification_record_pro_user_id", "certification_record", ["pro_user_id"])
    op.create_index("ix_certification_record_niche_id", "certification_record", ["niche_id"])

    op.add_column("pro_public_index", sa.Column("primary_niche_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column(
        "pro_public_index",
        sa.Column(
            "top_niches",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'[]'::jsonb"),
        ),
    )

    seed_rows = [
        ("weddings", "Weddings"),
        ("portraits", "Portraits"),
        ("family", "Family"),
        ("corporate", "Corporate"),
        ("events_nightlife", "Events & Nightlife"),
        ("product", "Product"),
        ("real_estate", "Real Estate"),
        ("food", "Food"),
        ("automotive", "Automotive"),
        ("sports", "Sports"),
        ("maternity", "Maternity"),
        ("architecture", "Architecture"),
    ]
    now = datetime.now(timezone.utc)
    op.bulk_insert(
        sa.table(
            "niche",
            sa.column("id", postgresql.UUID(as_uuid=True)),
            sa.column("slug", sa.Text()),
            sa.column("name", sa.Text()),
            sa.column("description", sa.Text()),
            sa.column("is_active", sa.Boolean()),
            sa.column("created_at", sa.DateTime(timezone=True)),
            sa.column("updated_at", sa.DateTime(timezone=True)),
        ),
        [
            {
                "id": uuid.uuid4(),
                "slug": slug,
                "name": name,
                "description": None,
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            }
            for slug, name in seed_rows
        ],
    )

    op.execute("UPDATE pro_package p SET niche_id = n.id FROM niche n WHERE n.slug = 'portraits' AND p.niche_id IS NULL")
    op.execute("UPDATE gig g SET niche_id = n.id FROM niche n WHERE n.slug = 'portraits' AND g.niche_id IS NULL")
    op.execute(
        "UPDATE review r SET niche_id = g.niche_id FROM gig g WHERE g.id = r.gig_id AND r.niche_id IS NULL AND g.niche_id IS NOT NULL"
    )
    op.execute("UPDATE review r SET niche_id = n.id FROM niche n WHERE n.slug = 'portraits' AND r.niche_id IS NULL")

    op.alter_column("pro_package", "niche_id", nullable=False)
    op.alter_column("review", "niche_id", nullable=False)


def downgrade() -> None:
    op.drop_column("pro_public_index", "top_niches")
    op.drop_column("pro_public_index", "primary_niche_id")

    op.drop_index("ix_certification_record_niche_id", table_name="certification_record")
    op.drop_index("ix_certification_record_pro_user_id", table_name="certification_record")
    op.drop_table("certification_record")

    op.drop_index("ix_pro_niche_skill_niche_id", table_name="pro_niche_skill")
    op.drop_index("ix_pro_niche_skill_pro_user_id", table_name="pro_niche_skill")
    op.drop_table("pro_niche_skill")

    op.drop_column("media_asset", "niche_tags")

    op.drop_index("ix_review_niche_id", table_name="review")
    op.drop_column("review", "niche_id")

    op.drop_index("ix_gig_niche_id", table_name="gig")
    op.drop_column("gig", "niche_id")

    op.drop_index("ix_pro_package_niche_id", table_name="pro_package")
    op.drop_column("pro_package", "niche_id")

    op.drop_index("ix_pro_niche_niche_id", table_name="pro_niche")
    op.drop_index("ix_pro_niche_pro_user_id", table_name="pro_niche")
    op.drop_table("pro_niche")

    op.drop_index("ix_niche_slug", table_name="niche")
    op.drop_table("niche")
