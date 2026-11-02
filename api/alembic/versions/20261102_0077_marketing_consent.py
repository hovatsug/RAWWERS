"""Marketing-use consent (closed beta).

Seven new tables, nothing existing changes. Consent records cannot be
deleted (a trigger refuses it), and the scope and term are held to their
lists by check constraints. The two placeholder wordings ("draft", not
legally reviewed) are seeded active; in production the feature stays off
while either is still a draft.

Revision ID: 20261102_0077
Revises: 20261101_0076
"""
from datetime import datetime, timezone

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261102_0077"
down_revision = "20261101_0076"
branch_labels = None
depends_on = None

UUID = postgresql.UUID(as_uuid=True)
TS = sa.DateTime(timezone=True)

CLIENT_DRAFT = (
    "DRAFT - not legally reviewed. You let RAWWERS show the photos you choose on RAWWERS's own channels "
    "(organic posts only, no advertising) for the term you pick, credited to your photographer. You can "
    "withdraw at any time in Settings > Marketing permissions; RAWWERS then takes them down within 30 days. "
    "Everyone shown is an adult who agrees, or you are their parent or guardian."
)
PHOTOGRAPHER_DRAFT = (
    "DRAFT - not legally reviewed. RAWWERS may ask your clients whether it can feature photos from your "
    "bookings on its own channels. You keep ownership; RAWWERS gets a non-exclusive licence for its own "
    "marketing only, and always credits you by name. You can turn it off for any booking before the client "
    "is asked, and it is never offered for a booking that includes children."
)


