# Company details needed

Written 2026-11-16 on `the-shelf-wip`, docs only. Found by searching the API, the apps, the web, the deploy files and the docs; nothing here is guessed. Where something does not exist yet, it says so.

**The decision:** the platform is run by a **Portuguese company, entity to be confirmed** (`MULTI_CURRENCY.md` 11.0, decision M11, 2026-11-16). Until the owner confirms the entity, every company detail stays a placeholder.

**This repository is public.** Real values never go into a file, a commit message or a doc. Real values go only into the places marked **setting** or **outside the repo** below (production env files on the server, the Stripe, Brevo and store dashboards, the published legal texts). In the repo, use only these placeholders:

| Placeholder | What it stands for |
|---|---|
| `[COMPANY LEGAL NAME]` | The company's registered name |
| `[REGISTERED ADDRESS]` | Its registered office |
| `[COMPANY NUMBER]` | Its registration number |
| `[VAT NUMBER]` | Its VAT or tax number |
| `[COUNTRY]` | Portugal (fixed by the decision; written as a placeholder until the entity is confirmed) |
| `[SUPPORT ADDRESS]` | The support email (decided: support@rawwers.com, `BETA_SCOPE.md` 4.4, item 8) |

**What blocks filling any of them in:** the entity is not confirmed (all rows). Rows with more blockers name them.

## The checklist

Key: **not built** = the place does not exist yet; **placeholder** = exists with placeholder text; **hard-coded** = a fixed value in the code; **setting** = an env value or a dashboard field, outside the repo.

### Legal texts

