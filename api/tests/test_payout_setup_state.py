"""Where a photographer's payout setup stands, from one mapping.

`setup_from_account` turns a Stripe account into both the status we store
(payout_account.status, which gates payouts) and the setup state the app
shows. One function, so the screen can never say "Payouts are set up"
while the stored status keeps Request payout hidden, or the other way
round.

The rule (owner's decision after the Stage 1 gate run, 2026-10-28): ready
means details_submitted AND payouts_enabled. charges_enabled is not part
of it - a transfers-only Express account is paid by transfer, and Stripe
may never enable charges on one. Disabled, under review, action needed and
in progress follow the Part A status table.

Stripe is faked throughout.
"""
import pytest

from app.api.v1.webhooks import _apply_stripe_event
from app.models.payouts import PayoutAccount, PayoutAccountStatus, PayoutMethod, PayoutSetupState
from app.services import stripe_connect
from tests.test_stripe_connect import _FakeAccount, _FakeStripe, _seed_pro

ACTIVE = PayoutAccountStatus.active
PENDING = PayoutAccountStatus.pending_verification
DISABLED = PayoutAccountStatus.disabled

CASES = [
    # --- Ready: submitted and payouts enabled.
    ("ready",
     {"charges_enabled": True, "payouts_enabled": True, "details_submitted": True},
     ACTIVE, PayoutSetupState.ready),
    # The case CHANGE 1 asked for: a transfers-only account Stripe pays out
    # to without ever enabling charges. Ready, and stored as active.
    ("ready without charges",
     {"charges_enabled": False, "payouts_enabled": True, "details_submitted": True},
     ACTIVE, PayoutSetupState.ready),
    # What the gate run's account looked like once onboarding finished: an
    # ID document due one day does not hold anything up today.
    ("ready with something eventually due",
     {"charges_enabled": True, "payouts_enabled": True, "details_submitted": True,
      "requirements": {"eventually_due": ["individual.verification.document"], "currently_due": []}},
     ACTIVE, PayoutSetupState.ready),
    # --- Not submitted: still filling in Stripe's form.
    ("fresh account, past_due stamped at creation",
     {"charges_enabled": False, "payouts_enabled": False, "details_submitted": False,
      "requirements": {"disabled_reason": "requirements.past_due",
                       "currently_due": ["individual.first_name", "external_account"]}},
     PENDING, PayoutSetupState.in_progress),
    ("payouts enabled but the form not submitted",
     {"charges_enabled": False, "payouts_enabled": True, "details_submitted": False},
     PENDING, PayoutSetupState.in_progress),
    # --- Submitted, something still due.
    ("submitted, currently_due",
     {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
      "requirements": {"currently_due": ["individual.verification.document"]}},
     PENDING, PayoutSetupState.action_needed),
    ("submitted, past_due only",
     {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
      "requirements": {"disabled_reason": "requirements.past_due", "past_due": ["external_account"]}},
     PENDING, PayoutSetupState.action_needed),
    ("submitted, currently_due, flattened shape",
     {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
      "currently_due": ["individual.id_number"], "past_due": [], "disabled_reason": None},
     PENDING, PayoutSetupState.action_needed),
    # --- Submitted, nothing due, payouts not on yet: Stripe is checking.
    ("submitted, nothing due",
     {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True},
     PENDING, PayoutSetupState.under_review),
    ("submitted, under_review",
     {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
      "requirements": {"disabled_reason": "under_review"}},
     PENDING, PayoutSetupState.under_review),
    ("submitted, pending_verification",
     {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
      "requirements": {"disabled_reason": "requirements.pending_verification",
                       "pending_verification": ["individual.verification.document"]}},
     PENDING, PayoutSetupState.under_review),
    # Charges on, payouts off: still not ready. Telling a photographer they
    # can be paid here would be a promise Stripe refuses to keep.
    ("charges but not payouts",
     {"charges_enabled": True, "payouts_enabled": False, "details_submitted": True},
     PENDING, PayoutSetupState.under_review),
    # --- Disabled: a reason that is not about unfinished onboarding.
    ("rejected",
     {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
      "requirements": {"disabled_reason": "rejected.fraud", "currently_due": ["external_account"]}},
     DISABLED, PayoutSetupState.disabled),
    ("listed, flattened shape",
     {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
      "disabled_reason": "listed", "currently_due": [], "past_due": []},
     DISABLED, PayoutSetupState.disabled),
    ("rejected before submitting",
     {"charges_enabled": False, "payouts_enabled": False, "details_submitted": False,
      "requirements": {"disabled_reason": "rejected.other"}},
     DISABLED, PayoutSetupState.disabled),
]


