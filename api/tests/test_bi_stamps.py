"""What the dashboard records instead of estimating (docs/BI.md, "Recorded,
estimated"), and the identities of a refund on a booking paid partly with
client credit."""
import uuid
from datetime import date
from decimal import Decimal

import pytest
from sqlalchemy import select, text, update

from app.models.admin import AdminAuditLog
from app.models.bi import BiStripeSyncDay
from app.models.booking import BookingRequest
from app.models.gig import Gig, LedgerEntry, LedgerEntryType, StripePayment, StripePaymentKind
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.reward import DiscountRedemption, DiscountRedemptionStatus, RedemptionContextType, RewardLedgerEntry
from app.models.shelf import ProRawwLedgerEntry, ShelfItem, ShelfOrder
from app.services import bi, client_credit
from app.services import raww_ledger as ledger
from app.services.gig_builder import build_gig_for_request
from app.services.shelf_settings import shelf_settings

from tests.test_bi import NOW, _card, _gig, _user, at
from tests.test_booking_close import _ensure_account
from tests.test_package_anchor import _package
from tests.test_shelf_admin_orders import H, _placed, _post

D1, D2 = date(2026, 10, 5), date(2026, 10, 6)


def _summary(db):
    return bi.summarize(db, D1, D2, now=NOW)


def _niche(db, slug="weddings"):
    return db.execute(select(Niche).where(Niche.slug == slug)).scalar_one()


def _payment(db, pi):
    db.flush()
    return db.execute(select(StripePayment).where(StripePayment.stripe_payment_intent_id == pi)).scalar_one()


def _refund(db, gig, amount, ref, payment=None):
    db.add(LedgerEntry(gig_id=gig.id, entry_type=LedgerEntryType.refund_succeeded, amount=-Decimal(amount), currency="EUR",
                       reference_type="stripe_refund", reference_id=ref, stripe_payment_id=payment.id if payment else None,
                       created_at=at(D2)))
    db.flush()


# --- a booking paid 90 by card and 10 in client credit, refunded -------------------------------


def _credit_booking(db):
    client, pro = uuid.uuid4(), uuid.uuid4()
    _user(db, client)
    _user(db, pro, pro_country="GB", name="Pro")
    gig = _gig(db, client, pro, _niche(db))  # 15 retained, 5 RAWW, no client credit percent
    payment = _payment(db, _card(db, gig, "90.00", D1))
    db.add(DiscountRedemption(user_id=client, context_type=RedemptionContextType.gig_payment, context_id=gig.id,
                              points_spent=1000, discount_amount=Decimal("10.00"), currency="EUR",
                              status=DiscountRedemptionStatus.applied, created_at=at(D1, 8), updated_at=at(D1)))
    for day in (D1, D2):
        db.add(BiStripeSyncDay(day=day, txn_count=0))
    db.flush()
    return gig, payment


def _refund_with_credit_back(db, gig, payment, amount):
    _refund(db, gig, amount, f"re_{uuid.uuid4().hex[:8]}", payment)
    # The credit goes back the way the refund flow gives it back.
    assert client_credit.return_credit_on_refunds(db, gig=gig)
    db.execute(update(RewardLedgerEntry).where(RewardLedgerEntry.reference_type == "booking_refund").values(created_at=at(D2)))
    db.commit()


def test_a_booking_paid_with_credit_and_refunded_in_full_nets_to_zero(db_session):
    gig, payment = _credit_booking(db_session)
    _refund_with_credit_back(db_session, gig, payment, "90.00")

    s = _summary(db_session)
    v = s.values
    # At the pre-discount price: 100 in, 100 back.
    assert (v["gmv"], v["refund"], v["net_gmv"]) == (10000, 10000, 0)
    assert (v["retained"], v["pro_cash"], v["pro_raww"], v["client_raww"]) == (0, 0, 0, 0)
    assert (v["client_credit_used"], v["marketing_spend"]) == (0, 0)
    assert v["operating_profit"] == 0
    w = bi.waterfall(s)
    assert w["adds_up"] and w["incomplete"] is None
    assert {x["key"]: x["cents"] for x in w["steps"] if x["kind"] == "total"} == {"retained": 0, "contribution": 0, "operating_profit": 0}


