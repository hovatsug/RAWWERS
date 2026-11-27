"""deploy/scripts/acceptance.py: the refusals, the photos it makes, the
amounts it expects, the run file, and the MANUAL steps. No network: every
call goes to a fake transport that records it. (The whole book and payout
phases against the real API, through the test client, are in
api/tests/test_acceptance_against_the_api.py.)

    NATIVE_DB_ROOT=1 tools/tests/native-db.sh deploy/tests
"""
from __future__ import annotations

import hashlib
import importlib.util
import io
import json
import stat
import sys
from decimal import Decimal as D

import pytest

from conftest import SCRIPTS


def _load():
    spec = importlib.util.spec_from_file_location("acceptance", SCRIPTS / "acceptance.py")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module  # dataclasses look the module up
    spec.loader.exec_module(module)
    return module


acc = _load()
API = ["--api", "https://api.test.invalid", "--confirm-host", "api.test.invalid"]


class Transport:
    """Answers from a table of (method, url start) -> (status, body); records every call."""

    def __init__(self, answers=None):
        self.answers = answers or {}
        self.calls = []

    def __call__(self, method, url, *, headers=None, json_body=None, form=None, data=None):
        self.calls.append({"method": method, "url": url, "headers": headers or {}, "json": json_body, "form": form})
        for (m, start), answer in self.answers.items():
            if m == method and url.startswith(start):
                return answer(json_body, form) if callable(answer) else answer
        return 404, {"error": {"message": "not in the fake"}}


def _run(argv, *, transport=None, env=None, tmp_path=None, ask=lambda prompt, secret: "x"):
    lines = []
    transport = transport or Transport()
    code = acc.main(argv, http=transport, ask=ask, out=lines.append, environ=env or {}, sleep=lambda s: None,
                    state_dir=tmp_path)
    return code, "\n".join(lines), transport


@pytest.mark.parametrize("argv, says", [
    (["book", "--api", "http://api.test.invalid", "--confirm-host", "api.test.invalid", "--pro-email", "p@x.test"], "https"),
    (["book", "--api", "https://api.test.invalid", "--confirm-host", "other.invalid", "--pro-email", "p@x.test"], "repeat"),
    (["book", "--api", "https://api.test.invalid/v1", "--confirm-host", "api.test.invalid", "--pro-email", "p@x.test"], "host only"),
    (["book", *API], "--pro-email"),
    (["payout", *API], "--run"),
])
def test_wrong_arguments_are_refused_before_anything_is_sent(argv, says, tmp_path):
    code, out, transport = _run(argv, tmp_path=tmp_path)
    assert code == 2 and "REFUSED" in out and says in out
    assert transport.calls == []


def test_there_is_no_default_api():
    code, _, transport = _run(["book", "--pro-email", "p@x.test"])
    assert code == 2 and transport.calls == []


@pytest.mark.parametrize("key, says", [("pk_live_abc123", "LIVE"), ("sk_test_abc123", "publishable test key"), ("rk_test_1", "publishable")])
def test_only_a_publishable_test_key_is_accepted(key, says, tmp_path):
    code, out, transport = _run(["book", *API, "--pro-email", "p@x.test"], env={"RAWWERS_STRIPE_PK": key}, tmp_path=tmp_path)
    assert code == 2 and says in out and transport.calls == []
    assert key not in out


def test_the_photos_are_valid_jpegs_each_with_its_own_sha256():
    from PIL import Image

    photos = [acc.photo("run-1", n) for n in range(30)]
    assert len({hashlib.sha256(p).hexdigest() for p in photos}) == 30
    assert acc.photo("run-1", 3) == acc.photo("run-1", 3)
    assert acc.photo("run-1", 3) != acc.photo("run-2", 3)
    for p in photos[:3]:
        assert p[:2] == b"\xff\xd8" and p[-2:] == b"\xff\xd9"
        image = Image.open(io.BytesIO(p))
        image.load()
        assert image.format == "JPEG" and image.size == (64, 48)


def test_the_amounts_follow_the_owners_rules():
    # The approved Portraits table: 20 at 4.80 = 96.00, 10 extras 31.74.
    assert acc.curve_total("portraits", D("4.80"), 20, 20) == D("96.00")
    assert acc.curve_total("portraits", D("4.80"), 20, 30) == D("127.74")
    assert acc.curve_total("portraits", D("4.50"), 20, 25) == D("107.81")
    assert acc.curve_total("weddings", D("4.80"), 20, 30) is None  # compared by hand
    assert acc.split(D("127.74")) == (D("19.16"), D("6.39"), D("102.19"))
    assert acc.split(D("107.81")) == (D("16.17"), D("5.39"), D("86.25"))


def _bare_run(tmp_path, transport=None, key=None, asked=None):
    asked = asked if asked is not None else []
    return acc.Run(api="https://api.test.invalid", http=transport or Transport(), ask=lambda p, s: asked.append(p) or "",
                   out=lambda line: None, sleep=lambda s: None, state_dir=tmp_path, publishable_key=key)


