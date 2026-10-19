"""A refund is not a verdict on the photographer, and nothing here ranks.

Every full or partial refund decided on a dispute applied a "quality
penalty" to the photographer - whatever the reason for the refund, goodwill
included - and three or five in 90 days escalated it to "visibility
downrank" and "temporary suspension". Refunds now record nothing against
anyone. When the admin resolving a dispute finds the photographer at fault,
they say so explicitly (actions.photographer_at_fault), and that is recorded
as a photographer-fault event: kept for review, never an input to ranking
or to which rows a photographer appears in.
"""
import uuid
from decimal import Decimal

import pytest
from app.models.admin import ProFaultEvent, ProQualityPenalty, RefundCase, RefundCaseStatus
from app.models.gig import GigStatus
from app.services.discovery_index import _compute_ranking_score
from sqlalchemy import select

from tests.test_refund_caps import _dispute, _resolve, stripe_all  # noqa: F401 - fixture
from tests.test_refund_routes import _paid_booking, stripe_refunds  # noqa: F401 - fixture

ADMIN = "00000000-0000-0000-0000-0000000000aa"


def _resolve_with(client, dispute, decision, actions):
    body = {"decision": decision, "rationale": "Checked", "actions": actions}
    if decision == "partial_refund":
        body["amount"] = "30.00"
    return client.post(f"/v1/admin/disputes/{dispute.id}/resolve", headers={"X-User-Id": ADMIN}, json=body)


def _faults(db_session, pro_id):
    db_session.expire_all()
    return db_session.execute(select(ProFaultEvent).where(ProFaultEvent.pro_user_id == uuid.UUID(pro_id))).scalars().all()


def _penalties(db_session, pro_id):
    return db_session.execute(select(ProQualityPenalty).where(ProQualityPenalty.pro_user_id == uuid.UUID(pro_id))).scalars().all()


@pytest.mark.parametrize("decision", ["full_refund", "partial_refund"])
def test_a_refund_records_nothing_against_the_photographer(client, db_session, stripe_all, decision):
    gig, client_id, pro_id = _paid_booking(db_session, status=GigStatus.disputed)
    dispute = _dispute(db_session, gig, client_id)

    assert _resolve_with(client, dispute, decision, {}).status_code == 200

    assert _penalties(db_session, pro_id) == []
    assert _faults(db_session, pro_id) == []


def test_the_refund_settling_records_nothing_either(client, db_session, stripe_all):
    """The refund's own success used to apply the penalty a second time."""
    from app.services.disputes import finalize_refund_case_success, initiate_refund_case

    gig, client_id, pro_id = _paid_booking(db_session, status=GigStatus.disputed)
    dispute = _dispute(db_session, gig, client_id)
    _resolve_with(client, dispute, "partial_refund", {})
    [case] = db_session.execute(select(RefundCase).where(RefundCase.dispute_id == dispute.id)).scalars().all()
    initiate_refund_case(db_session, case.id)
    db_session.commit()
    finalize_refund_case_success(db_session, stripe_refund_id=db_session.get(RefundCase, case.id).meta["stripe_refund_id"])
    db_session.commit()

    assert db_session.get(RefundCase, case.id).status == RefundCaseStatus.refunded
    assert _penalties(db_session, pro_id) == []
    assert _faults(db_session, pro_id) == []


@pytest.mark.parametrize("decision", ["full_refund", "partial_refund", "no_refund"])
def test_fault_is_recorded_only_when_the_admin_finds_it(client, db_session, stripe_all, decision):
    gig, client_id, pro_id = _paid_booking(db_session, status=GigStatus.disputed)
    dispute = _dispute(db_session, gig, client_id)

    resp = _resolve_with(client, dispute, decision, {"photographer_at_fault": True, "penalty_severity": "high"})

    assert resp.status_code == 200, resp.text
    [fault] = _faults(db_session, pro_id)
    assert (fault.kind, fault.severity, fault.dispute_id, fault.gig_id) == ("dispute_at_fault", "high", dispute.id, gig.id)
    assert str(fault.recorded_by_user_id) == ADMIN
    assert _penalties(db_session, pro_id) == []


