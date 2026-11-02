"""An admin decides a reported problem's hold: release it, or keep it, never silently.

Owner's decision (2026-11-02). A "Report a problem" holds the photographer's
earning for the booking (tests/test_review_gate.py). On its money-attention
item an admin either releases the hold - a required note, logged with who and
when - after which the earning follows its normal settlement date (and
settles at the next run if that date has passed), or keeps it on hold, also
with a note: the item then stays in the queue, so an open hold is never
closed away. Closing the item without saying which is refused. No refund
here: that belongs to the cancellation and refund rules.
"""
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models.admin import AdminAuditLog, MoneyAttentionItem
from app.models.payouts import EarningsEntryStatus, EarningsHold, EarningsHoldReason, EarningsLedgerEntry, EarningsSourceType
from app.models.review import ProblemReport
from app.services.payouts import create_earnings_hold, settle_due_earnings_entries
from tests.test_download_payment_gate import fake_stripe  # noqa: F401
from tests.test_review_gate import _delivered, _report

ADMIN = "00000000-0000-0000-0000-0000000000aa"


def _reported(client, db_session, *, due_in_days=7):
    """A delivered booking whose client reported a problem; its earning
    (recorded at completion) is held. `due_in_days` sets when it would
    otherwise settle."""
    client_id, gig, gallery, _assets = _delivered(client, db_session)
    entry = db_session.execute(
        select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_type == EarningsSourceType.gig_base, EarningsLedgerEntry.source_id == gig.id)
    ).scalar_one_or_none()
    if entry is None:
        entry = EarningsLedgerEntry(
            pro_user_id=gig.pro_user_id, source_type=EarningsSourceType.gig_base, source_id=gig.id,
            gross_eur=Decimal("40.00"), platform_fee_eur=Decimal("8.00"), net_eur=Decimal("32.00"),
            status=EarningsEntryStatus.pending, available_at=datetime.now(timezone.utc), meta={},
        )
        db_session.add(entry)
    entry.available_at = datetime.now(timezone.utc) + timedelta(days=due_in_days)
    entry.status = EarningsEntryStatus.pending
    db_session.commit()
    assert _report(client, gig, client_id).status_code == 200
    db_session.expire_all()
    item = db_session.execute(
        select(MoneyAttentionItem).where(MoneyAttentionItem.gig_id == gig.id, MoneyAttentionItem.kind == "client_reported_problem")
    ).scalar_one()
    report = db_session.execute(select(ProblemReport).where(ProblemReport.gig_id == gig.id)).scalar_one()
    return gig, item, db_session.get(EarningsHold, report.earnings_hold_id), entry.id


def _resolve(client, item, **body):
    return client.post(f"/v1/admin/money-attention/{item.id}/resolve", headers={"X-User-Id": ADMIN}, json=body)


def _fresh(db_session, model, row_id):
    db_session.expire_all()
    return db_session.get(model, row_id)


# --- release -------------------------------------------------------------------------------


def test_release_needs_a_note_and_is_logged_with_the_admin_and_the_time(client, db_session, fake_stripe):
    gig, item, hold, _entry_id = _reported(client, db_session)

    assert _resolve(client, item, hold_outcome="release", note="  ").status_code == 422
    assert _fresh(db_session, EarningsHold, hold.id).released_at is None

    before = datetime.now(timezone.utc)
    resp = _resolve(client, item, hold_outcome="release", note="Photos were all there; client confirmed by message")

    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "resolved"
    released = _fresh(db_session, EarningsHold, hold.id)
    assert released.released_at is not None and released.released_at >= before
    log = db_session.execute(
        select(AdminAuditLog).where(AdminAuditLog.target_id == str(item.id), AdminAuditLog.action == "earnings_hold_released")
    ).scalar_one()
    assert str(log.actor_user_id) == ADMIN and log.created_at >= before
    assert log.reason == "Photos were all there; client confirmed by message"
    assert log.meta["hold_id"] == str(hold.id) and log.meta["gig_id"] == str(gig.id)


def test_after_release_the_earning_waits_for_its_own_date(client, db_session, fake_stripe):
    _gig, item, _hold, entry_id = _reported(client, db_session, due_in_days=7)
    assert _fresh(db_session, EarningsLedgerEntry, entry_id).status == EarningsEntryStatus.held

    _resolve(client, item, hold_outcome="release", note="No problem found")

    entry = _fresh(db_session, EarningsLedgerEntry, entry_id)
    assert entry.status == EarningsEntryStatus.pending, "back to waiting for its date, not paid early and not still held"

    entry.available_at = datetime.now(timezone.utc) - timedelta(minutes=1)
    db_session.commit()
    settle_due_earnings_entries(db_session)
    db_session.commit()
    assert _fresh(db_session, EarningsLedgerEntry, entry_id).status == EarningsEntryStatus.available


