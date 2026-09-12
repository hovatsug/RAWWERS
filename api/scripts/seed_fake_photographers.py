#!/usr/bin/env python3
"""Populate a development database with photographers who look real.

Why this exists: every design decision in a photography marketplace is a
judgement about how actual photographs sit in an actual layout. Grey
placeholder rectangles, or one test account called "Alex Lens", tell you
nothing about whether a row of wedding work reads as beautiful or as
cluttered. This seeds enough genuine photography, spread honestly across
niches, tiers, cities and experience levels, that a layout can be judged.

Deliberately a separate entry point from seed_dev.py. That script seeds the
small deterministic set the e2e run depends on; this one adds forty
photographers and several hundred images, and the two must not ride along
together - an e2e failure should never be explained by "the fake data
changed".

Safety: refuses to run outside a development environment, through the same
assert_environment_is_seedable() guard seed_environment() uses.

    docker compose exec api python scripts/seed_fake_photographers.py --dry-run
    docker compose exec api python scripts/seed_fake_photographers.py
"""
from __future__ import annotations

import argparse
import io
import json
import os
import random
import sys
import urllib.error
import urllib.parse
import urllib.request
import uuid
from collections import Counter
from datetime import UTC, datetime, timedelta
from decimal import Decimal
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from _seed_common import assert_environment_is_seedable, _ensure_rollout_city, _upsert_user, SeedUser  # noqa: E402
from PIL import Image  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.db.session import SessionLocal  # noqa: E402
from app.models.admin import KYCStatus, ProProfile, UserRoleType  # noqa: E402
from app.models.booking import ProPackage  # noqa: E402
from app.models.gig import Gig, GigStatus  # noqa: E402
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus  # noqa: E402
from app.models.media import (  # noqa: E402
    MediaAsset,
    MediaKind,
    MediaObject,
    MediaProvider,
    MediaPurpose,
    MediaStatus,
    MediaVariant,
    MediaVisibility,
    ObjectStatus,
)
from app.models.media_rights import MediaDerivative, MediaDerivativeKind  # noqa: E402
from app.models.niche import Niche, ProNicheSkill, SkillTier  # noqa: E402
from app.services.discovery_index import recompute_pro_public_index  # noqa: E402
from app.services.niche_catalog import ensure_initial_niches  # noqa: E402
from app.services.storage import generate_variant_key, object_exists, upload_object_bytes  # noqa: E402
from app.tasks.media_tasks import watermarked_preview  # noqa: E402

# --------------------------------------------------------------------------
# Stock photography
# --------------------------------------------------------------------------

PEXELS_ENDPOINT = "https://api.pexels.com/v1/search"

# Python's default urllib User-Agent is rejected by Pexels' edge with
# Cloudflare error 1010, which presents as a 403 and reads exactly like a bad
# API key. It is not - the same key works with any browser UA.
_BROWSER_UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36"

CACHE_DIR = Path(__file__).resolve().parents[1] / ".seed-cache" / "pexels"

# What to search for, per niche. Phrased as a photographer would describe the
# work rather than as the slug, so the results actually look like the category
# - "product" alone returns shopping imagery, "product photography studio"
# returns product photography.
NICHE_QUERIES: dict[str, str] = {
    "weddings": "wedding photography couple",
    "portraits": "portrait photography studio",
    "events_nightlife": "concert nightlife party photography",
    "real_estate": "real estate interior architecture home",
    "product": "product photography studio still life",
    "food": "food photography restaurant dish",
    "corporate": "corporate business team office portrait",
    "family": "family photography children outdoor",
}

# Images fetched per niche. 8 niches x 18 = 144, inside the 120-150 agreed.
# Reused across the photographers in that niche: a wedding photographer's grid
# should look like wedding work, and drawing from a shared per-niche pool
# keeps that true while cutting fetches and storage roughly fourfold against
# unique-per-photographer.
IMAGES_PER_NICHE = 18


def _cache_path(photo_id: int) -> Path:
    return CACHE_DIR / f"{photo_id}.jpg"


