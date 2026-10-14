"""Three scheduling routes no test called: asking to reschedule, cancelling a
confirmed slot, and the photographer's scheduling policy.

A reschedule only proposes windows and frees the confirmed slot; the new time
is set by confirm-slot, which judges any time other than the one requested as
a new request made now (see test_available_now). So the end-to-end case here
is the one that matters: proposed, confirmed inside the window, and refused
inside the photographer's notice.
"""
from datetime import timedelta

from app.models.booking import ConfirmedSlot, ConfirmedSlotStatus, ProSchedulingPolicy
from sqlalchemy import select

from tests.test_available_now import (  # noqa: F401 - _no_presence_left_over is autouse
    _available,
    _booking,
    _confirm,
    _gig_for,
    _no_presence_left_over,
    _offered,
    _ordinary_request,
    _short_notice_pro,
    _slot_in,
    _toggle,
)
from tests.test_bookable_time import _no_stripe, _second_client  # noqa: F401 - _no_stripe is autouse

ADMIN = "00000000-0000-0000-0000-0000000000aa"  # the suite's admin (conftest)


def _confirmed(client, db_session):
    """An accepted booking with its slot confirmed at the requested time."""
    pro = _short_notice_pro(db_session)
    booking_id = _ordinary_request(client, db_session, pro, accept=True)
    booking = _booking(db_session, booking_id)
    assert _confirm(client, pro, booking_id, booking.requested_start, booking.requested_end).status_code == 200
    return pro, booking_id, _gig_for(db_session, booking_id)


def _slot(db_session, gig) -> ConfirmedSlot:
    db_session.expire_all()
    return db_session.execute(select(ConfirmedSlot).where(ConfirmedSlot.gig_id == gig.id)).scalar_one()


def _reschedule(client, gig, user_id, windows):
    return client.post(
        f"/v1/gigs/{gig.id}/reschedule-request",
        headers={"X-User-Id": user_id},
        json={
            "client_timezone": "Europe/Lisbon",
            "proposed_windows": [{"start_at_utc": s.isoformat(), "end_at_utc": e.isoformat()} for s, e in windows],
        },
    )


# --- reschedule-request ------------------------------------------------------------


def test_a_reschedule_frees_the_slot_and_records_the_windows(client, db_session):
    pro, _booking_id, gig = _confirmed(client, db_session)
    start, _ = _slot_in(50)

    resp = _reschedule(client, gig, pro.client_id, [(start, start + timedelta(hours=4))])

    assert resp.status_code == 200, resp.text
    assert len(resp.json()["windows"]) == 1
    slot = _slot(db_session, gig)
    assert slot.status == ConfirmedSlotStatus.cancelled and slot.cancellation_reason == "reschedule"


def test_the_new_time_must_be_inside_a_proposed_window(client, db_session):
    pro, booking_id, gig = _confirmed(client, db_session)
    start, _ = _slot_in(50)
    assert _reschedule(client, gig, pro.client_id, [(start, start + timedelta(hours=2))]).status_code == 200

    outside, outside_end = _slot_in(60)
    assert _confirm(client, pro, booking_id, outside, outside_end).status_code == 409
    resp = _confirm(client, pro, booking_id, start, start + timedelta(hours=1))
    assert resp.status_code == 200, resp.text
    assert _gig_for(db_session, booking_id).scheduled_start == start


def test_a_reschedule_into_the_notice_period_is_refused_unless_available_now(client, db_session):
    """The hole confirm-slot had: the new time was judged by notice counted
    from when the original request was made."""
    pro, booking_id, gig = _confirmed(client, db_session)
    booking = _booking(db_session, booking_id)
    booking.created_at -= timedelta(days=7)
    db_session.commit()
    start, end = _slot_in(3)
    assert _reschedule(client, gig, pro.client_id, [(start, end)]).status_code == 200

    assert _confirm(client, pro, booking_id, start, end).status_code == 409
    _available(client, db_session, pro)
    assert _confirm(client, pro, booking_id, start, end).status_code == 200


def test_only_the_two_people_on_the_booking_can_ask_to_reschedule(client, db_session):
    pro, _booking_id, gig = _confirmed(client, db_session)
    start, _ = _slot_in(50)
    window = [(start, start + timedelta(hours=2))]

    assert _reschedule(client, gig, _second_client(db_session), window).status_code == 403
    assert _reschedule(client, gig, pro.id, window).status_code == 200


