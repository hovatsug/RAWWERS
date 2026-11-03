"""Extras earn the credit (owner's decision, 2026-11-03): on an extra-image
purchase the platform keeps 15% and credits 5% to the photographer, as on
a booking, at the booking's own rates. The credit is stamped on the extras
earnings entry; its RAWW follow that entry (pending, spendable once it
settles with no hold) and a refund takes them back at the original rate.
The invoice's euro credit covers booking plus extras. No backfill."""
import uuid
from datetime import datetime, timezone
from decimal import Decimal as D

from sqlalchemy import select

from app.models.client_rewards_pricing import ExtraImagePurchase, ExtraImagePurchaseStatus
from app.models.payouts import EarningsHoldReason, EarningsLedgerEntry, EarningsSourceType
from app.models.shelf import ProRawwBalance, ProRawwLedgerEntry, RawwEntryKind, RawwEntryStatus
from app.services import raww_ledger as ledger
from app.services.payouts import (
    create_earnings_entry,
    create_earnings_hold,
    release_earnings_holds_for_source,
    reverse_earnings_entries_for_source,
)
from app.services.shelf_settings import shelf_settings

from tests.test_photographer_money import _settle
from tests.test_raww_wallet import _booking, _get, _pro_user


def _extras(db, gig, total="10.00") -> tuple[ExtraImagePurchase, EarningsLedgerEntry]:
    """An extra-image purchase paid, as the payment webhook records it."""
    purchase = ExtraImagePurchase(
        gig_id=gig.id, client_user_id=gig.client_user_id, pro_user_id=gig.pro_user_id,
        included_images=10, selected_images=12, extra_images=2,
        unit_price_applied=D(total) / 2, unit_price_configured=D(total) / 2, policy_unit_price_min=D("1.00"),
        subtotal=D(total), total=D(total), stripe_payment_intent_id=f"pi_{uuid.uuid4().hex}",
        status=ExtraImagePurchaseStatus.paid, meta={},
    )
    db.add(purchase)
    db.flush()
    entry = create_earnings_entry(
        db, pro_user_id=gig.pro_user_id, source_type=EarningsSourceType.extra_images, source_id=purchase.id,
        gross_eur=D(total), metadata={"gig_id": str(gig.id)},
    )
    db.commit()
    return purchase, entry


def _extras_raww(db, pro):
    db.expire_all()
    return db.execute(
        select(ProRawwLedgerEntry.kind, ProRawwLedgerEntry.amount, ProRawwLedgerEntry.status)
        .where(ProRawwLedgerEntry.pro_user_id == pro, ProRawwLedgerEntry.source_type == "extra_images")
        .order_by(ProRawwLedgerEntry.created_at)
    ).all()


def _balance(db, pro):
    db.expire_all()
    balance = db.get(ProRawwBalance, pro)
    assert (balance.spendable, balance.pending) == ledger.ledger_totals(db, pro)
    return balance.spendable, balance.pending


def test_ten_euros_of_extras_keep_15_percent_and_credit_5(db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)

    _, entry = _extras(db_session, gig)

    assert (entry.gross_eur, entry.platform_fee_eur, entry.net_eur) == (D("10.00"), D("2.00"), D("8.00"))
    assert (entry.pro_raww_eur, entry.pro_raww_percent) == (D("0.50"), 5)
    assert _extras_raww(db_session, pro) == [(RawwEntryKind.earn_extras, 5, RawwEntryStatus.pending)]
    [row] = db_session.execute(select(ProRawwLedgerEntry).where(ProRawwLedgerEntry.kind == RawwEntryKind.earn_extras)).scalars()
    assert row.gig_id == gig.id and row.eur_basis == D("0.50") and row.raww_eur_value == D("0.1000")


