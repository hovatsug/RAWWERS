from __future__ import annotations

import uuid
from decimal import Decimal

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.gig import Gig, GigStatus
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.outbox import OutboxEvent
from app.models.proof_of_gigs import (
    RawwClawback,
    RawwIssuanceCap,
    RawwIssuanceCapScope,
    RawwIssuanceEventType,
    RawwMintEvent,
    RawwMintEventStatus,
)
from app.models.reward import RewardEntryType, RewardLedgerEntry
from app.models.studioverse import (
    ContentPack,
    ContentPackCategory,
    ContentPackOrder,
    ContentPackOrderStatus,
    ContentPackPaymentMethod,
    ContentPackStatus,
)
from app.services.proof_of_gigs import (
    enqueue_milestone_events,
    process_raww_mint_event,
    reverse_raww_mints_for_refund,
)
from app.tasks.outbox_tasks import dispatch_outbox_events_task

ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"


def _seed_user(db_session, user_id: str, roles: list[UserRoleType]) -> None:
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid, email=f"{user_id}@example.com"))
    for role in roles:
        exists = db_session.query(UserRole).filter_by(user_id=uid, role=role).one_or_none()
        if not exists:
            db_session.add(UserRole(user_id=uid, role=role))
    db_session.flush()


def _first_niche_id(db_session) -> uuid.UUID:
    return db_session.query(Niche).first().id


