"""Per-tier, per-niche entry-price caps.

The enforcement code was built earlier and the table was empty, so
`enforce_entry_price_cap` returned on its first line every single time. Every
line after that early return had never executed - in production or in any test
that did not seed a cap. This project has a record of built-but-never-exercised
paths turning out to be wrong once real data arrives (the KYC gate, the
watermark that never marked, the webhook that could never disable), so these
treat the comparison logic as unproven rather than merely unused.
"""
import uuid
from decimal import Decimal

import pytest
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.package_pricing import NichePackagePriceCap
from app.services.niche_catalog import ensure_initial_niches
from sqlalchemy import select


def _pro(db_session) -> uuid.UUID:
    user_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=user_id))
    db_session.flush()
    db_session.add(UserRole(user_id=user_id, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=user_id, display_name="Cap Test"))
    db_session.commit()
    return user_id


def _niche(db_session, slug: str = "weddings") -> Niche:
    ensure_initial_niches(db_session)
    return db_session.execute(select(Niche).where(Niche.slug == slug)).scalar_one()


def _cap(db_session, niche: Niche, tier: SkillTier, maximum: Decimal | None):
    existing = db_session.execute(
        select(NichePackagePriceCap).where(
            NichePackagePriceCap.niche_id == niche.id, NichePackagePriceCap.tier == tier
        )
    ).scalar_one_or_none()
    if existing is None:
        existing = NichePackagePriceCap(niche_id=niche.id, tier=tier, currency="EUR")
        db_session.add(existing)
    existing.entry_price_min = Decimal("0.00")
    existing.entry_price_max = maximum
    db_session.commit()


def _skill(db_session, pro_user_id, niche: Niche, tier: SkillTier):
    db_session.add(ProNicheSkill(pro_user_id=pro_user_id, niche_id=niche.id, tier=tier, score=50))
    db_session.commit()


def _create_package(client, pro_user_id, niche_slug: str, price: str):
    return client.post(
        "/v1/pro/me/packages",
        headers={"X-User-Id": str(pro_user_id)},
        json={
            "niche_slug": niche_slug,
            "title": "Session",
            "duration_minutes": 60,
            "price": price,
            "currency": "EUR",
            "included_photos": 20,
            "extra_photo_price": "12.00",
            "proofs_sla_days": 3,
            "finals_sla_days": 10,
            "addons": [],
        },
    )


# ---------------------------------------------------------------------------
# The cap actually stops something.
# ---------------------------------------------------------------------------


def test_a_rate_over_the_cap_is_rejected_and_the_limit_is_named(client, db_session):
    """"Invalid" is not an error message. A photographer who is told the
    number cannot set a valid one without guessing."""
    niche = _niche(db_session)
    pro = _pro(db_session)
    _skill(db_session, pro, niche, SkillTier.rookie)
    _cap(db_session, niche, SkillTier.rookie, Decimal("4.00"))

    resp = _create_package(client, pro, "weddings", "118.00")
    assert resp.status_code == 422, resp.text
    assert "4.00" in resp.json()["error"]["message"], "the error does not name the actual limit"


def test_a_rate_exactly_at_the_cap_is_allowed(client, db_session):
    """The boundary is inclusive. An exclusive one would make the advertised
    ceiling a number nobody may actually charge."""
    niche = _niche(db_session)
    pro = _pro(db_session)
    _skill(db_session, pro, niche, SkillTier.rookie)
    _cap(db_session, niche, SkillTier.rookie, Decimal("4.00"))

    assert _create_package(client, pro, "weddings", "4.00").status_code == 200


def test_the_cap_follows_the_tier_the_photographer_holds_in_that_niche(client, db_session):
    """Tier is per-niche. A master in weddings who is a rookie in product must
    be capped as a rookie when pricing product work."""
    weddings = _niche(db_session, "weddings")
    product = _niche(db_session, "product")
    pro = _pro(db_session)
    _skill(db_session, pro, weddings, SkillTier.master)
    _cap(db_session, weddings, SkillTier.master, None)
    _cap(db_session, product, SkillTier.rookie, Decimal("15.00"))

    # No skill row for product at all, which resolves to rookie.
    assert _create_package(client, pro, "weddings", "200.00").status_code == 200
    over = _create_package(client, pro, "product", "200.00")
    assert over.status_code == 422
    assert "15.00" in over.json()["error"]["message"]


@pytest.mark.parametrize("slug", ["weddings", "portraits", "food", "product"])
def test_master_has_no_ceiling_in_any_niche(client, db_session, slug):
    niche = _niche(db_session, slug)
    pro = _pro(db_session)
    _skill(db_session, pro, niche, SkillTier.master)
    _cap(db_session, niche, SkillTier.master, None)

    assert _create_package(client, pro, slug, "9999.00").status_code == 200


def test_a_brand_new_photographer_is_capped_as_a_rookie(client, db_session):
    """No ProNicheSkill row exists before anyone has worked in a niche.
    Resolving that to rookie is the safe direction - the strictest cap - and
    resolving it to anything else would let a new account price as a master."""
    niche = _niche(db_session)
    pro = _pro(db_session)
    _cap(db_session, niche, SkillTier.rookie, Decimal("4.00"))

    resp = _create_package(client, pro, "weddings", "50.00")
    assert resp.status_code == 422
    assert "4.00" in resp.json()["error"]["message"]