| Where | What is there now | Needs | Also blocked by |
|---|---|---|---|
| Terms of service, privacy notice, photographer agreement (`BETA_SCOPE.md` #7, batch 3) | **Not built.** No page, route or text in the API, apps or web (no `terms`, `privacy` or `legal` route under `web/app`; nothing in `app/lib`) | Legal name, registered address, company number, country, support address; the privacy notice also names the data controller and any representative (#55) | The lawyer's texts; #55 |
| `docs/PRIVACY_NOTICE_INPUTS.md` | Inputs only; names no company | The controller's identity, when the notice is written | The lawyer |
| The Shelf's terms (`SHELF_TERMS_PLACEHOLDER`, `api/app/models/shelf.py:126`) | **Placeholder** ("DRAFT - not reviewed"); names no company. The admin cannot approve the placeholder (`shelf_settings.py:160`) | The legal name in the reviewed text, if the lawyer puts it there | The Shelf stays off; the lawyer |
| Data-deletion page for Google Play (`BETA_SCOPE.md` #10, batch 3) | **Not built** (no page under `web/app`) | Legal name and support address (Play asks for the developer's name on the page) | The lawyer's text |

### Money documents

| Where | What is there now | Needs | Also blocked by |
|---|---|---|---|
| The photographer's invoice (`api/app/services/invoices.py` `build_invoice`; `GET` invoice in `api/app/api/v1/payouts.py`; the Pro app's invoice screen) | **No issuer at all.** It shows the gig, the date, the client total, the platform's retained fee, RAWW, the photographer's cash, photos delivered and the photographer's VAT (status, rate, their VAT number). No company name, address, company number or VAT number of the platform | Whether the platform's fee needs an invoice from the company, and what it must show (legal name, address, VAT number, the fee's VAT) | **The accountant** (#56): an answer may need new fields, which is code |
| Client receipts | **None of ours.** The client gets Stripe's payment and the "payment received" email (`email_texts.py`), which shows the amount only | Whether a receipt from the company is required, and what it shows | The accountant |
| `country_tax_rule` (`api/app/services/tax.py:30-60`) | **Hard-coded** UK row: VAT 20%, threshold, `GB123456789` format. It describes **photographers'** VAT, not the company's | Nothing for the company itself; the platform's own VAT handling is #56 | The accountant |

### Email (Brevo)

| Where | What is there now | Needs | Also blocked by |
|---|---|---|---|
| Sender name `BREVO_SENDER_NAME` (`api/app/core/config.py:83`, `deploy/.env.prod.example:57`, staging `:63`) | **Setting**, default `RAWWERS` | Stays the brand unless the lawyer says otherwise | — |
| Sender address `BREVO_SENDER_EMAIL`, reply-to `BREVO_REPLY_TO` (`deploy/.env.prod.example:56, 58`) | **Setting**: `hello@mail.rawwers.com`, `support@rawwers.com` | Nothing company-specific | The SPF fix (`BETA_SCOPE.md` 4.5) |
| The email footer (`api/app/services/mail.py:115-119`) | **Hard-coded**: "You get this email because you have a RAWWERS account." and the unsubscribe link. No company name or postal address | Whether emails must name the company and its address (marketing emails especially) | The lawyer |
| The Brevo account and its DPA | **Outside the repo**; whose name the account is in: not verified | In the company's name, with the company's DPA | — |

### Stripe

| Where | What is there now | Needs | Also blocked by |
|---|---|---|---|
| The platform account | **Outside the repo.** A Portuguese account exists (`MULTI_CURRENCY.md` section 9); whether it is under the company: not decided | Moved to the company or a new one opened (the owner asks Stripe) | Stripe's answer |
| Keys and webhooks: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` (`api/app/core/config.py:57, 72`), `STRIPE_PUBLISHABLE_KEY` (`app/env/client.example.json`) | **Setting** | New values if a new account is opened | As above |
| Statement descriptor (what the client's bank statement shows) | **Not in the code** (no `statement_descriptor` anywhere); a Stripe dashboard setting (`BETA_SCOPE.md` 4.5) | The brand and, if Stripe requires, the legal name; support contact | The account above |
| Connect platform profile and branding (what photographers see in Express onboarding) | **Outside the repo** (dashboard) | Legal name, support address, country | The account above |
| `DEFAULT_CONNECT_COUNTRY` (`api/app/core/config.py:60`, default `PT`), `WARMUP_HOME_COUNTRY` (`:38`, default `PT`) | **Setting**, the country of a photographer's Connect account when none is known; not the company's country | Nothing for the company; `BETA_SCOPE.md` #58 (batch M6) | — |
| The GBP settlement account (Wise or Revolut Business) | **Outside the repo**; does not exist yet | In the company's name, linked in Stripe | The entity |

### Store listings and accounts

| Where | What is there now | Needs | Also blocked by |
|---|---|---|---|
| Apple Developer Program and Google Play Console | **Outside the repo**; organisation accounts not opened (`BETA_SCOPE.md` 4.5) | Legal name, D-U-N-S number, registered address, support URL, privacy policy URL | The entity; the D-U-N-S number; #7 |
| Store listing fields (seller name, support URL, privacy URL, Play's developer address) | **Not in the repo** (no fastlane or listing metadata) | Legal name, address, support address | As above |
| Apps' about or legal screens (`app/lib`) | **None** (no about, licences or legal screen) | Links to the terms and privacy notice once #7 exists | #7 |

### Web, admin and deploy

| Where | What is there now | Needs | Also blocked by |
|---|---|---|---|
| Public web pages (`web/app/page.tsx`, `get-the-app`, `waitlist`, `unsubscribe`, `share/[token]`) | Brand name only; **no footer**, no company name or legal links | A footer with the legal name, address and the terms and privacy links, if the lawyer asks for one | #7; the lawyer |
| Web admin, Costs and company cash (`web/app/admin/bi/costs/page.tsx`) | No company details. The cash form takes a free-text account name and a currency (default `EUR`) | Nothing company-specific; enter the GBP settlement account's balance in GBP once it exists | — |
| BI base currency (`MULTI_CURRENCY.md` 11.5; M5's `bi_base_currency`) | Not built; BI is euros only | EUR (decided by the company decision) | — |
| Production env (`deploy/.env.prod.example`, `deploy/.env.staging.example`) | No company field exists; the Brevo and Stripe settings above | The Stripe and Brevo values above | As above |
| Other provider accounts (Sentry, Mux, R2, the host, the domain) | **Outside the repo**; whose name each is in: not verified | In the company's name, with its DPAs where they apply | — |

## When the entity is confirmed

1. The owner gives the details outside the repo.
2. Fill in every **setting** and **outside the repo** row above.
3. Legal texts (#7, #10) are written by the lawyer with the real details, and published outside the repo (or added to the repo only as public pages, which the details then appear in by design).
4. Tick the company line in `DEPLOY_CHECKLIST.md` section 2.
