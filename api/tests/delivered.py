"""A booking whose photos really were paid for and delivered.

The review gate (download_gate.rating_allowed) lets a client rate only a
booking whose selection is paid and whose photos the server has released.
Tests that only set `status=completed` on a bare gig describe a booking that
cannot exist; `deliver` gives one the rest: the base payment, a gallery with
one photo, and that photo chosen in a submitted selection.
"""

from decimal import Decimal

from app.models.gallery import ClientSelection, ClientSelectionItem, ProofGallery, ProofGalleryItem, ProofGalleryStatus, SelectionStatus
from app.models.gig import Gig, PaymentStatus, StripePayment, StripePaymentKind
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility


def deliver(db_session, gig: Gig) -> ProofGallery:
    db_session.add(
        StripePayment(
            gig_id=gig.id, kind=StripePaymentKind.base, client_user_id=gig.client_user_id, status=PaymentStatus.succeeded,
            stripe_payment_intent_id=f"pi_base_{gig.id.hex}", amount=gig.amount_minimum, currency=gig.currency or "EUR", meta={},
        )
    )
    gallery = ProofGallery(
        gig_id=gig.id, pro_user_id=gig.pro_user_id, client_user_id=gig.client_user_id, included_photos=10,
        extra_photo_price=Decimal("5.00"), currency=gig.currency or "EUR", status=ProofGalleryStatus.selection_submitted,
    )
    db_session.add(gallery)
    asset = MediaAsset(
        owner_user_id=gig.pro_user_id, kind=MediaKind.photo, purpose=MediaPurpose.proof, provider=MediaProvider.r2,
        status=MediaStatus.ready, visibility=MediaVisibility.client_only, content_type="image/jpeg", meta={},
    )
    db_session.add(asset)
    db_session.flush()
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=1))
    selection = ClientSelection(gallery_id=gallery.id, client_user_id=gig.client_user_id, version=1, status=SelectionStatus.submitted)
    db_session.add(selection)
    db_session.flush()
    db_session.add(ClientSelectionItem(selection_id=selection.id, media_asset_id=asset.id))
    db_session.commit()
    return gallery





def rate(db_session, gig: Gig, rating: int = 5) -> None:
    """The client's star rating, which the review gate asks for before any
    original is released (tests/test_review_gate.py covers the gate itself)."""
    from app.models.review import Review

    if gig.niche_id is None:
        return  # not gated: a booking with no niche cannot be rated
    db_session.add(Review(gig_id=gig.id, pro_user_id=gig.pro_user_id, client_user_id=gig.client_user_id, niche_id=gig.niche_id, rating=rating, tags=[]))
    db_session.commit()
