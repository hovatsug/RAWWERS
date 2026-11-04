"""The emails RAWWERS sends, and their text (owner's decision, 2026-11-03).

Only these nine go out by email; every other notification stays in-app
(notifications._send_email_from_payload checks APPROVED). English first;
Portuguese to follow. Each text reads well without its optional facts
(a date, a tracking link), so a payload missing one still sends a clear
email. Dates are written in the recipient's time zone (their notification
preference), money with its currency's symbol.

Two of the nine are not notifications: the verification and reset codes,
sent straight from the outbox (`email.verify.send`, `email.reset.send`).
"""
from __future__ import annotations

from datetime import datetime
from decimal import Decimal, InvalidOperation
from zoneinfo import ZoneInfo

APPROVED = frozenset(
    {
        "email.verify",
        "email.reset",
        "auth.new_login",
        "booking.request_received",
        "booking.request_accepted",
        "payment.succeeded",
        "proofs.gallery_published",
        "payout.paid",
        "shelf.order_shipped",
    }
)

_SYMBOLS = {"EUR": "€", "GBP": "£", "USD": "$"}
_MONTHS = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
_DAYS = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")


def _when(value, tz: str) -> datetime | None:
    if not value:
        return None
    try:
        at = value if isinstance(value, datetime) else datetime.fromisoformat(str(value).replace("Z", "+00:00"))
        return at.astimezone(ZoneInfo(tz))
    except (ValueError, KeyError):
        return None


def _date(value, tz: str) -> str | None:
    """Fri 20 Nov"""
    at = _when(value, tz)
    return f"{_DAYS[at.weekday()]} {at.day} {_MONTHS[at.month - 1]}" if at else None


def _date_time(value, tz: str) -> str | None:
    """Fri 20 Nov at 10:00"""
    at = _when(value, tz)
    return f"{_date(value, tz)} at {at:%H:%M}" if at else None


def _money(amount, currency) -> str | None:
    try:
        value = Decimal(str(amount)).quantize(Decimal("0.01"))
    except (InvalidOperation, ValueError):
        return None
    code = str(currency or "EUR").upper()
    symbol = _SYMBOLS.get(code)
    return f"{symbol}{value}" if symbol else f"{value} {code}"


def render(kind: str, payload: dict | None, *, tz: str = "Europe/Lisbon") -> tuple[str, str]:
    """(subject, body) for an approved email. KeyError for any other kind."""
    p = payload or {}
    if kind == "email.verify":
        code, minutes = p["code"], p.get("minutes", 30)
        return (
            f"Your RAWWERS code: {code}",
            f"Enter {code} in the app to verify your email. It works for {minutes} minutes.\n\n"
            "If you did not sign up for RAWWERS, ignore this email.",
        )
    if kind == "email.reset":
        code, minutes = p["code"], p.get("minutes", 30)
        return (
            "Reset your RAWWERS password",
            f"Enter {code} in the app to choose a new password. It works for {minutes} minutes.\n\n"
            "If you did not ask for this, ignore this email: your password has not changed.",
        )
    if kind == "auth.new_login":
        when = _date_time(p.get("signed_in_at"), tz)
        return (
            "New sign-in to your RAWWERS account",
            (f"Your RAWWERS account was signed in to on {when}.\n\n" if when else "Your RAWWERS account was just signed in to.\n\n")
            + "If this was you, there is nothing to do. If not, reset your password now from the sign-in screen.",
        )
    if kind == "booking.request_received":
        start, reply_by = _date_time(p.get("requested_start"), tz), _date_time(p.get("expires_at"), tz)
        ask = f"A client would like to book you for {start}." if start else "A client would like to book you."
        deadline = f" Reply by {reply_by}, or the request lapses." if reply_by else " Reply soon: the request lapses if you do not."
        return "New booking request on RAWWERS", f"{ask}{deadline}\n\nOpen RAWWERS Pro to accept or decline."
    if kind == "booking.request_accepted":
        start, pro, pay_by = _date_time(p.get("starts_at"), tz), p.get("pro_name"), _date_time(p.get("pay_by"), tz)
        who = pro or "Your photographer"
        return (
            f"{who} accepted your booking" if pro else "Your photographer accepted your booking",
            (f"Good news: {who} accepted your booking for {start}." if start else f"Good news: {who} accepted your booking.")
            + (f"\n\nPay by {pay_by} to confirm it. Open RAWWERS to pay." if pay_by else "\n\nOpen RAWWERS to see what happens next."),
        )
    if kind == "payment.succeeded":
        amount, shoot = _money(p.get("amount"), p.get("currency")), _date(p.get("starts_at"), tz)
        return (
            f"Payment received: {amount}" if amount else "Payment received",
            (f"We received {amount}" if amount else "We received your payment")
            + (f" for your shoot on {shoot}." if shoot else " for your shoot.")
            + "\n\nYour receipt is in RAWWERS, under the booking.",
        )
    if kind == "proofs.gallery_published":
        shoot = _date(p.get("starts_at"), tz)
        return (
            "Your photos are ready to choose",
            (f"Your photographer has sent your gallery from {shoot}." if shoot else "Your photographer has sent your gallery.")
            + "\n\nOpen RAWWERS to choose your favourites.",
        )
    if kind == "payout.paid":
        amount = _money(p.get("amount"), p.get("currency"))
        return (
            f"Your payout of {amount} is on its way" if amount else "Your payout is on its way",
            (f"We have sent {amount} to your bank account." if amount else "We have sent your payout to your bank account.")
            + " It usually arrives within a few working days.\n\nThe breakdown is in RAWWERS Pro, under Wallet.",
        )
    if kind == "shelf.order_shipped":
        item, code, link = p.get("item"), p.get("tracking_code"), p.get("tracking_url")
        lines = [f"{item} is on its way to you." if item else "Your order from The Shelf is on its way to you."]
        if code:
            lines.append(f"Tracking number: {code}")
        if link:
            lines.append(f"Track it: {link}")
        lines.append("Your orders are in RAWWERS Pro, under Wallet, The Shelf.")
        return "Your Shelf order has shipped", "\n\n".join(lines)
    raise KeyError(kind)
