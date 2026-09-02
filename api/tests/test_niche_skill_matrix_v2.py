import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.client_rewards_pricing import ExtraImagePricingPolicy
from app.models.gallery import ProofGallery
from app.models.gig import Gig, GigStatus
from app.models.learning import Certificate, CertificateType, CurriculumPath
from app.models.niche import Badge, Niche, NicheTierPolicy, ProNicheSkill, SkillTier, UserBadge
from app.models.outbox import OutboxEvent
from app.models.review import Review, ReviewStatus
from app.services.client_rewards_pricing import compute_extra_image_unit_price
from app.services.niche_skills import enqueue_niche_skill_recalc, recompute_pro_niche_skill


def _ensure_user_role(db_session, user_id: uuid.UUID, role: UserRoleType):
    if not db_session.get(UserAccount, user_id):
        db_session.add(UserAccount(user_id=user_id))
        db_session.commit()
    exists = db_session.query(UserRole).filter_by(user_id=user_id, role=role).first()
    if not exists:
        db_session.add(UserRole(user_id=user_id, role=role))
        db_session.commit()


def _niche(db_session, slug: str = "portraits") -> Niche:
    row = db_session.query(Niche).filter_by(slug=slug).first()
    assert row is not None
    return row


def test_score_calc_is_deterministic(db_session):
    pro_id = uuid.uuid4()
    client_id = uuid.uuid4()
    niche = _niche(db_session)
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)

    for _ in range(20):
        db_session.add(
            Gig(
                client_user_id=client_id,
                pro_user_id=pro_id,
                niche_id=niche.id,
                status=GigStatus.completed,
                currency="EUR",
                amount_minimum=Decimal("100"),
                amount_platform_fee=Decimal("20"),
                amount_pro_gross=Decimal("80"),
                meta={},
            )
        )
    db_session.flush()
    gigs = db_session.query(Gig).filter_by(pro_user_id=pro_id, niche_id=niche.id).all()
    for gig in gigs[:12]:
        db_session.add(
            Review(
                gig_id=gig.id,
                pro_user_id=pro_id,
                client_user_id=client_id,
                niche_id=niche.id,
                rating=5,
                tags=[],
                would_book_again=True,
                status=ReviewStatus.published,
            )
        )
    db_session.commit()

    skill = recompute_pro_niche_skill(db_session, pro_id, niche.id)
    # Expected around: gigs=10 pts, rating>=10 reviews with 5.0 => 25 pts, no verified/penalty => 35
    assert 34 <= skill.score <= 36


def test_tier_assignment_respects_verified_requirement(db_session):
    pro_id = uuid.uuid4()
    client_id = uuid.uuid4()
    niche = _niche(db_session)
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)

    policy = db_session.query(NicheTierPolicy).filter_by(niche_id=niche.id).first()
    if not policy:
        policy = NicheTierPolicy(niche_id=niche.id, thresholds={})
        db_session.add(policy)
    policy.thresholds = {
        "rookie": {"min_score": 0, "min_gigs": 0, "min_rating": 0, "requires_verified": False},
        "skilled": {"min_score": 10, "min_gigs": 2, "min_rating": 4.0, "requires_verified": False},
        "pro": {"min_score": 30, "min_gigs": 5, "min_rating": 4.4, "requires_verified": True},
        "elite": {"min_score": 70, "min_gigs": 50, "min_rating": 4.6, "requires_verified": True},
        "master": {"min_score": 90, "min_gigs": 120, "min_rating": 4.8, "requires_verified": True},
    }
    db_session.commit()

    for _ in range(8):
        db_session.add(
            Gig(
                client_user_id=client_id,
                pro_user_id=pro_id,
                niche_id=niche.id,
                status=GigStatus.completed,
                currency="EUR",
                amount_minimum=Decimal("100"),
                amount_platform_fee=Decimal("20"),
                amount_pro_gross=Decimal("80"),
                meta={},
            )
        )
    db_session.flush()
    for gig in db_session.query(Gig).filter_by(pro_user_id=pro_id, niche_id=niche.id).all()[:8]:
        db_session.add(
            Review(
                gig_id=gig.id,
                pro_user_id=pro_id,
                client_user_id=client_id,
                niche_id=niche.id,
                rating=5,
                tags=[],
                would_book_again=True,
                status=ReviewStatus.published,
            )
        )
    db_session.commit()

    skill = recompute_pro_niche_skill(db_session, pro_id, niche.id)
    assert skill.tier == SkillTier.skilled

    path = CurriculumPath(niche_slug=niche.slug, name="Path", is_active=True)
    db_session.add(path)
    db_session.flush()
    db_session.add(
        Certificate(
            user_id=pro_id,
            certificate_type=CertificateType.curriculum,
            curriculum_path_id=path.id,
            course_id=None,
            niche_id=niche.id,
            niche_slug=niche.slug,
            certificate_code=f"CUR-{uuid.uuid4().hex[:8]}",
            verification_code=f"VC-{uuid.uuid4().hex[:8]}",
            meta={},
        )
    )
    db_session.commit()

    skill2 = recompute_pro_niche_skill(db_session, pro_id, niche.id)
    assert skill2.verified is True
    assert skill2.tier in {SkillTier.pro, SkillTier.elite, SkillTier.master}


