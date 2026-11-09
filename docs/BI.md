# Business dashboard (BI): the definitions

The single source of truth for every number on the admin dashboard (`/admin/bi`). Each number is defined here once, with its formula and its source. The code implements exactly these: the SQL views in `api/app/models/bi_views.py` and the computation in `api/app/services/bi.py`. When a definition changes, change it here first.

Where the request's definition did not fit the code, the reading used is marked **[interpretation]**. Those are questions for the owner (listed at the end).

## Ground rules

- **Currency.** Every booking, payment and ledger line today is in **EUR**: `gig.currency`, `stripe_payment.currency`, `ledger_entry.currency` and `discount_redemption.currency` exist, and the dev database holds EUR only. The dashboard computes EUR only. A line in any other currency is left out and counted as "excluded, other currency" on the overview. It is never converted silently.
- **Amounts.** Stored amounts are `Numeric(12,2)` euros. The views turn each into **integer cents** once (`round(amount * 100)::bigint`), and everything after that is integer arithmetic. No floats anywhere.
- **Days.** A day is a calendar day in **Europe/London**, the same as the client-credit month: `(timestamp AT TIME ZONE 'Europe/London')::date`.
- **Split rounding.** A money line is split as the code splits a booking (`commission.split_with_rates`): each percentage share is rounded half away from zero to the cent, and the photographer's cash is the remainder. So the shares always add back to the line exactly. The split is per line, so a booking's total can differ by a cent from the split stamped on the booking (`gig.final_*`), which is computed once on the total.
- **Missing is not zero.** A number that cannot be computed is `null` and shows "no data" or "not set", with the reason.
- **Honest averages.** An average or a percentage over fewer than 30 items shows "low sample (n=…)" instead of a number.

## The money lines (`bi_lines`)

One row per money movement on a booking, signed (+ in, − back). Every booking number below is a sum over these lines.

| Line | Sign | Source | Day |
|---|---|---|---|
| Card payment | + | `stripe_payment.amount`, status succeeded, refunded or disputed (money that reached us). Kinds base, difference and extras | the `payment_captured` ledger line's `created_at`; for extras (no such line), `stripe_payment.created_at` **[interpretation]** |
| Credit payment | + | `discount_redemption.discount_amount`, status applied, context `gig_payment` (client credit used at checkout) | `discount_redemption.updated_at` (as `client_credit.budget_view`) |
| Card refund | − | `ledger_entry` `refund_succeeded` (negative amount); a `refund_failed` line puts it back | the ledger line's `created_at` |
| Chargeback | − | `ledger_entry` `chargeback_opened` (−), `chargeback_won` (+) | the ledger line's `created_at` |
| Credit returned | − | `reward_ledger_entry`, reference `booking_refund` (credit given back on a refund), valued at its own redemption's rate: points × `discount_amount` / `points_spent` | its `created_at` |

**Rates for the split.**
- Base and difference lines use the booking's stamped `fee_percent`, `retained_percent`, `pro_raww_percent` and `client_credit_percent`, or the current `platform_fee_policy` if the booking has none stamped.
- Extras lines use the policy's `fee_percent_extras`, the booking's `pro_raww_percent`, and no client credit, the way `payouts.create_earnings_entry` splits extras.
- Refunds, chargebacks and returned credit use the booking's base rates **[interpretation]**. The ledger does not say which payment a refund came from.

**Dimensions.**
- Niche: `gig.niche_id`.
- Country: the photographer's `pro_profile.country`.
- Tier: the photographer's current `pro_niche_skill.tier` in that niche **[interpretation: the tier now, not at booking time; it is not stamped]**. A daily row keeps the tier as of when that day was computed.

## The definitions

