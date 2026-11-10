"""Fake business for the business dashboard (docs/BI.md), dev only.

    python scripts/seed_bi_demo.py            # add 90 days of fake business
    python scripts/seed_bi_demo.py --remove   # remove all of it

It adds, over the last 90 days (Europe/London): photographers in several
countries and niches, clients, bookings paid by card and with client
credit, difference and extras payments, refunds and a chargeback,
earnings and paid payouts, RAWW earned, spent on the Shelf and expired,
Shelf orders (one item with no cost), manual costs, company cash, and a
Stripe mirror that matches the card payments (fees about 1.5% + 0.25).
Then it recomputes bi_daily for those days.

Everything it makes is tagged: users under @bi-demo.rawwers.dev, rows with
metadata bi_demo, Stripe rows with demo = true, Shelf items titled
"[demo] ...". --remove deletes exactly those. Running it twice adds
nothing twice: it removes its earlier data first.

Refuses to run when APP_ENV is production. Rows are written directly, not
through the booking flow: they exist for the dashboard's numbers only.
"""
from __future__ import annotations

import argparse
import random
import sys
import uuid
from datetime import datetime, time, timedelta, timezone
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from sqlalchemy import select, text  # noqa: E402

from app.core.config import get_settings  # noqa: E402
from app.db.session import SessionLocal  # noqa: E402
from app.models.admin import MoneyAttentionItem, ProProfile, UserAccount, UserRole, UserRoleType  # noqa: E402
from app.models.bi import BiCompanyCash, BiCost, BiStripeSyncDay, BiStripeTxn  # noqa: E402
from app.models.gig import Gig, GigStatus, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment, StripePaymentKind  # noqa: E402
from app.models.niche import Niche, ProNicheSkill, SkillTier  # noqa: E402
from app.models.payouts import (  # noqa: E402
    EarningsEntryStatus,
    EarningsLedgerEntry,
    EarningsSourceType,
    PayoutAllocation,
    PayoutRequest,
    PayoutRequestStatus,
)
from app.models.reward import (  # noqa: E402
    DiscountRedemption,
    DiscountRedemptionStatus,
    RedemptionContextType,
    RewardEntryType,
    RewardLedgerEntry,
)
from app.models.shelf import ProRawwLedgerEntry, RawwEntryKind, RawwEntryStatus, ShelfItem, ShelfOrder, ShelfOrderStatus  # noqa: E402
from app.services import bi  # noqa: E402
from app.services.commission import split_with_rates  # noqa: E402
from app.services.shelf_orders import cost_snapshot  # noqa: E402
from app.services.shelf_settings import shelf_settings  # noqa: E402

DOMAIN = "bi-demo.rawwers.dev"
TAG = {"bi_demo": True}
DAYS = 90
NAMESPACE = uuid.UUID("6f1c3d1e-4b1a-4e55-9a77-0b1d00b1de00")
PRICES = {  # niche: (low, high) euros
    "weddings": (600, 1500), "portraits": (80, 220), "family": (120, 320),
    "corporate": (200, 650), "events_nightlife": (150, 420), "product": (100, 380),
}
PHOTOGRAPHERS = [
    ("Ava Hart", "GB", "weddings"), ("Ben Cole", "GB", "portraits"), ("Cara Lane", "GB", "family"),
    ("Dan Price", "GB", "corporate"), ("Eve Stone", "GB", "events_nightlife"), ("Finn Wade", "GB", "product"),
    ("Inês Rocha", "PT", "weddings"), ("João Lima", "PT", "portraits"), ("Rita Sousa", "PT", "family"),
    ("Tiago Neves", "PT", "events_nightlife"), ("Lucía Gil", "ES", "weddings"), ("Mateo Ruiz", "ES", "corporate"),
]
TIERS = [SkillTier.rookie, SkillTier.skilled, SkillTier.pro, SkillTier.elite]


def _uid(name: str) -> uuid.UUID:
    return uuid.uuid5(NAMESPACE, name)


