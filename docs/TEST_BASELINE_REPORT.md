# RAWWERS Backend Test Baseline — First Real Run, Then Root-Cause Fixes

Harness fix committed as `5120d0ee`. This is the first time this suite has ever executed to completion against Postgres. **Original baseline: 217 collected, 120 passed, 97 failed, 0 errored, 0 skipped.**

Root-cause fixes committed as `6b8645a4`, verified by rerunning the full suite against a fresh Postgres+Redis after each fix. **Result: 169 passed, 47 failed, 1 error (a diagnostic-tooling artifact, not a real bug — see below), 0 skipped.**

## Update — five shared root causes fixed (69 tests, `6b8645a4`)

| Fix | File(s) | Failures resolved |
|---|---|---:|
| `get_current_user()`'s dev-bypass path never ensured a `UserAccount` existed before logging an `auth_event_log` row for it — every other auth path already did | `app/api/deps.py` | 33 |
| `ContentPackReviewDecision` used but never imported | `app/api/v1/studioverse.py` | 4 |
| `ALLOWED_PREFIXES` missing `extra_images.`, `onboarding.`, `refund.`, `risk.` — cross-checked every `event_name` literal in the repo, not just this run's failures | `app/services/analytics.py` | 7 |
| `_sync_niche_badges()` deleted old badges and added new ones in the same flush with no explicit flush between — SQLAlchemy processes inserts before deletes by default, so re-awarding the same tier badge collided with its own not-yet-deleted predecessor | `app/services/niche_skills.py` | 6 direct + several mis-bucketed cascades |
| Test helpers generated email as `f"{user_id[:8]}@example.com"` — this codebase's hardcoded sequential test-id convention (`...0000000000ab`) means many ids share the same first 8 characters, causing collisions | 9 test files | 9 |

The 1 remaining "error" in the final run is `pytest-timeout` (a diagnostic tool I used locally to survive an earlier Redis-unavailable hang, not part of the repo) firing on one slow `drop_all`/`create_all` cycle — an artifact of my verification harness, not a real bug, and not present in actual CI (`pytest -q`, no timeout flag).

## What's left — 47 failures, a genuine long tail

Not pursued further in this pass; each needs individual investigation rather than sharing a cause with others at comparable scale:

- **`pro_profile.user_id` FK violation (~10 cases)** — a second, smaller FK gap; root cause not yet isolated (confirmed it is *not* simply the same dev-bypass issue, since it persists after that fix).
- **Pydantic `ValidationError` for `ChatMessageView` (3)** — schema/data shape mismatch.
- **Niche skill tier assertion mismatches (3)** — business logic worth real investigation now that the badge-collision noise is gone.
- **One real Postgres-vs-SQLite incompatibility**: `operator does not exist: json ~~ text` — code does a `LIKE` directly against a `json` column; Postgres needs an explicit cast.
- **A handful of stale tests, rate-limit/balance assertion mismatches, one unresolved Pydantic forward-ref, and other one-off failures** — see the original root-cause table below for the pre-fix shape of these (some counts shifted slightly as the dominant clusters cleared out from around them).

---

## What the harness fix actually was

