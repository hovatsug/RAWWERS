"""Self-service refunds are off outside development, and in development
follow the interim rule until the platform cancellation standard replaces
them.

Off outside dev: the client refund route answers 403 and asks Stripe for
nothing. The interim rule, where it is on: a refund is possible until the
earlier of 24 hours after paying and the shoot's start, and never once the
photographer has shown the client a gallery.
"""
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import uuid

import pytest
from app.core.config import get_settings
from app.models.gallery import ProofGallery, ProofGalleryStatus
from app.services.auth_tokens import create_access_token

from tests.test_refund_routes import _paid_booking, _refund, stripe_refunds  # noqa: F401 - fixture


@pytest.mark.parametrize("environment", ["production", "staging", "prod"])
def test_outside_development_the_client_cannot_refund_themselves(client, db_session, stripe_refunds, monkeypatch, environment):
    gig, client_id, _pro = _paid_booking(db_session)
    monkeypatch.setattr(get_settings(), "app_env", environment)
    # Production accepts no X-User-Id header: sign in as the client does there.
    token, _ttl = create_access_token(user_id=uuid.UUID(client_id), roles=["client"])

    resp = client.post(
        f"/v1/gigs/{gig.id}/refunds/stripe",
        headers={"Authorization": f"Bearer {token}"},
        json={"reason": "Plans changed"},
    )

    assert resp.status_code == 403, resp.text
    assert resp.json()["error"]["code"] == "self_service_refunds_off"
    assert stripe_refunds.calls == []


@pytest.mark.parametrize("environment", ["development", "dev", "local", "test"])
def test_in_development_it_is_still_possible(client, db_session, stripe_refunds, monkeypatch, environment):
    gig, client_id, _pro = _paid_booking(db_session)
    monkeypatch.setattr(get_settings(), "app_env", environment)

    assert _refund(client, gig, client_id).status_code == 200


def test_not_once_the_shoot_has_started_even_within_a_day_of_paying(client, db_session, stripe_refunds):
    """A short-notice shoot can start two hours after payment; the 24 hours
    must not outlive it."""
    gig, client_id, _pro = _paid_booking(db_session, paid_hours_ago=3)
    gig.scheduled_start = datetime.now(timezone.utc) - timedelta(minutes=5)
    gig.scheduled_end = gig.scheduled_start + timedelta(hours=1)
    db_session.commit()

    resp = _refund(client, gig, client_id)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "refund_not_allowed"
    assert stripe_refunds.calls == []


def test_up_to_the_shoot_start_when_that_comes_first(client, db_session, stripe_refunds):
    gig, client_id, _pro = _paid_booking(db_session, paid_hours_ago=3)
    gig.scheduled_start = datetime.now(timezone.utc) + timedelta(minutes=30)
    gig.scheduled_end = gig.scheduled_start + timedelta(hours=1)
    db_session.commit()

    assert _refund(client, gig, client_id).status_code == 200


@pytest.mark.parametrize("status", [ProofGalleryStatus.published, ProofGalleryStatus.selection_submitted, ProofGalleryStatus.delivered])
def test_not_once_the_client_has_been_shown_a_gallery(client, db_session, stripe_refunds, status):
    gig, client_id, pro_id = _paid_booking(db_session)
    db_session.add(
        ProofGallery(
            gig_id=gig.id,
            pro_user_id=gig.pro_user_id,
            client_user_id=gig.client_user_id,
            included_photos=10,
            extra_photo_price=Decimal("8.00"),
            currency="EUR",
            status=status,
        )
    )
    db_session.commit()

    resp = _refund(client, gig, client_id)

    assert resp.status_code == 409, resp.text
    assert stripe_refunds.calls == []


def test_a_draft_gallery_the_client_cannot_see_does_not_count(client, db_session, stripe_refunds):
    gig, client_id, _pro = _paid_booking(db_session)
    db_session.add(
        ProofGallery(
            gig_id=gig.id,
            pro_user_id=gig.pro_user_id,
            client_user_id=gig.client_user_id,
            included_photos=10,
            extra_photo_price=Decimal("8.00"),
            currency="EUR",
            status=ProofGalleryStatus.draft,
        )
    )
    db_session.commit()

    assert _refund(client, gig, client_id).status_code == 200
