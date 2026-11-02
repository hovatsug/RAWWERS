"""The older four-level gig consent, beside the new marketing-use consent.

Owner's decision (2026-11-02): the per-photo marketing consents are the only
authority for RAWWERS's own marketing. The older level keeps working for
the photographer's own marketing and for content packs, but no longer
grants RAWWERS anything and no longer pays points for RAWWERS's use - one
reward per booking:
- rawwers_marketing_only pays nothing; both_pro_and_rawwers pays what
  pro_marketing_only pays;
- a booking that already holds consent points earns no more from a change
  of level, and a clawback takes back only what was paid;
- the new grant's credit is reduced by the old consent's net points.
"""
import uuid
from datetime import datetime, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models.admin import UserAccount
from app.models.gig import Gig, GigStatus
from app.models.media_rights import GigConsentLevel, GigUsageConsentEvent
from app.models.reward import RewardLedgerEntry
from app.services.client_rewards_pricing import maybe_award_consent_points, maybe_clawback_consent_points
from app.services.media_rights import can_use_for_marketing, set_gig_consent
from app.services.studioverse import _consent_satisfies


def _gig(db_session):
    client_id, pro_id = uuid.uuid4(), uuid.uuid4()
    db_session.add_all([UserAccount(user_id=client_id), UserAccount(user_id=pro_id)])
    db_session.flush()
    gig = Gig(client_user_id=client_id, pro_user_id=pro_id, status=GigStatus.completed, currency="EUR",
              amount_minimum=Decimal("96.00"), amount_platform_fee=Decimal("19.20"), amount_pro_gross=Decimal("76.80"), meta={})
    db_session.add(gig)
    db_session.commit()
    return gig


def _points(db_session, gig):
    db_session.expire_all()
    return sum(
        e.amount
        for e in db_session.execute(
            select(RewardLedgerEntry).where(RewardLedgerEntry.user_id == gig.client_user_id, RewardLedgerEntry.reference_id.like(f"{gig.id}:%"))
        ).scalars()
    )


def _award(db_session, gig, level):
    entry = maybe_award_consent_points(db_session, gig_id=gig.id, client_user_id=gig.client_user_id, consent_level=level)
    db_session.commit()
    return entry


@pytest.mark.parametrize(
    ("level", "points"),
    [("pro_marketing_only", 80), ("both_pro_and_rawwers", 80), ("rawwers_marketing_only", 0), ("none", 0)],
)
def test_points_are_paid_for_the_photographers_use_only(db_session, level, points):
    gig = _gig(db_session)
    _award(db_session, gig, level)
    assert _points(db_session, gig) == points


def test_moving_to_both_earns_nothing_more(db_session):
    gig = _gig(db_session)
    _award(db_session, gig, "pro_marketing_only")
    _award(db_session, gig, "both_pro_and_rawwers")
    assert _points(db_session, gig) == 80


def _changed(db_session, gig, from_level, to_level):
    db_session.add(GigUsageConsentEvent(gig_id=gig.id, from_level=None, to_level=from_level, actor_user_id=gig.client_user_id, created_at=datetime.now(timezone.utc)))
    db_session.commit()
    entry = maybe_clawback_consent_points(db_session, gig_id=gig.id, client_user_id=gig.client_user_id, from_level=from_level, to_level=to_level)
    db_session.commit()
    return entry


def test_a_clawback_takes_back_only_what_was_paid(db_session):
    gig = _gig(db_session)
    _award(db_session, gig, "both_pro_and_rawwers")
    _changed(db_session, gig, "both_pro_and_rawwers", "pro_marketing_only")
    assert _points(db_session, gig) == 80, "both and photographer-only are worth the same now"

    _changed(db_session, gig, "pro_marketing_only", "none")
    assert _points(db_session, gig) == 0


def test_rawwers_only_to_none_takes_nothing_back(db_session):
    gig = _gig(db_session)
    _award(db_session, gig, "rawwers_marketing_only")
    _changed(db_session, gig, "rawwers_marketing_only", "none")
    assert _points(db_session, gig) == 0


@pytest.mark.parametrize("level", list(GigConsentLevel))
def test_the_old_consent_never_grants_rawwers_its_own_use(db_session, level):
    gig = _gig(db_session)
    set_gig_consent(db_session, gig=gig, actor_user_id=gig.client_user_id, consent_level=level, scope={})
    db_session.commit()
    assert can_use_for_marketing(db_session, gig_id=gig.id, actor="rawwers", channel="instagram") is False


@pytest.mark.parametrize(
    ("level", "allowed"),
    [
        (GigConsentLevel.pro_marketing_only, True),
        (GigConsentLevel.both_pro_and_rawwers, True),
        (GigConsentLevel.rawwers_marketing_only, False),
        (GigConsentLevel.none, False),
    ],
)
def test_the_photographers_own_use_is_unchanged(db_session, level, allowed):
    gig = _gig(db_session)
    set_gig_consent(db_session, gig=gig, actor_user_id=gig.client_user_id, consent_level=level, scope={})
    db_session.commit()
    assert can_use_for_marketing(db_session, gig_id=gig.id, actor="pro", channel="instagram") is allowed


def test_content_packs_read_the_old_level_as_before():
    assert _consent_satisfies(GigConsentLevel.both_pro_and_rawwers, GigConsentLevel.both_pro_and_rawwers)
    assert not _consent_satisfies(GigConsentLevel.pro_marketing_only, GigConsentLevel.both_pro_and_rawwers)
    assert _consent_satisfies(GigConsentLevel.pro_marketing_only, GigConsentLevel.pro_marketing_only)
    assert _consent_satisfies(GigConsentLevel.rawwers_marketing_only, GigConsentLevel.rawwers_marketing_only)


def test_the_new_credit_is_reduced_by_the_old_consents_net_points(db_session):
    from app.services.marketing_consent import _older_consent_points

    gig = _gig(db_session)
    _award(db_session, gig, "pro_marketing_only")
    assert _older_consent_points(db_session, gig, gig.client_user_id) == 80
    _changed(db_session, gig, "pro_marketing_only", "none")
    assert _older_consent_points(db_session, gig, gig.client_user_id) == 0, "clawed back: nothing to deduct"
