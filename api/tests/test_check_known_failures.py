"""The by-name check every commit's test run goes through."""
import importlib.util
from pathlib import Path

_spec = importlib.util.spec_from_file_location("check_known_failures", Path(__file__).resolve().parents[1] / "scripts" / "check_known_failures.py")
ckf = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(ckf)

KNOWN = {"tests/test_a.py::test_one", "tests/test_b.py::test_two"}
SUMMARY = """
ERROR    app.core.errors:errors.py:39 unhandled_exception
=========================== short test summary info ============================
FAILED tests/test_a.py::test_one - AssertionError: no
FAILED tests/test_b.py::test_two
{extra}
==== 2 failed, 900 passed in 10.00s ====
"""


def test_exactly_the_known_failures_is_clean():
    clean, _ = ckf.verdict(SUMMARY.format(extra=""), KNOWN)
    assert clean


def test_a_log_line_that_starts_with_error_is_not_an_errored_test():
    assert ckf.parse_run(SUMMARY.format(extra="")) == (KNOWN, set())


def test_any_errored_test_makes_the_run_not_clean_even_with_matching_failures():
    run = SUMMARY.format(extra="ERROR tests/test_c.py::test_setup[x-y] - sqlalchemy.exc.OperationalError: out of shared memory").replace(
        "2 failed, 900 passed", "2 failed, 900 passed, 1 error"
    )
    clean, lines = ckf.verdict(run, KNOWN)
    assert not clean
    assert "errored: tests/test_c.py::test_setup[x-y]" in lines


def test_a_new_failure_or_a_fixed_one_is_not_clean():
    new = SUMMARY.format(extra="FAILED tests/test_d.py::test_new").replace("2 failed", "3 failed")
    assert ckf.verdict(new, KNOWN)[0] is False
    fixed = SUMMARY.format(extra="").replace("FAILED tests/test_b.py::test_two\n", "").replace("2 failed", "1 failed")
    clean, lines = ckf.verdict(fixed, KNOWN)
    assert not clean and "fixed: tests/test_b.py::test_two" in lines


def test_the_real_known_failures_file_parses():
    known = ckf.read_known(Path(__file__).resolve().parents[2] / "docs" / "KNOWN_FAILURES.txt")
    assert known and all(name.startswith("tests/") and "::" in name for name in known)


def test_errors_the_run_did_not_list_still_make_it_not_clean():
    """The 2026-10-14 runs used -rf: 13 errors counted on the last line, none
    named. Matching failure names must not read as clean."""
    run = SUMMARY.format(extra="").replace("2 failed, 900 passed", "2 failed, 900 passed, 13 errors")
    clean, lines = ckf.verdict(run, KNOWN)
    assert not clean
    assert any("run with -rfE" in line for line in lines)


def test_a_run_that_never_finished_is_not_clean():
    clean, _ = ckf.verdict("FAILED tests/test_a.py::test_one\nFAILED tests/test_b.py::test_two\n", KNOWN)
    assert not clean
