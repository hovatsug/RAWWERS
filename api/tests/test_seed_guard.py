"""Seeding must not be able to reach a live marketplace.

`seed_dev.py` and `seed_staging.py` are two argument parsers around one
function, so before this the only thing separating dev data from production
was the filename someone typed. Seeding creates users, writes pro profiles
and rewrites the discovery index; there is no undo for that against real
data.
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from _seed_common import assert_environment_is_seedable  # noqa: E402


@pytest.mark.parametrize("environment", ["production", "prod", "PRODUCTION", "live", "prd"])
def test_refuses_anything_that_is_not_clearly_development(monkeypatch, environment):
    monkeypatch.setenv("APP_ENV", environment)
    with pytest.raises(RuntimeError, match="Refusing to seed"):
        assert_environment_is_seedable()


@pytest.mark.parametrize("environment", ["development", "dev", "local", "test", "staging", "Development"])
def test_permits_a_development_environment(monkeypatch, environment):
    """A guard that refuses everything is as useless as one that refuses
    nothing - it just gets deleted by whoever needs to seed."""
    monkeypatch.setenv("APP_ENV", environment)
    assert_environment_is_seedable() is None


def test_an_unset_environment_is_treated_as_development(monkeypatch):
    """Matching the app's own default, so a bare local checkout still seeds."""
    monkeypatch.delenv("APP_ENV", raising=False)
    assert_environment_is_seedable() is None


def test_the_guard_is_on_the_shared_path_not_the_entry_points():
    """Both scripts call seed_environment, so the check belongs there. Putting
    it in seed_dev.py would leave seed_staging.py unguarded, which is exactly
    the gap that existed."""
    import inspect

    from _seed_common import seed_environment

    body = inspect.getsource(seed_environment)
    assert "assert_environment_is_seedable()" in body