def _http_get(url: str, *, headers: dict[str, str], timeout: int = 30) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": _BROWSER_UA, **headers})
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return response.read()


def fetch_niche_pool(niche_slug: str, *, api_key: str, count: int) -> list[int]:
    """Photo ids for one niche, downloading only what is not already cached.

    The cache is keyed by Pexels photo id on local disk, so a re-seed after a
    database wipe re-reads from disk rather than re-downloading ~144 images.
    """
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    query = urllib.parse.urlencode(
        {"query": NICHE_QUERIES[niche_slug], "per_page": count, "orientation": "landscape", "size": "large"}
    )
    payload = json.loads(_http_get(f"{PEXELS_ENDPOINT}?{query}", headers={"Authorization": api_key}))

    ids: list[int] = []
    downloaded = 0
    for photo in payload.get("photos", []):
        photo_id = photo["id"]
        path = _cache_path(photo_id)
        if not path.exists():
            try:
                path.write_bytes(_http_get(photo["src"]["large2x"], headers={}))
                downloaded += 1
            except (urllib.error.URLError, OSError) as exc:
                print(f"  ! could not fetch photo {photo_id}: {exc}")
                continue
        ids.append(photo_id)

    print(f"  {niche_slug:<18} {len(ids):>3} images ({downloaded} downloaded, {len(ids) - downloaded} cached)")
    return ids


# --------------------------------------------------------------------------
# The photographers
# --------------------------------------------------------------------------

# (name, city, country, niche, tier, gig band)
# Gig bands: "none" 0, "few" 1-5, "some" 6-20, "many" 21-60. Spread on purpose
# so a "new photographers" row has honest candidates and a "most booked" row
# has honest winners - a catalogue clustered at one experience level cannot
# test either.
PHOTOGRAPHERS: list[tuple[str, str, str, str, SkillTier, str]] = [
    ("Inês Carvalho", "Lisbon", "PT", "weddings", SkillTier.master, "many"),
    ("Tomás Belmonte", "Lisbon", "PT", "weddings", SkillTier.elite, "many"),
    ("Marta Vieira", "Porto", "PT", "weddings", SkillTier.pro, "some"),
    ("Rui Nogueira", "Madrid", "ES", "weddings", SkillTier.skilled, "few"),
    ("Clara Espinosa", "Barcelona", "ES", "weddings", SkillTier.rookie, "none"),
    ("Daniel Roque", "Lisbon", "PT", "portraits", SkillTier.master, "many"),
    ("Sofia Marchetti", "Barcelona", "ES", "portraits", SkillTier.elite, "some"),
    ("Hugo Pereira", "Porto", "PT", "portraits", SkillTier.pro, "some"),
    ("Aline Duarte", "Madrid", "ES", "portraits", SkillTier.skilled, "few"),
    ("Nuno Bastos", "Lisbon", "PT", "portraits", SkillTier.rookie, "none"),
    ("Beatriz Lemos", "Porto", "PT", "events_nightlife", SkillTier.elite, "many"),
    ("Xavier Molins", "Barcelona", "ES", "events_nightlife", SkillTier.pro, "some"),
    ("Filipa Antunes", "Lisbon", "PT", "events_nightlife", SkillTier.skilled, "few"),
    ("Gonçalo Neves", "Madrid", "ES", "events_nightlife", SkillTier.skilled, "few"),
    ("Rita Salgueiro", "Porto", "PT", "events_nightlife", SkillTier.rookie, "none"),
    ("André Quintela", "Lisbon", "PT", "real_estate", SkillTier.master, "many"),
    ("Lucía Ferrán", "Madrid", "ES", "real_estate", SkillTier.pro, "some"),
    ("Pedro Mascarenhas", "Porto", "PT", "real_estate", SkillTier.skilled, "few"),
    ("Núria Camps", "Barcelona", "ES", "real_estate", SkillTier.rookie, "none"),
    ("Vasco Teixeira", "Lisbon", "PT", "product", SkillTier.elite, "many"),
    ("Helena Brito", "Barcelona", "ES", "product", SkillTier.pro, "some"),
    ("Miguel Arroyo", "Madrid", "ES", "product", SkillTier.skilled, "few"),
    ("Carolina Pinto", "Porto", "PT", "product", SkillTier.rookie, "none"),
    ("Joana Rebelo", "Lisbon", "PT", "food", SkillTier.master, "many"),
    ("Sergi Puigdemont", "Barcelona", "ES", "food", SkillTier.elite, "some"),
    ("Diogo Faria", "Porto", "PT", "food", SkillTier.pro, "some"),
    ("Elena Sarabia", "Madrid", "ES", "food", SkillTier.skilled, "few"),
    ("Tiago Mendonça", "Lisbon", "PT", "food", SkillTier.rookie, "none"),
    ("Patrícia Boaventura", "Lisbon", "PT", "corporate", SkillTier.elite, "many"),
    ("Álvaro Cifuentes", "Madrid", "ES", "corporate", SkillTier.pro, "some"),
    ("Susana Melo", "Porto", "PT", "corporate", SkillTier.skilled, "few"),
    ("Jordi Vilanova", "Barcelona", "ES", "corporate", SkillTier.skilled, "few"),
    ("Bruno Cardoso", "Lisbon", "PT", "corporate", SkillTier.rookie, "none"),
    ("Madalena Seixas", "Porto", "PT", "family", SkillTier.master, "many"),
    ("Paula Guerrero", "Madrid", "ES", "family", SkillTier.elite, "some"),
    ("Ricardo Amorim", "Lisbon", "PT", "family", SkillTier.pro, "some"),
    ("Mireia Bosch", "Barcelona", "ES", "family", SkillTier.skilled, "few"),
    ("Leonor Falcão", "Porto", "PT", "family", SkillTier.skilled, "few"),
    ("Simão Vasques", "Lisbon", "PT", "family", SkillTier.rookie, "none"),
    ("Catarina Lobo", "Barcelona", "ES", "portraits", SkillTier.pro, "some"),
]

