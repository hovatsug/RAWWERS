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

Re-running must repair, not only create: every helper here is expected to
bring an existing row back into line as well as write a new one. See the
standing rule at the top of _seed_common.py, which lists the three times
forgetting that has cost this project.

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
from app.models.niche import Niche, ProNiche, ProNicheSkill, SkillTier  # noqa: E402
from app.models.discovery import ProPublicIndex  # noqa: E402
from app.services.commission import split_for_pro  # noqa: E402
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

# Photographers who work in more than one niche.
#
# Added because the per-niche profile presentation has a tab-vs-no-tab
# decision in it, and with every seeded photographer in exactly one niche
# that branch was untestable - the tabs would have been built against a
# dataset that could never exercise them. Pairings are ones that actually
# co-occur: wedding photographers shoot families, event photographers get
# hired for corporate work, food and product share a studio and a lighting
# kit.
#
# The secondary tier sits one step below the primary. Someone established in
# weddings is rarely equally established in portraits, and a profile showing
# master in both reads as fake.
SECONDARY_NICHES: dict[str, list[str]] = {
    "Inês Carvalho": ["portraits", "family"],
    "Tomás Belmonte": ["portraits"],
    "Marta Vieira": ["family"],
    "Daniel Roque": ["corporate", "weddings"],
    "Beatriz Lemos": ["corporate"],
    "Xavier Molins": ["corporate"],
    "Joana Rebelo": ["product"],
    "Vasco Teixeira": ["food"],
    "Madalena Seixas": ["portraits", "weddings"],
    "Patrícia Boaventura": ["portraits"],
}

# What a photographer says about one particular kind of work, keyed by niche.
#
# Deliberately partial. A profile falls back to the general bio when a niche
# has no description, and seeding every one would leave that fallback never
# rendered - the same reason the price caps left master uncapped rather than
# giving every tier a number.
NICHE_DESCRIPTIONS: dict[str, str] = {
    "weddings": "Long days, shot quietly. I stay out of the way and come back with the day as it actually happened.",
    "portraits": "Studio or daylight, always directed. Most people arrive certain they photograph badly and leave with something they use for years.",
    "family": "Loose, warm and quick, because nobody under six holds a pose. Shot where the family already is.",
    "corporate": "Headshots and team work on location, lit to match the brand rather than the boardroom.",
    "product": "Controlled light on a clean set. Built for a catalogue that has to look consistent across a hundred frames.",
    "food": "Shot while it is still worth eating. I work alongside the kitchen rather than after service.",
}

# Only these photographers have written them. Everyone else falls back.
DESCRIBES_THEIR_NICHES = {
    "Inês Carvalho",
    "Tomás Belmonte",
    "Daniel Roque",
    "Madalena Seixas",
}

_TIER_LADDER = [SkillTier.rookie, SkillTier.skilled, SkillTier.pro, SkillTier.elite, SkillTier.master]


def _one_step_down(tier: SkillTier) -> SkillTier:
    index = _TIER_LADDER.index(tier)
    return _TIER_LADDER[max(0, index - 1)]


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

# A per-city multiplier on the cap, rather than absolute prices.
#
# Absolute figures here (95-260 per photo) predated the price caps and put 59
# of 66 seeded packages over their ceiling the moment caps were seeded - so a
# photographer opening their own package in the demo could not save it. Not a
# bug, but indistinguishable from one for anybody testing the app.
#
# Pricing as a fraction of the tier's cap keeps the seed compliant by
# construction: if the caps move, the seeded prices move with them, and there
# is no second table of numbers to keep in step.
CITY_PRICE_FACTOR: dict[str, tuple[float, float]] = {
    "Lisbon": (0.70, 0.95),
    "Porto": (0.55, 0.80),
    "Madrid": (0.75, 1.00),
    "Barcelona": (0.72, 0.97),
}

# What a master charges, since master is uncapped and a fraction of nothing is
# nothing. Sits above the elite ceiling for the niche, which is the point of
# being uncapped.
MASTER_PREMIUM = (1.15, 1.60)


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


