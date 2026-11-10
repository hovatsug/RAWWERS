"""The business dashboard's numbers (docs/BI.md), against a small world whose
every number is worked out by hand below.

Two days, D1 = 2026-10-05 and D2 = 2026-10-06 (Europe/London), read on
2026-11-09 (so neither is a "live" day).

G1, weddings, photographer P1 (PT, tier pro), rates 15 / 5 / client 0:
  D1  card 100.00   -> retained 1500, RAWW 500, cash 8000
  D1  credit 10.00  -> retained 150, RAWW 50, cash 800 (1000 points)
  D2  card refund 20.00    -> retained -300, RAWW -100, cash -1600
  D2  credit returned 200 points = 2.00 -> retained -30, RAWW -10, cash -160
G2, portraits, photographer P2 (GB, tier rookie), rates 15 / 5 / client 10:
  D2  card 52.43    -> retained 786, RAWW 262, client 524, cash 3671
  D2  extras 10.00  -> (extras 20%: 15 + 5) retained 150, RAWW 50, cash 800

  GMV 17243 (card 16243, credit 1000); refunds 2200 (card 2000, credit 200)
  net 15043 = cash 11511 + RAWW 752 + client 524 + retained 2256
  bookings 2; client credit used 1000 - 200 = 800

Stripe (D1 and D2 mirrored): fees 170 + 99 + 40 = 309; contribution 1947
Costs: ads 5000 (D1), marketing 1234 (D2), software 2000 (D1), salaries
  10000 monthly from 2026-09-06 (once in the period, on D2), Shelf
  shipping 300 (D2), and one in USD (left out, counted)
  marketing spend 5000 + 1234 + 800 = 7034; other costs 12000
Shelf (RAWW at 0.10, GBP at 1.20): O1 item A (GBP 30 = 3600) 500 RAWW =
  5000 on D1; O2 item B (no cost) 300 RAWW = 3000 on D2, cost not set;
  O3 item A 400 RAWW placed D1, refunded D2 (nets to 0)
  margin 5000 - 3600 - 300 = 1100
RAWW: issued 2000 RAWW (20000), spent 8000, expired 100 RAWW (1000),
  adjusted +20 RAWW (200); outstanding 1120 RAWW = 11200; breakage 1000
Operating profit: 1947 - 7034 - 12000 + 1100 + 1000 = -14987
"""
import uuid
from datetime import date, datetime, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select, text

from app.models.admin import MoneyAttentionItem, ProProfile, RefundCase, RefundCaseStatus, UserAccount
from app.models.bi import BiCompanyCash, BiCost, BiStripeSyncDay, BiStripeTxn
from app.models.gig import Gig, GigStatus, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment, StripePaymentKind
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry, EarningsSourceType, PayoutAllocation, PayoutRequest, PayoutRequestStatus
from app.models.reward import (
    DiscountRedemption,
    DiscountRedemptionStatus,
    RedemptionContextType,
    RewardEntryType,
    RewardLedgerEntry,
)
from app.models.shelf import ProRawwLedgerEntry, RawwEntryKind, RawwEntryStatus, ShelfItem, ShelfOrder, ShelfOrderStatus
from app.services import bi
from app.services.shelf_settings import shelf_settings

D1, D2 = date(2026, 10, 5), date(2026, 10, 6)
NOW = datetime(2026, 11, 9, 12, 0, tzinfo=timezone.utc)
ADMIN = uuid.UUID("00000000-0000-0000-0000-0000000000aa")


def at(day: date, hour: int = 12) -> datetime:
    return datetime(day.year, day.month, day.day, hour, 0, tzinfo=timezone.utc)


class World:
    pass


def _user(db, uid, *, pro_country=None, name=None):
    if not db.get(UserAccount, uid):
        db.add(UserAccount(user_id=uid))
        db.flush()
    if pro_country is not None:
        db.add(ProProfile(user_id=uid, country=pro_country, display_name=name))