HEADLINES: dict[str, list[str]] = {
    "weddings": [
        "Unposed wedding photography, start to last dance",
        "Documentary weddings with nothing staged",
        "Quiet, close wedding coverage",
        "Weddings shot like a day worth remembering",
        "Available light, real moments, full days",
    ],
    "portraits": [
        "Portraits that look like the person, not the pose",
        "Studio and natural-light portraiture",
        "Headshots and personal portraiture",
        "Portrait sessions, unhurried",
        "Character-first portraiture",
    ],
    "events_nightlife": [
        "Nightlife and live music, shot fast",
        "Festivals, clubs and late sets",
        "Event coverage that keeps up",
        "Live music photography",
        "Crowds, stages and the small moments between",
    ],
    "real_estate": [
        "Interiors and architecture, corrected and clean",
        "Property photography that sells the room",
        "Architectural interiors, natural light first",
        "Listings shot properly",
    ],
    "product": [
        "Studio product photography for e-commerce",
        "Still life and packshots",
        "Clean product work on white and in context",
        "Product photography with considered light",
    ],
    "food": [
        "Restaurant and menu photography",
        "Food shot the way it is served",
        "Editorial food and drink",
        "Dishes, kitchens and the people cooking",
        "Food photography for menus and press",
    ],
    "corporate": [
        "Team portraits and workplace photography",
        "Corporate headshots without the stiffness",
        "Conference and company photography",
        "Business portraiture and event coverage",
        "Office culture, honestly photographed",
    ],
    "family": [
        "Family sessions that are actually fun",
        "Children and family photography outdoors",
        "Unposed family photography",
        "Family portraits at home",
        "Growing-up photography, year by year",
    ],
}

