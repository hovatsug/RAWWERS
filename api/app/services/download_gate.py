"""The review gate: a client's originals wait for a star rating, or a reported problem.

Owner's decision (2026-11-01). Every path that hands a client a full-size
copy - the gallery's downloads (what "Save all" uses) and the single-file
signed URL - asks `require_review_or_report` after its payment check, so the
rule is the server's, not only the app's. Previews, thumbnails and the
selection flow do not ask.

Rating and reporting are allowed only to the booking's client, once the
selection is paid and the photos are delivered (`rating_allowed`): every
review on RAWWERS comes from a real, paid booking.
"""
from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.gallery import ProofGallery
from app.models.gig import Gig, GigStatus
from app.models.review import ProblemReport, Review

#: What the client app looks for to show "Rate your photographer to unlock
#: your photos".
REVIEW_REQUIRED = "review_required"
REVIEW_REQUIRED_MESSAGE = "Rate your photographer to unlock your photos, or report a problem."

#: A booking whose photos have been released to its client.
DELIVERED_STATUSES = frozenset({GigStatus.completed, GigStatus.final_delivered})


def has_rated_or_reported(db: Session, gig: Gig) -> bool:
    """A rating of any status counts (a review an admin later hides was still
    given), and so does a reported problem."""
    rated = db.execute(select(Review.id).where(Review.gig_id == gig.id)).first() is not None
    return rated or db.execute(select(ProblemReport.id).where(ProblemReport.gig_id == gig.id)).first() is not None


def require_review_or_report(db: Session, gig: Gig) -> None:
    """A booking with no niche cannot be rated at all (a review belongs to a
    niche), so it is not gated: asking for a rating nobody can give would
    leave "Report a problem" as the only way to one's own photos. Every
    booking made through the booking flow has its niche."""
    if gig.niche_id is None:
        return
    if not has_rated_or_reported(db, gig):
        raise APIError(code=REVIEW_REQUIRED, message=REVIEW_REQUIRED_MESSAGE, status_code=403)


def rating_allowed(db: Session, gig: Gig) -> bool:
    """The selection is paid and the photos delivered: the booking is
    complete, and its gallery has released finals to the client."""
    if gig.status not in DELIVERED_STATUSES:
        return False
    from app.services.media_rights import unlocked_final_asset_ids

    gallery = db.execute(select(ProofGallery).where(ProofGallery.gig_id == gig.id)).scalar_one_or_none()
    return gallery is not None and bool(unlocked_final_asset_ids(db, gallery=gallery))
