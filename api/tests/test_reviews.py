import uuid
from decimal import Decimal

import pytest

from app.models.discovery import ProPublicIndex
from app.models.gig import Gig, GigStatus
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.models.niche import Niche
from app.models.review import ProReputation, Review, ReviewStatus
from app.services.discovery_index import recompute_pro_public_index
from app.services.reputation import recompute_pro_reputation


def _create_gig(db_session, client_id: str, pro_id: str, status: GigStatus = GigStatus.completed) -> Gig:
    niche_id = db_session.query(Niche).filter_by(slug="portraits").first().id
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=niche_id,
        status=status,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.commit()
    db_session.refresh(gig)
    return gig


def test_cannot_review_without_completed_gig(client, db_session, monkeypatch):
    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_args, **_kwargs: None)

    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id, status=GigStatus.paid)

    resp = client.post(
        f"/v1/gigs/{gig.id}/review",
        headers={"X-User-Id": client_id},
        json={"rating": 5, "tags": ["punctual"], "would_book_again": True},
    )
    assert resp.status_code == 409


def test_only_one_review_per_gig(client, db_session, monkeypatch):
    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_args, **_kwargs: None)

    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id, status=GigStatus.completed)

    first = client.post(
        f"/v1/gigs/{gig.id}/review",
        headers={"X-User-Id": client_id},
        json={"rating": 5, "tags": ["creative"], "would_book_again": True},
    )
    assert first.status_code == 200

    second = client.post(
        f"/v1/gigs/{gig.id}/review",
        headers={"X-User-Id": client_id},
        json={"rating": 4, "tags": ["creative"], "would_book_again": True},
    )
    assert second.status_code == 409


@pytest.mark.parametrize(
    "tags",
    [{"tags": None}, {}, {"tags": []}],
    ids=["tags-null", "tags-omitted", "tags-empty"],
)
def test_a_review_without_tags_is_accepted(client, db_session, monkeypatch, tags):
    """The client app sends `"tags": null` when no tag was picked: all three
    forms of "no tags" are a review with no tags, not a 422."""
    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_args, **_kwargs: None)
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, str(uuid.uuid4()), status=GigStatus.completed)

    resp = client.post(
        f"/v1/gigs/{gig.id}/review",
        headers={"X-User-Id": client_id},
        json={"rating": 5, "text": None, "would_book_again": True, "video_media_asset_id": None, **tags},
    )

    assert resp.status_code == 200, resp.text
    assert resp.json()["tags"] == []
    stored = db_session.query(Review).filter_by(gig_id=gig.id).one()
    assert stored.tags == []


def test_client_cannot_attach_foreign_video_media_asset(client, db_session, monkeypatch):
    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_args, **_kwargs: None)

    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    foreign_owner = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id, status=GigStatus.completed)

    foreign_asset = MediaAsset(
        owner_user_id=uuid.UUID(foreign_owner),
        kind=MediaKind.video,
        purpose=MediaPurpose.video_review,
        provider=MediaProvider.mux,
        status=MediaStatus.ready,
        visibility=MediaVisibility.owner_only,
        meta={"playback_id": "pb_foreign"},
    )
    db_session.add(foreign_asset)
    db_session.commit()

    resp = client.post(
        f"/v1/gigs/{gig.id}/review",
        headers={"X-User-Id": client_id},
        json={
            "rating": 5,
            "tags": ["punctual"],
            "would_book_again": True,
            "video_media_asset_id": str(foreign_asset.id),
        },
    )
    assert resp.status_code == 403


