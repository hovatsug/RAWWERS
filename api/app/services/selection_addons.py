"""Adding photos after the selection closed (owner's decision, 2026-11-07).

The photographer has already delivered every edited photo; the client only
chooses which to take. A client who finished by mistake, or wants more
later, may add photos until `gig.addon_window_ends_at`: stamped once when the
selection closes (`selection_addon_days` after, 7 by default), so a later
change of the setting never moves an existing booking's window. An admin
may extend it.

- Price: total(already chosen + added) - total(already chosen), on the curve
  and anchor snapshotted on the booking (a flat-priced booking: its extras
  price). Totals are whole cents, so the differences telescope: adding in
  batches never costs more or less than adding at once.
- Payment: the same intent path as the selection difference (Stripe
  payment, payment sheet, webhook, reconcile job), as a payment of kind
  `extras`. A payment started before the window ends still completes.
- Each add-on is an `ExtraImagePurchase` (meta `kind: selection_addon`, the
  photos it adds). Paid, it becomes its own extras earnings entry for the
  photographer, settling as extras do, with its RAWW credit; its photos are
  downloadable at once (the review gate as today). The booking's status,
  payouts and reviews are not touched, and the photographer is not told.
- Not on a cancelled or refunded booking.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.client_rewards_pricing import ExtraImagePurchase, ExtraImagePurchaseStatus
from app.models.gallery import ClientSelectionItem, ProofGallery, ProofGalleryItem, ProofGalleryStatus
from app.models.gig import Gig, GigStatus, StripePaymentKind

ADDON_KIND = "selection_addon"
#: Bookings that take no add-ons.
CLOSED = (GigStatus.cancelled_by_client, GigStatus.cancelled_by_pro, GigStatus.refunded)
#: How long before the window ends the client is reminded.
REMINDER_BEFORE = timedelta(days=2)


def _now() -> datetime:
    return datetime.now(timezone.utc)


def addon_days(db: Session) -> int:
    from app.services.price_reduction import delivery_review_policy

    return int(delivery_review_policy(db).selection_addon_days)


def stamp_window(db: Session, gig: Gig, now: datetime | None = None) -> None:
    """Open the window when the selection closes, once."""
    if gig.addon_window_ends_at is None:
        gig.addon_window_ends_at = (now or _now()) + timedelta(days=addon_days(db))


def window_open(gig: Gig, now: datetime | None = None) -> bool:
    ends = gig.addon_window_ends_at
    return ends is not None and (now or _now()) < ends and gig.status not in CLOSED


def _purchases(db: Session, gig_id: uuid.UUID, statuses) -> list[ExtraImagePurchase]:
    rows = db.execute(
        select(ExtraImagePurchase)
        .where(ExtraImagePurchase.gig_id == gig_id, ExtraImagePurchase.status.in_(statuses))
        .order_by(ExtraImagePurchase.created_at)
    ).scalars().all()
    return [r for r in rows if (r.meta or {}).get("kind") == ADDON_KIND]


def paid_addon_asset_ids(db: Session, gig_id: uuid.UUID) -> list[uuid.UUID]:
    out: list[uuid.UUID] = []
    for purchase in _purchases(db, gig_id, (ExtraImagePurchaseStatus.paid,)):
        out.extend(uuid.UUID(a) for a in (purchase.meta or {}).get("asset_ids", []))
    return out


def _selected_asset_ids(db: Session, gallery: ProofGallery) -> list[uuid.UUID]:
    from app.services.media_rights import latest_submitted_selection

    selection = latest_submitted_selection(db, gallery_id=gallery.id)
    if selection is None:
        return []
    return list(
        db.execute(select(ClientSelectionItem.media_asset_id).where(ClientSelectionItem.selection_id == selection.id)).scalars()
    )


def chosen_asset_ids(db: Session, gallery: ProofGallery) -> list[uuid.UUID]:
    """Everything the client has taken: the selection, then paid add-ons."""
    seen: dict[uuid.UUID, None] = {}
    for asset_id in _selected_asset_ids(db, gallery) + paid_addon_asset_ids(db, gallery.gig_id):
        seen.setdefault(asset_id, None)
    return list(seen)


def unchosen_count(db: Session, gallery: ProofGallery) -> int:
    chosen = set(chosen_asset_ids(db, gallery))
    items = db.execute(select(ProofGalleryItem.media_asset_id).where(ProofGalleryItem.gallery_id == gallery.id)).scalars()
    return sum(1 for a in items if a not in chosen)


def addon_price(db: Session, *, gig: Gig, gallery: ProofGallery, already: int, adding: int) -> Decimal:
    """What adding `adding` photos to `already` chosen costs: the difference
    of two whole-cent totals, so batches add up to the same as all at once."""
    from app.services.selection_quote import selection_total

    if adding <= 0:
        return Decimal("0.00")
    return max(
        Decimal("0.00"),
        selection_total(db, gig=gig, gallery=gallery, photo_count=already + adding)
        - selection_total(db, gig=gig, gallery=gallery, photo_count=already),
    )


def _open_for_addons(db: Session, gallery: ProofGallery, user_id: uuid.UUID) -> Gig:
    if gallery.client_user_id != user_id:
        raise APIError(code="forbidden", message="Only the client can add photos", status_code=403)
    gig = db.get(Gig, gallery.gig_id)
    if gig is None or gig.status in CLOSED:
        raise APIError(code="invalid_state", message="This booking was cancelled; no photos can be added.", status_code=409)
    if gallery.status != ProofGalleryStatus.selection_submitted:
        raise APIError(code="invalid_state", message="Finish choosing first.", status_code=409)
    if not window_open(gig):
        raise APIError(code="addon_window_closed", message="The gallery has closed; no more photos can be added.", status_code=409)
    return gig


def quote(db: Session, *, gallery: ProofGallery, user_id: uuid.UUID, adding: int) -> dict:
    gig = _open_for_addons(db, gallery, user_id)
    already = len(chosen_asset_ids(db, gallery))
    return {
        "already_chosen": already,
        "adding": adding,
        "amount": addon_price(db, gig=gig, gallery=gallery, already=already, adding=adding),
        "currency": gallery.currency or gig.currency or "EUR",
        "window_ends_at": gig.addon_window_ends_at,
    }


def start(db: Session, *, gallery: ProofGallery, user_id: uuid.UUID, asset_ids: list[uuid.UUID], request_id: str):
    """Start adding these photos: (purchase, client secret or None). Free
    ones (a flat booking still under its included photos) are added at once.
    The same request id twice is the same add-on."""
    from app.services.payment_intents import _create_intent

    request_id = (request_id or "").strip()
    if not request_id or len(request_id) > 100:
        raise APIError(code="validation_error", message="A request id is required", status_code=422)
    gig = db.execute(select(Gig).where(Gig.id == gallery.gig_id).with_for_update()).scalar_one()
    for existing in _purchases(db, gig.id, tuple(ExtraImagePurchaseStatus)):
        if (existing.meta or {}).get("request_id") == request_id:
            if existing.status != ExtraImagePurchaseStatus.pending or not existing.stripe_payment_intent_id:
                return existing, None
            import stripe

            return existing, stripe.PaymentIntent.retrieve(existing.stripe_payment_intent_id).client_secret
    gig = _open_for_addons(db, gallery, user_id)

    wanted = list(dict.fromkeys(asset_ids))
    if not wanted:
        raise APIError(code="validation_error", message="Choose at least one photo to add", status_code=422)
    in_gallery = set(db.execute(select(ProofGalleryItem.media_asset_id).where(ProofGalleryItem.gallery_id == gallery.id)).scalars())
    if any(a not in in_gallery for a in wanted):
        raise APIError(code="validation_error", message="Those photos are not in this gallery", status_code=422)
    chosen = chosen_asset_ids(db, gallery)
    if set(wanted) & set(chosen):
        raise APIError(code="already_chosen", message="Some of those photos are already yours", status_code=409)

    amount = addon_price(db, gig=gig, gallery=gallery, already=len(chosen), adding=len(wanted))
    unit = (amount / len(wanted)).quantize(Decimal("0.01"))
    purchase = ExtraImagePurchase(
        gig_id=gig.id,
        client_user_id=gig.client_user_id,
        pro_user_id=gig.pro_user_id,
        niche_id=gig.niche_id,
        included_images=gallery.included_photos,
        selected_images=len(chosen) + len(wanted),
        extra_images=len(wanted),
        unit_price_applied=unit,
        unit_price_configured=unit,
        policy_unit_price_min=Decimal("0.00"),
        subtotal=amount,
        total=amount,
        status=ExtraImagePurchaseStatus.pending,
        meta={
            "kind": ADDON_KIND,
            "gallery_id": str(gallery.id),
            "asset_ids": [str(a) for a in wanted],
            "already_chosen": len(chosen),
            "request_id": request_id,
        },
    )
    db.add(purchase)
    db.flush()
    if amount <= 0:
        apply_paid(db, purchase, amount)
        return purchase, None
    _payment, pi = _create_intent(
        db, gig, kind=StripePaymentKind.extras, payable_amount=amount, return_url=None,
        extra_metadata={"addon_id": str(purchase.id)}, idempotency_key=f"gig:{gig.id}:addon:{purchase.id}",
    )
    purchase.stripe_payment_intent_id = pi.id
    db.flush()
    return purchase, pi.client_secret


def apply_paid(db: Session, purchase: ExtraImagePurchase, amount: Decimal) -> None:
    """The add-on is paid: its photos are the client's, and it is the
    photographer's own extras earning. Once, however often it is told."""
    from app.services.payouts import create_earnings_entry
    from app.models.payouts import EarningsSourceType

    if purchase.status == ExtraImagePurchaseStatus.paid:
        return
    purchase.status = ExtraImagePurchaseStatus.paid
    purchase.meta = {**(purchase.meta or {}), "paid_at": _now().isoformat()}
    purchase.total = amount
    db.flush()
    if amount > 0:
        create_earnings_entry(
            db,
            pro_user_id=purchase.pro_user_id,
            source_type=EarningsSourceType.extra_images,
            source_id=purchase.id,
            gross_eur=amount,
            metadata={"gig_id": str(purchase.gig_id), "selection_addon": True},
        )


