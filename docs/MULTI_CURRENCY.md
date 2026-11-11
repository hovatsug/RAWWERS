# Multi-currency (EUR and GBP): design

Written 2026-11-11 on `the-shelf-wip`, read-only: nothing here is built. It is for the owner to approve before batch M starts (`docs/BETA_SCOPE.md` #14).

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
  - an EEA country → EUR.
- It is the default currency of that account's bank payouts. Stripe fixes an account's country at creation (`stripe_connect.py:50-57` already passes the profile's country).
- Before a Connect account exists, the currency follows the profile's country, by the same rule.
- **Every package must be in it.** The API refuses a package in another currency (today `currency` is free text on create).
- **The earnings ledger, balance, holds and payouts are in it.** One photographer has one balance in one currency, so no balance ever mixes currencies.
- **Changing currency** (a photographer moving country): admin-only, and only when:
  - nothing is open: no booking before completed, no pending, held or available earnings, no payout in flight;
  - a new Connect account exists for the new country.
  The old account and the old-currency history stay as they were. Packages are switched off and the photographer re-prices them; nothing is converted.

### 2.2 The client's display currency

- **New field `display_currency`** on the user (EUR or GBP; null means "use the default"). The default comes from the device: the app sends its locale (`Accept-Language`, already read, `middleware.py:25`), and a region of GB means GBP, anything else EUR.
- It is **changeable in Account → Display currency**, and for photographers too (Settings).
- It changes **only the approximation**. The amount charged and every amount stored stay in the photographer's currency.

### 2.3 The platform's base currency

**EUR**, for reporting only (BI, the owner's totals). It is not a money-path currency.

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
2. **A UK photographer's connected account:** an Express account with `country="GB"`, `transfers` capability, created by a PT platform. This is a **cross-border connected account**. It needs the **recipient** service agreement (`tos_acceptance.service_agreement="recipient"`), which the code does not set today. Its default currency is GBP, and its payouts go to a UK bank account in GBP.
3. **GBP transfers.** `Transfer.create(currency="gbp", destination=<GB account>)`, funded from the platform's GBP balance. The code change is the currency (the row's), and refusing a transfer whose currency is not the photographer's.
4. **Optional, safer:** `source_transaction=<charge id>` on transfers, so a transfer is funded by the charge it pays out. Today one payout covers many bookings (allocations), so this is a larger change. Not proposed for batch M.

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
| **M6. Stripe GBP end to end (test mode)** | Recipient agreement for cross-border accounts; GB Express onboarding; GBP charge, refund and transfer run against Stripe test mode; the flag; docs (BI.md, DEPLOY_CHECKLIST, this file) | 1 | **yes** (money, Stripe) |

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

### Decisions for the owner

| # | Question | Recommendation |
|---|---|---|
| M1 | Approve this design (option A as specified: currency from the Stripe account's country, nothing converted on the money path)? | Yes. |
| M2 | Price caps per **currency** or per **city**? | Per currency now (a GBP and a EUR table); city overrides later if prices differ within one currency. |
| M3 | Client credit: per currency (no conversion), or one EUR wallet converted at the day's rate? | Per currency: no rate exposure, and simpler to explain ("€5 credit on euro bookings"). |
| M4 | The GBP withdrawal minimum? | £45.00 (close to €50). |
| M5 | The RAWW value in GBP? | Set it together with the EUR one at the Shelf's opening; until then the GBP value stays unset and GBP earnings stamp RAWW at the ECB-converted EUR value of that day. |
| M6 | Build batch M before batch 2 (the first distributed build)? | Yes, so the API contract changes before any app is installed, and no compatibility fields are needed. |
| M7 | Send the Stripe questions (section 3.3) now? | Yes, today: their answers gate switching the flag on, and question 1 may change the charge model. |
| M8 | The display rate source? | The ECB daily reference rates (free, official, once a working day), shown as "about". |
