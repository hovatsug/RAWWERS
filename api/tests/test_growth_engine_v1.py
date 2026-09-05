import uuid
from decimal import Decimal

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.models.reward import (
    AttributionTouch,
    ConversionAttribution,
    ReferralBlacklist,
    ReferralConversionType,
    ReferralLink,
    ReferralLinkStatus,
    ReferralRewardGrant,
)
from app.services.growth_engine import (
    bind_session_attribution_to_user,
    blacklist_referrer,
    ensure_referral_profile,
    link_referee_to_referrer,
    maybe_issue_referral_conversion_reward,
    record_attribution_touch,
)
from PIL import Image
from app.tasks.media_tasks import _draw_watermark


def _ensure_user(db_session, user_id: uuid.UUID, *, email: str, roles: list[UserRoleType] | None = None) -> None:
    row = db_session.get(UserAccount, user_id)
    if row is None:
        db_session.add(UserAccount(user_id=user_id, email=email))
    for role in roles or []:
        exists = db_session.query(UserRole).filter_by(user_id=user_id, role=role).first()
        if not exists:
            db_session.add(UserRole(user_id=user_id, role=role))
    db_session.commit()


def test_referral_code_unique_generation(db_session):
    user_a = uuid.uuid4()
    user_b = uuid.uuid4()
    _ensure_user(db_session, user_a, email="a@example.com", roles=[UserRoleType.client])
    _ensure_user(db_session, user_b, email="b@example.com", roles=[UserRoleType.client])

    code_a = ensure_referral_profile(db_session, user_a).referral_code
    code_b = ensure_referral_profile(db_session, user_b).referral_code
    db_session.commit()

    assert code_a
    assert code_b
    assert code_a != code_b


def test_attribution_binding_from_anonymous_to_user(db_session):
    user = uuid.uuid4()
    _ensure_user(db_session, user, email="bind@example.com", roles=[UserRoleType.client])

    record_attribution_touch(
        db_session,
        user_id=None,
        session_id="sess-1",
        source="referral",
        medium="social",
        campaign="spring",
        content="ABC12345",
        term=None,
        referrer_url="https://example.com",
    )
    db_session.commit()

    bound = bind_session_attribution_to_user(db_session, session_id="sess-1", user_id=user)
    db_session.commit()

    assert bound == 1
    row = db_session.query(AttributionTouch).filter_by(session_id="sess-1").one()
    assert row.user_id == user


def test_referral_rewards_are_idempotent(db_session):
    referrer = uuid.uuid4()
    referee = uuid.uuid4()
    _ensure_user(db_session, referrer, email="referrer@example.com", roles=[UserRoleType.client])
    _ensure_user(db_session, referee, email="referee@example.com", roles=[UserRoleType.client])

    code = ensure_referral_profile(db_session, referrer).referral_code
    link_referee_to_referrer(db_session, referee_user_id=referee, referral_code=code, referee_email="referee@example.com")
    db_session.commit()

    conversion_id = uuid.uuid4()
    first = maybe_issue_referral_conversion_reward(
        db_session,
        referee_user_id=referee,
        conversion_type=ReferralConversionType.booking_paid,
        conversion_id=conversion_id,
        conversion_value_eur=Decimal("120.00"),
    )
    second = maybe_issue_referral_conversion_reward(
        db_session,
        referee_user_id=referee,
        conversion_type=ReferralConversionType.booking_paid,
        conversion_id=conversion_id,
        conversion_value_eur=Decimal("120.00"),
    )
    db_session.commit()

    assert first.grant is not None
    assert second.grant is not None
    assert first.grant.id == second.grant.id
    assert db_session.query(ReferralRewardGrant).filter_by(conversion_id=conversion_id).count() == 1


def test_blacklist_blocks_referral_rewards(db_session):
    referrer = uuid.uuid4()
    referee = uuid.uuid4()
    _ensure_user(db_session, referrer, email="blk_referrer@example.com", roles=[UserRoleType.client])
    _ensure_user(db_session, referee, email="blk_referee@example.com", roles=[UserRoleType.client])

    code = ensure_referral_profile(db_session, referrer).referral_code
    link_referee_to_referrer(db_session, referee_user_id=referee, referral_code=code, referee_email="blk_referee@example.com")
    blacklist_referrer(db_session, user_id=referrer, reason="fraud")
    db_session.commit()

    result = maybe_issue_referral_conversion_reward(
        db_session,
        referee_user_id=referee,
        conversion_type=ReferralConversionType.booking_paid,
        conversion_id=uuid.uuid4(),
        conversion_value_eur=Decimal("200.00"),
    )
    db_session.commit()

    link = db_session.query(ReferralLink).filter_by(referee_user_id=referee).one()
    assert result.grant is None
    assert link.status == ReferralLinkStatus.blocked
    assert db_session.query(ReferralBlacklist).filter_by(user_id=referrer).count() == 1


def test_priority_referral_over_share_attribution(db_session):
    referrer = uuid.uuid4()
    referee = uuid.uuid4()
    _ensure_user(db_session, referrer, email="prio_referrer@example.com", roles=[UserRoleType.client])
    _ensure_user(db_session, referee, email="prio_referee@example.com", roles=[UserRoleType.client])

    code = ensure_referral_profile(db_session, referrer).referral_code
    link_referee_to_referrer(db_session, referee_user_id=referee, referral_code=code, referee_email="prio_referee@example.com")

    record_attribution_touch(
        db_session,
        user_id=referee,
        session_id="prio-sess",
        source="share_link",
        medium="organic",
        campaign=None,
        content=str(uuid.uuid4()),
        term=None,
        referrer_url=None,
    )

    conversion_id = uuid.uuid4()
    maybe_issue_referral_conversion_reward(
        db_session,
        referee_user_id=referee,
        conversion_type=ReferralConversionType.booking_paid,
        conversion_id=conversion_id,
        conversion_value_eur=Decimal("99.00"),
        share_link_id=uuid.uuid4(),
    )
    db_session.commit()

    row = db_session.query(ConversionAttribution).filter_by(conversion_id=conversion_id).one()
    assert row.attributed_to["primary"] == "referral"
    assert row.attributed_to["referral_code"] == code


def test_viral_watermark_footer_only_for_share_variant(db_session):
    owner = uuid.uuid4()
    _ensure_user(db_session, owner, email="wm_owner@example.com", roles=[UserRoleType.pro])

    asset = MediaAsset(
        owner_user_id=owner,
        kind=MediaKind.photo,
        purpose=MediaPurpose.proof,
        provider=MediaProvider.r2,
        status=MediaStatus.ready,
        visibility=MediaVisibility.owner_only,
        meta={},
    )
    db_session.add(asset)
    db_session.flush()

    base = Image.new("RGB", (1200, 900), color=(24, 24, 24))
    img_plain = base.copy()
    _draw_watermark(db_session, asset, img_plain, include_powered_by=False)
    img_share = base.copy()
    _draw_watermark(db_session, asset, img_share, include_powered_by=True)

    assert img_plain.tobytes() != img_share.tobytes()
