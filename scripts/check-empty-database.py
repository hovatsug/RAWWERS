"""The empty-database check (docs/DEPLOY_CHECKLIST.md section 0, steps 3-5).

Run against an API that has just been started, with production-like
settings, on a database that `alembic upgrade head` has just created and
nothing else has touched. Checks, in the checklist's order:

  3. GET /healthz answers 200;
  4. the public reads: the 12 niches (created on first use), Discover with
     nobody in it, the exchange rates, the OpenAPI document;
  5. the first account: register answers 201 with a user id, and that
     account can sign in.

The admin part of step 5 needs ADMIN_USER_IDS and a restart, and steps 6
and 7 need data loaded by hand: they stay manual. Standard library only, so
CI runs it without installing anything.

    python scripts/check-empty-database.py http://localhost:8000
"""
from __future__ import annotations

import json
import sys
import urllib.error
import urllib.request

BASE = (sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000").rstrip("/")
# A throw-away account on a throw-away database: no real address, no real password.
EMAIL = "first-admin@example.invalid"
PASSWORD = "empty-database-check-0123"

failures: list[str] = []


def call(method: str, path: str, body: dict | None = None, *, timeout: int = 30) -> tuple[int, object]:
    request = urllib.request.Request(
        BASE + path,
        method=method,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(request, timeout=timeout) as answer:
            raw = answer.read()
            return answer.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as error:
        raw = error.read()
        try:
            return error.code, json.loads(raw) if raw else None
        except ValueError:
            return error.code, None
    except OSError as error:  # refused, reset, timed out: a failed check, not a traceback
        return 0, str(error)


def expect(step: str, ok: bool, detail: object = "") -> None:
    print(("ok   " if ok else "FAIL ") + step + (f"  ({detail})" if detail and not ok else ""))
    if not ok:
        failures.append(step)


status, _ = call("GET", "/healthz")
expect("3 GET /healthz is 200", status == 200, status)

status, niches = call("GET", "/v1/niches")
expect("4 GET /v1/niches lists 12 niches", status == 200 and isinstance(niches, list) and len(niches) == 12,
       f"{status}, {len(niches) if isinstance(niches, list) else niches}")
status, discover = call("GET", "/v1/discover/pros")
expect("4 GET /v1/discover/pros is 200", status == 200, status)
status, _ = call("GET", "/v1/fx/rates")
expect("4 GET /v1/fx/rates is 200", status == 200, status)
# Production serves no API docs (API_DOCS_ENABLED, core/production_guard.py).
status, _ = call("GET", "/openapi.json")
expect("4 GET /openapi.json is 404 (no docs in production)", status == 404, status)
status, _ = call("GET", "/docs")
expect("4 GET /docs is 404 (no docs in production)", status == 404, status)

status, account = call("POST", "/v1/auth/register", {"email": EMAIL, "password": PASSWORD, "display_name": "First Admin"})
user_id = account.get("user_id") if isinstance(account, dict) else None
expect("5 the first account registers (201, a user id)", status == 201 and bool(user_id), f"{status}, {account}")
status, login = call("POST", "/v1/auth/login", {"email": EMAIL, "password": PASSWORD})
expect("5 the first account signs in", status == 200 and isinstance(login, dict) and bool(login.get("access_token")), status)

if failures:
    print(f"{len(failures)} check(s) failed")
    sys.exit(1)
print("The empty database works")