def seed(db, *, pools: dict[str, list[int]], rng: random.Random, prices_only: bool = False) -> Counter:
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


        # Every niche this photographer works in: the primary first, then any
        # secondary ones a step down the tier ladder. Each gets its own
        # package, its own portfolio subset and its own skill row, because
        # that is what the per-niche profile presentation reads.
        niche_plan: list[tuple[str, SkillTier]] = [(niche_slug, tier)]
        for extra_slug in SECONDARY_NICHES.get(name, []):
            niche_plan.append((extra_slug, _one_step_down(tier)))

        asset_ids: list[uuid.UUID] = []
        for niche_index, (plan_slug, plan_tier) in enumerate(niche_plan):
            plan_niche = niches[plan_slug]

            # The pro/niche association itself, which nothing had ever
            # written. Without it a photographer has skill rows and tagged
            # photos but has never declared what they do, and the description
            # the profile reads has nowhere to live.
            declared = db.execute(
                select(ProNiche).where(
                    ProNiche.pro_user_id == user_id, ProNiche.niche_id == plan_niche.id
                )
            ).scalar_one_or_none()
            if declared is None:
                declared = ProNiche(pro_user_id=user_id, niche_id=plan_niche.id)
                db.add(declared)
            declared.is_primary = niche_index == 0
            declared.description = (
                NICHE_DESCRIPTIONS.get(plan_slug) if name in DESCRIBES_THEIR_NICHES else None
            )
            price = _compliant_price(db, niche=plan_niche, tier=plan_tier, city=city, rng=rng)
            package = db.execute(
                select(ProPackage).where(
                    ProPackage.pro_user_id == user_id, ProPackage.niche_id == plan_niche.id
                )
            ).scalar_one_or_none()
            if package is not None:
                # Re-running must bring an existing package back into line,
                # not skip it. The first version only created, so a reseed
                # after the price caps landed finished successfully and
                # changed nothing - 56 packages stayed over cap while the
                # script reported success.
                package.price = price
                package.included_photos = package.included_photos or rng.choice([15, 20, 25, 30])
                package.is_active = True
            else:
                db.add(
                    ProPackage(
                        pro_user_id=user_id,
                        niche_id=plan_niche.id,
                        title=f"{plan_niche.name} session",
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
                )

            # Portfolio: images from this niche's shared pool, offset per
            # photographer so two wedding photographers do not show the same
            # grid in the same order. A secondary niche gets a smaller set,
            # which is also true of real photographers.
            pool = pools.get(plan_slug, [])
            wanted = rng.randint(8, 15) if niche_index == 0 else rng.randint(4, 7)
            if pool:
                offset = (position * 5 + niche_index * 7) % len(pool)
                chosen = [pool[(offset + i) % len(pool)] for i in range(min(wanted, len(pool)))]
            else:
                chosen = []

            for index, photo_id in enumerate([] if prices_only else chosen):
                asset_id = _build_media(
                    db,
                    owner_id=user_id,
                    photo_id=photo_id,
                    index=index + niche_index * 100,
                    niche_slugs=[plan_slug],
                )
                if asset_id:
                    asset_ids.append(asset_id)

            _ensure_skill(
                db,
                user_id=user_id,
                niche=plan_niche,
                tier=plan_tier,
                gig_count=0,  # set below for the primary niche only
                portfolio_count=len(chosen),
                rng=rng,
            )

        stats["images"] += len(asset_ids)
        stats[f"niches_per_pro:{len(niche_plan)}"] += 1

        # The cover is deliberately not asset_ids[0]: a hero identical to the
        # first grid tile makes the profile look like a bug.
        if asset_ids:
            profile.cover_media_asset_id = asset_ids[-1]

        gig_low, gig_high = GIG_BANDS[band]
        gig_count = rng.randint(gig_low, gig_high) if gig_high else 0
        _ensure_gigs(db, pro_user_id=user_id, niche_id=niche.id, count=gig_count, price=_compliant_price(db, niche=niche, tier=tier, city=city, rng=rng), now=now)
        # Completed work belongs to the niche it was booked in, so only the
        # primary skill carries the gig count. A secondary niche with the same
        # number of gigs as the primary would be a claim the gigs table
        # contradicts.
        _ensure_skill(
            db,
            user_id=user_id,
            niche=niche,
            tier=tier,
            gig_count=gig_count,
            portfolio_count=len(asset_ids),
            rng=rng,
        )

        db.flush()
        stats[f"niche:{niche_slug}"] += 1
        stats[f"tier:{tier.value}"] += 1
        stats[f"band:{band}"] += 1
        stats[f"city:{city}"] += 1
        stats["photographers"] += 1
        print(f"  [{position + 1:>2}/{len(PHOTOGRAPHERS)}] {name:<22} {niche_slug:<17} {tier.value:<8} {len(asset_ids):>2} photos, {gig_count:>2} gigs")

    return stats


def _compliant_price(db, *, niche, tier: SkillTier, city: str, rng: random.Random) -> Decimal:
    """A per-photo rate this photographer is actually allowed to charge.

    Read from the cap rather than invented, so seeded data obeys the
    platform's own rules. A seed that violates them produces a demo where
    every photographer is blocked from editing their own package - correct
    enforcement, and indistinguishable from a broken screen.

    Master is uncapped, so there is no fraction to take: they price above the
    elite ceiling, which is what being uncapped is for.
    """
    from app.services.package_pricing import get_price_cap

    low_factor, high_factor = CITY_PRICE_FACTOR[city]
    cap = get_price_cap(db, niche_id=niche.id, tier=tier)

    if cap is not None and cap.entry_price_max is not None:
        ceiling = float(cap.entry_price_max)
    else:
        elite = get_price_cap(db, niche_id=niche.id, tier=SkillTier.elite)
        if elite is None or elite.entry_price_max is None:
            # No caps configured for this niche at all - the pre-cap state.
            return Decimal(rng.randint(80, 200)).quantize(Decimal("0.01"))
        low_factor, high_factor = MASTER_PREMIUM
        ceiling = float(elite.entry_price_max)

    price = ceiling * rng.uniform(low_factor, high_factor)
    return Decimal(str(round(price, 2))).quantize(Decimal("0.01"))


def _ensure_skill(db, *, user_id, niche, tier, gig_count: int, portfolio_count: int, rng) -> None:
    """One ProNicheSkill row. Called once per niche the photographer works in,
    because tier is per-niche in this data model and a profile that shows the
    same tier everywhere is the flat version the per-niche presentation
    exists to replace."""
    skill = db.execute(
        select(ProNicheSkill).where(
            ProNicheSkill.pro_user_id == user_id, ProNicheSkill.niche_id == niche.id
        )
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
    skill.evidence_portfolio = portfolio_count


def gig_schedule(gig, *, duration_minutes: int, now) -> tuple[datetime, datetime] | None:
    """When a completed gig was actually shot.

    Derived the way the real flow derives it rather than invented. A client
    sends a booking request for a date, the photographer accepts, and the gig
    is created at acceptance with `scheduled_start = request.requested_start`
    and the end taken from the package duration. So acceptance comes first
    and the shoot follows some days later.

    `created_at` is the acceptance here, and the lead time is a deterministic
    function of the gig id so re-running produces the same dates rather than
    moving everyone's history. The result is clamped to stay in the past: a
    gig that is both completed and scheduled for next week is the same
    contradiction this exists to remove.
    """
    accepted = gig.created_at
    if accepted is None:
        return None
    if accepted.tzinfo is None:
        accepted = accepted.replace(tzinfo=UTC)

    # 3 to 20 days between accepting and shooting, and a daylight hour.
    spread = int(gig.id.int % 18) + 3
    hour = 9 + int(gig.id.int % 8)
    start = (accepted + timedelta(days=spread)).replace(hour=hour, minute=0, second=0, microsecond=0)

    end = start + timedelta(minutes=max(30, duration_minutes))
    if end >= now:
        # The most recent gigs are only a week old, so a long lead would put
        # the shoot in the future. Fall back to the day after acceptance.
        start = (accepted + timedelta(days=1)).replace(hour=hour, minute=0, second=0, microsecond=0)
        end = start + timedelta(minutes=max(30, duration_minutes))
        if end >= now:
            return None
    return start, end


def _package_duration(db, *, pro_user_id: uuid.UUID, niche_id: uuid.UUID) -> int:
    package = db.execute(
        select(ProPackage).where(
            ProPackage.pro_user_id == pro_user_id, ProPackage.niche_id == niche_id
        )
    ).scalars().first()
    return int(package.duration_minutes) if package and package.duration_minutes else 120


def _ensure_gigs(db, *, pro_user_id: uuid.UUID, niche_id: uuid.UUID, count: int, price: Decimal, now) -> None:
    """Completed gigs, because the discovery index counts rows rather than
    trusting a number written on the profile."""
    existing = db.execute(
        select(Gig).where(Gig.pro_user_id == pro_user_id, Gig.status == GigStatus.completed)
    ).scalars().all()
    duration = _package_duration(db, pro_user_id=pro_user_id, niche_id=niche_id)

    for index in range(len(existing), count):
        # The rate comes from the policy, not from multiplying by 2 and 8.
        # Those literals were a third definition of the platform's 20%, and
        # seeded money that does not track the real rate is money that lies
        # about what the platform would actually have taken.
        gross = (price * 10).quantize(Decimal("0.01"))
        split = split_for_pro(db, gross=gross, pro_user_id=pro_user_id)

        gig = Gig(
            id=_sid("gig", str(pro_user_id), str(index)),
            client_user_id=_sid("client", str(pro_user_id), str(index)),
            pro_user_id=pro_user_id,
            niche_id=niche_id,
            status=GigStatus.completed,
            currency="EUR",
            amount_minimum=gross,
            entry_rate=price,
            amount_platform_fee=split.platform_total,
            amount_pro_gross=split.pro_total,
            fee_percent=split.fee_percent,
            retained_percent=split.retained_percent,
            pro_raww_percent=split.pro_raww_percent,
            client_credit_percent=split.client_credit_percent,
            created_at=now - timedelta(days=7 * (index + 1)),
            meta={"seeded": True},
        )
        schedule = gig_schedule(gig, duration_minutes=duration, now=now)
        if schedule is not None:
            gig.scheduled_start, gig.scheduled_end = schedule
        db.add(gig)

    # Re-running repairs what is already there. The first version wrote no
    # dates at all, so every seeded gig rendered as "Not scheduled yet" on a
    # card that also called it completed.
    for gig in existing:
        if gig.scheduled_start is not None and gig.scheduled_end is not None:
            continue
        schedule = gig_schedule(gig, duration_minutes=duration, now=now)
        if schedule is not None:
            gig.scheduled_start, gig.scheduled_end = schedule


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Fetch and report, write nothing")
    parser.add_argument(
        "--prices-only",
        action="store_true",
        help="Skip media entirely and only bring package prices back within their caps",
    )
    parser.add_argument("--seed", type=int, default=20260912, help="RNG seed, so runs are reproducible")
    args = parser.parse_args()

    assert_environment_is_seedable()

    api_key = os.environ.get("PEXELS_API_KEY")
    if not api_key:
        print("PEXELS_API_KEY is not set. Add it to api/.env.")
        return 1

    rng = random.Random(args.seed)

    print("Fetching stock photography (cached on disk after the first run):")
    pools = (
        {}
        if args.prices_only
        else {slug: fetch_niche_pool(slug, api_key=api_key, count=IMAGES_PER_NICHE) for slug in NICHE_QUERIES}
    )
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
        stats = seed(db, pools=pools, rng=rng, prices_only=args.prices_only)
        db.commit()

        # Order matters, and getting it wrong made the first run's tier
        # distribution a fiction. recompute_pro_public_index() calls
        # recompute_pro_niche_skills() first, which derives tier from real
        # evidence and overwrote every seeded tier back to rookie - 672 rows
        # of it. The seeded distribution existed only in this script's own
        # counter, never in the database.
        #
        # So: index first, then re-apply the intended tiers, then refresh the
        # index fields that read from them, using the same helpers the
        # recompute uses rather than hand-writing the JSON shape.
        print("\nRebuilding the discovery index:")
        for name, *_rest in PHOTOGRAPHERS:
            recompute_pro_public_index(db, _sid("user", name))
        db.commit()

        print("Applying seeded tiers (after the recompute, not before):")
        applied = _apply_tiers(db, rng=rng)
        db.commit()
        print(f"  set {applied} skill rows and refreshed their index entries")

        _report(db, stats)
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
    return 0


def _apply_tiers(db, *, rng: random.Random) -> int:
    """Re-assert the intended tiers, and rebuild what the index derives.

    recompute_pro_niche_skills() is the real promotion engine and it is right
    to overwrite an invented tier - a photographer with no gigs and no reviews
    genuinely is a rookie. But seed data exists to populate states the real
    engine would take months to produce, so the tiers are applied afterwards
    and the index is refreshed from them.

    The index fields are rebuilt with get_top_niches_for_index and friends -
    the same functions recompute_pro_public_index calls - rather than by
    writing the JSON by hand, so the shape cannot drift from what readers
    expect.
    """
    from app.services.niche_skills import (
        get_niche_tier_map_for_index,
        get_top_niches_for_index,
        get_verified_niches_for_index,
    )

    niches = {n.slug: n for n in db.execute(select(Niche)).scalars().all()}
    applied = 0

    for name, _city, _country, niche_slug, tier, _band in PHOTOGRAPHERS:
        user_id = _sid("user", name)
        plan = [(niche_slug, tier)] + [
            (extra, _one_step_down(tier)) for extra in SECONDARY_NICHES.get(name, [])
        ]
        for plan_slug, plan_tier in plan:
            skill = db.execute(
                select(ProNicheSkill).where(
                    ProNicheSkill.pro_user_id == user_id,
                    ProNicheSkill.niche_id == niches[plan_slug].id,
                )
            ).scalar_one_or_none()
            if skill is None:
                continue
            skill.tier = plan_tier
            skill.score = {
                SkillTier.rookie: rng.randint(5, 24),
                SkillTier.skilled: rng.randint(25, 49),
                SkillTier.pro: rng.randint(50, 69),
                SkillTier.elite: rng.randint(70, 84),
                SkillTier.master: rng.randint(85, 100),
            }[plan_tier]
            skill.capability_score = skill.score
            skill.verified = plan_tier in {SkillTier.pro, SkillTier.elite, SkillTier.master}
            skill.certification_score = 100 if skill.verified else 0
            applied += 1
        db.flush()

        index = db.get(ProPublicIndex, user_id)
        if index is None:
            continue
        top = get_top_niches_for_index(db, user_id, limit=3)
        index.top_niches = top
        index.niche_tiers = get_niche_tier_map_for_index(db, user_id)
        index.verified_niches = get_verified_niches_for_index(db, user_id)
        if top:
            index.primary_niche_id = niches[top[0]["slug"]].id
            rank = {"rookie": 0, "skilled": 1, "pro": 2, "elite": 3, "master": 4}.get(str(top[0].get("tier")), 0)
            # Mirrors recompute_pro_public_index: the stored ranking_score
            # carries a tier bonus the pure scoring function does not.
            index.ranking_score = (index.ranking_score or Decimal("0")) + Decimal(str(rank * 8))

    return applied


def _report(db, stats: Counter) -> None:
    """Report what is in the database, not what this script believed it set.

    The first run reported a tier spread of 11 skilled / 9 pro / 8 rookie /
    7 elite / 5 master. All of it was false: recompute_pro_niche_skills ran
    afterwards and reset every row to rookie, and this function was counting
    an in-memory Counter that never touched the database. A seed report that
    reads its own intentions back is not a report.
    """
    from sqlalchemy import func

    seeded_ids = [_sid("user", name) for name, *_ in PHOTOGRAPHERS]

    print(f"\n{'=' * 56}")
    pro_count = db.execute(
        select(func.count()).select_from(ProProfile).where(ProProfile.user_id.in_(seeded_ids))
    ).scalar_one()
    asset_count = db.execute(
        select(func.count()).select_from(MediaAsset).where(MediaAsset.owner_user_id.in_(seeded_ids))
    ).scalar_one()
    print(f"In the database: {pro_count} photographers, {asset_count} portfolio images")

    def show(title: str, rows) -> None:
        print(f"\n{title}")
        for label, count in rows:
            print(f"  {str(label):<22} {count:>3}")

    show(
        "Per niche (primary, from the index)",
        db.execute(
            select(Niche.slug, func.count())
            .select_from(ProPublicIndex)
            .join(Niche, Niche.id == ProPublicIndex.primary_niche_id)
            .where(ProPublicIndex.pro_user_id.in_(seeded_ids))
            .group_by(Niche.slug)
            .order_by(func.count().desc())
        ).all(),
    )
    show(
        "Per tier (from pro_niche_skill, seeded niches only)",
        db.execute(
            select(ProNicheSkill.tier, func.count())
            .where(
                ProNicheSkill.pro_user_id.in_(seeded_ids),
                ProNicheSkill.score > 0,
            )
            .group_by(ProNicheSkill.tier)
            .order_by(func.count().desc())
        ).all(),
    )
    show(
        "Per city (from the index)",
        db.execute(
            select(ProPublicIndex.city, func.count())
            .where(ProPublicIndex.pro_user_id.in_(seeded_ids))
            .group_by(ProPublicIndex.city)
            .order_by(func.count().desc())
        ).all(),
    )

    bands = db.execute(
        select(ProPublicIndex.gigs_completed).where(ProPublicIndex.pro_user_id.in_(seeded_ids))
    ).scalars().all()
    show(
        "Per gig-count band (from the index)",
        [
            ("none (0)", sum(1 for g in bands if g == 0)),
            ("few (1-5)", sum(1 for g in bands if 1 <= g <= 5)),
            ("some (6-20)", sum(1 for g in bands if 6 <= g <= 20)),
            ("many (21+)", sum(1 for g in bands if g > 20)),
        ],
    )

    multi = db.execute(
        select(func.count())
        .select_from(
            select(ProNicheSkill.pro_user_id)
            .where(ProNicheSkill.pro_user_id.in_(seeded_ids), ProNicheSkill.score > 0)
            .group_by(ProNicheSkill.pro_user_id)
            .having(func.count() > 1)
            .subquery()
        )
    ).scalar_one()
    print(f"\nPhotographers working in more than one niche   {multi}")


if __name__ == "__main__":
    raise SystemExit(main())