def test_a_booking_paid_with_credit_and_half_refunded_nets_to_half(db_session):
    gig, payment = _credit_booking(db_session)
    _refund_with_credit_back(db_session, gig, payment, "45.00")  # half the card: half the credit, 5.00, back

    s = _summary(db_session)
    v = s.values
    assert (v["gmv"], v["refund"], v["refund_card"], v["refund_credit"], v["net_gmv"]) == (10000, 5000, 4500, 500, 5000)
    # 15% of what is left (50.00), at the pre-discount price.
    assert v["retained"] == 750 and v["pro_raww"] == 250 and v["pro_cash"] == 4000
    assert v["client_credit_used"] == 500 and v["marketing_spend"] == 500
    assert v["operating_profit"] == 750 - 500
    w = bi.waterfall(s)
    assert w["adds_up"] and w["incomplete"] is None
    assert {x["key"]: x["cents"] for x in w["steps"] if x["kind"] == "total"} == {"retained": 750, "contribution": 750, "operating_profit": 250}


# --- a refund splits at its payment's rates ------------------------------------------------------


def _refund_lines(db, gig):
    return db.execute(text(
        "SELECT reference, kind, rate_assumed, retained_cents, pro_raww_cents, client_raww_cents, pro_cash_cents "
        "FROM bi_lines WHERE gig_id = :g AND movement = 'refund' ORDER BY reference"
    ), {"g": gig.id}).mappings().all()


def test_an_extras_refund_splits_at_the_extras_rates_and_an_untied_one_at_base_labelled(db_session):
    client, pro = uuid.uuid4(), uuid.uuid4()
    _user(db_session, client)
    _user(db_session, pro, pro_country="GB")
    gig = _gig(db_session, client, pro, _niche(db_session), cc=10)  # base: client credit 10%; extras: none
    _card(db_session, gig, "100.00", D1)
    extras = _payment(db_session, _card(db_session, gig, "10.00", D1, kind=StripePaymentKind.extras, captured=False))
    _refund(db_session, gig, "10.00", "re_a_extras", extras)
    _refund(db_session, gig, "10.00", "re_b_untied")  # written before refunds named their payment
    db_session.commit()

    tied, untied = _refund_lines(db_session, gig)
    assert (tied["kind"], tied["rate_assumed"]) == ("extras", False)
    assert (tied["retained_cents"], tied["pro_raww_cents"], tied["client_raww_cents"], tied["pro_cash_cents"]) == (-150, -50, 0, -800)
    assert (untied["kind"], untied["rate_assumed"]) == ("base", True)
    assert (untied["retained_cents"], untied["pro_raww_cents"], untied["client_raww_cents"], untied["pro_cash_cents"]) == (-150, -50, -100, -700)
    assert _summary(db_session).meta["refund_rate_assumed_cents"] == 1000


def test_an_add_on_refund_is_read_from_its_payment_once(db_session):
    client, pro = uuid.uuid4(), uuid.uuid4()
    _user(db_session, client)
    _user(db_session, pro, pro_country="GB")
    gig = _gig(db_session, client, pro, _niche(db_session))
    _card(db_session, gig, "100.00", D1)
    addon = _payment(db_session, _card(db_session, gig, "12.00", D1, kind=StripePaymentKind.extras, captured=False))
    addon.meta = {"refunds": {
        "re_ok": {"amount": "12.00", "status": "succeeded", "created": at(D2).isoformat()},
        "re_failed": {"amount": "12.00", "status": "failed", "created": at(D2).isoformat()},
    }}
    db_session.commit()

    [line] = _refund_lines(db_session, gig)
    assert (line["reference"], line["kind"], line["rate_assumed"], line["pro_cash_cents"]) == ("re_ok", "extras", False, -960)
    assert _summary(db_session).values["refund"] == 1200

    # The same refund also written as a ledger line: counted once.
    _refund(db_session, gig, "12.00", "re_ok", addon)
    db_session.commit()
    assert len(_refund_lines(db_session, gig)) == 1


# --- RAWW expiries and adjustments carry their rate ------------------------------------------------


