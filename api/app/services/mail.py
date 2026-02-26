from __future__ import annotations

import logging

logger = logging.getLogger(__name__)


class MailProvider:
    provider_name: str = "unknown"

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

    def send_verification_email(self, *, email: str, code: str) -> None:
        raise NotImplementedError

    def send_password_reset_email(self, *, email: str, code: str) -> None:
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
        message_id = f"console-{template_key}"
        logger.info(
            "mail_template_send",
            extra={"template_key": template_key, "email_domain": _mask_email_domain(email), "subject": subject[:120], "message_id": message_id},
        )
        return message_id

    def send_verification_email(self, *, email: str, code: str) -> None:
        logger.info("mail_verify_send", extra={"email_domain": _mask_email_domain(email)})

    def send_password_reset_email(self, *, email: str, code: str) -> None:
        logger.info("mail_reset_send", extra={"email_domain": _mask_email_domain(email)})


_provider: MailProvider | None = None


def get_mail_provider() -> MailProvider:
    global _provider
    if _provider is None:
        _provider = ConsoleMailProvider()
    return _provider


def _mask_email_domain(email: str) -> str:
    parts = email.split("@")
    if len(parts) != 2:
        return "invalid"
    local, domain = parts
    if not local:
        return f"***@{domain}"
    return f"{local[:1]}***@{domain}"
