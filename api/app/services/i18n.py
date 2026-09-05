from __future__ import annotations

import threading
import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from string import Formatter

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.i18n import I18nBundle, I18nKeyAudit, I18nKeyAuditStatus, LocalizedText, UserLocalePreference

DEFAULT_LOCALE = "en-GB"
SUPPORTED_LOCALES = ("en-GB", "pt-PT", "es-ES", "ru-RU")
DEFAULT_NAMESPACES = ("core", "errors", "notifications", "gamification")
BUNDLE_CACHE_TTL_SECONDS = 120

_alias_map = {
    "en": "en-GB",
    "en-gb": "en-GB",
    "pt": "pt-PT",
    "pt-pt": "pt-PT",
    "es": "es-ES",
    "es-es": "es-ES",
    "ru": "ru-RU",
    "ru-ru": "ru-RU",
}


@dataclass(frozen=True)
class BundlePayload:
    locale: str
    namespace: str
    version: int
    content: dict[str, str]


_cache_lock = threading.Lock()
_bundle_cache: dict[tuple[str, str], tuple[datetime, int, dict[str, str]]] = {}


def normalize_locale(value: str | None) -> str:
    if not value:
        return DEFAULT_LOCALE
    key = value.strip().replace("_", "-").lower()
    mapped = _alias_map.get(key)
    if mapped:
        return mapped
    if key in {item.lower() for item in SUPPORTED_LOCALES}:
        for item in SUPPORTED_LOCALES:
            if item.lower() == key:
                return item
    if "-" in key:
        base = key.split("-", 1)[0]
        mapped = _alias_map.get(base)
        if mapped:
            return mapped
    return DEFAULT_LOCALE


def resolve_locale_from_accept_language(value: str | None) -> str:
    if not value:
        return DEFAULT_LOCALE
    weighted: list[tuple[float, str]] = []
    for idx, part in enumerate(value.split(",")):
        token = part.strip()
        if not token:
            continue
        locale = token
        q = 1.0
        if ";" in token:
            locale, attrs = token.split(";", 1)
            locale = locale.strip()
            attrs = attrs.strip()
            if attrs.startswith("q="):
                try:
                    q = float(attrs[2:])
                except Exception:
                    q = 1.0
        weighted.append((q - (idx * 1e-6), normalize_locale(locale)))
    if not weighted:
        return DEFAULT_LOCALE
    weighted.sort(key=lambda item: item[0], reverse=True)
    return weighted[0][1]


def get_user_locale_preference(db: Session, *, user_id: uuid.UUID, fallback_to_default: bool = True) -> str:
    row = db.get(UserLocalePreference, user_id)
    if row:
        return normalize_locale(row.locale)
    return DEFAULT_LOCALE if fallback_to_default else ""


def upsert_user_locale_preference(db: Session, *, user_id: uuid.UUID, locale: str) -> UserLocalePreference:
    normalized = normalize_locale(locale)
    row = db.get(UserLocalePreference, user_id)
    if not row:
        row = UserLocalePreference(user_id=user_id, locale=normalized)
        db.add(row)
    else:
        row.locale = normalized
    db.flush()
    return row


def resolve_effective_locale(
    db: Session,
    *,
    user_id: uuid.UUID | None,
    accept_language: str | None,
    request_locale: str | None,
) -> str:
    if user_id is not None:
        pref = get_user_locale_preference(db, user_id=user_id, fallback_to_default=False)
        if pref:
            return pref
    if accept_language:
        return resolve_locale_from_accept_language(accept_language)
    return normalize_locale(request_locale)