def test_an_adjustment_and_an_expiry_keep_the_rate_of_their_day(db_session):
    pro = uuid.uuid4()
    _user(db_session, pro, pro_country="GB")
    settings = shelf_settings(db_session)
    settings.raww_eur_value = Decimal("0.10")
    adjust = ledger.admin_adjust(db_session, pro_user_id=pro, amount=300, note="goodwill", actor_user_id=pro)
    expire = ledger.expire_spendable(db_session, pro_user_id=pro)
    assert (adjust.raww_eur_value, expire.raww_eur_value) == (Decimal("0.10"), Decimal("0.10"))

    settings.raww_eur_value = Decimal("0.25")
    db_session.commit()
    values = dict(db_session.execute(text(
        "SELECT kind, value_cents FROM bi_raww WHERE pro_user_id = :p"), {"p": pro}).all())
    assert values == {"admin_adjust": 3000, "expire": -3000}, "valued at 0.10, not today's 0.25"
    rows = db_session.execute(select(ProRawwLedgerEntry.raww_eur_value).where(ProRawwLedgerEntry.pro_user_id == pro)).scalars().all()
    assert all(r == Decimal("0.10") for r in rows)


# --- Shelf orders carry their cost; shipping is entered -----------------------------------------


def _shelf_line(db, order_id):
    return db.execute(text(
        "SELECT cost_cents, shipping_cents, cost_estimated_orders, shipping_not_set_orders FROM bi_shelf "
        "WHERE order_id = :o AND movement = 'placed'"), {"o": order_id}).mappings().one()


def test_an_order_records_its_cost_and_the_margin_ignores_later_changes(client, db_session):
    settings = shelf_settings(db_session)
    settings.gbp_eur_rate = Decimal("1.2000")
    db_session.commit()
    _, item, order = _placed(client, db_session)  # the item costs 10 GBP

    row = db_session.get(ShelfOrder, uuid.UUID(order["id"]))
    assert (row.supplier_cost, row.supplier_currency, row.cost_eur_rate, row.cost_estimated) == (Decimal("10.00"), "GBP", Decimal("1.2000"), False)

    item = db_session.get(ShelfItem, item.id)
    item.supplier_cost = Decimal("50.00")
    shelf_settings(db_session).gbp_eur_rate = Decimal("2.0000")
    db_session.commit()
    line = _shelf_line(db_session, order["id"])
    assert (line["cost_cents"], line["cost_estimated_orders"]) == (1200, 0), "10 GBP at 1.20, as when placed"


def test_shipping_is_entered_when_it_ships_or_later_and_each_change_is_logged(client, db_session):
    _, _, order = _placed(client, db_session)
    _post(client, order["id"], "ordered", {"supplier_order_ref": "WEX-1"})
    shipped = _post(client, order["id"], "shipped", {"tracking_code": "RM1"}).json()
    assert shipped["shipping_cost_eur"] is None
    assert _shelf_line(db_session, order["id"])["shipping_not_set_orders"] == 1

    url = f"/v1/admin/shelf/orders/{order['id']}/shipping-cost"
    assert client.put(url, headers=H, json={"shipping_cost_eur": "-1"}).status_code == 422
    assert client.put(url, headers=H, json={"shipping_cost_eur": "4.5"}).json()["shipping_cost_eur"] == "4.50"
    line = _shelf_line(db_session, order["id"])
    assert (line["shipping_cents"], line["shipping_not_set_orders"]) == (450, 0)
    [log] = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.action == "shelf_order_shipping_cost")).scalars().all()
    assert (log.meta["before"], log.meta["after"]) == (None, "4.50")
    # The margin takes the order's shipping off.
    today = bi.london_today()
    v = bi.summarize(db_session, today, today).values
    assert v["shelf_order_shipping"] == 450
    assert v["shelf_margin"] == v["shelf_value"] - v["shelf_cost"] - 450 - v["shelf_shipping"]


def test_shipping_can_come_with_the_tracking(client, db_session):
    _, _, order = _placed(client, db_session)
    _post(client, order["id"], "ordered", {"supplier_order_ref": "WEX-1"})
    shipped = _post(client, order["id"], "shipped", {"tracking_code": "RM1", "shipping_cost_eur": "3.20"}).json()
    assert shipped["shipping_cost_eur"] == "3.20"


# --- a booking carries the tier it was made at ----------------------------------------------------