def _gig(db, client, pro, niche, *, cc=0):
    gig = Gig(client_user_id=client, pro_user_id=pro, niche_id=niche.id, status=GigStatus.paid, currency="EUR",
              amount_minimum=Decimal("100.00"), amount_platform_fee=Decimal("20.00"), amount_pro_gross=Decimal("80.00"),
              fee_percent=20, retained_percent=15, pro_raww_percent=5, client_credit_percent=cc)
    db.add(gig)
    db.flush()
    return gig


def _card(db, gig, amount, day, *, kind=StripePaymentKind.base, captured=True):
    pi = f"pi_{uuid.uuid4().hex[:12]}"
    db.add(StripePayment(gig_id=gig.id, kind=kind, client_user_id=gig.client_user_id, status=PaymentStatus.succeeded,
                         stripe_payment_intent_id=pi, amount=Decimal(amount), currency="EUR", created_at=at(day, 9)))
    if captured:
        db.add(LedgerEntry(gig_id=gig.id, entry_type=LedgerEntryType.payment_captured, amount=Decimal(amount), currency="EUR",
                           reference_type="stripe_payment_intent", reference_id=pi, created_at=at(day)))
    return pi


def build_world(db) -> World:
    w = World()
    niches = {n.slug: n for n in db.execute(select(Niche)).scalars()}
    w.client, w.p1, w.p2 = uuid.uuid4(), uuid.uuid4(), uuid.uuid4()
    _user(db, w.client)
    _user(db, w.p1, pro_country="pt", name="Pat One")
    _user(db, w.p2, pro_country="GB", name="Sam Two")
    db.add(ProNicheSkill(pro_user_id=w.p1, niche_id=niches["weddings"].id, tier=SkillTier.pro))
    db.add(ProNicheSkill(pro_user_id=w.p2, niche_id=niches["portraits"].id, tier=SkillTier.rookie))

    # G1: card 100 and credit 10 on D1; a 20 refund and 200 points back on D2.
    w.g1 = _gig(db, w.client, w.p1, niches["weddings"])
    _card(db, w.g1, "100.00", D1)
    redemption = DiscountRedemption(user_id=w.client, context_type=RedemptionContextType.gig_payment, context_id=w.g1.id,
                                    points_spent=1000, discount_amount=Decimal("10.00"), currency="EUR",
                                    status=DiscountRedemptionStatus.applied, created_at=at(D1, 8), updated_at=at(D1))
    db.add(redemption)
    db.flush()
    db.add(LedgerEntry(gig_id=w.g1.id, entry_type=LedgerEntryType.refund_succeeded, amount=Decimal("-20.00"), currency="EUR",
                       reference_type="stripe_refund", reference_id="re_1", created_at=at(D2)))
    db.add(RewardLedgerEntry(user_id=w.client, entry_type=RewardEntryType.adjustment, amount=200, balance_after=200,
                             reference_type="booking_refund", reference_id=f"{w.g1.id}:re_1",
                             meta={"refunded_redemption_id": str(redemption.id)}, created_at=at(D2)))

    # G2: card 52.43 and extras 10 on D2, client credit 10%.
    w.g2 = _gig(db, w.client, w.p2, niches["portraits"], cc=10)
    w.g2_pi = _card(db, w.g2, "52.43", D2)
    _card(db, w.g2, "10.00", D2, kind=StripePaymentKind.extras, captured=False)

    # Stripe's side.
    for day in (D1, D2):
        db.add(BiStripeSyncDay(day=day, txn_count=0))
    for tid, typ, amount, fee, day in (
        ("txn_1", "charge", 10000, 170, D1), ("txn_2", "charge", 5243, 99, D2), ("txn_3", "charge", 1000, 40, D2),
        ("txn_4", "refund", -2000, 0, D2), ("txn_5", "transfer", -3000, 0, D2), ("txn_6", "payout", -5000, 0, D2),
    ):
        db.add(BiStripeTxn(id=tid, type=typ, currency="EUR", amount_cents=amount, fee_cents=fee, net_cents=amount - fee,
                           created_at=at(day)))

    # Manual costs.
    for day, category, cents, recurring, currency in (
        (D1, "ad_spend", 5000, False, "EUR"), (D2, "marketing", 1234, False, "EUR"), (D1, "software", 2000, False, "EUR"),
        (date(2026, 9, 6), "salaries", 10000, True, "EUR"), (D2, "shelf_shipping", 300, False, "EUR"),
        (D1, "software", 999, False, "USD"),
    ):
        db.add(BiCost(date=day, category=category, amount_cents=cents, recurring=recurring, currency=currency, created_by=ADMIN))

    # The Shelf.
    settings = shelf_settings(db)
    settings.raww_eur_value, settings.gbp_eur_rate = Decimal("0.10"), Decimal("1.20")
    item_a = ShelfItem(title="Battery", category="battery", level=1, price_raww=500, street_price=Decimal("40"),
                       supplier_cost=Decimal("30.00"), supplier_currency="GBP", supplier_name="S")
    item_b = ShelfItem(title="Tote", category="merch", level=1, price_raww=300, street_price=Decimal("10"),
                       supplier_cost=Decimal("0"), supplier_currency="GBP", supplier_name="S")
    db.add_all([item_a, item_b])
    db.flush()

    def order(item, raww, placed, status=ShelfOrderStatus.placed, refunded=None):
        o = ShelfOrder(pro_user_id=w.p1, item_id=item.id, client_request_id=uuid.uuid4().hex, title=item.title,
                       supplier_name="S", level=1, price_raww=raww, raww_eur_value=Decimal("0.10"), status=status,
                       shipping_address={}, country="GB", placed_at=at(placed), refunded_at=at(refunded) if refunded else None)
        db.add(o)
        db.flush()
        return o

    o1 = order(item_a, 500, D1)
    o2 = order(item_b, 300, D2)
    o3 = order(item_a, 400, D1, ShelfOrderStatus.refunded, refunded=D2)

    def raww(kind, amount, day, source_type, source_id, rate=None):
        db.add(ProRawwLedgerEntry(pro_user_id=w.p1, kind=kind, amount=amount, status=RawwEntryStatus.spendable,
                                  source_type=source_type, source_id=source_id, raww_eur_value=rate, created_at=at(day)))

    raww(RawwEntryKind.earn_booking, 2000, D1, "gig", f"gig:{w.g1.id}", Decimal("0.10"))
    raww(RawwEntryKind.spend_order, -500, D1, "shelf_order", str(o1.id))
    raww(RawwEntryKind.spend_order, -400, D1, "shelf_order", str(o3.id))
    raww(RawwEntryKind.refund_order, 400, D2, "shelf_order", str(o3.id))
    raww(RawwEntryKind.spend_order, -300, D2, "shelf_order", str(o2.id))
    raww(RawwEntryKind.expire, -100, D2, "expiry", "inactive-since:x")
    raww(RawwEntryKind.admin_adjust, 20, D2, "admin", "adj-1")

    # Money owed now: earnings, a paid payout, clients owed, company cash.
    def earning(pro, net, status):
        e = EarningsLedgerEntry(pro_user_id=pro, source_type=EarningsSourceType.gig_base, source_id=uuid.uuid4(),
                                gross_eur=net, platform_fee_eur=Decimal("0"), net_eur=net, status=status, available_at=at(D2))
        db.add(e)
        db.flush()
        return e

    earning(w.p1, Decimal("80.00"), EarningsEntryStatus.pending)
    earning(w.p2, Decimal("36.71"), EarningsEntryStatus.held)
    paid_entry = earning(w.p1, Decimal("50.00"), EarningsEntryStatus.available)
    payout = PayoutRequest(pro_user_id=w.p1, amount_eur=Decimal("30.00"), status=PayoutRequestStatus.paid, paid_at=at(D2))
    db.add(payout)
    db.flush()
    db.add(PayoutAllocation(payout_request_id=payout.id, earnings_ledger_entry_id=paid_entry.id, amount_eur=Decimal("30.00")))
    db.add(MoneyAttentionItem(kind="client_owed", status="open", gig_id=w.g1.id, amount=Decimal("5.00"), currency="EUR"))
    db.add(RefundCase(gig_id=w.g2.id, requested_by_user_id=w.client, status=RefundCaseStatus.approved, amount=Decimal("10.00"),
                      amount_refunded=Decimal("4.00"), currency="EUR"))
    for day, account, cents in ((date(2026, 10, 1), "Bank", 100000), (date(2026, 10, 5), "Bank", 150000), (D1, "Savings", 20000)):
        db.add(BiCompanyCash(date=day, account=account, amount_cents=cents, created_by=ADMIN))
    db.commit()
    return w


