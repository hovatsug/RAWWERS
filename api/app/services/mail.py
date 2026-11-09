"""Sending email: one way out, through `send_email`.

Every email (the verification and reset codes from the outbox, and the
approved notifications) goes through `send_email`, which decides whether it
may be delivered before any provider is called:

1. A suppressed address (a hard bounce, an invalid address, a block, a
   complaint: services/email_suppression.py) is not mailed. Security mail
   still goes to an address suppressed only for non-security mail.
2. A provider that really delivers (Brevo) is used only while sending is on
   (EMAIL_SENDING_ENABLED: off in production unless set, on elsewhere) and,
   outside production, only to an address on EMAIL_DEV_ALLOWLIST. A test run
   can never email a real person.

The console provider delivers nothing: it logs, and is what runs when Brevo
is not configured or sending is off. docs/BREVO_SETUP.md.
"""
from __future__ import annotations

import html
import logging
from dataclasses import dataclass

import requests

from app.core.config import get_settings

logger = logging.getLogger(__name__)

BREVO_SEND_URL = "https://api.brevo.com/v3/smtp/email"


class MailRetryable(Exception):
    """The provider was busy or failed (429, 5xx): try again later."""


class MailRejected(Exception):
    """The provider refused this email (other 4xx): retrying will not help."""


class MailUncertain(Exception):
    """No answer (a timeout): it may have been sent, so it is not resent."""


class MailProvider:
    provider_name: str = "unknown"
    #: True for a provider that puts mail in real inboxes. Only these are
    #: held to the sending switch and the dev allowlist.
    delivers: bool = False

    def send_template_email(
        self,
        *,
        email: str,
        template_key: str,
        subject: str,
        text_body: str,
        unsubscribe_url: str | None = None,
    ) -> str | None:
        raise NotImplementedError


class ConsoleMailProvider(MailProvider):
    provider_name = "console"

    def send_template_email(
        self,
        *,
        email: str,
        template_key: str,
        subject: str,
        text_body: str,
        unsubscribe_url: str | None = None,
    ) -> str | None:
        from app.services.unsubscribe import headers_for

        message_id = f"console-{template_key}"
        logger.info(
            "mail_template_send",
            extra={
                "template_key": template_key,
                "email_domain": _mask_email_domain(email),
                "subject": subject[:120],
                "message_id": message_id,
                # What a real provider must send: List-Unsubscribe and
                # List-Unsubscribe-Post on every email with a link.
                "headers": sorted(headers_for(unsubscribe_url)),
            },
        )
        return message_id


class BrevoMailProvider(MailProvider):
    """Brevo's transactional API (POST /v3/smtp/email)."""

    provider_name = "brevo"
    delivers = True

    def __init__(self, *, api_key: str, sender_email: str, sender_name: str, reply_to: str = "") -> None:
        self._api_key = api_key
        self.sender = {"email": sender_email, "name": sender_name}
        self.reply_to = reply_to

    def message(self, *, email: str, template_key: str, subject: str, text_body: str, unsubscribe_url: str | None) -> dict:
        """The request body for one email."""
        from app.services.unsubscribe import headers_for

        text = text_body
        if unsubscribe_url:
            text = (
                f"{text_body}\n\n--\nYou get this email because you have a RAWWERS account.\n"
                f"Stop these emails: {unsubscribe_url}"
            )
        body: dict = {
            "sender": self.sender,
            "to": [{"email": email}],
            "subject": subject,
            "textContent": text,
            "htmlContent": _html(text),
            "tags": [template_key],
        }
        if self.reply_to:
            body["replyTo"] = {"email": self.reply_to}
        headers = headers_for(unsubscribe_url)
        if headers:
            body["headers"] = headers
        return body

    def send_template_email(
        self,
        *,
        email: str,
        template_key: str,
        subject: str,
        text_body: str,
        unsubscribe_url: str | None = None,
    ) -> str | None:
        body = self.message(email=email, template_key=template_key, subject=subject, text_body=text_body, unsubscribe_url=unsubscribe_url)
        try:
            resp = requests.post(
                BREVO_SEND_URL,
                json=body,
                headers={"api-key": self._api_key, "accept": "application/json", "content-type": "application/json"},
                timeout=10,
            )
        except requests.Timeout as exc:
            raise MailUncertain("brevo: no answer in 10 s; it may have been sent, so it is not resent") from exc
        except requests.RequestException as exc:
            raise MailRetryable(f"brevo: {type(exc).__name__}") from exc
        if resp.status_code == 429 or resp.status_code >= 500:
            raise MailRetryable(f"brevo: {resp.status_code}")
        if resp.status_code >= 400:
            raise MailRejected(f"brevo: {resp.status_code} {resp.text[:300]}")
        message_id = (resp.json() or {}).get("messageId")
        logger.info(
            "mail_brevo_sent",
            extra={"template_key": template_key, "email_domain": _mask_email_domain(email), "message_id": message_id},
        )
        return message_id


def get_mail_provider() -> MailProvider:
    """Brevo when it is configured and sending is on; the console otherwise."""
    conf = get_settings()
    if conf.email_sending_on and conf.brevo_api_key and conf.brevo_sender_email:
        return BrevoMailProvider(
            api_key=conf.brevo_api_key,
            sender_email=conf.brevo_sender_email,
            sender_name=conf.brevo_sender_name,
            reply_to=conf.brevo_reply_to,
        )
    return ConsoleMailProvider()


@dataclass
class SendOutcome:
    #: "sent", "blocked" (sending off, or not on the dev allowlist) or
    #: "suppressed" (the address bounced or complained).
    status: str
    provider: str
    message_id: str | None = None
    reason: str | None = None


def delivery_block_reason(email: str) -> str | None:
    """Why a delivering provider may not send to `email` now, or None."""
    conf = get_settings()
    if not conf.email_sending_on:
        return "sending_off"
    if not conf.is_production and email.strip().lower() not in conf.email_dev_allowlist_set:
        return "not_on_dev_allowlist"
    return None


def send_email(
    db,
    *,
    email: str,
    template_key: str,
    subject: str,
    text_body: str,
    unsubscribe_url: str | None = None,
    security: bool = False,
) -> SendOutcome:
    """The one way an email leaves. Raises MailRetryable, MailRejected or
    MailUncertain from the provider; the caller records them."""
    from app.services.email_suppression import suppression_reason

    provider = get_mail_provider()
    name = getattr(provider, "provider_name", "unknown")
    suppressed = suppression_reason(db, email, security=security)
    if suppressed:
        logger.info("mail_suppressed", extra={"template_key": template_key, "email_domain": _mask_email_domain(email), "reason": suppressed})
        return SendOutcome("suppressed", name, reason=suppressed)
    if getattr(provider, "delivers", False):
        blocked = delivery_block_reason(email)
        if blocked:
            logger.info("mail_blocked", extra={"template_key": template_key, "email_domain": _mask_email_domain(email), "reason": blocked})
            return SendOutcome("blocked", name, reason=blocked)
    message_id = provider.send_template_email(
        email=email, template_key=template_key, subject=subject, text_body=text_body, unsubscribe_url=unsubscribe_url
    )
    return SendOutcome("sent", name, message_id=message_id)


def _html(text: str) -> str:
    paragraphs = [p for p in text.split("\n\n") if p.strip()]
    return "".join(f"<p>{html.escape(p).replace(chr(10), '<br>')}</p>" for p in paragraphs)


def _mask_email_domain(email: str) -> str:
    parts = email.split("@")
    if len(parts) != 2:
        return "invalid"
    local, domain = parts
    if not local:
        return f"***@{domain}"
    return f"{local[:1]}***@{domain}"
