"""The business dashboard: bi_daily, manual costs and company cash, the Stripe
mirror, and the read-only bi_* views (docs/BI.md).

Revision ID: 20261109_0092
Revises: 20261109_0091
Create Date: 2026-11-09

New tables and views only; nothing existing changes. The views are a frozen
copy of app/models/bi_views.py at this revision (tests/test_bi.py compares
them): a later change to the views needs its own migration.
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261109_0092"
down_revision = "20261109_0091"
branch_labels = None
depends_on = None

VIEW_NAMES = ['bi_policy', 'bi_bookings', 'bi_payments', 'bi_credit', 'bi_refunds', 'bi_lines', 'bi_raww', 'bi_shelf', 'bi_earnings', 'bi_payouts', 'bi_client_owed', 'bi_stripe', 'bi_costs', 'bi_cash']

VIEWS_SQL = [
    'CREATE OR REPLACE VIEW bi_policy AS SELECT coalesce(p.retained_percent, 15) AS retained_percent,\n       coalesce(p.pro_raww_percent, 5) AS pro_raww_percent,\n       coalesce(p.fee_percent_extras, 20) AS fee_percent_extras\nFROM (SELECT 1) AS one\nLEFT JOIN LATERAL (SELECT * FROM platform_fee_policy ORDER BY updated_at DESC LIMIT 1) AS p ON true',
    "CREATE OR REPLACE VIEW bi_bookings AS SELECT g.id AS gig_id, g.client_user_id, g.pro_user_id, pp.display_name AS pro_name, g.status::text AS status,\n       g.currency, g.created_at,\n       coalesce(n.slug, '-') AS niche,\n       coalesce(upper(nullif(trim(pp.country), '')), '-') AS country,\n       coalesce(s.tier::text, '-') AS tier,\n       round(coalesce(g.amount_final, g.amount_minimum) * 100)::bigint AS final_price_cents,\n       coalesce(g.retained_percent, pol.retained_percent) AS retained_percent,\n       coalesce(g.pro_raww_percent, pol.pro_raww_percent) AS pro_raww_percent,\n       coalesce(g.client_credit_percent, 0) AS client_credit_percent,\n       pol.fee_percent_extras\nFROM gig g\nCROSS JOIN bi_policy pol\nLEFT JOIN niche n ON n.id = g.niche_id\nLEFT JOIN pro_profile pp ON pp.user_id = g.pro_user_id\nLEFT JOIN pro_niche_skill s ON s.pro_user_id = g.pro_user_id AND s.niche_id = g.niche_id",
    "CREATE OR REPLACE VIEW bi_payments AS SELECT sp.id::text AS line_id, sp.gig_id, sp.kind::text AS kind, sp.currency,\n       round(sp.amount * 100)::bigint AS amount_cents,\n       round(sp.amount_refunded * 100)::bigint AS refunded_cents,\n       coalesce(cap.at, sp.created_at) AS at,\n       sp.stripe_payment_intent_id AS reference\nFROM stripe_payment sp\nLEFT JOIN LATERAL (\n    SELECT min(le.created_at) AS at FROM ledger_entry le\n    WHERE le.gig_id = sp.gig_id AND le.entry_type = 'payment_captured' AND le.reference_id = sp.stripe_payment_intent_id\n) AS cap ON true\nWHERE sp.status IN ('succeeded', 'refunded', 'disputed')",
    "CREATE OR REPLACE VIEW bi_credit AS SELECT 'redemption:' || dr.id AS line_id, dr.context_id AS gig_id, 'used' AS movement, dr.currency,\n       round(dr.discount_amount * 100)::bigint AS amount_cents, dr.updated_at AS at, dr.id::text AS reference\nFROM discount_redemption dr\nWHERE dr.status = 'applied' AND dr.context_type = 'gig_payment'\nUNION ALL\nSELECT 'returned:' || r.id, dr.context_id, 'returned', dr.currency,\n       -round(r.amount * dr.discount_amount * 100 / dr.points_spent)::bigint, r.created_at, r.reference_id\nFROM reward_ledger_entry r\nJOIN discount_redemption dr ON dr.id::text = r.metadata ->> 'refunded_redemption_id'\nWHERE r.reference_type = 'booking_refund' AND dr.points_spent > 0",
    "CREATE OR REPLACE VIEW bi_refunds AS SELECT le.id::text AS line_id, le.gig_id,\n       CASE WHEN le.entry_type IN ('refund_succeeded', 'refund_failed') THEN 'card' ELSE 'chargeback' END AS source,\n       le.entry_type::text AS entry_type, le.currency,\n       round(le.amount * 100)::bigint AS amount_cents, le.created_at AS at, le.reference_id AS reference\nFROM ledger_entry le\nWHERE le.entry_type IN ('refund_succeeded', 'refund_failed', 'chargeback_opened', 'chargeback_won')",
    "CREATE OR REPLACE VIEW bi_lines AS WITH raw AS (\n    SELECT line_id, gig_id, 'payment' AS movement, kind, 'card' AS source, currency, amount_cents, at, reference FROM bi_payments\n    UNION ALL\n    SELECT line_id, gig_id, 'payment', 'base', 'credit', currency, amount_cents, at, reference FROM bi_credit WHERE movement = 'used'\n    UNION ALL\n    SELECT line_id, gig_id, 'refund', 'base', source, currency, amount_cents, at, reference FROM bi_refunds\n    UNION ALL\n    SELECT line_id, gig_id, 'refund', 'base', 'credit', currency, amount_cents, at, reference FROM bi_credit WHERE movement = 'returned'\n), rated AS (\n    SELECT raw.*, b.pro_user_id, b.client_user_id, b.niche, b.country, b.tier,\n           (raw.at AT TIME ZONE 'Europe/London')::date AS day,\n           CASE WHEN raw.kind = 'extras' THEN b.fee_percent_extras - least(b.fee_percent_extras, b.pro_raww_percent)\n                ELSE b.retained_percent END AS r_pct,\n           CASE WHEN raw.kind = 'extras' THEN least(b.fee_percent_extras, b.pro_raww_percent)\n                ELSE b.pro_raww_percent END AS w_pct,\n           CASE WHEN raw.kind = 'extras' THEN 0 ELSE b.client_credit_percent END AS c_pct\n    FROM raw JOIN bi_bookings b ON b.gig_id = raw.gig_id\n), shares AS (\n    SELECT rated.*,\n           round(amount_cents * r_pct / 100.0)::bigint AS retained_cents,\n           round(amount_cents * w_pct / 100.0)::bigint AS pro_raww_cents,\n           round(amount_cents * c_pct / 100.0)::bigint AS client_raww_cents\n    FROM rated\n)\nSELECT line_id, gig_id, pro_user_id, client_user_id, niche, country, tier, movement, kind, source, currency, at, day,\n       reference, amount_cents, retained_cents, pro_raww_cents, client_raww_cents,\n       amount_cents - retained_cents - pro_raww_cents - client_raww_cents AS pro_cash_cents,\n       r_pct AS retained_percent, w_pct AS pro_raww_percent, c_pct AS client_credit_percent\nFROM shares",
    "CREATE OR REPLACE VIEW bi_raww AS WITH rated AS (\n    SELECT e.id::text AS line_id, e.pro_user_id, e.kind::text AS kind, e.amount AS amount_raww, e.gig_id, e.created_at AS at,\n           (e.created_at AT TIME ZONE 'Europe/London')::date AS day,\n           CASE WHEN e.raww_eur_value IS NOT NULL THEN e.raww_eur_value\n                WHEN o.id IS NOT NULL THEN o.raww_eur_value ELSE ss.raww_eur_value END AS rate,\n           CASE WHEN e.raww_eur_value IS NOT NULL THEN 'stamped'\n                WHEN o.id IS NOT NULL THEN 'order' ELSE 'current' END AS rate_source\n    FROM pro_raww_ledger_entry e\n    LEFT JOIN shelf_order o ON e.source_type = 'shelf_order' AND o.id::text = e.source_id\n    LEFT JOIN shelf_settings ss ON ss.id = 1\n)\nSELECT rated.*, round(amount_raww * rate * 100)::bigint AS value_cents FROM rated",
    "CREATE OR REPLACE VIEW bi_shelf AS WITH o AS (\n    SELECT o.id AS order_id, o.pro_user_id, o.item_id, o.status::text AS status, o.placed_at,\n           coalesce(o.refunded_at, o.cancelled_at) AS reversed_at,\n           round(o.price_raww * o.raww_eur_value * 100)::bigint AS value_cents,\n           CASE WHEN i.supplier_cost IS NULL OR i.supplier_cost <= 0 THEN NULL\n                WHEN upper(i.supplier_currency) = 'EUR' THEN round(i.supplier_cost * 100)::bigint\n                WHEN upper(i.supplier_currency) = 'GBP' AND ss.gbp_eur_rate IS NOT NULL\n                     THEN round(i.supplier_cost * ss.gbp_eur_rate * 100)::bigint\n                ELSE NULL END AS cost_cents\n    FROM shelf_order o\n    JOIN shelf_item i ON i.id = o.item_id\n    LEFT JOIN shelf_settings ss ON ss.id = 1\n)\nSELECT order_id::text || ':placed' AS line_id, order_id, pro_user_id, 'placed' AS movement, placed_at AS at,\n       (placed_at AT TIME ZONE 'Europe/London')::date AS day, value_cents, cost_cents, 1 AS orders\nFROM o\nUNION ALL\nSELECT order_id::text || ':reversed', order_id, pro_user_id, 'reversed', reversed_at,\n       (reversed_at AT TIME ZONE 'Europe/London')::date, -value_cents, -cost_cents, -1\nFROM o WHERE status IN ('cancelled', 'refunded') AND reversed_at IS NOT NULL",
    'CREATE OR REPLACE VIEW bi_earnings AS SELECT e.id AS entry_id, e.pro_user_id, e.source_type::text AS source_type, e.source_id, e.status::text AS status,\n       round(e.gross_eur * 100)::bigint AS gross_cents, round(e.net_eur * 100)::bigint AS net_cents,\n       e.available_at, e.created_at\nFROM earnings_ledger_entry e',
    "CREATE OR REPLACE VIEW bi_payouts AS SELECT r.id AS payout_id, r.pro_user_id, r.status::text AS status, round(r.amount_eur * 100)::bigint AS amount_cents,\n       coalesce((SELECT round(sum(a.amount_eur) * 100)::bigint FROM payout_allocation a WHERE a.payout_request_id = r.id), 0)\n           AS allocated_cents,\n       r.requested_at, r.paid_at, (r.paid_at AT TIME ZONE 'Europe/London')::date AS paid_day\nFROM payout_request r",
    "CREATE OR REPLACE VIEW bi_client_owed AS SELECT 'attention:' || m.id AS line_id, m.gig_id, 'client_owed' AS kind, m.currency,\n       round(m.amount * 100)::bigint AS amount_cents\nFROM money_attention_item m WHERE m.kind = 'client_owed' AND m.status = 'open'\nUNION ALL\nSELECT 'refund_case:' || c.id, c.gig_id, 'refund_in_flight', c.currency,\n       round(greatest(c.amount - coalesce(c.amount_refunded, 0), 0) * 100)::bigint\nFROM refund_case c WHERE c.status IN ('approved', 'processing', 'refund_initiated')",
    "CREATE OR REPLACE VIEW bi_stripe AS SELECT t.id, t.type, t.reporting_category, t.currency, t.amount_cents, t.fee_cents, t.net_cents, t.created_at AS at,\n       (t.created_at AT TIME ZONE 'Europe/London')::date AS day, t.available_on, t.source_id, t.demo\nFROM bi_stripe_txn t",
    'CREATE OR REPLACE VIEW bi_costs AS SELECT c.id AS cost_id, c.category, c.currency, c.amount_cents, c.recurring, c.note,\n       (c.date + make_interval(months => k))::date AS day\nFROM bi_cost c\nCROSS JOIN LATERAL generate_series(\n    0,\n    CASE WHEN c.recurring THEN\n        (extract(year FROM age(coalesce(c.end_date, current_date + 400), c.date)) * 12\n         + extract(month FROM age(coalesce(c.end_date, current_date + 400), c.date)))::int\n    ELSE 0 END\n) AS k\nWHERE c.deleted_at IS NULL',
    'CREATE OR REPLACE VIEW bi_cash AS SELECT DISTINCT ON (account) id, account, date, currency, amount_cents, note\nFROM bi_company_cash WHERE deleted_at IS NULL\nORDER BY account, date DESC, created_at DESC',
]


def _audit_columns():
    return [
        sa.Column("created_by", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_by", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("deleted_by", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
    ]


BOOKING_COLUMNS = (
    "gmv_cents", "gmv_card_cents", "gmv_credit_cents", "refund_cents", "refund_card_cents", "refund_chargeback_cents",
    "refund_credit_cents", "retained_cents", "pro_cash_cents", "pro_raww_cents", "client_raww_cents",
)
COMPANY_COLUMNS = (
    "stripe_fee_cents", "stripe_charge_cents", "stripe_refund_cents", "stripe_dispute_cents", "stripe_transfer_cents",
    "stripe_payout_cents", "payouts_paid_cents", "raww_issued_cents", "raww_reversed_cents", "raww_spent_cents",
    "raww_expired_cents", "raww_adjust_cents", "shelf_value_cents", "shelf_cost_cents", "shelf_cost_not_set_value_cents",
)


def upgrade() -> None:
    money = [sa.Column(name, sa.BigInteger(), nullable=False, server_default="0") for name in BOOKING_COLUMNS + COMPANY_COLUMNS]
    op.create_table(
        "bi_daily",
        sa.Column("day", sa.Date(), primary_key=True),
        sa.Column("scope", sa.Text(), primary_key=True),
        sa.Column("niche", sa.Text(), primary_key=True),
        sa.Column("country", sa.Text(), primary_key=True),
        sa.Column("tier", sa.Text(), primary_key=True),
        *money,
        sa.Column("bookings", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("other_currency_lines", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("stripe_synced", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("shelf_orders", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("shelf_cost_not_set_orders", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("computed_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.CheckConstraint("scope IN ('booking','company')", name="ck_bi_daily_scope"),
    )
    op.create_table(
        "bi_cost",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("date", sa.Date(), nullable=False),
        sa.Column("end_date", sa.Date(), nullable=True),
        sa.Column("category", sa.Text(), nullable=False),
        sa.Column("amount_cents", sa.BigInteger(), nullable=False),
        sa.Column("currency", sa.Text(), nullable=False, server_default="EUR"),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("recurring", sa.Boolean(), nullable=False, server_default=sa.false()),
        *_audit_columns(),
        sa.CheckConstraint("amount_cents > 0", name="ck_bi_cost_amount"),
    )
    op.create_index("ix_bi_cost_date", "bi_cost", ["date"])
    op.create_table(
        "bi_company_cash",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("date", sa.Date(), nullable=False),
        sa.Column("account", sa.Text(), nullable=False),
        sa.Column("amount_cents", sa.BigInteger(), nullable=False),
        sa.Column("currency", sa.Text(), nullable=False, server_default="EUR"),
        sa.Column("note", sa.Text(), nullable=True),
        *_audit_columns(),
    )
    op.create_index("ix_bi_company_cash_date", "bi_company_cash", ["date"])
    op.create_table(
        "bi_stripe_txn",
        sa.Column("id", sa.Text(), primary_key=True),
        sa.Column("type", sa.Text(), nullable=False),
        sa.Column("reporting_category", sa.Text(), nullable=True),
        sa.Column("currency", sa.Text(), nullable=False),
        sa.Column("amount_cents", sa.BigInteger(), nullable=False),
        sa.Column("fee_cents", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("net_cents", sa.BigInteger(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("available_on", sa.DateTime(timezone=True), nullable=True),
        sa.Column("source_id", sa.Text(), nullable=True),
        sa.Column("status", sa.Text(), nullable=True),
        sa.Column("demo", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("synced_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_bi_stripe_txn_created_at", "bi_stripe_txn", ["created_at"])
    op.create_table(
        "bi_stripe_sync_day",
        sa.Column("day", sa.Date(), primary_key=True),
        sa.Column("synced_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("txn_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("source", sa.Text(), nullable=False, server_default="stripe"),
    )
    bind = op.get_bind()
    for statement in VIEWS_SQL:
        # exec_driver_sql: the SQL holds ':placed'-style literals that text() would read as parameters.
        bind.exec_driver_sql(statement)


def downgrade() -> None:
    bind = op.get_bind()
    for name in reversed(VIEW_NAMES):
        bind.exec_driver_sql(f"DROP VIEW IF EXISTS {name}")
    op.drop_table("bi_stripe_sync_day")
    op.drop_index("ix_bi_stripe_txn_created_at", table_name="bi_stripe_txn")
    op.drop_table("bi_stripe_txn")
    op.drop_index("ix_bi_company_cash_date", table_name="bi_company_cash")
    op.drop_table("bi_company_cash")
    op.drop_index("ix_bi_cost_date", table_name="bi_cost")
    op.drop_table("bi_cost")
    op.drop_table("bi_daily")