def test_the_share_is_the_bookings_own_stamped_rate(db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    gig.retained_percent, gig.pro_raww_percent = 16, 4
    db_session.commit()

    _, entry = _extras(db_session, gig)

    assert (entry.platform_fee_eur, entry.net_eur, entry.pro_raww_eur) == (D("2.00"), D("8.00"), D("0.40"))
    assert _extras_raww(db_session, pro) == [(RawwEntryKind.earn_extras, 4, RawwEntryStatus.pending)]


def test_they_become_spendable_when_the_extras_settle_and_go_back_under_a_hold(db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    purchase, _ = _extras(db_session, gig)

    _settle(db_session, pro)
    assert _balance(db_session, pro) == (80, 0)

    hold = create_earnings_hold(
        db_session, pro_user_id=pro, reason=EarningsHoldReason.dispute_open, amount_eur=None,
        source_type=EarningsSourceType.extra_images.value, source_id=purchase.id, created_by_admin_id=None,
    )
    db_session.commit()
    assert _balance(db_session, pro) == (75, 5), "only the extras are held"

    release_earnings_holds_for_source(db_session, pro_user_id=pro, source_type=EarningsSourceType.extra_images.value, source_id=purchase.id)
    db_session.commit()
    assert _balance(db_session, pro) == (80, 0)
    assert hold is not None


def test_a_hold_on_the_booking_alone_leaves_the_extras_spendable(db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    _extras(db_session, gig)
    _settle(db_session, pro)

    create_earnings_hold(
        db_session, pro_user_id=pro, reason=EarningsHoldReason.dispute_open, amount_eur=None,
        source_type=EarningsSourceType.gig_base.value, source_id=gig.id, created_by_admin_id=None,
    )
    db_session.commit()

    assert _balance(db_session, pro) == (5, 75)


def test_a_refund_takes_them_back_at_the_original_rate(db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    purchase, _ = _extras(db_session, gig)
    shelf_settings(db_session).raww_eur_value = D("0.05")
    db_session.commit()

    reverse_earnings_entries_for_source(db_session, source_type=EarningsSourceType.extra_images, source_id=purchase.id, reason="stripe_refund")
    db_session.commit()

    assert _extras_raww(db_session, pro) == [
        (RawwEntryKind.earn_extras, 5, RawwEntryStatus.pending),
        (RawwEntryKind.reverse_extras, -5, RawwEntryStatus.pending),
    ], "5 back, not the 10 the new rate would make of €0.50"
    assert _balance(db_session, pro) == (0, 75)


def test_recording_it_again_changes_nothing(db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    purchase, _ = _extras(db_session, gig)

    again = create_earnings_entry(
        db_session, pro_user_id=pro, source_type=EarningsSourceType.extra_images, source_id=purchase.id,
        gross_eur=D("10.00"), metadata={"gig_id": str(gig.id)},
    )
    db_session.commit()

    assert again is not None
    assert len(_extras_raww(db_session, pro)) == 1


def test_extras_from_before_this_release_earn_nothing(db_session):
    """No backfill: an extras entry without a stamped credit has no RAWW."""
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    _, entry = _extras(db_session, gig)
    db_session.execute(ProRawwLedgerEntry.__table__.delete().where(ProRawwLedgerEntry.source_type == "extra_images"))
    entry.pro_raww_eur, entry.pro_raww_percent = None, None
    db_session.get(ProRawwBalance, pro).pending = 75
    db_session.commit()

    _settle(db_session, pro)

    assert _extras_raww(db_session, pro) == []
    assert _balance(db_session, pro) == (75, 0)


def test_the_invoice_credit_covers_booking_plus_extras(client, db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    purchase, _ = _extras(db_session, gig)

    invoice = _get(client, pro, f"/v1/pro/earnings/invoices/{gig.id}")
    summary = _get(client, pro, "/v1/pro/earnings/summary")

    assert (D(invoice["pro_raww"]), D(invoice["extras_pro_raww"]), invoice["pro_raww_rawws"]) == (D("7.50"), D("0.50"), 80)
    assert D(invoice["client_total"]) == D("150.00"), "the booking's own sum is unchanged"
    assert (D(summary["pro_raww"]), D(summary["extras_pro_raww"]), summary["pro_raww_rawws"]) == (D("7.50"), D("0.50"), 80)

    reverse_earnings_entries_for_source(db_session, source_type=EarningsSourceType.extra_images, source_id=purchase.id, reason="stripe_refund")
    db_session.commit()
    invoice = _get(client, pro, f"/v1/pro/earnings/invoices/{gig.id}")
    assert (D(invoice["extras_pro_raww"]), invoice["pro_raww_rawws"]) == (D("0.00"), 75)


def test_the_wallet_lists_pending_extras_with_their_date(client, db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    _, entry = _extras(db_session, gig)

    items = _get(client, pro)["pending_bookings"]

    assert sorted(i["amount"] for i in items) == [5, 75]
    extras = next(i for i in items if i["amount"] == 5)
    assert extras["gig_id"] == str(gig.id) and extras["held"] is False
    assert datetime.fromisoformat(extras["expected_at"].replace("Z", "+00:00")) == entry.available_at.astimezone(timezone.utc)


def test_earning_from_extras_restarts_the_expiry_clock(db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    db_session.get(ProRawwBalance, pro).last_activity_at = None
    db_session.commit()

    _extras(db_session, gig)

    db_session.expire_all()
    assert db_session.get(ProRawwBalance, pro).last_activity_at is not None


def test_a_later_change_of_the_raww_value_leaves_them_as_earned(db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    _extras(db_session, gig)
    shelf_settings(db_session).raww_eur_value = D("0.05")
    db_session.commit()

    _settle(db_session, pro)

    assert [a for _, a, _ in _extras_raww(db_session, pro)] == [5], "€0.50 stays 5 RAWW, not 10"


def test_refunding_one_purchase_leaves_another_on_the_same_booking(db_session):
    pro = _pro_user(db_session)
    gig = _booking(db_session, pro)
    first, _ = _extras(db_session, gig)
    _extras(db_session, gig, total="20.00")

    reverse_earnings_entries_for_source(db_session, source_type=EarningsSourceType.extra_images, source_id=first.id, reason="stripe_refund")
    db_session.commit()

    assert sorted(a for _, a, _ in _extras_raww(db_session, pro)) == [-5, 5, 10]
    assert _balance(db_session, pro) == (0, 85)
