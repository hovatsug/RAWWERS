"""UK VAT, structured so a second country is a row rather than a rewrite.

`country_tax_rule` is keyed by country, the same shape
`niche_package_price_cap` uses for niche and tier. Exactly one row is
populated.

`tax_profile` gains a three-state status. Not a boolean: a photographer who
has never been asked is materially different from one who has said they are
not registered, and inferring the latter from an absent VAT number would be
the zero-versus-unavailable mistake in a new field. It defaults to
not_answered so no existing row is made to claim an answer nobody gave.

The gig gains a stamped VAT rate, status and number, alongside the commission
rates it already stamps, for the same reason: the UK rate has changed three
times this century and an invoice must reproduce what applied at the time.

Revision ID: 20260915_0052
Revises: 20260914_0051
"""
from alembic import op
import sqlalchemy as sa

revision = "20260915_0052"
down_revision = "20260914_0051"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "country_tax_rule",
        sa.Column("country", sa.CHAR(2), primary_key=True),
        sa.Column("tax_name", sa.Text(), nullable=False, server_default="VAT"),
        sa.Column("standard_rate_percent", sa.Integer(), nullable=False),
        sa.Column("registration_threshold", sa.Numeric(14, 2), nullable=True),
        sa.Column("threshold_currency", sa.CHAR(3), nullable=True),
        sa.Column("vat_number_format", sa.Text(), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.add_column(
        "tax_profile",
        sa.Column("vat_status", sa.String(64), nullable=False, server_default="not_answered"),
    )
    op.add_column("gig", sa.Column("vat_rate_percent", sa.Integer(), nullable=True))
    op.add_column("gig", sa.Column("vat_status", sa.Text(), nullable=True))
    op.add_column("gig", sa.Column("vat_number", sa.Text(), nullable=True))


def downgrade() -> None:
    for column in ("vat_number", "vat_status", "vat_rate_percent"):
        op.drop_column("gig", column)
    op.drop_column("tax_profile", "vat_status")
    op.drop_table("country_tax_rule")
