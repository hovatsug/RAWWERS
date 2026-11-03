"""What a photographer sees of their RAWW: the Wallet card, history, and the
RAWW beside the euro credit on invoices once The Shelf is open."""
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import UserRole, UserRoleType
from app.models.payouts import EarningsHoldReason
from app.models.shelf import ProRawwBalance
from app.services.payouts import create_earnings_hold
from app.services.raww_ledger import months_after

from tests.test_photographer_money import _complete, _gig, _pay, _pro, _settle


def _pro_user(db):
    pro = _pro(db)
    db.add(UserRole(user_id=pro, role=UserRoleType.pro))
    db.commit()
    return pro


def _booking(db, pro, gross="150.00"):
    gig = _gig(db, pro, minimum=gross)
    _pay(db, gig, gross)
    _complete(db, gig)
    return gig


def _get(client, pro, path="/v1/pro/raww"):
    resp = client.get(path, headers={"X-User-Id": str(pro)})
    assert resp.status_code == 200, resp.text
    return resp.json()


def test_the_card_shows_pending_rawws_with_the_date_they_settle(client, db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)

    body = _get(client, pro)

    assert (body["spendable"], body["pending"]) == (0, 75)
    [item] = body["pending_bookings"]
    assert item["gig_id"] == str(gig.id) and item["amount"] == 75 and item["held"] is False
    assert item["expected_at"] is not None
    assert body["expires_at"] is None, "nothing spendable, nothing to expire"


def test_a_held_booking_has_no_date(client, db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    create_earnings_hold(db_session, pro_user_id=pro, reason=EarningsHoldReason.dispute_open, amount_eur=None, source_type="gig_base", source_id=gig.id, created_by_admin_id=None)
    db_session.commit()

    [item] = _get(client, pro)["pending_bookings"]

    assert item["held"] is True and item["expected_at"] is None


def test_spendable_rawws_show_when_they_expire(client, db_session):
    pro = _pro_user(db_session)
    _booking(db_session, pro)
    _settle(db_session, pro)

    body = _get(client, pro)

    assert (body["spendable"], body["pending"]) == (75, 0)
    assert body["pending_bookings"] == [], "a settled booking is not on the way"
    last = db_session.get(ProRawwBalance, pro).last_activity_at
    assert datetime.fromisoformat(body["expires_at"]) == months_after(last, 24)
    assert body["expiry_warning"] is False


def test_the_warning_shows_in_the_last_30_days(client, db_session):
    pro = _pro_user(db_session)
    _booking(db_session, pro)
    _settle(db_session, pro)
    balance = db_session.get(ProRawwBalance, pro)
    balance.last_activity_at = months_after(datetime.now(timezone.utc), -24) + timedelta(days=20)
    db_session.commit()

    assert _get(client, pro)["expiry_warning"] is True


def test_the_history_lists_entries_newest_first(client, db_session):
    pro = _pro_user(db_session)
    _booking(db_session, pro)
    _booking(db_session, pro, gross="100.00")

    body = _get(client, pro, "/v1/pro/raww/history")

    assert body["total"] == 2
    assert [i["amount"] for i in body["items"]] == [50, 75]


def test_invoices_show_the_rawws_beside_the_euros_once_the_shelf_is_open(client, db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)

    invoice = _get(client, pro, f"/v1/pro/earnings/invoices/{gig.id}")
    summary = _get(client, pro, "/v1/pro/earnings/summary")

    assert (Decimal(invoice["pro_raww"]), invoice["pro_raww_rawws"]) == (Decimal("7.50"), 75)
    assert summary["pro_raww_rawws"] == 75


def test_while_the_shelf_is_closed_invoices_show_euros_only(client, db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    from app.services.shelf_settings import shelf_settings

    shelf_settings(db_session).shelf_enabled = False
    db_session.commit()

    invoice = _get(client, pro, f"/v1/pro/earnings/invoices/{gig.id}")
    assert invoice["pro_raww_rawws"] is None
