# RAWWERS Release Engineering (Foundation #34)

This document defines v1 QA + release engineering for the RAWWERS monorepo (`api/`, `web/`, `flutter/`).

## Environments

- `local`: developer laptops, fast feedback, mocked/partial dependencies allowed.
- `dev`: shared integration environment for active development.
- `staging`: production-like environment for release candidate verification.
- `production`: customer-facing environment.

Environment files:

- `api/.env.example`
- `web/.env.example`
- `deploy/.env.staging.example`
- `deploy/.env.prod.example`

Do not commit real credentials. Use GitHub Environments + Secrets for deploy/runtime secrets.

## CI pipelines

Workflow: `.github/workflows/ci.yml`

### Backend job

- Python 3.12 + Poetry install.
- `ruff` lint.
- optional `mypy` check (non-blocking in v1).
- `pytest`.
- migration checks:
  - `alembic upgrade head`
  - `alembic check` (fails when models drift from migrations).
- OpenAPI export artifact (`api/openapi.ci.json`).
- Docker image build (`api` tagged by commit SHA).

### Web job

- `pnpm install --frozen-lockfile`
- `pnpm lint`
- `pnpm typecheck`
- OpenAPI contract gate:
  - regenerate schema from backend artifact
  - fail if generated `web/lib/api/generated/schema.ts` differs
- `pnpm build`
- optional unit test run (`pnpm test --if-present`)
- Docker image build (`web` tagged by commit SHA)

### Flutter job

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- APK uploaded as CI artifact

### Security job

- Python dependency scan (`pip-audit`)
- Node dependency scan (`pnpm audit`)
- Secret scanning (`gitleaks`)
- Basic SAST (`semgrep`)
- Container scan (`trivy`) for API and Web images

## E2E pipeline

Workflow: `.github/workflows/e2e.yml`

Runs on:

- push to `main`
- nightly schedule
- manual dispatch

Stack boot:

- `deploy/compose.e2e.yml` starts `postgres`, `redis`, `meilisearch`, `api`, `worker`, `web`.
- `api/scripts/seed_dev.py --deterministic` seeds users/pros/packages/rollout city/proof metadata.

Playwright tests (`web/tests/e2e/smoke.spec.ts`) validate:

- login
- discover list load
- pro profile fetch
- booking request creation
- proofs screen load

Artifacts:

- Playwright reports + traces
- stack logs

## Deployment pipeline

Workflow: `.github/workflows/deploy.yml`

- On `main`: build+push images, deploy to staging.
- On tag `v*`: build+push images, deploy to production.

Compose manifests:

- `deploy/compose.staging.yml`
- `deploy/compose.prod.yml`

### Versioning + changelog

- Docker images tagged with `GITHUB_SHA` on branch deploys.
- Docker images tagged with Git tag (`v*`) on production releases.
- `deploy/changelog_notes.sh` generates release notes artifact from git history.

## Release gates (observability driven)

Script: `deploy/release_gate.py`

Checks:

- health endpoint (`/healthz`)
- readiness endpoint (`/health/ready`)
- Prometheus metrics when configured:
  - `error_rate` over 10m
  - `p95` latency over 10m
  - worker queue backlog

Thresholds:

- `staging`: looser thresholds
- `production`: stricter thresholds

Examples:

```bash
python3 deploy/release_gate.py --env staging --fail-open-if-no-metrics
python3 deploy/release_gate.py --env production
```

If no metrics backend exists yet, use `--fail-open-if-no-metrics` only for non-production gates.

## Canary / progressive rollout

Use feature flags for controlled exposure:

1. Deploy new build to staging or production (inactive for most users).
2. Enable flag for internal allowlist users only (rollout overrides).
3. Expand by city-level rollout gates.
4. Expand percentage rollout after observing SLOs and business KPIs.
5. Remove temporary allowlist rules after full rollout.

Suggested flags for rollout control:

- `client_browsing_enabled_global`
- `client_booking_enabled`
- `search_enabled`
- `proof_gallery_enabled`

## Local runbook

### CI-like API checks

```bash
cd api
poetry install --with dev
poetry run pytest -q
poetry run alembic upgrade head
poetry run alembic check
```

### E2E locally

```bash
docker compose -f deploy/compose.e2e.yml up -d --build
docker compose -f deploy/compose.e2e.yml exec -T api python scripts/seed_dev.py --deterministic
cd web
pnpm install
pnpm test:e2e
```

### Staging seed

```bash
cd api
python scripts/seed_staging.py --city "New York" --country US
```

## Rollback procedure

1. Identify last known-good image tag.
2. Update `IMAGE_TAG` in deploy env file (`deploy/.env.staging` or `deploy/.env.prod`).
3. Re-run compose deploy (`docker compose ... up -d`).
4. Run `deploy/release_gate.py` to confirm health.
5. Keep feature flags disabled for risky modules until incident is closed.

## Incident response hooks / kill switches

Immediate containment options:

- Disable `client_booking_enabled` to stop booking writes.
- Disable `search_enabled` or force fallback if search provider is degraded.
- Disable `proof_gallery_enabled` if gallery pipeline is unstable.
- For severe incidents, scale worker down or pause queues while preserving API reads.

After stabilization:

- capture timeline and metrics evidence
- add missing automated checks to CI/e2e/release gate
- update runbook and postmortem actions
