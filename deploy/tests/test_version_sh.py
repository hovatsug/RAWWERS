"""version.sh: does the checkout need new images, or not?

After a tag that changes only scripts and docs (for example deploy-test-2),
the checkout is ahead of IMAGE_TAG on purpose. version.sh says which of these
it is, so "checkout commit differs from IMAGE_TAG" no longer reads as a
mistake (DEPLOY_RUNBOOK, "After every deploy").
"""
from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

from conftest import NO_NETWORK, SCRIPTS, executable


def _git(repo: Path, *args: str) -> str:
    env = {**os.environ, "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@example.invalid",
           "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@example.invalid"}
    return subprocess.run(["git", "-C", str(repo), *args], check=True, capture_output=True, text=True, env=env).stdout.strip()


def _commit(repo: Path, path: str, text: str) -> str:
    target = repo / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text)
    _git(repo, "add", "-A")
    _git(repo, "commit", "-q", "-m", f"change {path}")
    return _git(repo, "rev-parse", "HEAD")


def _setup(tmp_path: Path) -> tuple[Path, Path, dict]:
    repo = tmp_path / "src"
    (repo / "deploy" / "scripts").mkdir(parents=True)
    shutil.copy(SCRIPTS / "version.sh", repo / "deploy" / "scripts" / "version.sh")
    _git(repo, "init", "-q")
    dc = executable(tmp_path / "dc", "#!/usr/bin/env bash\nexit 0\n")
    env_file = tmp_path / "env.production"
    env = {**os.environ, **NO_NETWORK, "RAWWERS_DC": str(dc), "RAWWERS_ENV_FILE": str(env_file)}
    return repo, env_file, env


def _images_line(repo: Path, env: dict) -> str:
    done = subprocess.run(["bash", str(repo / "deploy" / "scripts" / "version.sh")], capture_output=True, text=True, env=env, timeout=60)
    lines = [l for l in done.stdout.splitlines() if l.startswith("images ")]
    assert len(lines) == 1, done.stdout + done.stderr
    return lines[0]


def test_same_commit(tmp_path):
    repo, env_file, env = _setup(tmp_path)
    first = _commit(repo, "api/app.py", "1")
    env_file.write_text(f"IMAGE_TAG={first[:12]}\n")
    assert "same commit as the checkout" in _images_line(repo, env)


def test_ahead_with_only_scripts_and_docs_needs_no_rebuild(tmp_path):
    repo, env_file, env = _setup(tmp_path)
    first = _commit(repo, "api/app.py", "1")
    _commit(repo, "web/page.tsx", "1")
    env_file.write_text(f"IMAGE_TAG={_git(repo, 'rev-parse', '--short=12', 'HEAD')}\n")
    _commit(repo, "deploy/scripts/backup-offsite.sh", "new")
    _commit(repo, "docs/RESTORE_PLAYBOOK.md", "new")
    line = _images_line(repo, env)
    assert "checkout is 2 commits after IMAGE_TAG" in line and "api/ and web/ unchanged since: no rebuild needed" in line
    assert first


def test_api_or_web_changed_needs_new_images(tmp_path):
    repo, env_file, env = _setup(tmp_path)
    _commit(repo, "api/app.py", "1")
    env_file.write_text(f"IMAGE_TAG={_git(repo, 'rev-parse', '--short=12', 'HEAD')}\n")
    _commit(repo, "docs/x.md", "1")
    _commit(repo, "web/page.tsx", "2")
    assert "api/ or web/ CHANGED since IMAGE_TAG: build and push new images" in _images_line(repo, env)


def test_checkout_behind_the_images(tmp_path):
    repo, env_file, env = _setup(tmp_path)
    first = _commit(repo, "api/app.py", "1")
    second = _commit(repo, "api/app.py", "2")
    env_file.write_text(f"IMAGE_TAG={second[:12]}\n")
    _git(repo, "checkout", "-q", first)
    assert "checkout is BEHIND IMAGE_TAG" in _images_line(repo, env)


def test_unknown_or_missing_image_tag(tmp_path):
    repo, env_file, env = _setup(tmp_path)
    _commit(repo, "api/app.py", "1")
    env_file.write_text("IMAGE_TAG=0123456789ab\n")
    assert "is not a commit in this checkout" in _images_line(repo, env)
    env_file.write_text("API_IMAGE=ghcr.io/example/rawwers-api\n")
    assert "no IMAGE_TAG in the secrets file" in _images_line(repo, env)
