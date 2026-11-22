"""The production compose file, the Caddyfile and the images' build rules.

Read from the repository, no Docker needed. A service without a restart
policy, a memory limit, a health check or log rotation fails here, as does a
second beat, a published port other than Caddy's, an API that migrates at
start, an image build that would copy an .env file or run as root, and a
backup script that writes inside a Docker volume.
"""
from __future__ import annotations

import re
from pathlib import Path

import pytest
import yaml

REPO = Path(__file__).resolve().parents[2]
COMPOSE = REPO / "deploy" / "compose.prod.yml"
CADDYFILE = REPO / "deploy" / "Caddyfile"
BACKUP_SCRIPT = REPO / "deploy" / "scripts" / "backup-now.sh"

pytestmark = pytest.mark.skipif(not COMPOSE.is_file(), reason="needs the full repository checkout")


def _compose() -> dict:
    return yaml.safe_load(COMPOSE.read_text())


def _services() -> dict:
    return _compose()["services"]


def _command(svc: dict) -> str:
    command = svc.get("command") or ""
    return command if isinstance(command, str) else " ".join(map(str, command))


def _long_running() -> dict:
    return {name: svc for name, svc in _services().items() if "jobs" not in (svc.get("profiles") or [])}


def test_every_service_has_restart_memory_healthcheck_and_log_rotation():
    problems = []
    for name, svc in _long_running().items():
        if svc.get("restart") not in {"unless-stopped", "always"}:
            problems.append(f"{name}: no restart policy")
        if not (svc.get("mem_limit") or (svc.get("deploy") or {}).get("resources", {}).get("limits", {}).get("memory")):
            problems.append(f"{name}: no memory limit")
        health = svc.get("healthcheck") or {}
        if not health.get("test") or health.get("disable"):
            problems.append(f"{name}: no health check")
        logging = svc.get("logging") or {}
        options = logging.get("options") or {}
        if logging.get("driver") != "json-file" or not options.get("max-size") or not options.get("max-file"):
            problems.append(f"{name}: no log rotation")
    assert not problems, problems


def test_the_expected_services_are_there():
    assert {"postgres", "redis", "api", "worker", "worker-photos", "beat", "web", "caddy", "migrate"} <= set(_services())


def test_exactly_one_beat_and_it_keeps_its_schedule_in_tmp():
    beats = [n for n, s in _services().items() if re.search(r"celery .*\bbeat\b", _command(s))]
    assert beats == ["beat"], beats
    beat = _services()["beat"]
    assert "-s /tmp/celerybeat-schedule" in _command(beat)
    assert not (beat.get("deploy") or {}).get("replicas", 1) > 1


def test_only_caddy_publishes_ports():
    published = {n for n, s in _services().items() if s.get("ports")}
    assert published == {"caddy"}, published


def test_the_api_does_not_migrate_at_start():
    api = _command(_services()["api"])
    assert "alembic" not in api
    assert "--no-proxy-headers" in api
    migrate = _services()["migrate"]
    assert migrate["command"] == ["alembic", "upgrade", "head"]
    assert migrate.get("profiles") == ["jobs"] and migrate.get("restart") == "no"


def test_images_are_pulled_never_built_and_never_latest():
    for name, svc in _services().items():
        assert "build" not in svc, f"{name} builds on the server"
        image = svc["image"]
        assert ":latest" not in image and image.split(":")[-1], f"{name}: {image}"
    for name in ("api", "worker", "worker-photos", "beat", "migrate"):
        assert _services()[name]["image"].startswith("${API_IMAGE"), name
    assert _services()["web"]["image"].startswith("${WEB_IMAGE")


def test_the_network_subnet_is_pinned_and_trusted():
    subnet = _compose()["networks"]["default"]["ipam"]["config"][0]["subnet"]
    for name in ("api", "worker", "worker-photos", "beat", "migrate"):
        env = _services()[name]["environment"]
        assert env["TRUSTED_PROXY_IPS"] == subnet, name
        assert env["APP_ENV"] == "production"


def test_the_web_gets_only_what_it_needs():
    web = _services()["web"]
    assert "env_file" not in web
    assert set(web["environment"]) <= {"NODE_ENV", "API_BASE_URL", "ADMIN_API_KEY", "SENTRY_DSN", "PORT", "HOSTNAME"}


def test_caddy_hides_private_routes_and_answers_no_unknown_host():
    text = CADDYFILE.read_text()
    private = re.search(r"@private path (.+)", text).group(1).split()
    for route in ("/v1/admin/*", "/v1/dev/*", "/docs", "/openapi.json", "/metrics"):
        assert route in private, route
    assert "respond @private 404" in text
    assert re.search(r"http:// \{\s*abort\s*\}", text)
    assert "trusted_proxies" not in text, "Caddy must not believe a client's X-Forwarded-For"


@pytest.mark.parametrize("folder", ["api", "web"])
def test_no_env_file_or_key_goes_into_an_image(folder):
    ignored = {line.strip() for line in (REPO / folder / ".dockerignore").read_text().splitlines()}
    for pattern in (".env", ".env.*", "*.pem", "*.key"):
        assert pattern in ignored, f"{folder}/.dockerignore does not exclude {pattern}"


def test_the_api_image_runs_as_a_user_not_root():
    dockerfile = (REPO / "api" / "Dockerfile").read_text()
    runtime = dockerfile.split("FROM runtime AS dev")[0]
    users = re.findall(r"^USER\s+(\S+)", runtime, flags=re.M)
    assert users and users[-1] not in {"root", "0"}, users
    web = (REPO / "web" / "Dockerfile").read_text()
    web_users = re.findall(r"^USER\s+(\S+)", web.split("AS runner")[-1], flags=re.M)
    assert web_users and web_users[-1] not in {"root", "0"}, web_users


def test_the_backup_script_writes_outside_docker_volumes():
    text = BACKUP_SCRIPT.read_text()
    default = re.search(r'^BACKUP_DIR="\$\{BACKUP_DIR:-([^}]+)\}"', text, flags=re.M)
    assert default, "backup-now.sh sets BACKUP_DIR"
    assert not default.group(1).startswith("/var/lib/docker"), default.group(1)
    # And it refuses one there, whatever is passed.
    assert "/var/lib/docker" in text and "refuse" in text.lower()