@pytest.fixture
def world(db_session):
    return build_world(db_session)


def _summary(db, **filters):
    return bi.summarize(db, D1, D2, bi.Filters(**filters), now=NOW)


# --- every definition ---------------------------------------------------------------------------


def test_gmv_refunds_and_the_split(db_session, world):
    v = _summary(db_session).values
    assert (v["gmv"], v["gmv_card"], v["gmv_credit"]) == (17243, 16243, 1000)
    assert (v["refund"], v["refund_card"], v["refund_credit"], v["refund_chargeback"]) == (2200, 2000, 200, 0)
    assert v["net_gmv"] == 15043
    assert (v["retained"], v["pro_raww"], v["client_raww"], v["pro_cash"]) == (2256, 752, 524, 11511)
    assert v["pro_cash"] + v["pro_raww"] + v["client_raww"] + v["retained"] == v["net_gmv"]
    assert v["bookings"] == 2


def test_stripe_fees_contribution_and_marketing(db_session, world):
    v = _summary(db_session).values
    assert v["stripe_fees"] == 309
    assert v["contribution"] == 1947
    assert v["client_credit_used"] == 800
    assert (v["ad_spend"], v["marketing_costs"], v["marketing_spend"]) == (5000, 1234, 7034)
    assert v["other_costs"] == 12000  # software 2000 + the salaries' October occurrence; the USD cost left out


