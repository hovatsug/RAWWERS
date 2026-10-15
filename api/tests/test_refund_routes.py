"""The two refund routes no test called: a client refunding a paid booking
within a day of paying, and an admin retrying a refund case.

Both send money back to a card. What must hold: only the client, only a
paid booking, only inside the window, each payment refunded once whatever
is retried or repeated - and a refund that failed can be tried again for
real, rather than replayed.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from app.models.admin import AdminAuditLog, RefundCase, RefundCaseStatus, RefundPaymentScope, UserAccount
from app.models.gig import Gig, GigStatus, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment
from app.models.outbox import OutboxEvent
from sqlalchemy import select

ADMIN = "00000000-0000-0000-0000-0000000000aa"  # the suite's admin (conftest)


class _Stripe:
    """Stripe's Refund.create, recorded. An idempotency key seen before
    replays the first answer, as Stripe does for 24 hours."""

    def __init__(self):
        self.calls: list[dict] = []
        self.by_key: dict[str, object] = {}
        self.next_status = "pending"

    def create(self, **kwargs):
        self.calls.append(kwargs)
        key = kwargs.get("idempotency_key")
        if key in self.by_key:
            return self.by_key[key]
        refund = type("Refund", (), {"id": f"re_{len(self.by_key) + 1}", "status": self.next_status})()
        self.by_key[key] = refund
        return refund


@pytest.fixture
def stripe_refunds(monkeypatch):
    fake = _Stripe()
    monkeypatch.setattr("app.api.v1.gigs.stripe.Refund.create", fake.create)
    monkeypatch.setattr("app.services.disputes.stripe.Refund.create", fake.create)
    return fake


def _account(db_session) -> str:
    uid = uuid.uuid4()
    db_session.add(UserAccount(user_id=uid))
    db_session.commit()
    return str(uid)


def _paid_booking(db_session, *, paid_hours_ago=1.0, status=GigStatus.paid, payments=1) -> tuple[Gig, str, str]:
    client_id, pro_id = _account(db_session), _account(db_session)
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
    db_session.flush()
    paid_at = datetime.now(timezone.utc) - timedelta(hours=paid_hours_ago)
    for n in range(payments):
        db_session.add(
            StripePayment(
                gig_id=gig.id,
                client_user_id=gig.client_user_id,
                status=PaymentStatus.succeeded,
                stripe_payment_intent_id=f"pi_{gig.id.hex[:10]}_{n}",
                amount=Decimal("100.00") if n == 0 else Decimal("20.00"),
                currency="EUR",
                meta={"paid_at": (paid_at + timedelta(minutes=n)).isoformat()},
            )
        )
    db_session.commit()
    return gig, client_id, pro_id


def _refund(client, gig, user_id):
    return client.post(f"/v1/gigs/{gig.id}/refunds/stripe", headers={"X-User-Id": user_id}, json={"reason": "Plans changed"})


def _initiated(db_session, gig) -> list[LedgerEntry]:
    db_session.expire_all()
    return db_session.execute(
        select(LedgerEntry).where(LedgerEntry.gig_id == gig.id, LedgerEntry.entry_type == LedgerEntryType.refund_initiated)
    ).scalars().all()


# --- a client refunding a paid booking ---------------------------------------------------


def test_the_client_can_refund_a_paid_booking_within_a_day_of_paying(client, db_session, stripe_refunds):
    gig, client_id, _pro = _paid_booking(db_session)

    resp = _refund(client, gig, client_id)

    assert resp.status_code == 200, resp.text
    [call] = stripe_refunds.calls
    assert call["payment_intent"] == f"pi_{gig.id.hex[:10]}_0"
    assert call["idempotency_key"].startswith(f"gig:{gig.id}:client-refund:")
    assert len(_initiated(db_session, gig)) == 1


def test_every_payment_on_the_booking_is_refunded(client, db_session, stripe_refunds):
    gig, client_id, _pro = _paid_booking(db_session, payments=2)

    resp = _refund(client, gig, client_id)

    assert resp.status_code == 200, resp.text
    assert sorted(c["payment_intent"] for c in stripe_refunds.calls) == sorted(f"pi_{gig.id.hex[:10]}_{n}" for n in range(2))
    assert len(resp.json()["refund_ids"]) == 2


def test_asking_again_neither_refunds_twice_nor_records_it_twice(client, db_session, stripe_refunds):
    gig, client_id, _pro = _paid_booking(db_session)
    first = _refund(client, gig, client_id)

    second = _refund(client, gig, client_id)

    assert second.status_code == 200, second.text
    assert second.json()["refund_ids"] == first.json()["refund_ids"], "Stripe saw the same key: the same refund"
    assert len({c["idempotency_key"] for c in stripe_refunds.calls}) == 1
    assert len(_initiated(db_session, gig)) == 1, "one ledger line per refund, however often asked"


def test_only_the_client_can_refund(client, db_session, stripe_refunds):
    gig, _client, pro_id = _paid_booking(db_session)

    for someone in (pro_id, _account(db_session)):
        assert _refund(client, gig, someone).status_code == 403
    assert stripe_refunds.calls == []
    assert client.post(f"/v1/gigs/{gig.id}/refunds/stripe", json={}).status_code == 401


@pytest.mark.parametrize("status", [GigStatus.payment_pending, GigStatus.shoot_done, GigStatus.cancelled_by_client])
def test_only_a_paid_booking_can_be_refunded(client, db_session, stripe_refunds, status):
    gig, client_id, _pro = _paid_booking(db_session, status=status)

    assert _refund(client, gig, client_id).status_code == 409
    assert stripe_refunds.calls == []


def test_after_a_day_the_client_cannot_refund_it_themselves(client, db_session, stripe_refunds):
    gig, client_id, _pro = _paid_booking(db_session, paid_hours_ago=24.5)

    resp = _refund(client, gig, client_id)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "refund_not_allowed"
    assert stripe_refunds.calls == []


def test_no_successful_payment_means_nothing_to_refund(client, db_session, stripe_refunds):
    gig, client_id, _pro = _paid_booking(db_session, payments=0)

    assert _refund(client, gig, client_id).status_code == 409
    assert stripe_refunds.calls == []


def test_an_unknown_booking_is_not_found(client, db_session, stripe_refunds):
    assert client.post(f"/v1/gigs/{uuid.uuid4()}/refunds/stripe", headers={"X-User-Id": _account(db_session)}, json={}).status_code == 404


# --- an admin retrying a refund case ----------------------------------------------------


def _case(db_session, status=RefundCaseStatus.failed, meta=None) -> RefundCase:
    gig, client_id, _pro = _paid_booking(db_session)
    case = RefundCase(
        gig_id=gig.id,
        requested_by_user_id=uuid.UUID(client_id),
        payment_scope=RefundPaymentScope.booking_payment,
        reference_id=gig.id,
        stripe_payment_intent_id=f"pi_{gig.id.hex[:10]}_0",
        amount_authorized=Decimal("100.00"),
        amount_refunded=Decimal("0.00"),
        status=status,
        amount=Decimal("100.00"),
        currency="EUR",
        reason="booking cancelled",
        admin_note=None,
        meta=meta or {},
    )
    db_session.add(case)
    db_session.commit()
    return case


def _retry(client, case, actor=ADMIN):
    return client.post(f"/v1/admin/refunds/{case.id}/retry", headers={"X-User-Id": actor})


def _retry_events(db_session, case) -> list[OutboxEvent]:
    db_session.expire_all()
    return [e for e in db_session.execute(select(OutboxEvent).where(OutboxEvent.topic == "refund.initiate")).scalars() if e.payload.get("refund_case_id") == str(case.id)]


def _run(db_session, event):
    from app.tasks.outbox_tasks import _dispatch_event

    _dispatch_event(db_session, event.topic, event.payload)
    db_session.commit()


def test_an_admin_retry_queues_the_refund_and_is_audited(client, db_session, stripe_refunds):
    case = _case(db_session)

    resp = _retry(client, case)

    assert resp.status_code == 200, resp.text
    assert len(_retry_events(db_session, case)) == 1
    audit = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_id == str(case.id))).scalars().all()
    assert [(a.action, a.meta.get("status")) for a in audit] == [("refund_retry_enqueued", "failed")]


def test_only_an_admin_can_retry(client, db_session, stripe_refunds):
    case = _case(db_session)

    assert _retry(client, case, actor=str(case.requested_by_user_id)).status_code == 403
    assert _retry_events(db_session, case) == []


@pytest.mark.parametrize("status", [RefundCaseStatus.refunded, RefundCaseStatus.succeeded, RefundCaseStatus.cancelled, RefundCaseStatus.rejected])
def test_a_finished_refund_cannot_be_retried(client, db_session, stripe_refunds, status):
    case = _case(db_session, status=status)

    assert _retry(client, case).status_code == 409
    assert _retry_events(db_session, case) == []


def test_an_unknown_refund_case_is_not_found(client, db_session):
    assert client.post(f"/v1/admin/refunds/{uuid.uuid4()}/retry", headers={"X-User-Id": ADMIN}).status_code == 404


def test_retrying_a_failed_refund_really_asks_stripe_again(client, db_session, stripe_refunds):
    """Stripe answers a repeated idempotency key with the first answer for
    24 hours. A failed refund retried under the same key gets its own
    failure back, and the case sat at refund_initiated with no money moved.
    Each attempt after a failure has a key of its own."""
    from app.services.disputes import finalize_refund_case_failed, initiate_refund_case

    case = _case(db_session, status=RefundCaseStatus.pending)
    initiate_refund_case(db_session, case.id)
    db_session.commit()
    failed_id = db_session.get(RefundCase, case.id).meta["stripe_refund_id"]
    finalize_refund_case_failed(db_session, stripe_refund_id=failed_id, reason="card expired")
    db_session.commit()

    _retry(client, case)
    [event] = _retry_events(db_session, case)
    _run(db_session, event)

    first_key, second_key = (c["idempotency_key"] for c in stripe_refunds.calls)
    assert first_key != second_key
    db_session.expire_all()
    assert db_session.get(RefundCase, case.id).meta["stripe_refund_id"] != failed_id


def test_retrying_a_refund_that_has_not_failed_never_refunds_twice(client, db_session, stripe_refunds):
    """A case still pending - its first attempt may or may not have reached
    Stripe - is retried under the same key, so Stripe cannot make a second
    refund."""
    from app.services.disputes import initiate_refund_case

    case = _case(db_session, status=RefundCaseStatus.pending)
    initiate_refund_case(db_session, case.id)
    db_session.rollback()  # the first attempt reached Stripe; our record of it was lost
    db_session.expire_all()

    _retry(client, case)
    [event] = _retry_events(db_session, case)
    _run(db_session, event)

    keys = [c["idempotency_key"] for c in stripe_refunds.calls]
    assert len(keys) == 2 and keys[0] == keys[1]
    assert len(stripe_refunds.by_key) == 1, "one refund at Stripe"
