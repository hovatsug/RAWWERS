import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import ProPackage
from app.models.gig import Gig, GigStatus
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.models.niche import CertificationRecord, Niche, ProNicheSkill, SkillTier
from app.models.review import Review, ReviewStatus
from app.services.discovery_index import recompute_pro_public_index
from app.services.niche_skills import recompute_pro_niche_skill


class DummyStripePI:
    def __init__(self, pi_id="pi_br_1", client_secret="sec_br_1", status="requires_payment_method"):
        self.id = pi_id
        self.client_secret = client_secret
        self.status = status


def _ensure_user_role(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()
    exists = db_session.query(UserRole).filter_by(user_id=uid, role=role).first()
    if not exists:
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()


def _seed_pro_profile(db_session, pro_id: str):
    pid = uuid.UUID(pro_id)
    profile = db_session.get(ProProfile, pid)
    if not profile:
        profile = ProProfile(user_id=pid)
        db_session.add(profile)
    profile.kyc_status = KYCStatus.approved
    profile.display_name = "Pro"
    profile.headline = "Portrait"
    profile.bio = "Long bio"
    profile.city = "Lisbon"
    profile.country = "PT"
    profile.languages = ["en"]
    profile.styles = ["editorial"]
    profile.gear = {"camera": "A7"}
    profile.completeness_score = 100
    profile.is_accepting_bookings = True
    db_session.commit()


def test_package_creation_requires_niche(client, db_session):
    pro_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _seed_pro_profile(db_session, pro_id)

    resp = client.post(
        "/v1/pro/me/packages",
        headers={"X-User-Id": pro_id},
        json={
            "title": "Mini Session",
            "duration_minutes": 60,
            "price": "120.00",
            "currency": "EUR",
            "included_photos": 10,
            "extra_photo_price": "8.00",
            "proofs_sla_days": 3,
            "finals_sla_days": 7,
            "addons": [],
        },
    )
    assert resp.status_code == 400


def test_invalid_niche_slug_is_rejected(client, db_session):
    pro_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _seed_pro_profile(db_session, pro_id)

    resp = client.put(
        "/v1/pro/me/niches",
        headers={"X-User-Id": pro_id},
        json={"primary_niche_slug": "does_not_exist", "niches": []},
    )
    assert resp.status_code == 422


def test_accept_booking_sets_gig_niche_snapshot(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _ensure_user_role(db_session, client_id, UserRoleType.client)
    _seed_pro_profile(db_session, pro_id)

    client.post(
        "/v1/pro/me/availability/rules",
        headers={"X-User-Id": pro_id},
        json={"rules": [{"day_of_week": 0, "start_time": "09:00:00", "end_time": "17:00:00"}]},
    )
    pkg = client.post(
        "/v1/pro/me/packages",
        headers={"X-User-Id": pro_id},
        json={
            "title": "Mini Session",
            "niche_slug": "weddings",
            "duration_minutes": 60,
            "price": "120.00",
            "currency": "EUR",
            "included_photos": 10,
            "extra_photo_price": "8.00",
            "proofs_sla_days": 3,
            "finals_sla_days": 7,
            "addons": [],
        },
    )
    assert pkg.status_code == 200
    pkg_id = pkg.json()["id"]

    req_start = datetime(2026, 3, 2, 11, 0, tzinfo=timezone.utc)
    req_end = req_start + timedelta(hours=1)
    br = client.post(
        f"/v1/pros/{pro_id}/booking-requests",
        headers={"X-User-Id": client_id},
        json={"package_id": pkg_id, "requested_start": req_start.isoformat(), "requested_end": req_end.isoformat()},
    )
    assert br.status_code == 200
    br_id = br.json()["id"]

    monkeypatch.setattr(
        "app.services.payment_intents.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripePI("pi_accept_1", "sec_accept_1"),
    )
    monkeypatch.setattr("app.services.payment_intents.stripe.PaymentIntent.retrieve", lambda pi_id: DummyStripePI(pi_id, "sec_accept_1"))

    accept = client.post(f"/v1/booking-requests/{br_id}/accept", headers={"X-User-Id": pro_id})
    assert accept.status_code == 200
    gig_id = accept.json()["gig_id"]
    gig = db_session.get(Gig, uuid.UUID(gig_id))
    assert gig is not None
    assert gig.niche_id is not None
    assert gig.meta["niche_slug"] == "weddings"
    assert gig.meta["niche_name"] == "Weddings"


def test_review_is_niche_scoped_to_gig(client, db_session, monkeypatch):
    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_args, **_kwargs: None)
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    niche_id = db_session.query(Niche).filter_by(slug="portraits").first().id

    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=niche_id,
        status=GigStatus.completed,
        currency="EUR",
        amount_total=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.commit()
    db_session.refresh(gig)

    resp = client.post(
        f"/v1/gigs/{gig.id}/review",
        headers={"X-User-Id": client_id},
        json={"rating": 5, "tags": ["creative"], "would_book_again": True},
    )
    assert resp.status_code == 200
    payload = resp.json()
    assert payload["niche_id"] == str(niche_id)


def test_scoring_produces_deterministic_master_tier(db_session):
    pro_id = uuid.uuid4()
    client_id = uuid.uuid4()
    niche = db_session.query(Niche).filter_by(slug="portraits").first()
    assert niche is not None
    now = datetime.now(timezone.utc)

    for i in range(30):
        gig = Gig(
            client_user_id=client_id,
            pro_user_id=pro_id,
            niche_id=niche.id,
            status=GigStatus.completed,
            currency="EUR",
            amount_total=Decimal("100.00"),
            amount_platform_fee=Decimal("20.00"),
            amount_pro_gross=Decimal("80.00"),
            scheduled_end=now - timedelta(days=30 - i),
            updated_at=now - timedelta(days=20 - i),
            meta={"pricing_snapshot": {"finals_sla_days": 7}},
        )
        db_session.add(gig)
        db_session.flush()
        if i < 20:
            db_session.add(
                Review(
                    gig_id=gig.id,
                    pro_user_id=pro_id,
                    client_user_id=client_id,
                    niche_id=niche.id,
                    rating=5,
                    tags=["great"],
                    would_book_again=True,
                    status=ReviewStatus.published,
                )
            )

    for _ in range(40):
        db_session.add(
            MediaAsset(
                owner_user_id=pro_id,
                kind=MediaKind.photo,
                purpose=MediaPurpose.portfolio_reel,
                provider=MediaProvider.r2,
                status=MediaStatus.ready,
                visibility=MediaVisibility.owner_only,
                niche_tags=[niche.slug],
                meta={},
            )
        )

    db_session.add(
        CertificationRecord(
            pro_user_id=pro_id,
            niche_id=niche.id,
            cert_code="portraits.foundation",
            score=90,
            completed_at=now - timedelta(days=1),
            expires_at=now + timedelta(days=30),
        )
    )
    db_session.commit()

    skill = recompute_pro_niche_skill(db_session, pro_id, niche.id)
    db_session.commit()

    assert skill.capability_score == 100
    assert skill.certification_score == 90
    assert float(skill.confidence) == 1.0
    assert skill.tier == SkillTier.master


def test_discovery_niche_filter_orders_by_tier_before_rank(client, db_session):
    niche = db_session.query(Niche).filter_by(slug="portraits").first()
    assert niche is not None
    pro_master = uuid.uuid4()
    pro_skilled = uuid.uuid4()

    for pro_id in [pro_master, pro_skilled]:
        db_session.add(UserAccount(user_id=pro_id))
        db_session.add(UserRole(user_id=pro_id, role=UserRoleType.pro))
        db_session.add(
            ProProfile(
                user_id=pro_id,
                display_name=f"Pro {str(pro_id)[:8]}",
                city="Lisbon",
                country="PT",
                styles=["editorial"],
                is_accepting_bookings=True,
                completeness_score=95,
                kyc_status=KYCStatus.approved,
            )
        )
        db_session.add(
            ProPackage(
                pro_user_id=pro_id,
                niche_id=niche.id,
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

    db_session.add(
        ProNicheSkill(
            pro_user_id=pro_master,
            niche_id=niche.id,
            tier=SkillTier.elite,
            capability_score=88,
            certification_score=88,
            confidence=Decimal("0.80"),
            evidence_gigs=20,
            evidence_reviews=10,
            evidence_portfolio=10,
            breakdown={},
            updated_at=datetime.now(timezone.utc),
        )
    )
    db_session.add(
        ProNicheSkill(
            pro_user_id=pro_skilled,
            niche_id=niche.id,
            tier=SkillTier.skilled,
            capability_score=70,
            certification_score=45,
            confidence=Decimal("0.95"),
            evidence_gigs=10,
            evidence_reviews=5,
            evidence_portfolio=5,
            breakdown={},
            updated_at=datetime.now(timezone.utc),
        )
    )
    recompute_pro_public_index(db_session, pro_master)
    recompute_pro_public_index(db_session, pro_skilled)
    db_session.commit()

    resp = client.get("/v1/discover/pros?niche=portraits")
    assert resp.status_code == 200
    ids = [item["pro_user_id"] for item in resp.json()["items"]]
    assert ids[0] == str(pro_master)
