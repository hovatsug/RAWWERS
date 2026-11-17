# Commits since the last full pass

The last full pass is **GATE 1 on 41fd970** (2026-11-17, below; the one before was 13148e8, 2026-11-08). The list restarts from 41fd970 (owner, 2026-11-17); the earlier rows are in git history. Every commit after it is listed here until the next gate (GATE 1: feature freeze; GATE 2: after the security audit fixes; GATE 3: before deploy). At a gate, run both full suites once and use this list to know what to watch. Then start a new list from the gate's commit.

## GATE 1 — run on 41fd970 (2026-11-17)

From the pinned worktree `~/Developer/RAWWERS-work/wt-gate1`; the progress log is in the owner's scratch folder (`gate1-progress.txt`).

| Stage | Result | Time |
|---|---|---|
| API lane 1 (66 files) | 956 passed, 2 xfailed, 0 failed, 0 errors | 2 h 47 min |
| API lane 2 (66 files) | 810 passed, 0 failed, 0 errors | 1 h 56 min |
| API lane 3 (66 files) | 873 passed, **2 failed**, 0 errors: two outdated tests (`test_check_known_failures`: the list may now be empty; `test_answering_a_request`: a hand-set tier, demoted by the recompute since 11e30c5). Fixed in 34f1b68; both whole files pass | 2 h 39 min |
| API total | 2,639 passed, 2 xfailed, 2 failed (fixed), 0 errors; KNOWN_FAILURES: 0 | |
| Flutter (`flutter test`) | 1,128 passed, 39 skipped, 0 failed | 3 min 41 s |
| Web (`pnpm verify`: lint, build, typecheck, isolation and user-page checks) | passed | 2 min |
| E2E (Playwright, 83 tests) | **The web Docker image does not build** (Corepack fetches the newest pnpm, 12.x, which refuses to install; with pnpm pinned, `Module not found: @sentry/core` because there is no `web/.dockerignore` and `COPY . .` brings the host's node_modules; Google Fonts unreachable in the build). Run instead with the e2e API stack in Docker (18000) and the web app started from the pinned worktree (13000): 78 passed, 3 failed, 2 skipped. Two outdated checks fixed in 7481ae2 (rerun: pass); **the funnel fails because `seed_dev.py --deterministic` crashes on a fresh database** ("Photographer profile not found", since c291946) | 4 min |

Not clean: two real bugs reported to the owner (the web image build, the seed on a fresh database), not fixed in the gate.

## Commits since 41fd970

| Commit | Date | What | High-risk |
|---|---|---|---|
| 34f1b68 | 2026-11-17 | Tests: two outdated tests found by Gate 1 (an empty known-failures list; a hand-set tier pinned as an override) | no (tests only) |
| 7481ae2 | 2026-11-17 | E2E: the login heading locator; the admin key the web proxy needs in compose.e2e | no (e2e tests and e2e compose only) |
| 4268ffd | 2026-11-17 | Docs: GATE 1 result; two real bugs logged | no (docs only) |
| 7ee2f09 | 2026-11-17 | Web image: pnpm pinned (packageManager, Dockerfile, CI), web/.dockerignore, self-hosted fonts | no (build and CI; a no-cache image build and pnpm verify pass) |
| ae0945b | 2026-11-17 | Seed on a fresh database (profile flushed before its currency is read); DEPLOY_CHECKLIST section 0, the empty-database sequence | no (dev seed script and docs) |
| c9557a9 | 2026-11-17 | Chat message emails (#69): photographer on a client's message, client on a reply; hold, unread, 15-minute window | **yes** (email, chat) |
| aea9f6e | 2026-11-17 | ruff.toml (E9, F63, F7, F82), ruff pinned in CI; repair partner index document returned again; CertificateView imported | no (lint config; two small fixes, failing tests first) |
