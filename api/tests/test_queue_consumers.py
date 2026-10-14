"""Every queue a task is routed to has a worker listening to it, in every
compose file that actually runs.

Photo processing moved to its own `photos` queue. A queue with no consumer
does not fail - tasks simply pile up in Redis and nothing happens: uploads
would sit in "processing" forever while every test of the task itself
passed. This reads the real routing table and the real compose files, so a
new route, or a stack that forgets a worker, fails here instead.

"Actually runs" is read from the workflows (every `-f <compose file>` they
invoke) plus the local dev stack, rather than listed by hand - a list here
would be one more thing to forget to update.
"""
import re
from pathlib import Path

import pytest
from app.tasks.celery_app import celery_app

REPO = Path(__file__).resolve().parents[2]
WORKFLOWS = REPO / ".github" / "workflows"
DEV_STACK = REPO / "api" / "docker-compose.yml"


def _running_compose_files() -> list[Path]:
    assert WORKFLOWS.is_dir(), (
        f"{WORKFLOWS} not found: this test reads the repository's workflows and compose files, "
        "so it must run from a full checkout (CI does)"
    )
    files = {DEV_STACK}
    for workflow in WORKFLOWS.glob("*.y*ml"):
        for match in re.finditer(r"-f\s+(\S*compose[\w.-]*\.ya?ml)", workflow.read_text()):
            files.add(REPO / match.group(1))
    return sorted(files)


def _routed_queues() -> set[str]:
    default = celery_app.conf.task_default_queue
    routes = celery_app.conf.task_routes or {}
    return {default} | {route["queue"] for route in routes.values() if "queue" in route}


def _consumed_queues(compose: Path) -> set[str]:
    """Queues served by the Celery workers in one compose file. A worker with
    no -Q serves the default queue."""
    consumed: set[str] = set()
    for command in re.findall(r"^\s*command:\s*(.+)$", compose.read_text(), flags=re.M):
        if "celery" not in command or " worker" not in command:
            continue
        queues = re.search(r"(?:-Q|--queues)[\s=]+(\S+)", command)
        consumed |= set(queues.group(1).split(",")) if queues else {celery_app.conf.task_default_queue}
    return consumed


def test_the_stacks_that_deploy_are_found():
    names = {path.relative_to(REPO).as_posix() for path in _running_compose_files()}
    assert {"deploy/compose.prod.yml", "deploy/compose.staging.yml"} <= names, names


@pytest.mark.parametrize("compose", _running_compose_files() if WORKFLOWS.is_dir() else [], ids=lambda p: p.name)
def test_every_routed_queue_has_a_worker(compose):
    assert compose.is_file(), f"a workflow runs {compose}, which does not exist"
    missing = _routed_queues() - _consumed_queues(compose)
    assert not missing, f"{compose.relative_to(REPO)}: no worker consumes {sorted(missing)}"


# The stacks that run the scheduler: the two deployed ones and the dev stack.
# The `deploy/docker-compose.*` pair are stale copies with no beat at all -
# DEPLOY_CHECKLIST says never to use them - and the e2e stack runs no
# scheduler by design.
SCHEDULED_STACKS = ["deploy/compose.prod.yml", "deploy/compose.staging.yml", "api/docker-compose.yml"]
SWEEP_SETTING = "BOOKING_REQUEST_EXPIRY_SWEEP_INTERVAL_SECONDS"


def _example_env(compose: Path) -> Path | None:
    """The committed example of the env file a stack reads, if any."""
    for name in re.findall(r"env_file:\s*\n?\s*-?\s*(\S*\.env[\w.-]*)", compose.read_text()):
        example = (compose.parent / name).resolve()
        for candidate in (example.with_name(example.name + ".example"), REPO / (name.lstrip("./") + ".example")):
            if candidate.is_file():
                return candidate
    return None


@pytest.mark.parametrize("stack", SCHEDULED_STACKS)
def test_every_scheduled_stack_runs_the_sweeps_every_minute(stack):
    """Request expiry and unpaid bookings are swept every 60 seconds - a
    short-notice request has 30 minutes. That holds only where beat runs and
    nothing overrides the interval."""
    compose = REPO / stack
    text = compose.read_text()
    assert re.search(r"^\s*command:.*celery.*\bbeat\b", text, flags=re.M), f"{stack} runs no beat: nothing is swept"
    assert SWEEP_SETTING not in text, f"{stack} overrides the sweep interval"
    example = _example_env(compose)
    if example is not None:
        assert SWEEP_SETTING not in example.read_text(), f"{example.relative_to(REPO)} overrides the sweep interval"
    schedule = celery_app.conf.beat_schedule
    for name in ("expire-booking-requests", "expire-unpaid-gigs"):
        assert schedule[name]["schedule"].total_seconds() == 60, name
