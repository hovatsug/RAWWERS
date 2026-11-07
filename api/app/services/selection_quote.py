"""What a selection costs, computed once and used by everyone.

The app needs to show a client the price of what they have chosen *before*
they commit to it, and `submit_selection` needs to charge them. Those must be
the same arithmetic. A second implementation that agrees today will disagree
eventually, and the failure mode is the worst kind: the app quotes one price
and Stripe charges another.

So this module owns the answer, `submit_selection` calls it rather than
computing its own, and the quote endpoint calls it too. One function, two
callers.
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy.orm import Session

from app.models.gallery import ProofGallery
from app.models.gig import Gig
from app.services.package_pricing import MINIMUM_PHOTOS, gig_curve, gig_minimum_selection, gig_total, is_curve_priced
from app.services.payment_intents import difference_paid

_CENTS = Decimal("0.01")


@dataclass(frozen=True)
class SelectionQuote:
    """Every number the selection screen shows, and the one it charges."""

    selected_count: int
    included_photos: int
    minimum_photos: int
    currency: str

    # What the whole selection comes to, including what was paid at booking.
    amount_total: Decimal
    # Collected when the booking was made.
    amount_paid: Decimal
    # What submitting right now would charge. Never negative.
    amount_due: Decimal

    # What submitting right now would refund: a selection cheaper than what
    # was paid is refunded the difference, automatically (price_reduction).
    # The final price is the curve's price at the number chosen - never below
    # the minimum selection's, since fewer cannot be submitted.
    refund_amount: Decimal

    # What adding one more photo would add to `amount_due`. Deliberately
    # defined as the change in the charge rather than as the curve's p(n+1):
    # while the total is still under what was already paid, another photo is
    # genuinely free to the client, and quoting the curve price there would
    # be quoting a number nobody is ever charged. None past the point where
    # more photos cannot be added.
    next_photo_price: Decimal | None

    # Non-curve (legacy) bookings only. Zero for curve-priced ones, where
    # `included_photos` is a selection allowance and not a pricing boundary.
    extras_count: int

    @property
    def can_submit(self) -> bool:
        return self.selected_count >= self.minimum_photos

    @property
    def photos_still_needed(self) -> int:
        return max(0, self.minimum_photos - self.selected_count)


def _extra_unit_price(db: Session, *, gig: Gig, gallery: ProofGallery) -> Decimal:
    """The flat per-extra price, for bookings with no curve.

    Imported lazily: client_rewards_pricing pulls in the whole rewards stack,
    and the curve path - which is every new booking - never needs it.
    """
    from app.services.client_rewards_pricing import compute_extra_image_unit_price

    _configured, applied, _min, _max, _tier = compute_extra_image_unit_price(db, gig=gig, gallery=gallery)
    return applied


def _amount_due_for(
    db: Session, *, gig: Gig, gallery: ProofGallery, photo_count: int, already_paid: Decimal = Decimal("0.00")
) -> tuple[Decimal, Decimal, int]:
    """(total, due, extras_count) for a hypothetical selection of `photo_count`.

    `already_paid` is difference money already collected. It is normally zero
    - a completed booking no longer accepts a new selection - but a payment
    that arrived for less than was owed leaves the gallery open with a
    shortfall, and the quote has to name the shortfall, not the whole
    difference, or it would show one price while submit charges another.

    Evaluating this at n and at n+1 is what makes the marginal price exact by
    construction rather than by a second formula that has to be kept in step.
    """
    if photo_count <= 0:
        return Decimal("0.00"), Decimal("0.00"), 0

    if is_curve_priced(gig):
        total = gig_total(db, gig, photo_count)
        due = max(
            Decimal("0.00"), (total - gig.amount_minimum - already_paid).quantize(_CENTS, rounding=ROUND_HALF_UP)
        )
        return total, due, 0

    extras = max(0, photo_count - gallery.included_photos)
    due = (_extra_unit_price(db, gig=gig, gallery=gallery) * Decimal(extras)).quantize(_CENTS, rounding=ROUND_HALF_UP)
    total = (gig.amount_minimum + due).quantize(_CENTS, rounding=ROUND_HALF_UP)
    return total, due, extras


def paid_photo_count(db: Session, *, gig: Gig, gallery: ProofGallery) -> int:
    """How many photos the money collected pays for (owner's rule,
    2026-11-07): a payment is for a count on the booking's own curve, not
    for particular photos. The deposit pays for the minimum selection; every
    difference collected raises the count to the largest n whose price it
    covers. Choosing or switching photos within it costs nothing; past it, the
    client pays price(new count) - what was paid; below it, the rest comes
    back at finish. Money collected beyond price(count) (a part payment, or a
    payment for photos already paid for) still counts towards the next photo
    and, at finish, goes back like any other overpayment."""
    minimum = gig_minimum_selection(gig)
    if not is_curve_priced(gig):
        return minimum
    from app.models.gig import StripePaymentKind
    from app.services.payment_intents import list_succeeded_payments_for_gig, refundable_remaining

    # Kept, not taken: a payment refunded (or being refunded) pays for nothing.
    kept = sum(
        (refundable_remaining(db, p) for p in list_succeeded_payments_for_gig(db, gig.id, kinds=[StripePaymentKind.difference])),
        Decimal("0.00"),
    )
    paid = (gig.amount_minimum + kept).quantize(_CENTS, rounding=ROUND_HALF_UP)
    curve = gig_curve(db, gig)
    limit = max(minimum, gallery_photo_count(db, gallery.id))
    count = minimum
    while count < limit and curve.total(gig.entry_rate, count + 1) <= paid:
        count += 1
    return count


def record_paid_count(db: Session, *, gig: Gig, gallery: ProofGallery) -> int:
    """Keep the booking's paid count in line with the money collected."""
    gig.selection_paid_count = paid_photo_count(db, gig=gig, gallery=gallery)
    return gig.selection_paid_count


