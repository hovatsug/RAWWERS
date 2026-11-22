# Backend tests without the dev stack

From 2026-11-22 the Mac does not run the dev stack
([MAC_DOCKER_OFF.md](MAC_DOCKER_OFF.md)). Backend tests run in two places:

| What | Where | How |
|---|---|---|
| A few test files, break checks | The Mac, no Docker | `tools/tests/native-db.sh <pytest arguments>` |
| The full suite (gates) | GitHub Actions | "Backend full suite (manual)", started by hand |

Both use a throwaway Postgres (database name ending `_test`) and Redis per
run, and placeholder settings only: no real key, and never `api/.env`.

## On the Mac: tools/tests/native-db.sh

Needs, from Homebrew: `postgresql@16` (the server's major version), `valkey`
(Redis-compatible; the `redis` formula would build Rust and LLVM from source
on this Intel Mac, hours) and `python@3.12` (the image's Python). Once:

```
tools/tests/native-db.sh setup
```

It makes the API's Python environment in `~/Developer/RAWWERS-work/venv/`
from `api/poetry.lock` with Poetry 1.8.4, as the image does, plus the dev
dependencies. Run it again after `poetry.lock` changes.

A run:

```
tools/tests/native-db.sh tests/test_deploy_scripts.py -q -rfE
tools/tests/native-db.sh tests/test_x.py -k some_name
NATIVE_DB_ROOT=1 tools/tests/native-db.sh tools/server/tests -q      # from the repository root
RAWWERS_REPO=<another checkout> tools/tests/native-db.sh tests/test_x.py
```

Each run starts a new Postgres cluster and a Valkey in a temporary folder, on
free ports, listening on this Mac only; runs pytest in `api/`; then stops both
and deletes the folder, also when the tests fail or the run is interrupted
(Ctrl-C). Nothing is left running. Runs can go side by side (own ports, own
folders). Its own tests: `tools/tests/test_native_db.sh`.

Its Postgres runs with `fsync=off` (a throwaway cluster: speed over
durability), unlike the server's.

## In GitHub: "Backend full suite (manual)"

`.github/workflows/backend-full-suite.yml`. Started only by hand: Actions >
Backend full suite (manual) > Run workflow, with:

| Input | Meaning |
|---|---|
| ref | The branch, tag or commit to test |
| shards | How many jobs side by side (default 8, at most 32) |
| only_shard | Empty: all shards. A number: that shard alone (a trial) |

**GitHub runs a manual workflow only once the file is on the default branch
(`main`).** Until it is merged there, the Run workflow button does not appear.

Each shard gets a share of the test files (`tools/tests/shard_tests.py`,
whole files, by size), its own Postgres 16.6 and Redis 7.4 (the server's
versions), and uploads its pytest output. The last job merges them
(`tools/tests/merge_shards.py`) and compares the failures by name with
`docs/KNOWN_FAILURES.txt` of the same commit
(`api/scripts/check_known_failures.py`): green only when the failures are
exactly the known ones and nothing errored. A missing or unfinished shard is
never green.

The repository is public, so the logs are public: the workflow has a
read-only token, uses no repository secret and prints no environment.

**Tests that need a real key:** none. `api/tests/conftest.py` replaces every
service setting with a placeholder (R2, Mux, Brevo, Stripe, the admin key) and
points Stripe at an address that cannot resolve; no test is skipped for a
missing key.

**First run: one shard alone.** Run workflow with `only_shard` = `0` and look
at the shard's time before using all eight. A shard has 5 h 40 min
(`timeout-minutes: 340`; GitHub's limit per job is 6 h). With today's
per-test schema rebuild (BETA_SCOPE LATER #96) a shard is expected to take
about 20-40 minutes on GitHub's runners (an estimate: 2,249 tests at about
3.6 s each, split eight ways; not measured).

## ci.yml: a finding, not changed

The `backend` job of `.github/workflows/ci.yml` runs `poetry run pytest -q`
with a Postgres service whose database is `rawwers`, and sets only
`DATABASE_URL`. The suite ignores `DATABASE_URL`: `api/tests/conftest.py`
uses `TEST_DATABASE_URL`, defaulting to
`postgresql+psycopg2://postgres:postgres@localhost:5432/rawwers_test`, a
database CI never creates. So the job most likely fails at the first test
with "database rawwers_test does not exist" (read from the files; not seen,
no access to the CI runs from here). It also runs the whole suite in one job,
which would pass GitHub's 6-hour limit.

Proposed fix (owner's decision; not made): in that job set
`POSTGRES_DB: rawwers_test` on the service and
`TEST_DATABASE_URL: postgresql+psycopg2://postgres:postgres@localhost:5432/rawwers_test`
in `env` (and the health check's `-d rawwers_test`); the migration check
step, which uses `DATABASE_URL`, needs its own database (`rawwers`, created
with `createdb` in a step) or the same one after the tests. Then replace its
single `pytest -q` with a call of this manual workflow's shards, or keep the
manual workflow for gates and run only a fast subset on every change.

## Measured on the Mac (2026-11-22)

The same two files (`tests/test_deploy_scripts.py`,
`tests/test_bootstrap_reference_data.py`, 10 tests):

| | Before: Docker runner (dev stack up) | After: native-db.sh |
|---|---|---|
| Wall time | 205 s (pytest 128 s) | 124 s (pytest 38 s) |
| Memory | 2.4 GB in use in Docker at the peak (the dev stack about 2.2 GB, the test container 0.24 GB), inside an 8 GB Docker VM | 0.38 GB at the peak (Postgres, Valkey and pytest together); nothing after the run |

Both runs had the same 10 passes, with the Mac busy (the Docker VM's dev stack
and a simulator running; load average 80 to 150), so the times are rough.
Most of the time outside pytest is Python importing the API at start (about
30 to 70 s on this Mac under that load); the first run after `setup` is slower
because the bytecode cache (`~/Developer/RAWWERS-work/venv/pycache`, outside
the repository) is empty.

Another comparison, the server-script tests (`tools/server/tests`, 18 tests,
against the API code of tag deploy-test-1): 17 min 30 s in the dev image with
Docker, 4 min 25 s with `native-db.sh`.
