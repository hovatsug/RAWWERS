"""The read-only bi_* views: the only way dashboard code reads money tables.

Each view is defined once here; docs/BI.md says what each number means.
Amounts become integer cents here, once. Days are Europe/London.

Created after the tables (`after_create` on the metadata, for the test
suite's create_all) and by the latest BI migration (20261113_0095), which
carries a frozen copy of this SQL; tests/test_bi_schema.py fails when the
two differ, so a change here needs a migration that recreates the views.
Dropped before the tables.
"""
from __future__ import annotations

from sqlalchemy import DDL, event

LONDON = "'Europe/London'"

VIEWS: list[tuple[str, str]] = [
    # The platform fee policy in force (the latest row), with the code's
    # defaults when there is none.
    ("bi_policy", """
SELECT coalesce(p.retained_percent, 15) AS retained_percent,
       coalesce(p.pro_raww_percent, 5) AS pro_raww_percent,
       coalesce(p.fee_percent_extras, 20) AS fee_percent_extras
FROM (SELECT 1) AS one
LEFT JOIN LATERAL (SELECT * FROM platform_fee_policy ORDER BY updated_at DESC LIMIT 1) AS p ON true
"""),
    # One row per booking: its dimensions and the rates its money splits at.
    # The tier is the one recorded when it was made; estimated when that
    # was backfilled, or is missing and today's is used.
    ("bi_bookings", """
SELECT g.id AS gig_id, g.client_user_id, g.pro_user_id, pp.display_name AS pro_name, g.status::text AS status,
       g.currency, g.created_at,
       coalesce(n.slug, '-') AS niche,
       coalesce(upper(nullif(trim(pp.country), '')), '-') AS country,
       coalesce(g.pro_tier, s.tier::text, '-') AS tier,
       (g.pro_tier IS NULL OR g.pro_tier_estimated) AS tier_estimated,
       round(coalesce(g.amount_final, g.amount_minimum) * 100)::bigint AS final_price_cents,
       coalesce(g.retained_percent, pol.retained_percent) AS retained_percent,
       coalesce(g.pro_raww_percent, pol.pro_raww_percent) AS pro_raww_percent,
       coalesce(g.client_credit_percent, 0) AS client_credit_percent,
       pol.fee_percent_extras
FROM gig g
CROSS JOIN bi_policy pol
LEFT JOIN niche n ON n.id = g.niche_id
LEFT JOIN pro_profile pp ON pp.user_id = g.pro_user_id
LEFT JOIN pro_niche_skill s ON s.pro_user_id = g.pro_user_id AND s.niche_id = g.niche_id
"""),
    # Card money that reached us (refunded or disputed since, too).
    ("bi_payments", """
SELECT sp.id::text AS line_id, sp.gig_id, sp.kind::text AS kind, sp.currency,
       round(sp.amount * 100)::bigint AS amount_cents,
       round(sp.amount_refunded * 100)::bigint AS refunded_cents,
       coalesce(cap.at, sp.created_at) AS at,
       sp.stripe_payment_intent_id AS reference
FROM stripe_payment sp
LEFT JOIN LATERAL (
    SELECT min(le.created_at) AS at FROM ledger_entry le
    WHERE le.gig_id = sp.gig_id AND le.entry_type = 'payment_captured' AND le.reference_id = sp.stripe_payment_intent_id
) AS cap ON true
WHERE sp.status IN ('succeeded', 'refunded', 'disputed')
"""),
    # Client credit: used at checkout (+), given back on a refund (-), each
    # valued at its own redemption's rate.
    ("bi_credit", """
SELECT 'redemption:' || dr.id AS line_id, dr.context_id AS gig_id, 'used' AS movement, dr.currency,
       round(dr.discount_amount * 100)::bigint AS amount_cents, dr.updated_at AS at, dr.id::text AS reference
FROM discount_redemption dr
WHERE dr.status = 'applied' AND dr.context_type = 'gig_payment'
UNION ALL
SELECT 'returned:' || r.id, dr.context_id, 'returned', dr.currency,
       -round(r.amount * dr.discount_amount * 100 / dr.points_spent)::bigint, r.created_at, r.reference_id
FROM reward_ledger_entry r
JOIN discount_redemption dr ON dr.id::text = r.metadata ->> 'refunded_redemption_id'
WHERE r.reference_type = 'booking_refund' AND dr.points_spent > 0
"""),
    # Card refunds (and refunds that failed, putting money back) and
    # chargebacks, each with the kind of payment it came from; a line that
    # names no payment is split at base rates (rate_assumed). Add-on
    # refunds write no ledger line: they are read from their payment.
    ("bi_refunds", """
SELECT le.id::text AS line_id, le.gig_id,
       CASE WHEN le.entry_type IN ('refund_succeeded', 'refund_failed') THEN 'card' ELSE 'chargeback' END AS source,
       le.entry_type::text AS entry_type, le.currency,
       round(le.amount * 100)::bigint AS amount_cents, le.created_at AS at, le.reference_id AS reference,
       sp.kind::text AS payment_kind, (sp.id IS NULL) AS rate_assumed, false AS date_estimated
FROM ledger_entry le
LEFT JOIN stripe_payment sp ON sp.id = le.stripe_payment_id
WHERE le.entry_type IN ('refund_succeeded', 'refund_failed', 'chargeback_opened', 'chargeback_won')
UNION ALL
SELECT 'payment_refund:' || r.key, sp.gig_id, 'card', 'refund_succeeded', sp.currency,
       -round((r.value ->> 'amount')::numeric * 100)::bigint, (r.value ->> 'created')::timestamptz, r.key,
       sp.kind::text, false, false
FROM stripe_payment sp
CROSS JOIN LATERAL jsonb_each(coalesce(sp.metadata -> 'refunds', '{}'::jsonb)) AS r
WHERE r.value ->> 'status' = 'succeeded'
  AND NOT EXISTS (SELECT 1 FROM ledger_entry le WHERE le.entry_type = 'refund_succeeded' AND le.reference_id = r.key)
UNION ALL
-- A selection add-on refunded before its refunds were recorded one by one
-- (2026-11-10): only the running total is known, so it counts in full on
-- the payment's last update, date estimated.
SELECT 'payment_refunded:' || sp.id::text, sp.gig_id, 'card', 'refund_succeeded', sp.currency,
       -round(sp.amount_refunded * 100)::bigint, sp.updated_at, sp.stripe_payment_intent_id,
       sp.kind::text, false, true
FROM stripe_payment sp
JOIN extra_image_purchase p ON p.stripe_payment_intent_id = sp.stripe_payment_intent_id
WHERE sp.amount_refunded > 0
  AND p.metadata ->> 'kind' = 'selection_addon'
  AND NOT (sp.metadata ? 'refunds')
  AND NOT EXISTS (SELECT 1 FROM ledger_entry le WHERE le.entry_type = 'refund_succeeded' AND le.stripe_payment_id = sp.id)
"""),
    # Every money line on a booking, signed, split at the booking's rates
    # (each share rounded, the photographer's cash the remainder).
    ("bi_lines", f"""
WITH raw AS (
    SELECT line_id, gig_id, 'payment' AS movement, kind, 'card' AS source, currency, amount_cents, at, reference,
           false AS rate_assumed, false AS date_estimated FROM bi_payments
    UNION ALL
    SELECT line_id, gig_id, 'payment', 'base', 'credit', currency, amount_cents, at, reference, false, false
    FROM bi_credit WHERE movement = 'used'
    UNION ALL
    SELECT line_id, gig_id, 'refund', coalesce(payment_kind, 'base'), source, currency, amount_cents, at, reference, rate_assumed,
           date_estimated
    FROM bi_refunds
    UNION ALL
    SELECT line_id, gig_id, 'refund', 'base', 'credit', currency, amount_cents, at, reference, false, false
    FROM bi_credit WHERE movement = 'returned'
), rated AS (
    SELECT raw.*, b.pro_user_id, b.client_user_id, b.niche, b.country, b.tier, b.tier_estimated,
           (raw.at AT TIME ZONE {LONDON})::date AS day,
           CASE WHEN raw.kind = 'extras' THEN b.fee_percent_extras - least(b.fee_percent_extras, b.pro_raww_percent)
                ELSE b.retained_percent END AS r_pct,
           CASE WHEN raw.kind = 'extras' THEN least(b.fee_percent_extras, b.pro_raww_percent)
                ELSE b.pro_raww_percent END AS w_pct,
           CASE WHEN raw.kind = 'extras' THEN 0 ELSE b.client_credit_percent END AS c_pct
    FROM raw JOIN bi_bookings b ON b.gig_id = raw.gig_id
), shares AS (
    SELECT rated.*,
           round(amount_cents * r_pct / 100.0)::bigint AS retained_cents,
           round(amount_cents * w_pct / 100.0)::bigint AS pro_raww_cents,
           round(amount_cents * c_pct / 100.0)::bigint AS client_raww_cents
    FROM rated
)
SELECT line_id, gig_id, pro_user_id, client_user_id, niche, country, tier, tier_estimated, movement, kind, source, currency,
       at, day, reference, rate_assumed, date_estimated, amount_cents, retained_cents, pro_raww_cents, client_raww_cents,
       amount_cents - retained_cents - pro_raww_cents - client_raww_cents AS pro_cash_cents,
       r_pct AS retained_percent, w_pct AS pro_raww_percent, c_pct AS client_credit_percent
FROM shares
"""),
    # RAWW lines, each valued: at its stamped rate, else the order's, else
    # the current setting (an expiry or an admin adjustment).
    ("bi_raww", f"""
WITH rated AS (
    SELECT e.id::text AS line_id, e.pro_user_id, e.kind::text AS kind, e.amount AS amount_raww, e.gig_id, e.created_at AS at,
           (e.created_at AT TIME ZONE {LONDON})::date AS day,
           CASE WHEN e.raww_eur_value IS NOT NULL THEN e.raww_eur_value
                WHEN o.id IS NOT NULL THEN o.raww_eur_value ELSE ss.raww_eur_value END AS rate,
           CASE WHEN e.raww_eur_value IS NOT NULL THEN 'stamped'
                WHEN o.id IS NOT NULL THEN 'order' ELSE 'current' END AS rate_source
    FROM pro_raww_ledger_entry e
    LEFT JOIN shelf_order o ON e.source_type = 'shelf_order' AND o.id::text = e.source_id
    LEFT JOIN shelf_settings ss ON ss.id = 1
)
SELECT rated.*, round(amount_raww * rate * 100)::bigint AS value_cents FROM rated
"""),
    # Manual costs, a recurring one repeated monthly on its day of the month.
    # The retired category shelf_shipping (legacy) repeats no later than the
    # day it was retired.
    ("bi_costs", """
WITH c AS (
    SELECT c.*, CASE WHEN c.category = 'shelf_shipping'
                     THEN least(coalesce(c.end_date, DATE '2026-11-10'), DATE '2026-11-10')
                     ELSE coalesce(c.end_date, current_date + 400) END AS last_day
    FROM bi_cost c WHERE c.deleted_at IS NULL
)
SELECT c.id AS cost_id, c.category, c.currency, c.amount_cents, c.recurring, c.note,
       (c.date + make_interval(months => k))::date AS day, (c.category = 'shelf_shipping') AS legacy
FROM c
CROSS JOIN LATERAL generate_series(
    0,
    CASE WHEN c.recurring THEN
        greatest((extract(year FROM age(c.last_day, c.date)) * 12 + extract(month FROM age(c.last_day, c.date)))::int, 0)
    ELSE 0 END
) AS k
"""),
    # Shelf orders: placed (+), and reversed (-) when cancelled or refunded.
    # The cost is the one recorded on the order (supplier cost x its euro
    # rate); an order with none recorded falls back to the item's cost at
    # today's rate, estimated. cost_cents null is "cost not set". Shipping
    # is what an admin entered on the order, in euros.
    ("bi_shelf", f"""
WITH o AS (
    SELECT o.id AS order_id, o.pro_user_id, o.item_id, o.status::text AS status, o.placed_at,
           coalesce(o.refunded_at, o.cancelled_at) AS reversed_at,
           round(o.price_raww * o.raww_eur_value * 100)::bigint AS value_cents,
           CASE WHEN o.supplier_cost IS NOT NULL OR o.supplier_currency IS NOT NULL THEN
                    CASE WHEN o.supplier_cost > 0 AND o.cost_eur_rate IS NOT NULL
                         THEN round(o.supplier_cost * o.cost_eur_rate * 100)::bigint END
                WHEN i.supplier_cost IS NULL OR i.supplier_cost <= 0 THEN NULL
                WHEN upper(i.supplier_currency) = 'EUR' THEN round(i.supplier_cost * 100)::bigint
                WHEN upper(i.supplier_currency) = 'GBP' AND ss.gbp_eur_rate IS NOT NULL
                     THEN round(i.supplier_cost * ss.gbp_eur_rate * 100)::bigint
                ELSE NULL END AS cost_cents,
           (o.cost_estimated OR (o.supplier_cost IS NULL AND o.supplier_currency IS NULL)) AS cost_estimated,
           CASE WHEN lg.covered THEN 0 ELSE coalesce(round(o.shipping_cost_eur * 100)::bigint, 0) END AS shipping_cents,
           (o.shipping_cost_eur IS NULL AND o.status::text IN ('shipped', 'delivered') AND NOT lg.covered) AS shipping_not_set
    FROM shelf_order o
    JOIN shelf_item i ON i.id = o.item_id
    LEFT JOIN shelf_settings ss ON ss.id = 1
    -- Shipped on or before the last legacy shelf_shipping cost: its shipping
    -- is in those costs, so its own is not counted again.
    CROSS JOIN LATERAL (
        SELECT coalesce(o.shipped_at IS NOT NULL AND (o.shipped_at AT TIME ZONE {LONDON})::date
                        <= (SELECT max(c.day) FROM bi_costs c WHERE c.category = 'shelf_shipping'), false) AS covered
    ) lg
)
SELECT order_id::text || ':placed' AS line_id, order_id, pro_user_id, 'placed' AS movement, placed_at AS at,
       (placed_at AT TIME ZONE {LONDON})::date AS day, value_cents, cost_cents, 1 AS orders,
       shipping_cents, cost_estimated::int AS cost_estimated_orders, shipping_not_set::int AS shipping_not_set_orders
FROM o
UNION ALL
SELECT order_id::text || ':reversed', order_id, pro_user_id, 'reversed', reversed_at,
       (reversed_at AT TIME ZONE {LONDON})::date, -value_cents, -cost_cents, -1,
       -shipping_cents, -(cost_estimated::int), 0
FROM o WHERE status IN ('cancelled', 'refunded') AND reversed_at IS NOT NULL
"""),
    ("bi_earnings", """
SELECT e.id AS entry_id, e.pro_user_id, e.source_type::text AS source_type, e.source_id, e.status::text AS status,
       e.currency, round(e.gross * 100)::bigint AS gross_cents, round(e.net * 100)::bigint AS net_cents,
       e.available_at, e.created_at
FROM earnings_ledger_entry e
"""),
    ("bi_payouts", f"""
SELECT r.id AS payout_id, r.pro_user_id, r.status::text AS status, r.currency, round(r.amount * 100)::bigint AS amount_cents,
       coalesce((SELECT round(sum(a.amount) * 100)::bigint FROM payout_allocation a WHERE a.payout_request_id = r.id), 0)
           AS allocated_cents,
       r.requested_at, r.paid_at, (r.paid_at AT TIME ZONE {LONDON})::date AS paid_day
FROM payout_request r
"""),
    # Money owed to clients now: open "client owed" items, and refunds
    # decided and not yet made.
    ("bi_client_owed", """
SELECT 'attention:' || m.id AS line_id, m.gig_id, 'client_owed' AS kind, m.currency,
       round(m.amount * 100)::bigint AS amount_cents
FROM money_attention_item m WHERE m.kind = 'client_owed' AND m.status = 'open'
UNION ALL
SELECT 'refund_case:' || c.id, c.gig_id, 'refund_in_flight', c.currency,
       round(greatest(c.amount - coalesce(c.amount_refunded, 0), 0) * 100)::bigint
FROM refund_case c WHERE c.status IN ('approved', 'processing', 'refund_initiated')
"""),
    ("bi_stripe", f"""
SELECT t.id, t.type, t.reporting_category, t.currency, t.amount_cents, t.fee_cents, t.net_cents, t.created_at AS at,
       (t.created_at AT TIME ZONE {LONDON})::date AS day, t.available_on, t.source_id, t.demo
FROM bi_stripe_txn t
"""),
    # The latest balance of each company account.
    ("bi_cash", """
SELECT DISTINCT ON (account) id, account, date, currency, amount_cents, note
FROM bi_company_cash WHERE deleted_at IS NULL
ORDER BY account, date DESC, created_at DESC
"""),
]


def create_sql() -> list[str]:
    return [f"CREATE OR REPLACE VIEW {name} AS {body.strip()}" for name, body in VIEWS]


def drop_sql() -> list[str]:
    return [f"DROP VIEW IF EXISTS {name} CASCADE" for name, _ in reversed(VIEWS)]


def _register() -> None:
    from app.models.media import Base

    for statement in create_sql():
        event.listen(Base.metadata, "after_create", DDL(statement).execute_if(dialect="postgresql"))
    for statement in drop_sql():
        event.listen(Base.metadata, "before_drop", DDL(statement).execute_if(dialect="postgresql"))


_register()
