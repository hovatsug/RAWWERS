"""Dev only: set the settlement delay to 0 for the Stage 1 loop, and put the
fee policy back exactly as it was afterwards (docs/STAGE1_LOOP.md, 0.4 and
12.1).

PUT /v1/admin/finance/fee-policy replaces every field it takes, so this
reads the policy first, saves it, changes only settlement_delay_days, sends
every field back, and reads it again to check nothing else moved. `restore`
sends the saved values back and checks them the same way.

    python3 -I docs/stage1-loop/fee_policy_delay.py set0
    python3 -I docs/stage1-loop/fee_policy_delay.py restore
    python3 -I docs/stage1-loop/fee_policy_delay.py show

Admin routes also need the admin API key: pass it as RAWWERS_ADMIN_API_KEY,
read from web/.env.local by the command in STAGE1_LOOP.md so it never
appears on a command line. It asks for the admin password (not echoed)
unless RAWWERS_ADMIN_PASSWORD is set. The key, the password and the token
stay inside this process and are never printed.
Only a dev API is accepted (localhost or a .local host): never production.
Standard library only.
"""
import getpass
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

API = os.environ.get("RAWWERS_API", "http://localhost:8000").rstrip("/")
ADMIN_EMAIL = os.environ.get("RAWWERS_ADMIN_EMAIL", "admin@rawwers.dev")
BACKUP = Path.home() / ".rawwers" / "fee-policy-before-stage1-loop.json"
FIELDS = ("fee_percent_gigs", "fee_percent_extras", "fee_percent_studioverse", "settlement_delay_days", "dispute_hold_days")


def stop(message: str) -> None:
    print(f"STOP: {message}", file=sys.stderr)
    sys.exit(1)


def dev_only() -> None:
    host = urllib.parse.urlparse(API).hostname or ""
    if not (host in ("localhost", "127.0.0.1") or host.endswith(".local")):
        stop(f"{API} is not a dev API (localhost or .local). This script never touches production.")


def call(method: str, path: str, token: str | None = None, body: dict | None = None) -> dict:
    request = urllib.request.Request(f"{API}/v1{path}", method=method, data=None if body is None else json.dumps(body).encode())
    request.add_header("Content-Type", "application/json")
    request.add_header("X-Admin-Api-Key", os.environ.get("RAWWERS_ADMIN_API_KEY", ""))
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        stop(f"{method} {path} answered {error.code}: {error.read().decode(errors='replace')[:300]}")


def login() -> str:
    password = os.environ.get("RAWWERS_ADMIN_PASSWORD") or getpass.getpass(f"Password for {ADMIN_EMAIL}: ")
    return call("POST", "/auth/login", body={"email": ADMIN_EMAIL, "password": password})["access_token"]


def policy(token: str) -> dict:
    row = call("GET", "/admin/finance/fee-policy", token)
    return {field: row[field] for field in ("id", *FIELDS)}


def show(label: str, row: dict) -> None:
    print(f"{label}: " + ", ".join(f"{field}={row[field]}" for field in FIELDS))


def put_and_check(token: str, wanted: dict) -> None:
    call("PUT", "/admin/finance/fee-policy", token, {field: wanted[field] for field in FIELDS})
    now = policy(token)
    show("now", now)
    differ = [field for field in ("id", *FIELDS) if now[field] != wanted[field]]
    if differ:
        stop(f"after the change these differ from what was sent: {', '.join(differ)}")


def set0() -> None:
    if BACKUP.exists():
        stop(f"{BACKUP} already exists: an earlier run was not restored. Run `restore` first.")
    token = login()
    before = policy(token)
    show("before", before)
    if before["settlement_delay_days"] == 0:
        stop("the delay is already 0, so the original value is unknown. Set it back by hand first.")
    BACKUP.parent.mkdir(mode=0o700, exist_ok=True)
    BACKUP.write_text(json.dumps(before, indent=2) + "\n")
    BACKUP.chmod(0o600)
    print(f"saved to {BACKUP}")
    put_and_check(token, {**before, "settlement_delay_days": 0})
    print("OK: settlement_delay_days is 0, every other field unchanged.")


def restore() -> None:
    if not BACKUP.exists():
        stop(f"{BACKUP} not found: nothing to restore.")
    saved = json.loads(BACKUP.read_text())
    token = login()
    current = policy(token)
    show("saved", saved)
    show("before restore", current)
    moved = [field for field in ("id", *FIELDS) if field != "settlement_delay_days" and current[field] != saved[field]]
    if moved:
        stop(f"since the save, these changed too: {', '.join(moved)}. Not overwriting them; report this.")
    put_and_check(token, saved)
    BACKUP.rename(BACKUP.with_suffix(".restored.json"))
    print("OK: the fee policy is back to the saved values.")


if __name__ == "__main__":
    dev_only()
    if not os.environ.get("RAWWERS_ADMIN_API_KEY"):
        stop("RAWWERS_ADMIN_API_KEY is not set (see docs/STAGE1_LOOP.md, 0.4).")
    command = sys.argv[1] if len(sys.argv) > 1 else ""
    if command == "set0":
        set0()
    elif command == "restore":
        restore()
    elif command == "show":
        show("now", policy(login()))
    else:
        stop("usage: fee_policy_delay.py set0 | restore | show")
