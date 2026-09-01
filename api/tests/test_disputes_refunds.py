import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import (
    DisputeCategory,
    Dispute,
    DisputeStatus,
    EntitlementHold,
    EntitlementHoldType,
    RefundCase,
    RefundPaymentScope,
    RefundCaseStatus,
    UserAccount,
    UserRole,
    UserRoleType,
)
from app.models.client_rewards_pricing import ExtraImagePurchase, ExtraImagePurchaseStatus
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment
from app.models.media_rights import GigEntitlementType, GigMediaEntitlement
from app.models.outbox import OutboxEvent
from app.services.disputes import escalate_due_disputes, finalize_refund_case_success, initiate_refund_case

ADMIN_USER_ID = "00000000-0000-0000-0000-0000000000aa"


class DummyRefund:
    def __init__(self, refund_id: str):
        self.id = refund_id
        self.status = "pending"


def _create_account(db_session, user_id: str) -> None:
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()


def _create_paid_gig(db_session, client_id: str, pro_id: str) -> Gig:
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        status=GigStatus.paid,
        currency="EUR",
        amount_total=Decimal("120.00"),
        amount_platform_fee=Decimal("24.00"),
        amount_pro_gross=Decimal("96.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.flush()
    db_session.add(
        StripePayment(
            gig_id=gig.id,
            client_user_id=uuid.UUID(client_id),
            status=PaymentStatus.succeeded,
            stripe_payment_intent_id=f"pi_{gig.id.hex[:12]}",
            amount=gig.amount_total,
            currency=gig.currency,
            meta={"paid_at": datetime.now(timezone.utc).isoformat()},
        )
    )
    db_session.commit()
    db_session.refresh(gig)
    return gig


def test_only_participants_can_open_view_and_message_dispute(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    outsider_id = str(uuid.uuid4())
    _create_account(db_session, client_id)
    _create_account(db_session, pro_id)
    _create_account(db_session, outsider_id)
    gig = _create_paid_gig(db_session, client_id, pro_id)

    denied_open = client.post(
        "/v1/disputes",
        headers={"X-User-Id": outsider_id},
        json={"gig_id": str(gig.id), "category": "deliverable_quality", "reason": "issue"},
    )
    assert denied_open.status_code == 403

    opened = client.post(
        "/v1/disputes",
        headers={"X-User-Id": client_id},
        json={"gig_id": str(gig.id), "category": "deliverable_quality", "reason": "issue"},
    )
    assert opened.status_code == 200
    dispute_id = opened.json()["id"]

    denied_view = client.get(f"/v1/disputes/{dispute_id}", headers={"X-User-Id": outsider_id})
    assert denied_view.status_code == 403

    denied_msg = client.post(
        f"/v1/disputes/{dispute_id}/messages",
        headers={"X-User-Id": outsider_id},
        json={"message": "spam"},
    )
    assert denied_msg.status_code == 403


def test_dispute_window_enforced(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _create_account(db_session, client_id)
    _create_account(db_session, pro_id)
    gig = _create_paid_gig(db_session, client_id, pro_id)
    gig.updated_at = datetime.now(timezone.utc) - timedelta(days=45)
    db_session.commit()

    resp = client.post(
        "/v1/disputes",
        headers={"X-User-Id": client_id},
        json={"gig_id": str(gig.id), "category": "late_delivery", "reason": "too late"},
    )
    assert resp.status_code == 422


def test_escalation_job_moves_dispute_to_awaiting_admin(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _create_account(db_session, client_id)
    _create_account(db_session, pro_id)
    gig = _create_paid_gig(db_session, client_id, pro_id)

    opened = client.post(
        "/v1/disputes",
        headers={"X-User-Id": client_id},
        json={"gig_id": str(gig.id), "category": "late_delivery", "reason": "too late"},
    )
    dispute_id = uuid.UUID(opened.json()["id"])
    dispute = db_session.get(Dispute, dispute_id)
    dispute.due_response_at = datetime.now(timezone.utc) - timedelta(hours=1)
    db_session.commit()

    escalated = escalate_due_disputes(db_session, now=datetime.now(timezone.utc))
    db_session.commit()
    assert escalated >= 1
    db_session.refresh(dispute)
    assert dispute.status == DisputeStatus.awaiting_admin


def test_admin_resolve_creates_refund_case_and_outbox(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _create_account(db_session, ADMIN_USER_ID)
    _create_account(db_session, client_id)
    _create_account(db_session, pro_id)
    db_session.add(UserRole(user_id=uuid.UUID(ADMIN_USER_ID), role=UserRoleType.admin))
    db_session.commit()
    gig = _create_paid_gig(db_session, client_id, pro_id)

    opened = client.post(
        "/v1/disputes",
        headers={"X-User-Id": client_id},
        json={"gig_id": str(gig.id), "category": "no_show", "reason": "did not arrive"},
    )
    dispute_id = opened.json()["id"]
    resolved = client.post(
        f"/v1/admin/disputes/{dispute_id}/resolve",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
        json={"decision": "partial_refund", "amount": "20.00", "rationale": "partial"},
    )
    assert resolved.status_code == 200

    case = db_session.query(RefundCase).filter_by(dispute_id=uuid.UUID(dispute_id)).one()
    assert case.status == RefundCaseStatus.pending
    events = db_session.query(OutboxEvent).filter_by(topic="refund.initiate").all()
    assert any((row.payload or {}).get("refund_case_id") == str(case.id) for row in events)


def test_refund_execution_idempotent(client, db_session, monkeypatch):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _create_account(db_session, client_id)
    _create_account(db_session, pro_id)
    gig = _create_paid_gig(db_session, client_id, pro_id)
    dispute = Dispute(
        gig_id=gig.id,
        opened_by_user_id=uuid.UUID(client_id),
        against_user_id=uuid.UUID(pro_id),
        category=DisputeCategory.billing,
        status=DisputeStatus.awaiting_admin,
        summary="billing issue",
        reason="billing issue",
        currency="EUR",
    )
    db_session.add(dispute)
    db_session.flush()
    case = RefundCase(
        gig_id=gig.id,
        dispute_id=dispute.id,
        requested_by_user_id=uuid.UUID(client_id),
        payment_scope=RefundPaymentScope.booking_payment,
        reference_id=gig.id,
        stripe_payment_intent_id=f"pi_{gig.id.hex[:12]}",
        amount_authorized=Decimal("120.00"),
        amount_refunded=Decimal("0.00"),
        status=RefundCaseStatus.pending,
        amount=Decimal("12.00"),
        currency="EUR",
        reason="billing",
        admin_note=None,
        meta={},
    )
    db_session.add(case)
    db_session.commit()

    calls = {"count": 0}

    def _refund_create(**_kwargs):
        calls["count"] += 1
        return DummyRefund("re_once")

    monkeypatch.setattr("app.services.disputes.stripe.Refund.create", _refund_create)
    initiate_refund_case(db_session, case.id)
    db_session.commit()
    initiate_refund_case(db_session, case.id)
    db_session.commit()

    assert calls["count"] == 1


def test_entitlement_hold_applied_and_released(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _create_account(db_session, ADMIN_USER_ID)
    _create_account(db_session, client_id)
    _create_account(db_session, pro_id)
    db_session.add(UserRole(user_id=uuid.UUID(ADMIN_USER_ID), role=UserRoleType.admin))
    db_session.commit()
    gig = _create_paid_gig(db_session, client_id, pro_id)

    opened = client.post(
        "/v1/disputes",
        headers={"X-User-Id": client_id},
        json={"gig_id": str(gig.id), "category": "billing", "reason": "billing"},
    )
    dispute_id = opened.json()["id"]
    hold = db_session.query(EntitlementHold).filter_by(gig_id=gig.id, hold_type=EntitlementHoldType.downloads_frozen).one()
    assert hold.released_at is None

    resolved = client.post(
        f"/v1/admin/disputes/{dispute_id}/resolve",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
        json={"decision": "no_refund", "rationale": "no breach"},
    )
    assert resolved.status_code == 200
    db_session.refresh(hold)
    assert hold.released_at is not None


def test_partial_refund_extra_purchase_updates_entitlements(db_session, monkeypatch):
    client_id = uuid.uuid4()
    pro_id = uuid.uuid4()
    gig = _create_paid_gig(db_session, str(client_id), str(pro_id))
    extra = ExtraImagePurchase(
        gig_id=gig.id,
        client_user_id=client_id,
        pro_user_id=pro_id,
        niche_id=None,
        included_images=1,
        selected_images=3,
        extra_images=2,
        unit_price_applied=Decimal("10.00"),
        unit_price_configured=Decimal("10.00"),
        policy_unit_price_min=Decimal("0.00"),
        policy_unit_price_max=None,
        subtotal=Decimal("20.00"),
        points_spent=0,
        discounts_total=Decimal("0.00"),
        total=Decimal("20.00"),
        stripe_payment_intent_id="pi_extra_ref",
        status=ExtraImagePurchaseStatus.paid,
        share_link_id=None,
        meta={},
    )
    db_session.add(extra)
    db_session.flush()
    entitlement = GigMediaEntitlement(
        gig_id=gig.id,
        user_id=client_id,
        entitlement_type=GigEntitlementType.download_extras,
        quantity_limit=5,
        valid_from=datetime.now(timezone.utc),
        metadata={},
    )
    db_session.add(entitlement)
    dispute = Dispute(
        gig_id=gig.id,
        extra_purchase_id=extra.id,
        opened_by_user_id=client_id,
        against_user_id=pro_id,
        category=DisputeCategory.billing,
        status=DisputeStatus.awaiting_admin,
        summary="billing",
        reason="billing",
        currency="EUR",
    )
    db_session.add(dispute)
    db_session.flush()
    case = RefundCase(
        gig_id=gig.id,
        dispute_id=dispute.id,
        requested_by_user_id=client_id,
        payment_scope=RefundPaymentScope.extra_image_purchase,
        reference_id=extra.id,
        stripe_payment_intent_id="pi_extra_ref",
        amount_authorized=Decimal("20.00"),
        amount_refunded=Decimal("0.00"),
        status=RefundCaseStatus.pending,
        amount=Decimal("10.00"),
        currency="EUR",
        reason="billing",
        admin_note=None,
        meta={},
    )
    db_session.add(case)
    db_session.commit()

    monkeypatch.setattr("app.services.disputes.stripe.Refund.create", lambda **kwargs: DummyRefund("re_extra"))
    initiate_refund_case(db_session, case.id)
    db_session.commit()
    finalize_refund_case_success(db_session, stripe_refund_id="re_extra")
    db_session.commit()

    db_session.refresh(entitlement)
    db_session.refresh(extra)
    assert entitlement.quantity_limit == 3
    assert extra.status == ExtraImagePurchaseStatus.refunded