def test_shelf_margin_raww_and_breakage(db_session, world):
    s = _summary(db_session)
    v = s.values
    assert (v["shelf_value"], v["shelf_cost"], v["shelf_shipping"], v["shelf_margin"]) == (5000, 3600, 300, 1100)
    assert (v["shelf_cost_not_set_orders"], v["shelf_cost_not_set_value"]) == (1, 3000)
    assert (v["raww_issued"], v["raww_spent"], v["raww_expired"], v["raww_adjust"]) == (20000, 8000, 1000, 200)
    assert v["breakage"] == 1000
    assert v["operating_profit"] == -14987
    assert s.meta["other_currency_costs"] == 1


def test_client_credit_is_counted_once(db_session, world):
    """Operating profit equals the same profit worked from card cash alone:
    the credit is in GMV (the pre-discount price) and comes off once, in
    marketing spend. Counting it twice, or not at all, breaks this."""
    v = _summary(db_session).values
    card_net = v["gmv_card"] - v["refund_card"] - v["refund_chargeback"]
    from_cash = (card_net - v["pro_cash"] - v["pro_raww"] - v["client_raww"] - v["stripe_fees"]
                 - v["ad_spend"] - v["marketing_costs"] - v["other_costs"] + v["shelf_margin"] + v["breakage"])
    assert v["operating_profit"] == from_cash
    assert v["gmv"] - v["gmv_card"] == v["gmv_credit"] == 1000  # in GMV, at the pre-discount price
    assert v["retained"] == 2256  # not lowered by the credit


