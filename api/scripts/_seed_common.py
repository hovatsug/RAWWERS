from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime, time, timedelta
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserAccountStatus, UserRole, UserRoleType
from app.models.booking import AvailabilityLocationMode, BookingRequest, BookingRequestStatus, ProAvailabilityRule, ProPackage
from app.models.client_launch import ClientPreference
from app.models.discovery import ProPublicIndex
from app.models.gallery import ProofGallery, ProofGalleryItem, ProofGalleryStatus
from app.models.gig import Gig, GigStatus
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus, RolloutCity
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.models.niche import Niche
from app.models.ops import FeatureFlag, FeatureFlagScope
from app.services.auth_service import hash_password
from app.services.discovery_index import recompute_pro_public_index
from app.services.niche_catalog import ensure_initial_niches


@dataclass(frozen=True)
class SeedUser:
    user_id: uuid.UUID
    email: str
    password: str
    display_name: str
    roles: tuple[UserRoleType, ...]


ADMIN_USER = SeedUser(
    user_id=uuid.UUID("00000000-0000-0000-0000-000000000001"),
    email="admin@rawwers.dev",
    password="Passw0rd!",
    display_name="RAWWERS Admin",
    roles=(UserRoleType.admin, UserRoleType.client),
)

CLIENT_USER = SeedUser(
    user_id=uuid.UUID("00000000-0000-0000-0000-000000000011"),
    email="client@rawwers.dev",
    password="Passw0rd!",
    display_name="Demo Client",
    roles=(UserRoleType.client,),
)

PRO_USERS = [
    SeedUser(
        user_id=uuid.UUID("00000000-0000-0000-0000-000000000111"),
        email="pro1@rawwers.dev",
        password="Passw0rd!",
        display_name="Alex Lens",
        roles=(UserRoleType.pro, UserRoleType.client),
    ),
    SeedUser(
        user_id=uuid.UUID("00000000-0000-0000-0000-000000000112"),
        email="pro2@rawwers.dev",
        password="Passw0rd!",
        display_name="Maya Frame",
        roles=(UserRoleType.pro, UserRoleType.client),
    ),
]


def _now() -> datetime:
    return datetime.now(UTC)


def _upsert_user(db: Session, seed_user: SeedUser) -> UserAccount:
    row = db.get(UserAccount, seed_user.user_id)
    if row is None:
        row = UserAccount(
            user_id=seed_user.user_id,
            email=seed_user.email,
            password_hash=hash_password(seed_user.password),
            status=UserAccountStatus.active,
            display_name=seed_user.display_name,
            email_verified_at=_now(),
            created_at=_now(),
            updated_at=_now(),
        )
        db.add(row)
    else:
        row.email = seed_user.email
        row.display_name = seed_user.display_name
        row.status = UserAccountStatus.active
        row.email_verified_at = row.email_verified_at or _now()
        if not row.password_hash:
            row.password_hash = hash_password(seed_user.password)
        row.updated_at = _now()

    for role in seed_user.roles:
        exists = db.execute(
            select(UserRole).where(UserRole.user_id == seed_user.user_id, UserRole.role == role)
        ).scalar_one_or_none()
        if exists is None:
            db.add(UserRole(user_id=seed_user.user_id, role=role))

    return row


def _ensure_flags(db: Session) -> None:
    required_flags = {
        "client_browsing_enabled_global": True,
        "client_booking_enabled": True,
        "proof_gallery_enabled": True,
        "search_enabled": True,
    }
    for key, enabled in required_flags.items():
        row = db.get(FeatureFlag, key)
        if row is None:
            row = FeatureFlag(
                key=key,
                is_enabled=enabled,
                scope=FeatureFlagScope.global_scope,
                rules={},
            )
            db.add(row)
        else:
            row.is_enabled = enabled
            row.scope = FeatureFlagScope.global_scope
            row.rules = row.rules or {}
            row.updated_at = _now()


def _ensure_rollout_city(db: Session, *, country: str, city: str) -> None:
    row = db.execute(
        select(RolloutCity).where(RolloutCity.country == country, RolloutCity.city == city)
    ).scalar_one_or_none()
    if row is None:
        db.add(
            RolloutCity(
                country=country,
                city=city,
                is_pro_onboarding_enabled=True,
                is_client_browsing_enabled=True,
                meta={"seeded": True},
            )
        )
    else:
        row.is_pro_onboarding_enabled = True
        row.is_client_browsing_enabled = True
        row.meta = {**(row.meta or {}), "seeded": True}
        row.updated_at = _now()


def _ensure_niche(db: Session, slug: str) -> Niche:
    niche = db.execute(select(Niche).where(Niche.slug == slug)).scalar_one_or_none()
    if niche is None:
        raise RuntimeError(f"missing niche slug={slug}; ensure_initial_niches did not create it")
    return niche


