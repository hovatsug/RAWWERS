"""The gig a booking request becomes - built in one place.

Accept and confirm-slot each built it, and drifted: confirm-slot's gig
carried no pricing snapshot, no scheduling preset and no niche, which every
later step (confirming, paying, other bookings' buffers, the invoice) reads
from the gig. Both now call build_gig_for_request.
"""
from __future__ import annotations

import uuid
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.booking import BookingRequest, ProPackage
from app.models.gig import Gig, GigStatus
from app.models.niche import Niche
from app.services.bookable_time import request_preset
from app.services.commission import split_for_pro, vat_stamp_for
from app.services.package_pricing import compute_minimum_amount


def find_gig_for_request(db: Session, booking_request_id: uuid.UUID) -> Gig | None:
    """The gig made from this request, if any. One query - this used to load
    every gig in the database and compare in Python."""
    return db.execute(
        select(Gig).where(Gig.meta["booking_request_id"].astext == str(booking_request_id)).limit(1)
    ).scalar_one_or_none()


def build_gig_for_request(
    db: Session,
    request: BookingRequest,
    *,
    client_credit_percent_override: Decimal | None = None,
) -> Gig:
    """A new, unsaved payment_pending gig for `request`, priced and split as
    of now. The caller adds it; whether the request may be booked at all is
    ensure_request_can_be_booked's question, asked before this."""
    package = db.get(ProPackage, request.package_id)
    if not package:
        raise APIError(code="validation_error", message="Package no longer exists", status_code=409)

    entry_rate = package.price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    amount_minimum = compute_minimum_amount(db, niche_id=package.niche_id, entry_rate=entry_rate, included_photos=package.included_photos)
    # One source for the rate. This read settings.platform_fee_bps while
    # earnings were computed from the admin-editable policy row - two
    # definitions of one number, agreeing only because nobody had changed
    # either of them.
    split = split_for_pro(
        db,
        gross=amount_minimum,
        pro_user_id=request.pro_user_id,
        client_credit_percent_override=client_credit_percent_override,
    )

    snapshot = {
        "package_id": str(package.id),
        "niche_slug": None,
        "niche_name": None,
        "package_title": package.title,
        "duration_minutes": package.duration_minutes,
        "included_photos": package.included_photos,
        "extra_photo_price": str(package.extra_photo_price),
        "proofs_sla_days": package.proofs_sla_days,
        "finals_sla_days": package.finals_sla_days,
        "addons": package.addons,
        "booking_request_id": str(request.id),
    }
    niche = db.get(Niche, package.niche_id)
    if niche:
        snapshot["niche_slug"] = niche.slug
        snapshot["niche_name"] = niche.name

    return Gig(
        client_user_id=request.client_user_id,
        pro_user_id=request.pro_user_id,
        status=GigStatus.payment_pending,
        niche_id=package.niche_id,
        currency=package.currency,
        amount_minimum=amount_minimum,
        entry_rate=entry_rate,
        amount_platform_fee=split.platform_total,
        amount_pro_gross=split.pro_total,
        # Recorded, not looked up later. An invoice a year from now must show
        # the split this booking was actually created under, whatever the
        # policy says by then.
        fee_percent=split.fee_percent,
        retained_percent=split.retained_percent,
        pro_raww_percent=split.pro_raww_percent,
        client_credit_percent=split.client_credit_percent,
        **vat_stamp_for(db, pro_user_id=request.pro_user_id),
        scheduled_start=request.requested_start,
        scheduled_end=request.requested_end,
        location_text=request.location_text,
        meta={
            "pricing_snapshot": snapshot,
            "booking_request_id": str(request.id),
            # Carried from the request: every later check on this booking
            # (confirming a slot, paying, others' buffers) reads it from here.
            "scheduling_preset": request_preset(request).value,
            "niche_slug": snapshot["niche_slug"],
            "niche_name": snapshot["niche_name"],
        },
    )
