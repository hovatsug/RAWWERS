"""Unsubscribe, before any email is sent for real.

The link carries a key id and an HMAC with a server secret (rotatable:
every key listed verifies, the first signs). Opening it changes nothing;
the page's button POSTs, and so does a mail client's one-click
unsubscribe. It writes the person's existing switches: one topic, or all
email except security. Security mail (verification, password reset, a
new sign-in) has no unsubscribe and ignores those switches."""
import hashlib
import uuid
from urllib.parse import parse_qs, urlparse

import pytest
from sqlalchemy import select

from app.models.communication import EmailMessage, Notification, NotificationPreference, NotificationTopicPreference
from app.services import unsubscribe
from app.services.notifications import enqueue_notification
from app.tasks.outbox_tasks import dispatch_outbox_events_task

from tests.test_notifications_v1 import _ensure_user


def _params(url):
    return {k: v[0] for k, v in parse_qs(urlparse(url).query).items()}


def _user(db, email=None):
    user = uuid.uuid4()
    _ensure_user(db, user, email or f"{user.hex[:8]}@example.com")
    return user


def _topic_pref(db, user, topic):
    db.expire_all()
    return db.execute(
        select(NotificationTopicPreference).where(NotificationTopicPreference.user_id == user, NotificationTopicPreference.topic == topic)
    ).scalars().all()


def test_the_link_names_its_key_and_opening_it_changes_nothing(client, db_session):
    user = _user(db_session)
    link = unsubscribe.page_url(user, "booking")
    params = _params(link)

    assert link.startswith(f"{unsubscribe.settings.app_public_url.rstrip('/')}/unsubscribe?")
    assert set(params) == {"u", "t", "k", "s"} and params["t"] == "booking" and params["k"]

    resp = client.get("/v1/email/unsubscribe", params=params)

    assert resp.status_code == 200
    assert resp.json()["topic"] == "booking" and resp.json()["topic_label"] == "bookings"
    assert _topic_pref(db_session, user, "booking") == [], "a GET writes nothing"


def test_a_forged_signature_is_refused(client, db_session):
    user = _user(db_session)
    # The old scheme: an unkeyed hash anyone could compute from the user id.
    forged = hashlib.sha256(f"{user}:booking".encode()).hexdigest()[:24]
    params = {**_params(unsubscribe.page_url(user, "booking")), "s": forged}

    assert client.get("/v1/email/unsubscribe", params=params).status_code == 400
    assert client.post("/v1/email/unsubscribe", params=params).status_code == 400
    assert _topic_pref(db_session, user, "booking") == []


def test_a_signature_for_one_topic_does_not_work_for_another(client, db_session):
    user = _user(db_session)
    params = {**_params(unsubscribe.page_url(user, "booking")), "t": "payments"}

    assert client.post("/v1/email/unsubscribe", params=params).status_code == 400


def test_the_button_stops_that_topic_by_email_and_leaves_the_app(client, db_session):
    user = _user(db_session)

    resp = client.post("/v1/email/unsubscribe", params=_params(unsubscribe.page_url(user, "booking")))

    assert resp.status_code == 200 and resp.json() == {"topic": "booking", "unsubscribed": True}
    [pref] = _topic_pref(db_session, user, "booking")
    assert (pref.email_enabled, pref.inapp_enabled) == (False, True)

    enqueue_notification(db_session, user_id=user, notification_type="booking.request_received", reference_id="r1", payload={"title": "T", "body": "B"})
    db_session.commit()
    dispatch_outbox_events_task(limit=50)
    db_session.expire_all()
    assert db_session.query(EmailMessage).filter_by(user_id=user).count() == 0
    assert db_session.query(Notification).filter_by(user_id=user).count() == 1


def test_unsubscribing_twice_is_one_change(client, db_session):
    user = _user(db_session)
    params = _params(unsubscribe.page_url(user, "booking"))

    client.post("/v1/email/unsubscribe", params=params)
    again = client.post("/v1/email/unsubscribe", params=params)

    assert again.status_code == 200, again.text
    assert len(_topic_pref(db_session, user, "booking")) == 1


def test_a_mail_clients_one_click_post_works(client, db_session):
    user = _user(db_session)
    url = unsubscribe.one_click_url(user, "payments")

    resp = client.post(
        urlparse(url).path, params=_params(url), content="List-Unsubscribe=One-Click",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )

    assert resp.status_code == 200
    assert _topic_pref(db_session, user, "payments")[0].email_enabled is False