BIOS: dict[str, list[str]] = {
    "weddings": [
        "I photograph weddings the way they actually happen. No shot list of poses, no "
        "three hours of formals - I stay close, stay quiet, and come back with the day you had.",
        "Twelve years of weddings has taught me that the pictures people keep are almost never "
        "the ones they asked for. I shoot for those instead.",
        "I work alone, in available light, and I do not ask anyone to do anything twice. "
        "Full-day coverage, everything delivered.",
    ],
    "portraits": [
        "Most people tell me they hate having their photo taken. That is usually because nobody "
        "gave them time. Sessions run long on purpose.",
        "Studio when the light needs controlling, outside when it does not. Either way the aim is "
        "the same - a photograph that looks like you on a good day.",
        "I photograph people for who they are rather than what they do. Headshots, personal work, "
        "and everything in between.",
    ],
    "events_nightlife": [
        "Clubs, festivals and late sets. I shoot fast, in bad light, without a flash in anyone's "
        "face, and I deliver the next morning.",
        "I have photographed enough live music to know the moment is usually not on stage. "
        "I watch the room as much as the band.",
        "Event coverage that keeps pace with the night rather than interrupting it.",
    ],
    "real_estate": [
        "Straight lines, honest colour, and rooms that look like themselves. I correct verticals "
        "and I do not fake a sky that was not there.",
        "Interiors and architecture for agents, architects and owners. Shot with natural light "
        "wherever the room allows it.",
        "A listing lives or dies on the first three photographs. I treat them that way.",
    ],
    "product": [
        "Packshots, still life and product work for online shops. Consistent across a catalogue, "
        "which matters more than any single hero shot.",
        "Studio product photography - clean on white when you need it, in context when the "
        "product needs explaining.",
        "I shoot small objects properly: controlled light, real shadows, colour you can trust "
        "against the physical product.",
    ],
    "food": [
        "I photograph food the way the kitchen sends it out, not rebuilt with glue and paint. "
        "Menus, press, and restaurant launches.",
        "Editorial food and drink work. I shoot fast enough that nothing wilts and the chef gets "
        "their pass back.",
        "Restaurants, producers and drinks brands. Natural light when the room has it, built "
        "light when it does not.",
    ],
    "corporate": [
        "Team portraits that do not look like a police lineup, plus conference and workplace "
        "coverage. I work quickly around people who have jobs to do.",
        "Corporate photography without the stock-photo handshake. Real desks, real people, "
        "real light.",
        "Headshots for whole companies, shot consistently so they sit together on one page.",
    ],
    "family": [
        "Family sessions with no instructions to smile. Children are allowed to be children and "
        "the photographs are better for it.",
        "I photograph families outdoors, at home, and anywhere the children will actually relax. "
        "Nothing posed unless you ask.",
        "Yearly sessions for families who want to see the change rather than a perfect portrait.",
    ],
}

GIG_BANDS: dict[str, tuple[int, int]] = {
    "none": (0, 0),
    "few": (1, 5),
    "some": (6, 20),
    "many": (21, 60),
}

CITY_PRICE: dict[str, tuple[int, int]] = {
    "Lisbon": (95, 260),
    "Porto": (80, 210),
    "Madrid": (110, 300),
    "Barcelona": (105, 285),
}


def _sid(*parts: str) -> uuid.UUID:
    return uuid.uuid5(uuid.NAMESPACE_URL, "rawwers-fake-photographer:" + ":".join(parts))


def _slugify(name: str) -> str:
    import unicodedata

    ascii_name = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode()
    return "".join(c.lower() if c.isalnum() else "." for c in ascii_name).strip(".").replace("..", ".")


# --------------------------------------------------------------------------
# Media
# --------------------------------------------------------------------------


