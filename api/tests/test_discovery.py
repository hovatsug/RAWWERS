import uuid
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import ProPackage
from app.models.discovery import AnalyticsEvent
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.models.niche import Niche
from app.services.discovery_index import _compute_ranking_score, recompute_pro_public_index


def _seed_pro(db_session, *, approved: bool = True, accepting: bool = True, completeness: int = 80) -> str:
    pro_id = str(uuid.uuid4())
    uid = uuid.UUID(pro_id)
    db_session.add(UserAccount(user_id=uid))
    db_session.add(UserRole(user_id=uid, role=UserRoleType.pro))
    db_session.add(
        ProProfile(
            user_id=uid,
            display_name="Pro",
            city="Lisbon",
            country="PT",
            styles=["editorial"],
            is_accepting_bookings=accepting,
            completeness_score=completeness,
            kyc_status=KYCStatus.approved if approved else KYCStatus.pending,
        )
    )
    db_session.commit()
    return pro_id


def test_discover_filters_only_approved_active(client, db_session):
    allowed_pro = _seed_pro(db_session, approved=True, accepting=True, completeness=90)
    blocked_pro = _seed_pro(db_session, approved=False, accepting=True, completeness=90)
    niche_id = db_session.query(Niche).filter_by(slug="portraits").first().id

    db_session.add(
        ProPackage(
            pro_user_id=uuid.UUID(allowed_pro),
            niche_id=niche_id,
            title="Pkg",
            duration_minutes=60,
            price=Decimal("100.00"),
            currency="EUR",
            included_photos=10,
            extra_photo_price=Decimal("10.00"),
            proofs_sla_days=3,
            finals_sla_days=7,
            addons=[],
            is_active=True,
        )
    )
    db_session.add(
        ProPackage(
            pro_user_id=uuid.UUID(blocked_pro),
            niche_id=niche_id,
            title="Pkg",
            duration_minutes=60,
            price=Decimal("100.00"),
            currency="EUR",
            included_photos=10,
            extra_photo_price=Decimal("10.00"),
            proofs_sla_days=3,
            finals_sla_days=7,
            addons=[],
            is_active=True,
        )
    )
    db_session.commit()

    recompute_pro_public_index(db_session, uuid.UUID(allowed_pro))
    recompute_pro_public_index(db_session, uuid.UUID(blocked_pro))
    db_session.commit()

    resp = client.get("/v1/discover/pros")
    assert resp.status_code == 200
    ids = {item["pro_user_id"] for item in resp.json()["items"]}
    assert allowed_pro in ids
    assert blocked_pro not in ids


def test_ranking_score_deterministic():
    score = _compute_ranking_score(
        completeness_score=80,
        portfolio_total=10,
        gigs_completed=5,
        gigs_cancelled=1,
        disputes_count=0,
        avg_response_minutes=50,
    )
    # deterministic numeric(10,4) value
    assert str(score) == "176.9790"


def test_reindex_updates_price_and_portfolio_counts(db_session):
    pro_id = _seed_pro(db_session, approved=True, accepting=True, completeness=95)
    pro_uuid = uuid.UUID(pro_id)
    niche_id = db_session.query(Niche).filter_by(slug="portraits").first().id

    db_session.add_all(
        [
            ProPackage(
                pro_user_id=pro_uuid,
                niche_id=niche_id,
                title="A",
                duration_minutes=30,
                price=Decimal("80.00"),
                currency="EUR",
                included_photos=5,
                extra_photo_price=Decimal("8.00"),
                proofs_sla_days=3,
                finals_sla_days=7,
                addons=[],
                is_active=True,
            ),
            ProPackage(
                pro_user_id=pro_uuid,
                niche_id=niche_id,
                title="B",
                duration_minutes=60,
                price=Decimal("150.00"),
                currency="EUR",
                included_photos=10,
                extra_photo_price=Decimal("10.00"),
                proofs_sla_days=3,
                finals_sla_days=7,
                addons=[],
                is_active=True,
            ),
            MediaAsset(
                owner_user_id=pro_uuid,
                kind=MediaKind.photo,
                purpose=MediaPurpose.portfolio_reel,
                provider=MediaProvider.r2,
                status=MediaStatus.ready,
                visibility=MediaVisibility.owner_only,
                meta={},
            ),
            MediaAsset(
                owner_user_id=pro_uuid,
                kind=MediaKind.video,
                purpose=MediaPurpose.portfolio_reel,
                provider=MediaProvider.mux,
                status=MediaStatus.ready,
                visibility=MediaVisibility.owner_only,
                meta={"playback_id": "pb_1"},
            ),
        ]
    )
    db_session.commit()

    idx = recompute_pro_public_index(db_session, pro_uuid)
    db_session.commit()

    assert idx.min_package_price == Decimal("80.00")
    assert idx.max_package_price == Decimal("150.00")
    assert idx.portfolio_photo_count == 1
    assert idx.portfolio_video_count == 1


def test_analytics_endpoint_stores_and_rejects_invalid(client, db_session):
    valid = client.post("/v1/analytics", json={"event_name": "discover.search", "properties": {"q": "lisbon"}})
    assert valid.status_code == 200

    count = db_session.query(AnalyticsEvent).filter_by(event_name="discover.search").count()
    assert count == 1

    invalid = client.post("/v1/analytics", json={"event_name": "spam.bad", "properties": {}})
    assert invalid.status_code == 422
