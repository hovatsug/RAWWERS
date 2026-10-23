"""The earnings seed uses the official split, like real bookings.

It took a single rounded 20%, so four seeded photographers' wallets were a
few cents off their invoices. It now passes the booking's own split, and
`--reseed` brings existing seeded entries to it.
"""
from __future__ import annotations

import importlib.util
import uuid
from decimal import Decimal
from pathlib import Path

from app.models.admin import UserAccount
from app.models.gig import Gig, GigStatus
from app.models.payouts import EarningsLedgerEntry, EarningsSourceType
from app.services.payouts import create_earnings_entry

D = Decimal


def _script():
    spec = importlib.util.spec_from_file_location("seed_pro_earnings", Path(__file__).resolve().parents[1] / "scripts" / "seed_pro_earnings.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _gig(db, gross="52.43") -> Gig:
    pro, client = uuid.uuid4(), uuid.uuid4()
    db.add_all([UserAccount(user_id=pro), UserAccount(user_id=client)])
    db.flush()
    gig = Gig(client_user_id=client, pro_user_id=pro, status=GigStatus.completed, currency="EUR", amount_minimum=D(gross),
              amount_platform_fee=D("0.00"), amount_pro_gross=D("0.00"), retained_percent=15, pro_raww_percent=5,
              client_credit_percent=0, meta={"seeded": True})
    db.add(gig)
    db.commit()
    return gig


def _entry(db, gig) -> EarningsLedgerEntry:
    db.expire_all()
    return db.query(EarningsLedgerEntry).filter_by(source_id=gig.id).one()


def test_seeded_earnings_use_the_booking_split(db_session):
    script = _script()
    gig = _gig(db_session)

    script.seed_earnings(db_session, gigs=[gig], settlement_days=7)
    db_session.commit()

    assert (_entry(db_session, gig).net_eur, _entry(db_session, gig).platform_fee_eur) == (D("41.95"), D("10.48"))
    assert script.check_reconciliation(db_session, gigs=[gig]) == []


def test_reseed_brings_an_old_single_20_percent_entry_to_the_split(db_session):
    script = _script()
    gig = _gig(db_session)
    # The old way: one rounded 20%, net 41.94.
    create_earnings_entry(db_session, pro_user_id=gig.pro_user_id, source_type=EarningsSourceType.gig_base, source_id=gig.id, gross_eur=D("52.43"))
    db_session.commit()
    assert _entry(db_session, gig).net_eur == D("41.94")

    changed = script.reseed_earnings(db_session, gigs=[gig])
    db_session.commit()

    assert [(old, new) for _, old, new in changed] == [(D("41.94"), D("41.95"))]
    assert _entry(db_session, gig).net_eur == D("41.95")
    assert script.reseed_earnings(db_session, gigs=[gig]) == []


def test_reconciliation_refuses_an_entry_off_the_split(db_session):
    script = _script()
    gig = _gig(db_session)
    create_earnings_entry(db_session, pro_user_id=gig.pro_user_id, source_type=EarningsSourceType.gig_base, source_id=gig.id, gross_eur=D("52.43"))
    db_session.commit()

    problems = script.check_reconciliation(db_session, gigs=[gig])

    assert len(problems) == 1 and "41.94" in problems[0] and "41.95" in problems[0]
