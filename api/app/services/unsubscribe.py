"""Unsubscribing from email: signed links, and what they change.

Every non-security email carries a link to the web app's public
/unsubscribe page, and List-Unsubscribe / List-Unsubscribe-Post headers
(RFC 8058) pointing at the API's one-click endpoint. Both carry the user,
the topic, a key id and a signature:

    s = HMAC-SHA256(key, "unsubscribe:v1:<user id>:<topic>"), hex

The key comes from UNSUBSCRIBE_SIGNING_KEYS ("<id>:<secret>", comma-
separated, newest first): the first signs, every one listed verifies, so
a key can rotate without breaking links already sent. Required in
production; development uses a fixed key from a public string, which
protects nothing. There is no expiry: an unsubscribe link must keep
working for good.

Opening the link changes nothing (mail scanners open every link); the
page's button POSTs, as does a mail client's one-click unsubscribe. It
writes the switches that already exist: the topic's email off, or, for
"all", every email except security.

Security mail (verification codes and password resets, sent outside
notifications, and the `auth.new_login` and `password.reset` alerts) has
no unsubscribe link and ignores the switches.
"""
from __future__ import annotations

import base64
import hashlib
import hmac
import uuid
from urllib.parse import urlencode, urlparse

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError

settings = get_settings()

#: Notification types that are security mail: always sent, never unsubscribable.
SECURITY_TYPES = frozenset({"auth.new_login", "password.reset"})
SECURITY_TOPIC = "security"
#: Every email except security.
ALL = "all"

#: How the page names a topic: "Stop emails about <label>?"
TOPIC_LABELS = {
    "booking": "bookings",
    "payments": "payments",
    "proofs": "your photos",
    "reviews": "reviews",
    "courses": "courses",
    "store": "the store",
    "repairs": "repairs",
    "gamification": "badges and quests",
    "general": "other updates",
    ALL: "everything except account security",
}

_DEV_SEED = b"rawwers-development-unsubscribe-key-not-a-secret"


def _keys() -> list[tuple[str, bytes]]:
    keys = []
    for part in (settings.unsubscribe_signing_keys or "").split(","):
        kid, _, secret = part.strip().partition(":")
        if kid and secret:
            keys.append((kid.strip(), secret.strip().encode()))
    if keys:
        return keys
    if settings.app_env == "production":
        raise RuntimeError("UNSUBSCRIBE_SIGNING_KEYS is required in production")
    return [("dev", base64.urlsafe_b64encode(hashlib.sha256(_DEV_SEED).digest()))]


def _mac(secret: bytes, user_id: uuid.UUID, topic: str) -> str:
    return hmac.new(secret, f"unsubscribe:v1:{user_id}:{topic}".encode(), hashlib.sha256).hexdigest()


def sign(user_id: uuid.UUID, topic: str) -> tuple[str, str]:
    """(key id, signature) with the newest key."""
    kid, secret = _keys()[0]
    return kid, _mac(secret, user_id, topic)


def verify(user_id: uuid.UUID, topic: str, kid: str, signature: str) -> bool:
    secret = dict(_keys()).get(kid or "")
    if secret is None or not signature:
        return False
    return hmac.compare_digest(_mac(secret, user_id, topic), signature)


def _query(user_id: uuid.UUID, topic: str) -> str:
    kid, sig = sign(user_id, topic)
    return urlencode({"u": str(user_id), "t": topic, "k": kid, "s": sig})


def page_url(user_id: uuid.UUID, topic: str) -> str:
    """The link in the email: the web app's page, which changes nothing until its button is pressed."""
    return f"{settings.app_public_url.rstrip('/')}/unsubscribe?{_query(user_id, topic)}"


def one_click_url(user_id: uuid.UUID, topic: str) -> str:
    """Where a mail client's one-click unsubscribe POSTs."""
    return f"{settings.api_public_url.rstrip('/')}/v1/email/unsubscribe?{_query(user_id, topic)}"


def headers_for(page: str | None) -> dict[str, str]:
    """The List-Unsubscribe headers for an email whose body links to `page`
    (none for security mail, which has no link). For the mail provider."""
    if not page:
        return {}
    query = urlparse(page).query
    return {
        "List-Unsubscribe": f"<{settings.api_public_url.rstrip('/')}/v1/email/unsubscribe?{query}>",
        "List-Unsubscribe-Post": "List-Unsubscribe=One-Click",
    }


def checked(user_id: str, topic: str, kid: str, signature: str) -> tuple[uuid.UUID, str]:
    """The user and topic of a valid link, or 400."""
    invalid = APIError(code="invalid_link", message="This unsubscribe link is not valid.", status_code=400)
    try:
        user = uuid.UUID(str(user_id))
    except ValueError:
        raise invalid from None
    if topic == SECURITY_TOPIC or not verify(user, topic, kid, signature):
        raise invalid
    return user, topic


def apply(db: Session, user_id: uuid.UUID, topic: str) -> None:
    """Switch that email off: one topic, or every email except security.
    In-app notifications are left as they are. Doing it twice is one change."""
    from app.models.communication import NotificationTopicPreference
    from app.services.analytics import log_event
    from app.services.notifications import get_or_create_preferences

    if topic == ALL:
        get_or_create_preferences(db, user_id).channel_email_enabled = False
    else:
        row = db.execute(
            select(NotificationTopicPreference).where(
                NotificationTopicPreference.user_id == user_id, NotificationTopicPreference.topic == topic
            )
        ).scalar_one_or_none()
        if row is None:
            db.add(NotificationTopicPreference(user_id=user_id, topic=topic, email_enabled=False, inapp_enabled=True))
        else:
            row.email_enabled = False
    log_event(db, event_name="notification.email_unsubscribed", user_id=user_id, properties={"topic": topic})
    db.flush()
