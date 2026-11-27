"""deploy/scripts/acceptance.py, both phases, against the real API.

The script's transport is pointed at the test client instead of the
network: its API calls are the routes themselves, Stripe's confirm is the
money journey's FakeStripe (the card goes through and the webhook is
sent), and its PUT to the signed upload address lands in the fake bucket
and is processed by the real photo task. So every route, field and status
the script relies on is checked against the code, with no network.

The admin's approval (MANUAL in a real run) is done here through the admin
route when the script stops for it.
"""
from __future__ import annotations

import importlib.util
import re
import sys
from decimal import Decimal as D
from pathlib import Path
from urllib.parse import urlsplit

import pytest

from tests.money_journey import LISBON_EUR, PASSWORD, Journey

SCRIPT = Path(__file__).resolve().parents[2] / "deploy" / "scripts" / "acceptance.py"
HOST = "api.acceptance.invalid"


def _load():
    spec = importlib.util.spec_from_file_location("acceptance_script", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


acc = _load()


class AppTransport:
    def __init__(self, j: Journey):
        self.j = j
        self.stripe_calls = []

    def __call__(self, method, url, *, headers=None, json_body=None, form=None, data=None):
        import app.tasks.media_tasks as tasks

        parts = urlsplit(url)
        if parts.hostname == HOST:
            path = url[len(f"https://{HOST}"):]
            resp = self.j.client.request(method, path, headers=headers or {}, json=json_body)
            completed = re.fullmatch(r"/v1/media/photos/([0-9a-f-]+)/complete", path)
            if completed and resp.status_code == 200:
                # The photo worker, as the server's would run it.
                tasks.process_photo_variants.push_request(retries=0)
                try:
                    tasks.process_photo_variants.run(completed.group(1))
                finally:
                    tasks.process_photo_variants.pop_request()
            self.j.db.expire_all()
            body = resp.json() if resp.content and resp.headers.get("content-type", "").startswith("application/json") else None
            return resp.status_code, body
        if parts.hostname == "api.stripe.com":
            self.stripe_calls.append({"url": url, "headers": headers, "form": form})
            pi_id = parts.path.split("/")[3]
            intent = self.j.stripe.intents[pi_id]
            assert headers["Authorization"] == "Bearer pk_test_journey"
            if form.get("client_secret") != intent.client_secret:
                return 400, {"error": {"message": "client_secret does not match"}}
            self.j.card_pays(pi_id)
            return 200, {"id": pi_id, "status": "succeeded"}
        if parts.hostname == "r2.invalid" and method == "PUT":
            self.j.bucket.receive(url, data)
            return 200, None
        raise AssertionError(f"the script called something outside the fakes: {method} {url}")


@pytest.fixture
def journey(proxied_client, db_session, monkeypatch):
    return Journey(proxied_client, db_session, monkeypatch, LISBON_EUR)


def test_both_phases_against_the_api(journey, tmp_path):
    j = journey
    j.open_city()
    j.set_price_cap()
    pro = j.photographer()
    transport = AppTransport(j)
    asked = []

    def ask(prompt, secret):
        asked.append(prompt)
        if prompt.startswith("Password for"):
            assert secret
            return PASSWORD
        if "approved in the admin web" in prompt:
            payouts = j.call("GET", "/v1/admin/payouts", "admin")["items"]
            j.approve_payout(payouts[0]["id"])
            j.confirm_transfers()
        return ""

    lines = []
    argv = ["--api", f"https://{HOST}", "--confirm-host", HOST]
    env = {"RAWWERS_STRIPE_PK": "pk_test_journey"}
    code = acc.main(["book", *argv, "--pro-email", pro.email], http=transport, ask=ask, out=lines.append,
                    environ=env, sleep=lambda s: None, state_dir=tmp_path)
    out = "\n".join(lines)
    assert code == 0, out
    assert not [line for line in lines if line.startswith("FAIL")] and " 0 FAIL," in out, out
    assert len(transport.stripe_calls) == 2  # the booking's payment and the difference
    run_id = re.search(r"^Run (\S+):", out, re.M).group(1)

    # 25 photos (the 20 included and 5 extras): 96.00 + 19.00 = 115.00 =
    # 17.25 kept + 5.75 RAWW + 92.00 cash.
    entries = j.entries(pro)
    assert [(e.gross, e.net) for e in entries] == [(D("115.00"), D("92.00"))]
    manual = [line for line in lines if line.startswith("MANUAL")]
    assert len(manual) == 3, manual  # the 24-hour rule, the settlement delay, the admin money page
    assert any("17.25" in m and "5.75" in m and "92.00" in m for m in manual)

    # The payout phase before the earning is available: it waits.
    lines.clear()
    code = acc.main(["payout", *argv, "--run", run_id], http=transport, ask=ask, out=lines.append, environ=env,
                    sleep=lambda s: None, state_dir=tmp_path)
    assert code == 0 and any("settle-now.py" in line for line in lines)
    assert not j.call("GET", "/v1/admin/payouts", "admin")["items"]

    # The 7 days pass and the sweep runs (settle-now on the server).
    j.jump_past_settlement_delay(pro)
    j.settle()
    lines.clear()
    code = acc.main(["payout", *argv, "--run", run_id], http=transport, ask=ask, out=lines.append, environ=env,
                    sleep=lambda s: None, state_dir=tmp_path)
    out = "\n".join(lines)
    assert code == 0 and " 0 FAIL," in out, out
    assert "ok      payout paid" in out
    assert sum(t.amount for t in j.stripe.transfers) == 9200
    assert j.wallet(pro).paid_out == D("92.00")
    # Nothing secret was printed or written.
    written = "".join(p.read_text() for p in tmp_path.iterdir())
    for secret in (PASSWORD, "pk_test_journey", "access_token", "client_secret"):
        assert secret not in out and secret not in written

