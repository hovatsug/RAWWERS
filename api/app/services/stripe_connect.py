"""Stripe Connect (Express) onboarding for photographers.

Express: Stripe hosts onboarding and KYC, the photographer never has to
manage a Stripe dashboard they did not ask for, and the platform keeps
control of the payout schedule.

NOTE ON VERIFICATION: at the time of writing, Connect is not enabled on
the platform's Stripe account, so none of the calls in this module have
run against Stripe. The shapes come from the Stripe API reference and the
error handling is exercised against a fake client in tests. Treat this as
structurally correct and unproven until Connect is switched on - see
docs/BACKEND_GAPS.md.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone

import stripe
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.payouts import PayoutAccount, PayoutAccountStatus, PayoutMethod
from app.services.payouts import get_or_create_payout_account

settings = get_settings()


def _stripe():
    """Indirection so tests can substitute a fake without patching the
    module-level import in three places."""
    stripe.api_key = settings.stripe_secret_key
    return stripe


def ensure_connect_account(db: Session, *, pro_user_id: uuid.UUID, email: str | None, country: str | None) -> PayoutAccount:
    """Get or create the photographer's Express account.

    Idempotent on our side: an account id already stored is returned
    untouched rather than creating a second account, which would strand
    whatever onboarding they had already completed.
    """
    account = get_or_create_payout_account(db, pro_user_id=pro_user_id)
    if account.stripe_connect_account_id:
        return account

    try:
        created = _stripe().Account.create(
            type="express",
            email=email,
            # Stripe requires a country at creation and it cannot be changed
            # afterwards. The pro's own country is the best available answer;
            # falling back to the platform's would quietly make a Portuguese
            # photographer a US account holder.
            country=(country or settings.default_connect_country or "PT").upper(),
            capabilities={"transfers": {"requested": True}},
            business_type="individual",
            metadata={"pro_user_id": str(pro_user_id)},
        )
    except Exception as exc:  # stripe.error.StripeError and anything below it
        raise APIError(
            code="stripe_error",
            message=_readable(exc),
            status_code=502,
        ) from exc

    account.stripe_connect_account_id = created["id"]
    account.payout_method = PayoutMethod.stripe_connect
    # Not active until Stripe says so through account.updated. Claiming
    # otherwise would show a photographer a working payout method that
    # cannot pay them.
    account.status = PayoutAccountStatus.pending_verification
    account.updated_at = datetime.now(timezone.utc)
    db.flush()
    return account


def create_onboarding_link(*, stripe_account_id: str, return_url: str, refresh_url: str) -> str:
    """A fresh hosted-onboarding URL.

    Account links expire within minutes and are single use, so this is
    never cached: every request mints a new one. `refresh_url` is where
    Stripe sends someone whose link went stale - it should come straight
    back here for another link rather than showing them an error.
    """
    try:
        link = _stripe().AccountLink.create(
            account=stripe_account_id,
            refresh_url=refresh_url,
            return_url=return_url,
            type="account_onboarding",
        )
    except Exception as exc:
        raise APIError(code="stripe_error", message=_readable(exc), status_code=502) from exc
    return link["url"]


def connect_status(*, stripe_account_id: str) -> dict:
    """What Stripe currently thinks, including what it is still waiting for.

    `requirements.currently_due` is the difference between telling a
    photographer "pending" and telling them "Stripe still needs your ID
    document" - the second is actionable, the first is a shrug.
    """
    try:
        account = _stripe().Account.retrieve(stripe_account_id)
    except Exception as exc:
        raise APIError(code="stripe_error", message=_readable(exc), status_code=502) from exc

    requirements = account.get("requirements") or {}
    return {
        "stripe_account_id": account.get("id"),
        "charges_enabled": bool(account.get("charges_enabled")),
        "payouts_enabled": bool(account.get("payouts_enabled")),
        "details_submitted": bool(account.get("details_submitted")),
        "currently_due": list(requirements.get("currently_due") or []),
        "past_due": list(requirements.get("past_due") or []),
        "disabled_reason": requirements.get("disabled_reason"),
    }


def status_from_account(payload: dict) -> PayoutAccountStatus:
    """The same mapping the account.updated webhook applies, so a status
    read directly from Stripe and one delivered by webhook cannot disagree."""
    requirements = payload.get("requirements") or {}
    if payload.get("charges_enabled") and payload.get("payouts_enabled") and payload.get("details_submitted"):
        return PayoutAccountStatus.active
    if requirements.get("disabled_reason"):
        return PayoutAccountStatus.disabled
    return PayoutAccountStatus.pending_verification


def _readable(exc: Exception) -> str:
    """Stripe's own message where there is one; it names the actual problem
    ("Connect is not enabled on this account") far better than a generic
    failure would."""
    message = getattr(exc, "user_message", None) or str(exc)
    return message.split("\n")[0][:300] or "Stripe request failed"
