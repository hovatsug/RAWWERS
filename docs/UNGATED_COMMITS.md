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
