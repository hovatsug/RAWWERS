import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.repair import (
    GearCategory,
    LoanerRequest,
    LoanerRequestStatus,
    RepairPartner,
    RepairTicket,
    RepairTicketStatus,
    RepairUrgency,
)
from app.services.repair import recompute_partner_score

ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"


def _ensure_user_role(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()
    row = db_session.query(UserRole).filter_by(user_id=uid, role=role).first()
    if not row:
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()


def _set_pro_profile(db_session, user_id: str, kyc: KYCStatus):
    uid = uuid.UUID(user_id)
    row = db_session.get(ProProfile, uid)
    if not row:
        row = ProProfile(user_id=uid)
        db_session.add(row)
    row.kyc_status = kyc
    db_session.commit()


def _set_tier(db_session, user_id: str, tier: SkillTier, niche_slug: str = "portraits"):
    niche = db_session.query(Niche).filter_by(slug=niche_slug).first()
    assert niche is not None
    row = db_session.query(ProNicheSkill).filter_by(pro_user_id=uuid.UUID(user_id), niche_id=niche.id).first()
    if not row:
        row = ProNicheSkill(
            pro_user_id=uuid.UUID(user_id),
            niche_id=niche.id,
            capability_score=80,
            certification_score=80,
            confidence=Decimal("0.80"),
            tier=tier,
            evidence_gigs=20,
            evidence_reviews=5,
            evidence_portfolio=5,
            breakdown={},
        )
        db_session.add(row)
    row.tier = tier
    db_session.commit()


def _create_partner(db_session, city: str = "Lisbon", country: str = "PT", categories: list[str] | None = None, brands: list[str] | None = None, loaner: bool = False):
    row = RepairPartner(
        name=f"Partner {city}",
        country=country,
        city=city,
        shipping_supported=True,
        pickup_supported=False,
        brands_supported=brands or [],
        categories_supported=categories or [GearCategory.camera_body.value],
        sla_quote_hours=24,
        sla_turnaround_days=7,
        loaner_supported=loaner,
        loaner_categories=[GearCategory.camera_body.value] if loaner else [],
        is_active=True,
        contact={},
        partner_terms={"deposit_required": False, "loaner_max_days": 10},
    )
    db_session.add(row)
    db_session.commit()
    return row


def _prepare_pro(db_session, pro_id: str, *, kyc: KYCStatus = KYCStatus.approved, tier: SkillTier = SkillTier.skilled):
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _set_pro_profile(db_session, pro_id, kyc)
    _set_tier(db_session, pro_id, tier)


def test_eligibility_gate_tier_kyc_override(client, db_session):
    pro_id = str(uuid.uuid4())
    _prepare_pro(db_session, pro_id, kyc=KYCStatus.unsubmitted, tier=SkillTier.pro)
    r1 = client.get("/v1/pro/me/gear-benefits/access", headers={"X-User-Id": pro_id})
    assert r1.status_code == 200
    assert r1.json()["allowed"] is False
    assert r1.json()["reason"] == "kyc_required"

    _set_pro_profile(db_session, pro_id, KYCStatus.approved)
    _set_tier(db_session, pro_id, SkillTier.rookie)
    r2 = client.get("/v1/pro/me/gear-benefits/access", headers={"X-User-Id": pro_id})
    assert r2.json()["allowed"] is False
    assert r2.json()["reason"] == "tier_below_policy"

    override = client.post(
        f"/v1/admin/repairs/overrides/{pro_id}",
        headers={"X-User-Id": ADMIN_ID},
        json={"is_allowed": True, "reason": "manual", "expires_at": None},
    )
    assert override.status_code == 200
    r3 = client.get("/v1/pro/me/gear-benefits/access", headers={"X-User-Id": pro_id})
    assert r3.json()["allowed"] is True
    assert r3.json()["reason"] == "override_allowed"


def test_loaner_request_blocked_if_not_eligible(client, db_session):
    pro_id = str(uuid.uuid4())
    _prepare_pro(db_session, pro_id, kyc=KYCStatus.unsubmitted, tier=SkillTier.rookie)
    ticket = client.post(
        "/v1/repairs/tickets",
        headers={"X-User-Id": pro_id},
        json={"category": "camera_body", "issue_description": "Shutter issue", "urgency": "normal"},
    )
    assert ticket.status_code == 200
    ticket_id = ticket.json()["id"]
    loaner = client.post(
        f"/v1/repairs/tickets/{ticket_id}/request-loaner",
        headers={"X-User-Id": pro_id},
        json={"category": "camera_body"},
    )
    assert loaner.status_code == 403


def test_transition_validation_rejects_invalid_jumps(client, db_session):
    pro_id = str(uuid.uuid4())
    _prepare_pro(db_session, pro_id)
    ticket = client.post(
        "/v1/repairs/tickets",
        headers={"X-User-Id": pro_id},
        json={"category": "lens", "issue_description": "Focus motor", "urgency": "normal"},
    )
    ticket_id = ticket.json()["id"]
    bad = client.post(
        f"/v1/admin/repairs/tickets/{ticket_id}/set-status",
        headers={"X-User-Id": ADMIN_ID},
        json={"to_status": "in_repair"},
    )
    assert bad.status_code == 409


def test_evidence_ownership_enforced(client, db_session):
    pro_id = str(uuid.uuid4())
    other_id = str(uuid.uuid4())
    _prepare_pro(db_session, pro_id)
    _prepare_pro(db_session, other_id)
    asset = MediaAsset(
        owner_user_id=uuid.UUID(other_id),
        kind=MediaKind.photo,
        purpose=MediaPurpose.other,
        provider=MediaProvider.r2,
        status=MediaStatus.ready,
        visibility=MediaVisibility.owner_only,
        meta={},
    )
    db_session.add(asset)
    db_session.commit()
    resp = client.post(
        "/v1/repairs/tickets",
        headers={"X-User-Id": pro_id},
        json={
            "category": "camera_body",
            "issue_description": "Body dent",
            "urgency": "normal",
            "evidence_media_asset_ids": [str(asset.id)],
        },
    )
    assert resp.status_code == 403


def test_partner_match_returns_only_compatible_partners(client, db_session):
    pro_id = str(uuid.uuid4())
    _prepare_pro(db_session, pro_id)
    _create_partner(db_session, city="Lisbon", categories=[GearCategory.camera_body.value], brands=["Sony"], loaner=True)
    _create_partner(db_session, city="Porto", categories=[GearCategory.lens.value], brands=["Canon"], loaner=False)
    matched = client.get(
        "/v1/repairs/partners",
        headers={"X-User-Id": pro_id},
        params={"country": "PT", "city": "Lisbon", "category": "camera_body", "brand": "Sony", "loaner_only": True},
    )
    assert matched.status_code == 200
    items = matched.json()
    assert len(items) == 1
    assert items[0]["city"] == "Lisbon"
    assert items[0]["loaner_supported"] is True


def test_partner_score_rollup_deterministic(db_session):
    pro_id = uuid.uuid4()
    partner = _create_partner(db_session, city="Madrid", country="ES", loaner=True)
    base_time = datetime.now(timezone.utc) - timedelta(days=10)

    t1 = RepairTicket(
        pro_user_id=pro_id,
        partner_id=partner.id,
        status=RepairTicketStatus.closed,
        urgency=RepairUrgency.normal,
        issue_description="Issue 1",
        quote_sent_at=base_time + timedelta(hours=12),
        repair_started_at=base_time + timedelta(days=1),
        closed_at=base_time + timedelta(days=6),
        created_at=base_time,
        updated_at=base_time + timedelta(days=6),
        evidence_media_asset_ids=[],
        shipping={},
        meta={},
    )
    t2 = RepairTicket(
        pro_user_id=pro_id,
        partner_id=partner.id,
        status=RepairTicketStatus.closed,
        urgency=RepairUrgency.normal,
        issue_description="Issue 2",
        quote_sent_at=base_time + timedelta(hours=24),
        repair_started_at=base_time + timedelta(days=2),
        closed_at=base_time + timedelta(days=7),
        created_at=base_time,
        updated_at=base_time + timedelta(days=7),
        evidence_media_asset_ids=[],
        shipping={},
        meta={},
    )
    db_session.add_all([t1, t2])
    db_session.flush()

    reopen = RepairTicket(
        pro_user_id=pro_id,
        partner_id=partner.id,
        status=RepairTicketStatus.submitted,
        urgency=RepairUrgency.normal,
        issue_description="Reopen",
        reopened_from_ticket_id=t1.id,
        created_at=t1.closed_at + timedelta(days=5),
        updated_at=t1.closed_at + timedelta(days=5),
        evidence_media_asset_ids=[],
        shipping={},
        meta={},
    )
    db_session.add(reopen)
    db_session.add(
        LoanerRequest(
            ticket_id=t1.id,
            pro_user_id=pro_id,
            partner_id=partner.id,
            status=LoanerRequestStatus.approved,
            category=GearCategory.camera_body,
            terms_snapshot={},
            deposit_required=False,
            shipping={},
        )
    )
    db_session.add(
        LoanerRequest(
            ticket_id=t2.id,
            pro_user_id=pro_id,
            partner_id=partner.id,
            status=LoanerRequestStatus.requested,
            category=GearCategory.camera_body,
            terms_snapshot={},
            deposit_required=False,
            shipping={},
        )
    )
    db_session.commit()

    score = recompute_partner_score(db_session, partner.id)
    db_session.commit()
    assert score.tickets_count == 3
    assert Decimal(score.avg_quote_hours) == Decimal("18.00")
    assert Decimal(score.avg_turnaround_days) == Decimal("5.00")
    assert Decimal(score.reopen_rate) == Decimal("33.33")
    assert Decimal(score.loaner_fulfillment_rate) == Decimal("50.00")
