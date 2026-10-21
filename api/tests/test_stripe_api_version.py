"""One Stripe API version, end to end: what our calls send, what the webhook
endpoints are pinned to, and what the captured fixtures are.

Three were in play: our calls sent 2024-06-20 (STRIPE_API_VERSION), the
library sends 2025-08-27.basil when nothing is set, and the account's
default - which every event was rendered in, and so every fixture -
is 2025-12-15.clover. Endpoints pinned to 2024-06-20 would have delivered
payloads in a shape no test had seen. Now the version is one constant,
2025-12-15.clover, and this fails if any of the three disagree.

The handlers that read payloads are then run on the captured clover events.
"""
import copy
import json
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from pathlib import Path

import stripe
from app.api.v1.webhooks import HANDLED_STRIPE_EVENTS, _apply_stripe_event
from app.core.config import STRIPE_API_VERSION, get_settings
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment, StripePaymentKind

from tests.test_refund_routes import _account

CAPTURE = json.loads((Path(__file__).parent / "fixtures" / "stripe" / "captured_events.json").read_text())


def _all_events():
    yield from CAPTURE["samples"].values()
    for group in ("refund_scenarios", "chargeback_scenarios"):
        for scenario in CAPTURE.get(group, {}).values():
            yield from scenario["events"]


def test_the_version_is_clover():
    assert STRIPE_API_VERSION == "2025-12-15.clover"
    assert get_settings().stripe_api_version == STRIPE_API_VERSION


def test_our_calls_send_it():
    from app.services import stripe_service  # noqa: F401 - sets it

    assert stripe.api_version == STRIPE_API_VERSION


def test_the_endpoints_are_pinned_to_it():
    from scripts.register_stripe_webhook import endpoint_params

    for connect in (False, True):
        assert endpoint_params("https://api.example.test/v1/webhooks/stripe", connect=connect)["api_version"] == STRIPE_API_VERSION


def test_every_fixture_was_captured_in_it():
    assert CAPTURE["api_versions"] == [STRIPE_API_VERSION]
    assert {e["api_version"] for e in _all_events()} == {STRIPE_API_VERSION}


def test_every_handled_event_has_a_captured_sample_in_it():
    captured = {e["type"] for e in _all_events()}
    assert HANDLED_STRIPE_EVENTS <= captured


# --- the handlers that read payloads, on the captured clover events -------------------------


def _pending_booking(db_session, intent: dict) -> Gig:
    client_id, pro_id = _account(db_session), _account(db_session)
    amount = (Decimal(intent["amount"]) / 100).quantize(Decimal("0.01"))
    gig = Gig(
        client_user_id=uuid.UUID(client_id), pro_user_id=uuid.UUID(pro_id), status=GigStatus.payment_pending, currency="EUR",
        amount_minimum=amount, amount_platform_fee=Decimal("0.00"), amount_pro_gross=amount, meta={},
        scheduled_start=datetime.now(timezone.utc) + timedelta(days=5), scheduled_end=datetime.now(timezone.utc) + timedelta(days=5, hours=2),
    )
    db_session.add(gig)
    db_session.flush()
    db_session.add(
        StripePayment(
            gig_id=gig.id, client_user_id=gig.client_user_id, kind=StripePaymentKind.base, status=PaymentStatus.pending,
            stripe_payment_intent_id=intent["id"], amount=amount, currency="EUR", meta={},
        )
    )
    db_session.commit()
    return gig


def _intent(event_type):
    return copy.deepcopy(CAPTURE["samples"][event_type]["data"]["object"])


def test_payment_intent_succeeded_in_clover_pays_the_booking(db_session):
    intent = _intent("payment_intent.succeeded")
    gig = _pending_booking(db_session, intent)

    _apply_stripe_event(db_session, "payment_intent.succeeded", intent)
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(Gig, gig.id).status == GigStatus.paid
    payment = db_session.query(StripePayment).filter_by(gig_id=gig.id).one()
    assert payment.status == PaymentStatus.succeeded
    assert payment.meta.get("paid_at")


def test_payment_intent_payment_failed_in_clover_records_why(db_session):
    intent = _intent("payment_intent.payment_failed")
    gig = _pending_booking(db_session, intent)

    _apply_stripe_event(db_session, "payment_intent.payment_failed", intent)
    db_session.commit()

    db_session.expire_all()
    payment = db_session.query(StripePayment).filter_by(gig_id=gig.id).one()
    assert payment.status == PaymentStatus.failed
    assert payment.last_error


def test_account_updated_in_clover_updates_the_payout_account(db_session):
    from app.models.payouts import PayoutAccount, PayoutAccountStatus, PayoutMethod

    account = _intent("account.updated")
    pro = uuid.UUID(_account(db_session))
    db_session.add(
        PayoutAccount(pro_user_id=pro, payout_method=PayoutMethod.stripe_connect, stripe_connect_account_id=account["id"], status=PayoutAccountStatus.not_set)
    )
    db_session.commit()

    _apply_stripe_event(db_session, "account.updated", account)
    db_session.commit()

    db_session.expire_all()
    from app.services.stripe_connect import status_from_account

    expected = status_from_account(account)
    assert expected != PayoutAccountStatus.not_set
    assert db_session.get(PayoutAccount, pro).status == expected


def test_transfer_created_in_clover_confirms_the_payout(db_session):
    from app.models.payouts import PayoutRequest, PayoutRequestStatus

    pro = uuid.UUID(_account(db_session))
    request = PayoutRequest(pro_user_id=pro, amount_eur=Decimal("10.00"), status=PayoutRequestStatus.processing, reference={})
    db_session.add(request)
    db_session.commit()
    transfer = _intent("transfer.created")
    transfer["metadata"] = {"payout_request_id": str(request.id)}

    _apply_stripe_event(db_session, "transfer.created", transfer)
    db_session.commit()

    db_session.refresh(request)
    assert request.status == PayoutRequestStatus.paid
    assert request.reference["stripe_transfer_id"] == transfer["id"]
