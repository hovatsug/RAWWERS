"""Multi-currency M2: every money value the API sends carries its currency,
and no amount is named `_eur` (docs/MULTI_CURRENCY.md 6.2)."""
from __future__ import annotations

import decimal
import inspect
import typing
import uuid
from decimal import Decimal

import pytest
from pydantic import BaseModel

from app.core.errors import APIError
from app.models.gig import GigStatus
from app.models.reward import RedemptionContextType
from app.services import email_texts
from app.services.rewards import CREDIT_CURRENCY, reserve_points_for_discount

from tests.test_booking_close import _ensure_account
from tests.test_client_booking_pay import _booking_with_gig
from tests.test_client_credit import _give, _h, fake_stripe  # noqa: F401 - fixture

#: Routes of dormant features (EUR-only by design, MULTI_CURRENCY.md 1.1),
#: The Shelf (off; per-currency RAWW values are batch M4) and dev helpers.
DORMANT = ("studioverse", "courses", "learning", "store", "repairs", "prints", "shelf", "legacy", "/dev/")
#: Decimal fields that are not money.
NOT_MONEY = ("progress", "percent", "rate", "ratio", "score", "_km", "rating", "multiplier", "weight", "factor", "_mm", "aperture", "shape_param", "floor_pct")
#: Models whose money is in a parent's `currency`, or not yet per currency.
ALLOWED_WITHOUT_CURRENCY = {
    # A point on a pricing curve; the response holding the curve has `currency`.
    "ProPricingCurvePoint",
    # The client's budget filter: in their display currency, which is batch M3.
    "ClientPreferenceView",
}
#: Per-currency settings: the suffix names the currency the setting is for
#: (a `_gbp` twin comes with batch M4), not an amount sent without one.
PER_CURRENCY_SETTINGS = {"monthly_marketing_credit_budget_eur", "min_conversion_value_eur", "min_eur_value", "raww_eur_value"}
#: Response models of dormant features reached through a shared route.
DORMANT_MODULES = ("app.schemas.learning", "app.schemas.studioverse", "app.schemas.store", "app.schemas.prints", "app.schemas.repair", "app.schemas.legacy_shoot")


def _response_models():
    from app.main import app

    seen: set = set()

    def walk(model):
        if model in seen:
            return
        seen.add(model)
        yield model
        for field in model.model_fields.values():
            for t in typing.get_args(field.annotation) or (field.annotation,):
                for tt in typing.get_args(t) or (t,):
                    if inspect.isclass(tt) and issubclass(tt, BaseModel):
                        yield from walk(tt)

    for route in app.routes:
        model = getattr(route, "response_model", None)
        path = getattr(route, "path", "")
        if model is None or any(part in path for part in DORMANT):
            continue
        for t in typing.get_args(model) or (model,):
            if inspect.isclass(t) and issubclass(t, BaseModel):
                yield from walk(t)


def _is_decimal(annotation) -> bool:
    return any(a is decimal.Decimal for a in (typing.get_args(annotation) or (annotation,)))


def test_every_money_field_in_a_response_has_a_currency_beside_it():
    missing = []
    for model in _response_models():
        if model.__name__ in ALLOWED_WITHOUT_CURRENCY or model.__module__ in DORMANT_MODULES:
            continue
        fields = model.model_fields
        money = [
            n for n, f in fields.items()
            if _is_decimal(f.annotation) and not any(k in n for k in NOT_MONEY) and n not in PER_CURRENCY_SETTINGS
        ]
        if money and not any(n == "currency" or n.endswith("_currency") for n in fields):
            missing.append(f"{model.__name__}: {', '.join(money)}")
    assert missing == []


def test_no_amount_in_a_response_is_named_in_euros():
    named = sorted(
        f"{model.__name__}.{name}"
        for model in _response_models()
        if model.__module__ not in DORMANT_MODULES
        for name in model.model_fields
        if "_eur" in name and name not in PER_CURRENCY_SETTINGS
    )
    assert named == []


# --- client credit is in euros, and pays for euro bookings only (decision M3) -------------------


def test_euro_credit_never_pays_for_a_booking_in_pounds(db_session):
    with pytest.raises(APIError) as err:
        reserve_points_for_discount(
            db_session, user_id=uuid.uuid4(), context_type=RedemptionContextType.gig_payment, context_id=uuid.uuid4(),
            points=1000, payment_amount=Decimal("100.00"), currency="GBP",
        )
    assert err.value.code == "credit_currency_mismatch"
    assert CREDIT_CURRENCY == "EUR"


def test_a_pound_booking_offers_no_euro_credit_and_charges_in_full(client, db_session, fake_stripe):  # noqa: F811
    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    booking, gig = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    gig.currency = "GBP"
    db_session.commit()
    _give(db_session, uuid.UUID(user_id), 3000)

    preview = client.get(f"/v1/client/bookings/{booking.id}/credit", headers=_h(user_id)).json()
    assert (preview["balance"], preview["credit_currency"]) == ("30.00", "EUR")
    assert (preview["discount"], preview["total"], preview["currency"]) == ("0.00", "100.00", "GBP")

    resp = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=_h(user_id)).json()
    assert (resp["credit"], resp["amount"], resp["currency"]) == ("0.00", "100.00", "GBP")
    assert fake_stripe.creates[-1]["amount"] == 10000


def test_the_credit_balance_says_its_currency(client, db_session):
    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    _give(db_session, uuid.UUID(user_id), 150)
    body = client.get("/v1/me/credit", headers=_h(user_id)).json()
    assert (body["balance"], body["currency"]) == ("1.50", "EUR")
    assert body["items"][0]["currency"] == "EUR"


# --- the rest ----------------------------------------------------------------------------------


def test_a_money_line_in_an_email_never_defaults_to_euros():
    assert email_texts._money("12.50", None) is None
    assert email_texts._money("12.50", "GBP") == "£12.50"


def test_a_dispute_is_in_its_bookings_currency_whatever_the_request_says(client, db_session):
    from app.models.admin import Dispute
    from tests.test_disputes_refunds import _create_account, _create_paid_gig

    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _create_account(db_session, client_id)
    _create_account(db_session, pro_id)
    gig = _create_paid_gig(db_session, client_id, pro_id)
    gig.currency = "GBP"
    db_session.commit()
    resp = client.post(
        "/v1/disputes",
        headers={"X-User-Id": client_id},
        json={"gig_id": str(gig.id), "category": "deliverable_quality", "reason": "issue", "requested_refund_amount": "10.00", "currency": "EUR"},
    )
    assert resp.status_code == 200, resp.text
    db_session.expire_all()
    assert db_session.get(Dispute, uuid.UUID(resp.json()["id"])).currency == "GBP"


@pytest.mark.uk_defaults
def test_the_balance_carries_the_payout_minimum_of_its_currency(client, db_session):
    from tests.test_currency_money import _available, _pro

    pro = _pro(db_session, country="GB")
    _available(db_session, pro, "100.00", "GBP")
    db_session.commit()
    body = client.get("/v1/pro/earnings/balance", headers={"X-User-Id": str(pro)}).json()
    assert (body["currency"], body["payout_minimum"]) == ("GBP", "45.00")
    profile = client.get("/v1/pro/me/profile", headers={"X-User-Id": str(pro)}).json()
    assert profile["currency"] == "GBP"