def apply_payment(db: Session, payment) -> bool:
    """The webhook's branch for an add-on payment. True if it was one."""
    purchase = db.execute(
        select(ExtraImagePurchase).where(ExtraImagePurchase.stripe_payment_intent_id == payment.stripe_payment_intent_id)
    ).scalar_one_or_none()
    if purchase is None or (purchase.meta or {}).get("kind") != ADDON_KIND:
        return False
    apply_paid(db, purchase, Decimal(payment.amount))
    return True


def reconcile_refunds(db: Session, payment, refunds) -> bool:
    """A refund of an add-on payment, as Stripe reports it. All or nothing,
    as extras are: refunded in full, the add-on is refunded, its photos are
    no longer the client's to download, and its extras earning (with its
    RAWW) is reversed. The booking is not touched. True if it was an add-on."""
    from app.models.gig import PaymentStatus
    from app.models.payouts import EarningsSourceType
    from app.services.payouts import reverse_earnings_entries_for_source

    purchase = db.execute(
        select(ExtraImagePurchase).where(ExtraImagePurchase.stripe_payment_intent_id == payment.stripe_payment_intent_id)
    ).scalar_one_or_none()
    if purchase is None or (purchase.meta or {}).get("kind") != ADDON_KIND:
        return False
    back = sum((Decimal(int(r.get("amount") or 0)) / 100 for r in refunds if r.get("status") == "succeeded"), Decimal("0.00"))
    payment.amount_refunded = min(back, payment.amount)
    if back >= payment.amount > 0:
        payment.status = PaymentStatus.refunded
        if purchase.status != ExtraImagePurchaseStatus.refunded:
            purchase.status = ExtraImagePurchaseStatus.refunded
            reverse_earnings_entries_for_source(
                db, source_type=EarningsSourceType.extra_images, source_id=purchase.id, reason="selection_addon_refunded"
            )
    db.flush()
    return True


