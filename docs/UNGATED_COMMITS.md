# Commits since the last full pass

The last full pass of both suites was on **13148e8** (2026-11-08: API exactly the 26 known failures, Flutter 0 failed). Every commit after it is listed here until the next gate (GATE 1: feature freeze; GATE 2: after the security audit fixes; GATE 3: before deploy). At a gate, run both full suites once and use this list to know what to watch. Then start a new list from the gate's commit.

| Commit | Date | What | High-risk |
|---|---|---|---|
| 35e3e66 | 2026-11-08 | Web: every old client and pro page redirects to "get the app" (web only) | no |
| f2838e1 | 2026-11-08 | Docs: the API suite's run time, Google Play's deletion page | no |
| 66b3ce0 | 2026-11-08 | Docs: this list (UNGATED_COMMITS.md) | no |
| d7c18c4 | 2026-11-09 | Mux webhook: all four events, out-of-order delivery, nothing settled moves back; KNOWN_FAILURES 26 -> 25 | no |
| 4134da5 | 2026-11-09 | Mux: the mux-sync job settles videos whose webhook never came; Mux lines in the env examples and DEPLOY_CHECKLIST | no |
| c95b39e | 2026-11-09 | Docs: MUX_LOCAL_WEBHOOKS.md (Mux CLI forwarding to the dev API) | no |
| 17a7e6f | 2026-11-09 | Email suppression table and service (migration 0091) | **yes** (migration) |
| b93d6a8 | 2026-11-09 | Email: the nine approved emails through Brevo, EMAIL_SENDING_ENABLED, dev allowlist, suppression checked | **yes** (authentication mail) |
| f576147 | 2026-11-09 | Brevo webhook: bounces and complaints suppress the address | **yes** (webhook authorization) |
| f8e7b47 | 2026-11-09 | Docs: Brevo as built, the sending domain DNS, the deploy lines | no |
| c239c45 | 2026-11-09 | Docs: plain-text codes on the gaps and SECURITY_AUDIT_LIST.md; Brevo authorised IPs | no |
| 83f1791 | 2026-11-09 | Docs: UNGATED_COMMITS lists f8e7b47 and c239c45 | no |
| e7f6ee0 | 2026-11-09 | Docs: BI.md, the business dashboard's definitions | no |
| 4aa922b | 2026-11-09 | BI: bi_daily, manual tables, Stripe mirror, bi_* views (migration 0092) | **yes** (migration) |
| 15627a0 | 2026-11-09 | BI: the definitions computed, bi-nightly job, backfill, Stripe mirror | **yes** (computes money) |
| fbbe76b | 2026-11-09 | BI: /v1/admin/bi/* routes | **yes** (admin authorization) |
| 8204047 | 2026-11-09 | BI: scripts/seed_bi_demo.py (dev only) | no |
| 0487106 | 2026-11-09 | Web admin: the business dashboard and the costs and cash forms (web only) | no |
| 42b2b29 | 2026-11-09 | BI: a test that days are London days | no |
| 536056a | 2026-11-09 | Docs: reading BI, refilling its tables; after-deploy Brevo and Mux tests | no |
| d0c7376 | 2026-11-10 | Docs: UNGATED_COMMITS lists the BI batch | no |
| b7e6e95 | 2026-11-10 | BI: phone-readable charts, Stripe mirrored hourly, today's Stripe data "as of" | no |
| 11e30c5 | 2026-11-10 | BI: migration 20261110_0093; refunds, RAWW rates, Shelf costs and shipping, booking tier recorded; free cash | **yes** (migration, money recorded) |
| 0caf8a7 | 2026-11-10 | BI demo seed records the new stamps (dev only) | no |
| 59701d7 | 2026-11-10 | Web admin: Net GMV, free cash, estimated values marked, Shelf shipping cost (web only) | no |
| 562a66e | 2026-11-10 | Docs: BI definitions for the owner's decisions | no |
| 39b7529 | 2026-11-10 | Web admin BI: filter options stay selectable (web only) | no |
| 0b33bb6 | 2026-11-10 | Docs: deploy checklist for migration 0093; UNGATED_COMMITS lists the batch | no |
| d493aab | 2026-11-10 | Admin BI routes: own rate limit 240/min, other admin routes stay at 60; who you are checked before any limit | no |
| a66d96b | 2026-11-10 | BI: migration 20261110_0094; old add-on refunds counted (date estimated), Shelf shipping per order only, never twice | **yes** (migration, money computed) |
| 1f945d4 | 2026-11-10 | BI demo seed: legacy Shelf shipping cost, old add-on refund (dev only) | no |
| f5ce0a7 | 2026-11-10 | Web admin: legacy cost label, Shelf shipping per order only, old add-on refunds estimated (web only) | no |
| 287c0b0 | 2026-11-10 | Docs: BI decisions 10-12; deploy step for 0094 | no |
| c3587fc | 2026-11-10 | Docs: security audit list items 2-3 (known security test failures, error bodies) | no |
| 4e5deae | 2026-11-10 | Docs: BETA_SCOPE.md (beta scope check: journeys, MUST/SHOULD/LATER, freeze list) | no |
| 4e5deae | 2026-11-10 | Docs: BETA_SCOPE.md (listed in deb165f) | no |
| bdc80e8 | 2026-11-11 | Known failures: nine fixed (seven test bugs, one chat 500); KNOWN_FAILURES 25 -> 16 | no (tests; product fix in the chat route only) |
| b3028c3 | 2026-11-11 | API: poetry.lock; the image installs from it; docs/DEPENDENCIES.md | no |
| 9fd8a97 | 2026-11-11 | Docs: BETA_SCOPE records the owner's decisions; FEATURE FREEZE DECLARED | no |
| 9225f10 | 2026-11-11 | Client IP: X-Forwarded-For only from a trusted proxy (core/client_ip.py) | **yes** (IP handling, authorization) |
| fbcca1f | 2026-11-11 | Docs: MULTI_CURRENCY.md, the EUR and GBP design (not built) | no |
| ead0fa2 | 2026-11-11 | Alerts: Sentry (API, worker, beat, web admin); failed emails retried, reported, listed, resent | **yes** (email) |
| 3c9c6f4 | 2026-11-13 | Errors: unhandled errors answered inside the request middleware; 500s carry X-Request-Id and the id in the body; the Sentry event carries the request_id tag; KNOWN_FAILURES 16 -> 15 | **yes** (error handling) |
| 83d369e | 2026-11-13 | Docs: BETA_SCOPE records UK first; UK items #54-#59 | no |
| 18eac9d | 2026-11-13 | Docs: MULTI_CURRENCY Stripe answers, design changes, company scenarios, build order; DEPLOY_CHECKLIST GBP settlement account | no |
| 733b7d7 | 2026-11-13 | Docs: UNGATED_COMMITS rows for 3c9c6f4, 83d369e, 18eac9d | no |
| 9d3194f | 2026-11-13 | Docs: the owner's multi-currency decisions M1-M10 (M11 open); Shelf stays off | no |
| 44c9b21 | 2026-11-14 | Multi-currency M1: currency on the photographer's money; currency_settings (GBP only); `_eur` columns renamed; migration 20261113_0095 | **yes** (money, migration) |
| ad49746 | 2026-11-14 | Multi-currency M2: every money value carries its currency; client credit euros-only; apps regenerated, RMoney without fallback; web money() requires a currency | **yes** (money display, contract) |
| 807bc23 | 2026-11-14 | Docs: credit earned in pounds is a beta gate item (#60) and a known gap until M4 | no |
| 1486e3e | 2026-11-14 | Client credit: the pay route's own currency check removed; the central one in rewards refuses and the route pays in full | **yes** (money) |
| bd8d409 | 2026-11-14 | Multi-currency M7: one transfer per client payment, from its charge; migration 20261114_0096 | **yes** (money, migration) |
| c291946 | 2026-11-14 | Multi-currency M4: caps, credit and RAWW per currency; migration 20261114_0097 | **yes** (money, migration) |
| 170207d | 2026-11-14 | Tests: four tests M4 left behind (credit wording, index currency, own preview) | no (tests only) |
| 2b7c983 | 2026-11-14 | Multi-currency M3: display rates and the display currency; default time zone Europe/London; migration 20261114_0098 | **yes** (migration) |
| 8b2e88e | 2026-11-14 | Lightroom plug-in 1.1.0: publish to the portfolio (BETA_SCOPE #61) | **yes** (token scope, uploads, user content) |
| 0e87bfc | 2026-11-15 | Price caps: pound caps proposed (not owner-approved), both currencies loaded from api/data/price_caps; admin grid refuses the other currency's file | **yes** (money) |
| ada3822 | 2026-11-15 | Lightroom: plug-in portfolio publish has its own 100 an hour; app 30/hour and device 5000/day unchanged | **yes** (upload limits) |
| 5c6de48 | 2026-11-15 | Admin: sidebar in collapsible categories, menu reachability guard; admin test fixtures for M1/M4 | no (web only) |
| 976847b | 2026-11-15 | Niches from Lightroom: GET/POST /v1/delivery/portfolio/niches (plug-in 1.2.0), shared niche rule, at most 3 niches (app route too); latest plug-in 1.2.0 | **yes** (token scope, profile writes) |
| 75c16d5 | 2026-11-15 | Lightroom plug-in 1.2.0: choose and add niches in the publish service and collection settings; checklist part P | no (plug-in only, server enforces) |
| 9c32d3e | 2026-11-16 | Lightroom plug-in 1.2.1: publish service Save allowed once connected (one connection state for line and Save); checklist P.2/P.4/P.5/P.6 | no (plug-in only, no API change) |
| 8d29427 | 2026-11-16 | Lightroom plug-in 1.2.2: 1.2.1's fix moved into RawwersPortfolio.lua (an open Lightroom could not load the new file); file-list test | no (plug-in only, no API change) |
| 7d2dd14 | 2026-11-16 | Portfolio publish: one photo per Lightroom photo and niche (publish key, picture hash), finish in one transaction and repeatable, deadlock lock, plain messages, niche counts; latest plug-in 1.2.3 | **yes** (uploads, portfolio state) |
| 1283ca3 | 2026-11-16 | Lightroom plug-in 1.2.3: key and picture hash, removes the version the server names, plain failure words, dialog counts from the server; checklist P.15-P.17 | no (plug-in only, server enforces) |
| 511248f | 2026-11-16 | Tests: two portfolio finishes at once on real Postgres (25 rounds; old code deadlocked every round), lock-first and fixed-order checks | no (tests only) |
| f095c06 | 2026-11-16 | Deliveries: key and picture guard, stuck uploads resumed, repeat-safe part joining; old portfolio versions removed by the server only, with dependency checks; DELETE refuses photos in use | **yes** (uploads, deliveries, portfolio state, deletes content) |
| 6be2ed6 | 2026-11-16 | Lightroom plug-in 1.2.4: delivery key and picture hash, true gallery counts, previous_id sent, no client-side removal; checklist 5.1, 6.2, 6b.1 | no (plug-in only, server enforces) |