def test_a_window_must_end_after_it_starts(client, db_session):
    pro, _booking_id, gig = _confirmed(client, db_session)
    start, _ = _slot_in(50)

    resp = _reschedule(client, gig, pro.client_id, [(start, start)])

    assert resp.status_code == 422, resp.text
    assert _slot(db_session, gig).status == ConfirmedSlotStatus.confirmed, "nothing changed on a refusal"


# --- cancel-slot ---------------------------------------------------------------------


def _cancel(client, gig, user_id, reason="Client asked"):
    return client.post(f"/v1/gigs/{gig.id}/cancel-slot", headers={"X-User-Id": user_id}, json={"reason": reason})


def test_either_person_on_the_booking_can_cancel_the_slot(client, db_session):
    pro, _booking_id, gig = _confirmed(client, db_session)

    resp = _cancel(client, gig, pro.client_id)

    assert resp.status_code == 200, resp.text
    slot = _slot(db_session, gig)
    assert slot.status == ConfirmedSlotStatus.cancelled and slot.cancellation_reason == "Client asked"


def test_someone_else_cannot_cancel_the_slot_but_an_admin_can(client, db_session):
    pro, _booking_id, gig = _confirmed(client, db_session)

    assert _cancel(client, gig, _second_client(db_session)).status_code == 403
    assert _slot(db_session, gig).status == ConfirmedSlotStatus.confirmed
    assert _cancel(client, gig, ADMIN).status_code == 200


def test_cancelling_a_slot_that_was_never_confirmed_is_not_found(client, db_session):
    pro = _short_notice_pro(db_session)
    booking_id = _ordinary_request(client, db_session, pro, accept=True)

    assert _cancel(client, _gig_for(db_session, booking_id), pro.client_id).status_code == 404


# --- the scheduling policy -------------------------------------------------------------


def _policy(client, user_id):
    return client.get("/v1/pro/scheduling/policy", headers={"X-User-Id": user_id})


def _put_policy(client, user_id, **fields):
    return client.put("/v1/pro/scheduling/policy", headers={"X-User-Id": user_id}, json=fields)


def test_the_policy_is_the_photographers_own(client, db_session):
    pro = _short_notice_pro(db_session)

    assert _policy(client, pro.id).status_code == 200
    assert _policy(client, pro.client_id).status_code == 403
    assert _put_policy(client, pro.client_id, advance_notice_hours=1).status_code == 403


def test_changing_the_notice_changes_what_clients_are_offered(client, db_session):
    pro = _short_notice_pro(db_session)  # 24 hours' notice
    start, _ = _slot_in(30)
    assert _offered(client, pro, start) is True

    resp = _put_policy(client, pro.id, advance_notice_hours=48, buffer_before_minutes=15, buffer_after_minutes=15)

    assert resp.status_code == 200, resp.text
    assert resp.json()["advance_notice_hours"] == 48
    assert _offered(client, pro, start) is False


def test_a_notice_out_of_range_is_refused_and_nothing_changes(client, db_session):
    pro = _short_notice_pro(db_session)

    assert _put_policy(client, pro.id, advance_notice_hours=721).status_code == 422
    assert _policy(client, pro.id).json()["advance_notice_hours"] == 24


def test_a_put_replaces_the_whole_policy(client, db_session):
    """Documented behaviour, logged in BACKEND_GAPS: a field left out of the
    body goes back to its default rather than keeping its value."""
    pro = _short_notice_pro(db_session, buffer=45)
    assert _policy(client, pro.id).json()["buffer_before_minutes"] == 45

    _put_policy(client, pro.id, advance_notice_hours=24)

    assert _policy(client, pro.id).json()["buffer_before_minutes"] == 15


def test_saving_the_policy_leaves_available_now_alone(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)

    assert _put_policy(client, pro.id, advance_notice_hours=36).status_code == 200

    db_session.expire_all()
    policy = db_session.get(ProSchedulingPolicy, pro.uuid)
    assert policy.available_until is not None
    assert _toggle(client, pro, on=False).status_code == 200