def _eur(cents: int) -> Decimal:
    return (Decimal(cents) / 100).quantize(Decimal("0.01"))


def _q(value: Decimal) -> Decimal:
    return value.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def _refuse_in_production() -> None:
    if get_settings().is_production:
        sys.exit("seed_bi_demo refuses to run when APP_ENV is production.")


def remove(db) -> dict:
    """Delete everything the seed made, children first."""
    users = [str(r[0]) for r in db.execute(text("SELECT user_id FROM user_account WHERE email LIKE :d"), {"d": f"%@{DOMAIN}"})]
    gigs = [str(r[0]) for r in db.execute(text("SELECT id FROM gig WHERE metadata ->> 'bi_demo' = 'true'"))]
    counts = {}

    def run(label, sql, **params):
        counts[label] = db.execute(text(sql), params).rowcount

    run("reward_ledger_entry", "DELETE FROM reward_ledger_entry WHERE metadata ->> 'bi_demo' = 'true'")
    run("discount_redemption", "DELETE FROM discount_redemption WHERE context_id = ANY(CAST(:g AS uuid[]))", g=gigs)
    run("ledger_entry", "DELETE FROM ledger_entry WHERE gig_id = ANY(CAST(:g AS uuid[]))", g=gigs)
    run("stripe_payment", "DELETE FROM stripe_payment WHERE gig_id = ANY(CAST(:g AS uuid[]))", g=gigs)
    run("money_attention_item", "DELETE FROM money_attention_item WHERE gig_id = ANY(CAST(:g AS uuid[]))", g=gigs)
    run("payout_allocation", "DELETE FROM payout_allocation WHERE payout_request_id IN (SELECT id FROM payout_request WHERE pro_user_id = ANY(CAST(:u AS uuid[])))", u=users)
    run("payout_request", "DELETE FROM payout_request WHERE pro_user_id = ANY(CAST(:u AS uuid[]))", u=users)
    run("earnings_ledger_entry", "DELETE FROM earnings_ledger_entry WHERE pro_user_id = ANY(CAST(:u AS uuid[]))", u=users)
    run("pro_raww_ledger_entry", "DELETE FROM pro_raww_ledger_entry WHERE pro_user_id = ANY(CAST(:u AS uuid[]))", u=users)
    run("shelf_order", "DELETE FROM shelf_order WHERE pro_user_id = ANY(CAST(:u AS uuid[]))", u=users)
    run("shelf_item", "DELETE FROM shelf_item WHERE title LIKE '[demo] %' AND id NOT IN (SELECT item_id FROM shelf_order)")
    run("gig", "DELETE FROM gig WHERE id = ANY(CAST(:g AS uuid[]))", g=gigs)
    run("pro_niche_skill", "DELETE FROM pro_niche_skill WHERE pro_user_id = ANY(CAST(:u AS uuid[]))", u=users)
    run("pro_profile", "DELETE FROM pro_profile WHERE user_id = ANY(CAST(:u AS uuid[]))", u=users)
    run("user_role", "DELETE FROM user_role WHERE user_id = ANY(CAST(:u AS uuid[]))", u=users)
    run("user_account", "DELETE FROM user_account WHERE user_id = ANY(CAST(:u AS uuid[]))", u=users)
    run("bi_stripe_txn", "DELETE FROM bi_stripe_txn WHERE demo")
    run("bi_stripe_sync_day", "DELETE FROM bi_stripe_sync_day WHERE source = 'demo'")
    run("bi_cost", "DELETE FROM bi_cost WHERE metadata ->> 'bi_demo' = 'true'")
    run("bi_company_cash", "DELETE FROM bi_company_cash WHERE metadata ->> 'bi_demo' = 'true'")
    return counts