- `tests/conftest.py` hardcoded `sqlite+pysqlite:///./test.db` regardless of `DATABASE_URL` — CI already had a correctly-configured `postgres:16` service with the right `DATABASE_URL`, the bug was purely conftest silently overriding it. Now builds its engine from the environment, defaulting to a distinct `rawwers_test` database (not the `rawwers` name dev/CI use, so a stray local run can't wipe real dev data).
- `httpx` was missing from dev dependencies entirely — `TestClient` requires it, so collection itself failed before ever reaching the SQLite/JSONB wall. Added.
- Two duplicate-index-name bugs fixed directly in the model files (not worked around): `Course.status` and `Dispute.against_user_id` each had `index=True` on the column *and* a separate explicit `Index(...)` creating the identical name a second time, which breaks `create_all()` outright. Scanned the whole `app/models/` package via metadata introspection for the same pattern (indexes, unique constraints, check constraints) — these were the only two.
- CI's workflow already runs both `postgres:16` and `redis:7` services correctly. Local dev compose already has Postgres. No changes needed to either.

One environment note, not a code bug: my sandbox had no Redis at all initially. One test (`test_dispute_open_only_participant_and_sets_gig_disputed`) appeared to hang indefinitely — turned out to be `kombu.retry_over_time` looping `sleep(1.0)` trying to reach an unreachable Redis backend. Adding a real Redis container made it pass instantly. Flagging this because it's a good reminder that **local `make test` runs need Redis reachable, not just Postgres** — worth a line in the README if there isn't one already.

---

## Results by file

| File | Passed | Failed | Errored | Skipped |
|---|---:|---:|---:|---:|
| test_admin_ops.py | 3 | 2 | 0 | 0 |
| test_ai_concierge_v1.py | 3 | 1 | 0 | 0 |
| test_auth_v1.py | 6 | 0 | 0 | 0 |
| test_chat_concierge.py | 1 | 3 | 0 | 0 |
| test_client_launch.py | 4 | 1 | 0 | 0 |
| test_client_rewards_pricing.py | 0 | 5 | 0 | 0 |
| test_discovery.py | 2 | 2 | 0 | 0 |
| test_disputes_refunds.py | 5 | 2 | 0 | 0 |
| test_followups_calls.py | 3 | 4 | 0 | 0 |
| test_gamification_v0.py | 0 | 6 | 0 | 0 |
| test_gigs_payments.py | 1 | 3 | 0 | 0 |
| test_growth_engine_v1.py | 6 | 0 | 0 | 0 |
| test_i18n_v1.py | 5 | 1 | 0 | 0 |
| test_launch_ops.py | 0 | 4 | 0 | 0 |
| test_learning_v0.py | 4 | 2 | 0 | 0 |
| test_learning_v1.py | 4 | 0 | 0 | 0 |
| test_legacy_shoot_v1.py | 4 | 0 | 0 | 0 |
| test_media_api.py | 0 | 1 | 0 | 0 |
| test_media_rights.py | 1 | 4 | 0 | 0 |
| test_multi_region_reliability.py | 2 | 1 | 0 | 0 |
| test_mux_webhooks.py | 2 | 1 | 0 | 0 |
| test_niche_skill_matrix_v2.py | 2 | 4 | 0 | 0 |
| test_niches_skills.py | 3 | 3 | 0 | 0 |
| test_notifications_v1.py | 4 | 1 | 0 | 0 |
| test_ops_security_baseline.py | 4 | 2 | 0 | 0 |
| test_payouts_v1.py | 5 | 2 | 0 | 0 |
| test_prints_fulfillment_v1.py | 6 | 0 | 0 | 0 |
| test_pro_onboarding_booking.py | 1 | 4 | 0 | 0 |
| test_proof_gallery.py | 0 | 5 | 0 | 0 |
| test_proof_of_gigs_v1.py | 1 | 6 | 0 | 0 |
| test_referrals_rewards.py | 3 | 2 | 0 | 0 |
| test_repairs_v0.py | 3 | 3 | 0 | 0 |
| test_reviews.py | 1 | 4 | 0 | 0 |
| test_scheduled_tasks.py | 22 | 0 | 0 | 0 |
| test_scheduling_v1.py | 2 | 2 | 0 | 0 |
| test_search_api_fallback.py | 0 | 1 | 0 | 0 |
| test_search_indexing_v0.py | 0 | 3 | 0 | 0 |
| test_search_provider.py | 1 | 0 | 0 | 0 |
| test_store_v0.py | 3 | 3 | 0 | 0 |
| test_studioverse_v1.py | 1 | 4 | 0 | 0 |
| test_trust_safety_v1.py | 2 | 5 | 0 | 0 |
| **TOTAL** | **120** | **97** | **0** | **0** |

**Fully green:** `test_auth_v1.py`, `test_growth_engine_v1.py`, `test_learning_v1.py`, `test_legacy_shoot_v1.py`, `test_prints_fulfillment_v1.py`, `test_scheduled_tasks.py`, `test_search_provider.py`.

**Fully red:** `test_client_rewards_pricing.py`, `test_gamification_v0.py`, `test_launch_ops.py`, `test_media_api.py`, `test_proof_gallery.py` — zero passing tests in these files.

---

## Failures grouped by root cause

Two clusters account for the majority of the 97 failures — this is a handful of shared problems, not 97 individual ones.

| Count | Root cause | One-line reason |
|---:|---|---|
| **33** | FK violation: `auth_event_log.user_id` | Test helpers create a `UserAccount` but never seed whatever actor id ends up logged to `auth_event_log` — SQLite never enforced this FK, Postgres does. |
| **12** | FK violation: `pro_profile.user_id` | Same pattern — code path creates/reads a `ProProfile` row for a `user_id` that was never actually inserted into `user_account`. |
| **9** | Unique violation: `user_account.email` | Multiple `UserAccount` rows created with the same (or same-default) email within a test. |
| **6** | Unique violation: `user_badge` (incl. cascaded `PendingRollbackError`) | Same gamification badge gets awarded twice in one test; the session-poisoning `PendingRollbackError` in later assertions is a downstream symptom of this same root cause, not a separate bug. |
| **10** | AssertionError: HTTP status mismatch (409/401/200 variants) | Behavioral mismatches — some plausibly real, some plausibly cascading from the FK/unique failures above corrupting earlier steps in the same test. Not investigated further, per instruction. |
| **7** | `APIError: Invalid analytics event_name` | Same class of bug as the `dispute.` prefix I found and fixed during Task A — `app/services/analytics.py`'s `ALLOWED_PREFIXES` is missing prefixes actually used elsewhere in the codebase (at least `trust_safety`/`risk`-adjacent event names judging by which test file these come from). Not re-investigated exhaustively here since fixing it is out of scope for this pass. |
| **4** | `NameError: name 'ContentPackReviewDecision' is not defined` | Straightforward missing import in the Studioverse module — a name is referenced that was never imported. |
| **4** | Pydantic `ValidationError` for `ChatMessageView` (datetime) | A response schema and the data being validated disagree on datetime shape/type. |
| **2** | `assert None is not None` | Certificate-issuance flow isn't producing a record the test expects. |
| **2** | AssertionError: niche skill tier mismatch | Business-logic assertion on `SkillTier` value doesn't match expected tier. |
| **1** | FK violation: `user_role.user_id` | Same pattern as the two FK clusters above, isolated case. |
| **1** | FK violation: `course.niche_id` | Same pattern, different table. |
| **1** | Postgres SQL: `operator does not exist: json ~~ text` | Code does a `LIKE`-style comparison directly against a `json`-typed column — Postgres requires an explicit cast to text; SQLite never enforced this at all. |
| **1** | `sqlalchemy.exc.MultipleResultsFound` | A `.scalar_one()`/`.one()`-style query matches more than one row where the code assumes exactly one. |
| **1** | `TypeError: 'title' is an invalid keyword argument for ProofGallery` | The test itself passes a constructor kwarg the model doesn't have — stale test, not app code. |
| **1** | AssertionError: outbox event status timing | Test expects an outbox event to still be `pending`/`processing` but it's already `delivered` — likely a timing assumption that doesn't hold now that dispatch actually runs to completion. |
| **1** | `PydanticUserError`: unresolved forward ref (`GearCategory`) | A FastAPI endpoint's `Annotated[...]` type has an unresolved forward reference — a real schema-definition bug, not data-dependent. |
| **1** | `RuntimeError: boom` | A deliberately-raised test exception meant to verify the global error handler returns a safe response — the raw exception is propagating instead of being caught as expected. |

**Bottom line on shape:** ~54 of the 97 failures (56%) are the *same* root cause repeated — test fixtures across many files create `UserAccount`/`ProProfile` rows without the referential integrity Postgres actually enforces, which SQLite silently let slide forever. Fix the handful of shared account/profile-seeding helper patterns and a large fraction of "red" files likely go fully green without touching business logic at all. The remaining ~40 are a longer tail of smaller, more varied issues (missing imports, missing analytics prefixes, one real Postgres-vs-SQLite SQL incompatibility, a few stale tests, a handful of genuine business-logic assertion mismatches worth real investigation).

Which subsystems "actually work" right now, going by fully-green files: auth, growth engine, learning (v1), legacy shoot, prints fulfillment, and the new scheduler tasks from Task A. Which subsystems have test files that exist but currently prove nothing: client rewards/pricing, gamification, launch ops, media upload, proof gallery.