def _ensure_pro_profile(db: Session, user: SeedUser, niche: Niche, city: str, country: str, price: Decimal) -> ProPackage:
    profile = db.get(ProProfile, user.user_id)
    if profile is None:
        profile = ProProfile(
            user_id=user.user_id,
            display_name=user.display_name,
            headline=f"{niche.name} specialist",
            bio=f"Seeded {niche.name.lower()} profile for {user.display_name}",
            city=city,
            country=country,
            languages=["en"],
            styles=["editorial", "natural-light"],
            gear={"camera": "Sony A7IV", "lenses": ["35mm", "85mm"]},
            is_accepting_bookings=True,
            completeness_score=92,
            kyc_status=KYCStatus.approved,
            kyc_updated_at=_now(),
        )
        db.add(profile)
    else:
        profile.display_name = user.display_name
        profile.headline = profile.headline or f"{niche.name} specialist"
        profile.city = city
        profile.country = country
        profile.is_accepting_bookings = True
        profile.completeness_score = max(80, profile.completeness_score)
        profile.kyc_status = KYCStatus.approved
        profile.kyc_updated_at = _now()
        profile.updated_at = _now()

    onboarding = db.get(ProOnboarding, user.user_id)
    if onboarding is None:
        db.add(
            ProOnboarding(
                pro_user_id=user.user_id,
                status=ProOnboardingStatus.approved_public,
                current_city={"country": country, "city": city},
                notes="Seeded onboarding",
                started_at=_now() - timedelta(days=30),
                updated_at=_now(),
            )
        )
    else:
        onboarding.status = ProOnboardingStatus.approved_public
        onboarding.current_city = {"country": country, "city": city}
        onboarding.updated_at = _now()

    availability = db.execute(
        select(ProAvailabilityRule).where(ProAvailabilityRule.pro_user_id == user.user_id)
    ).scalars().first()
    if availability is None:
        db.add(
            ProAvailabilityRule(
                pro_user_id=user.user_id,
                day_of_week=2,
                start_time=time(9, 0),
                end_time=time(18, 0),
                timezone="America/New_York",
                location_mode=AvailabilityLocationMode.both,
            )
        )

    package_id = uuid.uuid5(uuid.NAMESPACE_URL, f"rawwers-seed-package:{user.user_id}")
    package = db.get(ProPackage, package_id)
    if package is None:
        package = ProPackage(
            id=package_id,
            pro_user_id=user.user_id,
            niche_id=niche.id,
            title=f"{niche.name} Starter",
            description="Seed package for testing booking funnel",
            duration_minutes=60,
            price=price,
            currency="EUR",
            included_photos=10,
            extra_photo_price=Decimal("7.00"),
            proofs_sla_days=3,
            finals_sla_days=7,
            addons=[{"name": "extra_hour", "price": 90}],
            is_active=True,
        )
        db.add(package)
    else:
        package.niche_id = niche.id
        package.is_active = True
        package.price = price
        package.extra_photo_price = Decimal("7.00")
        package.updated_at = _now()

    for idx in range(3):
        asset_id = uuid.uuid5(uuid.NAMESPACE_URL, f"rawwers-seed-portfolio:{user.user_id}:{idx}")
        asset = db.get(MediaAsset, asset_id)
        if asset is None:
            db.add(
                MediaAsset(
                    id=asset_id,
                    owner_user_id=user.user_id,
                    kind=MediaKind.photo,
                    purpose=MediaPurpose.portfolio_reel,
                    provider=MediaProvider.r2,
                    status=MediaStatus.ready,
                    visibility=MediaVisibility.public,
                    content_type="image/jpeg",
                    byte_size=1250000,
                    checksum=f"seed-{idx}",
                    meta={"seeded": True},
                )
            )

    return package


def _ensure_client_preference(db: Session, user_id: uuid.UUID) -> None:
    pref = db.get(ClientPreference, user_id)
    if pref is None:
        db.add(
            ClientPreference(
                user_id=user_id,
                preferred_niches=["portraits", "events_nightlife"],
                budget_min=Decimal("50.00"),
                budget_max=Decimal("400.00"),
                style_tags=["editorial"],
                location={"country": "US", "city": "New York"},
            )
        )
    else:
        pref.preferred_niches = ["portraits", "events_nightlife"]
        pref.budget_min = Decimal("50.00")
        pref.budget_max = Decimal("400.00")
        pref.style_tags = ["editorial"]
        pref.location = {"country": "US", "city": "New York"}
        pref.updated_at = _now()


