"""Studioverse and the print store are off for the beta (owner, 2026-11-18);
so are loaner requests and the older points spending (owner, 2026-11-21),
while client credit at checkout keeps working and video uploads stay on.

Studioverse (`studioverse_enabled`): on in development, off elsewhere unless
an admin writes a flag row; while off, its user routes answer exactly as a
route that does not exist, before any login check. Its admin routes stay.

Prints (`ecom_enabled`, off by default everywhere): every user print route
answers 404, as the old store's routes do.
"""
import uuid

import pytest

from app.core.config import get_settings
from app.models.ops import FeatureFlagScope
from app.services import feature_flags
from app.services.feature_flags import default_flag_state, is_feature_enabled, upsert_feature_flag
from tests.test_studioverse_v1 import ADMIN_ID, _seed_approved_pro, _seed_user
from app.models.admin import UserRoleType


SWITCHES = ["studioverse_enabled", "ecom_enabled", "loaners_enabled", "rewards_spend_enabled", "video_uploads_enabled"]


@pytest.fixture(autouse=True)
def no_flag_rows(db_session):
    """The suite's database is shared: no flag row of these two before or
    after a test, so each sees the defaults and leaves them."""
    from app.models.ops import FeatureFlag

    def clear():
        db_session.query(FeatureFlag).filter(FeatureFlag.key.in_(SWITCHES)).delete()
        db_session.commit()

    clear()
    yield
    clear()


@pytest.fixture
def production(monkeypatch):
    """The defaults outside development, keeping this suite's sign-in header
    (as test_assistant_off_for_beta)."""
    monkeypatch.setattr(feature_flags, "DEVELOPMENT_ENVS", frozenset())


STUDIOVERSE_USER_ROUTES = [
    ("post", "/v1/studioverse/packs"),
    ("put", f"/v1/studioverse/packs/{uuid.uuid4()}"),
    ("post", f"/v1/studioverse/packs/{uuid.uuid4()}/submit"),
    ("get", "/v1/studioverse/packs/mine"),
    ("get", "/v1/studioverse/packs"),
    ("get", f"/v1/studioverse/packs/{uuid.uuid4()}"),
    ("post", f"/v1/studioverse/packs/{uuid.uuid4()}/checkout"),
    ("get", "/v1/studioverse/orders/mine"),
    ("post", f"/v1/studioverse/orders/{uuid.uuid4()}/download"),
]

PRINT_USER_ROUTES = [
    ("get", "/v1/prints/catalog"),
    ("post", f"/v1/gigs/{uuid.uuid4()}/prints/orders"),
    ("put", f"/v1/prints/orders/{uuid.uuid4()}"),
    ("post", f"/v1/prints/orders/{uuid.uuid4()}/pay"),
    ("get", "/v1/prints/orders/mine"),
    ("get", f"/v1/prints/orders/{uuid.uuid4()}"),
]


@pytest.mark.parametrize("env", ["production", "prod", "staging"])
def test_production_defaults_have_studioverse_and_prints_off(db_session, monkeypatch, env):
    monkeypatch.setattr(get_settings(), "app_env", env)
    assert default_flag_state("studioverse_enabled") is False
    assert is_feature_enabled(db_session, "studioverse_enabled") is False
    assert default_flag_state("ecom_enabled") is False
    assert is_feature_enabled(db_session, "ecom_enabled") is False


def test_development_keeps_studioverse_on_and_prints_off(db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "app_env", "development")
    assert is_feature_enabled(db_session, "studioverse_enabled") is True
    assert is_feature_enabled(db_session, "ecom_enabled") is False


@pytest.mark.parametrize(("method", "path"), STUDIOVERSE_USER_ROUTES)
def test_off_studioverse_answers_as_a_route_that_does_not_exist(client, db_session, production, method, path):
    pro = str(uuid.uuid4())
    _seed_approved_pro(db_session, pro)
    unmounted = client.get("/v1/no-such-route-at-all")
    for headers in ({}, {"X-User-Id": pro}):
        answer = getattr(client, method)(path, headers=headers, **({"json": {}} if method in {"post", "put"} else {}))
        assert answer.status_code == 404, answer.text
        assert answer.json() == unmounted.json() == {"detail": "Not Found"}


def test_studioverse_admin_routes_stay_while_it_is_off(client, db_session, production):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    answer = client.get("/v1/admin/studioverse/packs", headers={"X-User-Id": ADMIN_ID, "X-Admin-Api-Key": ""})
    assert answer.status_code == 200, answer.text


def test_an_admin_flag_row_switches_studioverse_on(client, db_session, production):
    upsert_feature_flag(db_session, key="studioverse_enabled", is_enabled=True, scope=FeatureFlagScope.global_scope, rules=None)
    db_session.commit()
    pro = str(uuid.uuid4())
    _seed_approved_pro(db_session, pro)
    assert client.get("/v1/studioverse/packs/mine", headers={"X-User-Id": pro}).status_code == 200


@pytest.mark.parametrize(("method", "path"), PRINT_USER_ROUTES)
def test_print_routes_answer_404_while_ecom_is_off(client, db_session, method, path):
    user = str(uuid.uuid4())
    _seed_user(db_session, user, [UserRoleType.client])
    answer = getattr(client, method)(path, headers={"X-User-Id": user}, **({"json": {}} if method in {"post", "put"} else {}))
    assert answer.status_code == 404, answer.text
    assert answer.json()["error"]["code"] == "not_found"


