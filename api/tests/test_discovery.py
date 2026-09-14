import uuid
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import ProPackage
from app.models.discovery import AnalyticsEvent
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.models.niche import Niche
from app.services.discovery_index import _compute_ranking_score, recompute_pro_public_index


def _seed_pro(db_session, *, approved: bool = True, accepting: bool = True, completeness: int = 80) -> str:
    pro_id = str(uuid.uuid4())
    uid = uuid.UUID(pro_id)
    db_session.add(UserAccount(user_id=uid))
    # The profile below points at this row, and a single flush does not
    # reliably insert the parent first - so make it explicit.
    db_session.flush()
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
    # Being discoverable takes two independent gates, not one. The profile's
    # kyc_status is what these tests vary; ProOnboarding.approved_public is a
    # separate publish gate that GET /v1/discover/pros enforces with a join,
    # and this fixture never created the row - so the join dropped every pro
    # and the endpoint returned nothing at all. Both pros get it here, so
    # exclusion is decided by the thing under test rather than by an absent
    # onboarding record.
    db_session.add(
        ProOnboarding(
            pro_user_id=uid,
            status=ProOnboardingStatus.approved_public,
            current_city={"city": "Lisbon", "country": "PT"},
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

    # The starting total, not the per-photo rate. This asserted 80.00 - the
    # entry rate - which is what every client-facing screen then rendered as
    # the price of a booking. 800.00 is what the cheapest complete booking
    # actually costs: ten photos at 80.00, the flat minimum bundle.
    assert idx.min_package_price == Decimal("800.00")
    assert idx.max_package_price == Decimal("1500.00")
    assert idx.portfolio_photo_count == 1
    assert idx.portfolio_video_count == 1


def test_analytics_endpoint_stores_and_rejects_invalid(client, db_session):
    valid = client.post("/v1/analytics", json={"event_name": "discover.search", "properties": {"q": "lisbon"}})
    assert valid.status_code == 200

    count = db_session.query(AnalyticsEvent).filter_by(event_name="discover.search").count()
    assert count == 1

    invalid = client.post("/v1/analytics", json={"event_name": "spam.bad", "properties": {}})
    assert invalid.status_code == 422


def test_the_card_rate_belongs_to_the_package_its_total_came_from(db_session):
    """The cheapest package is not always the one with the cheapest rate.

    A low rate over many photos beats a high rate over ten, so taking min()
    over the rates and min() over the totals independently can pick two
    different packages - and a card would then show a rate from one beside a
    total from another, describing a package nobody can book.
    """
    import uuid as _uuid
    from decimal import Decimal

    from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
    from app.models.booking import ProPackage
    from app.models.discovery import ProPublicIndex
    from app.models.niche import Niche
    from app.services.discovery_index import recompute_pro_public_index
    from app.services.niche_catalog import ensure_initial_niches
    from app.services.package_pricing import compute_minimum_amount
    from sqlalchemy import select

    ensure_initial_niches(db_session)
    niche = db_session.execute(select(Niche).where(Niche.slug == "portraits")).scalar_one()

    pro_id = _uuid.uuid4()
    db_session.add(UserAccount(user_id=pro_id))
    db_session.flush()
    db_session.add(UserRole(user_id=pro_id, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=pro_id, display_name="Two Packages", city="Lisbon", country="PT"))
    db_session.flush()

    def _package(price: str, photos: int) -> ProPackage:
        return ProPackage(
            pro_user_id=pro_id,
            niche_id=niche.id,
            title=f"{photos} photos",
            duration_minutes=60,
            price=Decimal(price),
            currency="EUR",
            included_photos=photos,
            extra_photo_price=Decimal("5.00"),
            proofs_sla_days=3,
            finals_sla_days=7,
            addons=[],
            is_active=True,
        )

    # A cheap rate over a large shoot, and a dearer rate over the minimum.
    big = _package("4.00", 60)
    small = _package("9.00", 10)
    db_session.add_all([big, small])
    db_session.commit()

    recompute_pro_public_index(db_session, pro_id)
    db_session.commit()

    index = db_session.get(ProPublicIndex, pro_id)
    totals = {
        p.id: compute_minimum_amount(
            db_session, niche_id=p.niche_id, entry_rate=p.price, included_photos=p.included_photos
        )
        for p in (big, small)
    }
    cheapest = min(totals, key=lambda k: totals[k])
    expected_rate = big.price if cheapest == big.id else small.price

    assert index.min_package_price == totals[cheapest]
    assert index.min_entry_rate == expected_rate, (
        f"the card would show {index.min_entry_rate}/photo beside a total of "
        f"{index.min_package_price}, which no package offers"
    )