@pytest.mark.parametrize("name,payload,status,state", CASES, ids=[c[0] for c in CASES])
def test_one_mapping_gives_both_the_stored_status_and_the_setup_state(name, payload, status, state):
    setup = stripe_connect.setup_from_account(payload)
    assert (setup.status, setup.state) == (status, state)


@pytest.mark.parametrize("name,payload,status,state", CASES, ids=[c[0] for c in CASES])
def test_the_stored_status_is_read_from_the_same_mapping(name, payload, status, state):
    assert stripe_connect.status_from_account(payload) == stripe_connect.setup_from_account(payload).status


@pytest.mark.parametrize("name,payload,status,state", CASES, ids=[c[0] for c in CASES])
def test_ready_and_active_always_go_together(name, payload, status, state):
    # The app shows "Payouts are set up" for ready; Request payout needs
    # active. Neither may appear without the other.
    setup = stripe_connect.setup_from_account(payload)
    assert (setup.state == PayoutSetupState.ready) == (setup.status == PayoutAccountStatus.active)


#: Cases shaped like a real Stripe account (requirements nested), which is
#: what Account.retrieve and the account.updated webhook deliver. The
#: flattened ones are connect_status()'s output, fed to the mapper only.
RAW = [c for c in CASES if "flattened" not in c[0]]


def test_every_setup_state_the_server_can_report_is_covered():
    reached = {c[3] for c in CASES} | {PayoutSetupState.not_started}
    assert reached == set(PayoutSetupState)


# --- Through the live read ------------------------------------------------


def _pro_with_account(db_session, status=PayoutAccountStatus.pending_verification, acct="acct_fake_123"):
    uid = _seed_pro(db_session)
    db_session.add(PayoutAccount(
        pro_user_id=uid, payout_method=PayoutMethod.stripe_connect,
        stripe_connect_account_id=acct, status=status,
    ))
    db_session.commit()
    return uid


def _live(monkeypatch, payload):
    fake = _FakeStripe(account=_FakeAccount(payload={"id": "acct_fake_123", **payload}))
    monkeypatch.setattr(stripe_connect, "_stripe", lambda: fake)
    return fake


def test_no_account_yet_is_not_started(client, db_session):
    uid = _seed_pro(db_session)
    body = client.get("/v1/pro/payouts/connect/status", headers={"X-User-Id": str(uid)}).json()
    assert body["setup_state"] == "not_started"
    assert body["account_status"] == "not_set"


@pytest.mark.parametrize("name,payload,status,state", RAW, ids=[c[0] for c in RAW])
def test_the_status_endpoint_reports_and_stores_what_the_mapping_says(
    client, db_session, monkeypatch, name, payload, status, state
):
    uid = _pro_with_account(db_session)
    _live(monkeypatch, payload)

    response = client.get("/v1/pro/payouts/connect/status", headers={"X-User-Id": str(uid)})
    assert response.status_code == 200, response.text
    body = response.json()
    assert body["setup_state"] == state.value
    assert body["account_status"] == status.value

    db_session.expire_all()
    assert db_session.get(PayoutAccount, uid).status == status


def test_payouts_without_charges_unlocks_payouts_through_the_endpoint(client, db_session, monkeypatch):
    uid = _pro_with_account(db_session)
    _live(monkeypatch, {"charges_enabled": False, "payouts_enabled": True, "details_submitted": True})

    body = client.get("/v1/pro/payouts/connect/status", headers={"X-User-Id": str(uid)}).json()
    assert (body["setup_state"], body["account_status"]) == ("ready", "active")
    # What the Wallet and the You band read to show Request payout.
    account = client.get("/v1/pro/payouts/account", headers={"X-User-Id": str(uid)}).json()
    assert account["status"] == "active"


# --- Through the webhook --------------------------------------------------


@pytest.mark.parametrize("name,payload,status,state", RAW, ids=[c[0] for c in RAW])
def test_the_webhook_stores_what_the_mapping_says(db_session, name, payload, status, state):
    uid = _pro_with_account(db_session, status=PayoutAccountStatus.not_set, acct="acct_hook")
    _apply_stripe_event(db_session, "account.updated", {"id": "acct_hook", **payload})
    db_session.commit()
    db_session.expire_all()
    assert db_session.get(PayoutAccount, uid).status == status


def test_setup_state_is_an_enum_in_the_api_schema(client):
    schema = client.get("/openapi.json").json()["components"]["schemas"]
    prop = schema["ConnectStatusResponse"]["properties"]["setup_state"]
    ref = prop.get("$ref") or prop["allOf"][0]["$ref"]
    values = schema[ref.rsplit("/", 1)[-1]]["enum"]
    assert set(values) == {s.value for s in PayoutSetupState}
    assert "setup_state" in schema["ConnectStatusResponse"]["required"]
