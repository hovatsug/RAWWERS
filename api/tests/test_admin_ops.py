import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.core.config import get_settings
from app.models.admin import (
    AdminAuditLog,
    BanAction,
    BanActionType,
    Dispute,
    KYCStatus,
    ProProfile,
    RefundCase,
    RefundCaseStatus,
    UserAccount,
    UserRole,
    UserRoleType,
)
from app.models.gig import Gig, GigStatus, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment

ADMIN_USER_ID = "00000000-0000-0000-0000-0000000000aa"


class DummyRefund:
    def __init__(self, refund_id="re_123", status="pending"):
        self.id = refund_id
        self.status = status


def _create_account(db_session, user_id: str):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()


def _create_gig(db_session, client_id: str, pro_id: str, status: GigStatus = GigStatus.payment_pending) -> Gig:
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        status=status,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.commit()
    db_session.refresh(gig)
    return gig


def test_admin_auth_non_admin_blocked(client, user_id):
    resp = client.get("/v1/admin/users", headers={"X-User-Id": user_id})
    assert resp.status_code == 403


def test_ban_enforcement_blocks_gig_and_media_create(client, db_session, user_id, monkeypatch):
    _create_account(db_session, user_id)
    db_session.add(
        BanAction(
            user_id=uuid.UUID(user_id),
            action=BanActionType.banned,
            reason="fraud",
            actor_user_id=uuid.UUID(ADMIN_USER_ID),
        )
    )
    db_session.commit()

    gig_resp = client.post(
        "/v1/gigs",
        headers={"X-User-Id": user_id},
        json={"pro_user_id": str(uuid.uuid4()), "amount_total": "100.00", "currency": "EUR"},
    )
    assert gig_resp.status_code == 403

    monkeypatch.setattr("app.api.v1.media.create_presigned_put", lambda storage_key, content_type: "https://signed")
    media_resp = client.post(
        "/v1/media/photos/uploads",
        headers={"X-User-Id": user_id},
        json={"purpose": "proof", "content_type": "image/jpeg", "file_name": "x.jpg"},
    )
    assert media_resp.status_code == 403


def test_kyc_gating_blocks_payment_intent_in_production(client, db_session, user_id, monkeypatch):
    pro_id = str(uuid.uuid4())
    _create_account(db_session, user_id)
    _create_account(db_session, pro_id)
    db_session.add(UserRole(user_id=uuid.UUID(pro_id), role=UserRoleType.pro))
    db_session.commit()

    gig = _create_gig(db_session, user_id, pro_id, status=GigStatus.payment_pending)

    settings = get_settings()
    original_env = settings.app_env
    settings.app_env = "production"

    try:
        response = client.post(
            f"/v1/gigs/{gig.id}/payments/stripe/create-intent",
            headers={"X-User-Id": user_id},
            json={},
        )
        assert response.status_code == 409
    finally:
        settings.app_env = original_env


def test_dispute_open_only_participant_and_sets_gig_disputed(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    outsider = str(uuid.uuid4())

    _create_account(db_session, client_id)
    _create_account(db_session, pro_id)
    _create_account(db_session, outsider)

    gig = _create_gig(db_session, client_id, pro_id, status=GigStatus.paid)

    denied = client.post(
        "/v1/disputes",
        headers={"X-User-Id": outsider},
        json={"gig_id": str(gig.id), "category": "quality", "summary": "Bad output"},
    )
    assert denied.status_code == 403

    allowed = client.post(
        "/v1/disputes",
        headers={"X-User-Id": client_id},
        json={"gig_id": str(gig.id), "category": "quality", "summary": "Bad output"},
    )
    assert allowed.status_code == 200

    db_session.refresh(gig)
    assert gig.status == GigStatus.disputed


def test_admin_refund_creates_case_audit_ledger_and_is_idempotent(client, db_session, monkeypatch):
    admin_id = ADMIN_USER_ID
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())

    _create_account(db_session, admin_id)
    _create_account(db_session, client_id)
    _create_account(db_session, pro_id)

    gig = _create_gig(db_session, client_id, pro_id, status=GigStatus.paid)
    db_session.add(
        StripePayment(
            gig_id=gig.id,
            client_user_id=uuid.UUID(client_id),
            status=PaymentStatus.succeeded,
            stripe_payment_intent_id="pi_admin_refund",
            amount=gig.amount_minimum,
            currency=gig.currency,
            meta={"paid_at": datetime.now(timezone.utc).isoformat()},
        )
    )
    db_session.commit()

    monkeypatch.setattr("app.api.v1.admin.stripe.Refund.create", lambda **kwargs: DummyRefund(refund_id="re_admin_1"))

    first = client.post(
        f"/v1/admin/gigs/{gig.id}/refunds",
        headers={"X-User-Id": admin_id},
        json={"reason": "Ops decision"},
    )
    assert first.status_code == 200

    second = client.post(
        f"/v1/admin/gigs/{gig.id}/refunds",
        headers={"X-User-Id": admin_id},
        json={"reason": "Ops decision"},
    )
    assert second.status_code == 200
    assert first.json()["id"] == second.json()["id"]

    cases = db_session.query(RefundCase).filter_by(gig_id=gig.id).all()
    assert len(cases) == 1
    assert cases[0].status == RefundCaseStatus.processing

    ledger_entries = db_session.query(LedgerEntry).filter_by(gig_id=gig.id, entry_type=LedgerEntryType.refund_initiated).all()
    assert len(ledger_entries) == 1

    logs = db_session.query(AdminAuditLog).filter_by(action="refund_initiated").all()
    assert len(logs) == 1
