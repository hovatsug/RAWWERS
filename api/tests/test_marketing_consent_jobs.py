"""Marketing-use consent: the daily job.

Owner's decisions (2026-11-01/02): a daily job marks consents past their end
date expired (the status changes; nothing is deleted). Thirty days before
the end date the client gets an in-app prompt to renew - once, and not for
a permission already renewed. Email comes later, with Brevo.
"""
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select

from app.models.marketing_consent import MarketingConsent
from app.models.communication import Notification
from app.services import marketing_consent as mc
from app.tasks.celery_app import celery_app
from app.tasks.outbox_tasks import dispatch_outbox_events_task
from tests.test_download_payment_gate import fake_stripe  # noqa: F401
from tests.test_marketing_consent_client import _booking

NOW = datetime(2026, 11, 2, 9, 0, tzinfo=timezone.utc)


def _granted(client, db_session, count=2):
    client_id, gig, assets = _booking(client, db_session)
    rows, _credit = mc.grant(db_session, gig, client_user_id=uuid.UUID(client_id), asset_ids=[uuid.UUID(a) for a in assets[:count]], term_months=12, people_confirmed=True)
    db_session.commit()
    return client_id, rows


def _set_end(db_session, rows, ends_at):
    for row in rows:
        row.ends_at = ends_at
    db_session.commit()


def _prompts(db_session, client_id):
    dispatch_outbox_events_task(limit=100)
    db_session.expire_all()
    return db_session.execute(
        select(Notification).where(Notification.user_id == uuid.UUID(client_id), Notification.type == "marketing_consent.renewal")
    ).scalars().all()


def test_a_consent_past_its_end_is_marked_expired(client, db_session, fake_stripe):
    _client_id, rows = _granted(client, db_session)
    _set_end(db_session, rows[:1], NOW - timedelta(minutes=1))
    _set_end(db_session, rows[1:], NOW + timedelta(days=200))

    assert mc.expire_due(db_session, now=NOW) == 1
    db_session.commit()

    db_session.expire_all()
    first, second = (db_session.get(MarketingConsent, r.id) for r in rows)
    assert (first.status, first.expired_at) == ("expired", NOW)
    assert second.status == "active"


def test_a_withdrawn_consent_is_not_expired_again(client, db_session, fake_stripe):
    client_id, rows = _granted(client, db_session, count=1)
    mc.withdraw(db_session, uuid.UUID(client_id), None)
    _set_end(db_session, rows, NOW - timedelta(days=1))
    assert mc.expire_due(db_session, now=NOW) == 0
    db_session.expire_all()
    assert db_session.get(MarketingConsent, rows[0].id).status == "withdrawn"


def test_thirty_days_before_the_end_the_client_is_prompted_once(client, db_session, fake_stripe):
    client_id, rows = _granted(client, db_session)
    _set_end(db_session, rows, NOW + timedelta(days=29))

    assert mc.send_renewal_prompts(db_session, now=NOW) == 1
    db_session.commit()
    assert mc.send_renewal_prompts(db_session, now=NOW + timedelta(days=1)) == 0
    db_session.commit()

    (prompt,) = _prompts(db_session, client_id)
    assert "2 photos" in prompt.body
    assert prompt.action["url"] == "/account/marketing-permissions"
    db_session.expire_all()
    assert all(db_session.get(MarketingConsent, r.id).renewal_prompted_at is not None for r in rows)


def test_not_prompted_earlier_than_thirty_days(client, db_session, fake_stripe):
    client_id, rows = _granted(client, db_session)
    _set_end(db_session, rows, NOW + timedelta(days=31))
    assert mc.send_renewal_prompts(db_session, now=NOW) == 0
    assert _prompts(db_session, client_id) == []


def test_not_prompted_for_a_permission_already_renewed(client, db_session, fake_stripe):
    client_id, rows = _granted(client, db_session, count=1)
    _set_end(db_session, rows, NOW + timedelta(days=10))
    mc.renew(db_session, uuid.UUID(client_id), [rows[0].id], 12)
    db_session.commit()

    assert mc.send_renewal_prompts(db_session, now=NOW) == 0
    assert _prompts(db_session, client_id) == []


def test_the_job_runs_daily():
    entry = celery_app.conf.beat_schedule["marketing-consent-daily"]
    assert entry["task"] == "app.tasks.scheduled.marketing_consent_daily"
    assert entry["schedule"] == timedelta(days=1)
    assert celery_app.conf.task_routes["app.tasks.scheduled.marketing_consent_daily"] == {"queue": "media"}
