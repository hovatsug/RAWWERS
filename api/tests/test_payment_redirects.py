"""No payment method that leaves the app: every PaymentIntent is created with
automatic_payment_methods {"enabled": True, "allow_redirects": "never"}.

The app's PaymentSheet sets no returnURL and the iOS app registers no URL
scheme, so a redirect-based method (iDEAL, Bancontact, Multibanco...) could
send the client to their bank with no way back into the app. Until that
return path exists, payments are cards and wallets only - and the live
payment-method configuration says the same (DEPLOY_CHECKLIST.md).

Two kinds of check: a scan of the source that fails on any creation path
that does not pass the shared setting (including paths added later), and
recordings of what the creation paths actually send to Stripe.
"""
from __future__ import annotations

import ast
import uuid
from decimal import Decimal
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import MagicMock

import stripe

from app.services.stripe_service import PAYMENT_METHODS

APP = Path(__file__).resolve().parents[1] / "app"
EXPECTED = {"enabled": True, "allow_redirects": "never"}


def _creation_calls():
    """Every `<...>.PaymentIntent.create(...)` call in app/, with where it is."""
    for path in sorted(APP.rglob("*.py")):
        tree = ast.parse(path.read_text(), filename=str(path))
        for node in ast.walk(tree):
            if (
                isinstance(node, ast.Call)
                and isinstance(node.func, ast.Attribute)
                and node.func.attr == "create"
                and isinstance(node.func.value, ast.Attribute)
                and node.func.value.attr == "PaymentIntent"
            ):
                yield f"{path.relative_to(APP.parent)}:{node.lineno}", node


def test_the_shared_setting_allows_no_redirects():
    assert PAYMENT_METHODS == EXPECTED


def test_every_payment_intent_creation_passes_the_shared_setting():
    calls = list(_creation_calls())
    # Booking, proof-gallery upsell (two branches), content pack, store, prints.
    assert len(calls) >= 6, [where for where, _ in calls]

    wrong = []
    for where, call in calls:
        kwargs = {k.arg: k.value for k in call.keywords}
        value = kwargs.get("automatic_payment_methods")
        uses_shared = isinstance(value, (ast.Name, ast.Attribute)) and (
            getattr(value, "id", None) == "PAYMENT_METHODS" or getattr(value, "attr", None) == "PAYMENT_METHODS"
        )
        if not uses_shared or "payment_method_types" in kwargs or None in kwargs:
            wrong.append(where)
    assert wrong == [], f"PaymentIntent created without automatic_payment_methods=PAYMENT_METHODS: {wrong}"


def _recorder(monkeypatch):
    sent: list[dict] = []

    def _create(**kwargs):
        sent.append(kwargs)
        return SimpleNamespace(id=f"pi_{uuid.uuid4().hex[:8]}", client_secret="cs_test", status="requires_payment_method", customer=None)

    monkeypatch.setattr(stripe.PaymentIntent, "create", _create)
    return sent


def test_a_booking_payment_sends_no_redirects(client, db_session, user_id, monkeypatch):
    from tests.test_gigs_payments import _create_gig, _ensure_pro_kyc_approved

    sent = _recorder(monkeypatch)
    pro_user_id = str(uuid.uuid4())
    _ensure_pro_kyc_approved(db_session, pro_user_id)
    gig_id = _create_gig(db_session, user_id, pro_user_id)

    resp = client.post(f"/v1/gigs/{gig_id}/payments/stripe/create-intent", headers={"X-User-Id": user_id}, json={})

    assert resp.status_code == 200, resp.text
    assert [k["automatic_payment_methods"] for k in sent] == [EXPECTED]


def test_a_content_pack_payment_sends_no_redirects(monkeypatch):
    from app.services.studioverse import create_stripe_payment_intent_for_pack

    sent = _recorder(monkeypatch)
    create_stripe_payment_intent_for_pack(
        order_id=uuid.uuid4(), buyer_user_id=uuid.uuid4(),
        pack=SimpleNamespace(id=uuid.uuid4(), creator_user_id=uuid.uuid4(), currency="EUR"), amount=Decimal("12.00"),
    )

    assert [k["automatic_payment_methods"] for k in sent] == [EXPECTED]


def test_a_print_order_payment_sends_no_redirects(monkeypatch):
    from app.models.prints import PrintOrderStatus
    from app.services.prints_fulfillment import create_print_payment_intent

    sent = _recorder(monkeypatch)
    order = SimpleNamespace(
        id=uuid.uuid4(), gig_id=uuid.uuid4(), client_user_id=uuid.uuid4(), status=PrintOrderStatus.draft,
        total_eur=Decimal("30.00"), currency="EUR", stripe_payment_intent_id=None, updated_at=None,
    )
    create_print_payment_intent(MagicMock(), order=order)

    assert [k["automatic_payment_methods"] for k in sent] == [EXPECTED]