def ensure_default_i18n_bundles(db: Session) -> None:
    existing = db.execute(select(I18nBundle.id).limit(1)).first()
    if existing:
        return

    seed: list[tuple[str, str, dict[str, str]]] = [
        (
            "en-GB",
            "notifications",
            {
                "notifications.booking.request_received.subject": "New booking request",
                "notifications.booking.request_received.title": "New booking request",
                "notifications.booking.request_received.body": "You received a booking request.",
                "notifications.booking.request_accepted.subject": "Booking request accepted",
                "notifications.booking.request_accepted.title": "Booking accepted",
                "notifications.booking.request_accepted.body": "Your booking request was accepted.",
                "notifications.booking.request_declined.subject": "Booking request declined",
                "notifications.booking.request_declined.title": "Booking declined",
                "notifications.booking.request_declined.body": "Your booking request was declined.",
                "notifications.payment.succeeded.subject": "Payment succeeded",
                "notifications.payment.succeeded.title": "Payment confirmed",
                "notifications.payment.succeeded.body": "Your payment was successful.",
                "notifications.payment.failed.subject": "Payment failed",
                "notifications.payment.failed.title": "Payment failed",
                "notifications.payment.failed.body": "Your payment could not be processed.",
                "notifications.proofs.gallery_published.subject": "Proof gallery ready",
                "notifications.proofs.gallery_published.title": "Your gallery is ready",
                "notifications.proofs.gallery_published.body": "Your proof gallery has been published.",
                "notifications.proofs.selection_due_reminder.subject": "Photo selection reminder",
                "notifications.proofs.selection_due_reminder.title": "Selection reminder",
                "notifications.proofs.selection_due_reminder.body": "Please complete your photo selection.",
                "notifications.proofs.delivery_completed.subject": "Delivery completed",
                "notifications.proofs.delivery_completed.title": "Delivery complete",
                "notifications.proofs.delivery_completed.body": "Your final delivery is complete.",
                "notifications.review.request.subject": "Review request",
                "notifications.review.request.title": "Leave a review",
                "notifications.review.request.body": "Please review your recent experience.",
                "notifications.course.completed.subject": "Course completed",
                "notifications.course.completed.title": "Course complete",
                "notifications.course.completed.body": "You completed your course.",
                "notifications.certificate.issued.subject": "Certificate issued",
                "notifications.certificate.issued.title": "Certificate available",
                "notifications.certificate.issued.body": "Your certificate has been issued.",
                "notifications.store.order_paid.subject": "Store order paid",
                "notifications.store.order_paid.title": "Order confirmed",
                "notifications.store.order_paid.body": "Your store order was paid.",
                "notifications.store.order_shipped.subject": "Order shipped",
                "notifications.store.order_shipped.title": "Order shipped",
                "notifications.store.order_shipped.body": "Your order is on the way.",
                "notifications.repair.quote_sent.subject": "Repair quote sent",
                "notifications.repair.quote_sent.title": "Repair quote available",
                "notifications.repair.quote_sent.body": "Your repair quote is ready.",
                "notifications.repair.return_shipped.subject": "Repair return shipped",
                "notifications.repair.return_shipped.title": "Return shipped",
                "notifications.repair.return_shipped.body": "Your repaired item is on its way back.",
                "notifications.loaner.approved.subject": "Loaner approved",
                "notifications.loaner.approved.title": "Loaner approved",
                "notifications.loaner.approved.body": "Your loaner request was approved.",
                "notifications.title.awarded.subject": "New title awarded",
                "notifications.title.awarded.title": "Title awarded",
                "notifications.title.awarded.body": "You earned a new title.",
                "notifications.quest.completed.subject": "Quest completed",
                "notifications.quest.completed.title": "Quest completed",
                "notifications.quest.completed.body": "You completed a quest.",
                "notifications.auth.new_login.subject": "New login detected",
                "notifications.auth.new_login.title": "New login",
                "notifications.auth.new_login.body": "A new login was detected on your account.",
                "notifications.password.reset.subject": "Password changed",
                "notifications.password.reset.title": "Password updated",
                "notifications.password.reset.body": "Your password was changed successfully.",
                "notifications.consent.updated.subject": "Usage consent updated",
                "notifications.consent.updated.title": "Media usage consent updated",
                "notifications.consent.updated.body": "A client updated media usage consent for a gig.",
                "notifications.consent.reminder.subject": "Set media consent",
                "notifications.consent.reminder.title": "Media consent reminder",
                "notifications.consent.reminder.body": "Please review your media usage consent preferences.",
                "notifications.payout.requested.subject": "Payout request",
                "notifications.payout.requested.title": "Payout request",
                "notifications.payout.requested.body": "A pro submitted a payout request.",
            },
        ),
        (
            "en-GB",
            "gamification",
            {
                "gamification.milestones.client_first_consent.name": "Set Your Consent",
                "gamification.milestones.client_first_consent.description": "Set a media usage consent level for a gig.",
                "gamification.milestones.client_first_share.name": "First Gallery Share",
                "gamification.milestones.client_first_share.description": "Reach your first engaged share viewers.",
                "gamification.milestones.client_reviews_started.name": "Feedback Giver",
                "gamification.milestones.client_reviews_started.description": "Leave your first review.",
            },
        ),
        (
            "en-GB",
            "core",
            {
                "core.locale.current": "Current locale",
                "core.action.save": "Save",
                "core.action.cancel": "Cancel",
            },
        ),
        (
            "en-GB",
            "errors",
            {
                "errors.generic": "Something went wrong",
            },
        ),
        (
            "pt-PT",
            "notifications",
            {
                "notifications.booking.request_received.subject": "Novo pedido de reserva",
                "notifications.booking.request_received.title": "Novo pedido de reserva",
                "notifications.booking.request_received.body": "Recebeste um novo pedido de reserva.",
                "notifications.payout.requested.title": "Pedido de pagamento",
            },
        ),
        (
            "es-ES",
            "notifications",
            {
                "notifications.booking.request_received.subject": "Nueva solicitud de reserva",
                "notifications.booking.request_received.title": "Nueva solicitud de reserva",
                "notifications.booking.request_received.body": "Has recibido una solicitud de reserva.",
            },
        ),
        (
            "ru-RU",
            "notifications",
            {
                "notifications.booking.request_received.subject": "Новый запрос на бронирование",
                "notifications.booking.request_received.title": "Новый запрос на бронирование",
                "notifications.booking.request_received.body": "Вы получили новый запрос на бронирование.",
            },
        ),
    ]

    now = datetime.now(timezone.utc)
    for locale, namespace, content in seed:
        db.add(
            I18nBundle(
                locale=locale,
                namespace=namespace,
                version=1,
                content=content,
                is_active=True,
                created_at=now,
                updated_at=now,
            )
        )
    db.flush()