def test_the_liquid_view_and_raww_liability(db_session, world):
    o = bi.owed(db_session, {"available_cents": 50000, "pending_cents": 7000, "reason": None})
    assert o["photographers"] == {"in_settlement_cents": 8000, "held_cents": 3671, "due_cents": 2000, "owed_cents": 13671,
                                  "paid_out_cents": 3000, "owed_back_by_photographers_cents": 0}
    assert o["clients"]["owed_cents"] == 1100
    assert (o["raww"]["outstanding_raww"], o["raww"]["outstanding_cents"]) == (1120, 11200)
    assert o["company_cash"]["total_cents"] == 170000
    assert o["liquid"] == {"cents": 50000 + 7000 + 170000 - 13671 - 1100, "reason": None}


def test_without_stripe_s_balance_liquid_is_no_data(db_session, world):
    o = bi.owed(db_session, {"available_cents": None, "pending_cents": None, "reason": "Stripe balance unavailable"})
    assert o["liquid"]["cents"] is None and o["liquid"]["reason"] == "Stripe balance unavailable"


def test_a_day_without_stripe_data_is_no_data_not_zero(db_session, world):
    db_session.execute(text("DELETE FROM bi_stripe_sync_day WHERE day = :d"), {"d": D2})
    s = _summary(db_session)
    assert s.values["stripe_fees"] is None and "No Stripe data for 1 day" in s.reasons["stripe_fees"]
    assert s.values["contribution"] is None and s.values["operating_profit"] is None


def test_a_filter_leaves_company_numbers_unsplit(db_session, world):
    s = _summary(db_session, niche="portraits")
    assert s.values["gmv"] == 5243 + 1000
    assert s.values["stripe_fees"] is None and s.values["operating_profit"] is None
    assert "Not split" in s.reasons["stripe_fees"]


# --- the waterfall and the reconciliation -------------------------------------------------------


def test_the_waterfall_adds_up(db_session, world):
    w = bi.waterfall(_summary(db_session))
    assert w["adds_up"] and w["mismatches"] == [] and w["incomplete"] is None
    totals = {s["key"]: s["cents"] for s in w["steps"] if s["kind"] == "total"}
    assert totals == {"retained": 2256, "contribution": 1947, "operating_profit": -14987}


def test_a_waterfall_that_does_not_add_up_says_so(db_session, world):
    bi.recompute_days(db_session, D1, D2)
    db_session.execute(text("UPDATE bi_daily SET retained_cents = retained_cents + 7 WHERE day = :d AND scope = 'booking' AND niche = 'weddings'"), {"d": D1})
    w = bi.waterfall(_summary(db_session))
    assert not w["adds_up"]
    assert w["mismatches"][0]["at"] == "retained" and w["mismatches"][0]["difference_cents"] == -7


def test_the_reconciliation_matches_and_then_catches_a_difference(db_session, world):
    r = bi.reconciliation(_summary(db_session))
    assert r["all_match"] and r["differences"] == []
    lines = {x["key"]: x for x in r["lines"]}
    assert (lines["charge"]["ours_cents"], lines["charge"]["stripe_cents"]) == (16243, 16243)
    assert (lines["transfer"]["ours_cents"], lines["transfer"]["stripe_cents"]) == (3000, 3000)
    payment = db_session.execute(select(StripePayment).where(StripePayment.stripe_payment_intent_id == world.g2_pi)).scalar_one()
    payment.amount = Decimal("52.44")
    db_session.commit()
    r = bi.reconciliation(_summary(db_session))
    assert r["differences"] == ["charge"]
    assert {x["key"]: x for x in r["lines"]}["charge"]["difference_cents"] == 1


# --- bi_daily: idempotent, and the same as the live views ---------------------------------------


def _stored(db):
    return [dict(r) for r in db.execute(text("SELECT * FROM bi_daily ORDER BY day, scope, niche, country, tier")).mappings()]


