"""Multi-currency M4: caps, discovery, client credit and RAWW per currency
(docs/MULTI_CURRENCY.md 5, 6.1 migrations 3 and 4; high-risk: money).

- Price caps and extra-photo price bounds are keyed by (niche, tier,
  currency); a photographer's own extra-photo price takes their currency
  (backfilled from pro_profile.currency).
- Client credit per currency: reward_ledger_entry.currency and
  reward_balance keyed by (user, currency), backfilled EUR (all credit so
  far is in euros); a monthly marketing budget in pounds beside the euro one
  (default 300.00) with its own 80%/100% alert months.
- pro_public_index.min_package_price_base_minor: the cheapest package in
  euro cents, for the budget filter across currencies (euros backfilled
  exactly; other currencies get it from the display rate, batch M3).
- RAWW per currency: shelf_settings.raww_gbp_value (null: not set);
  pro_raww_ledger_entry.raww_value and raww_value_currency, backfilled from
  the euro value for entries that have one.
- The server default 'EUR' is dropped from every currency column touched
  here (a missing currency is an error).

Downgrade refuses while any credit, cap, bound or RAWW entry is in a
currency other than EUR (it would relabel it as euros); otherwise it
restores 20261114_0096.

Revision ID: 20261114_0097
Revises: 20261114_0096
Create Date: 2026-11-14
"""
import sqlalchemy as sa
from alembic import op

revision = "20261114_0097"
down_revision = "20261114_0096"
branch_labels = None
depends_on = None

_NO_DEFAULT = ("niche_package_price_cap", "extra_image_pricing_policy", "pro_extra_image_price", "discount_redemption", "pro_public_index")


def upgrade() -> None:
    # Caps and bounds: one row per (niche, tier, currency).
    op.drop_constraint("uq_niche_package_price_cap_niche_tier", "niche_package_price_cap", type_="unique")
    op.create_unique_constraint(
        "uq_niche_package_price_cap_niche_tier_currency", "niche_package_price_cap", ["niche_id", "tier", "currency"]
    )
    op.drop_constraint("uq_extra_image_pricing_policy_niche_tier", "extra_image_pricing_policy", type_="unique")
    op.create_unique_constraint(
        "uq_extra_image_pricing_policy_niche_tier_currency", "extra_image_pricing_policy", ["niche_id", "tier", "currency"]
    )
    op.execute(
        """
        UPDATE pro_extra_image_price x SET currency = p.currency
        FROM pro_profile p WHERE p.user_id = x.pro_user_id AND x.currency <> p.currency
        """
    )
    op.execute(
        """
        UPDATE pro_public_index i SET currency = p.currency
        FROM pro_profile p WHERE p.user_id = i.pro_user_id AND i.currency <> p.currency
        """
    )
    for table in _NO_DEFAULT:
        op.alter_column(table, "currency", server_default=None)

    # Client credit per currency.
    op.add_column("reward_ledger_entry", sa.Column("currency", sa.CHAR(3), nullable=True))
    op.execute("UPDATE reward_ledger_entry SET currency = 'EUR'")
    op.alter_column("reward_ledger_entry", "currency", nullable=False)
    op.add_column("reward_balance", sa.Column("currency", sa.CHAR(3), nullable=True))
    op.execute("UPDATE reward_balance SET currency = 'EUR'")
    op.alter_column("reward_balance", "currency", nullable=False)
    op.drop_constraint("reward_balance_pkey", "reward_balance", type_="primary")
    op.create_primary_key("reward_balance_pkey", "reward_balance", ["user_id", "currency"])
    op.add_column(
        "client_credit_settings",
        sa.Column("monthly_marketing_credit_budget_gbp", sa.Numeric(12, 2), nullable=False, server_default="300.00"),
    )
    op.add_column("client_credit_settings", sa.Column("alerted_80_month_gbp", sa.Text(), nullable=True))
    op.add_column("client_credit_settings", sa.Column("alerted_100_month_gbp", sa.Text(), nullable=True))

    # Discovery: the cheapest package in euro cents.
    op.add_column("pro_public_index", sa.Column("min_package_price_base_minor", sa.BigInteger(), nullable=True))
    op.create_index("ix_pro_public_index_min_package_price_base_minor", "pro_public_index", ["min_package_price_base_minor"])
    op.execute(
        """
        UPDATE pro_public_index SET min_package_price_base_minor = round(min_package_price * 100)::bigint
        WHERE currency = 'EUR' AND min_package_price IS NOT NULL
        """
    )

    # RAWW per currency.
    op.add_column("shelf_settings", sa.Column("raww_gbp_value", sa.Numeric(10, 4), nullable=True))
    op.add_column("pro_raww_ledger_entry", sa.Column("raww_value", sa.Numeric(10, 4), nullable=True))
    op.add_column("pro_raww_ledger_entry", sa.Column("raww_value_currency", sa.CHAR(3), nullable=True))
    op.execute(
        """
        UPDATE pro_raww_ledger_entry SET raww_value = raww_eur_value, raww_value_currency = 'EUR'
        WHERE raww_eur_value IS NOT NULL
        """
    )


