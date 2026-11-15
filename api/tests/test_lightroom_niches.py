"""Adding a niche from the Lightroom plug-in (plug-in 1.2.0, docs/LIGHTROOM_PORTFOLIO.md).

The owner's decision of 2026-11-15: a photographer with no niches can set
them up without leaving Lightroom. The plug-in lists every niche with its
own marked, and adds one at a time to the photographer's own profile, by
the same rules as the app (app/services/pro_niches.py): active niches only,
at most `niches_max` (default 3), the first one becomes the main niche. It
cannot remove a niche or change the main one.
"""
import uuid

import pytest
from fastapi.routing import APIRoute
from sqlalchemy import select

from app.main import app
from app.models.admin import AdminAuditLog
from app.models.discovery import ProPublicIndex
from app.models.launch_ops import OnboardingRequirement
from app.models.niche import Niche, ProNiche, ProNicheSkill
from app.services import rate_limit
from tests.test_delivery_gigs import _pro, _token
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)

V = "1.2.0"


def _h(token, version=V):
    headers = {"Authorization": f"Bearer {token}"}
    if version:
        headers["X-Rawwers-Plugin-Version"] = version
    return headers


@pytest.fixture(autouse=True)
def generous_limits(monkeypatch):
    for name in ("auth_mutation", "delivery_niche_add", "delivery_pairing_issue"):
        monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, name, (100_000, 3600))


@pytest.fixture
def slugs(db_session):
    found = [n.slug for n in db_session.execute(select(Niche).where(Niche.is_active.is_(True)).order_by(Niche.slug)).scalars()]
    assert len(found) >= 5
    return found


def _rows(db, pro):
    db.expire_all()
    rows = db.execute(select(ProNiche, Niche.slug).join(Niche, Niche.id == ProNiche.niche_id).where(ProNiche.pro_user_id == pro)).all()
    return sorted((slug, row.is_primary) for row, slug in rows)


def _add(client, token, slug, version=V):
    return client.post("/v1/delivery/portfolio/niches", headers=_h(token, version), json={"slug": slug})


def _give(db, pro, *slugs, primary=None):
    found = {n.slug: n for n in db.execute(select(Niche).where(Niche.slug.in_(slugs))).scalars()}
    for slug in slugs:
        db.add(ProNiche(pro_user_id=pro, niche_id=found[slug].id, is_primary=slug == primary))
    db.commit()


# --- listing --------------------------------------------------------------------------------------


def test_the_list_is_every_active_niche_with_the_photographers_own_marked(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[1])
    body = client.get("/v1/delivery/portfolio/niches", headers=_h(_token(client, pro))).json()
    active = db_session.execute(select(Niche).where(Niche.is_active.is_(True))).scalars().all()
    assert sorted(n["slug"] for n in body["niches"]) == sorted(n.slug for n in active)
    marked = {n["slug"]: (n["mine"], n["primary"]) for n in body["niches"]}
    assert marked[slugs[0]] == (True, False) and marked[slugs[1]] == (True, True) and marked[slugs[2]] == (False, False)
    assert (body["count"], body["maximum"]) == (2, 3)


def test_an_inactive_niche_is_not_offered_and_cannot_be_added(client, db_session, slugs):
    niche = db_session.execute(select(Niche).where(Niche.slug == slugs[4])).scalar_one()
    niche.is_active = False
    db_session.commit()
    pro = _pro(db_session)
    token = _token(client, pro)
    listed = [n["slug"] for n in client.get("/v1/delivery/portfolio/niches", headers=_h(token)).json()["niches"]]
    assert slugs[4] not in listed
    refused = _add(client, token, slugs[4])
    assert refused.status_code == 422 and refused.json()["error"]["code"] == "unknown_niche"
    assert _rows(db_session, pro) == []


# --- adding ---------------------------------------------------------------------------------------


def test_the_first_niche_added_becomes_the_main_one_and_the_next_do_not(client, db_session, slugs):
    pro = _pro(db_session)
    token = _token(client, pro)

    first = _add(client, token, slugs[2])
    assert first.status_code == 200, first.text
    assert first.json()["added"] == {"slug": slugs[2], "name": first.json()["added"]["name"], "mine": True, "primary": True}
    assert first.json()["count"] == 1
    second = _add(client, token, slugs[0])
    assert second.status_code == 200 and second.json()["added"]["primary"] is False
    assert _rows(db_session, pro) == sorted([(slugs[2], True), (slugs[0], False)])
    # and the publish service sees them, the main one first
    portfolio = client.get("/v1/delivery/portfolio", headers=_h(token)).json()
    assert [(n["slug"], n["primary"]) for n in portfolio["niches"]] == [(slugs[2], True), (slugs[0], False)]


