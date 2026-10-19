"""refund_case's model matches the table every environment has.

Migration 0003 created gig_id and requested_by_user_id NOT NULL, and every
database has them so; the model said nullable. The test database is built
from the model, so tests could write refund cases production would refuse -
a seeded duplicate without a gig was what first showed it. Every code path
sets both, so the model now says what the table says.
"""
import uuid
from decimal import Decimal

import pytest
from app.models.admin import RefundCase, RefundCaseStatus
from sqlalchemy.exc import IntegrityError

from tests.test_refund_routes import _paid_booking


@pytest.mark.parametrize("column", ["gig_id", "requested_by_user_id"])
def test_the_model_says_not_null(column):
    assert RefundCase.__table__.c[column].nullable is False


@pytest.mark.parametrize("missing", ["gig_id", "requested_by_user_id"])
def test_a_refund_case_without_it_is_refused(db_session, missing):
    gig, client_id, _pro = _paid_booking(db_session)
    values = dict(
        gig_id=gig.id,
        requested_by_user_id=uuid.UUID(client_id),
        status=RefundCaseStatus.pending,
        amount=Decimal("10.00"),
        currency="EUR",
        meta={},
    )
    values[missing] = None
    db_session.add(RefundCase(**values))

    with pytest.raises(IntegrityError):
        db_session.commit()
    db_session.rollback()
