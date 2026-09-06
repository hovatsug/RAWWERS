"""Stripe Connect onboarding.

WHAT THESE PROVE: our own logic - idempotency, status mapping, that a
link is minted fresh every time, that Stripe failures surface as a
readable 502 rather than a 500, and that the local status reconciles with
what Stripe reports.

WHAT THESE DO NOT PROVE: these run against a fake. The request shapes
themselves were verified separately against real Stripe with Connect
enabled in test mode - Account.create, AccountLink.create and
Account.retrieve were all accepted - so the fake's shapes are no longer
guesses. What still is not covered here is the hosted onboarding flow
itself. See docs/BACKEND_GAPS.md.
"""
import uuid

import pytest

from app.core.errors import APIError
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.payouts import PayoutAccount, PayoutAccountStatus, PayoutMethod
from app.services import stripe_connect


class _FakeAccount:
    """Stands in for stripe.Account. Records what it was asked for so the
    request shape is at least pinned, even though it is unverified."""

    def __init__(self, *, payload=None, fail=None):
        self.payload = payload or {}
        self.fail = fail
        self.create_calls = []
        self.retrieve_calls = []

    def create(self, **kwargs):
        self.create_calls.append(kwargs)
        if self.fail:
            raise self.fail
        return {"id": "acct_fake_123"}

    def retrieve(self, account_id):
        self.retrieve_calls.append(account_id)
        if self.fail:
            raise self.fail
        return self.payload


class _FakeAccountLink:
    def __init__(self, *, fail=None):
        self.fail = fail
        self.calls = []
        self.counter = 0

    def create(self, **kwargs):
        self.calls.append(kwargs)
        if self.fail:
            raise self.fail
        self.counter += 1
        return {"url": f"https://connect.stripe.test/setup/{self.counter}"}


class _FakeStripe:
    def __init__(self, *, account=None, link=None):
        self.Account = account or _FakeAccount()
        self.AccountLink = link or _FakeAccountLink()
        self.api_key = None


@pytest.fixture
def fake_stripe(monkeypatch):
    fake = _FakeStripe()
    monkeypatch.setattr(stripe_connect, "_stripe", lambda: fake)
    return fake


def _seed_pro(db_session) -> uuid.UUID:
    uid = uuid.uuid4()
    db_session.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db_session.commit()
    db_session.add(UserRole(user_id=uid, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=uid, country="PT", city="Lisbon"))
    db_session.commit()
    return uid


def test_creating_an_account_stores_it_and_does_not_claim_it_is_ready(db_session, fake_stripe):
    uid = _seed_pro(db_session)
    row = stripe_connect.ensure_connect_account(db_session, pro_user_id=uid, email="a@b.test", country="PT")
    db_session.commit()

    assert row.stripe_connect_account_id == "acct_fake_123"
    assert row.payout_method == PayoutMethod.stripe_connect
    # Not active until Stripe says so. Showing a working payout method that
    # cannot pay anyone is worse than showing none.
    assert row.status == PayoutAccountStatus.pending_verification

    sent = fake_stripe.Account.create_calls[0]
    assert sent["type"] == "express"
    assert sent["country"] == "PT"
    assert sent["metadata"]["pro_user_id"] == str(uid)


def test_the_photographers_own_country_is_used_not_the_platforms(db_session, fake_stripe):
    # Country cannot be changed after creation, so getting it from the
    # platform default would permanently make a Portuguese photographer a
    # holder of an account in someone else's jurisdiction.
    uid = _seed_pro(db_session)
    stripe_connect.ensure_connect_account(db_session, pro_user_id=uid, email=None, country="ie")
    assert fake_stripe.Account.create_calls[0]["country"] == "IE"


def test_creating_twice_returns_the_same_account(db_session, fake_stripe):
    uid = _seed_pro(db_session)
    first = stripe_connect.ensure_connect_account(db_session, pro_user_id=uid, email=None, country="PT")
    db_session.commit()
    second = stripe_connect.ensure_connect_account(db_session, pro_user_id=uid, email=None, country="PT")
    db_session.commit()

    assert first.stripe_connect_account_id == second.stripe_connect_account_id
    # A second account would strand whatever onboarding was completed
    # against the first.
    assert len(fake_stripe.Account.create_calls) == 1


def test_every_link_request_mints_a_new_link(fake_stripe):
    # Account links expire in minutes and are consumed on first use, so a
    # cached one is a broken one.
    first = stripe_connect.create_onboarding_link(
        stripe_account_id="acct_fake_123", return_url="r://return", refresh_url="r://refresh"
    )
    second = stripe_connect.create_onboarding_link(
        stripe_account_id="acct_fake_123", return_url="r://return", refresh_url="r://refresh"
    )
    assert first != second
    assert len(fake_stripe.AccountLink.calls) == 2
    # refresh_url is where Stripe sends someone whose link went stale; it
    # has to lead back to another attempt, not to an error page.
    assert fake_stripe.AccountLink.calls[0]["refresh_url"] == "r://refresh"
    assert fake_stripe.AccountLink.calls[0]["type"] == "account_onboarding"


def test_a_stripe_failure_surfaces_readably_not_as_a_500(db_session, monkeypatch):
    # The most likely failure in practice is "Connect is not enabled on
    # this account", and that sentence is far more use than a generic one.
    fake = _FakeStripe(account=_FakeAccount(fail=Exception("Connect is not enabled on this account.\nmore detail")))
    monkeypatch.setattr(stripe_connect, "_stripe", lambda: fake)
    uid = _seed_pro(db_session)

    with pytest.raises(APIError) as caught:
        stripe_connect.ensure_connect_account(db_session, pro_user_id=uid, email=None, country="PT")
    assert caught.value.status_code == 502
    assert "Connect is not enabled" in caught.value.message
    assert "\n" not in caught.value.message


