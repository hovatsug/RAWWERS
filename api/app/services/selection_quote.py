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
from app.services.package_pricing import MINIMUM_PHOTOS, compute_package_total, is_curve_priced

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
    # What submitting right now would charge. Never negative: a selection
    # cheaper than the deposit does not refund, it just owes nothing.
    amount_due: Decimal

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


def _amount_due_for(db: Session, *, gig: Gig, gallery: ProofGallery, photo_count: int) -> tuple[Decimal, Decimal, int]:
    """(total, due, extras_count) for a hypothetical selection of `photo_count`.

    Evaluating this at n and at n+1 is what makes the marginal price exact by
    construction rather than by a second formula that has to be kept in step.
    """
    if photo_count <= 0:
        return Decimal("0.00"), Decimal("0.00"), 0

    if is_curve_priced(gig):
        total = compute_package_total(
            db, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=photo_count
        )
        due = max(Decimal("0.00"), (total - gig.amount_minimum).quantize(_CENTS, rounding=ROUND_HALF_UP))
        return total, due, 0

    extras = max(0, photo_count - gallery.included_photos)
    due = (_extra_unit_price(db, gig=gig, gallery=gallery) * Decimal(extras)).quantize(_CENTS, rounding=ROUND_HALF_UP)
    total = (gig.amount_minimum + due).quantize(_CENTS, rounding=ROUND_HALF_UP)
    return total, due, extras


def quote_selection(
    db: Session,
    *,
    gig: Gig,
    gallery: ProofGallery,
    selected_count: int,
    max_photos: int | None = None,
) -> SelectionQuote:
    """Price a selection of `selected_count` photos.

    `max_photos` is how many the gallery actually holds; past it there is no
    next photo to price, so `next_photo_price` is None rather than a number
    for a photo that does not exist.
    """
    total, due, extras = _amount_due_for(db, gig=gig, gallery=gallery, photo_count=selected_count)

    next_price: Decimal | None = None
    if max_photos is None or selected_count < max_photos:
        _next_total, next_due, _next_extras = _amount_due_for(
            db, gig=gig, gallery=gallery, photo_count=selected_count + 1
        )
        next_price = (next_due - due).quantize(_CENTS, rounding=ROUND_HALF_UP)

    return SelectionQuote(
        selected_count=selected_count,
        included_photos=gallery.included_photos,
        minimum_photos=MINIMUM_PHOTOS,
        currency=gallery.currency or gig.currency or "EUR",
        amount_total=total,
        amount_paid=gig.amount_minimum,
        amount_due=due,
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