def test_admin_moderation_affects_reputation(client, db_session, monkeypatch):
    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_args, **_kwargs: None)

    admin_id = "00000000-0000-0000-0000-0000000000aa"
    client_a = str(uuid.uuid4())
    client_b = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())

    gig_a = _create_gig(db_session, client_a, pro_id, status=GigStatus.completed)
    gig_b = _create_gig(db_session, client_b, pro_id, status=GigStatus.completed)

    r1 = client.post(
        f"/v1/gigs/{gig_a.id}/review",
        headers={"X-User-Id": client_a},
        json={"rating": 5, "tags": ["punctual"], "would_book_again": True},
    )
    assert r1.status_code == 200
    review_1_id = r1.json()["id"]

    r2 = client.post(
        f"/v1/gigs/{gig_b.id}/review",
        headers={"X-User-Id": client_b},
        json={"rating": 1, "tags": ["late"], "would_book_again": False},
    )
    assert r2.status_code == 200

    rep = db_session.get(ProReputation, uuid.UUID(pro_id))
    assert rep is not None
    assert rep.review_count == 2
    assert rep.avg_rating == Decimal("3.00")

    mod = client.post(
        f"/v1/admin/reviews/{review_1_id}/moderate",
        headers={"X-User-Id": admin_id},
        json={"action": "hidden", "reason": "policy"},
    )
    assert mod.status_code == 200

    db_session.expire_all()
    rep_after = db_session.get(ProReputation, uuid.UUID(pro_id))
    assert rep_after is not None
    assert rep_after.review_count == 1
    assert rep_after.avg_rating == Decimal("1.00")


def test_pro_public_index_updated_with_review_signals(db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id, status=GigStatus.completed)

    db_session.add(
        Review(
            gig_id=gig.id,
            pro_user_id=uuid.UUID(pro_id),
            client_user_id=uuid.UUID(client_id),
            niche_id=gig.niche_id,
            rating=5,
            tags=["creative"],
            would_book_again=True,
            status=ReviewStatus.published,
        )
    )
    db_session.commit()

    recompute_pro_reputation(db_session, uuid.UUID(pro_id))
    idx = recompute_pro_public_index(db_session, uuid.UUID(pro_id))
    db_session.commit()

    assert idx.avg_rating == Decimal("5.00")
    assert idx.review_count == 1
    persisted = db_session.get(ProPublicIndex, uuid.UUID(pro_id))
    assert persisted is not None
    assert persisted.avg_rating == Decimal("5.00")
    assert persisted.review_count == 1


# ---------------------------------------------------------------------------
# The public list must not say who wrote a review.
#
# It needs no sign-in. Carrying client_user_id and gig_id let anyone link a
# client's account to a booking with a named photographer - a visibility no
# client opted into. A review is shown as a verified booking, with the niche
# it was in and when.
# ---------------------------------------------------------------------------


def _post_review(client, gig, client_id, **body):
    resp = client.post(
        f"/v1/gigs/{gig.id}/review",
        headers={"X-User-Id": client_id},
        json={"rating": 5, "would_book_again": True, **body},
    )
    assert resp.status_code == 200, resp.text
    return resp.json()


def test_the_public_list_does_not_identify_the_client_or_the_booking(client, db_session, monkeypatch):
    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_a, **_k: None)
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    _post_review(client, gig, client_id, text="Lovely afternoon")

    # Signed out: no X-User-Id at all.
    resp = client.get(f"/v1/pros/{pro_id}/reviews")
    assert resp.status_code == 200
    item = resp.json()["items"][0]

    assert "client_user_id" not in item, "a signed-out visitor can see who wrote the review"
    assert "gig_id" not in item, "a signed-out visitor can see which booking it was"
    raw = resp.text
    assert client_id not in raw and str(gig.id) not in raw, "the client or booking id leaked elsewhere in the payload"


def test_a_public_review_says_what_it_is_verified_by(client, db_session, monkeypatch):
    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_a, **_k: None)
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    _post_review(client, gig, client_id, rating=4, text="Great light", would_book_again=False)

    item = client.get(f"/v1/pros/{pro_id}/reviews").json()["items"][0]
    assert item["rating"] == 4
    assert item["text"] == "Great light"
    assert item["would_book_again"] is False
    assert item["niche"] == {"slug": "portraits", "name": "Portraits"}
    assert item["created_at"]
    assert item["id"], "the photographer needs the id to reply"


def test_a_reply_still_appears_on_the_public_list(client, db_session, monkeypatch):
    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_a, **_k: None)
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    review = _post_review(client, gig, client_id)

    reply = client.post(f"/v1/reviews/{review['id']}/reply", headers={"X-User-Id": pro_id}, json={"text": "Thank you!"})
    assert reply.status_code == 200, reply.text

    item = client.get(f"/v1/pros/{pro_id}/reviews").json()["items"][0]
    assert item["reply"]["text"] == "Thank you!"


