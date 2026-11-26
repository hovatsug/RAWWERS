"""Shared helpers for the deploy-script tests (deploy/tests/).

Run from the repository root, with a throwaway Postgres:

    NATIVE_DB_ROOT=1 tools/tests/native-db.sh deploy/tests -q

Nothing here reaches the network or a real bucket:
- `dc` is a fake that runs the container's command on this Mac, against the
  throwaway Postgres that native-db.sh started (TEST_DATABASE_URL);
- `rclone` is a fake whose "bucket" is a local folder;
- `curl` is a fake that only writes down what it was asked to send;
- `systemctl` is a fake that only writes down what it was asked to do.
`age` is the real tool (it never touches the network). Every key and
"secret" here is made up by the test.
"""
from __future__ import annotations

import os
import shutil
import stat
import subprocess
import uuid
from pathlib import Path
from urllib.parse import urlparse

import pytest

REPO = Path(__file__).resolve().parents[2]
SCRIPTS = REPO / "deploy" / "scripts"
SYSTEMD = REPO / "deploy" / "systemd"

#: Any HTTP a broken script might still try goes to a closed local port.
NO_NETWORK = {"HTTPS_PROXY": "http://127.0.0.1:9", "HTTP_PROXY": "http://127.0.0.1:9", "NO_PROXY": ""}

#: The irreplaceable secrets the off-server backup carries, by name.
IRREPLACEABLE = [
    "ADDRESS_ENCRYPTION_KEYS",
    "UNSUBSCRIBE_SIGNING_KEYS",
    "MEDIA_SHARE_TOKEN_PEPPER",
    "MEDIA_ACCESS_IP_HASH_PEPPER",
    "SHARE_VIEW_FINGERPRINT_PEPPER",
    "RISK_IP_HASH_PEPPER",
    "RISK_DEVICE_HASH_PEPPER",
    "RISK_SESSION_HASH_PEPPER",
]


def pg_bin() -> Path:
    for candidate in (os.environ.get("PG_BIN"), "/usr/local/opt/postgresql@16/bin", "/opt/homebrew/opt/postgresql@16/bin"):
        if candidate and (Path(candidate) / "pg_dump").exists():
            return Path(candidate)
    raise RuntimeError("no Postgres 16 tools found: set PG_BIN or brew install postgresql@16")


def age_bin() -> Path:
    for candidate in (os.environ.get("AGE"), shutil.which("age"), str(Path.home() / "Developer/RAWWERS-work/bin/age")):
        if candidate and Path(candidate).exists():
            return Path(candidate)
    raise RuntimeError("no age found: see docs/RESTORE_PLAYBOOK.md, 'On the Mac, once'")


def executable(path: Path, text: str) -> Path:
    path.write_text(text)
    path.chmod(0o755)
    return path


class Pg:
    """The throwaway Postgres native-db.sh started, one new database per test."""

    def __init__(self) -> None:
        url = os.environ.get("TEST_DATABASE_URL")
        if not url:
            raise RuntimeError("run these tests through tools/tests/native-db.sh (NATIVE_DB_ROOT=1)")
        parsed = urlparse(url.replace("postgresql+psycopg2://", "postgresql://"))
        self.host = parsed.hostname or "127.0.0.1"
        self.port = str(parsed.port or 5432)
        self.user = parsed.username or "postgres"
        self.bin = pg_bin()

    def env(self, db: str) -> dict:
        return {"PGHOST": self.host, "PGPORT": self.port, "PGUSER": self.user, "POSTGRES_USER": self.user, "POSTGRES_DB": db}

    def psql(self, db: str, sql: str) -> str:
        done = subprocess.run(
            [str(self.bin / "psql"), "-X", "-q", "-At", "-v", "ON_ERROR_STOP=1", "-d", db, "-c", sql],
            capture_output=True, text=True, env={**os.environ, **self.env(db)}, timeout=60,
        )
        assert done.returncode == 0, done.stderr
        return done.stdout.strip()

    def new_database(self) -> str:
        name = f"deploytest_{uuid.uuid4().hex[:10]}"
        self.psql("postgres", f"CREATE DATABASE {name}")
        return name


@pytest.fixture(scope="session")
def pg() -> Pg:
    return Pg()


@pytest.fixture()
def small_db(pg: Pg) -> str:
    """A database shaped like ours in the ways the backup cares about."""
    db = pg.new_database()
    pg.psql(
        db,
        "CREATE EXTENSION btree_gist;"
        "CREATE TABLE alembic_version (version_num varchar(32) PRIMARY KEY);"
        "INSERT INTO alembic_version VALUES ('20261114_0098');"
        "CREATE TABLE user_account (id serial PRIMARY KEY, email text);"
        "INSERT INTO user_account (email) SELECT 'u' || g || '@example.invalid' FROM generate_series(1, 7) g;"
        "CREATE TABLE stripe_payment (id serial PRIMARY KEY, amount_minor int);"
        "INSERT INTO stripe_payment (amount_minor) SELECT g * 100 FROM generate_series(1, 3) g;"
        "CREATE TABLE payout_transfer (id serial PRIMARY KEY);",
    )
    return db