def test_hysteresis_blocks_rapid_promotion_flip(db_session):
    pro_id = uuid.uuid4()
    niche = _niche(db_session)
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)

    row = ProNicheSkill(
        pro_user_id=pro_id,
        niche_id=niche.id,
        tier=SkillTier.skilled,
        score=20,
        verified=False,
        gigs_completed=4,
        avg_rating=Decimal("4.20"),
        review_count=5,
        last_promotion_at=datetime.now(timezone.utc),
    )
    db_session.add(row)
    db_session.commit()

    # Recompute with no stronger evidence should not jump tiers, and hysteresis keeps changes conservative.
    updated = recompute_pro_niche_skill(db_session, pro_id, niche.id)
    assert updated.tier == SkillTier.skilled


def test_extra_image_price_cap_uses_niche_tier(db_session):
    pro_id = uuid.uuid4()
    client_id = uuid.uuid4()
    niche = _niche(db_session)

    db_session.add(
        ProNicheSkill(
            pro_user_id=pro_id,
            niche_id=niche.id,
            tier=SkillTier.master,
            score=92,
            verified=True,
            gigs_completed=120,
            avg_rating=Decimal("4.90"),
            review_count=200,
        )
    )
    db_session.add(
        ExtraImagePricingPolicy(
            niche_id=niche.id,
            tier=SkillTier.master,
            unit_price_min=Decimal("8.00"),
            unit_price_max=Decimal("15.00"),
            max_extra_images=50,
            bulk_curve={},
            currency="EUR",
            is_active=True,
        )
    )
    gig = Gig(
        client_user_id=client_id,
        pro_user_id=pro_id,
        niche_id=niche.id,
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=Decimal("100"),
        amount_platform_fee=Decimal("20"),
        amount_pro_gross=Decimal("80"),
        meta={},
    )
    db_session.add(gig)
    db_session.flush()
    gallery = ProofGallery(
        gig_id=gig.id,
        client_user_id=client_id,
        pro_user_id=pro_id,
        title="Gallery",
        expires_at=datetime.now(timezone.utc) + timedelta(days=10),
        included_photos=10,
        extra_photo_price=Decimal("30.00"),
        watermark_enabled=True,
        allow_favorites=True,
        allow_hidden=True,
    )
    db_session.add(gallery)
    db_session.commit()

    configured, applied, _min, _max, tier = compute_extra_image_unit_price(db_session, gig=gig, gallery=gallery)
    assert tier == SkillTier.master
    assert configured == Decimal("30.00")
    assert applied == Decimal("15.00")


def test_badge_award_and_revoke_current_only(db_session):
    pro_id = uuid.uuid4()
    client_id = uuid.uuid4()
    niche = _niche(db_session)
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)

    for _ in range(30):
        db_session.add(
            Gig(
                client_user_id=client_id,
                pro_user_id=pro_id,
                niche_id=niche.id,
                status=GigStatus.completed,
                currency="EUR",
                amount_minimum=Decimal("100"),
                amount_platform_fee=Decimal("20"),
                amount_pro_gross=Decimal("80"),
                meta={},
            )
        )
    db_session.commit()

    skill = recompute_pro_niche_skill(db_session, pro_id, niche.id)
    assert skill.tier in {SkillTier.skilled, SkillTier.pro, SkillTier.elite, SkillTier.master}

    badge_codes = [
        code
        for (code,) in db_session.query(Badge.code).join(UserBadge, UserBadge.badge_id == Badge.id).filter(UserBadge.user_id == pro_id).all()
    ]
    assert any(code.startswith(f"tier_{niche.slug}_") for code in badge_codes)

    # Force downgrade by removing all evidence and recomputing.
    db_session.query(Review).filter(Review.pro_user_id == pro_id, Review.niche_id == niche.id).delete()
    db_session.query(Gig).filter(Gig.pro_user_id == pro_id, Gig.niche_id == niche.id).delete()
    db_session.commit()
    skill2 = recompute_pro_niche_skill(db_session, pro_id, niche.id)
    assert skill2.tier == SkillTier.rookie

    badge_codes_after = [
        code
        for (code,) in db_session.query(Badge.code).join(UserBadge, UserBadge.badge_id == Badge.id).filter(UserBadge.user_id == pro_id).all()
    ]
    assert f"tier_{niche.slug}_rookie" in badge_codes_after
    assert not any(code.endswith("_master") for code in badge_codes_after)


def test_recalc_enqueues_outbox_event(db_session):
    pro_id = uuid.uuid4()
    niche = _niche(db_session)
    enqueue_niche_skill_recalc(db_session, pro_user_id=pro_id, niche_id=niche.id, reason="unit_test")
    db_session.commit()
    row = db_session.query(OutboxEvent).filter_by(topic="niche_skill.recalc").first()
    assert row is not None
    assert row.payload["pro_user_id"] == str(pro_id)
