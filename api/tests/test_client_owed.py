"""Any state in which a client is owed money is on "Money to act on".

A refund that fails, a reduction whose refund could not be issued, and - the
net under both - a booking whose client has kept more than its price with
nothing refunding it. Oldest first, closed only with a note.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from sqlalchemy import select

from app.models.admin import MoneyAttentionItem, RefundCase, UserAccount
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.services.client_owed import raise_clients_owed

ADMIN = "00000000-0000-0000-0000-0000000000aa"
D = Decimal


def _gig(db, *, minimum="79.74", final=None, paid="79.74", refunded="0.00", status=GigStatus.completed) -> Gig:
    client_id, pro_id = uuid.uuid4(), uuid.uuid4()
    db.add_all([UserAccount(user_id=client_id), UserAccount(user_id=pro_id)])
    db.flush()
    gig = Gig(client_user_id=client_id, pro_user_id=pro_id, status=status, currency="EUR", amount_minimum=D(minimum),
              amount_final=D(final) if final else None, amount_platform_fee=D("0.00"), amount_pro_gross=D("0.00"), meta={})
    db.add(gig)
    db.flush()
    db.add(StripePayment(gig_id=gig.id, kind=StripePaymentKind.base, client_user_id=client_id, status=PaymentStatus.succeeded,
                         stripe_payment_intent_id=f"pi_{gig.id.hex}", amount=D(paid), amount_refunded=D(refunded), currency="EUR", meta={}))
    db.commit()
    return gig


def _owed(db, gig):
    db.expire_all()
    return db.execute(select(MoneyAttentionItem).where(MoneyAttentionItem.gig_id == gig.id, MoneyAttentionItem.kind == "client_owed")).scalars().all()


def test_a_price_below_what_was_paid_with_no_refund_is_raised(db_session):
    gig = _gig(db_session, final="52.43")  # the owner's booking

    assert raise_clients_owed(db_session) == 1
    db_session.commit()

    [item] = _owed(db_session, gig)
    assert item.amount == D("27.31") and item.status == "open"


def test_raised_once_while_open(db_session):
    gig = _gig(db_session, final="52.43")
    raise_clients_owed(db_session)
    raise_clients_owed(db_session)
    db_session.commit()
    assert len(_owed(db_session, gig)) == 1


def test_a_refund_under_way_is_not_a_debt(db_session):
    gig = _gig(db_session, final="52.43")
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    db_session.add(RefundCase(gig_id=gig.id, requested_by_user_id=uuid.UUID(ADMIN), stripe_payment_intent_id=payment.stripe_payment_intent_id,
                              status="processing", amount=D("27.31"), currency="EUR", meta={"stripe_payment_id": str(payment.id)}))
    db_session.commit()

    assert raise_clients_owed(db_session) == 0


def test_paid_exactly_the_price_owes_nothing(db_session):
    _gig(db_session)
    _gig(db_session, minimum="20.00", final="40.00", paid="20.00")  # still to pay - owed by the client, not to them
    assert raise_clients_owed(db_session) == 0


def test_the_sweep_runs_on_beat():
    from app.tasks.celery_app import celery_app

    assert "app.tasks.scheduled.raise_clients_owed" in {e["task"] for e in celery_app.conf.beat_schedule.values()}


def test_money_to_act_on_lists_oldest_first(client, db_session):
    now = datetime.now(timezone.utc)
    for age in (1, 5, 3):
        gig = _gig(db_session)
        db_session.add(MoneyAttentionItem(kind="client_owed", status="open", gig_id=gig.id, amount=D(str(age)), currency="EUR",
                                          note=f"{age} days", created_at=now - timedelta(days=age)))
    db_session.commit()

    items = client.get("/v1/admin/money-attention", headers={"X-User-Id": ADMIN}).json()["items"]

    assert [i["note"] for i in items] == ["5 days", "3 days", "1 days"]


def test_closing_an_item_needs_a_note(client, db_session):
    gig = _gig(db_session, final="52.43")
    raise_clients_owed(db_session)
    db_session.commit()
    [item] = _owed(db_session, gig)

    refused = client.post(f"/v1/admin/money-attention/{item.id}/resolve", headers={"X-User-Id": ADMIN}, json={"note": " "})
    closed = client.post(f"/v1/admin/money-attention/{item.id}/resolve", headers={"X-User-Id": ADMIN}, json={"note": "Refunded 27.31"})

    assert refused.status_code == 422 and closed.status_code == 200