@pytest.fixture()
def fake_bin(tmp_path: Path, pg: Pg) -> Path:
    """A folder of fakes, first on PATH: dc, rclone, curl, systemctl."""
    bin_dir = tmp_path / "fakebin"
    bin_dir.mkdir()
    # dc: `dc exec -T postgres <command...>` runs <command...> here, against
    # the throwaway Postgres (POSTGRES_USER/POSTGRES_DB as in the container).
    executable(
        bin_dir / "dc",
        "#!/usr/bin/env bash\n"
        "set -e\n"
        'echo "dc $*" >> "$FAKE_LOG_DIR/dc.log"\n'
        '[[ "$1" == exec ]] || { echo "fake dc: only exec" >&2; exit 2; }\n'
        "shift\n"
        '[[ "$1" == -T ]] && shift\n'
        '[[ "$1" == postgres ]] || { echo "fake dc: only the postgres service" >&2; exit 2; }\n'
        "shift\n"
        f'export PATH="{pg.bin}:$PATH"\n'
        'exec "$@"\n',
    )
    # rclone: remote "rawwersbk:<bucket>/<key>" is "$FAKE_BUCKET_ROOT/<bucket>/<key>".
    executable(
        bin_dir / "rclone",
        "#!/usr/bin/env bash\n"
        "set -euo pipefail\n"
        'log="$FAKE_LOG_DIR/rclone.log"\n'
        'echo "argv: $*" >> "$log"\n'
        'echo "provider=${RCLONE_CONFIG_RAWWERSBK_PROVIDER:-} endpoint=${RCLONE_CONFIG_RAWWERSBK_ENDPOINT:-} type=${RCLONE_CONFIG_RAWWERSBK_TYPE:-} nocheck=${RCLONE_CONFIG_RAWWERSBK_NO_CHECK_BUCKET:-} keyset=$([[ -n ${RCLONE_CONFIG_RAWWERSBK_SECRET_ACCESS_KEY:-} ]] && echo yes || echo no)" >> "$log"\n'
        'args=(); for a in "$@"; do case "$a" in --*) ;; *) args+=("$a") ;; esac; done\n'
        'path() { local r="${1#rawwersbk:}"; echo "$FAKE_BUCKET_ROOT/$r"; }\n'
        'case "${args[0]}" in\n'
        '  version) echo "rclone v1.60.1-DEV (fake)" ;;\n'
        '  copyto)\n'
        '    [[ -n "${FAKE_RCLONE_FAIL_UPLOAD:-}" ]] && { echo "fake upload failure" >&2; exit 1; }\n'
        '    dest="$(path "${args[2]}")"; mkdir -p "$(dirname "$dest")"; cp "${args[1]}" "$dest" ;;\n'
        '  cat)\n'
        '    src="$(path "${args[1]}")"\n'
        '    if [[ -n "${FAKE_RCLONE_CORRUPT:-}" ]]; then cat "$src"; printf x; else cat "$src"; fi ;;\n'
        '  lsf)\n'
        '    d="$(path "${args[1]}")"; [[ -d "$d" ]] || { echo "directory not found" >&2; exit 3; }; ls -1 "$d" ;;\n'
        '  *) echo "fake rclone: unknown ${args[0]}" >&2; exit 2 ;;\n'
        "esac\n",
    )
    # curl: writes down the URL's query and the body, sends nothing.
    executable(
        bin_dir / "curl",
        "#!/usr/bin/env bash\n"
        'echo "argv: $*" >> "$FAKE_LOG_DIR/curl.log"\n'
        'exit "${FAKE_CURL_EXIT:-0}"\n',
    )
    executable(
        bin_dir / "systemctl",
        "#!/usr/bin/env bash\n"
        'echo "systemctl $*" >> "$FAKE_LOG_DIR/systemctl.log"\n',
    )
    return bin_dir


@pytest.fixture()
def age_key(tmp_path: Path) -> tuple[Path, str]:
    """A made-up age key pair: (private key file, public key)."""
    keygen = age_bin().parent / "age-keygen"
    key = tmp_path / "test-age-key.txt"
    subprocess.run([str(keygen), "-o", str(key)], check=True, capture_output=True)
    public = subprocess.run([str(keygen), "-y", str(key)], check=True, capture_output=True, text=True).stdout.strip()
    return key, public


def mode_of(path: Path) -> int:
    return stat.S_IMODE(path.stat().st_mode)