| Number | Formula | Source |
|---|---|---|
| **GMV** | Σ positive lines (card + credit payments). The pre-discount price: credit used counts as paid. Extras and selection add-ons included. | `bi_lines` |
| **Refunds** | Σ negative lines, as a positive number. Shown beside GMV, never netted silently. | `bi_lines` |
| **Net GMV** | GMV − Refunds | |
| **Platform fee** | `fee_percent` (20) of each line = retained (15) + photographer RAWW credit (5). Extras: the same 15 + 5 split (built 2026-11-03). | `bi_lines.retained_cents + pro_raww_cents` |
| **Retained fee (revenue)** | Σ `retained_cents` over all lines: the 15% share, after refunds | `bi_lines` |
| **Photographer cash (flow)** | Σ `pro_cash_cents`: the 80% share less any client credit the photographer passed on | `bi_lines` |
| **Photographer RAWW credit (flow)** | Σ `pro_raww_cents`: the 5% share | `bi_lines` |
| **Photographer's credit to client (flow)** | Σ `client_raww_cents`: the 0–10% a photographer gives their client, out of their own cash | `bi_lines` |
| **Identity** | Net GMV = photographer cash + photographer RAWW + photographer's credit to client + retained. Exact, by the split. | |
| **Photographer cash (stock, now)** | From the earnings ledger, as `photographer_money`: **in settlement** (status pending, the 7-day delay), **held** (status held: a dispute, a reported problem, an admin hold), **due** (available + requested + approved, not yet paid), **paid out** (allocated to paid payouts). Owed = in settlement + held + due. | `bi_earnings`, `bi_payouts` |
| **RAWW issued** | Σ RAWW `earn_booking` + `earn_extras`, each × its stamped `raww_eur_value`. Reversals (`reverse_*`) are shown beside it. | `bi_raww` |
| **RAWW spent in the Shelf** | Σ `spend_order` − `refund_order`, each × the order's stamped `raww_eur_value` | `bi_raww` |
| **RAWW expired (breakage)** | Σ `expire` × the current `shelf_settings.raww_eur_value` **[interpretation: an expiry line has no stamped rate]**. Recognised only when the expiry job has run (the line exists only then). | `bi_raww` |
| **RAWW outstanding (liability)** | Σ every RAWW line to date, each at its value as above. Admin adjustments are valued at the current rate. | `bi_raww` |
| **Stripe fees** | Σ `fee` of Stripe's balance transactions (processing, refund and dispute fees), mirrored daily into `bi_stripe_txn`. Not stored before this; never estimated. A day not yet mirrored makes the period's fees "no data". | `bi_stripe` |
| **Contribution profit** | Retained fee − Stripe fees | |
| **Client credit used** | Credit payments − credit returned (the credit lines of `bi_lines`). A marketing cost, paid from the retained share. It is **not** taken off GMV or the retained fee: it appears once, in marketing spend. | `bi_credit` |
| **Marketing spend** | Ad spend (manual, category `ad_spend`) + marketing costs (manual, category `marketing`) + client credit used | `bi_costs`, `bi_credit` |
| **Other costs** | Every manual cost in any other category, except `shelf_shipping` | `bi_costs` |
| **Shelf margin** | For each order: `price_raww × raww_eur_value` (stamped on the order) − the item's `supplier_cost` in EUR, minus manual costs in category `shelf_shipping`. An order whose item has no cost (≤ 0, or in a currency other than EUR/GBP) is "cost not set": counted and shown, excluded from the margin, never taken as zero. GBP costs are converted at the current `shelf_settings.gbp_eur_rate` **[interpretation: the cost and the rate are not stamped on the order]**. Placed on `placed_at`; reversed on `refunded_at`/`cancelled_at` for cancelled and refunded orders. | `bi_shelf`, `bi_costs` |
| **Breakage** | RAWW expired, as above | `bi_raww` |
| **Operating profit** | Contribution profit − marketing spend − other costs + Shelf margin + breakage | |

**Why the client credit is never counted twice.** Cash actually kept = retained − client credit used. The definitions reach it once: retained is computed on the pre-discount price, and the credit comes off once, in marketing spend. A test (`test_bi.py::test_client_credit_is_counted_once`) checks operating profit against the same profit computed from the card cash alone.

## Gross view (accrual) and liquid view (cash)

- **Gross view:** the definitions above, over a period. Money is recognised on the day it moves (paid, refunded), not when the booking completes.
- **Liquid view (now):** what is really ours today.

  ```
  cash held      = Stripe balance (available + pending, live from Stripe)
                 + company cash (the latest manual balance of each account)
  owed           = photographer cash owed (in settlement + held + due)
                 + owed to clients (open "client owed" items + refunds approved and not yet made)
  liquid         = cash held − owed
  ```

  Stripe's pending balance is shown apart: money Stripe has not yet made available (the balance timing). The RAWW liability is shown in euros beside it and is **not** subtracted. It is settled in goods at cost (the Shelf margin), not in cash **[interpretation]**.

## Bookings count

The number of bookings whose first card or credit payment fell on that day (base kind).

## Not counted

- The legacy `upsell_purchase` path: no rows in dev. Its payments are not `stripe_payment` rows. If any succeed, the overview says so.
- Studioverse sales and prints: separate products, not bookings.

## Questions for the owner

1. Refunds use the booking's base rates. Should an extras refund use the extras rates? This needs the refund linked to its payment.
2. Breakage and admin adjustments are valued at the current RAWW rate. Should the expiry stamp the rate (or FIFO the lots)?
3. The Shelf cost is the item's current `supplier_cost`, converted at the current GBP rate. Should the order stamp its cost and rate?
4. The tier is today's tier. Should the booking stamp the tier at acceptance?
5. Should the RAWW liability be subtracted from liquid at cost (supplier cost / RAWW value) rather than left out?
6. Should credit-returned lines count as refunds (they do now) and reduce marketing spend (they do now)?
