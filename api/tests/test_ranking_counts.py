"""What a photographer is ranked down for: their own cancellations, and
disputes where they were found at fault. Nothing a client did.

ranking_score took 2 points for every cancelled booking - the client's
cancellations included - and 5 for every dispute on the photographer's
bookings, whoever opened it and however it ended. The index's
gigs_cancelled and disputes_count now count only cancelled_by_pro and
disputes with a recorded photographer-fault finding. Everything that reads
them follows: ranking_score, the match score's dispute penalty, the "high
reliability" reason, and the counts on the public profile.

Fault events are read here for this count, and by the lost-chargeback policy;
nowhere else.
"""
import uuid
from decimal import Decimal
from pathlib import Path

import pytest
from app.models.admin import Dispute, DisputeCategory, DisputeStatus, ProFaultEvent
from app.models.discovery import ProPublicIndex
from app.models.gig import Gig, GigStatus
from app.services.discovery_index import recompute_pro_public_index

from tests.test_refund_routes import _account


def _pro(db_session) -> uuid.UUID:
    return uuid.UUID(_account(db_session))


def _gig(db_session, pro, status, client=None) -> Gig:
    gig = Gig(
        client_user_id=client or uuid.UUID(_account(db_session)), pro_user_id=pro, status=status, currency="EUR",
        amount_minimum=Decimal("100.00"), amount_platform_fee=Decimal("20.00"), amount_pro_gross=Decimal("80.00"), meta={},
    )
    db_session.add(gig)
    db_session.flush()
    return gig


def _dispute(db_session, gig, status=DisputeStatus.resolved_refund, opened_by=None) -> Dispute:
    dispute = Dispute(
        gig_id=gig.id, opened_by_user_id=opened_by or gig.client_user_id, against_user_id=gig.pro_user_id, status=status,
        category=DisputeCategory.no_show, currency="EUR", summary="x", resolution={}, meta={},
    )
    db_session.add(dispute)
    db_session.flush()
    return dispute


def _index(db_session, pro) -> ProPublicIndex:
    recompute_pro_public_index(db_session, pro)
    db_session.commit()
    db_session.expire_all()
    return db_session.get(ProPublicIndex, pro)


def _baseline(db_session):
    pro = _pro(db_session)
    for _ in range(3):
        _gig(db_session, pro, GigStatus.completed)
    db_session.commit()
    row = _index(db_session, pro)
    return pro, row.ranking_score


def test_a_client_cancelling_does_not_count_against_the_photographer(db_session):
    pro, before = _baseline(db_session)

    _gig(db_session, pro, GigStatus.cancelled_by_client)
    db_session.commit()

    row = _index(db_session, pro)
    assert row.gigs_cancelled == 0
    assert row.ranking_score == before


def test_a_photographer_cancelling_still_counts(db_session):
    pro, before = _baseline(db_session)

    _gig(db_session, pro, GigStatus.cancelled_by_pro)
    db_session.commit()

    row = _index(db_session, pro)
    assert row.gigs_cancelled == 1
    assert row.ranking_score == before - 2


@pytest.mark.parametrize("status", list(DisputeStatus))
def test_a_dispute_without_a_fault_finding_does_not_count(db_session, status):
    pro, before = _baseline(db_session)
    gig = _gig(db_session, pro, GigStatus.disputed)
    _dispute(db_session, gig, status=status)
    db_session.commit()

    row = _index(db_session, pro)
    assert row.disputes_count == 0
    assert row.ranking_score == before


def test_a_dispute_with_a_fault_finding_counts(db_session):
    pro, before = _baseline(db_session)
    gig = _gig(db_session, pro, GigStatus.completed)
    dispute = _dispute(db_session, gig)
    db_session.add(ProFaultEvent(pro_user_id=pro, gig_id=gig.id, dispute_id=dispute.id, kind="dispute_at_fault", severity="medium"))
    db_session.commit()

    row = _index(db_session, pro)
    assert row.disputes_count == 1
    assert row.ranking_score == before - 5 + 1, "one more completed gig, one fault-found dispute"


def test_only_a_dispute_at_fault_finding_counts(db_session):
    """Other kinds of finding, on another dispute, are not this count."""
    pro, before = _baseline(db_session)
    gig = _gig(db_session, pro, GigStatus.completed)
    dispute, other = _dispute(db_session, gig), _dispute(db_session, gig)
    db_session.add(ProFaultEvent(pro_user_id=pro, gig_id=gig.id, dispute_id=dispute.id, kind="dispute_at_fault", severity="medium"))
    db_session.add(ProFaultEvent(pro_user_id=pro, gig_id=gig.id, dispute_id=other.id, kind="late_delivery_noted", severity="low"))
    db_session.commit()

    assert _index(db_session, pro).disputes_count == 1


def test_fault_events_are_read_in_one_place_only():
    root = Path(__file__).resolve().parents[1] / "app"
    readers = {
        str(path.relative_to(root))
        for path in root.rglob("*.py")
        if "ProFaultEvent" in path.read_text()
    }
    # The model, its registration, two writers, and two readers: this
    # count, and the lost-chargeback policy (a finding decides whether the
    # photographer's earnings are reversed - services/chargebacks.py). The
    # second writer, services/accountability.py, records non-delivery
    # findings in effect as kind non_delivery_at_fault, which this count does
    # not count: strikes, warnings and pauses never feed ranking.
    assert readers == {
        "models/admin.py", "db/base.py", "services/disputes.py", "services/discovery_index.py", "services/chargebacks.py",
        "services/accountability.py",
    }