def test_with_ecom_on_the_print_routes_answer_again(client, db_session):
    upsert_feature_flag(db_session, key="ecom_enabled", is_enabled=True, scope=FeatureFlagScope.global_scope, rules=None)
    db_session.commit()
    user = str(uuid.uuid4())
    _seed_user(db_session, user, [UserRoleType.client])
    assert client.get("/v1/prints/catalog", headers={"X-User-Id": user}).status_code == 200
    assert client.get("/v1/prints/orders/mine", headers={"X-User-Id": user}).status_code == 200


# --- loaners and the older points spending (owner, 2026-11-21) ----------------------------------


@pytest.mark.parametrize("env", ["production", "prod", "staging"])
def test_production_defaults_have_loaners_and_points_spending_off_and_video_uploads_on(db_session, monkeypatch, env):
    monkeypatch.setattr(get_settings(), "app_env", env)
    for key in ("loaners_enabled", "rewards_spend_enabled"):
        assert default_flag_state(key) is False and is_feature_enabled(db_session, key) is False, key
    assert default_flag_state("video_uploads_enabled") is True
    assert is_feature_enabled(db_session, "video_uploads_enabled") is True


def test_development_keeps_loaners_and_points_spending_on(db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "app_env", "development")
    assert is_feature_enabled(db_session, "loaners_enabled") is True
    assert is_feature_enabled(db_session, "rewards_spend_enabled") is True


def test_off_loaners_refuse_a_loaner_request(client, db_session, production):
    from tests.test_repairs_v0 import _prepare_pro

    pro = str(uuid.uuid4())
    _prepare_pro(db_session, pro)
    ticket = client.post("/v1/repairs/tickets", headers={"X-User-Id": pro},
                         json={"category": "camera_body", "issue_description": "Shutter issue", "urgency": "normal"})
    assert ticket.status_code == 200, ticket.text
    loaner = client.post(f"/v1/repairs/tickets/{ticket.json()['id']}/request-loaner", headers={"X-User-Id": pro},
                         json={"category": "camera_body"})
    assert loaner.status_code == 503 and loaner.json()["error"]["code"] == "feature_disabled"


def test_off_points_spending_refuses_the_older_spend_route(client, db_session, production):
    user = str(uuid.uuid4())
    _seed_user(db_session, user, [UserRoleType.client])
    spend = client.post("/v1/rewards/spend", headers={"X-User-Id": user}, json={
        "context_type": "gig_payment", "context_id": str(uuid.uuid4()), "points": 100, "payment_amount": "100.00", "currency": "EUR",
    })
    assert spend.status_code == 503 and spend.json()["error"]["code"] == "feature_disabled"


def test_client_credit_at_checkout_works_with_points_spending_off(client, db_session, production, monkeypatch):
    """The client's credit: balance, preview and the discount on the payment,
    and switching it off again, all with `rewards_spend_enabled` off."""
    from decimal import Decimal

    from sqlalchemy import select

    from app.models.gig import GigStatus, StripePayment
    from tests.test_booking_close import _ensure_account
    from tests.test_client_booking_pay import _booking_with_gig
    from tests.test_client_credit import _give
    from tests.test_download_payment_gate import FakeStripe

    fake = FakeStripe()
    for name in ("create", "retrieve", "modify", "cancel"):
        monkeypatch.setattr(f"stripe.PaymentIntent.{name}", getattr(fake, name))
    assert is_feature_enabled(db_session, "rewards_spend_enabled") is False
    user = str(uuid.uuid4())
    _ensure_account(db_session, user)
    booking, gig = _booking_with_gig(db_session, user, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    _give(db_session, uuid.UUID(user), 3000)  # EUR 30 on a EUR 100 booking
    headers = {"X-User-Id": user}

    assert client.get("/v1/me/credit", headers=headers).json()["balance"] == "30.00"
    preview = client.get(f"/v1/client/bookings/{booking.id}/credit", headers=headers).json()
    assert (preview["discount"], preview["total"]) == ("10.00", "90.00")
    paid = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=headers)
    assert paid.status_code == 200, paid.text
    assert (paid.json()["credit"], paid.json()["amount"]) == ("10.00", "90.00")
    assert fake.creates[-1]["amount"] == 9000
    assert db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one().amount == Decimal("90.00")
    off = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": False}, headers=headers)
    assert off.status_code == 200 and off.json()["amount"] == "100.00"


# --- the "Meet the photographer" video stays off until the real Mux round trip ------------------


def test_presentation_video_is_off_by_default_in_production(monkeypatch):
    """Switched on in production only after DEPLOY_CHECKLIST 4b passes."""
    from app.core.config import Settings
    from app.services import presentation_video as pv

    assert Settings.model_fields["presentation_video_enabled"].default is False
    monkeypatch.delenv("PRESENTATION_VIDEO_ENABLED", raising=False)
    monkeypatch.delenv("MUX_FAKE", raising=False)
    production = Settings(_env_file=None, APP_ENV="production",
                          CONNECT_RETURN_URL="https://api.example.test/v1/payouts/connect/return",
                          CONNECT_REFRESH_URL="https://api.example.test/v1/payouts/connect/refresh")
    assert production.presentation_video_enabled is False
    monkeypatch.setattr("app.services.presentation_video.get_settings", lambda: production)
    assert pv.available() is False