def _build_media(db, *, owner_id: uuid.UUID, photo_id: int, index: int, niche_slugs: list[str]) -> uuid.UUID | None:
    """One portfolio photo, with every variant a real upload produces.

    The existing seeder wrote `original` and `thumbnail` only, so a seeded
    photo had no watermarked preview and no web_res derivative - which means a
    null preview_url, and a fullscreen viewer opening onto nothing. Design work
    judged against that would be judging the seed, not the app. This produces
    all four, and the watermark comes from the same function the worker runs,
    so a seeded preview is marked exactly like a real one.
    """
    source = _cache_path(photo_id)
    if not source.exists():
        return None

    asset_id = _sid("asset", str(owner_id), str(photo_id), str(index))
    base_key = f"seed/fake/{owner_id}/portfolio/{photo_id}.jpg"

    image = Image.open(io.BytesIO(source.read_bytes())).convert("RGB")

    thumb = image.copy()
    thumb.thumbnail((512, 512))
    web = image.copy()
    if web.width > 2048:
        web.thumbnail((2048, 2048))

    asset = db.get(MediaAsset, asset_id)
    if asset is None:
        asset = MediaAsset(
            id=asset_id,
            owner_user_id=owner_id,
            kind=MediaKind.photo,
            purpose=MediaPurpose.portfolio_reel,
            provider=MediaProvider.r2,
            status=MediaStatus.ready,
            visibility=MediaVisibility.public,
            content_type="image/jpeg",
            byte_size=source.stat().st_size,
            checksum=f"pexels-{photo_id}",
            niche_tags=niche_slugs,
            meta={"seeded": True, "source": "pexels", "pexels_id": photo_id},
        )
        db.add(asset)
    else:
        asset.niche_tags = niche_slugs

    watermark = watermarked_preview(db, asset, image, include_powered_by=False)

    variants = [
        (MediaVariant.original, base_key, image),
        (MediaVariant.thumbnail, generate_variant_key(base_key, "thumbnail"), thumb),
        (MediaVariant.watermark_preview, generate_variant_key(base_key, "watermark_preview"), watermark),
    ]
    for variant, key, rendered in variants:
        existing = db.execute(
            select(MediaObject).where(MediaObject.media_asset_id == asset_id, MediaObject.variant == variant)
        ).scalar_one_or_none()
        if existing is None:
            db.add(
                MediaObject(
                    media_asset_id=asset_id,
                    variant=variant,
                    storage_key=key,
                    width=rendered.width,
                    height=rendered.height,
                    status=ObjectStatus.ready,
                )
            )
        _upload(key, rendered)

    web_key = generate_variant_key(base_key, "web_res")
    existing_derivative = db.execute(
        select(MediaDerivative).where(
            MediaDerivative.media_asset_id == asset_id,
            MediaDerivative.kind == MediaDerivativeKind.web_res,
        )
    ).scalar_one_or_none()
    if existing_derivative is None:
        buffer = io.BytesIO()
        web.save(buffer, format="JPEG", quality=88)
        db.add(
            MediaDerivative(
                media_asset_id=asset_id,
                kind=MediaDerivativeKind.web_res,
                storage_key=web_key,
                content_type="image/jpeg",
                width=web.width,
                height=web.height,
                bytes=len(buffer.getvalue()),
            )
        )
    _upload(web_key, web)

    return asset_id


def _upload(storage_key: str, image: Image.Image) -> None:
    """Best-effort, like the existing seeder: a database that is coherent
    without object storage beats one that half-exists because R2 was down."""
    try:
        if object_exists(storage_key):
            return
        buffer = io.BytesIO()
        image.save(buffer, format="JPEG", quality=86)
        upload_object_bytes(storage_key, buffer.getvalue(), content_type="image/jpeg")
    except Exception as exc:  # noqa: BLE001
        print(f"  ! upload failed {storage_key}: {exc}")


# --------------------------------------------------------------------------
# Seeding
# --------------------------------------------------------------------------