def test_a_booking_records_the_tier_and_a_later_promotion_changes_nothing(db_session):
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    package = _package(db_session, pro_id, slug="weddings")
    skill = ProNicheSkill(pro_user_id=uuid.UUID(pro_id), niche_id=package.niche_id, tier=SkillTier.pro)
    db_session.add(skill)
    db_session.flush()
    from datetime import datetime, timedelta, timezone

    start = datetime.now(timezone.utc) + timedelta(days=3)
    request = BookingRequest(pro_user_id=uuid.UUID(pro_id), client_user_id=uuid.UUID(client_id), package_id=package.id,
                             requested_start=start, requested_end=start + timedelta(hours=1), expires_at=start)
    db_session.add(request)
    db_session.flush()
    gig = build_gig_for_request(db_session, request)
    db_session.add(gig)
    db_session.flush()
    assert (gig.pro_tier, gig.pro_tier_estimated) == ("pro", False)

    skill.tier = SkillTier.elite
    db_session.commit()
    tier, estimated = db_session.execute(text("SELECT tier, tier_estimated FROM bi_bookings WHERE gig_id = :g"), {"g": gig.id}).one()
    assert (tier, estimated) == ("pro", False)

    # A booking with no tier recorded reads today's, labelled.
    db_session.get(Gig, gig.id).pro_tier = None
    db_session.commit()
    tier, estimated = db_session.execute(text("SELECT tier, tier_estimated FROM bi_bookings WHERE gig_id = :g"), {"g": gig.id}).one()
    assert (tier, estimated) == ("elite", True)


# --- an add-on refunded before its refunds were recorded one by one -------------------------------


def _old_addon(db, gig, amount, refunded, updated):
    from app.models.client_rewards_pricing import ExtraImagePurchase

    payment = _payment(db, _card(db, gig, amount, D1, kind=StripePaymentKind.extras, captured=False))
    db.add(ExtraImagePurchase(
        gig_id=gig.id, client_user_id=gig.client_user_id, pro_user_id=gig.pro_user_id, included_images=0, selected_images=3,
        extra_images=3, unit_price_applied=Decimal("4.00"), unit_price_configured=Decimal("4.00"),
        policy_unit_price_min=Decimal("1.00"), subtotal=Decimal(amount), total=Decimal(amount),
        stripe_payment_intent_id=payment.stripe_payment_intent_id, meta={"kind": "selection_addon"},
    ))
    payment.amount_refunded = Decimal(refunded)
    db.flush()
    # The last update is the only date there is.
    db.execute(update(StripePayment).where(StripePayment.id == payment.id).values(updated_at=updated))
    db.commit()
    return payment


def test_an_old_add_on_refund_counts_on_the_payment_s_last_update_marked_estimated(db_session):
    client, pro = uuid.uuid4(), uuid.uuid4()
    _user(db_session, client)
    _user(db_session, pro, pro_country="GB")
    gig = _gig(db_session, client, pro, _niche(db_session))
    _card(db_session, gig, "100.00", D1)
    addon = _old_addon(db_session, gig, "12.00", "12.00", at(D2, 15))

    [line] = db_session.execute(text(
        "SELECT kind, day, date_estimated, rate_assumed, amount_cents, pro_cash_cents FROM bi_lines "
        "WHERE gig_id = :g AND movement = 'refund'"), {"g": gig.id}).mappings().all()
    assert dict(line) == {"kind": "extras", "day": D2, "date_estimated": True, "rate_assumed": False,
                          "amount_cents": -1200, "pro_cash_cents": -960}
    s = _summary(db_session)
    assert (s.values["refund"], s.meta["refund_date_estimated_cents"]) == (1200, 1200)

    # Once Stripe's refunds are on the payment, they are read instead: counted once, not estimated.
    addon.meta = {"refunds": {"re_1": {"amount": "12.00", "status": "succeeded", "created": at(D2).isoformat()}}}
    db_session.commit()
    s = _summary(db_session)
    assert (s.values["refund"], s.meta["refund_date_estimated_cents"]) == (1200, 0)
    assert len(_refund_lines(db_session, gig)) == 1


def test_an_old_add_on_refund_already_in_the_ledger_is_not_counted_again(db_session):
    client, pro = uuid.uuid4(), uuid.uuid4()
    _user(db_session, client)
    _user(db_session, pro, pro_country="GB")
    gig = _gig(db_session, client, pro, _niche(db_session))
    _card(db_session, gig, "100.00", D1)
    addon = _old_addon(db_session, gig, "12.00", "12.00", at(D2, 15))
    _refund(db_session, gig, "12.00", "re_ledger", addon)
    db_session.commit()

    [line] = _refund_lines(db_session, gig)
    assert line["reference"] == "re_ledger"
    assert _summary(db_session).meta["refund_date_estimated_cents"] == 0


# --- shipping: per order only; legacy shelf_shipping costs count, never twice ----------------------


