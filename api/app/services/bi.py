"""The business dashboard's numbers, computed here once (docs/BI.md).

Everything reads the bi_* views (app/models/bi_views.py), never the money
tables. Two aggregation queries turn the views into daily rows: one per day
and booking dimension (niche, country, tier), one per day for the company
(Stripe, RAWW, the Shelf, payouts). The same two queries fill `bi_daily`
(recompute_days, the nightly job, the backfill) and answer for days that
are not stored yet, so a stored day and a live day cannot disagree.

The last LIVE_DAYS days (Europe/London) are always computed live: their
money is still moving. Older days come from `bi_daily`; a day never stored
is computed live too, and the answer says how many were.

Amounts are integer cents. A number that cannot be computed is None, with
the reason beside it, never 0.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date, datetime, timedelta, timezone
from decimal import ROUND_HALF_UP, Decimal
from zoneinfo import ZoneInfo

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.bi import MARKETING_CATEGORIES

LONDON = ZoneInfo("Europe/London")
#: Today and the two days before it are computed live.
LIVE_DAYS = 3
#: The longest period one request may read.
MAX_READ_DAYS = 731
#: The most days one request may recompute.
MAX_RECOMPUTE_DAYS = 93
#: Fewer items than this and an average or a percentage is "low sample".
LOW_SAMPLE = 30

BOOKING_COLUMNS = (
    "gmv_cents", "gmv_card_cents", "gmv_credit_cents", "refund_cents", "refund_card_cents", "refund_chargeback_cents",
    "refund_credit_cents", "retained_cents", "pro_cash_cents", "pro_raww_cents", "client_raww_cents", "bookings",
    "other_currency_lines", "refund_rate_assumed_cents", "tier_estimated_bookings",
)
COMPANY_COLUMNS = (
    "stripe_fee_cents", "stripe_charge_cents", "stripe_refund_cents", "stripe_dispute_cents", "stripe_transfer_cents",
    "stripe_payout_cents", "payouts_paid_cents", "raww_issued_cents", "raww_reversed_cents", "raww_spent_cents",
    "raww_expired_cents", "raww_adjust_cents", "shelf_orders", "shelf_value_cents", "shelf_cost_cents",
    "shelf_cost_not_set_orders", "shelf_cost_not_set_value_cents", "shelf_cost_estimated_orders", "shelf_order_shipping_cents",
    "shelf_shipping_not_set_orders", "raww_estimated_cents",
)
DIMENSIONS = ("niche", "country", "tier")

BOOKING_AGG_SQL = """
WITH firsts AS (
    SELECT gig_id, min(day) AS first_day FROM bi_lines
    WHERE movement = 'payment' AND kind = 'base' AND currency = 'EUR' GROUP BY gig_id
), l AS (
    SELECT bi_lines.*, f.first_day, bi_lines.currency = 'EUR' AS eur
    FROM bi_lines LEFT JOIN firsts f ON f.gig_id = bi_lines.gig_id
    WHERE bi_lines.day BETWEEN :a AND :b
)
SELECT day, niche, country, tier,
    coalesce(sum(amount_cents) FILTER (WHERE eur AND movement = 'payment'), 0) AS gmv_cents,
    coalesce(sum(amount_cents) FILTER (WHERE eur AND movement = 'payment' AND source = 'card'), 0) AS gmv_card_cents,
    coalesce(sum(amount_cents) FILTER (WHERE eur AND movement = 'payment' AND source = 'credit'), 0) AS gmv_credit_cents,
    -coalesce(sum(amount_cents) FILTER (WHERE eur AND movement = 'refund'), 0) AS refund_cents,
    -coalesce(sum(amount_cents) FILTER (WHERE eur AND movement = 'refund' AND source = 'card'), 0) AS refund_card_cents,
    -coalesce(sum(amount_cents) FILTER (WHERE eur AND movement = 'refund' AND source = 'chargeback'), 0) AS refund_chargeback_cents,
    -coalesce(sum(amount_cents) FILTER (WHERE eur AND movement = 'refund' AND source = 'credit'), 0) AS refund_credit_cents,
    coalesce(sum(retained_cents) FILTER (WHERE eur), 0) AS retained_cents,
    coalesce(sum(pro_cash_cents) FILTER (WHERE eur), 0) AS pro_cash_cents,
    coalesce(sum(pro_raww_cents) FILTER (WHERE eur), 0) AS pro_raww_cents,
    coalesce(sum(client_raww_cents) FILTER (WHERE eur), 0) AS client_raww_cents,
    count(DISTINCT gig_id) FILTER (WHERE eur AND movement = 'payment' AND kind = 'base' AND day = first_day) AS bookings,
    count(*) FILTER (WHERE NOT eur) AS other_currency_lines,
    -coalesce(sum(amount_cents) FILTER (WHERE eur AND movement = 'refund' AND rate_assumed), 0) AS refund_rate_assumed_cents,
    count(DISTINCT gig_id) FILTER (WHERE eur AND movement = 'payment' AND kind = 'base' AND day = first_day AND tier_estimated)
        AS tier_estimated_bookings
