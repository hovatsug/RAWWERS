"""One source of truth for a photographer's money.

A photographer's earnings for a booking are its final price net of refunds,
split by the invoice method (15% retained and 5% $RAWW credit, each rounded,
the photographer's cash the remainder), stamped on the booking once. Every
reader - the Wallet, the "All time" card, the payout request limit, payout
approval and the transfer - asks `photographer_money` or reads the stamp.

The buckets, and the invariant they must hold whatever happens:

    available + reserved + paid_out + pending + on_hold == lifetime cash earned

available may be negative (money paid out that a later refund took back);
the data layer says so, and only the photographer's screen shows 0 with the
adjustment owed.

Found by the owner's test booking: a client paid EUR 79.74, chose 11 photos
(EUR 52.43), and the Wallet credited the photographer EUR 63.79 - 80% of
the payment, not of the price.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.core.errors import APIError
from app.models.admin import ProProfile, UserAccount
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry, EarningsSourceType, PayoutRequest, PayoutRequestStatus
from app.services.invoices import build_invoice, summarise_invoices
from app.services.payouts import (
    approve_payout_request,
    create_earnings_hold,
    create_payout_request,
    mark_payout_paid_manual,
    reject_payout_request,
    reverse_earnings_entries_for_source,
)
from app.services.photographer_money import photographer_money, record_gig_earnings

ADMIN = uuid.UUID("00000000-0000-0000-0000-0000000000aa")
D = Decimal


def _user(db) -> uuid.UUID:
    uid = uuid.uuid4()
    db.add(UserAccount(user_id=uid))
    db.flush()
    return uid


def _pro(db) -> uuid.UUID:
    uid = _user(db)
    db.add(ProProfile(user_id=uid, display_name="Pro", city="Lisbon", country="PT"))
    db.commit()
    return uid


def _gig(db, pro, *, minimum: str, final: str | None = None, credit: int = 0) -> Gig:
    gig = Gig(
        client_user_id=_user(db), pro_user_id=pro, status=GigStatus.paid, currency="EUR",
        amount_minimum=D(minimum), amount_platform_fee=(D(minimum) * D("0.20")).quantize(D("0.01")),
        amount_pro_gross=(D(minimum) * D("0.80")).quantize(D("0.01")),
        amount_final=D(final) if final else None,
        fee_percent=20, retained_percent=15, pro_raww_percent=5, client_credit_percent=credit, meta={},
    )
    db.add(gig)
    db.commit()
    return gig


def _pay(db, gig, amount: str, *, kind=StripePaymentKind.base, refunded: str = "0.00") -> StripePayment:
    status = PaymentStatus.refunded if D(refunded) >= D(amount) else PaymentStatus.succeeded
    payment = StripePayment(
        gig_id=gig.id, kind=kind, client_user_id=gig.client_user_id, status=status,
        stripe_payment_intent_id=f"pi_{uuid.uuid4().hex}", amount=D(amount), amount_refunded=D(refunded), currency="EUR", meta={},
    )
    db.add(payment)
    db.commit()
    return payment


def _complete(db, gig) -> EarningsLedgerEntry | None:
    gig.status = GigStatus.completed
    entry = record_gig_earnings(db, gig)
    db.commit()
    return entry


def _settle(db, pro):
    """Past the settlement delay: pending earnings become available."""
    from app.services.payouts import settle_due_earnings_entries

    for row in db.execute(select(EarningsLedgerEntry).where(EarningsLedgerEntry.pro_user_id == pro)).scalars():
        row.available_at = datetime.now(timezone.utc) - timedelta(minutes=1)
    db.commit()
    settle_due_earnings_entries(db)
    db.commit()


def _holds(m) -> None:
    assert m.available + m.reserved + m.paid_out + m.pending + m.on_hold == m.lifetime, m


def _money(db, pro):
    db.expire_all()
    m = photographer_money(db, pro)
    _holds(m)
    return m


# --- the split ----------------------------------------------------------------------------


def test_the_invoice_method_is_the_split_for_this_booking(db_session):
    """EUR 52.43: 15% is 7.86, 5% is 2.62, the photographer's cash 41.95."""
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="79.74", final="52.43")
    _pay(db_session, gig, "79.74")

    entry = _complete(db_session, gig)

    assert (entry.gross_eur, entry.platform_fee_eur, entry.net_eur) == (D("52.43"), D("10.48"), D("41.95"))
    db_session.refresh(gig)
    assert (gig.final_gross, gig.final_platform_retained, gig.final_pro_raww, gig.final_client_raww, gig.final_pro_cash) == (
        D("52.43"), D("7.86"), D("2.62"), D("0.00"), D("41.95"),
    )


