"""Photographer accountability for non-delivery: fair, visible, never by guesswork.

A finding exists only when an admin records fault on a booking whose price
reduction carries the reason photographer_non_delivery. The photographer is
told and has a window to respond, which starts when they first see the
finding in the app (or after a grace period if they never open it). Nothing
takes effect before the window ends. A confirmed finding is a strike; the
ladder - warning, booking pause, suspension review - and every number in it
are an admin-editable policy row. A withdrawn finding leaves no strike.

None of it feeds ranking: strikes, warnings and pauses are not inputs, and
a pause takes a photographer out of discovery the way a ban does, not by
reordering anyone.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.core.errors import APIError
from app.models.accountability import AccountabilityPolicy, BookingPause, PhotographerFinding
from app.models.admin import AdminAuditLog, MoneyAttentionItem, ProFaultEvent
from app.models.discovery import ProPublicIndex
from app.models.gig import GigStatus
from app.services import accountability as acc
from app.services.booking_answer import ensure_request_can_be_booked
from app.services.discovery_index import recompute_pro_public_index
from app.services.price_reduction import ReductionLine, apply_price_reduction
from tests.test_price_reduction import _booking, _price, refunds  # noqa: F401 - fixture
from tests.test_pro_shut_out import _listed_pro, _pending_request

ADMIN = uuid.UUID("00000000-0000-0000-0000-0000000000aa")
D = Decimal
NOW = datetime.now(timezone.utc)


def _reduced(db, *, reason="photographer_non_delivery", pro=None):
    """A completed booking whose price came down for `reason`."""
    gig, _, _ = _booking(db)
    if pro is not None:
        gig.pro_user_id = pro
    gig.status = GigStatus.completed
    db.commit()
    p20 = _price(db, gig, 20)
    apply_price_reduction(db, gig, new_final=p20 - 10, lines=[ReductionLine(reason, D("10.00"))], note="Short",
                          source="admin", key=f"k:{gig.id}", actor_user_id=ADMIN)
    db.commit()
    return gig


def _finding(db, gig, *, severe=False) -> PhotographerFinding:
    finding = acc.record_finding(db, gig=gig, admin_user_id=ADMIN, note="6 photos never delivered", severe=severe,
                                 severe_note="Wedding, nothing delivered" if severe else None)
    db.commit()
    return finding


def _past_window(db, finding):
    """The contest window over: seen long ago."""
    finding.first_seen_at = datetime.now(timezone.utc) - timedelta(days=30)
    finding.created_at = datetime.now(timezone.utc) - timedelta(days=31)
    db.commit()


def _confirm(db, finding):
    acc.decide(db, finding=finding, admin_user_id=ADMIN, decision="confirm", note="Confirmed after review")
    db.commit()
    db.refresh(finding)
    return finding


# --- when a finding may exist -------------------------------------------------------------


def test_a_finding_needs_a_non_delivery_reduction(db_session, refunds):
    gig = _reduced(db_session, reason="client_selected_fewer")
    with pytest.raises(APIError) as refused:
        _finding(db_session, gig)
    assert refused.value.code == "finding_needs_non_delivery"


def test_a_booking_with_no_reduction_cannot_carry_a_finding(db_session):
    gig, _, _ = _booking(db_session)
    with pytest.raises(APIError):
        _finding(db_session, gig)


def test_a_reason_that_may_not_carry_fault_cannot_be_used(db_session, refunds):
    from app.models.price_reduction import PriceReductionReason

    gig = _reduced(db_session)
    db_session.get(PriceReductionReason, "photographer_non_delivery").may_carry_fault = False
    db_session.commit()
    with pytest.raises(APIError):
        _finding(db_session, gig)


def test_the_short_delivery_flag_is_never_a_finding(client, db_session, refunds):
    from tests.test_price_reduction import _submit

    gig, gallery, _ = _booking(db_session)
    _submit(client, gallery, gig)

    assert db_session.execute(select(PhotographerFinding)).first() is None
    assert db_session.execute(select(ProFaultEvent)).first() is None


def test_recording_a_finding_tells_the_photographer_and_is_audited(db_session, refunds):
    from app.models.outbox import OutboxEvent

    gig = _reduced(db_session)
    finding = _finding(db_session, gig)

    assert finding.status == "pending"
    payloads = [e.payload for e in db_session.execute(select(OutboxEvent)).scalars()]
    assert any(p.get("type") == "finding.recorded" and p.get("user_id") == str(gig.pro_user_id) for p in payloads)
    assert db_session.execute(select(AdminAuditLog).where(AdminAuditLog.action == "finding_recorded")).first()


# --- the window ---------------------------------------------------------------------------


def test_the_window_starts_when_the_photographer_first_sees_it(db_session, refunds):
    gig = _reduced(db_session)
    finding = _finding(db_session, gig)
    policy = acc.policy(db_session)
    assert acc.window_ends_at(finding, policy) == finding.created_at + timedelta(days=policy.unseen_grace_days + policy.contest_window_days)

    acc.mark_seen(db_session, finding=finding, pro_user_id=gig.pro_user_id)
    db_session.commit()
    seen = finding.first_seen_at
    acc.mark_seen(db_session, finding=finding, pro_user_id=gig.pro_user_id)  # seeing it again moves nothing

    assert finding.first_seen_at == seen
    assert acc.window_ends_at(finding, policy) == seen + timedelta(days=policy.contest_window_days)


def test_the_window_lengths_are_policy(db_session, refunds):
    db_session.add(AccountabilityPolicy(id=1, contest_window_days=3, unseen_grace_days=5))
    db_session.commit()
    gig = _reduced(db_session)
    finding = _finding(db_session, gig)

    assert acc.window_ends_at(finding, acc.policy(db_session)) == finding.created_at + timedelta(days=8)


def test_only_the_photographer_marks_it_seen(db_session, refunds):
    gig = _reduced(db_session)
    finding = _finding(db_session, gig)
    with pytest.raises(APIError):
        acc.mark_seen(db_session, finding=finding, pro_user_id=uuid.uuid4())


def test_the_photographer_responds_and_the_response_is_kept(db_session, refunds):
    gig = _reduced(db_session)
    finding = _finding(db_session, gig)

    acc.respond(db_session, finding=finding, pro_user_id=gig.pro_user_id, text="The client cancelled half the shoot on the day.")
    db_session.commit()

    assert finding.response.startswith("The client cancelled") and finding.responded_at is not None


def test_nothing_takes_effect_before_the_window_ends(db_session, refunds):
    gig = _reduced(db_session)
    finding = _finding(db_session, gig)
    acc.mark_seen(db_session, finding=finding, pro_user_id=gig.pro_user_id)
    acc.respond(db_session, finding=finding, pro_user_id=gig.pro_user_id, text="I disagree")
    db_session.commit()

    _confirm(db_session, finding)  # confirmed on their reply, inside the window

    assert finding.status == "confirmed" and finding.consequence is None
    assert acc.strikes(db_session, gig.pro_user_id) == 0
    assert db_session.execute(select(ProFaultEvent)).first() is None

    acc.apply_due_findings(db_session, now=acc.window_ends_at(finding, acc.policy(db_session)) + timedelta(minutes=1))
    db_session.commit()
    db_session.refresh(finding)
    assert finding.consequence == "warning" and acc.strikes(db_session, gig.pro_user_id) == 1


def test_the_due_sweep_runs_on_beat():
    from app.tasks.celery_app import celery_app

    assert "app.tasks.scheduled.apply_due_findings" in {e["task"] for e in celery_app.conf.beat_schedule.values()}


def test_a_withdrawn_finding_leaves_no_strike(db_session, refunds):
    gig = _reduced(db_session)
    finding = _finding(db_session, gig)
    _past_window(db_session, finding)

    acc.decide(db_session, finding=finding, admin_user_id=ADMIN, decision="withdraw", note="Client's own cancellation")
    db_session.commit()

    assert finding.status == "withdrawn"
    assert acc.strikes(db_session, gig.pro_user_id) == 0
    assert db_session.execute(select(ProFaultEvent)).first() is None


def test_a_decision_needs_a_note(db_session, refunds):
    gig = _reduced(db_session)
    finding = _finding(db_session, gig)
    with pytest.raises(APIError):
        acc.decide(db_session, finding=finding, admin_user_id=ADMIN, decision="confirm", note=" ")


# --- the ladder ---------------------------------------------------------------------------


def _strike(db, pro, *, severe=False):
    gig = _reduced(db, pro=pro)
    finding = _finding(db, gig, severe=severe)
    _past_window(db, finding)
    return _confirm(db, finding)


def test_first_confirmed_finding_is_a_warning(db_session, refunds):
    pro = _listed_pro(db_session)
    finding = _strike(db_session, pro)

    assert (finding.consequence, finding.strike_number) == ("warning", 1)
    assert acc.active_pause(db_session, pro) is None


def test_second_pauses_new_bookings_and_lists_existing_ones(db_session, refunds):
    from app.models.gig import Gig

    pro = _listed_pro(db_session)
    _strike(db_session, pro)
    paid = Gig(client_user_id=uuid.uuid4(), pro_user_id=pro, status=GigStatus.paid, currency="EUR", amount_minimum=D("100.00"),
               amount_platform_fee=D("20.00"), amount_pro_gross=D("80.00"), meta={})
    db_session.add(paid)
    db_session.commit()

    second = _strike(db_session, pro)

    assert second.consequence == "booking_pause"
    pause = acc.active_pause(db_session, pro)
    assert pause is not None and pause.created_by_user_id == ADMIN and pause.reason
    db_session.expire_all()
    assert db_session.get(ProPublicIndex, pro).is_accepting_bookings is False
    assert db_session.get(Gig, paid.id).status == GigStatus.paid  # untouched
    listed = db_session.execute(select(MoneyAttentionItem).where(MoneyAttentionItem.gig_id == paid.id)).scalars().all()
    assert [i.kind for i in listed] == ["pro_shut_out_booking"]


def test_a_paused_photographer_cannot_accept_and_cannot_switch_it_back(client, db_session, refunds):
    pro = _listed_pro(db_session)
    request = _pending_request(db_session, pro)
    _strike(db_session, pro)
    _strike(db_session, pro)

    with pytest.raises(APIError) as refused:
        ensure_request_can_be_booked(db_session, request)
    assert refused.value.code == "bookings_paused"

    # Their own "accepting bookings" switch does not lift it.
    from app.models.admin import ProProfile

    db_session.get(ProProfile, pro).is_accepting_bookings = True
    recompute_pro_public_index(db_session, pro)
    db_session.commit()
    assert db_session.get(ProPublicIndex, pro).is_accepting_bookings is False


def test_only_an_admin_lifts_a_pause_and_it_restores_them(db_session, refunds):
    pro = _listed_pro(db_session)
    _strike(db_session, pro)
    _strike(db_session, pro)

    acc.lift_pause(db_session, pro_user_id=pro, admin_user_id=ADMIN, note="Reviewed; delivered the rest")
    db_session.commit()

    assert acc.active_pause(db_session, pro) is None
    db_session.expire_all()
    assert db_session.get(ProPublicIndex, pro).is_accepting_bookings is True


def test_third_raises_a_suspension_review_for_an_admin(db_session, refunds):
    pro = _listed_pro(db_session)
    for _ in range(3):
        last = _strike(db_session, pro)

    assert last.consequence == "suspension_review"
    assert db_session.execute(select(MoneyAttentionItem).where(MoneyAttentionItem.kind == "pro_suspension_review")).first()


def test_a_severe_finding_skips_to_suspension_review(db_session, refunds):
    pro = _listed_pro(db_session)
    finding = _strike(db_session, pro, severe=True)
    assert finding.consequence == "suspension_review"


def test_marking_severe_needs_a_note(db_session, refunds):
    gig = _reduced(db_session)
    with pytest.raises(APIError):
        acc.record_finding(db_session, gig=gig, admin_user_id=ADMIN, note="x", severe=True, severe_note=" ")


def test_the_ladder_thresholds_are_policy(db_session, refunds):
    db_session.add(AccountabilityPolicy(id=1, pause_at=3, suspension_review_at=5))
    db_session.commit()
    pro = _listed_pro(db_session)
    _strike(db_session, pro)
    second = _strike(db_session, pro)
    assert second.consequence == "warning"


def test_strikes_count_only_inside_the_rolling_window(db_session, refunds):
    pro = _listed_pro(db_session)
    old = _strike(db_session, pro)
    old.effective_at = datetime.now(timezone.utc) - timedelta(days=400)
    db_session.commit()

    assert acc.strikes(db_session, pro) == 0
    assert _strike(db_session, pro).consequence == "warning"


def test_nothing_is_retroactive(db_session, refunds):
    """A fault recorded before this policy existed is not a strike."""
    pro = _listed_pro(db_session)
    db_session.add(ProFaultEvent(pro_user_id=pro, kind="dispute_at_fault", note="old", recorded_by_user_id=ADMIN))
    db_session.commit()

    assert acc.strikes(db_session, pro) == 0
    assert _strike(db_session, pro).consequence == "warning"


# --- ranking ------------------------------------------------------------------------------


def test_strikes_warnings_and_pauses_never_feed_ranking(db_session, refunds):
    pro = _listed_pro(db_session)
    # The bookings first: completed bookings do count towards ranking, and
    # what is under test is only the findings, the strikes and the pause.
    gigs = [_reduced(db_session, pro=pro), _reduced(db_session, pro=pro)]
    before = recompute_pro_public_index(db_session, pro)
    score, disputes = before.ranking_score, before.disputes_count
    for gig in gigs:  # warning, then pause
        finding = _finding(db_session, gig)
        _past_window(db_session, finding)
        _confirm(db_session, finding)
    assert acc.active_pause(db_session, pro) is not None

    after = recompute_pro_public_index(db_session, pro)
    assert (after.ranking_score, after.disputes_count) == (score, disputes)


def test_a_confirmed_finding_is_recorded_as_a_fault_outside_disputes_count(db_session, refunds):
    pro = _listed_pro(db_session)
    finding = _strike(db_session, pro)

    [event] = db_session.execute(select(ProFaultEvent).where(ProFaultEvent.pro_user_id == pro)).scalars().all()
    assert (event.kind, event.gig_id, event.dispute_id) == ("non_delivery_at_fault", finding.gig_id, None)


# --- the photographer's view and the admin's ----------------------------------------------


def _pro_headers(db, pro):
    from app.models.admin import UserRole, UserRoleType

    if not db.execute(select(UserRole).where(UserRole.user_id == pro, UserRole.role == UserRoleType.pro)).first():
        db.add(UserRole(user_id=pro, role=UserRoleType.pro))
        db.commit()
    return {"X-User-Id": str(pro)}


def test_the_photographer_sees_their_own_findings_and_strike_count(client, db_session, refunds):
    pro = _listed_pro(db_session)
    _strike(db_session, pro)
    pending = _finding(db_session, _reduced(db_session, pro=pro))

    body = client.get("/v1/pro/findings", headers=_pro_headers(db_session, pro)).json()

    assert body["strikes"] == 1 and body["pause"] is None
    statuses = {f["id"]: f["status"] for f in body["items"]}
    assert statuses[str(pending.id)] == "pending"
    assert all("window_ends_at" in f and "reason" in f for f in body["items"])


def test_opening_the_finding_starts_the_window(client, db_session, refunds):
    pro = _listed_pro(db_session)
    finding = _finding(db_session, _reduced(db_session, pro=pro))

    resp = client.post(f"/v1/pro/findings/{finding.id}/seen", headers=_pro_headers(db_session, pro))

    assert resp.status_code == 200
    db_session.refresh(finding)
    assert finding.first_seen_at is not None


def test_another_photographer_cannot_see_or_answer_it(client, db_session, refunds):
    pro, other = _listed_pro(db_session), _listed_pro(db_session)
    finding = _finding(db_session, _reduced(db_session, pro=pro))

    assert str(finding.id) not in {f["id"] for f in client.get("/v1/pro/findings", headers=_pro_headers(db_session, other)).json()["items"]}
    resp = client.post(f"/v1/pro/findings/{finding.id}/response", headers=_pro_headers(db_session, other), json={"text": "x"})
    assert resp.status_code == 404


def test_clients_never_see_findings(client, db_session, refunds):
    pro = _listed_pro(db_session)
    _strike(db_session, pro)
    profile = client.get(f"/v1/pros/{pro}").text
    assert "finding" not in profile.lower() and "strike" not in profile.lower()


def test_admin_rates_of_findings_per_admin_and_per_photographer(client, db_session, refunds):
    pro = _listed_pro(db_session)
    _strike(db_session, pro)

    stats = client.get("/v1/admin/findings/stats", headers={"X-User-Id": str(ADMIN)}).json()

    assert stats["by_admin"][0]["admin_user_id"] == str(ADMIN) and stats["by_admin"][0]["findings"] == 1
    assert stats["by_photographer"][0]["pro_user_id"] == str(pro)


def test_the_policy_row_is_editable_and_audited(client, db_session):
    resp = client.put("/v1/admin/policies/accountability", headers={"X-User-Id": str(ADMIN)}, json={"contest_window_days": 10})

    assert resp.status_code == 200 and resp.json()["contest_window_days"] == 10
    assert db_session.execute(select(AdminAuditLog).where(AdminAuditLog.action == "accountability_policy_updated")).first()


def test_a_finding_needs_a_note(db_session, refunds):
    gig = _reduced(db_session)
    with pytest.raises(APIError):
        acc.record_finding(db_session, gig=gig, admin_user_id=ADMIN, note="  ")
    assert db_session.execute(select(PhotographerFinding)).first() is None
