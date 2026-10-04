"""Price caps on an empty table - the state a new production database is in.

The admin grid used to list only niches that already had a cap row, so with
none it listed nothing and nothing could be entered: the same cold start the
camera reference table had. The page now shows every niche; these cover the
endpoint it saves through - that it fills an empty table, that what it
writes is then actually enforced, and that a bad save (now likely to be a
whole file at once) writes nothing at all.
"""
from decimal import Decimal

from app.models.admin import AdminAuditLog
from app.models.niche import SkillTier
from app.models.package_pricing import NichePackagePriceCap
from sqlalchemy import func, select

from tests.test_package_pricing import ADMIN_USER_ID, _ensure_account
from tests.test_price_caps import _create_package, _niche, _pro, _skill

URL = "/v1/admin/pricing/niche-package-price-caps"


def _put(client, items):
    return client.put(URL, headers={"X-User-Id": ADMIN_USER_ID}, json={"items": items})


def _item(niche="weddings", tier="rookie", maximum="4.00", minimum="0.00"):
    return {"niche_slug": niche, "tier": tier, "entry_price_min": minimum, "entry_price_max": maximum, "currency": "EUR"}


def _rows(db_session) -> int:
    db_session.expire_all()
    return db_session.execute(select(func.count()).select_from(NichePackagePriceCap)).scalar_one()


def test_an_empty_table_is_filled_from_the_admin_and_then_enforced(client, db_session):
    _ensure_account(db_session, ADMIN_USER_ID)
    assert _rows(db_session) == 0
    niche = _niche(db_session)
    pro = _pro(db_session)
    _skill(db_session, pro, niche, SkillTier.rookie)
    # Unconfigured means unlimited: the cold start is invisible until it is fixed.
    assert _create_package(client, pro, "weddings", "118.00").status_code == 200

    saved = _put(client, [_item(maximum="4.00"), _item(niche="food", tier="pro", maximum=None)])

    assert saved.status_code == 200, saved.text
    assert _rows(db_session) == 2
    refused = _create_package(client, pro, "weddings", "118.00")
    assert refused.status_code == 422, refused.text
    assert "4.00" in refused.json()["error"]["message"]


def test_a_save_with_one_bad_cap_writes_none_of_them(client, db_session):
    _ensure_account(db_session, ADMIN_USER_ID)

    for bad, said in [
        (_item(niche="weddings", tier="pro", maximum="-1.00"), "negative"),
        (_item(niche="weddings", tier="pro", maximum="2.00", minimum="3.00"), "below the minimum"),
        (_item(niche="weddings", tier="rookie", maximum="5.00"), "appears twice"),
        (_item(niche="underwater-basket-weaving", tier="pro"), "Unknown niche"),
    ]:
        resp = _put(client, [_item(maximum="4.00"), bad])
        assert resp.status_code == 422, (said, resp.text)
        assert said in resp.json()["error"]["message"]

    assert _rows(db_session) == 0, "a refused save must not write the good rows before the bad one"
    db_session.expire_all()
    assert db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_type == "niche_package_price_cap")).first() is None


def test_the_refusal_names_the_niche_and_tier(client, db_session):
    _ensure_account(db_session, ADMIN_USER_ID)
    resp = _put(client, [_item(niche="food", tier="elite", maximum="2.00", minimum="3.00")])
    assert resp.json()["error"]["message"] == "food · elite: the cap (2.00) is below the minimum (3.00)"


def test_uncapped_is_saved_as_a_real_setting(client, db_session):
    _ensure_account(db_session, ADMIN_USER_ID)
    assert _put(client, [_item(tier="master", maximum=None)]).status_code == 200

    db_session.expire_all()
    [row] = db_session.execute(select(NichePackagePriceCap)).scalars().all()
    assert row.tier == SkillTier.master and row.entry_price_max is None
    assert row.entry_price_min == Decimal("0.00")