@pytest.mark.parametrize(
    "payload,expected",
    [
        (
            {"charges_enabled": True, "payouts_enabled": True, "details_submitted": True},
            PayoutAccountStatus.active,
        ),
        # Stripe stamps requirements.past_due on an Express account the
        # moment it is created, before the photographer has seen the
        # onboarding form. Observed on a real account. This expectation
        # previously said "disabled" and so encoded the bug as the spec.
        (
            {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
             "requirements": {"disabled_reason": "requirements.past_due"}},
            PayoutAccountStatus.pending_verification,
        ),
        (
            {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
             "requirements": {"disabled_reason": "under_review"}},
            PayoutAccountStatus.pending_verification,
        ),
        (
            {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
             "requirements": {"disabled_reason": "rejected.fraud"}},
            PayoutAccountStatus.disabled,
        ),
        # The shape connect_status() actually returns: flattened, with
        # disabled_reason at the top level rather than under requirements.
        # This is the shape the live-read endpoint passes in, and it was
        # never exercised - so that path could not report "disabled" at all.
        (
            {"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
             "disabled_reason": "rejected.fraud", "currently_due": [], "past_due": []},
            PayoutAccountStatus.disabled,
        ),
        (
            {"charges_enabled": False, "payouts_enabled": False, "details_submitted": False,
             "requirements": {"currently_due": ["individual.id_number"]}},
            PayoutAccountStatus.pending_verification,
        ),
        # Onboarding submitted but transfers not yet enabled: still pending,
        # not active. Treating this as active would tell a photographer they
        # can be paid when Stripe will refuse the transfer.
        (
            {"charges_enabled": True, "payouts_enabled": False, "details_submitted": True},
            PayoutAccountStatus.pending_verification,
        ),
    ],
)
def test_status_mapping_matches_what_stripe_reports(payload, expected):
    assert stripe_connect.status_from_account(payload) == expected


def test_status_reports_what_stripe_is_still_waiting_for(monkeypatch):
    # "Pending" is a shrug; "Stripe needs your ID number" is an instruction.
    fake = _FakeStripe(account=_FakeAccount(payload={
        "id": "acct_fake_123",
        "charges_enabled": False,
        "payouts_enabled": False,
        "details_submitted": False,
        "requirements": {"currently_due": ["individual.id_number", "individual.verification.document"]},
    }))
    monkeypatch.setattr(stripe_connect, "_stripe", lambda: fake)

    status = stripe_connect.connect_status(stripe_account_id="acct_fake_123")
    assert status["currently_due"] == ["individual.id_number", "individual.verification.document"]
    assert status["payouts_enabled"] is False


def test_a_live_read_round_trips_through_connect_status(monkeypatch):
    """The live-read endpoint does not pass Stripe's account to the mapper -
    it passes connect_status()'s reshaped dict. Nothing exercised that
    hand-off, and the mapper only understood the nested spelling, so a
    genuinely rejected account read back as pending_verification forever."""
    fake = _FakeStripe(account=_FakeAccount(payload={
        "id": "acct_fake_123",
        "charges_enabled": False,
        "payouts_enabled": False,
        "details_submitted": True,
        "requirements": {"disabled_reason": "rejected.fraud", "currently_due": [], "past_due": []},
    }))
    monkeypatch.setattr(stripe_connect, "_stripe", lambda: fake)

    live = stripe_connect.connect_status(stripe_account_id="acct_fake_123")
    assert stripe_connect.status_from_account(live) == PayoutAccountStatus.disabled


def test_the_webhook_moves_the_row_the_way_the_mapper_says(db_session):
    """Drives the real account.updated arm rather than transcribing it.

    The test this replaces copied the handler's logic into itself and
    compared the copy to the mapper - two copies of the same idea agreeing
    with each other. It passed while the handler and the mapper genuinely
    disagreed on a live account, in opposite directions.
    """
    from app.api.v1.webhooks import _apply_stripe_event

    cases = [
        # A brand-new Express account, exactly as Stripe reports it.
        ({"charges_enabled": False, "payouts_enabled": False, "details_submitted": False,
          "requirements": {"disabled_reason": "requirements.past_due"}},
         PayoutAccountStatus.pending_verification),
        ({"charges_enabled": True, "payouts_enabled": True, "details_submitted": True,
          "requirements": {"disabled_reason": None}},
         PayoutAccountStatus.active),
        ({"charges_enabled": False, "payouts_enabled": False, "details_submitted": True,
          "requirements": {"disabled_reason": "rejected.fraud"}},
         PayoutAccountStatus.disabled),
    ]

    for index, (account_payload, expected) in enumerate(cases):
        uid = _seed_pro(db_session)
        acct_id = f"acct_case_{index}"
        db_session.add(PayoutAccount(
            pro_user_id=uid,
            payout_method=PayoutMethod.stripe_connect,
            stripe_connect_account_id=acct_id,
            status=PayoutAccountStatus.not_set,
        ))
        db_session.commit()

        _apply_stripe_event(db_session, "account.updated", {"id": acct_id, **account_payload})
        db_session.commit()

        row = db_session.get(PayoutAccount, uid)
        assert row.status == expected, f"{account_payload} -> {row.status}, expected {expected}"
        # And the mapper, given the same payload, must agree - checked by
        # calling it, not by re-deriving it.
        assert stripe_connect.status_from_account(account_payload) == expected
