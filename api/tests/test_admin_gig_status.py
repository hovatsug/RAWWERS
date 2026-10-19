"""The admin status route moves a gig only along the state machine.

It wrote any of five statuses straight onto the gig, whatever it was
before: a paid booking could be marked cancelled with the money still
taken, a completed one reopened as disputed, anything marked refunded
without a cent going back. Now it goes through transition_gig, so only
legal moves happen, and the statuses that mean money - paid, refunded,
disputed - are refused here with the route that owns each: the payment
webhook, the refund routes, a dispute. Every change it makes is recorded
twice: the gig's transition (who, why) and the admin audit log.
"""
import pytest
from app.models.admin import AdminAuditLog
from app.models.gig import Gig, GigStatus, GigTransition
from sqlalchemy import select

from tests.test_refund_routes import _paid_booking

ADMIN = "00000000-0000-0000-0000-0000000000aa"  # the suite's admin (conftest)


def _set(client, gig, status, actor=ADMIN):
    return client.post(
        f"/v1/admin/gigs/{gig.id}/status", headers={"X-User-Id": actor}, json={"status": status, "reason": "Support call"}
    )


def _trail(db_session, gig):
    db_session.expire_all()
    transitions = db_session.execute(select(GigTransition).where(GigTransition.gig_id == gig.id)).scalars().all()
    audits = db_session.execute(
        select(AdminAuditLog).where(AdminAuditLog.target_type == "gig", AdminAuditLog.target_id == str(gig.id))
    ).scalars().all()
    return transitions, audits


def test_an_unpaid_booking_can_be_cancelled_and_it_is_recorded(client, db_session):
    gig, _client, _pro = _paid_booking(db_session, status=GigStatus.payment_pending)

    resp = _set(client, gig, "cancelled_by_client")

    assert resp.status_code == 200, resp.text
    assert db_session.get(Gig, gig.id).status == GigStatus.cancelled_by_client
    [transition], [audit] = _trail(db_session, gig)
    assert (transition.from_status, transition.to_status, str(transition.actor_user_id)) == (
        GigStatus.payment_pending, GigStatus.cancelled_by_client, ADMIN
    )
    assert transition.reason == "Support call"
    assert (audit.action, audit.meta["from_status"], audit.meta["to_status"]) == ("gig_status_update", "payment_pending", "cancelled_by_client")


@pytest.mark.parametrize("target", ["cancelled_by_client", "cancelled_by_pro"])
def test_a_paid_booking_cannot_simply_be_marked_cancelled(client, db_session, target):
    """The money would stay taken. Cancelling a paid booking is a refund."""
    gig, _client, _pro = _paid_booking(db_session)

    resp = _set(client, gig, target)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "invalid_state_transition"
    assert db_session.get(Gig, gig.id).status == GigStatus.paid
    assert _trail(db_session, gig) == ([], [])


@pytest.mark.parametrize(
    "target, owner",
    [("paid", "payment"), ("refunded", "refund"), ("disputed", "dispute")],
)
@pytest.mark.parametrize("start", [GigStatus.payment_pending, GigStatus.paid])
def test_money_states_only_through_their_own_routes(client, db_session, target, owner, start):
    gig, _client, _pro = _paid_booking(db_session, status=start)

    resp = _set(client, gig, target)

    assert resp.status_code == 409, resp.text
    error = resp.json()["error"]
    assert error["code"] == "money_state_has_its_own_route"
    assert owner in error["message"].lower()
    assert db_session.get(Gig, gig.id).status == start
    assert _trail(db_session, gig) == ([], [])


@pytest.mark.parametrize("terminal", [GigStatus.completed, GigStatus.refunded, GigStatus.cancelled_by_client])
def test_a_finished_booking_is_not_reopened(client, db_session, terminal):
    gig, _client, _pro = _paid_booking(db_session, status=terminal)

    for target in ("completed", "cancelled_by_pro"):
        if target == terminal.value:
            continue
        assert _set(client, gig, target).status_code == 409

    assert db_session.get(Gig, gig.id).status == terminal


def test_a_disputed_booking_is_not_closed_here(client, db_session):
    """A dispute ends through its resolution, which decides the money."""
    gig, _client, _pro = _paid_booking(db_session, status=GigStatus.disputed)

    for target in ("completed", "cancelled_by_client"):
        assert _set(client, gig, target).status_code == 409

    assert db_session.get(Gig, gig.id).status == GigStatus.disputed


def test_completing_a_paid_booking_still_works_and_is_recorded(client, db_session):
    gig, _client, _pro = _paid_booking(db_session)

    assert _set(client, gig, "completed").status_code == 200

    assert db_session.get(Gig, gig.id).status == GigStatus.completed
    [transition], [audit] = _trail(db_session, gig)
    assert transition.to_status == GigStatus.completed and audit.meta["to_status"] == "completed"


def test_only_an_admin(client, db_session):
    gig, client_id, _pro = _paid_booking(db_session, status=GigStatus.payment_pending)

    assert _set(client, gig, "cancelled_by_client", actor=client_id).status_code == 403
    assert db_session.get(Gig, gig.id).status == GigStatus.payment_pending


def test_setting_the_status_it_already_has_records_nothing(client, db_session):
    gig, _client, _pro = _paid_booking(db_session, status=GigStatus.payment_pending)
    assert _set(client, gig, "cancelled_by_client").status_code == 200

    assert _set(client, gig, "cancelled_by_client").status_code == 409

    transitions, audits = _trail(db_session, gig)
    assert len(transitions) == 1 and len(audits) == 1
