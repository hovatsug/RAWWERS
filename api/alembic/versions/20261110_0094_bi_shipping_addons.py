"""Business dashboard: old add-on refunds counted, Shelf shipping per order
only (docs/BI.md, the owner's decisions of 2026-11-10, second set):

- bi_refunds: a selection add-on refunded before its refunds were recorded
  one by one counts its refunded total on the payment's last update,
  marked date_estimated (carried through bi_lines).
- bi_costs: the retired category shelf_shipping (legacy) still counts; a
  recurring one repeats no later than 2026-11-10. bi_costs now comes before
  bi_shelf, which reads it.
- bi_shelf: an order shipped on or before the last legacy shelf_shipping
  cost has its shipping in those costs: its own is not counted again and it
  is not "shipping not set".
- bi_daily: refund_date_estimated_cents; its rows are emptied (a cache:
  days are computed live until the backfill refills them).
- the bi_* views recreated: a frozen copy of app/models/bi_views.py at this
  revision (tests/test_bi_schema.py compares them).

No data changes besides the cache. Downgrade drops the column and restores
the views of 20261110_0093.

Revision ID: 20261110_0094
Revises: 20261110_0093
Create Date: 2026-11-10
"""
import importlib.util
import pathlib

import sqlalchemy as sa
from alembic import op

revision = "20261110_0094"
down_revision = "20261110_0093"
branch_labels = None
depends_on = None

VIEW_NAMES = ['bi_policy', 'bi_bookings', 'bi_payments', 'bi_credit', 'bi_refunds', 'bi_lines', 'bi_raww', 'bi_costs', 'bi_shelf', 'bi_earnings', 'bi_payouts', 'bi_client_owed', 'bi_stripe', 'bi_cash']