def _without_time(rows):
    return [{k: v for k, v in r.items() if k != "computed_at"} for r in rows]


def test_recomputing_a_day_gives_the_same_rows(db_session, world):
    bi.recompute_days(db_session, D1, D2)
    first = _without_time(_stored(db_session))
    bi.recompute_days(db_session, D1, D2)
    assert _without_time(_stored(db_session)) == first
    assert {r["scope"] for r in first} == {"booking", "company"}


def test_the_backfill_matches_the_live_views(db_session, world):
    live = _summary(db_session)
    assert live.meta["live_days"] == 2
    bi.recompute_range(db_session, date(2026, 9, 1), date(2026, 10, 31))
    stored = _summary(db_session)
    assert stored.meta["live_days"] == 0
    assert stored.values == live.values


def test_the_last_three_days_are_always_live(db_session, world):
    rows = bi.daily_rows(db_session, date(2026, 11, 1), date(2026, 11, 9), now=NOW)
    assert rows.live_days == 9
    bi.recompute_days(db_session, date(2026, 11, 1), date(2026, 11, 9))
    assert bi.daily_rows(db_session, date(2026, 11, 1), date(2026, 11, 9), now=NOW).live_days == 3


def test_ranges_are_capped(db_session):
    from app.core.errors import APIError

    with pytest.raises(APIError):
        bi.recompute_days(db_session, date(2026, 1, 1), date(2026, 6, 1))
    with pytest.raises(APIError):
        bi.daily_rows(db_session, date(2023, 1, 1), date(2026, 1, 1))


# --- breakdowns and the sample-size rule --------------------------------------------------------


def test_breakdowns_carry_n_and_hide_low_samples(db_session, world):
    rows = {r["key"]: r for r in bi.breakdown(db_session, D1, D2, "niche", now=NOW)}
    assert rows["weddings"]["n"] == 1 and rows["weddings"]["avg_booking"] == {"value": None, "n": 1, "low_sample": True}
    assert rows["weddings"]["take_rate_bp"]["low_sample"] is True
    countries = {r["key"] for r in bi.breakdown(db_session, D1, D2, "country", now=NOW)}
    assert countries == {"PT", "GB"}
    top = bi.breakdown(db_session, D1, D2, "photographer", now=NOW)
    assert [r["label"] for r in top] == ["Pat One", "Sam Two"]


def test_thirty_bookings_give_a_real_average(db_session, world):
    niche = db_session.execute(select(Niche).where(Niche.slug == "family")).scalar_one()
    for _ in range(30):
        _card(db_session, _gig(db_session, world.client, world.p1, niche), "10.00", D1)
    db_session.commit()
    row = {r["key"]: r for r in bi.breakdown(db_session, D1, D2, "niche", now=NOW)}["family"]
    assert row["n"] == 30
    assert row["avg_booking"] == {"value": 1000, "n": 30, "low_sample": False}
    assert row["take_rate_bp"] == {"value": 1500, "n": 30, "low_sample": False}


def test_the_drill_down_lists_the_bookings_behind_a_number(db_session, world):
    page = bi.bookings(db_session, D1, D2, bi.Filters(niche="weddings"))
    assert page["total"] == 1 and page["items"][0]["gig_id"] == str(world.g1.id)
    assert (page["items"][0]["gmv_cents"], page["items"][0]["refund_cents"]) == (11000, 2200)
    page = bi.bookings(db_session, D1, D2, limit=1)
    assert page["total"] == 2 and page["next_offset"] == 1


def test_series_by_day(db_session, world):
    days = bi.series(db_session, D1, D2, "day", now=NOW)
    assert [(d["start"], d["gmv_cents"], d["bookings"]) for d in days] == [("2026-10-05", 11000, 1), ("2026-10-06", 6243, 1)]
    assert days[0]["contribution_cents"] == 1650 - 170


