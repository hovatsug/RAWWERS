"""Rebuild-all reports how many photographers clients can see, not only how
many profiles it recomputed.

`rows` counts every photographer profile - test accounts, the unfinished and
the unapproved included - so it moves whenever anyone registers, and a
change in it says nothing about what clients see (on dev, 2026-10-14: 159
rows, 42 listed photographers). `listed` counts the photographers
who pass the five gates every client list applies; that is the number a
deploy check compares.
"""
from app.models.admin import KYCStatus
from app.models.discovery import ProPublicIndex
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.services.discovery_index import listed_photographer_count, recompute_all_pro_public_indexes

from tests.test_bookable_time import _pro


def _unlisted(db_session, gate: str):
    """A photographer with an index row who fails exactly one gate."""
    pro = _pro(db_session)  # live: every gate passed
    if gate == "onboarding":
        db_session.get(ProOnboarding, pro.uuid).status = ProOnboardingStatus.ready_for_review
    else:
        row = db_session.get(ProPublicIndex, pro.uuid)
        if gate == "kyc":
            row.kyc_status = KYCStatus.pending
        elif gate == "accepting":
            row.is_accepting_bookings = False
    db_session.commit()
    return pro


def test_listed_counts_only_who_clients_can_see(db_session):
    before = listed_photographer_count(db_session)
    _pro(db_session)
    for gate in ("onboarding", "kyc", "accepting"):
        pro = _unlisted(db_session, gate)
        assert db_session.get(ProPublicIndex, pro.uuid) is not None, "each has an index row all the same"

    assert listed_photographer_count(db_session) == before + 1


def test_rebuild_all_reports_listed_photographers_as_well_as_rows(db_session):
    _pro(db_session)
    _unlisted(db_session, "onboarding")

    result = recompute_all_pro_public_indexes(db_session)
    db_session.commit()

    assert result.listed == listed_photographer_count(db_session)
    assert result.listed < result.rows