# ---------------------------------------------------------------------------
# The booking says whether its client has reviewed it.
#
# Without this the app could only find out by paging through the
# photographer's public list - which fails once there are many reviews, and
# lies when a moderator has hidden one: the form comes back, and submitting
# it gets "already exists".
# ---------------------------------------------------------------------------


def _reviewable_booking(db_session, client_id, pro_id):
    """A booking whose gig is completed, linked the way acceptance links them."""
    from datetime import datetime, timedelta, timezone

    from app.models.booking import BookingRequest, BookingRequestStatus

    from tests.test_client_gallery_access import _package

    now = datetime.now(timezone.utc)
    gig = _create_gig(db_session, client_id, pro_id, status=GigStatus.completed)
    booking = BookingRequest(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        package_id=_package(db_session, pro_id).id,
        status=BookingRequestStatus.accepted,
        requested_start=now - timedelta(days=3),
        requested_end=now - timedelta(days=3) + timedelta(hours=2),
        expires_at=now + timedelta(days=1),
    )
    db_session.add(booking)
    db_session.flush()
    gig.meta = {**(gig.meta or {}), "booking_request_id": str(booking.id)}
    db_session.commit()
    db_session.refresh(gig)
    db_session.refresh(booking)
    return booking, gig


def _booking_detail(client, booking, user_id):
    resp = client.get(f"/v1/client/bookings/{booking.id}", headers={"X-User-Id": user_id})
    assert resp.status_code == 200, resp.text
    return resp.json()


def test_an_unreviewed_booking_says_so(client, db_session):
    from tests.test_booking_close import _ensure_account

    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    booking, _gig = _reviewable_booking(db_session, client_id, pro_id)

    assert _booking_detail(client, booking, client_id)["review"] is None


def test_a_reviewed_booking_carries_the_clients_own_review(client, db_session, monkeypatch):
    from tests.test_booking_close import _ensure_account

    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_a, **_k: None)
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    booking, gig = _reviewable_booking(db_session, client_id, pro_id)
    posted = _post_review(client, gig, client_id, rating=3, text="Fine", would_book_again=False)
    client.post(f"/v1/reviews/{posted['id']}/reply", headers={"X-User-Id": pro_id}, json={"text": "Sorry to hear"})

    review = _booking_detail(client, booking, client_id)["review"]
    assert review["id"] == posted["id"]
    assert (review["rating"], review["text"], review["would_book_again"]) == (3, "Fine", False)
    assert review["status"] == "published"
    assert review["reply"]["text"] == "Sorry to hear"


def test_a_hidden_review_is_still_the_clients_review(client, db_session, monkeypatch):
    """The case paging the public list gets wrong: moderation removes it from
    the list, and the client must still see that they reviewed this - not be
    offered a form whose submission is refused."""
    from tests.test_booking_close import _ensure_account

    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_a, **_k: None)
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    booking, gig = _reviewable_booking(db_session, client_id, pro_id)
    posted = _post_review(client, gig, client_id)

    mod = client.post(
        f"/v1/admin/reviews/{posted['id']}/moderate",
        headers={"X-User-Id": "00000000-0000-0000-0000-0000000000aa"},
        json={"action": "hidden", "reason": "policy"},
    )
    assert mod.status_code == 200
    assert client.get(f"/v1/pros/{pro_id}/reviews").json()["items"] == []

    review = _booking_detail(client, booking, client_id)["review"]
    assert review is not None and review["status"] == "hidden"


def test_the_photographer_does_not_see_the_clients_review_through_the_booking(client, db_session, monkeypatch):
    """The booking detail is readable by both sides; the review on it is the
    client's own record. The photographer reads reviews from the public list
    like everyone else."""
    from tests.test_booking_close import _ensure_account

    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_a, **_k: None)
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    booking, gig = _reviewable_booking(db_session, client_id, pro_id)
    _post_review(client, gig, client_id)

    assert _booking_detail(client, booking, pro_id)["review"] is None