FROM l GROUP BY day, niche, country, tier
"""

COMPANY_AGG_SQL = """
WITH days AS (
    SELECT d::date AS day FROM generate_series(CAST(:a AS date), CAST(:b AS date), interval '1 day') AS d
), st AS (
    SELECT day,
        -- Fees on transactions, and Stripe's own fees billed as their own
        -- transactions (Radar, Connect: reporting category "fee").
        sum(fee_cents) - coalesce(sum(amount_cents) FILTER (WHERE reporting_category = 'fee'), 0) AS fee,
        sum(amount_cents) FILTER (WHERE type IN ('charge', 'payment')) AS charge,
        -sum(amount_cents) FILTER (WHERE type IN ('refund', 'payment_refund', 'refund_failure')) AS refund,
        -sum(amount_cents) FILTER (WHERE reporting_category IN ('dispute', 'dispute_reversal')) AS dispute,
        -sum(amount_cents) FILTER (WHERE type IN ('transfer', 'transfer_refund', 'transfer_cancel', 'transfer_failure')) AS transfer,
        -sum(amount_cents) FILTER (WHERE type IN ('payout', 'payout_cancel', 'payout_failure')) AS payout
    FROM bi_stripe WHERE day BETWEEN :a AND :b AND upper(currency) = 'EUR' GROUP BY day
), synced AS (
    SELECT day FROM bi_stripe_sync_day WHERE day BETWEEN :a AND :b
), po AS (
    SELECT paid_day AS day, sum(amount_cents) AS paid FROM bi_payouts
    WHERE status = 'paid' AND paid_day BETWEEN :a AND :b GROUP BY paid_day
), rw AS (
    SELECT day,
        sum(value_cents) FILTER (WHERE kind IN ('earn_booking', 'earn_extras')) AS issued,
        -sum(value_cents) FILTER (WHERE kind IN ('reverse_booking', 'reverse_extras')) AS reversed,
        -sum(value_cents) FILTER (WHERE kind IN ('spend_order', 'refund_order')) AS spent,
        -sum(value_cents) FILTER (WHERE kind = 'expire') AS expired,
        sum(value_cents) FILTER (WHERE kind = 'admin_adjust') AS adjust,
        sum(abs(value_cents)) FILTER (WHERE rate_source = 'current') AS estimated
    FROM bi_raww WHERE day BETWEEN :a AND :b GROUP BY day
), sh AS (
    SELECT day,
        sum(orders) AS orders,
        sum(value_cents) FILTER (WHERE cost_cents IS NOT NULL) AS value,
        sum(cost_cents) AS cost,
        sum(orders) FILTER (WHERE cost_cents IS NULL) AS ns_orders,
        sum(value_cents) FILTER (WHERE cost_cents IS NULL) AS ns_value,
        sum(cost_estimated_orders) AS est_orders,
        sum(shipping_cents) AS shipping,
        sum(shipping_not_set_orders) AS shipping_ns
    FROM bi_shelf WHERE day BETWEEN :a AND :b GROUP BY day
)
SELECT days.day,
    (synced.day IS NOT NULL) AS stripe_synced,
    coalesce(st.fee, 0) AS stripe_fee_cents,
    coalesce(st.charge, 0) AS stripe_charge_cents,
    coalesce(st.refund, 0) AS stripe_refund_cents,
    coalesce(st.dispute, 0) AS stripe_dispute_cents,
    coalesce(st.transfer, 0) AS stripe_transfer_cents,
    coalesce(st.payout, 0) AS stripe_payout_cents,
    coalesce(po.paid, 0) AS payouts_paid_cents,
    coalesce(rw.issued, 0) AS raww_issued_cents,
    coalesce(rw.reversed, 0) AS raww_reversed_cents,
    coalesce(rw.spent, 0) AS raww_spent_cents,
    coalesce(rw.expired, 0) AS raww_expired_cents,
    coalesce(rw.adjust, 0) AS raww_adjust_cents,
    coalesce(sh.orders, 0) AS shelf_orders,
    coalesce(sh.value, 0) AS shelf_value_cents,
    coalesce(sh.cost, 0) AS shelf_cost_cents,
    coalesce(sh.ns_orders, 0) AS shelf_cost_not_set_orders,
    coalesce(sh.ns_value, 0) AS shelf_cost_not_set_value_cents,
    coalesce(sh.est_orders, 0) AS shelf_cost_estimated_orders,
    coalesce(sh.shipping, 0) AS shelf_order_shipping_cents,
    coalesce(sh.shipping_ns, 0) AS shelf_shipping_not_set_orders,
    coalesce(rw.estimated, 0) AS raww_estimated_cents