def send_closing_reminders(db: Session, now: datetime | None = None) -> int:
    """One in-app reminder to the client, within two days of the window
    ending, if photos are still unchosen. A window an admin extends gets its
    own reminder before its new end."""
    from app.services.notifications import enqueue_notification

    now = now or _now()
    gigs = db.execute(
        select(Gig).where(Gig.addon_window_ends_at > now, Gig.addon_window_ends_at <= now + REMINDER_BEFORE)
    ).scalars().all()
    sent = 0
    for gig in gigs:
        if gig.status in CLOSED:
            continue
        gallery = db.execute(select(ProofGallery).where(ProofGallery.gig_id == gig.id)).scalar_one_or_none()
        if gallery is None or gallery.status != ProofGalleryStatus.selection_submitted:
            continue
        left = unchosen_count(db, gallery)
        if left == 0:
            continue
        enqueue_notification(
            db,
            user_id=gig.client_user_id,
            notification_type="proofs.addon_closing",
            payload={
                "title": "Your gallery closes soon",
                "body": f"{left} {'photo is' if left == 1 else 'photos are'} still there to add. After the gallery closes they can no longer be chosen.",
                "gallery_id": str(gallery.id),
            },
            reference_type="proof_gallery",
            reference_id=str(gallery.id),
            dedupe_key=f"addon-closing:{gig.id}:{gig.addon_window_ends_at.isoformat()}",
        )
        sent += 1
    return sent


def extend(db: Session, *, gig: Gig, days: int, note: str, admin_user_id: uuid.UUID) -> datetime:
    """Give the client `days` more, from the window's end or from now if it
    has already closed. Needs a note; logged."""
    from app.services.audit import add_admin_audit_log

    note = (note or "").strip()
    if not note:
        raise APIError(code="validation_error", message="Say why the window is extended", status_code=422)
    if not 1 <= days <= 60:
        raise APIError(code="validation_error", message="Extend by 1 to 60 days", status_code=422)
    if gig.status in CLOSED:
        raise APIError(code="invalid_state", message="This booking was cancelled", status_code=409)
    before = gig.addon_window_ends_at
    gig.addon_window_ends_at = max(before or _now(), _now()) + timedelta(days=days)
    add_admin_audit_log(
        db, actor_user_id=admin_user_id, target_type="gig", target_id=str(gig.id), action="selection_window_extended",
        reason=note, metadata={"days": days, "from": before.isoformat() if before else None, "to": gig.addon_window_ends_at.isoformat()},
    )
    db.flush()
    return gig.addon_window_ends_at