def seed(db, *, pools: dict[str, list[int]], rng: random.Random) -> Counter:
    stats: Counter = Counter()
    niches = {n.slug: n for n in db.execute(select(Niche)).scalars().all()}
    now = datetime.now(UTC)

    for position, (name, city, country, niche_slug, tier, band) in enumerate(PHOTOGRAPHERS):
        niche = niches[niche_slug]
        user_id = _sid("user", name)
        handle = _slugify(name)

        _upsert_user(
            db,
            SeedUser(
                user_id=user_id,
                email=f"{handle}@rawwers.dev",
                password="Passw0rd!",
                display_name=name,
                roles=(UserRoleType.pro, UserRoleType.client),
            ),
        )
        db.flush()

        profile = db.get(ProProfile, user_id)
        if profile is None:
            profile = ProProfile(user_id=user_id)
            db.add(profile)
            db.flush()
        profile.display_name = name
        profile.headline = rng.choice(HEADLINES[niche_slug])
        profile.bio = rng.choice(BIOS[niche_slug])
        profile.city = city
        profile.country = country
        profile.styles = ["documentary", "editorial", "natural-light"][: 1 + position % 3]
        profile.is_accepting_bookings = True
        profile.kyc_status = KYCStatus.approved
        profile.completeness_score = rng.randint(72, 98)

        onboarding = db.get(ProOnboarding, user_id) or ProOnboarding(pro_user_id=user_id)
        if onboarding.pro_user_id is None:
            onboarding.pro_user_id = user_id
        db.add(onboarding)
        onboarding.status = ProOnboardingStatus.approved_public
        onboarding.current_city = {"city": city, "country": country}

        low, high = CITY_PRICE[city]
        price = Decimal(rng.randint(low, high)).quantize(Decimal("0.01"))
        package = db.execute(
            select(ProPackage).where(ProPackage.pro_user_id == user_id, ProPackage.niche_id == niche.id)
        ).scalar_one_or_none()
        if package is None:
            package = ProPackage(
                pro_user_id=user_id,
                niche_id=niche.id,
                title=f"{niche.name} session",
                duration_minutes=rng.choice([60, 90, 120, 180]),
                price=price,
                currency="EUR",
                included_photos=rng.choice([15, 20, 25, 30]),
                extra_photo_price=Decimal("12.00"),
                proofs_sla_days=3,
                finals_sla_days=10,
                addons=[],
                is_active=True,
            )
            db.add(package)

        # Portfolio: 8-15 images drawn from this niche's shared pool, offset
        # per photographer so two wedding photographers do not show the same
        # grid in the same order.
        pool = pools.get(niche_slug, [])
        wanted = rng.randint(8, 15)
        if pool:
            offset = (position * 5) % len(pool)
            chosen = [pool[(offset + i) % len(pool)] for i in range(min(wanted, len(pool)))]
        else:
            chosen = []

        asset_ids: list[uuid.UUID] = []
        for index, photo_id in enumerate(chosen):
            asset_id = _build_media(db, owner_id=user_id, photo_id=photo_id, index=index, niche_slugs=[niche_slug])
            if asset_id:
                asset_ids.append(asset_id)
        stats["images"] += len(asset_ids)

        # The cover is deliberately not asset_ids[0]: a hero identical to the
        # first grid tile makes the profile look like a bug.
        if asset_ids:
            profile.cover_media_asset_id = asset_ids[-1]

        gig_low, gig_high = GIG_BANDS[band]
        gig_count = rng.randint(gig_low, gig_high) if gig_high else 0
        _ensure_gigs(db, pro_user_id=user_id, niche_id=niche.id, count=gig_count, price=price, now=now)

        skill = db.execute(
            select(ProNicheSkill).where(ProNicheSkill.pro_user_id == user_id, ProNicheSkill.niche_id == niche.id)
        ).scalar_one_or_none()
        if skill is None:
            skill = ProNicheSkill(pro_user_id=user_id, niche_id=niche.id)
            db.add(skill)
        skill.tier = tier
        skill.gigs_completed = gig_count
        skill.review_count = max(0, gig_count - rng.randint(0, 3))
        skill.avg_rating = Decimal("0.00") if gig_count == 0 else Decimal(str(round(rng.uniform(4.1, 5.0), 2)))
        skill.verified = tier in {SkillTier.pro, SkillTier.elite, SkillTier.master}
        skill.score = {
            SkillTier.rookie: rng.randint(5, 24),
            SkillTier.skilled: rng.randint(25, 49),
            SkillTier.pro: rng.randint(50, 69),
            SkillTier.elite: rng.randint(70, 84),
            SkillTier.master: rng.randint(85, 100),
        }[tier]
        skill.capability_score = skill.score
        skill.confidence = Decimal(str(round(min(0.95, 0.2 + gig_count / 60), 2)))
        skill.evidence_gigs = gig_count
        skill.evidence_reviews = skill.review_count
        skill.evidence_portfolio = len(asset_ids)

        db.flush()
        stats[f"niche:{niche_slug}"] += 1
        stats[f"tier:{tier.value}"] += 1
        stats[f"band:{band}"] += 1
        stats[f"city:{city}"] += 1
        stats["photographers"] += 1
        print(f"  [{position + 1:>2}/{len(PHOTOGRAPHERS)}] {name:<22} {niche_slug:<17} {tier.value:<8} {len(asset_ids):>2} photos, {gig_count:>2} gigs")

    return stats


