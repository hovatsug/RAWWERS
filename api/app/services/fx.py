"""Exchange rates for display and reporting, never for money
(docs/MULTI_CURRENCY.md 4, decision M8).

- **Source:** the European Central Bank's euro reference rates
  (eurofxref-daily.xml: free, no key, published once on working days around
  16:00 CET). Refreshed every hour by the beat (`fx_refresh`), which keeps
  the newest publication: one real change a working day.
- **Stored** in `fx_rate`, one row per (currency, publication day), quoted
  as units of the currency per euro. Nothing is ever converted on the money
  path: a charge, hold, refund and transfer are all in the photographer's
  currency.
- **At most 4 days old** (weekends and holidays). Older, or none: there is
  no rate, the API sends none, and the apps show only the charged amount
  with "Charged in EUR". The job raises a Sentry event when the newest is
  older than that.
- **GBP to EUR** is the inverse of the stored EUR to GBP, at full
  precision, rounded only at the end.
- **Display conversion** (4.3): the charged amount in minor units times the
  rate, rounded half up to a whole minor unit; shown to the whole unit from
  20.00 up, to the minor unit below. An approximation is never summed.
"""
from __future__ import annotations

import logging
import xml.etree.ElementTree as ET
from datetime import date, datetime, timedelta, timezone
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import select
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.orm import Session

logger = logging.getLogger(__name__)

BASE_CURRENCY = "EUR"
SOURCE = "ecb"
ECB_DAILY_URL = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
#: The oldest rate still used (weekends and holidays): older is no rate.
MAX_AGE_DAYS = 4
_ECB_NS = {"gesmes": "http://www.gesmes.org/xml/2002-08-01", "ecb": "http://www.ecb.int/vocabulary/2002-08-01/eurofxref"}


def _today() -> date:
    from app.services.bi import london_today

    return london_today()


def latest(db: Session, currency: str):
    """The newest stored rate for `currency`, fresh or not."""
    from app.models.fx import FxRate

    return db.execute(
        select(FxRate).where(FxRate.base == BASE_CURRENCY, FxRate.quote == currency).order_by(FxRate.as_of.desc()).limit(1)
    ).scalar_one_or_none()


def is_fresh(as_of: date, today: date | None = None) -> bool:
    return ((today or _today()) - as_of).days <= MAX_AGE_DAYS


def rate_from_base(db: Session | None, currency: str) -> Decimal | None:
    """Units of `currency` per euro, or None when no rate at most
    MAX_AGE_DAYS old is known."""
    if currency == BASE_CURRENCY:
        return Decimal("1")
    if db is None:
        return None
    row = latest(db, currency)
    if row is None or not is_fresh(row.as_of):
        return None
    return Decimal(row.rate)