def test_after_release_an_earning_already_due_is_available(client, db_session, fake_stripe):
    _gig, item, _hold, entry_id = _reported(client, db_session, due_in_days=-1)

    _resolve(client, item, hold_outcome="release", note="No problem found")
    settle_due_earnings_entries(db_session)
    db_session.commit()

    assert _fresh(db_session, EarningsLedgerEntry, entry_id).status == EarningsEntryStatus.available


def test_another_open_hold_on_the_booking_still_holds_it(client, db_session, fake_stripe):
    gig, item, _hold, entry_id = _reported(client, db_session)
    create_earnings_hold(
        db_session, pro_user_id=gig.pro_user_id, reason=EarningsHoldReason.dispute_open, amount_eur=None,
        source_type=EarningsSourceType.gig_base.value, source_id=gig.id, created_by_admin_id=None,
    )
    db_session.commit()

    _resolve(client, item, hold_outcome="release", note="This report is fine; the dispute is separate")

    assert _fresh(db_session, EarningsLedgerEntry, entry_id).status == EarningsEntryStatus.held


def test_release_makes_no_refund(client, db_session, fake_stripe, monkeypatch):
    from app.models.admin import RefundCase

    gig, item, _hold, _entry_id = _reported(client, db_session)
    cases_before = db_session.execute(select(RefundCase.id).where(RefundCase.gig_id == gig.id)).all()
    refunds = []
    monkeypatch.setattr("stripe.Refund.create", lambda **kw: refunds.append(kw))

    _resolve(client, item, hold_outcome="release", note="No problem found")

    assert refunds == []
    db_session.expire_all()
    assert db_session.execute(select(RefundCase.id).where(RefundCase.gig_id == gig.id)).all() == cases_before


# --- keep, and never silently --------------------------------------------------------------


def test_keep_on_hold_needs_a_note_and_leaves_the_item_in_the_queue(client, db_session, fake_stripe):
    _gig, item, hold, entry_id = _reported(client, db_session)

    assert _resolve(client, item, hold_outcome="keep", note="").status_code == 422
    resp = _resolve(client, item, hold_outcome="keep", note="Waiting for the photographer's reply")

    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "open", "a hold still open stays visible in the queue"
    assert "Kept on hold" in resp.json()["note"] and "Waiting for the photographer's reply" in resp.json()["note"]
    assert _fresh(db_session, EarningsHold, hold.id).released_at is None
    assert _fresh(db_session, EarningsLedgerEntry, entry_id).status == EarningsEntryStatus.held
    assert db_session.execute(
        select(AdminAuditLog).where(AdminAuditLog.target_id == str(item.id), AdminAuditLog.action == "earnings_hold_kept")
    ).scalar_one().reason == "Waiting for the photographer's reply"

    # Released later, from the same item.
    assert _resolve(client, item, hold_outcome="release", note="Photographer resent the missing photos").json()["status"] == "resolved"
    assert _fresh(db_session, EarningsHold, hold.id).released_at is not None


def test_closing_without_saying_what_happens_to_the_hold_is_refused(client, db_session, fake_stripe):
    _gig, item, hold, _entry_id = _reported(client, db_session)

    resp = _resolve(client, item, note="Looked at it")

    assert resp.status_code == 422
    assert "hold" in resp.json()["error"]["message"].lower()
    assert _fresh(db_session, MoneyAttentionItem, item.id).status == "open"
    assert _fresh(db_session, EarningsHold, hold.id).released_at is None


@pytest.mark.parametrize("outcome", ["refund", "maybe", ""])
def test_only_release_or_keep(client, db_session, fake_stripe, outcome):
    _gig, item, _hold, _entry_id = _reported(client, db_session)
    assert _resolve(client, item, hold_outcome=outcome, note="x").status_code == 422


def test_an_item_with_no_hold_takes_no_outcome(client, db_session):
    from tests.test_client_owed import _gig

    gig = _gig(db_session)
    item = MoneyAttentionItem(kind="client_owed", gig_id=gig.id, amount=Decimal("10.00"), currency="EUR")
    db_session.add(item)
    db_session.commit()

    assert _resolve(client, item, hold_outcome="release", note="x").status_code == 422
    assert _resolve(client, item, note="Paid back by transfer").status_code == 200


def test_the_queue_says_whether_a_hold_is_open(client, db_session, fake_stripe):
    _gig, item, _hold, _entry_id = _reported(client, db_session)
    (row,) = [i for i in client.get("/v1/admin/money-attention", headers={"X-User-Id": ADMIN}).json()["items"] if i["id"] == str(item.id)]
    assert row["hold_open"] is True


def test_only_an_admin_decides(client, db_session, fake_stripe):
    gig, item, _hold, _entry_id = _reported(client, db_session)
    resp = client.post(
        f"/v1/admin/money-attention/{item.id}/resolve",
        headers={"X-User-Id": str(gig.pro_user_id)},
        json={"hold_outcome": "release", "note": "mine"},
    )
    assert resp.status_code == 403