def test_raww_mint_idempotent_for_same_event(db_session):
    pro_id = "00000000-0000-0000-0000-000000000101"
    client_id = "00000000-0000-0000-0000-000000000102"
    _seed_user(db_session, pro_id, [UserRoleType.pro])
    _seed_user(db_session, client_id, [UserRoleType.client])

    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=_first_niche_id(db_session),
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=Decimal("120.00"),
        amount_platform_fee=Decimal("24.00"),
        amount_pro_gross=Decimal("96.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.commit()

    payload = {"event_type": RawwIssuanceEventType.gig_completed.value, "gig_id": str(gig.id)}
    process_raww_mint_event(db_session, payload=payload)
    process_raww_mint_event(db_session, payload=payload)
    db_session.commit()

    mints = db_session.query(RawwMintEvent).filter_by(event_type=RawwIssuanceEventType.gig_completed.value, reference_id=gig.id).all()
    earns = db_session.query(RewardLedgerEntry).filter_by(user_id=uuid.UUID(pro_id), entry_type=RewardEntryType.earn, reference_type="raww_mint").all()
    assert len(mints) == 1
    assert len(earns) == 1


def test_raww_caps_clamp_then_block(db_session):
    pro_id = "00000000-0000-0000-0000-000000000111"
    client_id = "00000000-0000-0000-0000-000000000112"
    _seed_user(db_session, pro_id, [UserRoleType.pro])
    _seed_user(db_session, client_id, [UserRoleType.client])
    niche_id = _first_niche_id(db_session)

    gig_a = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=niche_id,
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    gig_b = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=niche_id,
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add_all([gig_a, gig_b])
    db_session.flush()

    cap = db_session.query(RawwIssuanceCap).filter_by(scope=RawwIssuanceCapScope.pro_daily).one()
    cap.cap_raww = 100
    db_session.flush()
    process_raww_mint_event(db_session, payload={"event_type": RawwIssuanceEventType.gig_completed.value, "gig_id": str(gig_a.id)})
    process_raww_mint_event(db_session, payload={"event_type": RawwIssuanceEventType.gig_completed.value, "gig_id": str(gig_b.id)})
    db_session.commit()

    first = db_session.query(RawwMintEvent).filter_by(reference_id=gig_a.id).one()
    second = db_session.query(RawwMintEvent).filter_by(reference_id=gig_b.id).one()
    assert first.raww_awarded == 100
    assert second.status == RawwMintEventStatus.blocked


def test_raww_tier_multiplier_applies(db_session):
    niche_id = _first_niche_id(db_session)

    pro_rookie = "00000000-0000-0000-0000-000000000121"
    pro_master = "00000000-0000-0000-0000-000000000122"
    client_a = "00000000-0000-0000-0000-000000000123"
    client_b = "00000000-0000-0000-0000-000000000124"

    _seed_user(db_session, pro_rookie, [UserRoleType.pro])
    _seed_user(db_session, pro_master, [UserRoleType.pro])
    _seed_user(db_session, client_a, [UserRoleType.client])
    _seed_user(db_session, client_b, [UserRoleType.client])

    db_session.add(ProNicheSkill(pro_user_id=uuid.UUID(pro_rookie), niche_id=niche_id, tier=SkillTier.rookie))
    db_session.add(ProNicheSkill(pro_user_id=uuid.UUID(pro_master), niche_id=niche_id, tier=SkillTier.master))

    gig_rookie = Gig(
        client_user_id=uuid.UUID(client_a),
        pro_user_id=uuid.UUID(pro_rookie),
        niche_id=niche_id,
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    gig_master = Gig(
        client_user_id=uuid.UUID(client_b),
        pro_user_id=uuid.UUID(pro_master),
        niche_id=niche_id,
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add_all([gig_rookie, gig_master])
    db_session.commit()

    process_raww_mint_event(db_session, payload={"event_type": RawwIssuanceEventType.gig_completed.value, "gig_id": str(gig_rookie.id)})
    process_raww_mint_event(db_session, payload={"event_type": RawwIssuanceEventType.gig_completed.value, "gig_id": str(gig_master.id)})
    db_session.commit()

    rookie_award = db_session.query(RawwMintEvent).filter_by(reference_id=gig_rookie.id).one().raww_awarded
    master_award = db_session.query(RawwMintEvent).filter_by(reference_id=gig_master.id).one().raww_awarded
    assert master_award > rookie_award


def test_self_dealing_is_blocked(db_session):
    pro_id = "00000000-0000-0000-0000-000000000131"
    _seed_user(db_session, pro_id, [UserRoleType.pro, UserRoleType.client])

    gig = Gig(
        client_user_id=uuid.UUID(pro_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=_first_niche_id(db_session),
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=Decimal("200.00"),
        amount_platform_fee=Decimal("40.00"),
        amount_pro_gross=Decimal("160.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.commit()

    process_raww_mint_event(db_session, payload={"event_type": RawwIssuanceEventType.gig_completed.value, "gig_id": str(gig.id)})
    db_session.commit()

    mint = db_session.query(RawwMintEvent).filter_by(reference_id=gig.id).one()
    assert mint.status == RawwMintEventStatus.blocked
    assert (mint.multiplier_snapshot or {}).get("reason") == "self_dealing"


def test_refund_reverses_prior_mints(db_session):
    pro_id = "00000000-0000-0000-0000-000000000141"
    client_id = "00000000-0000-0000-0000-000000000142"
    _seed_user(db_session, pro_id, [UserRoleType.pro])
    _seed_user(db_session, client_id, [UserRoleType.client])

    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=_first_niche_id(db_session),
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=Decimal("150.00"),
        amount_platform_fee=Decimal("30.00"),
        amount_pro_gross=Decimal("120.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.commit()

    process_raww_mint_event(db_session, payload={"event_type": RawwIssuanceEventType.gig_completed.value, "gig_id": str(gig.id)})
    reversed_count = reverse_raww_mints_for_refund(db_session, gig_id=gig.id, reason="refund")
    db_session.commit()

    mint = db_session.query(RawwMintEvent).filter_by(reference_id=gig.id).one()
    reversal = db_session.query(RewardLedgerEntry).filter_by(reference_type="raww_mint_reversal", reference_id=str(mint.id)).one_or_none()
    assert reversed_count >= 1
    assert mint.status == RawwMintEventStatus.reversed
    assert reversal is not None
    assert reversal.amount < 0


def test_milestone_mints_only_once_per_threshold(db_session):
    creator_id = "00000000-0000-0000-0000-000000000151"
    _seed_user(db_session, creator_id, [UserRoleType.pro])

    pack = ContentPack(
        creator_user_id=uuid.UUID(creator_id),
        title="Milestone Pack",
        description="Pack",
        category=ContentPackCategory.preset,
        niche_slugs=["weddings"],
        tags=["x"],
        price_eur=Decimal("10.00"),
        price_raww=0,
        currency="EUR",
        cover_media_asset_id=None,
        preview_media_asset_ids=[],
        pack_file_storage_key="studioverse/packs/milestone.zip",
        pack_file_bytes=100,
        license_code="standard_personal",
        status=ContentPackStatus.approved,
    )
    db_session.add(pack)
    db_session.flush()

    for idx in range(12):
        buyer_id = f"00000000-0000-0000-0000-000000000{200 + idx:03d}"
        _seed_user(db_session, buyer_id, [UserRoleType.client])
        db_session.add(
            ContentPackOrder(
                buyer_user_id=uuid.UUID(buyer_id),
                content_pack_id=pack.id,
                price_eur_paid=Decimal("10.00"),
                price_raww_paid=0,
                payment_method=ContentPackPaymentMethod.stripe,
                status=ContentPackOrderStatus.paid,
            )
        )
    db_session.commit()

    enqueue_milestone_events(db_session)
    enqueue_milestone_events(db_session)
    db_session.commit()

    queued = db_session.query(OutboxEvent).filter_by(topic="raww.mint").all()
    assert len(queued) == 1

    dispatch_outbox_events_task(limit=100)
    dispatch_outbox_events_task(limit=100)

    milestone_mints = db_session.query(RawwMintEvent).filter_by(event_type=RawwIssuanceEventType.studioverse_milestone_reached.value).all()
    assert len(milestone_mints) == 1


def test_admin_clawback_endpoint_writes_auditable_entries(client, db_session):
    pro_id = "00000000-0000-0000-0000-000000000171"
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    _seed_user(db_session, pro_id, [UserRoleType.pro])

    # Seed mintable gig so pro has credits first.
    gig = Gig(
        client_user_id=uuid.UUID("00000000-0000-0000-0000-000000000172"),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=_first_niche_id(db_session),
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=Decimal("180.00"),
        amount_platform_fee=Decimal("36.00"),
        amount_pro_gross=Decimal("144.00"),
        meta={},
    )
    _seed_user(db_session, "00000000-0000-0000-0000-000000000172", [UserRoleType.client])
    db_session.add(gig)
    db_session.commit()

    process_raww_mint_event(db_session, payload={"event_type": RawwIssuanceEventType.gig_completed.value, "gig_id": str(gig.id)})
    db_session.commit()

    resp = client.post(
        "/v1/admin/raww/clawback",
        headers={"X-User-Id": ADMIN_ID, "X-Admin-Api-Key": ""},
        json={
            "pro_user_id": pro_id,
            "reference_type": "gig",
            "reference_id": str(gig.id),
            "amount_raww": 20,
            "reason": "fraud_case",
        },
    )
    assert resp.status_code == 200

    clawback = db_session.query(RawwClawback).filter_by(pro_user_id=uuid.UUID(pro_id)).one_or_none()
    ledger = db_session.query(RewardLedgerEntry).filter_by(reference_type="raww_clawback").one_or_none()
    assert clawback is not None
    assert ledger is not None
    assert ledger.amount == -20