def get_active_bundle(db: Session, *, locale: str, namespace: str) -> BundlePayload:
    ensure_default_i18n_bundles(db)
    loc = normalize_locale(locale)
    key = (loc, namespace)
    now = datetime.now(timezone.utc)

    with _cache_lock:
        cached = _bundle_cache.get(key)
        if cached and cached[0] > now:
            return BundlePayload(locale=loc, namespace=namespace, version=int(cached[1]), content=dict(cached[2]))

    row = db.execute(
        select(I18nBundle)
        .where(I18nBundle.locale == loc, I18nBundle.namespace == namespace, I18nBundle.is_active.is_(True))
        .order_by(I18nBundle.version.desc())
    ).scalars().first()

    version = int(row.version if row else 0)
    content = dict((row.content or {}) if row else {})
    with _cache_lock:
        _bundle_cache[key] = (now + timedelta(seconds=BUNDLE_CACHE_TTL_SECONDS), version, content)
    return BundlePayload(locale=loc, namespace=namespace, version=version, content=content)


def invalidate_bundle_cache(*, locale: str | None = None, namespace: str | None = None) -> None:
    with _cache_lock:
        if not locale and not namespace:
            _bundle_cache.clear()
            return
        to_remove: list[tuple[str, str]] = []
        for key in _bundle_cache:
            loc_match = locale is None or key[0] == normalize_locale(locale)
            ns_match = namespace is None or key[1] == namespace
            if loc_match and ns_match:
                to_remove.append(key)
        for key in to_remove:
            _bundle_cache.pop(key, None)


