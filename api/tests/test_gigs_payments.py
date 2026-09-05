import uuid
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.gig import Gig, GigStatus, LedgerEntry, LedgerEntryType


class DummyStripeObject:
    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)


def _create_gig(client, user_id, pro_user_id):
    response = client.post(
        "/v1/gigs",
        headers={"X-User-Id": user_id},
        json={
            "pro_user_id": pro_user_id,
            "amount_total": "100.00",
            "currency": "EUR",
            "location_text": "Lisbon",
        },
    )
    assert response.status_code == 200
    return response.json()["id"]


def _ensure_pro_kyc_approved(db_session, pro_user_id: str):
    pro_uuid = uuid.UUID(pro_user_id)
    if not db_session.get(UserAccount, pro_uuid):
        db_session.add(UserAccount(user_id=pro_uuid))
    if not db_session.query(UserRole).filter_by(user_id=pro_uuid, role=UserRoleType.pro).first():
        db_session.add(UserRole(user_id=pro_uuid, role=UserRoleType.pro))
    profile = db_session.get(ProProfile, pro_uuid)
    if not profile:
        profile = ProProfile(user_id=pro_uuid)
        db_session.add(profile)
    profile.kyc_status = KYCStatus.approved
    db_session.commit()


def test_gig_access_control(client, user_id):
    pro_user_id = str(uuid.uuid4())
    gig_id = _create_gig(client, user_id, pro_user_id)

    outsider = str(uuid.uuid4())
    denied = client.get(f"/v1/gigs/{gig_id}", headers={"X-User-Id": outsider})
    assert denied.status_code == 403

    pro_access = client.get(f"/v1/gigs/{gig_id}", headers={"X-User-Id": pro_user_id})
    assert pro_access.status_code == 200


def test_state_transition_enforced_paid_only_via_webhook(client, db_session, user_id, monkeypatch):
    pro_user_id = str(uuid.uuid4())
    _ensure_pro_kyc_approved(db_session, pro_user_id)
    gig_id = _create_gig(client, user_id, pro_user_id)

    monkeypatch.setattr(
        "app.api.v1.gigs.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripeObject(id="pi_123", client_secret="sec_123", status="requires_payment_method", customer=None),
    )

    create_intent = client.post(
        f"/v1/gigs/{gig_id}/payments/stripe/create-intent",
        headers={"X-User-Id": user_id},
        json={},
    )
    assert create_intent.status_code == 200

    gig = db_session.get(Gig, uuid.UUID(gig_id))
    assert gig.status == GigStatus.payment_pending


def test_stripe_webhook_idempotency_and_ledger_totals(client, db_session, user_id, monkeypatch):
    pro_user_id = str(uuid.uuid4())
    _ensure_pro_kyc_approved(db_session, pro_user_id)
    gig_id = _create_gig(client, user_id, pro_user_id)

    monkeypatch.setattr(
        "app.api.v1.gigs.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripeObject(id="pi_456", client_secret="sec_456", status="requires_payment_method", customer=None),
    )

    intent_resp = client.post(
        f"/v1/gigs/{gig_id}/payments/stripe/create-intent",
        headers={"X-User-Id": user_id},
        json={},
    )
    assert intent_resp.status_code == 200

    event = {
        "id": "evt_pi_succeeded_1",
        "type": "payment_intent.succeeded",
        "data": {
            "object": {
                "id": "pi_456",
            }
        },
    }
    monkeypatch.setattr("app.api.v1.webhooks.construct_stripe_event", lambda raw, sig: event)

    first = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "sig"})
    assert first.status_code == 200

    second = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "sig"})
    assert second.status_code == 200

    gig = db_session.get(Gig, uuid.UUID(gig_id))
    assert gig.status == GigStatus.paid

    captured = (
        db_session.query(LedgerEntry)
        .filter(LedgerEntry.gig_id == gig.id, LedgerEntry.entry_type == LedgerEntryType.payment_captured)
        .all()
    )
    fee_entries = (
        db_session.query(LedgerEntry)
        .filter(LedgerEntry.gig_id == gig.id, LedgerEntry.entry_type == LedgerEntryType.platform_fee)
        .all()
    )
    hold_entries = (
        db_session.query(LedgerEntry)
        .filter(LedgerEntry.gig_id == gig.id, LedgerEntry.entry_type == LedgerEntryType.payout_hold_created)
        .all()
    )

    assert len(captured) == 1
    assert len(fee_entries) == 1
    assert len(hold_entries) == 1

    total = sum(entry.amount for entry in db_session.query(LedgerEntry).filter(LedgerEntry.gig_id == gig.id).all())
    assert total == Decimal("120.00")


def test_stripe_webhook_invalid_signature_returns_401(client):
    response = client.post(
        "/v1/webhooks/stripe",
        json={"id": "evt_bad", "type": "payment_intent.succeeded", "data": {"object": {"id": "pi_bad"}}},
        headers={"stripe-signature": "bad"},
    )
    assert response.status_code == 401
