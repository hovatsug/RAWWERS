"""RAWW expiry after long inactivity, and the warning before it."""
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select

from app.models.communication import Notification
from app.models.shelf import ProRawwBalance, RawwEntryKind, RawwEntryStatus
from app.services import raww_ledger as ledger
from app.services.raww_expiry import run_daily
from app.services.shelf_settings import shelf_settings
from app.tasks.outbox_tasks import dispatch_outbox_events_task

NOW = datetime(2026, 11, 3, 12, tzinfo=timezone.utc)


def _pro(db, spendable=500, last_activity=None, pending=0):
    pro = uuid.uuid4()
    ledger.post_entry(db, pro_user_id=pro, kind=RawwEntryKind.earn_booking, amount=spendable, status=RawwEntryStatus.spendable, source_type="gig", source_id=f"g-{pro}", gig_id=uuid.uuid4())
    if pending:
        ledger.post_entry(db, pro_user_id=pro, kind=RawwEntryKind.earn_booking, amount=pending, status=RawwEntryStatus.pending, source_type="gig", source_id=f"p-{pro}", gig_id=uuid.uuid4())
    balance = db.get(ProRawwBalance, pro)
    balance.last_activity_at = last_activity
    db.commit()
    return pro


def _balance(db, pro):
    db.expire_all()
    balance = db.get(ProRawwBalance, pro)
    assert (balance.spendable, balance.pending) == ledger.ledger_totals(db, pro)
    return balance


def _titles(db, pro):
    dispatch_outbox_events_task()
    db.expire_all()
    return db.execute(select(Notification.title).where(Notification.user_id == pro).order_by(Notification.created_at)).scalars().all()


def test_after_24_months_without_activity_the_spendable_balance_expires_and_they_are_told(db_session):
    pro = _pro(db_session, last_activity=NOW - timedelta(days=24 * 31), pending=40)

    assert run_daily(db_session, now=NOW)["expired"] == 1
    db_session.commit()

    balance = _balance(db_session, pro)
    assert (balance.spendable, balance.pending) == (0, 40), "pending RAWW do not expire"
    assert _titles(db_session, pro) == ["Your RAWW expired"]


def test_running_twice_expires_once(db_session):
    pro = _pro(db_session, last_activity=NOW - timedelta(days=800))
    run_daily(db_session, now=NOW)
    db_session.commit()

    assert run_daily(db_session, now=NOW)["expired"] == 0


def test_30_days_before_they_are_warned_once(db_session):
    pro = _pro(db_session, last_activity=ledger.months_after(NOW, -24) + timedelta(days=20))

    first = run_daily(db_session, now=NOW)
    db_session.commit()
    second = run_daily(db_session, now=NOW + timedelta(days=1))
    db_session.commit()

    assert (first["warned"], second["warned"]) == (1, 0)
    assert _balance(db_session, pro).spendable == 500
    assert _titles(db_session, pro) == ["Your RAWW expire soon"]


def test_before_the_warning_period_nothing_happens(db_session):
    pro = _pro(db_session, last_activity=ledger.months_after(NOW, -24) + timedelta(days=40))
    assert run_daily(db_session, now=NOW) == {"expired": 0, "warned": 0}
    assert _balance(db_session, pro).expiry_warned_at is None


def test_spending_after_the_warning_restarts_the_clock_and_clears_it(db_session):
    pro = _pro(db_session, last_activity=ledger.months_after(NOW, -24) + timedelta(days=20))
    run_daily(db_session, now=NOW)
    db_session.commit()

    ledger.spend(db_session, pro_user_id=pro, amount=10, source_type="shelf_order", source_id="o1")
    db_session.commit()

    balance = _balance(db_session, pro)
    assert balance.expiry_warned_at is None
    assert run_daily(db_session, now=NOW + timedelta(days=40)) == {"expired": 0, "warned": 0}


def test_nothing_expires_while_the_shelf_is_closed(db_session):
    pro = _pro(db_session, last_activity=NOW - timedelta(days=800))
    shelf_settings(db_session).shelf_enabled = False
    db_session.commit()

    assert run_daily(db_session, now=NOW)["expired"] == 0
    assert _balance(db_session, pro).spendable == 500


def test_the_period_follows_the_setting(db_session):
    pro = _pro(db_session, last_activity=NOW - timedelta(days=200))
    shelf_settings(db_session).inactivity_months = 6
    db_session.commit()

    assert run_daily(db_session, now=NOW)["expired"] == 1