def selection_total(db: Session, *, gig: Gig, gallery: ProofGallery, photo_count: int) -> Decimal:
    """What `photo_count` photos come to on this booking, in whole cents: the
    curve and anchor snapshotted on it, or a flat booking's deposit plus its
    extras. Add-ons are priced as the difference of two of these."""
    total, _due, _extras = _amount_due_for(db, gig=gig, gallery=gallery, photo_count=photo_count)
    return total


def selection_minimum(gig: Gig, *, delivered: int) -> int:
    """The fewest photos the client may submit: the package's size, as agreed
    at booking (10 for a booking made before that was stored). A gallery that
    holds fewer than that lowers it to what it holds, never below the
    platform's 10 - a client cannot be asked for photos that were not
    delivered, and choosing all of them is refunded the shortfall as before."""
    required = gig_minimum_selection(gig)
    if delivered < required:
        return max(MINIMUM_PHOTOS, delivered)
    return required


def quote_selection(
    db: Session,
    *,
    gig: Gig,
    gallery: ProofGallery,
    selected_count: int,
    max_photos: int | None = None,
    unrecorded_paid: Decimal = Decimal("0.00"),
) -> SelectionQuote:
    """Price a selection of `selected_count` photos.

    `unrecorded_paid` is difference money Stripe has collected that is not
    recorded yet (a missed webhook): it counts as paid.

    `max_photos` is how many the gallery actually holds; past it there is no
    next photo to price, so `next_photo_price` is None rather than a number
    for a photo that does not exist.
    """
    already_paid = difference_paid(db, gig) + unrecorded_paid if is_curve_priced(gig) else Decimal("0.00")
    minimum = selection_minimum(
        gig, delivered=max_photos if max_photos is not None else gallery_photo_count(db, gallery.id)
    )
    total, due, extras = _amount_due_for(
        db, gig=gig, gallery=gallery, photo_count=selected_count, already_paid=already_paid
    )

    next_price: Decimal | None = None
    if max_photos is None or selected_count < max_photos:
        _next_total, next_due, _next_extras = _amount_due_for(
            db, gig=gig, gallery=gallery, photo_count=selected_count + 1, already_paid=already_paid
        )
        next_price = (next_due - due).quantize(_CENTS, rounding=ROUND_HALF_UP)

    return SelectionQuote(
        selected_count=selected_count,
        included_photos=gallery.included_photos,
        minimum_photos=minimum,
        currency=gallery.currency or gig.currency or "EUR",
        amount_total=total,
        amount_paid=(gig.amount_minimum + already_paid).quantize(_CENTS, rounding=ROUND_HALF_UP),
        amount_due=due,
        refund_amount=max(
            Decimal("0.00"),
            (gig.amount_minimum + already_paid - total).quantize(_CENTS, rounding=ROUND_HALF_UP),
        ) if is_curve_priced(gig) and selected_count >= minimum else Decimal("0.00"),
        next_photo_price=next_price,
        extras_count=extras,
    )


def quote_for_gallery(
    db: Session, *, gallery: ProofGallery, selected_count: int, max_photos: int | None = None
) -> SelectionQuote | None:
    """Convenience for callers holding a gallery but not its gig."""
    gig = db.get(Gig, gallery.gig_id)
    if not gig:
        return None
    return quote_selection(
        db, gig=gig, gallery=gallery, selected_count=selected_count, max_photos=max_photos
    )


def gallery_photo_count(db: Session, gallery_id: uuid.UUID) -> int:
    from sqlalchemy import func, select

    from app.models.gallery import ProofGalleryItem

    return db.execute(
        select(func.count()).select_from(ProofGalleryItem).where(ProofGalleryItem.gallery_id == gallery_id)
    ).scalar_one()