def _ensure_sample_gig_and_proofs(db: Session, *, pro_user_id: uuid.UUID, client_user_id: uuid.UUID) -> None:
    gig_id = uuid.UUID("00000000-0000-0000-0000-000000000211")
    gig = db.get(Gig, gig_id)
    if gig is None:
        gig = Gig(
            id=gig_id,
            client_user_id=client_user_id,
            pro_user_id=pro_user_id,
            niche_id=None,
            status=GigStatus.proofs_delivered,
            currency="EUR",
            amount_total=Decimal("180.00"),
            amount_platform_fee=Decimal("36.00"),
            amount_pro_gross=Decimal("144.00"),
            scheduled_start=_now() - timedelta(days=3),
            scheduled_end=_now() - timedelta(days=3) + timedelta(hours=2),
            location_text="New York",
            meta={"seeded": True},
        )
        db.add(gig)
    db.flush()

    gallery_id = uuid.UUID("00000000-0000-0000-0000-000000000311")
    gallery = db.get(ProofGallery, gallery_id)
    if gallery is None:
        gallery = ProofGallery(
            id=gallery_id,
            gig_id=gig_id,
            pro_user_id=pro_user_id,
            client_user_id=client_user_id,
            included_photos=10,
            extra_photo_price=Decimal("7.00"),
            currency="EUR",
            status=ProofGalleryStatus.published,
            published_at=_now() - timedelta(days=1),
        )
        db.add(gallery)
    db.flush()

    for idx in range(5):
        proof_asset_id = uuid.uuid5(uuid.NAMESPACE_URL, f"rawwers-seed-proof:{gig_id}:{idx}")
        asset = db.get(MediaAsset, proof_asset_id)
        if asset is None:
            db.add(
                MediaAsset(
                    id=proof_asset_id,
                    owner_user_id=pro_user_id,
                    kind=MediaKind.photo,
                    purpose=MediaPurpose.proof,
                    provider=MediaProvider.r2,
                    status=MediaStatus.ready,
                    visibility=MediaVisibility.client_only,
                    content_type="image/jpeg",
                    byte_size=980000,
                    checksum=f"proof-{idx}",
                    meta={"seeded": True, "index": idx},
                )
            )
            db.flush()

        item_id = uuid.uuid5(uuid.NAMESPACE_URL, f"rawwers-seed-proof-item:{gallery_id}:{idx}")
        if db.get(ProofGalleryItem, item_id) is None:
            db.add(
                ProofGalleryItem(
                    id=item_id,
                    gallery_id=gallery_id,
                    media_asset_id=proof_asset_id,
                    sort_order=idx,
                )
            )


def _ensure_sample_booking_request(db: Session, *, pro_user_id: uuid.UUID, client_user_id: uuid.UUID, package_id: uuid.UUID) -> None:
    booking_id = uuid.UUID("00000000-0000-0000-0000-000000000411")
    booking = db.get(BookingRequest, booking_id)
    if booking is None:
        db.add(
            BookingRequest(
                id=booking_id,
                pro_user_id=pro_user_id,
                client_user_id=client_user_id,
                package_id=package_id,
                requested_start=_now() + timedelta(days=7),
                requested_end=_now() + timedelta(days=7, hours=2),
                location_text="New York",
                notes="Seed booking request",
                status=BookingRequestStatus.pending,
                expires_at=_now() + timedelta(days=2),
            )
        )


def seed_environment(db: Session, *, city: str, country: str, include_sample_booking: bool = True) -> None:
    ensure_initial_niches(db)
    _ensure_flags(db)
    _ensure_rollout_city(db, country=country, city=city)

    _upsert_user(db, ADMIN_USER)
    _upsert_user(db, CLIENT_USER)
    for pro in PRO_USERS:
        _upsert_user(db, pro)
    db.flush()

    portraits = _ensure_niche(db, "portraits")
    events = _ensure_niche(db, "events_nightlife")

    package_main = _ensure_pro_profile(db, PRO_USERS[0], portraits, city=city, country=country, price=Decimal("120.00"))
    _ensure_pro_profile(db, PRO_USERS[1], events, city=city, country=country, price=Decimal("160.00"))
    db.flush()

    _ensure_client_preference(db, CLIENT_USER.user_id)
    _ensure_sample_gig_and_proofs(db, pro_user_id=PRO_USERS[0].user_id, client_user_id=CLIENT_USER.user_id)
    db.flush()

    if include_sample_booking:
        _ensure_sample_booking_request(
            db,
            pro_user_id=PRO_USERS[0].user_id,
            client_user_id=CLIENT_USER.user_id,
            package_id=package_main.id,
        )

    db.flush()

    for pro in PRO_USERS:
        recompute_pro_public_index(db, pro.user_id)

    # Keep deterministic e2e target up to date.
    primary = db.get(ProPublicIndex, PRO_USERS[0].user_id)
    if primary:
        primary.city = city
        primary.country = country
        primary.is_accepting_bookings = True
        primary.kyc_status = KYCStatus.approved
        primary.completeness_score = max(primary.completeness_score, 80)
        primary.updated_at = _now()
