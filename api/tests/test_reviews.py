import uuid
from decimal import Decimal

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
        amount_total=Decimal("100.00"),
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
