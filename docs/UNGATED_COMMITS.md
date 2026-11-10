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