VIEWS_SQL = ['CREATE OR REPLACE VIEW bi_policy AS SELECT coalesce(p.retained_percent, 15) AS retained_percent,\n'
 '       coalesce(p.pro_raww_percent, 5) AS pro_raww_percent,\n'
 '       coalesce(p.fee_percent_extras, 20) AS fee_percent_extras\n'
 'FROM (SELECT 1) AS one\n'
 'LEFT JOIN LATERAL (SELECT * FROM platform_fee_policy ORDER BY updated_at DESC LIMIT 1) AS p ON true',
 'CREATE OR REPLACE VIEW bi_bookings AS SELECT g.id AS gig_id, g.client_user_id, g.pro_user_id, pp.display_name AS pro_name, g.status::text AS status,\n'
 '       g.currency, g.created_at,\n'
 "       coalesce(n.slug, '-') AS niche,\n"
 "       coalesce(upper(nullif(trim(pp.country), '')), '-') AS country,\n"
 "       coalesce(g.pro_tier, s.tier::text, '-') AS tier,\n"
 '       (g.pro_tier IS NULL OR g.pro_tier_estimated) AS tier_estimated,\n'
 '       round(coalesce(g.amount_final, g.amount_minimum) * 100)::bigint AS final_price_cents,\n'
 '       coalesce(g.retained_percent, pol.retained_percent) AS retained_percent,\n'
 '       coalesce(g.pro_raww_percent, pol.pro_raww_percent) AS pro_raww_percent,\n'
 '       coalesce(g.client_credit_percent, 0) AS client_credit_percent,\n'
 '       pol.fee_percent_extras\n'
 'FROM gig g\n'
 'CROSS JOIN bi_policy pol\n'
 'LEFT JOIN niche n ON n.id = g.niche_id\n'
 'LEFT JOIN pro_profile pp ON pp.user_id = g.pro_user_id\n'
 'LEFT JOIN pro_niche_skill s ON s.pro_user_id = g.pro_user_id AND s.niche_id = g.niche_id',
 'CREATE OR REPLACE VIEW bi_payments AS SELECT sp.id::text AS line_id, sp.gig_id, sp.kind::text AS kind, sp.currency,\n'
 '       round(sp.amount * 100)::bigint AS amount_cents,\n'
 '       round(sp.amount_refunded * 100)::bigint AS refunded_cents,\n'
 '       coalesce(cap.at, sp.created_at) AS at,\n'
 '       sp.stripe_payment_intent_id AS reference\n'
 'FROM stripe_payment sp\n'
 'LEFT JOIN LATERAL (\n'
 '    SELECT min(le.created_at) AS at FROM ledger_entry le\n'
 "    WHERE le.gig_id = sp.gig_id AND le.entry_type = 'payment_captured' AND le.reference_id = sp.stripe_payment_intent_id\n"
 ') AS cap ON true\n'
 "WHERE sp.status IN ('succeeded', 'refunded', 'disputed')",
 "CREATE OR REPLACE VIEW bi_credit AS SELECT 'redemption:' || dr.id AS line_id, dr.context_id AS gig_id, 'used' AS movement, dr.currency,\n"
 '       round(dr.discount_amount * 100)::bigint AS amount_cents, dr.updated_at AS at, dr.id::text AS reference\n'
 'FROM discount_redemption dr\n'
 "WHERE dr.status = 'applied' AND dr.context_type = 'gig_payment'\n"
 'UNION ALL\n'
 "SELECT 'returned:' || r.id, dr.context_id, 'returned', dr.currency,\n"
 '       -round(r.amount * dr.discount_amount * 100 / dr.points_spent)::bigint, r.created_at, r.reference_id\n'
 'FROM reward_ledger_entry r\n'
 "JOIN discount_redemption dr ON dr.id::text = r.metadata ->> 'refunded_redemption_id'\n"
 "WHERE r.reference_type = 'booking_refund' AND dr.points_spent > 0",
 'CREATE OR REPLACE VIEW bi_refunds AS SELECT le.id::text AS line_id, le.gig_id,\n'
 "       CASE WHEN le.entry_type IN ('refund_succeeded', 'refund_failed') THEN 'card' ELSE 'chargeback' END AS source,\n"
 '       le.entry_type::text AS entry_type, le.currency,\n'
 '       round(le.amount * 100)::bigint AS amount_cents, le.created_at AS at, le.reference_id AS reference,\n'
 '       sp.kind::text AS payment_kind, (sp.id IS NULL) AS rate_assumed, false AS date_estimated\n'
 'FROM ledger_entry le\n'
 'LEFT JOIN stripe_payment sp ON sp.id = le.stripe_payment_id\n'
 "WHERE le.entry_type IN ('refund_succeeded', 'refund_failed', 'chargeback_opened', 'chargeback_won')\n"
 'UNION ALL\n'
 "SELECT 'payment_refund:' || r.key, sp.gig_id, 'card', 'refund_succeeded', sp.currency,\n"
 "       -round((r.value ->> 'amount')::numeric * 100)::bigint, (r.value ->> 'created')::timestamptz, r.key,\n"
 '       sp.kind::text, false, false\n'
 'FROM stripe_payment sp\n'
 "CROSS JOIN LATERAL jsonb_each(coalesce(sp.metadata -> 'refunds', '{}'::jsonb)) AS r\n"
 "WHERE r.value ->> 'status' = 'succeeded'\n"
 "  AND NOT EXISTS (SELECT 1 FROM ledger_entry le WHERE le.entry_type = 'refund_succeeded' AND le.reference_id = r.key)\n"
 'UNION ALL\n'
 '-- A selection add-on refunded before its refunds were recorded one by one\n'
 '-- (2026-11-10): only the running total is known, so it counts in full on\n'
 "-- the payment's last update, date estimated.\n"
 "SELECT 'payment_refunded:' || sp.id::text, sp.gig_id, 'card', 'refund_succeeded', sp.currency,\n"
 '       -round(sp.amount_refunded * 100)::bigint, sp.updated_at, sp.stripe_payment_intent_id,\n'
 '       sp.kind::text, false, true\n'
 'FROM stripe_payment sp\n'
 'JOIN extra_image_purchase p ON p.stripe_payment_intent_id = sp.stripe_payment_intent_id\n'
 'WHERE sp.amount_refunded > 0\n'
 "  AND p.metadata ->> 'kind' = 'selection_addon'\n"
 "  AND NOT (sp.metadata ? 'refunds')\n"
 "  AND NOT EXISTS (SELECT 1 FROM ledger_entry le WHERE le.entry_type = 'refund_succeeded' AND le.stripe_payment_id = sp.id)",
 'CREATE OR REPLACE VIEW bi_lines AS WITH raw AS (\n'
 "    SELECT line_id, gig_id, 'payment' AS movement, kind, 'card' AS source, currency, amount_cents, at, reference,\n"
 '           false AS rate_assumed, false AS date_estimated FROM bi_payments\n'
 '    UNION ALL\n'
 "    SELECT line_id, gig_id, 'payment', 'base', 'credit', currency, amount_cents, at, reference, false, false\n"
 "    FROM bi_credit WHERE movement = 'used'\n"
 '    UNION ALL\n'
 "    SELECT line_id, gig_id, 'refund', coalesce(payment_kind, 'base'), source, currency, amount_cents, at, reference, rate_assumed,\n"
 '           date_estimated\n'
 '    FROM bi_refunds\n'
 '    UNION ALL\n'
 "    SELECT line_id, gig_id, 'refund', 'base', 'credit', currency, amount_cents, at, reference, false, false\n"
 "    FROM bi_credit WHERE movement = 'returned'\n"
 '), rated AS (\n'
 '    SELECT raw.*, b.pro_user_id, b.client_user_id, b.niche, b.country, b.tier, b.tier_estimated,\n'
 "           (raw.at AT TIME ZONE 'Europe/London')::date AS day,\n"
 "           CASE WHEN raw.kind = 'extras' THEN b.fee_percent_extras - least(b.fee_percent_extras, b.pro_raww_percent)\n"
 '                ELSE b.retained_percent END AS r_pct,\n'
 "           CASE WHEN raw.kind = 'extras' THEN least(b.fee_percent_extras, b.pro_raww_percent)\n"
 '                ELSE b.pro_raww_percent END AS w_pct,\n'
 "           CASE WHEN raw.kind = 'extras' THEN 0 ELSE b.client_credit_percent END AS c_pct\n"
 '    FROM raw JOIN bi_bookings b ON b.gig_id = raw.gig_id\n'
 '), shares AS (\n'
 '    SELECT rated.*,\n'
 '           round(amount_cents * r_pct / 100.0)::bigint AS retained_cents,\n'
 '           round(amount_cents * w_pct / 100.0)::bigint AS pro_raww_cents,\n'
 '           round(amount_cents * c_pct / 100.0)::bigint AS client_raww_cents\n'
 '    FROM rated\n'
 ')\n'
 'SELECT line_id, gig_id, pro_user_id, client_user_id, niche, country, tier, tier_estimated, movement, kind, source, currency,\n'
 '       at, day, reference, rate_assumed, date_estimated, amount_cents, retained_cents, pro_raww_cents, client_raww_cents,\n'
 '       amount_cents - retained_cents - pro_raww_cents - client_raww_cents AS pro_cash_cents,\n'
 '       r_pct AS retained_percent, w_pct AS pro_raww_percent, c_pct AS client_credit_percent\n'
 'FROM shares',
 'CREATE OR REPLACE VIEW bi_raww AS WITH rated AS (\n'
 '    SELECT e.id::text AS line_id, e.pro_user_id, e.kind::text AS kind, e.amount AS amount_raww, e.gig_id, e.created_at AS at,\n'
 "           (e.created_at AT TIME ZONE 'Europe/London')::date AS day,\n"
 '           CASE WHEN e.raww_eur_value IS NOT NULL THEN e.raww_eur_value\n'
 '                WHEN o.id IS NOT NULL THEN o.raww_eur_value ELSE ss.raww_eur_value END AS rate,\n'
 "           CASE WHEN e.raww_eur_value IS NOT NULL THEN 'stamped'\n"
 "                WHEN o.id IS NOT NULL THEN 'order' ELSE 'current' END AS rate_source\n"
 '    FROM pro_raww_ledger_entry e\n'
 "    LEFT JOIN shelf_order o ON e.source_type = 'shelf_order' AND o.id::text = e.source_id\n"
 '    LEFT JOIN shelf_settings ss ON ss.id = 1\n'
 ')\n'
 'SELECT rated.*, round(amount_raww * rate * 100)::bigint AS value_cents FROM rated',
 'CREATE OR REPLACE VIEW bi_costs AS WITH c AS (\n'
 "    SELECT c.*, CASE WHEN c.category = 'shelf_shipping'\n"
 "                     THEN least(coalesce(c.end_date, DATE '2026-11-10'), DATE '2026-11-10')\n"
 '                     ELSE coalesce(c.end_date, current_date + 400) END AS last_day\n'
 '    FROM bi_cost c WHERE c.deleted_at IS NULL\n'
 ')\n'
 'SELECT c.id AS cost_id, c.category, c.currency, c.amount_cents, c.recurring, c.note,\n'
 "       (c.date + make_interval(months => k))::date AS day, (c.category = 'shelf_shipping') AS legacy\n"
 'FROM c\n'
 'CROSS JOIN LATERAL generate_series(\n'
 '    0,\n'
 '    CASE WHEN c.recurring THEN\n'
 '        greatest((extract(year FROM age(c.last_day, c.date)) * 12 + extract(month FROM age(c.last_day, c.date)))::int, 0)\n'
 '    ELSE 0 END\n'
 ') AS k',
 'CREATE OR REPLACE VIEW bi_shelf AS WITH o AS (\n'
 '    SELECT o.id AS order_id, o.pro_user_id, o.item_id, o.status::text AS status, o.placed_at,\n'
 '           coalesce(o.refunded_at, o.cancelled_at) AS reversed_at,\n'
 '           round(o.price_raww * o.raww_eur_value * 100)::bigint AS value_cents,\n'
 '           CASE WHEN o.supplier_cost IS NOT NULL OR o.supplier_currency IS NOT NULL THEN\n'
 '                    CASE WHEN o.supplier_cost > 0 AND o.cost_eur_rate IS NOT NULL\n'
 '                         THEN round(o.supplier_cost * o.cost_eur_rate * 100)::bigint END\n'
 '                WHEN i.supplier_cost IS NULL OR i.supplier_cost <= 0 THEN NULL\n'
 "                WHEN upper(i.supplier_currency) = 'EUR' THEN round(i.supplier_cost * 100)::bigint\n"
 "                WHEN upper(i.supplier_currency) = 'GBP' AND ss.gbp_eur_rate IS NOT NULL\n"
 '                     THEN round(i.supplier_cost * ss.gbp_eur_rate * 100)::bigint\n'
 '                ELSE NULL END AS cost_cents,\n'
 '           (o.cost_estimated OR (o.supplier_cost IS NULL AND o.supplier_currency IS NULL)) AS cost_estimated,\n'
 '           CASE WHEN lg.covered THEN 0 ELSE coalesce(round(o.shipping_cost_eur * 100)::bigint, 0) END AS shipping_cents,\n'
 "           (o.shipping_cost_eur IS NULL AND o.status::text IN ('shipped', 'delivered') AND NOT lg.covered) AS shipping_not_set\n"
 '    FROM shelf_order o\n'
 '    JOIN shelf_item i ON i.id = o.item_id\n'
 '    LEFT JOIN shelf_settings ss ON ss.id = 1\n'
 '    -- Shipped on or before the last legacy shelf_shipping cost: its shipping\n'
 '    -- is in those costs, so its own is not counted again.\n'
 '    CROSS JOIN LATERAL (\n'
 "        SELECT coalesce(o.shipped_at IS NOT NULL AND (o.shipped_at AT TIME ZONE 'Europe/London')::date\n"
 "                        <= (SELECT max(c.day) FROM bi_costs c WHERE c.category = 'shelf_shipping'), false) AS covered\n"
 '    ) lg\n'
 ')\n'
 "SELECT order_id::text || ':placed' AS line_id, order_id, pro_user_id, 'placed' AS movement, placed_at AS at,\n"
 "       (placed_at AT TIME ZONE 'Europe/London')::date AS day, value_cents, cost_cents, 1 AS orders,\n"
 '       shipping_cents, cost_estimated::int AS cost_estimated_orders, shipping_not_set::int AS shipping_not_set_orders\n'
 'FROM o\n'
 'UNION ALL\n'
 "SELECT order_id::text || ':reversed', order_id, pro_user_id, 'reversed', reversed_at,\n"
 "       (reversed_at AT TIME ZONE 'Europe/London')::date, -value_cents, -cost_cents, -1,\n"
 '       -shipping_cents, -(cost_estimated::int), 0\n'
 "FROM o WHERE status IN ('cancelled', 'refunded') AND reversed_at IS NOT NULL",
 'CREATE OR REPLACE VIEW bi_earnings AS SELECT e.id AS entry_id, e.pro_user_id, e.source_type::text AS source_type, e.source_id, e.status::text AS status,\n'
 '       round(e.gross_eur * 100)::bigint AS gross_cents, round(e.net_eur * 100)::bigint AS net_cents,\n'
 '       e.available_at, e.created_at\n'
 'FROM earnings_ledger_entry e',
 'CREATE OR REPLACE VIEW bi_payouts AS SELECT r.id AS payout_id, r.pro_user_id, r.status::text AS status, round(r.amount_eur * 100)::bigint AS amount_cents,\n'
 '       coalesce((SELECT round(sum(a.amount_eur) * 100)::bigint FROM payout_allocation a WHERE a.payout_request_id = r.id), 0)\n'
 '           AS allocated_cents,\n'
 "       r.requested_at, r.paid_at, (r.paid_at AT TIME ZONE 'Europe/London')::date AS paid_day\n"
 'FROM payout_request r',
 "CREATE OR REPLACE VIEW bi_client_owed AS SELECT 'attention:' || m.id AS line_id, m.gig_id, 'client_owed' AS kind, m.currency,\n"
 '       round(m.amount * 100)::bigint AS amount_cents\n'
 "FROM money_attention_item m WHERE m.kind = 'client_owed' AND m.status = 'open'\n"
 'UNION ALL\n'
 "SELECT 'refund_case:' || c.id, c.gig_id, 'refund_in_flight', c.currency,\n"
 '       round(greatest(c.amount - coalesce(c.amount_refunded, 0), 0) * 100)::bigint\n'
 "FROM refund_case c WHERE c.status IN ('approved', 'processing', 'refund_initiated')",
 'CREATE OR REPLACE VIEW bi_stripe AS SELECT t.id, t.type, t.reporting_category, t.currency, t.amount_cents, t.fee_cents, t.net_cents, t.created_at AS at,\n'
 "       (t.created_at AT TIME ZONE 'Europe/London')::date AS day, t.available_on, t.source_id, t.demo\n"
 'FROM bi_stripe_txn t',
 'CREATE OR REPLACE VIEW bi_cash AS SELECT DISTINCT ON (account) id, account, date, currency, amount_cents, note\n'
 'FROM bi_company_cash WHERE deleted_at IS NULL\n'
 'ORDER BY account, date DESC, created_at DESC']


def _previous():
    path = pathlib.Path(__file__).resolve().parent / "20261110_0093_bi_stamps.py"
    spec = importlib.util.spec_from_file_location("bi_0093", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _drop_views(names) -> None:
    bind = op.get_bind()
    for name in reversed(names):
        bind.exec_driver_sql(f"DROP VIEW IF EXISTS {name}")


def upgrade() -> None:
    _drop_views(_previous().VIEW_NAMES)
    op.add_column("bi_daily", sa.Column("refund_date_estimated_cents", sa.BigInteger(), nullable=False, server_default="0"))
    bind = op.get_bind()
    # A cache: recomputed live until the backfill refills it.
    bind.exec_driver_sql("DELETE FROM bi_daily")
    for statement in VIEWS_SQL:
        bind.exec_driver_sql(statement)


def downgrade() -> None:
    _drop_views(VIEW_NAMES)
    bind = op.get_bind()
    bind.exec_driver_sql("DELETE FROM bi_daily")
    op.drop_column("bi_daily", "refund_date_estimated_cents")
    for statement in _previous().VIEWS_SQL:
        bind.exec_driver_sql(statement)