def t(db: Session, key: str, *, locale: str, namespace: str = "core", **kwargs) -> str:
    bundle = get_active_bundle(db, locale=locale, namespace=namespace)
    template = bundle.content.get(key)
    if template is None and bundle.locale != DEFAULT_LOCALE:
        fallback = get_active_bundle(db, locale=DEFAULT_LOCALE, namespace=namespace)
        template = fallback.content.get(key)

    if template is None:
        _upsert_key_audit(db, locale=normalize_locale(locale), namespace=namespace, key=key, status=I18nKeyAuditStatus.missing)
        return key

    _upsert_key_audit(db, locale=normalize_locale(locale), namespace=namespace, key=key, status=I18nKeyAuditStatus.present)
    return _safe_format(template, kwargs)


def _safe_format(template: str, values: dict) -> str:
    required: set[str] = set()
    for _, field_name, _, _ in Formatter().parse(template):
        if field_name:
            required.add(field_name)
    missing = sorted([field for field in required if field not in values])
    if missing:
        raise APIError(
            code="i18n_placeholder_missing",
            message="Missing translation placeholders",
            status_code=422,
            details={"missing_placeholders": missing},
        )
    return template.format(**values)


def _upsert_key_audit(db: Session, *, locale: str, namespace: str, key: str, status: I18nKeyAuditStatus) -> I18nKeyAudit:
    row = db.execute(
        select(I18nKeyAudit).where(
            I18nKeyAudit.locale == locale,
            I18nKeyAudit.namespace == namespace,
            I18nKeyAudit.key == key,
        )
    ).scalar_one_or_none()
    if not row:
        row = I18nKeyAudit(locale=locale, namespace=namespace, key=key, status=status)
        db.add(row)
    else:
        row.status = status
    db.flush()
    return row


def activate_bundle(db: Session, *, bundle_id: uuid.UUID) -> I18nBundle:
    row = db.get(I18nBundle, bundle_id)
    if not row:
        raise APIError(code="not_found", message="Bundle not found", status_code=404)

    rows = db.execute(
        select(I18nBundle).where(
            I18nBundle.locale == row.locale,
            I18nBundle.namespace == row.namespace,
        )
    ).scalars().all()
    for item in rows:
        item.is_active = item.id == row.id
    db.flush()
    invalidate_bundle_cache(locale=row.locale, namespace=row.namespace)
    return row


def audit_missing_keys(db: Session, *, locale: str, namespace: str) -> dict[str, list[str]]:
    loc = normalize_locale(locale)
    base = get_active_bundle(db, locale=DEFAULT_LOCALE, namespace=namespace).content
    target = get_active_bundle(db, locale=loc, namespace=namespace).content

    base_keys = set(base.keys())
    locale_keys = set(target.keys())

    missing = sorted(list(base_keys - locale_keys))
    unused = sorted(list(locale_keys - base_keys))

    for key in missing:
        _upsert_key_audit(db, locale=loc, namespace=namespace, key=key, status=I18nKeyAuditStatus.missing)
    for key in unused:
        _upsert_key_audit(db, locale=loc, namespace=namespace, key=key, status=I18nKeyAuditStatus.unused)
    for key in sorted(list(base_keys & locale_keys)):
        _upsert_key_audit(db, locale=loc, namespace=namespace, key=key, status=I18nKeyAuditStatus.present)

    return {"missing": missing, "unused": unused}


def get_localized_fields(
    db: Session,
    *,
    entity_type: str,
    entity_id: uuid.UUID,
    locale: str,
    base_fields: dict[str, str | None],
) -> dict[str, str | None]:
    loc = normalize_locale(locale)
    row = db.execute(
        select(LocalizedText).where(
            LocalizedText.entity_type == entity_type,
            LocalizedText.entity_id == entity_id,
            LocalizedText.locale == loc,
        )
    ).scalar_one_or_none()
    overlay = (row.fields or {}) if row else {}

    merged = dict(base_fields)
    for key, value in overlay.items():
        if key in merged and isinstance(value, str):
            merged[key] = value
    return merged
