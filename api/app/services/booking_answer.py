"""Whether a photographer may answer a booking request with a booking.

Accept and confirm-slot both turn a request into its gig. They used to
decide that separately, and confirm-slot did not decide it at all: it checked
neither the request's status nor its deadline, so a photographer could make
an unpaid booking out of a request the client had withdrawn, one they had
declined themselves, or one long expired - and skip the KYC check accept
makes. One function now, asked by both, before anything is written.
"""
from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile
from app.models.booking import BookingRequest, BookingRequestStatus
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.services.pro_standing import PAUSED, booking_block_reason

_GONE = {
    BookingRequestStatus.expired: ("request_expired", "This request has expired."),
    BookingRequestStatus.declined: ("request_declined", "This request was declined."),
    BookingRequestStatus.cancelled: ("request_cancelled", "The client withdrew this request."),
}


def ensure_request_can_be_booked(db: Session, request: BookingRequest) -> None:
    """Refuse, with a distinct reason, unless `request` may become a booking
    now: its photographer may take bookings, and it is either pending inside
    its deadline or already accepted (answering again returns its own gig).

    Checks the request's state only after the photographer's standing, so a
    photographer who may not take bookings learns that rather than a detail
    about one request.
    """
    _ensure_photographer_may_take_bookings(db, request)

    if request.status == BookingRequestStatus.accepted:
        return
    if request.status in _GONE:
        code, message = _GONE[request.status]
        raise APIError(code=code, message=message, status_code=409)
    if request.status != BookingRequestStatus.pending:
        raise APIError(code="invalid_state", message="This request cannot be answered.", status_code=409)
    # Past its deadline but not yet swept: expired in all but name.
    if request.expires_at < datetime.now(timezone.utc):
        code, message = _GONE[BookingRequestStatus.expired]
        raise APIError(code=code, message=message, status_code=409)


def _ensure_photographer_may_take_bookings(db: Session, request: BookingRequest) -> None:
    settings = get_settings()
    # Before anything else, and whatever BAN_ENFORCEMENT_MODE says.
    blocked = booking_block_reason(db, request.pro_user_id)
    if blocked == PAUSED:
        raise APIError(code="bookings_paused", message="New bookings are paused on your account until an admin reviews it.", status_code=409)
    if blocked is not None:
        raise APIError(code="pro_shut_out", message="Your account is suspended, so you cannot take bookings.", status_code=409)
    profile = db.get(ProProfile, request.pro_user_id)
    unverified_allowed = settings.app_env.lower() in {"dev", "development"} and settings.allow_unverified_pro
    if (profile is None or profile.kyc_status != KYCStatus.approved) and not unverified_allowed:
        raise APIError(code="kyc_required", message="Pro KYC must be approved", status_code=409)
    onboarding = db.get(ProOnboarding, request.pro_user_id)
    if onboarding is None or onboarding.status != ProOnboardingStatus.approved_public:
        raise APIError(
            code="pro_not_live",
            message="Your profile is not live yet, so you cannot take bookings.",
            status_code=409,
        )
