from __future__ import annotations

import json
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

import stripe

from app.core.config import get_settings
from app.core.errors import APIError

settings = get_settings()

stripe.api_key = settings.stripe_secret_key or "sk_test_placeholder"
if settings.stripe_api_version:
    stripe.api_version = settings.stripe_api_version


def to_cents(amount: Decimal) -> int:
    quantized = amount.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    return int(quantized * 100)


def from_cents(amount_cents: int) -> Decimal:
    return (Decimal(amount_cents) / Decimal("100")).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def map_intent_status(status: str) -> str:
    if status in {"requires_action", "requires_confirmation", "requires_capture"}:
        return "requires_action"
    if status == "succeeded":
        return "succeeded"
    if status in {"canceled"}:
        return "cancelled"
    if status in {"processing", "requires_payment_method"}:
        return "pending"
    return "failed"


def construct_stripe_event(raw_body: bytes, signature_header: str | None) -> dict:
    secret = settings.stripe_webhook_secret

    if secret:
        if not signature_header:
            raise APIError(code="invalid_signature", message="Missing Stripe signature", status_code=401)
        try:
            event = stripe.Webhook.construct_event(raw_body, signature_header, secret)
            if hasattr(event, "to_dict_recursive"):
                return event.to_dict_recursive()
            return dict(event)
        except stripe.error.SignatureVerificationError as exc:
            raise APIError(code="invalid_signature", message="Invalid Stripe signature", status_code=401) from exc
        except ValueError as exc:
            raise APIError(code="invalid_payload", message="Malformed Stripe payload", status_code=400) from exc

    dev_env = settings.app_env.lower() in {"dev", "development", "test"}
    if dev_env and settings.stripe_webhook_allow_unverified:
        try:
            return json.loads(raw_body.decode("utf-8"))
        except json.JSONDecodeError as exc:
            raise APIError(code="invalid_payload", message="Malformed Stripe payload", status_code=400) from exc

    raise APIError(
        code="invalid_signature",
        message="Stripe webhook secret is not configured",
        status_code=401,
    )


def is_within_hours(when: datetime, hours: int) -> bool:
    return (datetime.now(timezone.utc) - when).total_seconds() <= hours * 3600