def to_base_minor(db: Session | None, amount: Decimal | None, currency: str) -> int | None:
    """`amount` of `currency` in euro cents (half up), or None."""
    if amount is None:
        return None
    rate = rate_from_base(db, currency)
    if rate is None:
        return None
    return int((Decimal(amount) * Decimal(100) / rate).quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def convert_minor(amount_minor: int, from_currency: str, to_currency: str, *, rate_to_quote: Decimal) -> int:
    """A display conversion: `amount_minor` of one currency in minor units of
    the other, rounded half up once. `rate_to_quote` is units of the quote
    currency (not the euro) per euro; euros to it multiply, it to euros
    divides, at full precision."""
    if from_currency == to_currency:
        return int(amount_minor)
    if from_currency == BASE_CURRENCY:
        value = Decimal(int(amount_minor)) * rate_to_quote
    elif to_currency == BASE_CURRENCY:
        value = Decimal(int(amount_minor)) / rate_to_quote
    else:
        raise ValueError("display conversions are to or from the euro")
    return int(value.quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def rates_view(db: Session) -> dict:
    """What GET /v1/fx/rates sends: only rates fresh enough to show, all
    from the newest publication among them."""
    from app.services.currencies import SUPPORTED

    rates: dict[str, str] = {}
    as_of: date | None = None
    for currency in sorted(SUPPORTED):
        if currency == BASE_CURRENCY:
            continue
        row = latest(db, currency)
        if row is None or not is_fresh(row.as_of):
            continue
        rates[currency] = f"{Decimal(row.rate):.8f}"
        as_of = row.as_of if as_of is None or row.as_of > as_of else as_of
    return {"base": BASE_CURRENCY, "rates": rates, "as_of": as_of}


# --- the ECB job ---------------------------------------------------------------------------


def parse_ecb_daily(xml_text: str) -> tuple[date, dict[str, Decimal]]:
    """(publication day, {currency: units per euro}) from eurofxref-daily.xml."""
    root = ET.fromstring(xml_text)
    day_cube = root.find(".//ecb:Cube/ecb:Cube[@time]", _ECB_NS)
    if day_cube is None:
        raise ValueError("no dated Cube in the ECB file")
    as_of = date.fromisoformat(day_cube.attrib["time"])
    rates = {}
    for cube in day_cube.findall("ecb:Cube[@currency]", _ECB_NS):
        rate = Decimal(cube.attrib["rate"])
        if rate <= 0:
            raise ValueError(f"a non-positive rate for {cube.attrib['currency']}")
        rates[cube.attrib["currency"].upper()] = rate
    return as_of, rates


def fetch_ecb_daily(timeout: float = 15.0) -> str:
    import httpx

    response = httpx.get(ECB_DAILY_URL, timeout=timeout, headers={"User-Agent": "rawwers-fx/1"})
    response.raise_for_status()
    return response.text


def store_rates(db: Session, as_of: date, rates: dict[str, Decimal]) -> int:
    """Keep the supported currencies' rates of one publication; a day already
    stored is left as it is. Returns how many rows were new."""
    from app.models.fx import FxRate
    from app.services.currencies import SUPPORTED

    new = 0
    for currency, rate in sorted(rates.items()):
        if currency not in SUPPORTED or currency == BASE_CURRENCY:
            continue
        result = db.execute(
            insert(FxRate)
            .values(base=BASE_CURRENCY, quote=currency, rate=rate, as_of=as_of, fetched_at=datetime.now(timezone.utc), source=SOURCE)
            .on_conflict_do_nothing(index_elements=["base", "quote", "as_of"])
        )
        new += int(result.rowcount or 0)
    db.flush()
    return new


def refresh_rates(db: Session, *, fetch=fetch_ecb_daily, today: date | None = None) -> dict:
    """The hourly job: fetch, store, then bring what depends on the rate in
    line (the discovery index's euro values; RAWW of bookings in pounds that
    were waiting for a rate). A fetch that fails changes nothing. Raises a
    Sentry event when the newest stored rate is older than MAX_AGE_DAYS."""
    from app.core.sentry import capture_message
    from app.services.currencies import SUPPORTED

    stored = 0
    error = None
    try:
        as_of, rates = parse_ecb_daily(fetch())
        stored = store_rates(db, as_of, rates)
    except Exception as exc:  # the network or the file: tried again next hour
        error = type(exc).__name__
        logger.warning("fx_refresh_failed", extra={"error": error})

    stale = []
    for currency in sorted(c for c in SUPPORTED if c != BASE_CURRENCY):
        row = latest(db, currency)
        if row is None or not is_fresh(row.as_of, today):
            stale.append(currency)
    if stale:
        logger.error("fx_rate_stale", extra={"currencies": stale})
        capture_message("Exchange rate older than 4 days", tags={"component": "fx"}, extra={"currencies": stale, "error": error})

    reindexed = reindex_base_prices(db)
    revalued = value_waiting_raww(db)
    return {"stored": stored, "stale": stale, "error": error, "reindexed": reindexed, "raww_valued": revalued}


def reindex_base_prices(db: Session) -> int:
    """Every non-euro row of the discovery index gets its cheapest price's
    euro value at today's rate (null when there is none)."""
    from app.models.discovery import ProPublicIndex

    rows = db.execute(select(ProPublicIndex).where(ProPublicIndex.currency != BASE_CURRENCY)).scalars().all()
    changed = 0
    for row in rows:
        value = to_base_minor(db, row.min_package_price, row.currency)
        if value != row.min_package_price_base_minor:
            row.min_package_price_base_minor = value
            changed += 1
    db.flush()
    return changed


def value_waiting_raww(db: Session, *, limit: int = 500) -> int:
    """Bookings in a currency other than the euro that earned RAWW while no
    value for it was known (no pound value set, no rate): valued now
    (raww_earning.sync_booking_raww, decision M5)."""
    from app.models.gig import Gig, GigStatus
    from app.models.payouts import EarningsLedgerEntry, EarningsSourceType
    from app.models.shelf import ProRawwLedgerEntry
    from app.services.raww_earning import sync_booking_raww

    waiting = db.execute(
        select(Gig)
        .join(
            EarningsLedgerEntry,
            (EarningsLedgerEntry.source_id == Gig.id) & (EarningsLedgerEntry.source_type == EarningsSourceType.gig_base),
        )
        .where(
            Gig.currency != BASE_CURRENCY,
            Gig.status == GigStatus.completed,
            Gig.final_pro_raww.is_not(None),
            ~select(ProRawwLedgerEntry.id).where(ProRawwLedgerEntry.gig_id == Gig.id).exists(),
        )
        .limit(limit)
    ).scalars().all()
    valued = 0
    for gig in waiting:
        sync_booking_raww(db, gig)
        if db.execute(select(ProRawwLedgerEntry.id).where(ProRawwLedgerEntry.gig_id == gig.id).limit(1)).first():
            valued += 1
    db.flush()
    return valued


def stale_cutoff(today: date | None = None) -> date:
    return (today or _today()) - timedelta(days=MAX_AGE_DAYS)