def test_the_deposit_fields_are_history_and_never_change(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="79.74", final="52.43")
    _pay(db_session, gig, "79.74")
    _complete(db_session, gig)

    db_session.refresh(gig)
    assert (gig.amount_minimum, gig.amount_platform_fee, gig.amount_pro_gross) == (D("79.74"), D("15.95"), D("63.79"))


def test_client_credit_comes_out_of_the_photographers_cash(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00", credit=10)
    _pay(db_session, gig, "100.00")

    entry = _complete(db_session, gig)

    assert entry.net_eur == D("70.00")
    assert gig.final_client_raww == D("10.00")


# --- where earnings come from ---------------------------------------------------------------


def test_earnings_come_from_the_final_price_not_the_payments(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="79.74", final="52.43")
    _pay(db_session, gig, "79.74")
    _complete(db_session, gig)

    assert _money(db_session, pro).lifetime == D("41.95")


def test_a_difference_payment_is_earned_on(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="79.74", final="100.00")
    _pay(db_session, gig, "79.74")
    _pay(db_session, gig, "20.26", kind=StripePaymentKind.difference)
    _complete(db_session, gig)

    assert _money(db_session, pro).lifetime == D("80.00")


def test_a_partial_refund_before_completion_is_not_earned_on(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00")
    _pay(db_session, gig, "100.00", refunded="30.00")
    _complete(db_session, gig)

    assert _money(db_session, pro).lifetime == D("56.00")  # 70.00 - 10.50 - 3.50


def test_a_partial_refund_after_completion_lowers_earnings(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00")
    payment = _pay(db_session, gig, "100.00")
    _complete(db_session, gig)
    payment.amount_refunded = D("30.00")
    db_session.commit()

    record_gig_earnings(db_session, gig)
    db_session.commit()

    assert _money(db_session, pro).lifetime == D("56.00")


def test_refund_reconciliation_recomputes_through_the_one_function(db_session, monkeypatch):
    from app.services import refund_reconcile

    calls = []
    monkeypatch.setattr(refund_reconcile, "record_gig_earnings", lambda db, gig, **kw: calls.append((gig.id, kw)))
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00")
    payment = _pay(db_session, gig, "100.00")
    _complete(db_session, gig)
    from types import SimpleNamespace

    refund = {"id": "re_1", "amount": 3000, "status": "succeeded", "created": 1, "metadata": {}}
    monkeypatch.setattr(refund_reconcile.stripe.Refund, "list", lambda **_: SimpleNamespace(auto_paging_iter=lambda: [refund]))

    refund_reconcile.reconcile_payment_refunds(db_session, payment.stripe_payment_intent_id, trigger="test")

    assert calls == [(gig.id, {"lower_only": True})]


def test_a_full_refund_leaves_nothing_earned(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00")
    _pay(db_session, gig, "100.00", refunded="100.00")
    assert _complete(db_session, gig) is None
    assert _money(db_session, pro).lifetime == D("0.00")


def test_a_reversed_entry_is_never_brought_back(db_session):
    pro = _pro(db_session)
    gig = _earned(db_session, pro)
    reverse_earnings_entries_for_source(db_session, source_type=EarningsSourceType.gig_base, source_id=gig.id, reason="full_refund")
    db_session.commit()

    record_gig_earnings(db_session, gig)
    db_session.commit()

    assert _money(db_session, pro).lifetime == D("0.00")


def test_a_failed_refund_never_raises_earnings_back(db_session):
    """The money is back with us but owed to the client, not earned."""
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00")
    payment = _pay(db_session, gig, "100.00", refunded="30.00")
    _complete(db_session, gig)
    payment.amount_refunded = D("0.00")  # the refund failed
    db_session.commit()

    record_gig_earnings(db_session, gig, lower_only=True)
    db_session.commit()

    assert _money(db_session, pro).lifetime == D("56.00")


def test_recording_twice_records_once(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00")
    _pay(db_session, gig, "100.00")
    _complete(db_session, gig)
    record_gig_earnings(db_session, gig)
    db_session.commit()

    rows = db_session.execute(select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_id == gig.id)).scalars().all()
    assert len(rows) == 1 and _money(db_session, pro).lifetime == D("80.00")


def test_the_admin_status_route_to_completed_earns_the_same(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="79.74", final="52.43")
    _pay(db_session, gig, "79.74")

    resp = client.post(
        f"/v1/admin/gigs/{gig.id}/status", headers={"X-User-Id": str(ADMIN)},
        json={"status": "completed", "reason": "Closing by hand"},
    )

    assert resp.status_code == 200, resp.text
    assert _money(db_session, pro).lifetime == D("41.95")


# --- buckets --------------------------------------------------------------------------------


def _earned(db, pro, gross="100.00") -> Gig:
    gig = _gig(db, pro, minimum=gross)
    _pay(db, gig, gross)
    _complete(db, gig)
    return gig


def test_new_earnings_are_pending_then_available(db_session):
    pro = _pro(db_session)
    _earned(db_session, pro)
    m = _money(db_session, pro)
    assert (m.pending, m.available) == (D("80.00"), D("0.00"))

    _settle(db_session, pro)
    m = _money(db_session, pro)
    assert (m.pending, m.available, m.withdrawable) == (D("0.00"), D("80.00"), D("80.00"))


def test_a_disputed_booking_is_on_hold(db_session):
    from app.models.payouts import EarningsHoldReason

    pro = _pro(db_session)
    gig = _earned(db_session, pro)
    create_earnings_hold(db_session, pro_user_id=pro, reason=EarningsHoldReason.dispute_open, amount_eur=None, source_type="gig_base", source_id=gig.id, created_by_admin_id=None)
    db_session.commit()

    m = _money(db_session, pro)
    assert (m.on_hold, m.available, m.withdrawable) == (D("80.00"), D("0.00"), D("0.00"))


def _payout(db, pro, amount: str, *, older: bool = False) -> PayoutRequest:
    row = create_payout_request(db, pro_user_id=pro, amount_eur=D(amount))
    if older:  # out of the weekly request limit's window, so another can follow
        row.created_at = datetime.now(timezone.utc) - timedelta(days=8)
    db.commit()
    return row


def test_a_payout_moves_through_reserved_to_paid_out(db_session):
    pro = _pro(db_session)
    _earned(db_session, pro)
    _settle(db_session, pro)

    row = _payout(db_session, pro, "60.00")
    m = _money(db_session, pro)
    assert (m.available, m.reserved, m.paid_out) == (D("80.00"), D("0.00"), D("0.00"))  # requested only

    approve_payout_request(db_session, payout_request_id=row.id, admin_user_id=ADMIN)
    db_session.commit()
    m = _money(db_session, pro)
    assert (m.available, m.reserved, m.paid_out, m.withdrawable) == (D("20.00"), D("60.00"), D("0.00"), D("20.00"))

    mark_payout_paid_manual(db_session, payout_request_id=row.id, admin_user_id=ADMIN, reference={"bank": "x"})
    db_session.commit()
    m = _money(db_session, pro)
    # Paid out is not reserved: it has left.
    assert (m.available, m.reserved, m.paid_out, m.lifetime) == (D("20.00"), D("0.00"), D("60.00"), D("80.00"))


def test_a_rejected_payout_frees_nothing_it_never_held(db_session):
    pro = _pro(db_session)
    _earned(db_session, pro)
    _settle(db_session, pro)
    row = _payout(db_session, pro, "60.00")

    reject_payout_request(db_session, payout_request_id=row.id, admin_user_id=ADMIN, reason="no")
    db_session.commit()

    m = _money(db_session, pro)
    assert (m.available, m.reserved, m.paid_out) == (D("80.00"), D("0.00"), D("0.00"))


def test_a_refund_after_payout_goes_negative_in_the_data_and_zero_on_screen(db_session):
    pro = _pro(db_session)
    gig = _earned(db_session, pro)
    _settle(db_session, pro)
    row = _payout(db_session, pro, "80.00")
    approve_payout_request(db_session, payout_request_id=row.id, admin_user_id=ADMIN)
    mark_payout_paid_manual(db_session, payout_request_id=row.id, admin_user_id=ADMIN, reference={})
    db_session.commit()

    reverse_earnings_entries_for_source(db_session, source_type=EarningsSourceType.gig_base, source_id=gig.id, reason="full_refund")
    db_session.commit()

    m = _money(db_session, pro)
    assert (m.lifetime, m.paid_out, m.available) == (D("0.00"), D("80.00"), D("-80.00"))
    assert (m.withdrawable, m.adjustment_owed) == (D("0.00"), D("80.00"))


def test_the_balance_route_shows_the_photographer_zero_and_the_adjustment(client, db_session):
    pro = _pro(db_session)
    gig = _earned(db_session, pro)
    _settle(db_session, pro)
    row = _payout(db_session, pro, "80.00")
    approve_payout_request(db_session, payout_request_id=row.id, admin_user_id=ADMIN)
    mark_payout_paid_manual(db_session, payout_request_id=row.id, admin_user_id=ADMIN, reference={})
    reverse_earnings_entries_for_source(db_session, source_type=EarningsSourceType.gig_base, source_id=gig.id, reason="full_refund")
    db_session.commit()
    from app.models.admin import UserRole, UserRoleType

    db_session.add(UserRole(user_id=pro, role=UserRoleType.pro))
    db_session.commit()

    body = client.get("/v1/pro/earnings/balance", headers={"X-User-Id": str(pro)}).json()

    assert body["withdrawable_eur"] == "0.00"
    assert body["adjustment_owed_eur"] == "80.00"
    assert body["paid_out_eur"] == "80.00"


# --- payouts ask the same function -----------------------------------------------------------


def test_a_payout_request_cannot_exceed_withdrawable(db_session):
    pro = _pro(db_session)
    _earned(db_session, pro)
    _settle(db_session, pro)

    with pytest.raises(APIError):
        create_payout_request(db_session, pro_user_id=pro, amount_eur=D("80.01"))


def test_the_request_limit_is_what_can_be_withdrawn_not_what_was_earned(db_session):
    pro = _pro(db_session)
    _earned(db_session, pro)
    _settle(db_session, pro)
    row = _payout(db_session, pro, "60.00", older=True)
    approve_payout_request(db_session, payout_request_id=row.id, admin_user_id=ADMIN)
    db_session.commit()
    assert (_money(db_session, pro).lifetime, _money(db_session, pro).withdrawable) == (D("80.00"), D("20.00"))

    with pytest.raises(APIError):
        create_payout_request(db_session, pro_user_id=pro, amount_eur=D("50.00"))


def test_approval_re_checks_what_is_available_now(db_session):
    pro = _pro(db_session)
    _earned(db_session, pro)
    _settle(db_session, pro)
    first, second = _payout(db_session, pro, "60.00"), _payout(db_session, pro, "60.00")
    approve_payout_request(db_session, payout_request_id=first.id, admin_user_id=ADMIN)
    db_session.commit()

    with pytest.raises(APIError) as refused:
        approve_payout_request(db_session, payout_request_id=second.id, admin_user_id=ADMIN)
    assert refused.value.code == "insufficient_balance"


def test_approval_asks_the_wallet_function(db_session, monkeypatch):
    from app.services import payouts

    pro = _pro(db_session)
    _earned(db_session, pro)
    _settle(db_session, pro)
    row = _payout(db_session, pro, "60.00")
    asked = []
    real = payouts.photographer_money
    monkeypatch.setattr(payouts, "photographer_money", lambda db, p: asked.append(p) or real(db, p))

    approve_payout_request(db_session, payout_request_id=row.id, admin_user_id=ADMIN)

    assert asked == [pro]


# --- $RAWW is not cash ----------------------------------------------------------------------


def test_raww_minted_and_reversed_never_moves_cash(db_session):
    from app.models.proof_of_gigs import RawwMintEvent, RawwMintEventStatus

    pro = _pro(db_session)
    gig = _earned(db_session, pro)
    before = _money(db_session, pro)
    mint = RawwMintEvent(event_type="gig.completed", pro_user_id=pro, reference_type="gig", reference_id=gig.id,
                         raww_awarded=108, multiplier_snapshot={}, status=RawwMintEventStatus.minted)
    db_session.add(mint)
    db_session.commit()
    assert _money(db_session, pro) == before

    mint.status = RawwMintEventStatus.reversed
    db_session.commit()
    assert _money(db_session, pro) == before


# --- the "All time" card --------------------------------------------------------------------


def test_the_card_adds_up_and_raww_credit_sits_outside_the_sum(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="79.74", final="52.43")
    _pay(db_session, gig, "79.74")
    _complete(db_session, gig)

    s = summarise_invoices(db_session, pro)

    assert (s.gross, s.platform_fees, s.pro_cash, s.pro_raww) == (D("52.43"), D("10.48"), D("41.95"), D("2.62"))
    assert s.gross - s.platform_fees == s.pro_cash
    assert s.pro_cash == _money(db_session, pro).lifetime


def test_the_invoice_reads_the_stamp(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00")
    payment = _pay(db_session, gig, "100.00")
    _complete(db_session, gig)
    payment.amount_refunded = D("30.00")
    db_session.commit()
    record_gig_earnings(db_session, gig)
    db_session.commit()

    invoice = build_invoice(db_session, gig)

    assert (invoice.client_total, invoice.pro_cash) == (D("70.00"), D("56.00"))


# --- the invariant, every scenario at once --------------------------------------------------


def test_the_invariant_holds_through_a_photographers_whole_history(db_session):
    from app.models.payouts import EarningsHoldReason

    pro = _pro(db_session)
    _earned(db_session, pro)                                           # completed
    reduced = _gig(db_session, pro, minimum="79.74", final="52.43")     # price reduced
    _pay(db_session, reduced, "79.74")
    _complete(db_session, reduced)
    diff = _gig(db_session, pro, minimum="79.74", final="100.00")      # difference payment
    _pay(db_session, diff, "79.74")
    _pay(db_session, diff, "20.26", kind=StripePaymentKind.difference)
    _complete(db_session, diff)
    part = _gig(db_session, pro, minimum="100.00")                     # part-refunded
    _pay(db_session, part, "100.00", refunded="30.00")
    _complete(db_session, part)
    full = _earned(db_session, pro)                                    # refunded
    reverse_earnings_entries_for_source(db_session, source_type=EarningsSourceType.gig_base, source_id=full.id, reason="full_refund")
    disputed = _earned(db_session, pro)                                # disputed
    create_earnings_hold(db_session, pro_user_id=pro, reason=EarningsHoldReason.dispute_open, amount_eur=None, source_type="gig_base", source_id=disputed.id, created_by_admin_id=None)
    db_session.commit()
    _money(db_session, pro)
    _settle(db_session, pro)
    paid = _payout(db_session, pro, "50.00", older=True)               # payout paid
    approve_payout_request(db_session, payout_request_id=paid.id, admin_user_id=ADMIN)
    mark_payout_paid_manual(db_session, payout_request_id=paid.id, admin_user_id=ADMIN, reference={})
    rejected = _payout(db_session, pro, "50.00", older=True)            # payout rejected
    reject_payout_request(db_session, payout_request_id=rejected.id, admin_user_id=ADMIN, reason="no")
    pending = _payout(db_session, pro, "60.00")                        # payout approved, not paid
    approve_payout_request(db_session, payout_request_id=pending.id, admin_user_id=ADMIN)
    db_session.commit()

    m = _money(db_session, pro)

    assert m.lifetime == D("80.00") + D("41.95") + D("80.00") + D("56.00") + D("80.00")
    assert (m.paid_out, m.reserved, m.on_hold) == (D("50.00"), D("60.00"), D("80.00"))


# --- the repair script ----------------------------------------------------------------------


def test_the_recompute_script_finds_and_fixes_an_old_style_entry(db_session):
    import importlib.util
    from pathlib import Path

    from app.services.payouts import create_earnings_entry

    spec = importlib.util.spec_from_file_location("recompute_earnings", Path(__file__).resolve().parents[1] / "scripts" / "recompute_earnings.py")
    script = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(script)

    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="79.74", final="52.43")
    _pay(db_session, gig, "79.74")
    gig.status = GigStatus.completed
    # The old way: 20% of the sum of the payments.
    create_earnings_entry(db_session, pro_user_id=pro, source_type=EarningsSourceType.gig_base, source_id=gig.id, gross_eur=D("79.74"))
    db_session.commit()
    assert _money(db_session, pro).lifetime == D("63.79")

    changes = script.plan(db_session)
    assert [(g.id, cur, new) for g, cur, new in changes] == [(gig.id, D("63.79"), D("41.95"))]

    for g, _, _ in changes:
        record_gig_earnings(db_session, g)
    db_session.commit()
    assert _money(db_session, pro).lifetime == D("41.95")
    assert script.plan(db_session) == []


def test_reward_points_paid_count_towards_what_was_earned(db_session):
    """A client paid part with points: RAWWERS funds that discount, and the
    photographer earns on the whole price, as if it had been card."""
    from app.models.reward import DiscountRedemption, DiscountRedemptionStatus, RedemptionContextType

    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00")
    _pay(db_session, gig, "90.00")
    db_session.add(DiscountRedemption(user_id=gig.client_user_id, context_type=RedemptionContextType.gig_payment, context_id=gig.id,
                                      points_spent=1000, discount_amount=D("10.00"), currency="EUR", status=DiscountRedemptionStatus.applied))
    db_session.commit()
    _complete(db_session, gig)

    assert _money(db_session, pro).lifetime == D("80.00")


def test_the_recompute_script_never_wipes_earnings_with_no_payment_on_record(db_session):
    import importlib.util
    from pathlib import Path

    from app.services.payouts import create_earnings_entry

    spec = importlib.util.spec_from_file_location("recompute_earnings", Path(__file__).resolve().parents[1] / "scripts" / "recompute_earnings.py")
    script = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(script)

    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00")  # no payment rows at all, like the seed fixtures
    gig.status = GigStatus.completed
    create_earnings_entry(db_session, pro_user_id=pro, source_type=EarningsSourceType.gig_base, source_id=gig.id, gross_eur=D("100.00"))
    db_session.commit()

    unpaid: list = []
    assert script.plan(db_session, None, unpaid) == []
    assert [g.id for g, _ in unpaid] == [gig.id]