def test_an_unconfigured_niche_and_tier_is_unrestricted(client, db_session):
    """The state the whole table was in until now: no row means no ceiling.
    Worth pinning, because it is why the cap silently enforced nothing - the
    behaviour is deliberate, but it must be visible rather than assumed."""
    niche = _niche(db_session, "sports")
    pro = _pro(db_session)
    _skill(db_session, pro, niche, SkillTier.rookie)

    assert _create_package(client, pro, "sports", "500.00").status_code == 200


def test_updating_a_package_is_capped_too(client, db_session):
    """Two call sites enforce this - create and update. A cap on creation
    alone would be bypassed by creating low and editing up."""
    niche = _niche(db_session)
    pro = _pro(db_session)
    _skill(db_session, pro, niche, SkillTier.rookie)
    _cap(db_session, niche, SkillTier.rookie, Decimal("4.00"))

    created = _create_package(client, pro, "weddings", "4.00")
    assert created.status_code == 200
    package_id = created.json()["id"]

    resp = client.put(
        f"/v1/pro/me/packages/{package_id}",
        headers={"X-User-Id": str(pro)},
        json={
            "niche_slug": "weddings",
            "title": "Session",
            "duration_minutes": 60,
            "price": "118.00",
            "currency": "EUR",
            "included_photos": 20,
            "extra_photo_price": "12.00",
            "proofs_sla_days": 3,
            "finals_sla_days": 10,
            "addons": [],
        },
    )
    assert resp.status_code == 422, "a package could be created at the cap and then edited above it"
    assert "4.00" in resp.json()["error"]["message"]


# ---------------------------------------------------------------------------
# The seeded table itself.
# ---------------------------------------------------------------------------


def test_the_seeded_caps_cover_every_tier_of_every_seeded_niche(db_session):
    """40 cells: 8 niches x 5 tiers. A missing cell is not a smaller cap, it
    is no cap at all, which is exactly how this mechanism was inert."""
    import sys
    from pathlib import Path

    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
    from seed_price_caps import CAPS

    assert len(CAPS) == 8
    for slug, by_tier in CAPS.items():
        assert set(by_tier) == set(SkillTier), f"{slug} is missing a tier"
        assert by_tier[SkillTier.master] is None, f"{slug} caps master"

        capped = [(tier, value) for tier, value in by_tier.items() if value is not None]
        ordered = sorted(capped, key=lambda item: list(SkillTier).index(item[0]))
        values = [value for _tier, value in ordered]
        assert values == sorted(values), f"{slug} caps do not rise with tier: {values}"


# ---------------------------------------------------------------------------
# The seed data obeys the caps it is seeded alongside.
# ---------------------------------------------------------------------------


def test_the_demo_seed_prices_a_package_under_the_cap(db_session):
    """The base seed hard-coded 120.00 and 160.00 as package prices - day-rate
    numbers, from before `ProPackage.price` was understood as the per-photo
    entry rate. Once the caps were populated those two demo accounts sat 20x
    over a rookie ceiling and could not rename their own package. A correct
    422, indistinguishable from a broken screen.
    """
    import sys
    from pathlib import Path

    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
    from _seed_common import _capped_entry_rate

    niche = _niche(db_session, "portraits")
    pro = _pro(db_session)
    _cap(db_session, niche, SkillTier.rookie, Decimal("6.00"))

    rate = _capped_entry_rate(
        db_session, niche=niche, pro_user_id=pro, fallback=Decimal("120.00")
    )
    assert rate <= Decimal("6.00"), f"the seed would price a demo pro at {rate} against a 6.00 cap"
    assert rate > Decimal("0"), "a free package is not a demo, it is a different bug"


def test_the_demo_seed_follows_the_tier_the_pro_actually_holds(db_session):
    """Reading the cap for the wrong tier would pass this suite and still
    produce an over-cap package, because the enforcement resolves the tier
    itself. The seed has to agree with it."""
    import sys
    from pathlib import Path

    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
    from _seed_common import _capped_entry_rate

    niche = _niche(db_session, "portraits")
    pro = _pro(db_session)
    _skill(db_session, pro, niche, SkillTier.elite)
    _cap(db_session, niche, SkillTier.rookie, Decimal("6.00"))
    _cap(db_session, niche, SkillTier.elite, Decimal("28.00"))

    rate = _capped_entry_rate(
        db_session, niche=niche, pro_user_id=pro, fallback=Decimal("120.00")
    )
    assert Decimal("6.00") < rate <= Decimal("28.00"), (
        f"an elite was priced at {rate}, which reads the wrong tier's cap"
    )


def test_an_uncapped_niche_falls_back_rather_than_pricing_at_zero(db_session):
    """No cap row is the pre-cap state and still has to produce a usable
    package. Returning 0.00 or None here would seed a free shoot."""
    import sys
    from pathlib import Path

    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
    from _seed_common import _capped_entry_rate

    niche = _niche(db_session, "sports")
    pro = _pro(db_session)

    rate = _capped_entry_rate(
        db_session, niche=niche, pro_user_id=pro, fallback=Decimal("9.00")
    )
    assert rate == Decimal("9.00")