def test_adding_has_the_apps_side_effects_and_leaves_an_audit_row(client, db_session, slugs):
    pro = _pro(db_session)
    token = _token(client, pro)
    assert _add(client, token, slugs[1]).status_code == 200
    db_session.expire_all()
    niche = db_session.execute(select(Niche).where(Niche.slug == slugs[1])).scalar_one()
    assert db_session.execute(select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro, ProNicheSkill.niche_id == niche.id)).scalar_one_or_none()
    assert db_session.get(ProPublicIndex, pro) is not None
    audit = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_type == "pro_niche", AdminAuditLog.actor_user_id == pro)).scalars().all()
    assert [(a.action, a.target_id, a.meta["source"], a.meta["primary"]) for a in audit] == [("niche_added", f"{pro}:{slugs[1]}", "lightroom", True)]
    assert audit[0].meta["device_id"]


def test_a_niche_already_theirs_is_refused_and_nothing_changes(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], primary=slugs[0])
    refused = _add(client, _token(client, pro), slugs[0])
    assert refused.status_code == 409 and "already one of your niches" in refused.json()["error"]["message"]
    assert _rows(db_session, pro) == [(slugs[0], True)]


def test_an_unknown_niche_is_refused(client, db_session):
    pro = _pro(db_session)
    refused = _add(client, _token(client, pro), "underwater-weddings")
    assert refused.status_code == 422 and refused.json()["error"]["message"] == 'There is no niche called "underwater-weddings".'
    assert _rows(db_session, pro) == []


def test_the_maximum_is_three_and_says_so(client, db_session, slugs):
    pro = _pro(db_session)
    token = _token(client, pro)
    for slug in slugs[:3]:
        assert _add(client, token, slug).status_code == 200
    refused = _add(client, token, slugs[3])
    assert refused.status_code == 422, refused.text
    error = refused.json()["error"]
    assert error["code"] == "niche_limit_reached"
    assert error["message"].startswith("You can have at most 3 niches, and you have 3.")
    assert len(_rows(db_session, pro)) == 3


def test_the_maximum_is_the_admin_setting(client, db_session, slugs):
    row = db_session.execute(select(OnboardingRequirement).where(OnboardingRequirement.key == "niches_max")).scalar_one_or_none()
    if row is None:
        db_session.add(OnboardingRequirement(key="niches_max", value={"count": 1}))
    else:
        row.value = {"count": 1}
    db_session.commit()
    pro = _pro(db_session)
    token = _token(client, pro)
    assert _add(client, token, slugs[0]).status_code == 200
    assert _add(client, token, slugs[1]).json()["error"]["code"] == "niche_limit_reached"
    assert client.get("/v1/delivery/portfolio/niches", headers=_h(token)).json()["maximum"] == 1


def test_only_the_tokens_own_photographer_gets_the_niche(client, db_session, slugs):
    alex, other = _pro(db_session), _pro(db_session)
    token = _token(client, alex)
    # A body naming someone else is not read.
    answer = client.post("/v1/delivery/portfolio/niches", headers=_h(token), json={"slug": slugs[0], "pro_user_id": str(other), "user_id": str(other)})
    assert answer.status_code == 200
    assert _rows(db_session, alex) == [(slugs[0], True)]
    assert _rows(db_session, other) == []
    # and the other photographer's list is not theirs
    mine = client.get("/v1/delivery/portfolio/niches", headers=_h(_token(client, other))).json()
    assert mine["count"] == 0 and not any(n["mine"] for n in mine["niches"])


def test_adding_is_limited_per_device(client, db_session, slugs, monkeypatch):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_niche_add", (1, 3600))
    pro = _pro(db_session)
    token = _token(client, pro)
    assert _add(client, token, slugs[0]).status_code == 200
    assert _add(client, token, slugs[1]).status_code == 429
    assert len(_rows(db_session, pro)) == 1


# --- what the plug-in cannot do -------------------------------------------------------------------