class Seeder:
    def __init__(self, db, today):
        self.db, self.today, self.rng = db, today, random.Random(20261109)
        self.start = today - timedelta(days=DAYS - 1)
        self.stripe: list[BiStripeTxn] = []
        self.admin = _uid("admin")
        self.n = 0

    def at(self, day, hour=None):
        hour = self.rng.randint(8, 20) if hour is None else hour
        local = datetime.combine(day, time(hour, self.rng.randint(0, 59)), tzinfo=bi.LONDON)
        return local.astimezone(timezone.utc)

    def txn(self, typ, amount, when, fee=0, category=None):
        self.n += 1
        self.stripe.append(BiStripeTxn(id=f"txn_demo_{self.n:05d}", type=typ, reporting_category=category or typ, currency="EUR",
                                       amount_cents=amount, fee_cents=fee, net_cents=amount - fee, created_at=when,
                                       available_on=when + timedelta(days=7), demo=True))

    def user(self, key, email, role, *, name=None, country=None):
        uid = _uid(key)
        self.db.add(UserAccount(user_id=uid, email=email, display_name=name))
        self.db.flush()
        self.db.add(UserRole(user_id=uid, role=role))
        if role == UserRoleType.pro:
            self.db.add(ProProfile(user_id=uid, display_name=name, country=country))
        return uid

    def card(self, gig, cents, when, kind=StripePaymentKind.base):
        pi = f"pi_demo_{uuid.uuid4().hex[:16]}"
        payment = StripePayment(gig_id=gig.id, kind=kind, client_user_id=gig.client_user_id, status=PaymentStatus.succeeded,
                                stripe_payment_intent_id=pi, amount=_eur(cents), currency="EUR", meta=dict(TAG),
                                created_at=when - timedelta(minutes=2))
        self.db.add(payment)
        if kind != StripePaymentKind.extras:
            self.db.add(LedgerEntry(gig_id=gig.id, entry_type=LedgerEntryType.payment_captured, amount=_eur(cents), currency="EUR",
                                    reference_type="stripe_payment_intent", reference_id=pi, created_at=when))
        self.txn("charge", cents, when, fee=round(cents * 0.015) + 25)
        self.db.flush()
        return payment

    def run(self) -> dict:
        db, rng = self.db, self.rng
        niches = {n.slug: n for n in db.execute(select(Niche)).scalars()}
        settings = shelf_settings(db)
        rate = Decimal(settings.raww_eur_value)
        pros = []
        tier_of: dict[uuid.UUID, str] = {}
        for i, (name, country, niche) in enumerate(PHOTOGRAPHERS):
            uid = self.user(f"pro{i}", f"pro{i}@{DOMAIN}", UserRoleType.pro, name=name, country=country)
            db.add(ProNicheSkill(pro_user_id=uid, niche_id=niches[niche].id, tier=TIERS[i % len(TIERS)]))
            tier_of[uid] = TIERS[i % len(TIERS)].value
            pros.append((uid, niches[niche]))
        clients = [self.user(f"client{i}", f"client{i}@{DOMAIN}", UserRoleType.client) for i in range(40)]
        db.flush()

        gigs = earned = 0
        earnings_by_pro: dict[uuid.UUID, list[tuple[EarningsLedgerEntry, Decimal]]] = {}
        raww_by_pro: dict[uuid.UUID, int] = {}
        for offset in range(DAYS):
            day = self.start + timedelta(days=offset)
            weekend = day.weekday() >= 5
            for _ in range(rng.randint(1, 4) + (1 if weekend else 0)):
                pro, niche = rng.choice(pros)
                low, high = PRICES[niche.slug]
                price = rng.randint(low, high) * 100 + rng.choice((0, 0, 50, 99))
                cc = rng.choice((0, 0, 0, 5, 10))
                paid_at = self.at(day)
                age = (self.today - day).days
                status = GigStatus.completed if age > 10 else rng.choice((GigStatus.paid, GigStatus.scheduled, GigStatus.shoot_done))
                gig = Gig(client_user_id=rng.choice(clients), pro_user_id=pro, niche_id=niche.id, status=status, currency="EUR",
                          amount_minimum=_eur(price), amount_platform_fee=_eur(price * 20 // 100), amount_pro_gross=_eur(price * 80 // 100),
                          fee_percent=20, retained_percent=15, pro_raww_percent=5, client_credit_percent=cc,
                          pro_tier=tier_of[pro], meta=dict(TAG), created_at=paid_at - timedelta(days=rng.randint(1, 5)))
                db.add(gig)
                db.flush()
                gigs += 1
                credit, redemption = 0, None
                if rng.random() < 0.2:
                    credit = min(price // 10, rng.choice((500, 1000, 1500)))
                    redemption = DiscountRedemption(user_id=gig.client_user_id, context_type=RedemptionContextType.gig_payment,
                                              context_id=gig.id, points_spent=credit, discount_amount=_eur(credit), currency="EUR",
                                              status=DiscountRedemptionStatus.applied, created_at=paid_at, updated_at=paid_at)
                    db.add(redemption)
                    db.flush()
                base = self.card(gig, price - credit, paid_at)
                total = price
                if rng.random() < 0.25 and age > 3:
                    diff = rng.randint(2, 12) * 1000
                    self.card(gig, diff, self.at(min(self.today, day + timedelta(days=rng.randint(2, 6)))), StripePaymentKind.difference)
                    total += diff
                if rng.random() < 0.1 and age > 5:
                    extras = rng.randint(1, 6) * 1500
                    self.card(gig, extras, self.at(min(self.today, day + timedelta(days=rng.randint(3, 8)))), StripePaymentKind.extras)
                refunded = 0
                if rng.random() < 0.08 and age > 4:
                    refunded = rng.choice(((price - credit) // 2, price - credit))
                    when = self.at(min(self.today, day + timedelta(days=rng.randint(1, 4))))
                    db.add(LedgerEntry(gig_id=gig.id, entry_type=LedgerEntryType.refund_succeeded, amount=-_eur(refunded),
                                       currency="EUR", reference_type="stripe_refund", reference_id=f"re_demo_{gig.id.hex[:10]}",
                                       stripe_payment_id=base.id, created_at=when))
                    self.txn("refund", -refunded, when)
                    if credit:
                        back = credit if refunded >= price - credit else credit // 2
                        db.add(RewardLedgerEntry(user_id=gig.client_user_id, entry_type=RewardEntryType.adjustment, amount=back,
                                                 balance_after=back, reference_type="booking_refund",
                                                 reference_id=f"{gig.id}:re_demo_{gig.id.hex[:10]}", created_at=when,
                                                 meta={**TAG, "refunded_redemption_id": str(redemption.id)}))
                        refunded += back
                    gig.status = GigStatus.refunded if refunded >= price else gig.status
                if status == GigStatus.completed and gig.status != GigStatus.refunded:
                    split = split_with_rates(_eur(total - refunded), retained_percent=15, pro_raww_percent=5, client_credit_percent=cc)
                    settled = age > 17
                    entry = EarningsLedgerEntry(pro_user_id=pro, source_type=EarningsSourceType.gig_base, source_id=gig.id,
                                                gross_eur=split.gross, platform_fee_eur=_q(split.gross - split.pro_cash),
                                                net_eur=split.pro_cash, status=EarningsEntryStatus.available if settled else EarningsEntryStatus.pending,
                                                available_at=paid_at + timedelta(days=17), meta=dict(TAG), created_at=paid_at + timedelta(days=10))
                    db.add(entry)
                    earnings_by_pro.setdefault(pro, []).append((entry, split.pro_cash))
                    raww = int((split.pro_raww / rate).quantize(Decimal("1"), rounding=ROUND_HALF_UP))
                    if raww:
                        db.add(ProRawwLedgerEntry(pro_user_id=pro, kind=RawwEntryKind.earn_booking, amount=raww,
                                                  status=RawwEntryStatus.spendable, source_type="gig", source_id=f"gig:{gig.id}",
                                                  gig_id=gig.id, raww_eur_value=rate, eur_basis=split.pro_raww,
                                                  created_at=paid_at + timedelta(days=10), meta=dict(TAG)))
                        raww_by_pro[pro] = raww_by_pro.get(pro, 0) + raww
                        earned += raww
        db.flush()

        # One chargeback, lost.
        gig = db.execute(select(Gig).where(Gig.meta["bi_demo"].astext == "true", Gig.status == GigStatus.completed)).scalars().first()
        if gig is not None:
            when = self.at(self.today - timedelta(days=20))
            amount = int(gig.amount_minimum * 100) // 2
            disputed = db.execute(select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.base)).scalars().first()
            db.add(LedgerEntry(gig_id=gig.id, entry_type=LedgerEntryType.chargeback_opened, amount=-_eur(amount), currency="EUR",
                               reference_type="stripe_dispute", reference_id="dp_demo_1",
                               stripe_payment_id=disputed.id if disputed else None, created_at=when))
            self.txn("adjustment", -amount, when, fee=1500, category="dispute")
            db.add(MoneyAttentionItem(kind="client_owed", status="open", gig_id=gig.id, client_user_id=gig.client_user_id,
                                      amount=Decimal("12.50"), currency="EUR"))

        # Weekly payouts of settled earnings, and the bank payout from Stripe.
        payouts = 0
        for week in range(DAYS // 7):
            pay_day = self.start + timedelta(days=week * 7 + 6)
            if pay_day > self.today - timedelta(days=1):
                break
            for pro, entries in earnings_by_pro.items():
                due = [(e, cash) for e, cash in entries if e.available_at.date() <= pay_day and not e.meta.get("paid")]
                if not due or rng.random() < 0.3:
                    continue
                when = self.at(pay_day, 15)
                amount = sum((cash for _, cash in due), Decimal("0.00"))
                request = PayoutRequest(pro_user_id=pro, amount_eur=amount, status=PayoutRequestStatus.paid, requested_at=when - timedelta(days=1),
                                        approved_at=when, paid_at=when, reference=dict(TAG))
                db.add(request)
                db.flush()
                for e, cash in due:
                    db.add(PayoutAllocation(payout_request_id=request.id, earnings_ledger_entry_id=e.id, amount_eur=cash))
                    e.meta = {**e.meta, "paid": True}
                self.txn("transfer", -int(amount * 100), when)
                payouts += 1
            self.txn("payout", -rng.randint(800, 2500) * 100, self.at(pay_day, 18))

        # The Shelf: three items (one with no cost), orders, one cancelled, one expiry.
        items = [
            ShelfItem(title="[demo] Spare battery", category="battery", level=1, price_raww=450, street_price=Decimal("49"),
                      supplier_cost=Decimal("28.00"), supplier_currency="GBP", supplier_name="Demo Supply"),
            ShelfItem(title="[demo] 128GB card", category="card", level=2, price_raww=700, street_price=Decimal("69"),
                      supplier_cost=Decimal("41.50"), supplier_currency="EUR", supplier_name="Demo Supply"),
            ShelfItem(title="[demo] RAWWERS tote", category="merch", level=1, price_raww=200, street_price=Decimal("15"),
                      supplier_cost=Decimal("0"), supplier_currency="GBP", supplier_name="Demo Merch"),
        ]
        db.add_all(items)
        db.flush()
        orders = 0
        for pro, balance in sorted(raww_by_pro.items(), key=lambda kv: -kv[1])[:8]:
            item = rng.choice(items)
            if balance < item.price_raww:
                continue
            placed = self.at(self.today - timedelta(days=rng.randint(2, 40)))
            cancelled = orders == 2
            order = ShelfOrder(pro_user_id=pro, item_id=item.id, client_request_id=uuid.uuid4().hex, title=item.title,
                               supplier_name=item.supplier_name, level=item.level, price_raww=item.price_raww, raww_eur_value=rate,
                               status=ShelfOrderStatus.refunded if cancelled else ShelfOrderStatus.shipped, shipping_address={},
                               country="GB", placed_at=placed, refunded_at=placed + timedelta(days=1) if cancelled else None,
                               shipped_at=None if cancelled else placed + timedelta(days=2),
                               # Recorded as the live flow records them; one shipped order still
                               # without its shipping cost, to show the warning.
                               **cost_snapshot(item, settings),
                               shipping_cost_eur=None if cancelled or orders == 0 else Decimal(rng.choice(("3.20", "4.50", "6.95"))))
            db.add(order)
            db.flush()
            db.add(ProRawwLedgerEntry(pro_user_id=pro, kind=RawwEntryKind.spend_order, amount=-item.price_raww,
                                      status=RawwEntryStatus.spendable, source_type="shelf_order", source_id=str(order.id),
                                      created_at=placed, meta=dict(TAG)))
            if cancelled:
                db.add(ProRawwLedgerEntry(pro_user_id=pro, kind=RawwEntryKind.refund_order, amount=item.price_raww,
                                          status=RawwEntryStatus.spendable, source_type="shelf_order", source_id=str(order.id),
                                          created_at=placed + timedelta(days=1), meta=dict(TAG)))
            orders += 1
        quiet = min(raww_by_pro, key=raww_by_pro.get) if raww_by_pro else None
        if quiet is not None:
            db.add(ProRawwLedgerEntry(pro_user_id=quiet, kind=RawwEntryKind.expire, amount=-min(raww_by_pro[quiet], 150),
                                      status=RawwEntryStatus.spendable, source_type="expiry", source_id="inactive-since:demo",
                                      raww_eur_value=rate, created_at=self.at(self.today - timedelta(days=5)), meta=dict(TAG)))

        # Manual costs and company cash.
        def cost(day, category, euros, note, recurring=False):
            db.add(BiCost(date=day, category=category, amount_cents=int(euros * 100), note=note, recurring=recurring,
                          created_by=self.admin, meta=dict(TAG)))

        for week in range(DAYS // 7 + 1):
            cost(self.start + timedelta(days=week * 7), "ad_spend", rng.randint(60, 180), "Demo: Meta and Google ads")
        cost(self.start, "software", 89, "Demo: tools, monthly", recurring=True)
        cost(self.start + timedelta(days=3), "salaries", 1500, "Demo: contractor, monthly", recurring=True)
        cost(self.start + timedelta(days=20), "marketing", 350, "Demo: launch photoshoot")
        cost(self.start + timedelta(days=45), "legal", 600, "Demo: terms review")
        cost(self.today - timedelta(days=10), "shelf_shipping", 24, "Demo: Shelf shipping")
        balance = 18000_00
        for week in range(DAYS // 7 + 1):
            balance += rng.randint(-1500, 3500) * 100
            db.add(BiCompanyCash(date=self.start + timedelta(days=week * 7), account="Demo bank", amount_cents=balance,
                                 note="Demo balance", created_by=self.admin, meta=dict(TAG)))

        # Stripe: the mirror, and every seeded day marked mirrored.
        db.add_all(self.stripe)
        existing = {r[0] for r in db.execute(select(BiStripeSyncDay.day).where(BiStripeSyncDay.day >= self.start))}
        for offset in range(DAYS):
            day = self.start + timedelta(days=offset)
            if day not in existing:
                db.add(BiStripeSyncDay(day=day, txn_count=0, source="demo"))
        db.flush()
        rows = bi.recompute_range(db, self.start, self.today)
        return {"bookings": gigs, "raww_earned": earned, "payouts": payouts, "shelf_orders": orders,
                "stripe_rows": len(self.stripe), "bi_daily_rows": rows}


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--remove", action="store_true", help="remove the demo data and stop")
    args = parser.parse_args(argv)
    _refuse_in_production()
    db = SessionLocal()
    try:
        today = bi.london_today()
        removed = remove(db)
        if args.remove:
            bi.recompute_range(db, today - timedelta(days=DAYS + 30), today)
            db.commit()
            print("removed:", {k: v for k, v in removed.items() if v})
            return 0
        result = Seeder(db, today).run()
        db.commit()
        print("seeded:", result)
        return 0
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