def test_typed_amounts_are_exact():
    from app.core.errors import APIError

    assert bi.euros_to_cents("12.34") == 1234
    with pytest.raises(APIError):
        bi.euros_to_cents("1.234")


def test_days_are_london_days(db_session, world):
    """23:30 UTC on 5 October is 00:30 on the 6th in London (BST)."""
    niche = db_session.execute(select(Niche).where(Niche.slug == "food")).scalar_one()
    gig = _gig(db_session, world.client, world.p1, niche)
    pi = _card(db_session, gig, "1.00", D1)
    db_session.flush()
    db_session.execute(text("UPDATE ledger_entry SET created_at = :t WHERE reference_id = :pi"),
                       {"t": datetime(2026, 10, 5, 23, 30, tzinfo=timezone.utc), "pi": pi})
    db_session.commit()
    days = {d["start"]: d["gmv_cents"] for d in bi.series(db_session, D1, D2, "day", now=NOW)}
    assert days == {"2026-10-05": 11000, "2026-10-06": 6243 + 100}


def test_a_day_mirrored_before_it_ended_says_as_of_when(db_session, world):
    # D2 last mirrored at 14:05 UTC that day (15:05 in London, BST): its
    # Stripe numbers are as of then. D1 was mirrored after it ended.
    db_session.get(BiStripeSyncDay, D2).synced_at = datetime(2026, 10, 6, 14, 5, tzinfo=timezone.utc)
    db_session.commit()
    assert _summary(db_session).meta["stripe_partial_days"] == [{"day": "2026-10-06", "as_of": "15:05"}]


# --- recorded, or estimated (docs/BI.md) --------------------------------------------------------


def test_what_the_world_estimates_is_counted(db_session, world):
    """The world's lines predate the recorded stamps: the refund names no
    payment (base rates), the bookings have no tier at booking (today's),
    the expiry and the adjustment no rate (today's), the orders no cost
    snapshot (the item's, at today's rate)."""
    m = _summary(db_session).meta
    assert m["refund_rate_assumed_cents"] == 2000  # the card refund; credit returned is always base
    assert m["tier_estimated_bookings"] == 2
    assert m["raww_estimated_cents"] == 1000 + 200
    assert m["shelf_cost_estimated_orders"] == 2  # O1, O2 (O3 placed and reversed)
    assert m["shelf_shipping_not_set_orders"] == 0


def test_stripe_s_own_fees_count_as_stripe_fees(db_session, world):
    # Radar, Connect: billed as their own balance transaction, category "fee".
    db_session.add(BiStripeTxn(id="txn_fee", type="stripe_fee", reporting_category="fee", currency="EUR", amount_cents=-500,
                               fee_cents=0, net_cents=-500, created_at=at(D2)))
    db_session.commit()
    v = _summary(db_session).values
    assert v["stripe_fees"] == 309 + 500 and v["contribution"] == 1947 - 500


def test_free_cash_takes_the_raww_outstanding_off_at_face_value_and_at_cost(db_session, world):
    from app.models.reward import RewardBalance

    db_session.add(RewardBalance(user_id=world.client, balance=250))
    db_session.commit()
    o = bi.owed(db_session, {"available_cents": 50000, "pending_cents": 7000, "reason": None})
    liquid = 50000 + 7000 + 170000 - 13671 - 1100
    assert o["raww"]["face_value_cents"] == 1120 * 10  # 1120 RAWW at 0.10
    # Orders with a cost: O1 3600 for 5000; O3 placed and reversed. 0.72 per euro.
    assert o["raww"]["cost_per_face_euro"] == "0.7200" and o["raww"]["at_cost_cents"] == 8064
    assert o["free_cash"] == {"cents": liquid - 11200, "reason": None, "at_cost_cents": liquid - 8064, "at_cost_reason": None}
    assert o["client_credit"]["outstanding_cents"] == 250  # 250 points, informational, not subtracted
    assert o["liquid"]["cents"] == liquid