@pytest.mark.parametrize("version", ["1.1.0", "1.0.0", None])
def test_the_niche_routes_need_plugin_1_2_0(client, db_session, slugs, version):
    pro = _pro(db_session)
    token = _token(client, pro)
    for answer in (client.get("/v1/delivery/portfolio/niches", headers=_h(token, version)), _add(client, token, slugs[0], version)):
        assert answer.status_code == 426, answer.text
        assert answer.json()["error"]["details"]["minimum_version"] == "1.2.0"
    assert _rows(db_session, pro) == []
    # 1.1.0 keeps publishing
    if version == "1.1.0":
        assert client.get("/v1/delivery/portfolio", headers=_h(token, "1.1.0")).status_code == 200


def test_the_plugin_can_only_list_and_add_never_remove_or_change_the_main_niche(client, db_session, slugs):
    niche_routes = sorted(
        (method, route.path)
        for route in app.routes
        if isinstance(route, APIRoute) and route.path.startswith("/v1/delivery") and "niche" in route.path
        for method in route.methods - {"HEAD", "OPTIONS"}
    )
    assert niche_routes == [("GET", "/v1/delivery/portfolio/niches"), ("POST", "/v1/delivery/portfolio/niches")]

    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    token = _token(client, pro)
    for method, url, body in (
        ("DELETE", f"/v1/delivery/portfolio/niches/{slugs[1]}", None),
        ("DELETE", "/v1/delivery/portfolio/niches", {"slug": slugs[1]}),
        ("PUT", "/v1/delivery/portfolio/niches", {"slug": slugs[1], "primary": True}),
        ("PATCH", "/v1/delivery/portfolio/niches", {"slug": slugs[1], "primary": True}),
    ):
        answer = client.request(method, url, headers=_h(token), json=body)
        # DELETE /portfolio/niches is the photo-removal route with "niches"
        # as a photo id: refused as not an id (422), removing nothing.
        assert answer.status_code in (404, 405, 422), (method, url, answer.status_code)
    # adding cannot move the main niche either
    assert _add(client, token, slugs[2]).json()["added"]["primary"] is False
    assert _rows(db_session, pro) == sorted([(slugs[0], True), (slugs[1], False), (slugs[2], False)])


def test_the_token_cannot_change_niches_through_the_apps_route(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], primary=slugs[0])
    token = _token(client, pro)
    for method, path in (("PUT", "/v1/pro/me/niches"), ("PUT", "/v1/pro/niches/mine")):
        answer = client.request(method, path, headers=_h(token), json={"primary_niche_slug": slugs[1], "niches": []})
        assert answer.status_code == 401, (path, answer.status_code)
    assert _rows(db_session, pro) == [(slugs[0], True)]


# --- the app follows the same maximum --------------------------------------------------------------


def _put(client, pro, slugs, primary=None):
    return client.put(
        "/v1/pro/me/niches",
        headers={"X-User-Id": str(pro)},
        json={"primary_niche_slug": primary, "niches": [{"slug": s, "is_primary": s == primary} for s in slugs]},
    )


def test_the_apps_niche_list_has_the_same_maximum(client, db_session, slugs):
    pro = _pro(db_session)
    assert _put(client, pro, slugs[:3], primary=slugs[0]).status_code == 200
    refused = _put(client, pro, slugs[:4], primary=slugs[0])
    assert refused.status_code == 422 and refused.json()["error"]["code"] == "niche_limit_reached"
    # a main niche outside the list counts too
    assert _put(client, pro, slugs[:3], primary=slugs[3]).json()["error"]["code"] == "niche_limit_reached"
    assert len(_rows(db_session, pro)) == 3


def test_a_photographer_above_the_maximum_from_before_can_keep_or_shrink_but_not_grow(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, *slugs[:4], primary=slugs[0])
    assert _put(client, pro, slugs[:4], primary=slugs[0]).status_code == 200
    assert _put(client, pro, slugs[:5], primary=slugs[0]).status_code == 422
    assert _put(client, pro, slugs[:2], primary=slugs[0]).status_code == 200
    assert len(_rows(db_session, pro)) == 2
    # and the plug-in, at the maximum, adds nothing
    _give(db_session, pro, slugs[2])
    assert _add(client, _token(client, pro), slugs[3]).json()["error"]["code"] == "niche_limit_reached"