def _ensure_gigs(db, *, pro_user_id: uuid.UUID, niche_id: uuid.UUID, count: int, price: Decimal, now) -> None:
    """Completed gigs, because the discovery index counts rows rather than
    trusting a number written on the profile."""
    existing = db.execute(
        select(Gig).where(Gig.pro_user_id == pro_user_id, Gig.status == GigStatus.completed)
    ).scalars().all()
    for index in range(len(existing), count):
        db.add(
            Gig(
                id=_sid("gig", str(pro_user_id), str(index)),
                client_user_id=_sid("client", str(pro_user_id), str(index)),
                pro_user_id=pro_user_id,
                niche_id=niche_id,
                status=GigStatus.completed,
                currency="EUR",
                amount_minimum=price * 10,
                entry_rate=price,
                amount_platform_fee=price * 2,
                amount_pro_gross=price * 8,
                created_at=now - timedelta(days=7 * (index + 1)),
                meta={"seeded": True},
            )
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Fetch and report, write nothing")
    parser.add_argument("--seed", type=int, default=20260912, help="RNG seed, so runs are reproducible")
    args = parser.parse_args()

    assert_environment_is_seedable()

    api_key = os.environ.get("PEXELS_API_KEY")
    if not api_key:
        print("PEXELS_API_KEY is not set. Add it to api/.env.")
        return 1

    rng = random.Random(args.seed)

    print("Fetching stock photography (cached on disk after the first run):")
    pools = {slug: fetch_niche_pool(slug, api_key=api_key, count=IMAGES_PER_NICHE) for slug in NICHE_QUERIES}
    total_images = sum(len(v) for v in pools.values())
    print(f"  pool total: {total_images} images across {len(pools)} niches\n")

    if args.dry_run:
        print(f"Dry run: would create {len(PHOTOGRAPHERS)} photographers from the pool above. Nothing written.")
        return 0

    db = SessionLocal()
    try:
        ensure_initial_niches(db)
        for city, country in {(c, k) for _n, c, k, *_r in PHOTOGRAPHERS}:
            _ensure_rollout_city(db, country=country, city=city)
        db.flush()

        print("Creating photographers:")
        stats = seed(db, pools=pools, rng=rng)
        db.commit()

        print("\nRebuilding the discovery index:")
        for name, *_rest in PHOTOGRAPHERS:
            recompute_pro_public_index(db, _sid("user", name))
        db.commit()
        print(f"  indexed {stats['photographers']} photographers")

        _report(stats)
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
    return 0


def _report(stats: Counter) -> None:
    def block(title: str, prefix: str) -> None:
        rows = sorted(((k.split(":", 1)[1], v) for k, v in stats.items() if k.startswith(prefix)), key=lambda r: -r[1])
        print(f"\n{title}")
        for label, count in rows:
            print(f"  {label:<20} {count:>3}")

    print(f"\n{'=' * 52}\nSeeded {stats['photographers']} photographers, {stats['images']} portfolio images")
    block("Per niche", "niche:")
    block("Per tier", "tier:")
    block("Per gig-count band", "band:")
    block("Per city", "city:")


if __name__ == "__main__":
    raise SystemExit(main())
