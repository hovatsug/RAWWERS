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


def _fake_docker(tmp_path, platform: str) -> dict:
    """A `docker` that answers check-image.sh's questions about one image
    without Docker: user 10001, the given platform, nothing found inside."""
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    fake = bin_dir / "docker"
    fake.write_text(
        "#!/usr/bin/env bash\n"
        'case "$*" in\n'
        '  *Config.User*) echo 10001 ;;\n'
        f'  *Architecture*) echo {platform} ;;\n'
        '  *Size*) echo 1048576 ;;\n'
        '  *) : ;;\n'
        "esac\n"
    )
    fake.chmod(0o755)
    return {**os.environ, "PATH": f"{bin_dir}:{os.environ['PATH']}"}


def test_check_image_refuses_an_image_for_another_processor(tmp_path):
    env = _fake_docker(tmp_path, "linux/arm64")
    done = _run(["bash", str(SCRIPTS / "check-image.sh"), "example/rawwers-api:test"], env=env)
    assert done.returncode == 1, done.stdout
    assert "built for linux/arm64" in done.stdout and "exec format error" in done.stdout

    (tmp_path / "amd64").mkdir()
    env = _fake_docker(tmp_path / "amd64", "linux/amd64")
    done = _run(["bash", str(SCRIPTS / "check-image.sh"), "example/rawwers-api:test"], env=env)
    assert done.returncode == 0, done.stdout
    assert "ok    built for linux/amd64" in done.stdout


def test_build_and_push_builds_for_the_server_and_checks_those_images():
    text = (SCRIPTS / "build-and-push.sh").read_text()
    assert 'PLATFORM="linux/amd64"' in text
    assert "${PLATFORM:-" not in text, "the platform is never taken from the environment"
    builds = [line for line in text.splitlines() if line.startswith("docker buildx build")]
    assert len(builds) == 2 and all('--platform "$PLATFORM"' in b for b in builds)
    assert '-t "$API_TAG"' in builds[0] and '-t "$WEB_TAG"' in builds[1]
    assert 'EXPECT_PLATFORM="$PLATFORM" "$HERE/check-image.sh" "$API_TAG" "$WEB_TAG"' in text
    # The check runs before any push.
    assert text.index("check-image.sh\" \"$API_TAG\"") < text.index('docker push "$API_TAG"')