FROM days
LEFT JOIN st ON st.day = days.day
LEFT JOIN synced ON synced.day = days.day
LEFT JOIN po ON po.day = days.day
LEFT JOIN rw ON rw.day = days.day
LEFT JOIN sh ON sh.day = days.day
"""


# --- days and periods -------------------------------------------------------------------------


def london_today(now: datetime | None = None) -> date:
    return (now or datetime.now(timezone.utc)).astimezone(LONDON).date()


def _check_range(a: date, b: date, cap: int) -> None:
    if b < a:
        raise APIError(code="validation_error", message="The period ends before it starts", status_code=422)
    if (b - a).days + 1 > cap:
        raise APIError(code="validation_error", message=f"At most {cap} days per request", status_code=422)


def period_bounds(period: str | None, start: date | None, end: date | None, now: datetime | None = None) -> tuple[date, date]:
    """today, 7d, 30d, this_month, last_month, or custom (start and end)."""
    today = london_today(now)
    if period in (None, "", "custom"):
        if start is None or end is None:
            if period == "custom":
                raise APIError(code="validation_error", message="A custom period needs a start and an end", status_code=422)
            return today - timedelta(days=29), today
        return start, end
    if period == "today":
        return today, today
    if period == "7d":
        return today - timedelta(days=6), today
    if period == "30d":
        return today - timedelta(days=29), today
    if period == "this_month":
        return today.replace(day=1), today
    if period == "last_month":
        last = today.replace(day=1) - timedelta(days=1)
        return last.replace(day=1), last
    raise APIError(code="validation_error", message="Unknown period", status_code=422)


def previous_period(a: date, b: date) -> tuple[date, date]:
    length = (b - a).days + 1
    return a - timedelta(days=length), a - timedelta(days=1)


# --- daily rows: computed, stored, read -------------------------------------------------------


def compute_rows(db: Session, a: date, b: date) -> list[dict]:
    """The daily rows for [a, b], straight from the views."""
    rows: list[dict] = []
    for r in db.execute(text(BOOKING_AGG_SQL), {"a": a, "b": b}).mappings():
        rows.append({"scope": "booking", **{k: r[k] for k in ("day", *DIMENSIONS, *BOOKING_COLUMNS)}})
    for r in db.execute(text(COMPANY_AGG_SQL), {"a": a, "b": b}).mappings():
        rows.append({"scope": "company", "niche": "-", "country": "-", "tier": "-", "stripe_synced": r["stripe_synced"],
                     **{k: r[k] for k in ("day", *COMPANY_COLUMNS)}})
    for row in rows:
        for k in (*BOOKING_COLUMNS, *COMPANY_COLUMNS):
            row[k] = int(row.get(k) or 0)
        row.setdefault("stripe_synced", False)
    return rows


def recompute_days(db: Session, a: date, b: date) -> int:
    """Replace `bi_daily` for [a, b] with what the views say now.
    Idempotent: the same data gives the same rows. Returns rows written."""
    _check_range(a, b, MAX_RECOMPUTE_DAYS)
    rows = compute_rows(db, a, b)
    db.execute(text("DELETE FROM bi_daily WHERE day BETWEEN :a AND :b"), {"a": a, "b": b})
    if rows:
        columns = ("day", "scope", *DIMENSIONS, *BOOKING_COLUMNS, *COMPANY_COLUMNS, "stripe_synced")
        db.execute(
            text(f"INSERT INTO bi_daily ({', '.join(columns)}, computed_at) VALUES ({', '.join(':' + c for c in columns)}, now())"),
            [{c: row.get(c, 0) for c in columns} for row in rows],
        )
    db.flush()
    return len(rows)


def recompute_range(db: Session, a: date, b: date) -> int:
    """Any range, in chunks (the backfill)."""
    written, cursor = 0, a
    while cursor <= b:
        end = min(b, cursor + timedelta(days=MAX_RECOMPUTE_DAYS - 1))
        written += recompute_days(db, cursor, end)
        cursor = end + timedelta(days=1)
    return written


def _stored_rows(db: Session, a: date, b: date) -> list[dict]:
    columns = ("day", "scope", *DIMENSIONS, *BOOKING_COLUMNS, *COMPANY_COLUMNS, "stripe_synced")
    return [dict(r) for r in db.execute(text(f"SELECT {', '.join(columns)} FROM bi_daily WHERE day BETWEEN :a AND :b"), {"a": a, "b": b}).mappings()]


@dataclass
class Rows:
    rows: list[dict]
    live_days: int
    days: int


def daily_rows(db: Session, a: date, b: date, now: datetime | None = None) -> Rows:
    """[a, b]: stored days from `bi_daily`, the rest computed live."""
    _check_range(a, b, MAX_READ_DAYS)
    live_from = london_today(now) - timedelta(days=LIVE_DAYS - 1)
    stored = _stored_rows(db, a, min(b, live_from - timedelta(days=1))) if a < live_from else []
    stored_days = {r["day"] for r in stored if r["scope"] == "company"}
    stored = [r for r in stored if r["day"] in stored_days]
    wanted = [a + timedelta(days=i) for i in range((b - a).days + 1)]
    missing = [d for d in wanted if d not in stored_days]
    rows = list(stored)
    if missing:
        live = compute_rows(db, min(missing), max(missing))
        missing_set = set(missing)
        rows += [r for r in live if r["day"] in missing_set]
    return Rows(rows=rows, live_days=len(missing), days=len(wanted))


# --- one period -------------------------------------------------------------------------------


@dataclass
class Filters:
    niche: str | None = None
    country: str | None = None
    tier: str | None = None

    @property
    def any(self) -> bool:
        return any((self.niche, self.country, self.tier))

    def keeps(self, row: dict) -> bool:
        return all(getattr(self, d) in (None, row[d]) for d in DIMENSIONS)


@dataclass
class Summary:
    values: dict[str, int | None]
    reasons: dict[str, str] = field(default_factory=dict)
    meta: dict = field(default_factory=dict)


def _sum(rows: list[dict], column: str) -> int:
    return sum(int(r.get(column) or 0) for r in rows)


def costs(db: Session, a: date, b: date) -> dict:
    """Manual costs in [a, b] by kind, EUR only; others counted, not converted."""
    out = {"ad_spend": 0, "marketing": 0, "shelf_shipping": 0, "other": 0, "other_currency_entries": 0, "entries": 0}
    for r in db.execute(
        text("SELECT category, upper(currency) AS currency, sum(amount_cents) AS cents, count(*) AS n FROM bi_costs "
             "WHERE day BETWEEN :a AND :b GROUP BY category, upper(currency)"),
        {"a": a, "b": b},
    ).mappings():
        if r["currency"] != "EUR":
            out["other_currency_entries"] += int(r["n"])
            continue
        out["entries"] += int(r["n"])
        key = r["category"] if r["category"] in (*MARKETING_CATEGORIES, "shelf_shipping") else "other"
        out[key] += int(r["cents"])
    return out


def summarize(db: Session, a: date, b: date, filters: Filters | None = None, now: datetime | None = None) -> Summary:
    """Every number of docs/BI.md for [a, b]."""
    filters = filters or Filters()
    got = daily_rows(db, a, b, now)
    booking = [r for r in got.rows if r["scope"] == "booking" and filters.keeps(r)]
    company = [r for r in got.rows if r["scope"] == "company"]
    v: dict[str, int | None] = {}
    reasons: dict[str, str] = {}
    for column in BOOKING_COLUMNS:
        v[column.removesuffix("_cents")] = _sum(booking, column)
    v["net_gmv"] = v["gmv"] - v["refund"]
    v["client_credit_used"] = v["gmv_credit"] - v["refund_credit"]

    unsynced = sorted(r["day"] for r in company if not r["stripe_synced"])
    not_split = "Not split by niche, country or tier" if filters.any else None

    def company_value(name: str, value: int) -> None:
        if not_split:
            v[name], reasons[name] = None, not_split
        else:
            v[name] = value

    for column in COMPANY_COLUMNS:
        company_value(column.removesuffix("_cents"), _sum(company, column))
    if not not_split and unsynced:
        for name in ("stripe_fee", "stripe_charge", "stripe_refund", "stripe_dispute", "stripe_transfer", "stripe_payout"):
            v[name], reasons[name] = None, f"No Stripe data for {len(unsynced)} day(s), first {unsynced[0].isoformat()}"
    v["stripe_fees"] = v.pop("stripe_fee")
    if v["stripe_fees"] is None:
        reasons["stripe_fees"] = reasons.pop("stripe_fee")

    c = costs(db, a, b)
    company_value("ad_spend", c["ad_spend"])
    company_value("marketing_costs", c["marketing"])
    company_value("shelf_shipping", c["shelf_shipping"])
    company_value("other_costs", c["other"])

    def derived(name: str, parts: list[str], value) -> None:
        missing = [p for p in parts if v.get(p) is None]
        if missing:
            v[name] = None
            reasons[name] = reasons.get(missing[0], f"{missing[0]} is not available")
        else:
            v[name] = value()

    derived("contribution", ["retained", "stripe_fees"], lambda: v["retained"] - v["stripe_fees"])
    derived("marketing_spend", ["ad_spend", "marketing_costs"], lambda: v["ad_spend"] + v["marketing_costs"] + v["client_credit_used"])
    derived("shelf_margin", ["shelf_value", "shelf_cost", "shelf_order_shipping", "shelf_shipping"],
            lambda: v["shelf_value"] - v["shelf_cost"] - v["shelf_order_shipping"] - v["shelf_shipping"])
    derived("breakage", ["raww_expired"], lambda: v["raww_expired"])
    derived(
        "operating_profit",
        ["contribution", "marketing_spend", "other_costs", "shelf_margin", "breakage"],
        lambda: v["contribution"] - v["marketing_spend"] - v["other_costs"] + v["shelf_margin"] + v["breakage"],
    )
    meta = {
        "from": a.isoformat(), "to": b.isoformat(), "days": got.days, "live_days": got.live_days,
        "stripe_unsynced_days": len(unsynced), "stripe_partial_days": stripe_partial_days(db, a, b), "other_currency_lines": v["other_currency_lines"],
        "other_currency_costs": c["other_currency_entries"],
        "shelf_cost_not_set_orders": v.get("shelf_cost_not_set_orders"),
        # Estimated values in the period (docs/BI.md, "Recorded, estimated").
        "refund_rate_assumed_cents": v["refund_rate_assumed"],
        "tier_estimated_bookings": v["tier_estimated_bookings"],
        "raww_estimated_cents": v.get("raww_estimated"),
        "shelf_cost_estimated_orders": v.get("shelf_cost_estimated_orders"),
        "shelf_shipping_not_set_orders": v.get("shelf_shipping_not_set_orders"),
    }
    return Summary(values=v, reasons=reasons, meta=meta)


def stripe_partial_days(db: Session, a: date, b: date) -> list[dict]:
    """Days in [a, b] last mirrored before they ended (today, mostly): their
    Stripe numbers are as of that time, and the page says so."""
    rows = db.execute(text(
        "SELECT day, synced_at FROM bi_stripe_sync_day WHERE day BETWEEN :a AND :b "
        "AND synced_at < ((day + 1)::timestamp AT TIME ZONE 'Europe/London') ORDER BY day"
    ), {"a": a, "b": b}).mappings().all()
    return [{"day": r["day"].isoformat(), "as_of": r["synced_at"].astimezone(LONDON).strftime("%H:%M")} for r in rows]


# --- the waterfall ----------------------------------------------------------------------------


def waterfall(summary: Summary) -> dict:
    """GMV down to operating profit, each step from the summary. The running
    total is checked at the retained fee and at operating profit; a
    difference is reported, never absorbed."""
    v = summary.values
    steps: list[dict] = [{"key": "gmv", "label": "GMV", "kind": "start", "cents": v["gmv"]}]
    running = v["gmv"]
    mismatches: list[dict] = []
    incomplete: str | None = None

    def step(key: str, label: str, cents: int | None, sign: int) -> None:
        nonlocal running, incomplete
        if incomplete:
            return
        if cents is None:
            incomplete = summary.reasons.get(key) or f"{label}: no data"
            return
        running += sign * cents
        steps.append({"key": key, "label": label, "kind": "step", "cents": sign * cents})

    def check(key: str, label: str, reported: int | None) -> None:
        if incomplete or reported is None:
            return
        steps.append({"key": key, "label": label, "kind": "total", "cents": running})
        if running != reported:
            mismatches.append({"at": key, "running_cents": running, "reported_cents": reported, "difference_cents": running - reported})

    step("refund", "Refunds", v["refund"], -1)
    step("pro_cash", "Photographer cash", v["pro_cash"], -1)
    step("pro_raww", "Photographer RAWW credit", v["pro_raww"], -1)
    step("client_raww", "Photographer's credit to client", v["client_raww"], -1)
    check("retained", "Retained fee", v["retained"])
    step("stripe_fees", "Stripe fees", v.get("stripe_fees"), -1)
    check("contribution", "Contribution profit", v.get("contribution"))
    step("client_credit_used", "Client credit used", v["client_credit_used"], -1)
    ads = None if v.get("ad_spend") is None or v.get("marketing_costs") is None else v["ad_spend"] + v["marketing_costs"]
    step("marketing_costs", "Ad spend and marketing costs", ads, -1)
    step("other_costs", "Other costs", v.get("other_costs"), -1)
    step("shelf_margin", "Shelf margin", v.get("shelf_margin"), 1)
    step("breakage", "Breakage (RAWW expired)", v.get("breakage"), 1)
    check("operating_profit", "Operating profit", v.get("operating_profit"))
    return {"steps": steps, "adds_up": not mismatches, "mismatches": mismatches, "incomplete": incomplete}


# --- changes, series, breakdowns --------------------------------------------------------------


def change_bp(current: int | None, previous: int | None) -> int | None:
    """The change in basis points of the previous value; None when there is
    nothing to compare with."""
    if current is None or previous is None or previous == 0:
        return None
    return int((Decimal(current - previous) * 10000 / abs(Decimal(previous))).quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def ratio(numerator: int, denominator: int, scale: int = 1) -> int | None:
    if denominator == 0:
        return None
    return int((Decimal(numerator) * scale / Decimal(denominator)).quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def honest(n: int, value: int | None) -> dict:
    """An average or a percentage, or "low sample" under LOW_SAMPLE items."""
    if n < LOW_SAMPLE:
        return {"value": None, "n": n, "low_sample": True}
    return {"value": value, "n": n, "low_sample": False}


def _bucket(day: date, grain: str) -> date:
    if grain == "week":
        return day - timedelta(days=day.weekday())
    if grain == "month":
        return day.replace(day=1)
    return day


def series(db: Session, a: date, b: date, grain: str, filters: Filters | None = None, now: datetime | None = None) -> list[dict]:
    if grain not in ("day", "week", "month"):
        raise APIError(code="validation_error", message="grain is day, week or month", status_code=422)
    filters = filters or Filters()
    got = daily_rows(db, a, b, now)
    buckets: dict[date, dict] = {}
    for i in range((b - a).days + 1):
        key = _bucket(a + timedelta(days=i), grain)
        buckets.setdefault(key, {"start": key.isoformat(), "gmv_cents": 0, "bookings": 0, "retained_cents": 0,
                                 "stripe_fee_cents": 0, "unsynced": 0})
    for r in got.rows:
        bucket = buckets[_bucket(r["day"], grain)]
        if r["scope"] == "booking" and filters.keeps(r):
            bucket["gmv_cents"] += r["gmv_cents"]
            bucket["bookings"] += r["bookings"]
            bucket["retained_cents"] += r["retained_cents"]
        elif r["scope"] == "company":
            bucket["stripe_fee_cents"] += r["stripe_fee_cents"]
            bucket["unsynced"] += 0 if r["stripe_synced"] else 1
    out = []
    for key in sorted(buckets):
        bucket = buckets[key]
        contribution = None if filters.any or bucket["unsynced"] else bucket["retained_cents"] - bucket["stripe_fee_cents"]
        out.append({"start": bucket["start"], "gmv_cents": bucket["gmv_cents"], "bookings": bucket["bookings"],
                    "retained_cents": bucket["retained_cents"], "contribution_cents": contribution})
    return out


def _group_stats(key: str, label: str, gmv: int, refund: int, retained: int, n: int) -> dict:
    net = gmv - refund
    return {
        "key": key, "label": label, "n": n, "gmv_cents": gmv, "refund_cents": refund, "net_gmv_cents": net,
        "retained_cents": retained,
        "avg_booking": honest(n, ratio(gmv, n)),
        "take_rate_bp": honest(n, ratio(retained, net, 10000) if net else None),
    }


def breakdown(db: Session, a: date, b: date, by: str, filters: Filters | None = None, now: datetime | None = None) -> list[dict]:
    """By niche, country or tier (from the daily rows) or the top 10
    photographers (from the money lines). n is the number of bookings."""
    filters = filters or Filters()
    if by == "photographer":
        _check_range(a, b, MAX_READ_DAYS)
        rows = db.execute(text(f"""
            WITH firsts AS (SELECT gig_id, min(day) AS first_day FROM bi_lines
                            WHERE movement = 'payment' AND kind = 'base' AND currency = 'EUR' GROUP BY gig_id)
            SELECT l.pro_user_id::text AS key, coalesce(max(b.pro_name), 'Unnamed') AS label,
                coalesce(sum(l.amount_cents) FILTER (WHERE l.movement = 'payment'), 0) AS gmv,
                -coalesce(sum(l.amount_cents) FILTER (WHERE l.movement = 'refund'), 0) AS refund,
                coalesce(sum(l.retained_cents), 0) AS retained,
                count(DISTINCT l.gig_id) FILTER (WHERE l.movement = 'payment' AND l.kind = 'base' AND l.day = f.first_day) AS n
            FROM bi_lines l
            JOIN bi_bookings b ON b.gig_id = l.gig_id
            LEFT JOIN firsts f ON f.gig_id = l.gig_id
            WHERE l.day BETWEEN :a AND :b AND l.currency = 'EUR' {_line_filters(filters)}
            GROUP BY l.pro_user_id
            ORDER BY coalesce(sum(l.amount_cents), 0) DESC, l.pro_user_id
            LIMIT 10
        """), {"a": a, "b": b, **_filter_params(filters)}).mappings()
        return [_group_stats(r["key"], r["label"], int(r["gmv"]), int(r["refund"]), int(r["retained"]), int(r["n"])) for r in rows]
    if by not in DIMENSIONS:
        raise APIError(code="validation_error", message="by is niche, country, tier or photographer", status_code=422)
    groups: dict[str, list[int]] = {}
    for r in daily_rows(db, a, b, now).rows:
        if r["scope"] != "booking" or not filters.keeps(r):
            continue
        g = groups.setdefault(r[by], [0, 0, 0, 0, 0])
        g[0] += r["gmv_cents"]
        g[1] += r["refund_cents"]
        g[2] += r["retained_cents"]
        g[3] += r["bookings"]
        g[4] += r["tier_estimated_bookings"]
    # Bookings whose tier is estimated (backfilled): said beside the tier.
    out = [{**_group_stats(k, k, *g[:4]), "tier_estimated_n": g[4]} for k, g in groups.items()]
    return sorted(out, key=lambda x: (-x["net_gmv_cents"], x["key"]))


def _line_filters(filters: Filters, alias: str = "l") -> str:
    return "".join(f" AND {alias}.{d} = :{d}" for d in DIMENSIONS if getattr(filters, d))


def _filter_params(filters: Filters) -> dict:
    return {d: getattr(filters, d) for d in DIMENSIONS if getattr(filters, d)}


# --- drill-down -------------------------------------------------------------------------------


def bookings(db: Session, a: date, b: date, filters: Filters | None = None, pro_user_id: str | None = None,
             offset: int = 0, limit: int = 50) -> dict:
    """The bookings behind a number: their money lines in [a, b]."""
    _check_range(a, b, MAX_READ_DAYS)
    filters = filters or Filters()
    limit = max(1, min(int(limit), 100))
    offset = max(0, int(offset))
    where = f"l.day BETWEEN :a AND :b AND l.currency = 'EUR' {_line_filters(filters)}"
    params = {"a": a, "b": b, **_filter_params(filters)}
    if pro_user_id:
        where += " AND l.pro_user_id::text = :pro"
        params["pro"] = pro_user_id
    total = db.execute(text(f"SELECT count(DISTINCT l.gig_id) FROM bi_lines l WHERE {where}"), params).scalar_one()
    rows = db.execute(text(f"""
        SELECT l.gig_id::text AS gig_id, max(b.pro_name) AS pro_name, max(l.niche) AS niche, max(l.country) AS country,
               max(l.tier) AS tier, bool_or(l.tier_estimated) AS tier_estimated, max(b.status) AS status,
               min(l.day) AS first_day,
               coalesce(sum(l.amount_cents) FILTER (WHERE l.movement = 'payment'), 0) AS gmv_cents,
               -coalesce(sum(l.amount_cents) FILTER (WHERE l.movement = 'refund'), 0) AS refund_cents,
               coalesce(sum(l.retained_cents), 0) AS retained_cents
        FROM bi_lines l JOIN bi_bookings b ON b.gig_id = l.gig_id
        WHERE {where}
        GROUP BY l.gig_id
        ORDER BY gmv_cents DESC, l.gig_id
        OFFSET :offset LIMIT :limit
    """), {**params, "offset": offset, "limit": limit}).mappings()
    items = [{**dict(r), "first_day": r["first_day"].isoformat(), "gmv_cents": int(r["gmv_cents"]),
              "refund_cents": int(r["refund_cents"]), "retained_cents": int(r["retained_cents"])} for r in rows]
    next_offset = offset + limit if offset + limit < total else None
    return {"items": items, "total": int(total), "offset": offset, "limit": limit, "next_offset": next_offset}


# --- reconciliation ---------------------------------------------------------------------------


def reconciliation(summary: Summary) -> dict:
    """Ours against Stripe for the same period. A difference is shown, never
    hidden; without Stripe data the Stripe side is None."""
    v = summary.values

    def line(key: str, label: str, ours: int | None, stripe: int | None, note: str | None = None) -> dict:
        diff = None if ours is None or stripe is None else ours - stripe
        return {"key": key, "label": label, "ours_cents": ours, "stripe_cents": stripe, "difference_cents": diff,
                "matches": diff == 0 if diff is not None else None, "note": note,
                "reason": (summary.reasons.get(f"stripe_{key}") or summary.reasons.get(f"stripe_{key}s")) if stripe is None else None}

    lines = [
        line("charge", "Card payments", v["gmv_card"], v.get("stripe_charge")),
        line("refund", "Card refunds", v["refund_card"], v.get("stripe_refund")),
        line("dispute", "Chargebacks", v["refund_chargeback"], v.get("stripe_dispute")),
        line("transfer", "Payouts to photographers", v.get("payouts_paid"), v.get("stripe_transfer"),
             "Ours: payout requests paid in the period. Stripe: transfers to connected accounts."),
        line("fee", "Stripe fees", None, v.get("stripe_fees"), "We store no fees of our own: Stripe is the only source."),
        line("payout", "Stripe payouts to the bank", None, v.get("stripe_payout"), "Stripe's payouts to the company account."),
    ]
    return {"lines": lines, "all_match": all(x["matches"] for x in lines if x["matches"] is not None),
            "differences": [x["key"] for x in lines if x["matches"] is False]}


# --- money owed and cash now ------------------------------------------------------------------


def owed(db: Session, stripe_balance: dict | None) -> dict:
    """Now: photographer cash owed, clients owed, RAWW outstanding, client
    credit this month, company cash, Stripe's balance, and the liquid view."""
    from app.services import client_credit

    photographers = db.execute(text("""
        WITH e AS (
            SELECT pro_user_id,
                sum(net_cents) FILTER (WHERE status <> 'reversed') AS lifetime,
                sum(net_cents) FILTER (WHERE status = 'pending') AS pending,
                sum(net_cents) FILTER (WHERE status = 'held') AS held
            FROM bi_earnings GROUP BY pro_user_id
        ), p AS (
            SELECT pro_user_id,
                sum(amount_cents) FILTER (WHERE status = 'requested') AS requested,
                sum(allocated_cents) FILTER (WHERE status IN ('approved', 'processing')) AS reserved,
                sum(allocated_cents) FILTER (WHERE status = 'paid') AS paid
            FROM bi_payouts GROUP BY pro_user_id
        ), each AS (
            SELECT coalesce(e.pending, 0) AS pending, coalesce(e.held, 0) AS held,
                   coalesce(e.lifetime, 0) - coalesce(e.pending, 0) - coalesce(e.held, 0) - coalesce(p.paid, 0) AS due,
                   coalesce(p.paid, 0) AS paid
            FROM e LEFT JOIN p ON p.pro_user_id = e.pro_user_id
        )
        SELECT coalesce(sum(pending), 0) AS pending, coalesce(sum(held), 0) AS held,
               coalesce(sum(greatest(due, 0)), 0) AS due, coalesce(sum(greatest(-due, 0)), 0) AS owed_back,
               coalesce(sum(paid), 0) AS paid
        FROM each
    """)).mappings().one()
    pending, held, due = int(photographers["pending"]), int(photographers["held"]), int(photographers["due"])
    owed_photographers = pending + held + due

    clients = db.execute(text(
        "SELECT kind, count(*) AS n, coalesce(sum(amount_cents), 0) AS cents FROM bi_client_owed WHERE currency = 'EUR' GROUP BY kind"
    )).mappings().all()
    owed_clients = sum(int(r["cents"]) for r in clients)

    raww = db.execute(text(
        "SELECT coalesce(sum(amount_raww), 0) AS raww, coalesce(sum(value_cents), 0) AS cents, "
        "count(*) FILTER (WHERE rate IS NULL) AS unvalued, "
        "coalesce(sum(value_cents) FILTER (WHERE rate_source = 'current'), 0) AS at_current FROM bi_raww"
    )).mappings().one()

    cash_rows = db.execute(text("SELECT account, date, upper(currency) AS currency, amount_cents FROM bi_cash ORDER BY account")).mappings().all()
    eur_cash = [r for r in cash_rows if r["currency"] == "EUR"]
    company_cash = sum(int(r["amount_cents"]) for r in eur_cash) if eur_cash else None

    # RAWW outstanding at face value (today's admin rate), and at what it
    # would cost us: face value x what Shelf orders have cost per euro of
    # RAWW spent on them, over every order with a cost.
    rate = db.execute(text("SELECT raww_eur_value FROM shelf_settings WHERE id = 1")).scalar()
    face = int((Decimal(int(raww["raww"])) * Decimal(rate) * 100).quantize(Decimal("1"), rounding=ROUND_HALF_UP)) if rate is not None else None
    shelf = db.execute(text(
        "SELECT coalesce(sum(cost_cents), 0) AS cost, coalesce(sum(value_cents), 0) AS value, coalesce(sum(orders), 0) AS n "
        "FROM bi_shelf WHERE cost_cents IS NOT NULL"
    )).mappings().one()
    cost_ratio = Decimal(int(shelf["cost"])) / Decimal(int(shelf["value"])) if int(shelf["value"]) > 0 else None
    at_cost = int((Decimal(face) * cost_ratio).quantize(Decimal("1"), rounding=ROUND_HALF_UP)) if face is not None and cost_ratio is not None else None

    credit = client_credit.budget_view(db)
    stripe_available = stripe_balance.get("available_cents") if stripe_balance else None
    stripe_pending = stripe_balance.get("pending_cents") if stripe_balance else None
    liquid = None
    liquid_reason = None
    if stripe_available is None or stripe_pending is None:
        liquid_reason = (stripe_balance or {}).get("reason") or "Stripe balance unavailable"
    else:
        liquid = stripe_available + stripe_pending + (company_cash or 0) - owed_photographers - owed_clients
        if company_cash is None:
            liquid_reason = "Company cash not set: counts Stripe only"
    free_cash = liquid - face if liquid is not None and face is not None else None
    free_cash_at_cost = liquid - at_cost if liquid is not None and at_cost is not None else None
    free_cash_at_cost_reason = (
        liquid_reason if liquid is None else None if at_cost is not None else "No Shelf order with a cost yet: no cost per RAWW"
    )
    return {
        "photographers": {"in_settlement_cents": pending, "held_cents": held, "due_cents": due,
                          "owed_cents": owed_photographers, "paid_out_cents": int(photographers["paid"]),
                          "owed_back_by_photographers_cents": int(photographers["owed_back"])},
        "clients": {"owed_cents": owed_clients, "items": [{"kind": r["kind"], "n": int(r["n"]), "cents": int(r["cents"])} for r in clients]},
        "raww": {"outstanding_raww": int(raww["raww"]), "outstanding_cents": int(raww["cents"]),
                 "valued_at_current_rate_cents": int(raww["at_current"]), "unvalued_lines": int(raww["unvalued"]),
                 "face_value_cents": face, "rate": str(rate) if rate is not None else None,
                 "at_cost_cents": at_cost, "cost_per_face_euro": str(cost_ratio.quantize(Decimal("0.0001"))) if cost_ratio is not None else None,
                 "cost_orders": int(shelf["n"])},
        "client_credit": {"month": credit["month"], "budget_cents": _cents(credit["budget_eur"]),
                          "used_cents": _cents(credit["used_eur"]), "awarded_cents": _cents(credit["awarded_eur"]),
                          "remaining_cents": _cents(credit["remaining_eur"]),
                          # Awarded and not used yet, all clients: an obligation, not subtracted.
                          "outstanding_cents": _cents(credit["outstanding_eur"])},
        "company_cash": {"total_cents": company_cash,
                         "accounts": [{"account": r["account"], "date": r["date"].isoformat(), "currency": r["currency"],
                                       "amount_cents": int(r["amount_cents"])} for r in cash_rows]},
        "stripe": {"available_cents": stripe_available, "pending_cents": stripe_pending,
                   "reason": (stripe_balance or {}).get("reason")},
        "liquid": {"cents": liquid, "reason": liquid_reason},
        # Liquid minus the RAWW outstanding at face value; and at cost.
        "free_cash": {"cents": free_cash, "reason": liquid_reason if liquid is None else None if face is not None else "No RAWW rate set",
                      "at_cost_cents": free_cash_at_cost, "at_cost_reason": free_cash_at_cost_reason},
    }


def _cents(euros) -> int:
    return int((Decimal(str(euros)) * 100).quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def euros_to_cents(value: Decimal | str) -> int:
    """An admin's typed amount: at most two decimals, never a float."""
    amount = Decimal(str(value))
    if amount != amount.quantize(Decimal("0.01")):
        raise APIError(code="validation_error", message="At most two decimals", status_code=422)
    return int(amount * 100)
