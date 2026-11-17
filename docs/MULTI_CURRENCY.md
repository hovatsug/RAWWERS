# Multi-currency (EUR and GBP): design

Written 2026-11-11 on `the-shelf-wip`, read-only: nothing here is built. It is for the owner to approve before batch M starts (`docs/BETA_SCOPE.md` #14).

**Updated 2026-11-13** for the owner's UK-first decision (GBP main and the default for new users, EUR second) and Stripe's answers. Sections 9 to 12 are new: Stripe's answers (9), what they change in the design (10), the two company scenarios (11) and the build order (12). Where an earlier section said otherwise, it is marked *superseded* and points to the new text.

**Updated 2026-11-16:** decision M11 is made: the platform is run by a **Portuguese company, entity to be confirmed** (section 11.0). Scenario X (a UK company) is **archived**, kept for comparison only. What batch M6 still waits for is in section 12.

**The requirement (decided, option A).**
- Each photographer prices and is paid in one currency, EUR or GBP.
- Each user picks a display currency and sees an approximate conversion, labelled with the currency actually charged.
- The platform takes no exchange-rate risk.
- Charging the client in their own currency (option B) is not wanted.

**In one paragraph.** Money already flows in one currency per booking: a package has a currency, the booking and its Stripe charge take it, and refunds go back in it. What breaks for GBP:
- Everything **after** the charge assumes EUR: the photographer's earnings ledger, balances, holds, payouts (the Stripe transfer is hard-coded to `eur`), the €50 minimum, the invoice, RAWW, client credit and BI.
- The apps format several of these as €.
- Two checks compare a GBP number with a EUR one without noticing: the price cap and the discovery budget filter.

The design:
- Every amount carries its currency, end to end.
- A photographer's currency is fixed by their Stripe account's country.
- The platform holds GBP as GBP, so nothing is ever converted on the money path.
- Conversion exists only for display (approximate, labelled) and for reporting (BI in EUR, at a rate stamped when the money moved).

---

## 1. Inventory: where amounts live today

Key: **✓** currency known · **≈** a currency column exists but is defaulted or ignored · **✗** EUR assumed (hard-coded, `_eur` name, or no currency).

### 1.1 Stored (API database)

| Area | Where | Today |
|---|---|---|
| Packages | `pro_package.price`, `currency` (`models/booking.py:68`, default EUR); the API takes `currency` on create (`pro_onboarding.py:395`) | ✓ but nothing stops a photographer mixing currencies across packages |
| Price curves | `package_decay_curve` (per niche; ratios, no amounts) | ✓ currency-free |
| Price caps | `niche_package_price_cap` (niche, tier) with `currency` default EUR (`models/package_pricing.py:68`) | **≈ the check ignores currency**: `enforce_entry_price_cap` compares the entry price with the cap's numbers (`services/package_pricing.py:347`), so a £500 package is held to a €500 cap. No city in the key. |
| Extra-image price caps | `extra_image_pricing_policy` (niche, tier, `currency`) | ≈ same |
| Bookings and gigs | `booking_request.currency`, `gig.currency` (from the package, `gig_builder.py:102`), `gig.amount_*` | ✓ |
| Payments | `stripe_payment.amount`, `currency`, `amount_refunded`; `ledger_entry.amount`, `currency` | ✓ |
| Extras, selection add-ons | `proof_gallery.currency`, `extra_image_purchase.currency`, `upsell_purchase.currency` (`models/gallery.py`) | ✓, with fallbacks `or "EUR"` (`selection_quote.py:207`, `selection_addons.py:141`, `invoices.py:210`) |
| Price reductions, refunds | `price_reduction.currency`, `refund_case.currency` (`models/admin.py:262`) | ✓ (Stripe refunds the PaymentIntent in its own currency) |
| Disputes, chargebacks | `dispute.currency` (`or "EUR"`, `disputes.py:434`); `money_attention_item.currency` (`accountability.py:230` writes "EUR") | ✓ / ≈ |
| **Earnings** | `earnings_ledger_entry.gross_eur`, `platform_fee_eur`, `net_eur`, `pro_raww_eur` (`models/payouts.py:87-93`) | **✗ no currency column** |
| **Balances** | `earnings_balance_snapshot.pending_eur`, `available_eur`, `held_eur` | **✗** |
| **Holds** | `earnings_hold.amount_eur` | **✗** |
| **Payouts** | `payout_request.amount_eur`, `payout_allocation.amount_eur`; `MIN_PAYOUT_EUR = 50.00` (`services/payouts.py:40`); `Transfer.create(currency="eur")` (`payouts.py:496-498`); the "on its way" notification writes € and `"currency": "EUR"` (`payouts.py:540-542`) | **✗ hard-coded** |
| Fee policy | `platform_fee_policy` (percentages) | ✓ currency-free |
| VAT | `country_tax_rule.threshold_currency` (reference only, `tax.py:56`) | ✓ |
| RAWW | `shelf_settings.raww_eur_value` (one rate); `pro_raww_ledger_entry.raww_eur_value` stamped per entry (`models/shelf.py`); earning = `round(pro_raww_eur / raww_eur_value)` (`raww_earning.py`) | **✗ RAWW valued in EUR only** |
| Client credit | the reward ledger in points (100 = €1); `client_credit_settings.monthly_marketing_credit_budget_eur`, `min_conversion_value_eur` (`models/reward.py`); credit applied to `gig.currency` as if euros (`client_credit.py:255-277`) | **✗ points are euros** |
| The Shelf | items `supplier_cost` + `supplier_currency` (default GBP), `street_currency` GBP; `shelf_settings.gbp_eur_rate` 1.17 (a fixed helper rate); `shelf_order.shipping_cost_eur` | ≈ GBP costs, EUR valuation |
| Discovery | `pro_public_index.min_package_price`, `currency` (first package's, `discovery_index.py:81`); the budget filter compares numbers across currencies | **≈ wrong across currencies** |
| BI | `bi_daily` in EUR cents; lines not in EUR are **counted and left out** (`other_currency_lines`, `services/bi.py:76`); Stripe mirror reads EUR balance entries only (`bi_stripe.py:104`); costs EUR only (`bi.py:300`) | ✗ by design, flagged on screen |
| Dormant (store, prints, learning, Studioverse, legacy shoot) | `*_eur` columns throughout | ✗, stay dormant and EUR-only |

### 1.2 Returned by the API

- **Carry a currency:** gig and booking responses (`GigResponse.currency`), packages, the selection quote, extras, invoice (`api/v1/payouts.py:107`), refunds, disputes, the BI responses (EUR).
- **No currency, EUR in the name:** `GET /v1/pro/earnings/balance` (`withdrawable_eur`, `pending_eur`, `available_eur`, `held_eur`), the earnings ledger and summary (`gross_eur`, `net_eur`, ...), payout requests (`amount_eur`), the RAWW card (`raww_eur_value`). `schemas/payouts.py` alone has 27 `_eur` fields.
- **Client credit** ("€1.00 credit") and the Shelf (EUR price helper, GBP supplier cost) are text or EUR-only numbers.
- `GET /v1/pro/me/pricing/niches/{id}` defaults `currency="EUR"` (`pro_onboarding.py:826`).

### 1.3 Shown in the apps

- One formatter, `RMoney` (`app/lib/core/format/money.dart`). It formats by the response's currency and falls back to EUR (`fallbackCurrency`) for responses that send none, which is every earnings, balance and payout response.
- **Literal "€" in four places:** `pro/wallet/raww_card.dart`, `pro/shelf/shelf_screen.dart`, `shared/discover/discover_card.dart`, `client/credit/credit_labels.dart`.
- **Other EUR assumptions:**
  - payout requests are made in EUR (`core/money/payout_request_money.dart`);
  - `amount_eur`, `pending_eur`, `withdrawable_eur` and `net_eur` are read in about 25 places in the pro app.

### 1.4 Shown on the web admin

`money(amount, currency)` in `app/admin/_components/ui.tsx` is currency-aware. € or "EUR" is assumed in disputes, BI (`bi/_parts.tsx`, costs), Shelf settings and orders, client credit and price caps.

### 1.5 Emails and notifications

- `email_texts` formats by currency (`_SYMBOLS` has £), and "payment received" carries the payment's currency.
- "Payout on its way" says € (`payouts.py:540`).
- The client-credit notifications say € (`client_credit.py:182, 203`).

---

## 2. Where each currency is set

### 2.1 The photographer's currency (pricing and payout: one)

- **New field `pro_profile.currency`** (EUR or GBP). It is set **from the country of their Stripe Connect account** when the account is created:
  - GB → GBP;
  - a eurozone country → EUR.
  - No exceptions (Stripe's answers, 10.3).
- It is the default currency of that account's bank payouts. Stripe fixes an account's country at creation (`stripe_connect.py:50-57` already passes the profile's country).
- Before a Connect account exists, the currency follows the profile's country, by the same rule.
- **Every package must be in it.** The API refuses a package in another currency (today `currency` is free text on create).
- **The earnings ledger, balance, holds and payouts are in it.** One photographer has one balance in one currency, so no balance ever mixes currencies.
- **Changing currency** (a photographer moving country): admin-only, and only when:
  - nothing is open: no booking before completed, no pending, held or available earnings, no payout in flight;
  - a new Connect account exists for the new country.
  The old account and the old-currency history stay as they were. Packages are switched off and the photographer re-prices them; nothing is converted.

### 2.2 The client's display currency

- **New field `display_currency`** on the user (EUR or GBP; null means "use the default"). *Superseded 2026-11-13:* the default is **GBP** for every new user (UK first); a device region in the eurozone may suggest EUR, but never sets it on its own (10.1).
- It is **changeable in Account → Display currency**, and for photographers too (Settings).
- It changes **only the approximation**. The amount charged and every amount stored stay in the photographer's currency.

### 2.3 The platform's base currency

**EUR**, for reporting only (BI, the owner's totals). It is not a money-path currency. *Superseded 2026-11-13:* the base currency is the currency of the company's books, a setting: EUR for a Portuguese company, GBP for a UK one (section 11). *Decided 2026-11-16:* **EUR**, the books of a Portuguese company (11.0, 11.5).

### 2.4 When the display currency differs from the charged currency

**Rule:** the charged amount is always shown, exact, in its own currency. The approximation is added beside it, never instead of it, and never on a line the client pays from. Approximations are rounded (section 4.3).

| Screen | Shows |
|---|---|
| Discover cards, search, niche rows | `about £850` as the headline, with `€1,000` small beneath it |
| Photographer profile, package list | `€1,000 · about £850` |
| Booking request sheet (before sending) | `€1,000 · about £850` and the line *"You'll be charged in euros (EUR). Your bank sets the final amount in pounds."* |
| Pay screen and payment sheet | `Total €1,000.00`, then *"Charged in EUR. About £850 at today's rate; your bank's rate may differ."* (Stripe's sheet itself shows €) |
| Selection quote, extras, add-on window | Same as the pay screen, per line |
| Booking detail, receipt and history | Exact amounts in the charged currency only; one line *"Charged in EUR"* |
| Emails ("payment received") | Charged currency only: `We received €1,000.00 for your shoot.` No approximation in money emails |
| Photographer wallet, earnings, payouts, invoice | Always in the photographer's own currency, exact. No approximation |
| Refund lines | Charged currency only: `€250.00 back to your card` |

**Exact wording** (English, for the lawyer to confirm):
- Short label: **"about £850 · charged in €1,000"**. Where space allows: **"about £850, charged in €1,000"**.
- Before paying: **"You'll be charged €1,000.00 (EUR). About £850 at today's rate. Your bank or card sets the final amount."**
- When the rate is stale or missing (section 4.1): the approximation is dropped, and the line reads **"Charged in EUR"** only.

---

## 3. Stripe

### 3.1 How it is set up today (read from the code)

- **Charge type: separate charges and transfers.** The booking's PaymentIntent is created **on the platform account**, in `gig.currency` (`payment_intents.py:340`). There is no `transfer_data`, `on_behalf_of` or `application_fee_amount`.
- The platform holds the money through the hold and settlement period. On a payout request it sends `stripe.Transfer.create(currency="eur", destination=<connected account>)`, with an idempotency key (`payouts.py:496`).
- **Connected accounts: Express**, `capabilities={"transfers": {"requested": True}}`, `business_type="individual"`, country from the profile (`stripe_connect.py:50-57`).
- **The platform account is Portuguese and settles in EUR** (BACKEND_GAPS "GB photographers on a PT/EUR platform").
- Payment methods: `automatic_payment_methods` without redirects (cards and wallets). Delayed methods are disabled in the dashboard.

### 3.2 What GBP needs

1. **GBP charges.** Creating a PaymentIntent with `currency="gbp"` already works in code. **The risk:** a Portuguese account with only a EUR bank account converts GBP charges into EUR on settlement. Stripe then applies its conversion fee and rate, so the platform holds EUR against a GBP debt to the photographer. That is exactly the exchange-rate risk the requirement forbids.
   **Needed:** the platform account holds a **GBP balance**: Stripe's multi-currency settlement, with a GBP bank account added to the PT account. GBP charges then settle as GBP, and refunds, disputes and transfers come out of that GBP balance.
2. **A UK photographer's connected account:** an Express account with `country="GB"`, `transfers` capability, created by a PT platform. This is a **cross-border connected account**. *Superseded by Stripe's answer (9, 10.2):* it needs the **full** service agreement, not the recipient one, and the agreement cannot be changed once accepted. Its default currency is GBP, and its payouts go to a UK bank account in GBP.
3. **GBP transfers.** `Transfer.create(currency="gbp", destination=<GB account>)`, funded from the platform's GBP balance. The code change is the currency (the row's), and refusing a transfer whose currency is not the photographer's.
4. **Optional, safer:** `source_transaction=<charge id>` on transfers, so a transfer is funded by the charge it pays out. Today one payout covers many bookings (allocations), so this is a larger change. Not proposed for batch M. *Superseded 2026-11-13:* every transfer uses `source_transaction` (10.4, batch M7).

### 3.3 What only Stripe can confirm, and the questions to send

Send to Stripe support (Connect), from the platform account:

1. *"Our platform account is in Portugal (EUR). Can we enable multi-currency settlement with a GBP bank account, so GBP card charges settle and stay in a GBP balance without conversion? What are the requirements, and is it available in test mode?"*
2. *"Can our PT platform create Express connected accounts in the United Kingdom, using separate charges and transfers? Must they use the recipient service agreement? Are there restrictions on GB recipients for an EEA platform (capabilities, onboarding requirements, payout schedule)?"*
3. *"If we transfer GBP from our GBP balance to a GB Express account, is anything converted at any step? Do the account's payouts go to a UK bank in GBP?"*
4. *"When a GBP charge is refunded or disputed, is the amount (and the dispute fee) debited from our GBP balance? If the GBP balance is short, what happens: a debit from EUR with conversion, or a negative GBP balance?"*
5. *"What fees apply to GBP card payments by UK cardholders, charged by our PT account: international card, currency conversion, cross-border transfer and payout fees? Is `on_behalf_of` recommended or required for UK consumers in our model (the settlement merchant, the statement descriptor, SCA)?"*
6. *"Can a GB connected account also receive EUR, or a PT account GBP? We intend one currency per photographer, and want to know whether Stripe enforces that."*
7. *"Does our Stripe agreement or our platform profile need changing to serve UK customers and UK recipients (business description, countries served)?"*

### 3.4 What test mode cannot show

- Real exchange rates and conversion fees. Test mode applies rates, but neither the fees nor the rates are the live ones.
- Real fee amounts on UK cards charged by a PT merchant.
- Live identity verification of UK individuals: test mode passes everyone with test values.
- Actual bank payouts arriving, and their timing.
- Whether live multi-currency settlement is approved for the account. It is an account-level review.
- Real dispute timelines and evidence handling by UK issuers.

**Test mode can show** a GB Express account onboarded, a GBP PaymentIntent, a GBP refund and a GBP transfer to that account. That is the end-to-end test plan's Stripe step (section 7.3).

---

## 4. Exchange rates

### 4.1 For display (approximate)

- **Source:** the European Central Bank's euro reference rates (free, no key, published once on working days, around 16:00 CET; `eurofxref-daily.xml`). EUR/GBP is on it.
- **Refreshed** by a beat job every hour that keeps the newest publication. That is one real change a working day.
- **Stored** in a new table, `fx_rate` (`base` EUR, `quote`, `rate` as `Numeric(18,8)`, `as_of` (the ECB date), `fetched_at`, `source`), one row per day. The newest row is served by `GET /v1/fx/rates` (public, cached), so the apps convert with the same rate the server uses for emails and BI.
- **May be at most 4 days old** (weekends and holidays). Older, or if no rate exists, the API returns no rate. The apps then show only the charged amount and the line "Charged in EUR". The job raises a Sentry event when the newest rate is older than 4 days.
- GBP to EUR is the inverse of the stored EUR to GBP, computed at full precision, rounded only at the end.

### 4.2 For real money

- **On our money path nothing is converted:** the charge, the hold, the refund and the transfer are all in the photographer's currency, and the platform holds that currency (section 3.2).
- If Stripe nevertheless converts something (a debit from another balance, a fee in another currency), the **balance transaction's `exchange_rate`** is what applied. The Stripe mirror already reads balance transactions, so it records it: `stripe_balance_txn.exchange_rate`, currency and original amount.
- The rate a client's bank applies is theirs and is never known to us. That is why the label says "about".

### 4.3 Units and rounding

- **Storage.**
  - **Today:** amounts are `Numeric(12,2)` decimals, not integer minor units.
  - **New columns:** integer minor units (`*_minor bigint`).
  - **Existing columns:** stay `Numeric(12,2)` for now. A whole-schema change to integers is out of scope.
  - Both EUR and GBP have exponent 2, so a 2-decimal amount *is* an exact count of minor units. Every Stripe call already converts with `to_cents` (`stripe_service.py:27`).
  - **Rule:** any amount that leaves Python for Stripe, BI or the apps is an exact count of minor units; a float never carries money.
- **Money-path rounding** (unchanged; it is the same in both currencies):
  - every computed part rounds half-up to 0.01 in the charge currency (`commission.py:45`, `photographer_money.py:68`);
  - the last part is the remainder, so the parts always add up to the total exactly.
- **Display conversion:** `charged_minor × rate`, rounded half-up to a whole minor unit, then shown rounded:
  - to the nearest whole unit (£850) when it is £20 or more;
  - to the minor unit (£8.47) below that.
  An approximation is never summed. A total's approximation is converted from the exact total, not added up from rounded lines.
- **Reporting conversion (BI):** `amount_minor × rate_to_base`, rounded half-up to a whole EUR cent, **once per line, at stamping time**. Totals are sums of stamped lines, so they never move when rates change.

---

## 5. Effect on the rest

| Area | Design |
|---|---|
| **RAWW** | RAWW stay a unit with no currency. The RAWW **value** becomes per currency: `shelf_settings.raww_value_eur` (today's `raww_eur_value`) and `raww_value_gbp`, changed together by the admin. An earning stamps the currency and the rate it used (`pro_raww_ledger_entry.raww_value` and `raww_value_currency`, beside today's `raww_eur_value`). Then `RAWW = round(pro_raww_amount / raww_value[currency])`, and a refund reverses at the stamped rate (as today). The Shelf prices items in RAWW, so nothing on the Shelf converts. Its platform cost in BI uses the stamped rate and the payment-day EUR rate (section 5, BI). The Shelf stays off (UK and GBP only). |
| **Client credit and its monthly budget** | **Per currency.** Credit earned on a EUR booking is EUR credit, usable on EUR bookings only, and likewise GBP. The reward ledger gets a `currency` column (existing points are EUR), and the balance is per (client, currency). The monthly marketing budget gets one figure per currency (`monthly_marketing_credit_budget_eur` and `_gbp`), and the 80%/100% alerts work per currency. No conversion, so no risk. The alternative, one EUR wallet converted at the day's rate, puts a small rate exposure on the platform: decision M3. |
| **The Shelf** | Supplier costs stay in their currency (GBP). The fixed helper rate `gbp_eur_rate` (1.17) is replaced by the `fx_rate` table for the price helper. The order's cost snapshot keeps the supplier currency and amount, plus the EUR value at the order date for BI. `shipping_cost_eur` becomes `shipping_cost` and `shipping_currency`. |
| **Refunds** | Always in the original payment's currency, which Stripe already enforces (a refund is on the PaymentIntent). `refund_case.currency` is set from the payment, never defaulted. The client-owed and money-attention items carry the payment's currency (no `"EUR"` default). |
| **Disputes and chargebacks** | Amount and currency from Stripe's dispute object (it has both). The dispute fee is recorded in the currency Stripe debits. |
| **Price caps** | Keyed by **(niche, tier, currency)**, so there is a GBP table and a EUR table, each in its own currency. `enforce_entry_price_cap` looks up the cap for the package's currency, and refuses (422 "no cap for GBP yet") when a currency has no caps while caps exist for others. That avoids today's silent pass-through. **Per city** (the owner's words) is not in today's model; it would add a `city` column to the key and a city to each package. Recommended: per currency now, a city override later if prices really differ by city within one currency (decision M2). |
| **The withdrawal minimum** | Per currency: `PAYOUT_MINIMUM_EUR` (50.00) and `PAYOUT_MINIMUM_GBP` (owner sets; proposed 45.00), as settings. |
| **VAT** | Unchanged in shape: VAT is charged on the platform fee, in the booking's currency. Which VAT applies to a PT company's fee on a UK booking is the accountant's question, not a code one. The invoice shows the fee and its VAT in the booking's currency. `country_tax_rule.threshold_currency` stays reference-only. |
| **Invoices** | In the booking's currency; the `or "EUR"` fallback is removed (a missing currency is a bug and raises). |
| **Discovery and search** | `pro_public_index` keeps `min_package_price` and `currency`, and adds `min_package_price_base_minor` (EUR) for the budget filter. That column is recomputed by the daily rate job and when packages change. The filter converts the client's budget (in their display currency) to EUR at today's rate. Approximate by nature, and the card then shows the exact price. |
| **BI dashboard** | Base currency EUR. **Each money line is stamped with its EUR value when the money moves** (`base_minor`, `base_rate`, `base_rate_source`): payments when they succeed, refunds when they settle, and so on. It uses the Stripe balance transaction's rate if Stripe converted, else the ECB rate of that London day. Instead of counting non-EUR lines and leaving them out (`other_currency_lines`), every line counts at its stamped EUR value, and the screen can split by currency. Reconciliation with Stripe is per currency, since the Stripe mirror reads every currency's balance. The Stripe mirror (`bi_stripe.py:104`) reads every currency. Manual costs take a currency and are converted at their date's rate. The `bi_*` views change, so this is a new migration and a frozen copy for `test_bi_schema`. |

---

## 6. Data model, API contract, versions, flag

### 6.1 Migrations (one per batch, each high-risk)

1. **Currencies on the photographer's money.** Add `currency CHAR(3) NOT NULL` to:
   - `pro_profile`;
   - `earnings_ledger_entry`, `earnings_balance_snapshot`, `earnings_hold`;
   - `payout_request`, `payout_allocation`.

   Backfill: every existing row is EUR (all money so far is EUR). The `_eur` columns are renamed to plain names (`gross`, `net`, `amount`, ...) at the same time. **No production database exists yet**, so this is the cheapest moment. Dev and the test fixtures follow.
2. **Rates and stamps.**
   - New table: `fx_rate`.
   - New columns: `base_minor`, `base_rate` and `base_rate_source` on `stripe_payment`, `ledger_entry`, `refund_case`, `price_reduction`, `extra_image_purchase` and `shelf_order`.
   - `stripe_balance_txn` gets `exchange_rate` and the original amount and currency.
   - Backfill: EUR rows get `base_minor = amount` and rate 1.
3. **Credit and RAWW per currency.**
   - `currency` on the reward ledger, the balance per (user, currency), budgets per currency.
   - RAWW values per currency, and the stamped currency on RAWW entries.
   - Backfill: EUR.
4. **Caps and display.**
   - `currency` in the price-cap and extra-image-policy unique keys.
   - `user_account.display_currency` (nullable).
   - `pro_public_index.min_package_price_base_minor`.
5. **BI views:** a new frozen copy (`bi_views.py`) reading `base_minor`, and a `bi_daily` rebuild with the backfill job (as for 0093 and 0094).

### 6.2 The API contract

- **Every money value travels as an amount string plus a currency.**
  - Money objects gain `currency`.
  - The `_eur` names go: `withdrawable_eur` becomes `withdrawable` beside `currency`, and the same for `amount_eur` and the rest.
  - Display-only conversions are never sent as money. Where the server adds one (emails, BI), it is labelled `approx_*` with `fx_as_of`.
- **New endpoints:**
  - `GET /v1/fx/rates` (`{base, rates: {GBP: "0.85123"}, as_of}`);
  - `PUT /v1/me/display-currency`;
  - the photographer's currency is read-only on their profile.
- **App versions.** **No beta build has shipped yet.** If batch M lands before batch 2 builds the first distributed app, the contract can change in place, with no compatibility fields and no versioned endpoints, which is the main reason to do M first. After that, a money-field rename would need the old names kept beside the new for one release, plus the minimum-app-version switch (batch 2).

### 6.3 The feature flag: `multi_currency_enabled` (default off)

Built dark: every path is currency-aware, but with the flag off only EUR can come into existence.

| Flag | Behaviour |
|---|---|
| **Off** | A Connect account for a GB photographer is refused, with "not available yet". A package in GBP is refused. The display-currency setting is hidden (the API answers EUR). `GET /v1/fx/rates` works, for testing. |
| **On** | GB photographers, GBP packages and display currencies are all allowed. |

It is an admin feature flag (the `feature_flags` table, as `client_browsing_enabled` is), so it switches on without a deploy. It is checked by one helper.

*Superseded 2026-11-13 (UK first):* the boolean becomes a per-currency setting, `enabled_currencies` (admin, no deploy), because GBP is now the main currency and EUR the one that may wait (10.1).

---

## 7. Build plan

### 7.1 Batches

About a day each unless noted; agent-days.

| Batch | What | Effort | High-risk |
|---|---|---|---|
| **M1. Currency on the photographer's money** | Migration 1; `pro_profile.currency` from the Connect country; packages refuse other currencies; the ledger, balance, holds, payouts and allocations carry it; `Transfer.create(currency=row.currency)`; minimums per currency; the "payout on its way" text; invoice fallbacks removed | 1.5 | **yes** (money, migration) |
| **M2. Contract and apps** | Every money response gets `currency`, and the `_eur` names are renamed; `RMoney` loses the EUR fallback (a missing currency is a bug); the four "€" literals go; payout requests in the account's currency; web admin `money()` everywhere; openapi regenerated | 1.5 | **yes** (money display, contract) |
| **M3. Rates and display** | `fx_rate`, the ECB job and staleness alert, `GET /v1/fx/rates`, `display_currency` (default from the locale, a setting screen in both apps), the labels in section 2.4 on every screen listed | 1.5 | no (display only) |
| **M4. Caps, discovery, credit, RAWW** | Caps keyed by currency, with the check fixed; the discovery base price and budget filter; credit and budget per currency; RAWW value per currency | 1.5 | **yes** (money, migrations) |
| **M5. BI stamps** | Migration 2's stamps written where money moves; the Stripe mirror for every currency; BI views and `bi_daily` rebuilt; costs with currency; the dashboard split by currency | 1 | **yes** (money recorded, migration) |
| **M6. Stripe GBP end to end (test mode)** | ~~Recipient~~ **Full** service agreement for cross-border accounts (superseded, 10.2); GB Express onboarding; GBP charge, refund and transfer run against Stripe test mode; the flag; docs (BI.md, DEPLOY_CHECKLIST, this file) | 1 | **yes** (money, Stripe) |

**Total: about 8 agent-days.** M6 needs Stripe's answers (section 3.3) before the live switch, not before the test-mode run.

### 7.2 Test plan

Hand-computed fixtures, written out in the tests, never computed by the code under test:

- **The same booking in both currencies.**
  - The fixture: €1,000.00 and £1,000.00, 10 photos, the standard fee policy.
  - Hand-computed for each currency:
    - the fee, the photographer's share and the RAWW credit;
    - the invoice lines;
    - balance pending to available to payout;
    - the transfer amount and currency.
  - The GBP case must give exactly the same digits, with £ and `gbp` everywhere.
- **A fixed display rate:**
  - **The rate:** 1 EUR = 0.85123 GBP.
  - **What is checked:**
    - €1,000.00 → "about £851";
    - €12.34 → "about £10.50" (1234 × 0.85123 = 1050.42 minor units, rounded to 1050);
    - £850.00 → "about €999" (85000 / 0.85123 = 99855.27, so 99855 minor units, shown as €999 whole);
    - a stale rate (5 days old) → no approximation and the "Charged in EUR" text;
    - no rate → the same.
- **Rounding at the half:**
  - **The rate:** chosen so `amount × rate` ends in exactly .5 minor units.
  - **What is checked:** it rounds up. A 3-way split leaves the remainder on the last part, and the parts sum to the total.
- **Refund in a second currency:**
  - **The setup:** a GBP booking with a partial price reduction to £600.00, and a refund of £400.00.
  - **What is checked:**
    - the refund case is in GBP;
    - the photographer's GBP earnings drop by the hand-computed amount;
    - RAWW reverse at the stamped GBP rate;
    - BI stamps the refund's EUR value at the refund day's rate, not the payment day's;
    - the payment's stamped base stays unchanged.
- **Mixed-currency refusals:**
  - a GBP package for a EUR photographer is refused;
  - a payout whose currency differs from the account's is refused;
  - client credit earned in EUR offers nothing on a GBP booking;
  - a GBP package with only EUR caps configured is refused with the named error.
- **BI:**
  - **The data:** a day with one EUR and one GBP payment.
  - **What is checked:** the totals equal the hand-computed EUR sum of the stamps; `other_currency_lines` is gone; changing today's rate changes nothing already stamped.
- **Flag off:** no GB account, no GBP package and no display setting can be created, and EUR flows are byte-identical to before (the existing money suites pass unchanged).
- **Stripe test mode (M6, by hand, recorded):** a GB Express account onboarded, a GBP charge, a GBP refund and a GBP transfer, each checked in the Stripe dashboard (currency, amount, and no conversion line).

### 7.3 Break checks (each must make a named test fail)

- `Transfer.create` back to `currency="eur"`: the GBP payout test fails.
- The cap lookup without the currency: the "£ against € cap" test fails.
- The display conversion with banker's rounding or a float: the rounding fixtures fail.
- BI reading `amount` instead of `base_minor`: the mixed-day totals fail.
- `RMoney` with the EUR fallback restored: the app test for a GBP balance fails (a balance without a currency must throw in debug).
- Credit applied across currencies: the credit-refusal test fails.
- The flag check removed: the flag-off tests fail.

---

## 8. Risks, and the owner's decisions

### Risks

1. **The platform holding GBP depends on Stripe.** If multi-currency settlement is not available for the PT account, GBP charges become EUR at Stripe's rate and the platform carries the difference until payout. **Mitigation:**
   - do not switch the flag on until Stripe confirms (question 1);
   - the fallback is destination charges with `on_behalf_of` the GB account, so the GBP settles in the photographer's account. That is a larger change to holds and refunds.
2. **Cross-border recipient accounts** may have limits (capabilities, payout timing) that change the photographer's experience (question 2).
3. **Refunds and disputes exceeding the GBP balance**, early on, when little GBP is held (question 4).
4. **A rename of every `_eur` field** touches about 120 code references across API, app and web. Tests and break checks catch misses, but it is a wide change, so it lands before any app is distributed.
5. **Rates:** a stale or wrong ECB rate only ever affects the approximation and BI stamps, never money. The staleness rule hides it rather than showing a wrong number.
6. **Clients misreading the approximation as the price.** Mitigated by the wording, and by never putting an approximation on a line that is paid. The lawyer confirms the wording.

### The owner's decisions (decided 2026-11-13)

| # | Question | Decision |
|---|---|---|
| M1 | Approve this design (option A)? | **Approved.** The currency comes from the Stripe account's country; nothing is converted on the money path. |
| M2 | Price caps per currency or per city? | **Per currency** (a GBP table and a EUR table); city overrides later. |
| M3 | Client credit: per currency, or one EUR wallet? | **Per currency**, and the monthly budget too; no conversion. |
| M4 | The GBP withdrawal minimum? | **£45.00.** |
| M5 | The RAWW value in GBP? | **Approved as recommended:** set with the EUR one when the Shelf opens; until then GBP earnings stamp RAWW at the ECB-converted EUR value of that day. |
| M6 | Batch M before batch 2 (the first distributed build)? | **Approved.** |
| M7 | Send the Stripe questions? | **Sent.** Stripe's chat answered (section 9); a written confirmation by a Stripe human is requested for cross-border payout eligibility, the accepted GBP bank accounts and the exact fees. |
| M8 | The display rate source? | **Approved:** the ECB daily reference rates, shown as "about". |
| M9 | A lost dispute that is the photographer's fault? | **Approved:** recovered in this order: the held earning, then their future earnings, then a transfer reversal only if the admin chooses, then written off after 90 days. Not their fault: the platform absorbs it. The photographer agreement must say this (lawyer, `BETA_SCOPE.md` 4.5). |
| M10 | Pass Stripe fees on to photographers? | **Never.** |
| M11 | The company: UK (X) or Portuguese (Y)? | ~~OPEN~~ **Decided 2026-11-16: a Portuguese company (Scenario Y), entity to be confirmed** (section 11.0). Scenario X is archived. |

**The Shelf stays OFF** (2026-11-13): it needs the terms and the RAWW expiry review first.

**Updates to section 8, 2026-11-13** (the text above is kept as the owner read it):
- Risk 1's fallback, "destination charges with `on_behalf_of`", is withdrawn: Stripe says `on_behalf_of` is not part of the compatible flow, and the design never uses it (10.2). If multi-currency settlement were refused, the fallback is a UK company (section 11, Scenario X), not a different charge type.
- Risk 2 (cross-border limits) and risk 3 (refunds and disputes above the GBP balance) now have Stripe's answers (section 9) and a rule (10.5).
- *2026-11-16:* with Scenario X archived (11.0), the fallback above is gone. If Stripe refused GBP settlement for the company's account, the options are in 11.6 (the owner's answer of 2026-11-17; a low risk).
- M2's GBP table comes first and is the default (UK first). M4's minimum is still the owner's. M5: the RAWW value is set in GBP first (11.3). M7 is done (questions sent; answers in section 9). New decisions M9 to M11 are in section 12.

---

## 9. Stripe answers (2026-11-13)

Given by Stripe support's chat to the owner on **2026-11-13**, for the platform account `[STRIPE PLATFORM ACCOUNT ID]` (Portugal). The chat reads as AI-generated: **every answer is indicative until a Stripe human confirms it in writing.** Where the owner asked for written confirmation, it says so. Recorded as stated.

| # | Question (3.3) | Stripe's answer, as stated | Status |
|---|---|---|---|
| 1 | GBP settlement | A Portuguese account can settle in GBP with **Multi-Currency Settlement**. GBP must be **enabled as a settlement currency** and a **GBP bank account linked** (in the UK or Gibraltar). Without it, GBP payments are converted to EUR. With it, a GBP balance forms when charges are presented in GBP. | Indicative |
| 2 | UK Express accounts | Yes, through **cross-border payouts** for EEA platforms with UK connected accounts, in **separate charges and transfers**. They do **not** work with the "recipient" service agreement: UK photographers need the **"full"** service agreement, and once accepted it **cannot be changed**. Eligibility for cross-border payouts is decided by Stripe. | Eligibility: **to be confirmed in writing by a Stripe human** |
| 3 | Transfers and payouts | Conversion happens only when the sender's balance currency differs from the receiver's. A GBP transfer from our GBP balance to a UK account with a GBP balance involves **no conversion**, and the UK account's payout to a UK bank stays in GBP. A transfer **fails** if our available GBP balance is insufficient; **`source_transaction` avoids that**. Cross-border payout fees depend on the recipient's location. | Indicative |
| 4 | Refunds and disputes | Refunds, disputes and fees are debited from the **platform** balance, **each currency separately**; Stripe never covers a negative in one currency with another. A refund on a low balance stays **pending**, is processed when funds arrive, and **fails with `insufficient_funds` after 45 days**. A disputed amount and its fee leave the platform balance, which **can go negative**; where supported, Stripe may debit the registered bank account within two business days. We can add funds to the GBP balance, or convert EUR to GBP with instant currency conversion (it has a fee). To recover from the photographer: a **transfer reversal**, which works only if their available balance covers it. | Indicative |
| 5 | Fees | UK cards are **international** cards for a Portuguese account: an international card fee is added to the standard fee. Settling in GBP (not our main currency) adds the **Multi-Currency Settlement fee**, charged at settlement. If Stripe converts to EUR instead, the conversion fee applies. Stripe fees come out of the platform balance and can be recovered by adjusting the transferred amount. Exact figures are on Stripe's pricing pages. | Figures: **to be confirmed in writing by a Stripe human** (asked) |
| 5b | `on_behalf_of` | **Not** part of the compatible flow. **Never use it.** | Indicative; the design follows it |
| 6 | One currency per connected account | No explicit rule. Each connected account settles in its country's default currency. Extra currencies through platform configuration need the account in the **same region** as the platform; a UK account under an EEA platform does not qualify. Cross-border payouts are described as local-currency payments, with no confirmation of payouts in another currency. | Indicative; the design rule is 10.3 |
| 7 | Platform agreement and profile | Nothing mandatory. To verify: Stripe decides cross-border eligibility; check the Connect settings and the platform profile; tax and reporting obligations in another country are ours. | Indicative |

### 9.1 Stripe Support, 2026-11-16

A written reply from **Stripe Support** on **2026-11-16**, on the same case as the earlier answers. Recorded as stated. Where it adds to or conflicts with section 9, the last column says so.

| # | Topic | Stripe Support's answer, as stated | Against section 9 |
|---|---|---|---|
| 1 | A GBP settlement account at **Wise or Revolut Business** (UK sort code and account number) | **Supported**, but such accounts **can see a higher rate of payout failures**. Stripe gave no specific technical cause and no recommended setup. A failed payout shows a **specific failure reason in the Dashboard** (from Stripe or from the bank). | **Adds** to #1 (which bank account may be linked). Risk carried into `DEPLOY_CHECKLIST.md` |
| 2 | **Connect fees** for our model (Express accounts, separate charges and transfers, "You handle pricing for your users"), **on top of** card processing and the cross-border payout fee | **EUR 2 per monthly active account**, charged only in months when a payout is sent to the account's bank account or debit card; **0.25% + EUR 0.10 per payout sent**, charged on total payouts at the end of the month; **0.25% of payout volume** for "funds routing and platform management". | **Adds** the figures #5 lacked; answers 10.4 point 7 in part (fees are per payout to the bank, not per transfer; whether transfers carry any fee: not stated) |

**Stripe's public Portugal Connect pricing page** (`https://stripe.com/en-pt/connect/pricing`, as read by the owner on 2026-11-16; prices on a public page can change) also lists: cross-border payouts **starting at 0.25%** of payout volume; instant payouts **1%**; account debits **1.4%**; ongoing risk monitoring **"varies"**, with no number; and, under payments, **UK cards at 2.5% + EUR 0.25**.

**Open discrepancy: the UK card fee.** An earlier Stripe Support answer (**2026-11-15**, as the owner relayed it; not recorded in this doc until 2026-11-16) gave **UK standard cards 1.5% + 20p** and **premium cards 2.8% + 20p**. The Portugal page shows **UK cards 2.5% + EUR 0.25**. The chat of 2026-11-13 (#5) said an international card fee is added to the standard fee. These do not agree. **Open** until Stripe answers question (d) below.

**Open questions, sent back to Stripe Support by the owner (2026-11-16). All OPEN:**

| | Question | Status |
|---|---|---|
| (a) | Do the three payout percentages all apply together: up to **0.75% of payout volume** (cross-border 0.25% + per payout 0.25% + funds routing 0.25%) plus EUR 0.10 per payout plus EUR 2 per active account? | **Open** |
| (b) | In which currency, and at which exchange rate, are the EUR 2 and EUR 0.10 fees charged for **GBP** accounts? Does the 1% Multi-Currency Settlement fee apply to them? | **Open** |
| (c) | The **risk monitoring** amount ("varies") | **Open** |
| (d) | **Which UK card fee applies** (1.5% + 20p and 2.8% + 20p, or 2.5% + EUR 0.25), and what decides standard versus premium | **Open** |
| (e) | UK platform Connect pricing, had the company been in the UK (for the record only; Scenario X is archived) | **Open** |
| | **Volume discounts** | **Open** |

---

## 10. What changes in the design

### 10.1 UK first: GBP is the default

- **New users** get `display_currency = GBP`. New photographers default to GBP until their Stripe account exists; then the account's country decides (10.3).
- **Every `default="EUR"`** (20 columns, 9 schemas; `BETA_SCOPE.md` #59) is removed, not switched to GBP: a missing currency is a bug and raises. Where a default is genuinely needed (the display currency, a new photographer before Connect), it is **GBP**.
- **`DEFAULT_CONNECT_COUNTRY`** stops defaulting to `PT`: the account is created in the photographer's profile country, and a profile without a country cannot start Connect. `notification_default_timezone` becomes `Europe/London` (same clock as Lisbon, so no behaviour changes).
- **`enabled_currencies`** (admin setting) replaces the `multi_currency_enabled` flag: a currency not in it cannot get a package, a Connect account or a display setting. The UK beta starts with `{GBP}`; EUR is added when the owner says so (11.4).
- The labels in 2.4 are written GBP-first: "about €1,180 · charged in £1,000".

### 10.2 UK connected accounts: the full service agreement, never `on_behalf_of`

- `stripe.Account.create` for a GB photographer passes `tos_acceptance={"service_agreement": "full"}`, with `country="GB"`, `type="express"`, `capabilities={"transfers": {"requested": True}}` (and, with the full agreement, whatever capabilities Stripe requires for it; checked in test mode).
- **New column `payout_account.stripe_service_agreement`** (`full` or `recipient`), written when the account is created and **never updated**: Stripe says it cannot change. A photographer whose account was created with the wrong one needs a new account (admin-only, as for a change of country, 2.1).
- A test asserts that no Stripe call anywhere in the code passes `on_behalf_of` (a source search in the test suite, plus a break check).

### 10.3 The pricing currency is the Stripe account's country's currency

- GB → GBP; a eurozone country → EUR. **No exceptions**, no override, no second currency per photographer.
- A country that is neither (Ireland is EUR, so it is fine; Switzerland or Sweden are not) is refused at Connect creation with "not available yet".
- Once the Connect account exists, `pro_profile.currency` is read from `account.default_currency` and checked against the rule; a mismatch raises a Sentry event and blocks packages until an admin looks.

### 10.4 Every transfer uses `source_transaction`

**Today** (`services/payouts.py:636-666, 496-500`): a photographer asks for a payout (at least €50, at most 2 a week); the admin approves; `_allocate_payout_amount` spreads it over the oldest **available** earnings entries (FIFO, partial entries allowed, `payout_allocation`); one `Transfer` for the total, no `source_transaction`. An entry becomes available `settlement_delay_days` (7) after delivery is accepted; a hold (`earnings_hold`: dispute, refund risk, compliance, a client's problem report) keeps it out of "available" until released. The charge id is **not stored** (only the PaymentIntent id).

**`source_transaction` rules (Stripe's documented behaviour, to check in test mode):** one transfer is funded by one charge; the transfers from a charge add up to at most its amount; the transfer is in the charge's currency; it can be created while the charge's funds are still pending, and the connected account receives them when they become available.

**What must change (batch M7):**
1. **Store the charge:** `stripe_payment.stripe_charge_id` (the PaymentIntent's `latest_charge`), written by the payment webhook; backfilled from Stripe for existing rows.
2. **Tie each earning to its payment:** `earnings_ledger_entry.stripe_payment_id`. A booking can have several payments (the booking, extras, add-ons); each earning comes from exactly one. Earnings with no payment behind them (an admin adjustment) are transferred without `source_transaction`, only when the available balance in that currency covers them, else they wait and the admin is told.
3. **One transfer per payment, not per payout:** the payout request keeps its allocations; execution groups them by payment and creates one transfer each, with `source_transaction=<charge id>` and the idempotency key `payout-transfer:<payout id>:<payment id>`. New table `payout_transfer` (payout request, payment, amount, currency, Stripe transfer id, status). The payout is `paid` when all its transfers are; a failed one is retried alone.
4. **The invariant, checked before each transfer:** the sum transferred from a charge ≤ the charge's amount minus what was refunded from it. The photographer's net (80%) is always below the charge, even with the 10% maximum client credit (90%), so this holds by construction; a breach is a bug and stops the payout.
5. **Timing:** the 7-day settlement and the holds stay as they are, in our ledger, **before** allocation; `source_transaction` changes nothing about when an entry is available. It only means a transfer never fails for lack of balance: if the charge's funds are still pending at Stripe (possible right after a short settlement delay), the photographer's account receives them when Stripe releases them. The app says "on its way" either way.
6. **Refunds and disputes after a payout** become exact: the transfer funded by that booking's charge is the one to reverse (10.5).
7. The minimum and the 2-a-week limit stay on the request. Many small bookings mean many transfers per payout. Cross-border payout fees depend on the recipient (9, #3); whether any fee is per transfer or per bank payout is part of the fee figures asked from Stripe in writing.

### 10.5 Platform balances per currency: monitoring, low balance, refunds and disputes

- **Monitoring:** the hourly BI job already reads Stripe's balance (`bi_stripe.py`); it reads **every currency** (today EUR only). New settings: `stripe_balance_floor_gbp` and `_eur`. An alert (Sentry, and the in-app admin alert used for failed emails, at most once an hour) fires when a currency's available balance falls below its floor, **or** below what is due out of it in the next 7 days (approved payouts not yet transferred + pending refunds + open client-owed items in that currency).
- **A refund on a low balance:** it is still created (the client's refund is never held back by us). Stripe keeps it pending; our refund case shows `pending_funds`, and a money-attention item "Refund waiting for GBP funds" opens at once, with the 45-day deadline. The admin tops the GBP balance up by bank transfer, or converts EUR to GBP with Stripe's instant conversion (its fee is recorded as a cost in BI). A second alert fires at day 3 and a third at day 30.
- **A dispute:** Stripe takes the amount and its fee from that currency's balance, which may go negative (and Stripe may debit the bank). The booking's earnings get a `dispute_open` hold, as today. What happens to the photographer when it is lost:
  - **Not the photographer's fault** (the beta policy, `DEPLOY_CHECKLIST.md` "Chargebacks"): the platform absorbs it. BI shows it as "chargebacks lost".
  - **The photographer's fault** (an admin finding on the booking), in this order:
    1. **Not yet transferred:** the held earning is reversed. This is the usual case, because the hold starts with the dispute and a dispute usually comes within the settlement window.
    2. **Already transferred:** a negative entry on their ledger, taken from their **future earnings** before the next payout, with a notice to them.
    3. **A transfer reversal**, only if the admin chooses it and their Stripe balance covers it (Stripe: it fails otherwise). `source_transaction` makes it exact: the transfer funded by that charge.
    4. **Nothing recovered after 90 days:** written off as absorbed.
  - Which of these the beta uses is decision M9.
- **Design constraint for M8 (2026-11-16): never rely on Stripe account debits** (debiting a connected account; 1.4% of the debit volume on the Portugal pricing page, 9.1). Dispute and refund recovery uses **transfer reversals and our own ledger and holds** only. The plan above already keeps to this: steps 1, 2 and 4 are our ledger and holds, step 3 is a transfer reversal; no step debits a photographer's account, and nothing in the code calls an account debit. Note for M8: a reversal works only while the photographer's Stripe balance covers it (9, #4), and an Express account pays its balance out to the bank, so after their bank payout a reversal will usually fail; the ledger steps are the real recovery. (Stripe debiting **the platform's own** bank account for a negative platform balance, 9 #4, is a different thing and not an account debit.)

### 10.6 Card and settlement fees are real costs: BI

- **Where they appear:** the international card fee is part of each charge's Stripe fee (its balance transaction `fee`, itemised in `fee_details`). The Multi-Currency Settlement fee is charged at settlement: it may be part of that fee or a separate balance transaction; test mode cannot show live fees (3.4), so the first live GBP charge is checked by hand and the mirror reads both forms. Instant conversions and cross-border payout fees are their own balance transactions.
- **Change:** the mirror reads every currency and every fee type; each fee is stamped with its base value (as in 4.3). The dashboard's "Stripe fees" line splits into *card fees*, *settlement and conversion fees*, *payout and Connect fees*, per currency.
- **Per booking:** the booking's own fee is its charge's balance transaction fee (now that the charge id is stored, 10.4). New view `bi_booking_contribution`: retained − that booking's Stripe fees − its share of the settlement fee, so a GBP booking's lower contribution is visible, not averaged away.
- **Effect on contribution per booking.** Illustrative only: these are **not Stripe's figures**, which the owner has asked for in writing. A £200 booking, fee 20% (£40), retained 15% (**£30**), RAWW 5% (£10):

| Setup | Assumed fees on the £200 charge | Stripe fees | Contribution | Share of retained lost |
|---|---|---|---|---|
| UK card, UK company (Scenario X) | 1.5% + £0.20 | £3.20 | **£26.80** | 11% |
| UK card, PT company, GBP settled (Scenario Y) | 1.5% + £0.25, + 2.0% international, + 1.0% settlement | £9.25 | **£20.75** | 31% |
| UK card, PT company, converted to EUR | 1.5% + £0.25, + 2.0% international, + 2.0% conversion | £11.25 | **£18.75** | 38% |

  *Superseded 2026-11-16 by the cost model in 10.9* (Stripe Support's Connect fees, 9.1). The real figures replace these in BI.md when Stripe confirms them. Recovering fees "by adjusting the transferred amount" (Stripe, #5) would charge the photographer; the design does not do it, and it is decision M10.

### 10.7 BI: the liquid view and money owed per currency

- `owed()` (`services/bi.py:633`) today reads EUR only (`bi_client_owed WHERE currency = 'EUR'`, the EUR Stripe balance). Every line becomes per currency: photographers owed (pending, held, due), clients owed, RAWW outstanding, client credit, company cash, Stripe available and pending.
- **Liquid, per currency** = Stripe available + pending + company cash − photographers owed − clients owed, in that currency. A negative in one currency is shown as such, never netted with the other, as Stripe does (9, #4).
- A total in the base currency is shown below, labelled "approximate, at today's rate".

### 10.8 The GBP settlement account in the plans

Added to `DEPLOY_CHECKLIST.md` (GBP at Stripe) and to `BETA_SCOPE.md` 4.5 (Stripe, accountant and lawyer lists): enable GBP settlement and link a GBP bank account before the first GBP booking; written confirmation of cross-border eligibility and fees; the full agreement for UK photographers.

### 10.9 Cost model for one booking (2026-11-16)

**What it answers:** what the platform keeps from a **£200 booking** after Stripe's fees, in Scenario Y (the plan) and Scenario X (archived, a comparison only), for a photographer with 1, 2, 4 or 8 bookings a month. Computed in code with exact decimals (`Decimal`, rounded half up to the penny only at the end), not by hand; the script lives outside the repo, in the owner's scratch folder.

**The booking:** the client pays **£200 (B)**. The fee is 20% (£40); the photographer's RAWW credit is 5% (£10), so the platform **keeps £30 (R)** before Stripe, and the photographer is **paid £160 in cash (P)**. The £10 RAWW are a liability, not cash out today, and are left out.

**The formula** (all in pounds; *n* = bookings per photographer per month, each paid out on its own):

    Stripe cost per booking = card + s × B + c × P + (q × P + f × r) + g × P + (a × r) / n
    platform keeps         = R − Stripe cost per booking

| Symbol | Meaning | Value used | Label |
|---|---|---|---|
| card | UK card processing on B | 1.5% × B + £0.20 = **£3.20** (standard). Premium: 2.8% × B + £0.20 = £5.80, **£2.60 more** | **Assumed** (Stripe Support, 2026-11-15); **open** discrepancy with 2.5% + EUR 0.25 (9.1, d) |
| s | Multi-Currency Settlement fee, on the booking | **1%** of B = £2.00 (Y); 0 (X) | **Assumed** |
| c | Cross-border payout fee, on the payout | **0.25%** of P = £0.40 (Y); 0 (X) | "Starting at 0.25%" on the PT page; the rate for UK: **assumed** |
| q, f | Connect: per payout sent | **0.25%** of P = £0.40, plus **EUR 0.10** = £0.087 | **Stated by Stripe Support** (9.1); the currency and rate of the EUR part: **open** (b) |
| g | Connect: funds routing and platform management | **0.25%** of P = £0.40 | **Stated by Stripe Support** (9.1); that it applies with q and c: **assumed**, **open** (a) |
| a | Connect: monthly active account | **EUR 2** = £1.74, once a month per photographer paid that month, spread over *n* bookings | **Stated by Stripe Support** (9.1); currency: **open** (b) |
| r | Exchange rate | **EUR 1 = GBP 0.87** | **Assumed** |
| — | Risk monitoring | **not included** ("varies") | **Open** (c) |

So, per booking, Y costs **£6.487 + £1.74 / n** and X **£4.087 + £1.74 / n**. Scenario X assumes UK Connect fees of the same structure and no settlement or cross-border fee: an **assumption only** (e).

**Result** (what the platform keeps of its £30, standard UK card):

| Bookings a month (*n*) | Y: Stripe cost | **Y: keeps** | X (archived): Stripe cost | X: keeps |
|---|---|---|---|---|
| 1 | £8.2270 | **£21.77** | £5.8270 | £24.17 |
| 2 | £7.3570 | **£22.64** | £4.9570 | £25.04 |
| 4 | £6.9220 | **£23.08** | £4.5220 | £25.48 |
| 8 | £6.7045 | **£23.30** | £4.3045 | £25.70 |

The owner's own figures (2026-11-16: Y 21.76, 22.64, 23.07, 23.29; X 24.16, 25.04, 25.47, 25.69) agree to within a penny; the exact values are above, and the differences are rounding only.

**How much the open questions move it** (Y, what the platform keeps):

| *n* | Standard card (as above) | Premium card (2.8% + 20p) | The PT page's UK card rate (2.5% + EUR 0.25) | Only one payout percentage applies (no routing, no separate cross-border) |
|---|---|---|---|---|
| 1 | £21.77 | £19.17 | £19.76 | £22.57 |
| 2 | £22.64 | £20.04 | £20.63 | £23.44 |
| 4 | £23.08 | £20.48 | £21.06 | £23.88 |
| 8 | £23.30 | £20.70 | £21.28 | £24.10 |

**If the Portugal pricing page's UK card rate applies** (2.5% + EUR 0.25 = £5.2175 instead of £3.20): the Portuguese-company figures fall by about **£2.02 per booking** (£2.0175), to **£19.76, £20.63, £21.06 and £21.28** for 1, 2, 4 and 8 bookings a month (the fourth column above).

**Not included:** VAT on Stripe's fees (the accountant), dispute fees and lost chargebacks, refunds, Radar, instant payouts, client credit (a marketing cost in BI), and the risk-monitoring fee. Fewer bank payouts per photographer (a weekly payout schedule) would lower the per-payout parts; the monthly EUR 2 is the largest part at low *n*.

**To redo it when Stripe answers:** change the values in the table of symbols and recompute the two lines of the formula.

**Where Stripe or Connect fee assumptions live** (to update once the real figures are confirmed; nothing in the code or settings holds a Stripe fee figure, since BI reads Stripe's real fees from its balance transactions):

1. This file: the illustrative table in 10.6 (superseded by this section); 10.4 point 7 (fee per transfer or per payout: per payout to the bank, 9.1; whether transfers carry any fee: open); the "UK card fee" and "Settlement fee on GBP" rows of 11.3 (names, no figures).
2. `BI.md`, "Stripe fees": counts Stripe's own fees billed as separate transactions (Connect among them). The monthly Connect fees are charged at month end, not per charge, so they cannot be tied to one booking: M9's per-booking contribution must spread them or show them apart.
3. `api/app/services/bi.py` (line 97): the mirror stores Stripe's balance transactions in every currency (`bi_stripe.py:77`), but BI sums only the EUR ones (and `bi_stripe.py:103-107` reads only the EUR balance). Connect fees charged in EUR are counted; any charged in GBP are not, until M5.
4. `api/app/services/bi.py` (line 623): the line text "We store no fees of our own: Stripe is the only source." Still true; no figure.
5. `api/scripts/seed_bi_demo.py` (dev demo only): fees of 1.5% + 0.25 per charge (lines 11, 168) and a 15.00 dispute fee (line 289). Not real; update only if the demo should look like the UK figures.
6. `DEPLOY_CHECKLIST.md`: "Chargebacks" (Stripe's dispute fee, EUR 20 seen in test mode, not a live figure) and "GBP at Stripe" (the written fee confirmations).
7. `BETA_SCOPE.md` 4.5: the Stripe and accountant bullets (fee figures, costs).
8. The web admin's BI screens (`web/app/admin/bi/`): the label "Stripe fees" only, no figures. The Costs page's categories (`api/app/models/bi.py:32`: ad spend, marketing, salaries, software, legal, office, other) have no Stripe category, which is right while Stripe's fees come from the mirror.
9. Not Stripe fees, but the £30 above depends on them: the platform fee policy (`fee_percent_gigs` 20, retained 15, RAWW 5: `api/app/models/payouts.py:295-303`, `api/app/models/bi_views.py:24`).

---

## 11. Company scenarios

### 11.0 The decision (2026-11-16)

**Decision M11 (the owner's, 2026-11-16): the company behind RAWWERS is a Portuguese company. Scenario Y is the plan; Scenario X is archived.**

- **Why:** the company's tax is paid in Portugal, and photographers pay their own tax wherever they live. A UK company was ruled out for tax-residence and banking reasons, on the UK accountants' advice. (This doc draws no legal conclusion from it.)
- **Which Portuguese company is not decided:** **"Portuguese company, entity to be confirmed."** The owner decides the entity after talking to a Portuguese accountant. No doc, setting or text may name an entity until then; placeholders are listed in [COMPANY_DETAILS_NEEDED.md](COMPANY_DETAILS_NEEDED.md).
- **What follows at once:** the books and the BI base currency are EUR (2.3, 11.5); UK photographers are cross-border connected accounts on the full service agreement (9, #2; 10.2); GBP needs Multi-Currency Settlement and a GBP settlement account in the company's name (9, #1).
- **What does not change:** UK first, GBP the default (10.1); batches M1, M2, M3, M4 and M7 as built; M5, M8 and M9 as designed (11.4).

**Scenario X (ARCHIVED 2026-11-16, not chosen):** the platform is a **UK company** with a **UK Stripe account**. GBP is native; UK photographers are domestic connected accounts; UK cards are domestic; EUR is the foreign currency. Kept below as a comparison only.
**Scenario Y (the plan):** the platform is a **Portuguese company** with a **Portuguese Stripe account**: the design above.

### 11.1 Charges and payouts

| | X: UK company (archived) | Y: Portuguese company (the plan) |
|---|---|---|
| Charge model | Separate charges and transfers, as today | The same |
| GBP | Native: GBP charges settle in GBP with no extra setup or fee | Needs Multi-Currency Settlement and a GBP bank account (9, #1) |
| UK photographers | **Domestic** Express accounts: no cross-border payout | **Cross-border**, full agreement, Stripe decides eligibility (9, #2) |
| EUR photographers | Cross-border from a UK platform to the EEA: needs EUR settlement and Stripe's rules for that direction | Domestic in the EEA |
| `source_transaction` | Recommended (same code) | Required in practice (a short GBP balance fails transfers) |
| `on_behalf_of` | Not used | Never used (9, #5b) |

### 11.2 Stripe questions that still matter

- **X (archived 2026-11-16):** most answers in section 9 become moot for GBP. To ask again **only when EUR is switched on**: EUR settlement on a UK account; cross-border payouts from a UK platform to EEA photographers (agreement type, eligibility); EU cards' fees on a UK account; the same refund and dispute rules for the EUR balance.
- **Y (the plan):** all of section 9 stands; the written confirmations still owed are cross-border eligibility (#2) and the fee figures (#5). *2026-11-16:* also whether the existing Stripe platform account moves to the company or a new one is opened (the owner asks Stripe), and the open fee questions of 9.1.

### 11.3 Fees, currencies and settings

| | X: UK company (archived) | Y: Portuguese company (the plan) |
|---|---|---|
| UK card fee | Domestic rate | International rate (standard + international fee) |
| Settlement fee on GBP | None | Multi-Currency Settlement fee |
| EUR (when on) | EU cards international on a UK account; EUR settlement fee | Native |
| Can EUR ship switched off? | **Yes, completely**: no EUR settlement account or EUR questions until the owner switches it on | **Yes in the code** (`enabled_currencies = {GBP}`), though EUR is the company's own currency and costs nothing extra to switch on |
| RAWW valuation | Set in GBP (`raww_value_gbp`); the Shelf is GBP, so nothing converts | Set in both; the books value RAWW in EUR at the stamped rate |
| Client credit | Per currency (M3), GBP first | Per currency |
| Monthly credit budget | One figure per currency, GBP first | The same |
| Price caps | GBP table first, EUR when switched on | Both tables before their currency is enabled |
| Withdrawal minimum | GBP (M4) first | Both |
| BI base currency | **GBP** (the books) | **EUR** (the books) |
| VAT on the fee | UK VAT: registration at £90,000, voluntary below; EU photographers need the accountant (B2B reverse charge, or EU VAT for unregistered ones) | UK VAT as a non-established taxable person, **no threshold**, for UK-taxable supplies; Portuguese VAT for EU ones; the accountant decides the place of supply |
| Data protection | ICO fee; an **EU** representative if EU photographers are served | A **UK** representative (UK GDPR Art. 27) |

### 11.4 Which batches are the same in both

| Batch | Same in X and Y? | Why |
|---|---|---|
| **M1** currency on the photographer's money (GBP default) | **Same** | Pure data model and ledger; no Stripe account difference |
| **M2** contract and apps | **Same** | Currency on every amount, the `_eur` names go |
| **M7** `source_transaction`, per-payment transfers, the charge id | **Same** | Same code in both; required in Y, good practice in X |
| **M4** caps, discovery, credit, RAWW per currency | **Same** | Per-currency tables and values; which currency is set first is data, not code |
| **M3** rates and display | **Same** if rates are stored both ways | ECB rates are EUR-based; GBP-based display uses the inverse at full precision (4.1) |
| **M5** BI stamps | **Same** if the base currency is a setting (`bi_base_currency`) | Only the setting's value depends on the company |
| **M8** balance monitoring per currency, low-balance rule, dispute recovery | **Same** monitoring; the recovery rule waits for M9 | Stripe's per-currency balance rules are the same in both (to confirm for X) |
| **M9** BI fees per booking, liquid and owed per currency | **Same** mechanism | The fee figures differ, but they come from Stripe's data |
| **M6** Stripe end to end: the service agreement, eligibility, the live switch | **Depends** on the company and on Stripe's written answers | X: domestic UK accounts, no settlement setup. Y: cross-border, full agreement, GBP settlement account. *2026-11-16: Y is the plan; what M6 waits for is in section 12.* |

### 11.5 Books and BI (2026-11-16)

- **The company's books are in euros.** Pounds held (the GBP balance at Stripe and the GBP settlement account) are revalued in the books; how and when (which rate, at which dates) is **the accountant's to say, to be confirmed**. Nothing in the code does this revaluation, and BI is not the books.
- **What the BI design already does** (section 5, BI row; 10.6; 10.7; batches M5 and M9, not built):
  - every money line is stamped with its euro value **when the money moves** (`base_minor`, `base_rate`); BI totals are sums of those stamps, so they never move with today's rate;
  - the liquid view and money owed are **per currency**, never netted across currencies, with one euro total below, **labelled "approximate, at today's rate", for display only** (10.7);
  - fees are split per currency (10.6).
- **What it does not say yet:** the profit-and-loss lines (GMV, retained fee, Stripe fees, contribution) are designed as **stamped euros**, and the per-currency split there is optional ("the screen can split by currency", section 5). To match the books note above, M5 should show those lines **per currency (GBP, EUR)** with the stamped-euro total beside them, not instead of them. Recorded here for M5; not built.
- **Today (built):** BI counts euros only and leaves other lines out (`other_currency_lines`); that stays until M5.

### 11.6 Risk: Stripe refuses GBP settlement for the company's account (2026-11-17)

**A low risk, recorded as one.** Stripe has already said a Portuguese platform account can settle in GBP with Multi-Currency Settlement and a linked GBP account (9, #1); the open point is the specific account and bank, not eligibility. Nothing below is built; the options are the owner's (2026-11-17):

- **(a) Another UK sort-code account provider,** if Wise or Revolut Business fails (refused by Stripe, or too many failed payouts, 9.1). Which providers open a GBP account for a non-UK company: to be confirmed. Nothing in the design changes.
- **(b) Settle in euros and accept a conversion cost.** Stripe then converts every GBP charge to EUR at settlement, with its conversion fee (9, #1 and #5; the figure is not confirmed). What changes:
  - **GBP transfers to UK photographers:** the platform holds EUR but owes pounds. A GBP transfer from a EUR balance is converted again when it is sent (9, #3: conversion happens when the sender's balance currency differs), with a second conversion fee, and the rate can move between the charge and the payout. That is the exchange-rate risk the requirement forbids (option A: "the platform takes no exchange-rate risk"), so this option breaks the requirement and would need the owner's decision. Whether `source_transaction` (M7) still works with a charge settled in EUR and a GBP transfer: to be checked with Stripe. Refunds and disputes in GBP would also be paid from the EUR balance with a conversion.
  - **The model in 10.9:** *s* (1% settlement on B) is replaced by the conversion fee on B, plus a conversion fee on P for each transfer, plus a rate risk the model does not price. The cross-border and Connect parts stay. With conversion fees at or above 1%, the platform keeps less than the 10.9 figures.
- **(c) Revisit a UK entity with the accountants.** Scenario X (archived) is the comparison; it reopens decision M11.

---

## 12. Build order (2026-11-13) and new decisions

**Order**, GBP the default throughout; every batch is high-risk except M3 and M9, which are display and reporting:

1. **M1** currency on the photographer's money (1.5 days)
2. **M2** contract and apps (1.5)
3. **M7** `source_transaction` and per-payment transfers (1.5)
4. **M4** caps, discovery, credit, RAWW (1.5)
5. **M3** rates and display (1.5)
6. **M5** BI stamps, base currency a setting (1)
7. **M8** balances per currency, alerts, the low-balance and dispute rules (1); recovery never uses Stripe account debits (10.5, 2026-11-16); low-balance and failed-payout alerts must exist before real money (`DEPLOY_CHECKLIST.md`)
8. **M9** BI fees per booking, liquid and owed per currency (1)
9. **M6** Stripe end to end, **after** the company decision and Stripe's written answers (1). *2026-11-16:* the company decision is made (Portuguese, 11.0). M6 still waits for **all** of:
   1. **the company entity confirmed** (which Portuguese company; the owner, after a Portuguese accountant);
   2. **the Stripe platform account under that company** (the owner asks Stripe whether the existing account moves or a new one is opened; a new account means new keys, webhook secrets and Connect settings, see [COMPANY_DETAILS_NEEDED.md](COMPANY_DETAILS_NEEDED.md));
   3. **the full service agreement for UK connected accounts** (9, #2; 10.2), with Stripe's written confirmation of cross-border eligibility;
   4. **a GBP settlement account in the company's name** (Wise or Revolut Business; UK sort code and account number), linked for Multi-Currency Settlement (9, #1; such accounts can see more payout failures, 9.1);
   5. **Stripe's answers to the open fee questions** (9.1).

**Total: about 11.5 agent-days** (8 before, plus M7, M8 and M9). Batches 1 to 8 can start once the owner approves the design; M6 waits.

**Decisions M9 to M11:** decided 2026-11-13; M11 decided 2026-11-16 (Portuguese company, entity to be confirmed); see section 8.

---

## 13. Build log

### M1: currency on the photographer's money (built 2026-11-13, high-risk: money, migration)

- **Settings:** `currency_settings` (one row; with none, the code's defaults: **GBP only**, withdrawal minimums GBP 45.00 and EUR 50.00), read and changed by `GET/PUT /v1/admin/finance/currency-settings` (audited). `DEFAULT_CURRENCY` (env, default `GBP`) is the currency of a photographer whose country gives none. `app/services/currencies.py` holds the rules.
- **The photographer's currency:** `pro_profile.currency`, set at creation from the country (GB → GBP, eurozone → EUR, else the default); follows a change of country only while no package, earning or payout exists; set from the country of the Stripe account when the Connect account is created. A Connect account in a currency that is not enabled (`currency_not_enabled`), in a country with no supported currency (`country_not_supported`), or in a currency other than the one their money is already in (`currency_mismatch`, 409) is refused before Stripe is called.
- **Packages** are always in the photographer's currency (a different one in the request: 422 `currency_mismatch`), and only while it is enabled (422 `currency_not_enabled`). Existing packages, bookings and payouts in a disabled currency keep working.
- **Earnings, balance, holds, payout requests and allocations** carry `currency`; the `_eur` columns and fields are renamed (`gross`, `platform_fee`, `net`, `pro_raww`, `pending`, `available`, `held`, `amount`, `withdrawable`, ...). An earning in a currency other than the photographer's is refused (409); the balance counts the photographer's currency only; allocation takes earnings of the payout's currency only; the transfer is `Transfer.create(currency=<payout currency>)`, and a payout whose currency is not the photographer's is failed, never sent. The minimum is per currency. "Payout on its way" says £ or €.
- **EUR defaults removed** from `pro_package`, `gig` and `dispute` (model and database), and the `or "EUR"` fallbacks on the live money path (invoices, disputes, reviews, galleries, selection quote and add-ons, refund reconciliation). A missing currency raises.
- **BI:** `bi_earnings` and `bi_payouts` carry the currency; photographer cash and paid payouts count EUR only (as every other BI line does until M5).
- **Migration** `20261113_0095`; downgrade refuses while any of those rows is not EUR.
- **Tests:** `tests/test_currency_money.py` (30). The suite was written in euros, so `tests/conftest.py` runs it with EUR enabled and EUR as the default (`_currencies_of_the_suite`); a test about the production defaults marks itself `uk_defaults`.

**Not as the design said, and why:**
- The **API's payout field names** changed in M1, not M2: the model attributes are the response fields. The web admin's payout queue follows in the same commit; the apps' generated client follows in M2 (no app is distributed).
- **EUR defaults left for their batches:** price caps, the extra-image price policy and per-photographer extra prices, and `pro_public_index` (M4); BI tables (M5); dormant tables (store, prints, learning, Studioverse, repairs) stay EUR-only, as section 1.1 says.
- **Left for M6** (Stripe-dependent): `DEFAULT_CONNECT_COUNTRY` still falls back to `PT` (a PT account is refused while EUR is off), the full service agreement and its column.
- **Not yet done from 10.1:** the default time zone `Europe/London` (no behaviour changes; with M3).

### M2: contract and apps (built 2026-11-14, high-risk: money display, contract)

- **API:** every money value in a live response carries its currency, and no amount is named `_eur` (tests/test_currency_contract.py walks every response model of every live route and fails on either). Renamed with a `currency` beside them: the client's payment (`credit`, `amount`), the credit balance, history and checkout preview (`balance` with `credit_currency`; `discount`, `price`, `total` in the booking's `currency`), the marketing-credit budget (`budget`, `awarded`, `used`, `returned_on_refunds`, `outstanding`, `remaining`), the marketing consent credit (`credit_amount`). `currency` added to the selection submit, the add-on and legacy payment intents, a gig's ledger summary, the earnings summary and the photographer's profile (read-only). The balance carries the withdrawal minimum (`payout_minimum`), so the app no longer copies it.
- **Client credit is in euros and pays for euro bookings only** (decision M3, ahead of M4): `reserve_points_for_discount` refuses another currency (`credit_currency_mismatch`), and the preview and the pay route offer no credit on a booking in pounds.
- **A dispute is in its booking's currency**; the request no longer chooses it. The admin's photographer row shows the photographer's currency, not a EUR default.
- **Emails:** a money line without a currency is left out, never shown as euros.
- **Apps:** the API client regenerated from the schema (`make gen-api`); `RMoney` has no fallback (the currency is a required argument, so an amount without one does not compile); the four "€" literals are gone (the discover card and credit labels take the currency; the RAWW card and Shelf levels say EUR explicitly, as RAWW are valued in euros until M4); payout requests and the wallet use the balance's currency and minimum; packages are created without a currency (the server sets the photographer's).
- **Web admin:** `money()` requires a currency; the payout queue, disputes and client credit pass the one the API sends; the Shelf pages pass EUR explicitly (`SHELF_VALUE_CURRENCY`).

**Not as the design said, and why:**
- The regenerated API client also picked up routes the committed client was missing (the email unsubscribe client and models, reordered gallery, review and notification clients): the client had not been regenerated since those routes were added. Nothing in the app uses them yet.
- **Left as named per currency** (the suffix names the currency a setting is for; a `_gbp` twin comes with M4): `monthly_marketing_credit_budget_eur`, `min_conversion_value_eur`, `raww_eur_value`, `gbp_eur_rate`. The Shelf's amounts (off) and BI's cents (EUR by design) are M4 and M5.
- **Known gap until M4: client credit earned on a booking in pounds** is still counted in euro points. Per-currency credit is M4, which comes before any app is distributed. It is a gate item in `BETA_SCOPE.md` (#60): it must be fixed before the beta (owner, 2026-11-14). *Fixed in M4 (2026-11-14).*
- **The client's budget filter** (`ClientPreferenceView.budget_min/max`) has no currency yet: it is the display currency, batch M3.

### The owner's decisions of 2026-11-15 (answers to the M7, M4 and M3 report)

- **The monthly marketing budget in pounds stays at £300.00** (`monthly_marketing_credit_budget_gbp`, the default M4 set; an admin setting, adjustable).
- **`raww_gbp_value` stays unset until the Shelf opens.** Pound bookings keep valuing RAWW at the day's euro value converted at the ECB rate (decision M5's fallback, built in M3).
- **The pound price caps** are proposed in [PRICE_CAPS.md](PRICE_CAPS.md) (the euro caps at the ECB rate of 2026-11-13, rounded) for the owner to correct. They are on dev only. Production is loaded from the same files through the admin, once they are confirmed.

### M7: one transfer per client payment, from its charge (built 2026-11-14, high-risk: money, migration)

- **The charge is stored:** `stripe_payment.stripe_charge_id`, written by the payment webhook from the PaymentIntent's `latest_charge`. Payments from before have none; the first payout that needs one reads it from Stripe once and keeps it (no backfill job to run).
- **Each earning is tied to its payment:** `earnings_ledger_entry.stripe_payment_id` (a booking's first base payment; an add-on's own payment), backfilled by the migration.
- **One transfer per payment** (`app/services/payout_transfers.py`, table `payout_transfer`): at execution the payout's allocations are grouped by the payment behind each earning, and each group is one `Transfer` with `source_transaction=<charge>`, `transfer_group=payout:<id>` and the idempotency key `payout-transfer:<payout id>:<payment id>`. The payout is paid when all its transfers are.
- **The invariant** is checked when the transfers are planned and again before each is sent: what is sent from a charge never exceeds its amount less what was refunded. A breach is a bug: nothing (more) is sent and Sentry gets "Payout transfer invariant breach".
- **A failed transfer is retried alone:** while part of a payout has gone (or waits for funds), it stays `processing`, so its money stays reserved and cannot be asked for twice; nothing of it went, it fails as before. The admin's **Retry transfers** (`POST /v1/admin/payouts/{id}/retry-transfers`, audited; a button on the web admin's payout queue) sends only the failed or waiting ones, first checking with Stripe (`Transfer.list` by `transfer_group`) that a "failed" one did not in fact go (a timeout), then under a new idempotency key (`...:retry<n>`), since Stripe keeps an error under the old key for a day.
- **The webhooks, per transfer:** `transfer.created` confirms that transfer, and the payout only when all are; `transfer.reversed` marks that transfer reversed, and fails the payout only if nothing of it remains sent (otherwise it stays `processing` for the admin).
- **Tests:** `tests/test_payout_transfers.py` (16), with the hand-computed amounts in its header.

**Not as the design said, and why:**
- **"Each earning comes from exactly one payment"** does not hold for a booking: a booking can be paid by its base payment and a difference payment (a larger selection). Its earning stores the base payment, and its transfer draws on the base charge first, then the difference charge, each within what is left of it (a £150.00 booking paid £100.00 + £50.00 earns £120.00: £100.00 from the first charge, £20.00 from the second). Add-ons have exactly one payment.
- **Earnings with no payment of ours behind them** are the legacy gallery upsell (its own PaymentIntent, not a `stripe_payment` row) and Studioverse (dormant). They are sent without `source_transaction` only when Stripe's available balance in that currency covers them (`Balance.retrieve`); otherwise the transfer waits (`waiting_funds`), the payout stays `processing`, Sentry gets "Payout waiting for funds", and the admin retries. The design said "the admin is told": it is Sentry and the payout queue, not a new money-attention item kind.
- **Payouts made before M7** have no `payout_transfer` rows (one transfer for the whole payout). They are not rebuilt: the invariant then counts only transfers made since, which can only make it more lenient for those old charges, never block a payout. No production database exists.
- **Not in M7** (they are M8): recovering money after a payout from the transfer a charge funded (refunds and lost disputes), and the low-balance alerts.

### M4: caps, discovery, client credit and RAWW per currency (built 2026-11-14, high-risk: money, migration)

- **Price caps** are keyed by (niche, tier, currency) (decision M2). A package is checked against the cap in its own currency only. A currency with no cap for a niche and tier where another currency has one is refused (422 `no_price_cap_for_currency`, naming the currencies that have caps), so a pound price is never let through, or checked, against a euro cap. No cap in any currency is still no restriction. The admin's upsert requires the currency and keeps one row per currency; the web admin's caps grid has a GBP / EUR switch (GBP first). The pricing preview is in the photographer's currency whatever the query says.
- **Extra-photo price bounds** are keyed the same way and looked up in the booking's currency; a photographer's own extra-photo price is always in their currency (the admin route refuses another).
- **Client credit per currency** (decision M3): every reward line and balance has a currency (balances are keyed by user and currency); credit earned on a booking is in that booking's currency (marketing permissions, consent rewards, share rewards, referrals), and pays only for bookings in that currency (the checkout preview, the pay route and every `reserve_points_for_discount` spend only that balance). Released and refunded credit goes back to the balance it came from. 100 points are one unit of each currency (€1, £1). A sign-up reward with no booking behind it is in the default currency.
- **The monthly marketing budget per currency:** `monthly_marketing_credit_budget_eur` and `_gbp` (300.00 each by default), counted and alerted (80%, 100%) per currency; the admin budget view takes `?currency=` (the default currency when not given); the web admin's client-credit page has a GBP / EUR switch and both budgets.
- **The client's credit page** (`GET /v1/me/credit`) lists every currency held (`balances`), and the app shows the others under the main one ("€12.00 credit for bookings in EUR"), never added up.
- **Discovery:** the match score's budget fit (`client_launch.score_pro_for_match`, `currency` on the match request) follows the same rule. `pro_public_index.min_package_price_base_minor` (euro cents) and a currency on every price filter (`currency` query; the default currency when not given). A photographer priced in the budget's currency is compared exactly; one in another currency by its euro value, and left out while that is unknown. Price sort is by the euro value, unknown ones last. The search index's filter compares the budget's currency only.
- **RAWW per currency** (decision M5): `shelf_settings.raww_gbp_value` (unset), and every RAWW entry stamps `raww_value` and `raww_value_currency`. A booking in pounds earns round(credit in pounds / pounds per RAWW); later changes to the same booking use the first entry's value. The web admin's Shelf settings have "Pounds per RAWW".
- **Migration** `20261114_0097`: up, down and up tested on a copy of dev. Downgrade refuses while any credit, cap, bound or RAWW entry is in another currency than EUR.
- **Tests:** `tests/test_currency_m4.py` (27), with the hand-computed amounts in its header; the app's credit screen test.

**Not as the design said, and why:**
- **The batch order puts M4 before M3, but three parts of M4 need M3's rates:** the euro value of a price in pounds (discovery), a client's budget in their display currency, and decision M5's fallback (a pound booking's RAWW valued at the euro value at the day's rate while no pound value is set). M4 builds them against `services/fx.py`, which knows euros only until M3 adds the ECB rates: until then a pound price has no euro value (it is left out of euro-budget filters, and sorted after the others), a budget is in the default currency, and **a booking in pounds earns no RAWW while `raww_gbp_value` is unset** (logged `raww_not_valued`; never valued as if pounds were euros). The Shelf is off, so no photographer can spend RAWW meanwhile.
- **The RAWW value setting is named `raww_gbp_value`**, beside the existing `raww_eur_value`, not renamed to `raww_value_eur` / `raww_value_gbp`: renaming the euro one changes the `bi_*` views (BI is batch M5).
- **Points per unit:** the setting is still called `points_per_eur`; it now means points per unit of any currency (100 = €1 or £1). Renaming it touches the reward rules' stored metadata; not done.
- **Referral minimums:** `min_conversion_value_eur` has no pound twin; it is compared in the booking's own currency's units (a £20.00 booking against the 20.00 minimum).
- **Dormant points** (the legacy proof-of-gigs RAWW mints, off by `raww_minting_enabled`; Studioverse; the store) stay in euros (`LEGACY_POINTS_CURRENCY`).
- **BI** reads the euro credit budget only (`budget_view(db, "EUR")`), as it counts euros only until M5; a RAWW entry valued in pounds has no euro value, so BI values it at the current euro setting until M5.
- **GBP price caps do not exist yet:** on dev, the euro caps exist, so **a photographer in pounds cannot create a package in a capped niche and tier until the admin sets the pound caps** (the designed refusal). The figures are the owner's. *Proposed 2026-11-15 in [PRICE_CAPS.md](PRICE_CAPS.md) and loaded on dev; production waits for the owner's figures.*

### M3: rates and display (built 2026-11-14, high-risk: migration; display only, nothing on the money path)

- **Rates:** `fx_rate` (EUR base, one row per currency and ECB publication day, `Numeric(18,8)`, never edited), filled by the hourly beat job `fx-refresh` (minute 15) from the ECB's `eurofxref-daily.xml` (`app/services/fx.py`). A rate is used up to 4 days old (weekends and holidays); older or missing means no rate, and Sentry gets "Exchange rate older than 4 days". A failed fetch changes nothing and is tried again the next hour. GBP to EUR is the inverse of EUR to GBP at full precision, rounded once.
- **`GET /v1/fx/rates`** (public, cached an hour): `{base: "EUR", rates: {"GBP": "0.85123000"}, as_of}`, fresh rates only (`{}` and no `as_of` when none is).
- **The display currency:** `user_account.display_currency` (null: the default, GBP), `GET` / `PUT /v1/me/display-currency` (only a currency switched on; null goes back to the default), and `display_currency` on `GET /v1/me`. The client's budget preference carries it (`ClientPreferenceView.currency`), and the discovery and match budget filters use it when the request names no currency.
- **What the rate feeds on the server:** the discovery index's euro value of prices in pounds (recomputed by the job), and decision M5's fallback: a booking in pounds with no pound RAWW value set is valued at the euro value converted at that day's rate (`raww_value` in pounds and `raww_eur_value` stamped), including bookings that waited for a rate since M4 (the job values them).
- **Apps:** `RMoney` stays exact; `core/format/approx_money.dart` makes the approximation (half up once to a minor unit, shown whole from 20 up, to the penny below) and the labels of 2.4, GBP first; `core/fx/` reads the rates and the display currency. Shown: the Discover cards and rows, the photographer's profile packages and the booking request sheet ("about £850"; on the sheet also "You'll be charged in euros (EUR). Your bank sets the final amount in pounds."), the pay card and the selection confirmation ("You'll be charged €1,000.00 (EUR). About £850 at today's rate. Your bank or card sets the final amount."). No rate: "Charged in EUR" instead. The same currency: nothing added. Account > Display currency (clients) and Settings > Account (photographers), shown only when more than one currency is switched on. Photographers' wallet, earnings, payouts and invoices are unchanged: their own currency, exact.
- **The default time zone** is Europe/London (`NOTIFICATION_DEFAULT_TIMEZONE`, new notification preferences, email times, call compliance), from 10.1. The same clock as Lisbon all year; existing rows keep theirs.
- **Migration** `20261114_0098`; up, down and up tested on a copy of dev.
- **Tests:** `tests/test_fx_display.py` (14 tests, 18 cases: the design's fixtures of 7.2, the display currency in discovery and the client preference, the hourly job, the London default), and the app's `test/core/format/approx_money_test.dart` and `test/core/fx/approx_widgets_test.dart`. App widget tests that draw a price use `test/support/fake_fx.dart` (no rate, no choice), so none reaches the network.

**Not as the design said, and why:**
- **The fixture of 7.2 for £850.00 to euros** says 99855 cents; 85000 / 0.85123 = 99855.503, which rounds half up to **99856**. The test uses 99856; the shown amount ("about €999") is the same.
- **The photographer sees the approximation on their own listing preview** (the pro app draws the same Discover card), in their display currency. It is a line under the exact price, as for clients; not hidden, so the preview stays what clients see.
- **Changing the display currency does not reload lists already on screen** (Discover, the profile): the approximations change at once, but a budget filter in another currency applies from the next search.
- **The ECB rate is fetched by the beat only** (no rate until the job has run once after a deploy; see DEPLOY_CHECKLIST).

