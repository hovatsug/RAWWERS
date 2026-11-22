"""The deploy scripts' safety rules (deploy/scripts/), run as the owner would.

- smoke.py sends nothing without an explicit --api URL, and its write steps
  run only when --write names that same host;
- generate-secrets.sh fills every generated value, makes the file readable by
  its owner only, and never overwrites an existing file;
- backup-now.sh refuses a folder inside Docker's own storage.
None of these reach the network.
"""
from __future__ import annotations

import os
import re
import stat
import subprocess
import sys
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parents[2]
SCRIPTS = REPO / "deploy" / "scripts"

pytestmark = pytest.mark.skipif(not SCRIPTS.is_dir(), reason="needs the full repository checkout")


#: Every HTTP request of the script goes to a closed local port, so even a
#: broken script reaches nothing outside this machine; .invalid never resolves.
NO_NETWORK = {**os.environ, "HTTPS_PROXY": "http://127.0.0.1:9", "HTTP_PROXY": "http://127.0.0.1:9", "NO_PROXY": ""}
OFFLINE = ["--admin", "https://admin.invalid", "--insecure-tls", "--no-redirect-check"]


def _run(args: list[str], **kw) -> subprocess.CompletedProcess:
    kw.setdefault("env", NO_NETWORK)
    return subprocess.run(args, capture_output=True, text=True, timeout=120, **kw)


def test_smoke_needs_the_urls_on_the_command_line():
    done = _run([sys.executable, str(SCRIPTS / "smoke.py")])
    assert done.returncode == 2
    assert "required" in done.stderr
    # Without --api there is no default to fall back on: nothing is sent.
    done = _run([sys.executable, str(SCRIPTS / "smoke.py"), *OFFLINE])
    assert done.returncode == 2, done.stdout + done.stderr
    assert "API " not in done.stdout


def test_smoke_writes_only_to_the_host_it_names():
    done = _run([
        sys.executable, str(SCRIPTS / "smoke.py"),
        "--api", "https://api.invalid", *OFFLINE, "--write", "api.example.org",
    ])
    assert done.returncode == 2
    assert "Nothing was sent" in done.stdout


def test_smoke_refuses_a_url_that_is_not_one():
    done = _run([sys.executable, str(SCRIPTS / "smoke.py"), "--api", "api.invalid", *OFFLINE])
    assert done.returncode == 2
    assert "Nothing was sent" in done.stdout


def test_generate_secrets_fills_every_value_and_never_overwrites(tmp_path):
    target = tmp_path / "env.production"
    done = _run(["bash", str(SCRIPTS / "generate-secrets.sh"), str(target)])
    assert done.returncode == 0, done.stderr
    text = target.read_text()
    assert "<GENERATED_" not in "\n".join(line for line in text.splitlines() if not line.startswith("#"))
    assert stat.S_IMODE(os.stat(target).st_mode) == 0o600
    values = dict(re.findall(r"^([A-Z_]+)=(.*)$", text, flags=re.M))
    assert re.fullmatch(r"[0-9a-f]{64}", values["AUTH_JWT_SECRET"])
    assert re.fullmatch(r"[0-9a-f]{48}", values["POSTGRES_PASSWORD"])
    assert values["UNSUBSCRIBE_SIGNING_KEYS"].startswith("k1:")
    peppers = [values[k] for k in values if k.endswith("_PEPPER")]
    assert len(peppers) == 6 and len(set(peppers)) == 6, "every generated value is its own"
    from cryptography.fernet import Fernet

    Fernet(values["ADDRESS_ENCRYPTION_KEYS"])
    assert values["DEPLOYMENT_MODE"] == "test"
    assert "<FROM" in values["STRIPE_SECRET_KEY"], "service values stay placeholders, which the guard refuses"

    before = target.read_text()
    again = _run(["bash", str(SCRIPTS / "generate-secrets.sh"), str(target)])
    assert again.returncode == 2
    assert target.read_text() == before


def test_backup_refuses_docker_storage(tmp_path):
    env = {**os.environ, "BACKUP_DIR": "/var/lib/docker/volumes/rawwers_postgres_data/_data", "RAWWERS_ENV_FILE": "/dev/null"}
    done = _run(["bash", str(SCRIPTS / "backup-now.sh")], env=env)
    assert done.returncode == 2
    assert "refuse" in done.stderr