def upgrade() -> None:
    op.create_table(
        "marketing_wording",
        sa.Column("version", sa.Text(), primary_key=True),
        sa.Column("audience", sa.String(length=32), nullable=False),
        sa.Column("text", sa.Text(), nullable=False),
        sa.Column("is_draft", sa.Boolean(), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", TS, nullable=False),
    )
    op.create_table(
        "pro_marketing_agreement",
        sa.Column("id", UUID, primary_key=True),
        sa.Column("pro_user_id", UUID, nullable=False),
        sa.Column("opted_in", sa.Boolean(), nullable=False),
        sa.Column("wording_version", sa.Text(), sa.ForeignKey("marketing_wording.version"), nullable=False),
        sa.Column("recorded_at", TS, nullable=False),
    )
    op.create_index("ix_pro_marketing_agreement_pro_user_id", "pro_marketing_agreement", ["pro_user_id"])
    op.create_index("ix_pro_marketing_agreement_recorded_at", "pro_marketing_agreement", ["recorded_at"])
    op.create_table(
        "booking_marketing_setting",
        sa.Column("gig_id", UUID, sa.ForeignKey("gig.id"), primary_key=True),
        sa.Column("allow_marketing", sa.Boolean(), nullable=False),
        sa.Column("includes_children", sa.Boolean(), nullable=False),
        sa.Column("updated_by_user_id", UUID, nullable=False),
        sa.Column("updated_at", TS, nullable=False),
    )
    op.create_table(
        "marketing_consent",
        sa.Column("id", UUID, primary_key=True),
        sa.Column("client_user_id", UUID, nullable=False),
        sa.Column("gig_id", UUID, sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("pro_user_id", UUID, nullable=False),
        sa.Column("media_asset_id", UUID, sa.ForeignKey("media_asset.id"), nullable=False),
        sa.Column("wording_version", sa.Text(), sa.ForeignKey("marketing_wording.version"), nullable=False),
        sa.Column("wording_text", sa.Text(), nullable=False),
        sa.Column("scope", sa.Text(), nullable=False),
        sa.Column("term_months", sa.Integer(), nullable=False),
        sa.Column("granted_at", TS, nullable=False),
        sa.Column("ends_at", TS, nullable=False),
        sa.Column("status", sa.Text(), nullable=False),
        sa.Column("withdrawn_at", TS, nullable=True),
        sa.Column("expired_at", TS, nullable=True),
        sa.Column("photographer_credit", sa.Text(), nullable=False),
        sa.Column("people_confirmed", sa.Boolean(), nullable=False),
        sa.Column("renews_consent_id", UUID, sa.ForeignKey("marketing_consent.id"), nullable=True),
        sa.Column("renewal_prompted_at", TS, nullable=True),
        sa.CheckConstraint("scope IN ('rawwers_organic')", name="ck_marketing_consent_scope"),
        sa.CheckConstraint("term_months IN (6, 12, 24)", name="ck_marketing_consent_term"),
        sa.CheckConstraint("status IN ('active', 'withdrawn', 'expired')", name="ck_marketing_consent_status"),
    )
    for column in ("client_user_id", "gig_id", "pro_user_id", "media_asset_id", "ends_at", "status"):
        op.create_index(f"ix_marketing_consent_{column}", "marketing_consent", [column])
    op.execute(
        """
        CREATE OR REPLACE FUNCTION marketing_consent_no_delete() RETURNS trigger AS $$
        BEGIN
            RAISE EXCEPTION 'marketing_consent rows are never deleted; withdraw or expire them';
        END;
        $$ LANGUAGE plpgsql;
        """
    )
    op.execute(
        "CREATE TRIGGER marketing_consent_no_delete BEFORE DELETE ON marketing_consent "
        "FOR EACH ROW EXECUTE FUNCTION marketing_consent_no_delete();"
    )
    op.create_table(
        "marketing_content_use",
        sa.Column("id", UUID, primary_key=True),
        sa.Column("content_name", sa.Text(), nullable=False),
        sa.Column("used_on", sa.Date(), nullable=False),
        sa.Column("owned_channel", sa.Boolean(), nullable=False),
        sa.Column("recorded_by_user_id", UUID, nullable=False),
        sa.Column("created_at", TS, nullable=False),
    )
    op.create_table(
        "marketing_content_use_consent",
        sa.Column("use_id", UUID, sa.ForeignKey("marketing_content_use.id"), primary_key=True),
        sa.Column("consent_id", UUID, sa.ForeignKey("marketing_consent.id"), primary_key=True),
    )
    op.create_table(
        "marketing_original_access",
        sa.Column("id", UUID, primary_key=True),
        sa.Column("consent_id", UUID, sa.ForeignKey("marketing_consent.id"), nullable=False),
        sa.Column("admin_user_id", UUID, nullable=False),
        sa.Column("accessed_at", TS, nullable=False),
    )
    op.create_index("ix_marketing_original_access_consent_id", "marketing_original_access", ["consent_id"])

    wording = sa.table(
        "marketing_wording",
        sa.column("version", sa.Text()), sa.column("audience", sa.String()), sa.column("text", sa.Text()),
        sa.column("is_draft", sa.Boolean()), sa.column("is_active", sa.Boolean()), sa.column("created_at", TS),
    )
    now = datetime.now(timezone.utc)
    op.bulk_insert(
        wording,
        [
            {"version": "client-draft-1", "audience": "client", "text": CLIENT_DRAFT, "is_draft": True, "is_active": True, "created_at": now},
            {"version": "photographer-draft-1", "audience": "photographer", "text": PHOTOGRAPHER_DRAFT, "is_draft": True, "is_active": True, "created_at": now},
        ],
    )


def downgrade() -> None:
    op.drop_index("ix_marketing_original_access_consent_id", table_name="marketing_original_access")
    op.drop_table("marketing_original_access")
    op.drop_table("marketing_content_use_consent")
    op.drop_table("marketing_content_use")
    op.execute("DROP TRIGGER IF EXISTS marketing_consent_no_delete ON marketing_consent")
    for column in ("client_user_id", "gig_id", "pro_user_id", "media_asset_id", "ends_at", "status"):
        op.drop_index(f"ix_marketing_consent_{column}", table_name="marketing_consent")
    op.drop_table("marketing_consent")
    op.execute("DROP FUNCTION IF EXISTS marketing_consent_no_delete()")
    op.drop_table("booking_marketing_setting")
    op.drop_index("ix_pro_marketing_agreement_recorded_at", table_name="pro_marketing_agreement")
    op.drop_index("ix_pro_marketing_agreement_pro_user_id", table_name="pro_marketing_agreement")
    op.drop_table("pro_marketing_agreement")
    op.drop_table("marketing_wording")