def test_resolving_twice_records_one_fault(client, db_session, stripe_all):
    gig, client_id, pro_id = _paid_booking(db_session, status=GigStatus.disputed)
    dispute = _dispute(db_session, gig, client_id)

    _resolve_with(client, dispute, "no_refund", {"photographer_at_fault": True})
    _resolve_with(client, dispute, "no_refund", {"photographer_at_fault": True})

    assert len(_faults(db_session, pro_id)) == 1


def test_ranking_never_reads_fault_events(db_session):
    """The score is a function of its inputs; fault events are not one."""
    import inspect

    from app.services import discovery_index

    assert not any("fault" in name or "penalt" in name for name in inspect.signature(_compute_ranking_score).parameters)

    source = inspect.getsource(discovery_index)
    assert "ProFaultEvent" not in source and "pro_fault_event" not in source
    assert "ProQualityPenalty" not in source


def test_a_recomputed_index_is_the_same_with_or_without_a_fault(client, db_session, stripe_all):
    from app.models.discovery import ProPublicIndex
    from app.services.discovery_index import recompute_pro_public_index

    gig, client_id, pro_id = _paid_booking(db_session, status=GigStatus.disputed)
    dispute = _dispute(db_session, gig, client_id)
    recompute_pro_public_index(db_session, uuid.UUID(pro_id))
    db_session.commit()
    row = db_session.get(ProPublicIndex, uuid.UUID(pro_id))
    before = (row.ranking_score, row.disputes_count)

    _resolve_with(client, dispute, "full_refund", {"photographer_at_fault": True})
    recompute_pro_public_index(db_session, uuid.UUID(pro_id))
    db_session.commit()
    db_session.expire_all()
    after = db_session.get(ProPublicIndex, uuid.UUID(pro_id))

    assert (after.ranking_score, after.disputes_count) == before
    assert len(_faults(db_session, pro_id)) == 1


def test_a_refunded_dispute_no_longer_lowers_the_niche_skill_score(db_session):
    """Niche skill scoring took 10 points per dispute resolved with a refund
    in 90 days (up to 30). The score sets the niche tier, and the tier feeds
    ranking_score and niche-row order - so refunds ranked photographers."""
    from datetime import datetime, timezone

    from app.models.admin import Dispute, DisputeCategory, DisputeStatus
    from app.models.niche import Niche, ProNicheSkill
    from app.services.niche_skills import recompute_pro_niche_skill

    niche = Niche(slug=f"portraits-{uuid.uuid4().hex[:6]}", name="Portraits")
    db_session.add(niche)
    db_session.flush()
    gig, client_id, pro_id = _paid_booking(db_session, status=GigStatus.completed)
    gig.niche_id = niche.id
    from app.models.gig import Gig

    for _ in range(40):  # enough work for a score well above the penalty
        db_session.add(
            Gig(
                client_user_id=gig.client_user_id, pro_user_id=gig.pro_user_id, niche_id=niche.id, status=GigStatus.completed,
                currency="EUR", amount_minimum=Decimal("100.00"), amount_platform_fee=Decimal("20.00"),
                amount_pro_gross=Decimal("80.00"), meta={},
            )
        )
    db_session.commit()

    def score():
        recompute_pro_niche_skill(db_session, uuid.UUID(pro_id), niche.id)
        db_session.commit()
        db_session.expire_all()
        return db_session.execute(
            select(ProNicheSkill.score).where(ProNicheSkill.pro_user_id == uuid.UUID(pro_id), ProNicheSkill.niche_id == niche.id)
        ).scalar_one()

    before = score()
    assert before >= 20
    for status in (DisputeStatus.resolved_refund, DisputeStatus.resolved_partial_refund):
        db_session.add(
            Dispute(
                gig_id=gig.id, opened_by_user_id=uuid.UUID(client_id), against_user_id=gig.pro_user_id, status=status,
                category=DisputeCategory.no_show, currency="EUR", summary="x", resolution={}, meta={},
                resolved_at=datetime.now(timezone.utc),
            )
        )
    db_session.commit()

    assert score() == before