def _legacy_cost(db, day, cents, recurring=False):
    from app.models.bi import BiCost

    row = BiCost(date=day, category="shelf_shipping", amount_cents=cents, recurring=recurring, created_by=uuid.UUID(H["X-User-Id"]))
    db.add(row)
    db.commit()
    return row


def test_the_shelf_shipping_category_is_retired_for_new_entries(client, db_session):
    from tests.test_bi_api import ADMIN as BI_ADMIN

    body = {"date": "2026-10-05", "category": "shelf_shipping", "amount": "7.00"}
    assert client.post("/v1/admin/bi/costs", headers=BI_ADMIN, json=body).status_code == 422
    page = client.get("/v1/admin/bi/costs", headers=BI_ADMIN).json()
    assert "shelf_shipping" not in page["categories"] and page["legacy_categories"] == ["shelf_shipping"]

    # A row already using it stays, labelled legacy, and its amount can be corrected; not its dates.
    legacy = _legacy_cost(db_session, D2, 700)
    [row] = [r for r in client.get("/v1/admin/bi/costs", headers=BI_ADMIN).json()["items"] if r["id"] == str(legacy.id)]
    assert row["legacy"] is True
    url = f"/v1/admin/bi/costs/{legacy.id}"
    assert client.patch(url, headers=BI_ADMIN, json={"amount": "8.00"}).json()["amount_cents"] == 800
    assert client.patch(url, headers=BI_ADMIN, json={"date": "2026-10-07"}).status_code == 422
    # Nothing else may move into it.
    other = client.post("/v1/admin/bi/costs", headers=BI_ADMIN, json={**body, "category": "software"}).json()
    assert client.patch(f"/v1/admin/bi/costs/{other['id']}", headers=BI_ADMIN, json={"category": "shelf_shipping"}).status_code == 422
    # And it still counts.
    assert _summary(db_session).values["shelf_shipping"] == 800


def test_a_recurring_legacy_shipping_cost_stops_on_the_day_it_was_retired(db_session):
    _legacy_cost(db_session, date(2026, 9, 1), 500, recurring=True)
    days = db_session.execute(text("SELECT day FROM bi_costs WHERE category = 'shelf_shipping' ORDER BY day")).scalars().all()
    assert days == [date(2026, 9, 1), date(2026, 10, 1), date(2026, 11, 1)]


def test_shipping_is_never_counted_twice(client, db_session):
    from datetime import datetime, timedelta, timezone

    today = bi.london_today()
    _legacy_cost(db_session, today - timedelta(days=1), 700)
    orders = []
    for _ in range(2):
        _, _, order = _placed(client, db_session)
        _post(client, order["id"], "ordered", {"supplier_order_ref": "WEX-1"})
        _post(client, order["id"], "shipped", {"tracking_code": "RM1"})
        orders.append(order["id"])
    old, new = orders
    # `old` shipped yesterday: its shipping is in the legacy cost.
    row = db_session.get(ShelfOrder, uuid.UUID(old))
    row.shipped_at = datetime.now(timezone.utc) - timedelta(days=1)
    db_session.commit()

    put = lambda o, eur: client.put(f"/v1/admin/shelf/orders/{o}/shipping-cost", headers=H, json={"shipping_cost_eur": eur})  # noqa: E731
    refused = put(old, "5.00")
    assert refused.status_code == 409 and refused.json()["error"]["code"] == "shipping_in_legacy_costs"
    assert put(new, "4.50").status_code == 200
    listed = {o["id"]: o for o in client.get("/v1/admin/shelf/orders", headers=H).json()["items"]}
    assert (listed[old]["shipping_in_legacy_costs"], listed[new]["shipping_in_legacy_costs"]) == (True, False)

    # Even with both somehow recorded, the order's own does not count.
    db_session.get(ShelfOrder, uuid.UUID(old)).shipping_cost_eur = Decimal("5.00")
    db_session.commit()
    old_line, new_line = _shelf_line(db_session, old), _shelf_line(db_session, new)
    assert (old_line["shipping_cents"], old_line["shipping_not_set_orders"]) == (0, 0), "not set is not asked of it either"
    assert new_line["shipping_cents"] == 450
    v = bi.summarize(db_session, today - timedelta(days=1), today).values
    assert (v["shelf_order_shipping"], v["shelf_shipping"]) == (450, 700)
    assert v["shelf_margin"] == v["shelf_value"] - v["shelf_cost"] - 450 - 700

    # Clearing an order's shipping is always allowed.
    assert put(old, None).status_code == 200
