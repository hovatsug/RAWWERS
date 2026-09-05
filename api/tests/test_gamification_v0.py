import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.gamification import CyclePoints, MilestoneCompletion, MilestoneProgressStatus, MilestoneScope, ProCredential
from app.models.gig import Gig, GigStatus
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.reward import RewardLedgerEntry, RewardRule
from app.services.gamification import evaluate_user_milestones, recompute_credentials

ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"


def _ensure_user_role(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()
    existing = db_session.query(UserRole).filter_by(user_id=uid, role=role).first()
    if not existing:
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()


def _seed_completed_gig(db_session, pro_user_id: uuid.UUID, niche_id: uuid.UUID, *, on_time: bool = True) -> Gig:
    now = datetime.now(timezone.utc)
    updated_at = now
    if not on_time:
        updated_at = now + timedelta(days=10)
    gig = Gig(
        client_user_id=uuid.uuid4(),
        pro_user_id=pro_user_id,
        niche_id=niche_id,
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=Decimal("200.00"),
        amount_platform_fee=Decimal("40.00"),
        amount_pro_gross=Decimal("160.00"),
        scheduled_start=now - timedelta(days=2),
        scheduled_end=now - timedelta(days=1),
        updated_at=updated_at,
        meta={"pricing_snapshot": {"finals_sla_days": 7}},
    )
    db_session.add(gig)
    db_session.commit()
    return gig


def test_credential_issuance_and_tier_milestone(client, db_session):
    pro_id = uuid.uuid4()
    _ensure_user_role(db_session, str(pro_id), UserRoleType.pro)
    niche = db_session.query(Niche).filter_by(slug="weddings").first()
    assert niche is not None

    db_session.add(
        ProNicheSkill(
            pro_user_id=pro_id,
            niche_id=niche.id,
            capability_score=90,
            certification_score=90,
            confidence=Decimal("0.90"),
            tier=SkillTier.elite,
            evidence_gigs=20,
            evidence_reviews=10,
            evidence_portfolio=10,
            breakdown={},
        )
    )
    db_session.commit()

    awarded = recompute_credentials(db_session, pro_id, niche.id)
    assert awarded >= 2
    db_session.commit()

    creds = db_session.query(ProCredential).filter_by(pro_user_id=pro_id, niche_id=niche.id).all()
    assert len(creds) == 2

    admin_resp = client.post(
        "/v1/admin/gamification/milestones",
        headers={"X-User-Id": ADMIN_ID},
        json={
            "code": "tier_elite_weddings",
            "name": "Elite Weddings",
            "description": "Reach elite tier in weddings",
            "scope": "niche",
            "niche_id": str(niche.id),
            "difficulty": "advanced",
            "is_repeatable": False,
            "criteria": {"type": "tier_reached", "tier": "elite"},
            "is_active": True,
        },
    )
    assert admin_resp.status_code == 200

    completed = evaluate_user_milestones(db_session, pro_id, niche.id)
    db_session.commit()
    assert completed == 1

    me = client.get("/v1/me/gamification/credentials", headers={"X-User-Id": str(pro_id)})
    assert me.status_code == 200
    assert len(me.json()) == 2


def test_milestone_completion_is_idempotent_and_rewards_once(client, db_session):
    pro_id = uuid.uuid4()
    _ensure_user_role(db_session, str(pro_id), UserRoleType.pro)
    niche = db_session.query(Niche).filter_by(slug="portraits").first()
    assert niche is not None

    db_session.add(
        RewardRule(
            code="milestone_nonrepeat_reward",
            is_enabled=True,
            amount=150,
            currency="RAWW_POINTS",
            daily_cap_per_user=10000,
            lifetime_cap_per_user=100000,
            meta={},
        )
    )
    db_session.commit()
    _seed_completed_gig(db_session, pro_id, niche.id)

    milestone_resp = client.post(
        "/v1/admin/gamification/milestones",
        headers={"X-User-Id": ADMIN_ID},
        json={
            "code": "first_gig_portraits",
            "name": "First Portrait Gig",
            "description": "Complete your first portrait gig",
            "scope": "niche",
            "niche_id": str(niche.id),
            "difficulty": "standard",
            "is_repeatable": False,
            "criteria": {"type": "gig_count_completed", "count": 1},
            "reward_rule_code": "milestone_nonrepeat_reward",
            "is_active": True,
        },
    )
    assert milestone_resp.status_code == 200

    evaluate_user_milestones(db_session, pro_id, niche.id)
    evaluate_user_milestones(db_session, pro_id, niche.id)
    db_session.commit()

    completions = db_session.query(MilestoneCompletion).filter_by(user_id=pro_id).all()
    rewards = db_session.query(RewardLedgerEntry).filter_by(user_id=pro_id, rule_code="milestone_nonrepeat_reward").all()
    assert len(completions) == 1
    assert len(rewards) == 1


def test_repeatable_milestone_cooldown_enforced(client, db_session):
    pro_id = uuid.uuid4()
    _ensure_user_role(db_session, str(pro_id), UserRoleType.pro)
    niche = db_session.query(Niche).filter_by(slug="family").first()
    assert niche is not None
    _seed_completed_gig(db_session, pro_id, niche.id)

    milestone_resp = client.post(
        "/v1/admin/gamification/milestones",
        headers={"X-User-Id": ADMIN_ID},
        json={
            "code": "repeatable_family_count",
            "name": "Family Cadence",
            "description": "Keep delivering in family niche",
            "scope": "niche",
            "niche_id": str(niche.id),
            "difficulty": "standard",
            "is_repeatable": True,
            "cooldown_days": 30,
            "criteria": {"type": "gig_count_completed", "count": 1},
            "is_active": True,
        },
    )
    assert milestone_resp.status_code == 200

    evaluate_user_milestones(db_session, pro_id, niche.id)
    evaluate_user_milestones(db_session, pro_id, niche.id)
    db_session.commit()
    assert db_session.query(MilestoneCompletion).filter_by(user_id=pro_id).count() == 1

    first = db_session.query(MilestoneCompletion).filter_by(user_id=pro_id).first()
    assert first is not None
    first.completed_at = datetime.now(timezone.utc) - timedelta(days=31)
    db_session.commit()

    evaluate_user_milestones(db_session, pro_id, niche.id)
    db_session.commit()
    assert db_session.query(MilestoneCompletion).filter_by(user_id=pro_id).count() == 2


def test_cycle_points_only_accumulate_within_window(client, db_session):
    pro_id = uuid.uuid4()
    _ensure_user_role(db_session, str(pro_id), UserRoleType.pro)
    niche = db_session.query(Niche).filter_by(slug="corporate").first()
    assert niche is not None
    _seed_completed_gig(db_session, pro_id, niche.id)

    now = datetime.now(timezone.utc)
    active_cycle = client.post(
        "/v1/admin/gamification/cycles",
        headers={"X-User-Id": ADMIN_ID},
        json={
            "code": "2026_02",
            "name": "February 2026",
            "start_at": (now - timedelta(days=1)).isoformat(),
            "end_at": (now + timedelta(days=1)).isoformat(),
            "is_active": True,
            "metadata": {},
        },
    )
    assert active_cycle.status_code == 200
    past_cycle = client.post(
        "/v1/admin/gamification/cycles",
        headers={"X-User-Id": ADMIN_ID},
        json={
            "code": "2026_01",
            "name": "January 2026",
            "start_at": (now - timedelta(days=10)).isoformat(),
            "end_at": (now - timedelta(days=5)).isoformat(),
            "is_active": True,
            "metadata": {},
        },
    )
    assert past_cycle.status_code == 200

    milestone_resp = client.post(
        "/v1/admin/gamification/milestones",
        headers={"X-User-Id": ADMIN_ID},
        json={
            "code": "corp_cycle_points",
            "name": "Corporate Velocity",
            "description": "Complete one corporate gig",
            "scope": "niche",
            "niche_id": str(niche.id),
            "difficulty": "advanced",
            "is_repeatable": False,
            "criteria": {"type": "gig_count_completed", "count": 1, "cycle_points": 77},
            "is_active": True,
        },
    )
    assert milestone_resp.status_code == 200

    evaluate_user_milestones(db_session, pro_id, niche.id)
    db_session.commit()

    points_rows = db_session.query(CyclePoints).filter_by(user_id=pro_id).all()
    assert len(points_rows) == 1
    assert points_rows[0].points == 77

    cycle_payload = client.get("/v1/me/gamification/cycle/current", headers={"X-User-Id": str(pro_id)})
    assert cycle_payload.status_code == 200
    assert cycle_payload.json()["my_points"] == 77


def test_admin_endpoints_access_control(client, db_session):
    outsider = str(uuid.uuid4())
    _ensure_user_role(db_session, outsider, UserRoleType.pro)

    denied = client.post(
        "/v1/admin/gamification/milestones",
        headers={"X-User-Id": outsider},
        json={
            "code": "denied",
            "name": "Denied",
            "description": "Denied",
            "scope": MilestoneScope.global_scope.value,
            "difficulty": "standard",
            "criteria": {"type": "gig_count_completed", "count": 1},
            "is_active": True,
        },
    )
    assert denied.status_code == 403

    allowed = client.post(
        "/v1/admin/gamification/milestones",
        headers={"X-User-Id": ADMIN_ID},
        json={
            "code": "allowed",
            "name": "Allowed",
            "description": "Allowed",
            "scope": MilestoneScope.global_scope.value,
            "difficulty": "standard",
            "criteria": {"type": "gig_count_completed", "count": 1},
            "is_active": True,
        },
    )
    assert allowed.status_code == 200


def test_me_gamification_milestones_returns_progress(client, db_session):
    pro_id = uuid.uuid4()
    _ensure_user_role(db_session, str(pro_id), UserRoleType.pro)
    niche = db_session.query(Niche).filter_by(slug="events_nightlife").first()
    assert niche is not None
    _seed_completed_gig(db_session, pro_id, niche.id)

    client.post(
        "/v1/admin/gamification/milestones",
        headers={"X-User-Id": ADMIN_ID},
        json={
            "code": "events_count",
            "name": "Events Delivery",
            "description": "Complete events gigs",
            "scope": "niche",
            "niche_id": str(niche.id),
            "difficulty": "standard",
            "is_repeatable": False,
            "criteria": {"type": "gig_count_completed", "count": 1},
            "is_active": True,
        },
    )
    resp = client.get("/v1/me/gamification/milestones", headers={"X-User-Id": str(pro_id)})
    assert resp.status_code == 200
    payload = resp.json()
    assert payload["total"] >= 1
    assert any(item["progress"]["status"] == MilestoneProgressStatus.completed.value for item in payload["items"])
