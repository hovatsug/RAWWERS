"""The price caps files (api/data/price_caps, docs/PRICE_CAPS.md) and their import.

One file per currency, in the format the web admin's caps grid imports;
production is loaded from them through the admin, dev from the seed script.
The pound caps are a proposal (the euro caps at the ECB rate of 2026-11-13,
0.83559, rounded to 50p under £10 and to the pound above):

  weddings rookie: €4.00 x 0.83559 = £3.34, proposed £3.50.

What a pound photographer may then charge is checked against the pound cap
only: £3.50 and £3.00 are accepted for a weddings rookie, £3.51 is refused,
and a euro photographer is still held to €4.00.
"""
from __future__ import annotations

import sys
import uuid
from decimal import Decimal
from pathlib import Path

import pytest
from sqlalchemy import func, select

from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.niche import SkillTier
from app.models.package_pricing import NichePackagePriceCap

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import seed_price_caps as caps_seed  # noqa: E402

D = Decimal
TIERS = list(SkillTier)


# --- the files ----------------------------------------------------------------------------------


def test_both_files_cap_the_same_niches_and_tiers_and_never_master():
    eur, gbp = caps_seed.CAPS_BY_CURRENCY["EUR"], caps_seed.CAPS_BY_CURRENCY["GBP"]
    assert set(eur) == set(gbp) and len(eur) == 8
    for slug in eur:
        for tier in TIERS:
            # a cell missing in one currency refuses that currency's packages
            assert (eur[slug][tier] is None) == (gbp[slug][tier] is None), f"{slug} {tier.value}"
        assert eur[slug][SkillTier.master] is None and gbp[slug][SkillTier.master] is None


@pytest.mark.parametrize("currency", ["EUR", "GBP"])
def test_every_niches_caps_rise_with_tier(currency):
    for slug, by_tier in caps_seed.CAPS_BY_CURRENCY[currency].items():
        values = [by_tier[t] for t in TIERS if by_tier[t] is not None]
        assert values == sorted(set(values)), f"{currency} {slug}: {values}"


def test_a_pound_cap_is_within_reach_of_its_euro_cap():
    """A pound is worth more than a euro, so a pound cap is a little lower;
    anything outside 70%-100% of the euro cap is a typo (4.00 for 40.00)."""
    eur, gbp = caps_seed.CAPS_BY_CURRENCY["EUR"], caps_seed.CAPS_BY_CURRENCY["GBP"]
    for slug in eur:
        for tier in TIERS:
            if eur[slug][tier] is not None:
                assert D("0.70") <= gbp[slug][tier] / eur[slug][tier] <= D("1.00"), f"{slug} {tier.value}"


def test_the_proposed_weddings_rookie_cap():
    assert caps_seed.CAPS_BY_CURRENCY["GBP"]["weddings"][SkillTier.rookie] == D("3.50")
    assert caps_seed.CAPS["weddings"][SkillTier.rookie] == D("4.00")


HEADER = "niche_slug,tier,entry_price_max,currency\n"
FULL = "".join(f"weddings,{t.value},{'' if t == SkillTier.master else '3.00'},GBP\n" for t in TIERS)


@pytest.mark.parametrize(
    ("text", "error"),
    [
        ("niche_slug,tier,entry_price_max\nweddings,rookie,3.00\n", "the first line"),
        (HEADER + FULL.replace("weddings,pro,3.00,GBP", "weddings,pro,3.00,EUR"), "one currency"),
        (HEADER + FULL + "weddings,rookie,3.00,GBP\n", "listed twice"),
        (HEADER + FULL.replace("weddings,elite,3.00,GBP\n", ""), "no row for elite"),
        (HEADER + FULL.replace("weddings,pro,3.00", "weddings,pro,3,50"), "columns"),
        (HEADER + FULL.replace("weddings,pro,3.00", "weddings,pro,-3.00"), "not a price"),
        (HEADER + FULL.replace("weddings,pro,3.00", "weddings,legend,3.00"), "not a tier"),
    ],
)
def test_a_bad_file_is_refused_whole(text, error):
    with pytest.raises(ValueError, match=error):
        caps_seed.read_caps_csv(text)


def test_a_good_file_reads_with_empty_as_uncapped():
    currency, caps = caps_seed.read_caps_csv("﻿" + HEADER + FULL)
    assert currency == "GBP"
    assert caps["weddings"][SkillTier.rookie] == D("3.00")
    assert caps["weddings"][SkillTier.master] is None


# --- the import -----------------------------------------------------------------------------------


def _rows(db, currency=None):
    db.expire_all()
    q = select(func.count()).select_from(NichePackagePriceCap)
    if currency:
        q = q.where(NichePackagePriceCap.currency == currency)
    return db.execute(q).scalar_one()


def test_the_import_fills_both_currencies_once(db_session):
    assert caps_seed.apply_caps(db_session, dry_run=True) == (80, 0, 0)
    assert _rows(db_session) == 0

    assert caps_seed.apply_caps(db_session) == (80, 0, 0)
    db_session.commit()
    assert (_rows(db_session, "EUR"), _rows(db_session, "GBP")) == (40, 40)

    assert caps_seed.apply_caps(db_session) == (0, 0, 80)


def test_the_import_of_one_currency_leaves_the_other_alone(db_session):
    caps_seed.apply_caps(db_session, currencies=("GBP",))
    db_session.commit()
    assert (_rows(db_session, "EUR"), _rows(db_session, "GBP")) == (0, 40)


# --- what a pound photographer may then charge ------------------------------------------------------


def _photographer(db, currency: str) -> uuid.UUID:
    uid = uuid.uuid4()
    db.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db.flush()
    db.add(UserRole(user_id=uid, role=UserRoleType.pro))
    db.add(ProProfile(user_id=uid, display_name="Cap", country="GB" if currency == "GBP" else "PT", currency=currency))
    db.commit()
    return uid


def _package(client, pro, price: str, currency: str):
    return client.post(
        "/v1/pro/me/packages",
        headers={"X-User-Id": str(pro)},
        json={
            "niche_slug": "weddings",
            "title": "Session",
            "duration_minutes": 60,
            "price": price,
            "currency": currency,
            "included_photos": 20,
            "extra_photo_price": "3.00",
            "proofs_sla_days": 3,
            "finals_sla_days": 10,
            "addons": [],
        },
    )


def test_a_pound_package_is_held_to_the_imported_pound_cap(client, db_session):
    caps_seed.apply_caps(db_session)
    db_session.commit()
    pro = _photographer(db_session, "GBP")

    over = _package(client, pro, "3.51", "GBP")
    assert over.status_code == 422, over.text
    assert "at most 3.50" in over.json()["error"]["message"]

    for price in ("3.50", "3.00"):
        ok = _package(client, pro, price, "GBP")
        assert ok.status_code in (200, 201), ok.text


def test_a_euro_package_is_still_held_to_the_euro_cap(client, db_session):
    caps_seed.apply_caps(db_session)
    db_session.commit()
    pro = _photographer(db_session, "EUR")

    # over the pound cap, under the euro one: only the euro one applies
    assert _package(client, pro, "3.90", "EUR").status_code in (200, 201)
    assert _package(client, pro, "4.01", "EUR").status_code == 422