def test_the_run_file_is_private_and_holds_no_password_or_token(tmp_path):
    run = _bare_run(tmp_path)
    run.state = {"run": "r1", "api": run.api, "pro_email": "p@x.test", "gig_id": "g1", "cash": "102.19"}
    path = run.save()
    assert stat.S_IMODE(path.stat().st_mode) == 0o600
    assert path.parent == tmp_path
    saved = json.loads(path.read_text())
    assert not any(k in saved for k in ("password", "token", "access_token", "client_secret", "publishable_key"))


def test_a_run_file_for_another_api_is_refused(tmp_path):
    run = _bare_run(tmp_path)
    run.state = {"run": "r2", "api": "https://other.invalid"}
    run.save()
    with pytest.raises(acc.Refused):
        run.load("r2")


def test_without_a_key_a_payment_is_a_manual_step_naming_the_test_card(tmp_path):
    asked = []
    run = _bare_run(tmp_path, asked=asked)
    assert run.confirm_payment("booking payment", "pi_1", "pi_1_secret_x", D("96.00"), "EUR") is False
    assert run.steps[-1].status == "MANUAL" and "4000 0000 0000 0077" in run.steps[-1].detail and "96.00 EUR" in run.steps[-1].detail
    assert asked  # it waits for you


def test_with_the_key_the_payment_is_confirmed_at_stripe_with_the_publishable_key_only(tmp_path):
    transport = Transport({("POST", "https://api.stripe.com/v1/payment_intents/pi_1/confirm"): (200, {"status": "succeeded"})})
    run = _bare_run(tmp_path, transport, key="pk_test_abc")
    assert run.confirm_payment("booking payment", "pi_1", "pi_1_secret_x", D("96.00"), "EUR") is True
    call = transport.calls[-1]
    assert call["headers"]["Authorization"] == "Bearer pk_test_abc"
    assert call["form"] == {"client_secret": "pi_1_secret_x", "payment_method": acc.TEST_CARD}
    assert run.steps[-1].status == "ok"


def test_if_stripe_refuses_the_test_method_the_payment_becomes_manual(tmp_path):
    refusal = (400, {"error": {"message": "You cannot use pm_card_* with a publishable key."}})
    transport = Transport({("POST", "https://api.stripe.com/"): refusal})
    run = _bare_run(tmp_path, transport, key="pk_test_abc")
    assert run.confirm_payment("difference payment", "pi_2", "pi_2_secret_x", D("31.74"), "EUR") is False
    step = run.steps[-1]
    assert step.status == "MANUAL" and "HTTP 400" in step.detail and "client app" in step.detail and "31.74 EUR" in step.detail
    assert "pk_test_abc" not in step.detail


def _signed_in():
    return {("POST", "https://api.test.invalid/v1/auth/login"): (200, {"access_token": "tok", "refresh_token": "r", "expires_in": 900})}


def test_payout_waits_while_the_earning_is_not_available(tmp_path):
    answers = {
        **_signed_in(),
        ("GET", "https://api.test.invalid/v1/pro/earnings/ledger"): (200, {"items": [
            {"source_id": "g1", "gross": "127.74", "net": "102.19"}]}),
        ("GET", "https://api.test.invalid/v1/pro/earnings/balance"): (200, {"withdrawable": "0.00", "paid_out": "0.00"}),
    }
    transport = Transport(answers)
    run = _bare_run(tmp_path, transport)
    run.state = {"run": "r3", "api": run.api, "pro_email": "p@x.test", "gig_id": "g1", "cash": "102.19", "total": "127.74", "currency": "EUR"}
    run.payout()
    assert [s.status for s in run.steps] == ["ok", "ok", "MANUAL"]
    assert "settle-now.py" in run.steps[-1].detail
    assert not any(c["url"].endswith("/v1/pro/payouts/request") for c in transport.calls)
    assert run.table() == 0  # nothing failed; a step is waiting


def test_a_wrong_earning_is_a_fail(tmp_path):
    answers = {
        **_signed_in(),
        ("GET", "https://api.test.invalid/v1/pro/earnings/ledger"): (200, {"items": [
            {"source_id": "g1", "gross": "127.74", "net": "102.20"}]}),
        ("GET", "https://api.test.invalid/v1/pro/earnings/balance"): (200, {"withdrawable": "0.00"}),
    }
    run = _bare_run(tmp_path, Transport(answers))
    run.state = {"run": "r4", "api": run.api, "pro_email": "p@x.test", "gig_id": "g1", "cash": "102.19", "total": "127.74", "currency": "EUR"}
    run.payout()
    assert "FAIL" in [s.status for s in run.steps]
    assert run.table() == 1


def test_a_refused_call_stops_the_run_and_says_why(tmp_path):
    answers = {("POST", "https://api.test.invalid/v1/auth/login"): (401, {"error": {"message": "Invalid credentials"}})}
    code, out, transport = _run(["book", *API, "--pro-email", "p@x.test"], transport=Transport(answers), tmp_path=tmp_path)
    assert code == 1 and "FAIL    sign in" in out and "Invalid credentials" in out
    assert len(transport.calls) == 1