def downgrade() -> None:
    bind = op.get_bind()
    checks = {
        "reward_ledger_entry": "SELECT count(*) FROM reward_ledger_entry WHERE currency <> 'EUR'",
        "niche_package_price_cap": "SELECT count(*) FROM niche_package_price_cap WHERE currency <> 'EUR'",
        "extra_image_pricing_policy": "SELECT count(*) FROM extra_image_pricing_policy WHERE currency <> 'EUR'",
        "pro_raww_ledger_entry": "SELECT count(*) FROM pro_raww_ledger_entry WHERE raww_value_currency IS NOT NULL AND raww_value_currency <> 'EUR'",
        "reward_balance": "SELECT count(*) FROM reward_balance WHERE currency <> 'EUR' AND balance <> 0",
    }
    for table, sql in checks.items():
        count = bind.execute(sa.text(sql)).scalar_one()
        if count:
            raise RuntimeError(f"{table} has {count} rows in another currency than EUR: downgrading would relabel them. Refused.")

    op.drop_column("pro_raww_ledger_entry", "raww_value_currency")
    op.drop_column("pro_raww_ledger_entry", "raww_value")
    op.drop_column("shelf_settings", "raww_gbp_value")

    op.drop_index("ix_pro_public_index_min_package_price_base_minor", table_name="pro_public_index")
    op.drop_column("pro_public_index", "min_package_price_base_minor")

    op.drop_column("client_credit_settings", "alerted_100_month_gbp")
    op.drop_column("client_credit_settings", "alerted_80_month_gbp")
    op.drop_column("client_credit_settings", "monthly_marketing_credit_budget_gbp")
    # Empty balances in another currency (made when one was first read).
    op.execute("DELETE FROM reward_balance WHERE currency <> 'EUR' AND balance = 0")
    op.drop_constraint("reward_balance_pkey", "reward_balance", type_="primary")
    op.create_primary_key("reward_balance_pkey", "reward_balance", ["user_id"])
    op.drop_column("reward_balance", "currency")
    op.drop_column("reward_ledger_entry", "currency")

    for table in _NO_DEFAULT:
        op.alter_column(table, "currency", server_default=sa.text("'EUR'::bpchar"))
    op.drop_constraint("uq_extra_image_pricing_policy_niche_tier_currency", "extra_image_pricing_policy", type_="unique")
    op.create_unique_constraint("uq_extra_image_pricing_policy_niche_tier", "extra_image_pricing_policy", ["niche_id", "tier"])
    op.drop_constraint("uq_niche_package_price_cap_niche_tier_currency", "niche_package_price_cap", type_="unique")
    op.create_unique_constraint("uq_niche_package_price_cap_niche_tier", "niche_package_price_cap", ["niche_id", "tier"])