def test_all_email_except_security_from_the_page(client, db_session):
    user = _user(db_session)
    shown = client.get("/v1/email/unsubscribe", params=_params(unsubscribe.page_url(user, "booking"))).json()

    resp = client.post("/v1/email/unsubscribe", params={"u": str(user), "t": "all", "k": shown["all"]["k"], "s": shown["all"]["s"]})

    assert resp.status_code == 200
    db_session.expire_all()
    assert db_session.get(NotificationPreference, user).channel_email_enabled is False


def test_security_cannot_be_unsubscribed(client, db_session):
    user = _user(db_session)
    kid, sig = unsubscribe.sign(user, "security")

    resp = client.post("/v1/email/unsubscribe", params={"u": str(user), "t": "security", "k": kid, "s": sig})

    assert resp.status_code == 400


def test_security_mail_has_no_link_and_ignores_the_switches(db_session, monkeypatch):
    user = _user(db_session, "secure@example.com")
    db_session.add(NotificationPreference(user_id=user, channel_email_enabled=False))
    db_session.commit()
    sent = []

    class Provider:
        provider_name = "test"

        def send_template_email(self, *, email, template_key, subject, text_body, unsubscribe_url=None):
            sent.append((template_key, unsubscribe_url))
            return "m1"

    monkeypatch.setattr("app.services.mail.get_mail_provider", lambda: Provider())

    for kind in ("auth.new_login", "booking.request_received"):
        enqueue_notification(db_session, user_id=user, notification_type=kind, reference_id=kind, payload={"title": "T", "body": "B"})
    db_session.commit()
    dispatch_outbox_events_task(limit=50)

    assert sent == [("auth.new_login", None)], "the sign-in alert goes, with no unsubscribe; the booking email does not"


def test_other_mail_carries_the_signed_link(db_session, monkeypatch):
    user = _user(db_session, "link@example.com")
    sent = []

    class Provider:
        provider_name = "test"

        def send_template_email(self, *, email, template_key, subject, text_body, unsubscribe_url=None):
            sent.append(unsubscribe_url)
            return "m1"

    monkeypatch.setattr("app.services.mail.get_mail_provider", lambda: Provider())
    enqueue_notification(db_session, user_id=user, notification_type="booking.request_received", reference_id="x", payload={"title": "T", "body": "B"})
    db_session.commit()
    dispatch_outbox_events_task(limit=50)

    [url] = sent
    p = _params(url)
    assert unsubscribe.verify(uuid.UUID(p["u"]), p["t"], p["k"], p["s"]) and p["t"] == "booking"


def test_the_headers_offer_one_click_to_the_api(db_session):
    user = uuid.uuid4()

    headers = unsubscribe.headers_for(unsubscribe.page_url(user, "booking"))

    assert headers["List-Unsubscribe-Post"] == "List-Unsubscribe=One-Click"
    one_click = headers["List-Unsubscribe"].strip("<>")
    assert one_click.startswith(f"{unsubscribe.settings.api_public_url.rstrip('/')}/v1/email/unsubscribe?")
    assert _params(one_click) == _params(unsubscribe.page_url(user, "booking"))
    assert unsubscribe.headers_for(None) == {}


def test_rotation_old_links_still_work_and_unknown_keys_do_not(monkeypatch):
    user = uuid.uuid4()
    monkeypatch.setattr(unsubscribe.settings, "unsubscribe_signing_keys", "k1:old-secret-old-secret-old-secret")
    old_kid, old_sig = unsubscribe.sign(user, "booking")

    monkeypatch.setattr(unsubscribe.settings, "unsubscribe_signing_keys", "k2:new-secret-new-secret-new-secret,k1:old-secret-old-secret-old-secret")

    assert unsubscribe.sign(user, "booking")[0] == "k2", "the first key signs"
    assert unsubscribe.verify(user, "booking", old_kid, old_sig) is True
    assert unsubscribe.verify(user, "booking", "k9", old_sig) is False


def test_production_needs_its_own_keys(monkeypatch):
    monkeypatch.setattr(unsubscribe.settings, "unsubscribe_signing_keys", "")
    monkeypatch.setattr(unsubscribe.settings, "app_env", "production")

    with pytest.raises(RuntimeError):
        unsubscribe.sign(uuid.uuid4(), "booking")
