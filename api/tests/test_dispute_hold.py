"""A disputed booking keeps its time, and a dispute that ends without a
refund gives the booking back as it was.

`disputed` released the photographer's calendar: while a client disputed a
shoot that had not happened yet, someone else could book that time. And a
dispute that ended with no refund left the gig `disputed` for good - it
could never complete, and so never pay the photographer. Now `disputed`
holds the time; the status before the dispute is stored when it opens (from
the client, or from a Stripe chargeback), and a dispute that ends without a
refund - no-refund resolution, cancelled, closed - returns the gig to it,
once no other dispute on it is open.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from app.models.admin import Dispute, DisputeCategory, DisputeStatus
from app.models.gig import Gig, GigStatus, GigTransition
from app.services.bookable_time import load_calendar
from sqlalchemy import select

from tests.test_refund_caps import stripe_all  # noqa: F401 - fixture
from tests.test_refund_routes import _paid_booking, stripe_refunds  # noqa: F401 - fixture

ADMIN = "00000000-0000-0000-0000-0000000000aa"


def _booking(db_session, status=GigStatus.paid):
    gig, client_id, pro_id = _paid_booking(db_session, status=status)
    gig.scheduled_start = datetime.now(timezone.utc).replace(microsecond=0) + timedelta(days=4)
    gig.scheduled_end = gig.scheduled_start + timedelta(hours=2)
    db_session.commit()
    return gig, client_id


def _open(client, gig, client_id):
    resp = client.post(
        "/v1/disputes",
        headers={"X-User-Id": client_id},
        json={"gig_id": str(gig.id), "category": "no_show", "reason": "Not sure they will come", "summary": "x"},
    )
    assert resp.status_code == 200, resp.text
    return resp.json()["id"]


def _status(db_session, gig):
    db_session.expire_all()
    return db_session.get(Gig, gig.id).status


def _holds_time(db_session, gig) -> bool:
    db_session.expire_all()
    gig = db_session.get(Gig, gig.id)
    cal = load_calendar(db_session, pro_user_id=gig.pro_user_id, start=gig.scheduled_start, end=gig.scheduled_end)
    return any(b.gig_id == gig.id for b in cal.bookings)


def test_a_disputed_booking_keeps_its_time(client, db_session):
    gig, client_id = _booking(db_session)
    assert _holds_time(db_session, gig)

    _open(client, gig, client_id)

    assert _status(db_session, gig) == GigStatus.disputed
    assert _holds_time(db_session, gig), "nobody else may book that time while it is disputed"


def test_the_status_before_the_dispute_is_stored(client, db_session):
    gig, client_id = _booking(db_session)

    _open(client, gig, client_id)

    db_session.expire_all()
    assert db_session.get(Gig, gig.id).meta["pre_dispute_status"] == "paid"


@pytest.mark.parametrize(
    "end",
    ["resolve_no_refund", "cancel_by_client", "set_status_resolved_no_refund", "set_status_closed", "status_cancelled"],
)
def test_a_dispute_ending_without_a_refund_returns_the_booking(client, db_session, stripe_all, end):
    gig, client_id = _booking(db_session)
    dispute_id = _open(client, gig, client_id)

    admin = {"X-User-Id": ADMIN}
    if end == "resolve_no_refund":
        resp = client.post(f"/v1/admin/disputes/{dispute_id}/resolve", headers=admin, json={"decision": "no_refund", "rationale": "No breach"})
    elif end == "cancel_by_client":
        resp = client.post(f"/v1/disputes/{dispute_id}/cancel", headers={"X-User-Id": client_id})
    elif end == "set_status_resolved_no_refund":
        resp = client.post(f"/v1/admin/disputes/{dispute_id}/set-status", headers=admin, json={"status": "resolved_no_refund"})
    elif end == "set_status_closed":
        resp = client.post(f"/v1/admin/disputes/{dispute_id}/set-status", headers=admin, json={"status": "closed"})
    else:
        resp = client.post(f"/v1/admin/disputes/{dispute_id}/status", headers=admin, json={"status": "cancelled"})
    assert resp.status_code == 200, resp.text

    assert _status(db_session, gig) == GigStatus.paid
    assert _holds_time(db_session, gig)
    back = db_session.execute(
        select(GigTransition).where(GigTransition.gig_id == gig.id, GigTransition.from_status == GigStatus.disputed)
    ).scalars().all()
    assert [(t.to_status, bool(t.reason)) for t in back] == [(GigStatus.paid, True)]


def test_a_dispute_still_under_review_does_not_return_it(client, db_session):
    gig, client_id = _booking(db_session)
    dispute_id = _open(client, gig, client_id)

    resp = client.post(f"/v1/admin/disputes/{dispute_id}/set-status", headers={"X-User-Id": ADMIN}, json={"status": "in_review"})

    assert resp.status_code == 200
    assert _status(db_session, gig) == GigStatus.disputed


def test_while_another_dispute_is_open_it_stays_disputed(client, db_session):
    gig, client_id = _booking(db_session)
    first = _open(client, gig, client_id)
    db_session.add(
        Dispute(
            gig_id=gig.id, opened_by_user_id=gig.pro_user_id, against_user_id=gig.client_user_id, status=DisputeStatus.open,
            category=DisputeCategory.deliverable_quality, currency="EUR", summary="The pro's own", resolution={}, meta={},
        )
    )
    db_session.commit()

    client.post(f"/v1/disputes/{first}/cancel", headers={"X-User-Id": client_id})

    assert _status(db_session, gig) == GigStatus.disputed


def test_a_completed_booking_comes_back_completed(client, db_session):
    gig, client_id = _booking(db_session, status=GigStatus.completed)
    dispute_id = _open(client, gig, client_id)
    assert _status(db_session, gig) == GigStatus.disputed

    client.post(f"/v1/admin/disputes/{dispute_id}/resolve", headers={"X-User-Id": ADMIN}, json={"decision": "no_refund", "rationale": "x"})

    assert _status(db_session, gig) == GigStatus.completed


def test_a_full_refund_still_ends_it(client, db_session, stripe_all):
    """A refund is not "without a refund": the full one ends the booking
    through the refund path, as before."""
    gig, client_id = _booking(db_session)
    dispute_id = _open(client, gig, client_id)

    client.post(f"/v1/admin/disputes/{dispute_id}/resolve", headers={"X-User-Id": ADMIN}, json={"decision": "full_refund", "rationale": "x"})

    assert _status(db_session, gig) == GigStatus.disputed, "until Stripe confirms the refund"


# --- Stripe chargebacks ----------------------------------------------------------------------


def _chargeback(db_session, gig):
    import copy
    import json
    from pathlib import Path

    from app.api.v1.webhooks import _apply_stripe_event
    from app.models.gig import StripePayment

    capture = json.loads((Path(__file__).parent / "fixtures" / "stripe" / "captured_events.json").read_text())
    obj = copy.deepcopy(capture["samples"]["charge.dispute.created"]["data"]["object"])
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    obj["payment_intent"] = payment.stripe_payment_intent_id
    obj["id"] = f"dp_{uuid.uuid4().hex[:12]}"
    _apply_stripe_event(db_session, "charge.dispute.created", obj)
    db_session.commit()


def test_a_chargeback_stores_the_status_and_keeps_the_time(db_session):
    gig, _client = _booking(db_session)

    _chargeback(db_session, gig)

    assert _status(db_session, gig) == GigStatus.disputed
    assert db_session.get(Gig, gig.id).meta["pre_dispute_status"] == "paid"
    assert _holds_time(db_session, gig)


def test_a_chargeback_on_a_completed_booking_is_recorded(db_session):
    """It used to raise "completed -> disputed not allowed", failing the
    event on every retry: nothing of the chargeback was recorded."""
    gig, _client = _booking(db_session, status=GigStatus.completed)

    _chargeback(db_session, gig)

    assert _status(db_session, gig) == GigStatus.disputed
    assert db_session.get(Gig, gig.id).meta["pre_dispute_status"] == "completed"
