"""The photographer's cover (BETA_SCOPE #74, owner addition 2026-11-18).

One rule on the server (services/profile_cover.py), read by the Discover
card, the listing preview built from it, the client profile and the Pro
app's portfolio: the cover they chose while it is their own ready portfolio
photo, otherwise their earliest ready photo of their main niche, otherwise
their earliest ready photo. "Set as cover" (PUT /v1/pro/me/portfolio/{id}/
cover) takes only their own ready photo, refreshes Discover at once, is
harmless twice, rate limited and audited.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from sqlalchemy import select

from app.models.admin import AdminAuditLog, ProProfile
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaPurpose, MediaStatus, MediaVariant, MediaVisibility, ObjectStatus
from app.models.niche import Niche, ProNiche
from app.services import rate_limit
from app.services.lightroom_portfolio import LIGHTROOM_NICHE_KEY
from app.models.admin import UserRoleType
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from tests.test_client_launch import _enable_city_and_flags, _seed_pro, _seed_user
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)

T0 = datetime(2026, 11, 1, 9, 0, tzinfo=timezone.utc)


@pytest.fixture(autouse=True)
def generous_limits(monkeypatch):
    for name in ("uploads", "auth_mutation", "portfolio_removal", "cover_change", "public_read"):
        monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, name, (100_000, 3600))


@pytest.fixture(autouse=True)
def no_storage_deletes(monkeypatch):
    monkeypatch.setattr("app.services.storage.delete_object", lambda _key: None)


def _city() -> str:
    # A city of its own per test: Discover answers are cached by city.
    return f"Covertown {uuid.uuid4().hex[:8]}"


def _pro(db, *, city=None) -> uuid.UUID:
    pro = uuid.uuid4()
    _seed_pro(db, str(pro), city=city or _city(), country="PT")
    return pro


def _main(db, pro, slug):
    niche = db.execute(select(Niche).where(Niche.slug == slug)).scalar_one()
    db.add(ProNiche(pro_user_id=pro, niche_id=niche.id, is_primary=True))
    db.commit()


def _photo(db, pro, *, minutes=0, tags=(), status=MediaStatus.ready, objects_ready=True, kind=MediaKind.photo, meta=None) -> uuid.UUID:
    asset = MediaAsset(owner_user_id=pro, kind=kind, purpose=MediaPurpose.portfolio_reel, provider="r2", status=status,
                       visibility=MediaVisibility.public, content_type="image/jpeg", niche_tags=list(tags), meta=meta or {},
                       created_at=T0 + timedelta(minutes=minutes))
    db.add(asset)
    db.flush()
    state = ObjectStatus.ready if objects_ready else ObjectStatus.processing
    db.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.original, storage_key=f"p/{asset.id}/o.jpg", status=state))
    db.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.thumbnail, storage_key=f"p/{asset.id}/t.jpg", status=state))
    db.commit()
    return asset.id


def _h(user):
    return {"X-User-Id": str(user)}


def _set(client, pro, asset_id):
    return client.put(f"/v1/pro/me/portfolio/{asset_id}/cover", headers=_h(pro))


def _chosen(db, pro):
    db.expire_all()
    return db.get(ProProfile, pro).cover_media_asset_id


def _preview(client, pro):
    answer = client.get("/v1/pro/me/listing-preview", headers=_h(pro))
    assert answer.status_code == 200, answer.text
    return answer.json()


def _client_profile_cover(client, db, pro, city):
    viewer = str(uuid.uuid4())
    _seed_user(db, viewer, [UserRoleType.client])
    answer = client.get(f"/v1/client/pros/{pro}", params={"country": "PT", "city": city}, headers={"X-User-Id": viewer})
    assert answer.status_code == 200, answer.text
    return answer.json()["cover_media_asset_id"]


def _discover_cover(client, pro, city):
    answer = client.get("/v1/client/discover", params={"country": "PT", "city": city, "niche_slug": "portraits"})
    assert answer.status_code == 200, answer.text
    card = next(c for c in answer.json()["items"] if c["pro_user_id"] == str(pro))
    return card["cover_media_asset_id"], card["cover_url"]


# --- choosing ---------------------------------------------------------------------------------------


def test_a_photographer_sets_their_own_ready_photo_as_cover(client, db_session):
    pro = _pro(db_session)
    first = _photo(db_session, pro, minutes=0)
    mine = _photo(db_session, pro, minutes=5)
    answer = _set(client, pro, mine)
    assert answer.status_code == 200, answer.text
    assert answer.json() == {"cover_media_asset_id": str(mine), "changed": True}
    assert _chosen(db_session, pro) == mine
    listed = client.get("/v1/pro/me/portfolio", headers=_h(pro)).json()
    assert {i["media_asset_id"]: i["is_cover"] for i in listed["items"]} == {str(mine): True, str(first): False}
    assert listed["cover_media_asset_id"] == str(mine) and listed["cover_chosen"] is True
    preview = _preview(client, pro)
    assert preview["card"]["cover_media_asset_id"] == str(mine) and preview["card"]["cover_url"]
    assert preview["cover_chosen"] is True


def test_setting_it_is_audited(client, db_session):
    pro = _pro(db_session)
    photo = _photo(db_session, pro)
    assert _set(client, pro, photo).status_code == 200
    audit = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_id == str(photo))).scalars().all()
    assert [(a.action, a.actor_user_id, a.meta["source"]) for a in audit] == [("cover_set", pro, "app")]


def test_setting_the_same_cover_twice_is_harmless(client, db_session):
    pro = _pro(db_session)
    photo = _photo(db_session, pro)
    assert _set(client, pro, photo).json()["changed"] is True
    again = _set(client, pro, photo)
    assert again.status_code == 200
    assert again.json() == {"cover_media_asset_id": str(photo), "changed": False}
    audit = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_id == str(photo))).scalars().all()
    assert len(audit) == 1, "a second, unchanged set wrote another audit record"


def test_another_photographers_photo_is_refused(client, db_session):
    pro = _pro(db_session)
    _photo(db_session, pro)
    other = _pro(db_session)
    theirs = _photo(db_session, other)
    answer = _set(client, pro, theirs)
    assert answer.status_code == 404
    assert _chosen(db_session, pro) is None
    assert _chosen(db_session, other) is None


def test_another_photographers_photo_is_refused_through_the_profile_too(client, db_session):
    pro = _pro(db_session)
    other = _pro(db_session)
    theirs = _photo(db_session, other)
    answer = client.put("/v1/pro/me/profile", headers=_h(pro), json={"cover_media_asset_id": str(theirs)})
    assert answer.status_code == 404
    assert _chosen(db_session, pro) is None


def test_the_profile_save_sends_the_current_cover_back_unchanged(client, db_session):
    pro = _pro(db_session)
    photo = _photo(db_session, pro)
    assert _set(client, pro, photo).status_code == 200
    answer = client.put("/v1/pro/me/profile", headers=_h(pro), json={"cover_media_asset_id": str(photo), "headline": "New headline"})
    assert answer.status_code == 200, answer.text
    assert _chosen(db_session, pro) == photo
    audit = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_id == str(photo))).scalars().all()
    assert len(audit) == 1


def test_a_photo_still_processing_is_refused_with_a_reason(client, db_session):
    pro = _pro(db_session)
    waiting = _photo(db_session, pro, status=MediaStatus.processing, objects_ready=False)
    answer = _set(client, pro, waiting)
    assert answer.status_code == 409
    assert answer.json()["error"]["code"] == "cover_not_ready"
    assert "still being prepared" in answer.json()["error"]["message"]
    assert _chosen(db_session, pro) is None


def test_a_video_is_refused(client, db_session):
    pro = _pro(db_session)
    video = _photo(db_session, pro, kind=MediaKind.video)
    answer = _set(client, pro, video)
    assert answer.status_code == 422
    assert _chosen(db_session, pro) is None


def test_a_removed_photo_is_refused(client, db_session):
    pro = _pro(db_session)
    gone = _photo(db_session, pro, status=MediaStatus.deleted)
    assert _set(client, pro, gone).status_code == 404


def test_a_photo_published_from_lightroom_can_be_the_cover(client, db_session):
    pro = _pro(db_session)
    from_lr = _photo(db_session, pro, tags=("portraits",), meta={LIGHTROOM_NICHE_KEY: "portraits"})
    assert _set(client, pro, from_lr).status_code == 200
    assert _chosen(db_session, pro) == from_lr


def test_a_client_cannot_call_it(client, db_session):
    pro = _pro(db_session)
    photo = _photo(db_session, pro)
    stranger = uuid.uuid4()
    assert client.put(f"/v1/pro/me/portfolio/{photo}/cover", headers=_h(stranger)).status_code in (401, 403, 404)
    assert _chosen(db_session, pro) is None


def test_changes_are_rate_limited(client, db_session, monkeypatch):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "cover_change", (2, 3600))
    pro = _pro(db_session)
    a, b, c = (_photo(db_session, pro, minutes=m) for m in range(3))
    assert _set(client, pro, a).status_code == 200
    assert _set(client, pro, b).status_code == 200
    assert _set(client, pro, c).status_code == 429
    assert _chosen(db_session, pro) == b


# --- the automatic cover ----------------------------------------------------------------------------


def test_with_no_chosen_cover_the_earliest_photo_of_the_main_niche_is_used(client, db_session):
    pro = _pro(db_session)
    _main(db_session, pro, "portraits")
    _photo(db_session, pro, minutes=0, tags=("weddings",))
    main_first = _photo(db_session, pro, minutes=5, tags=("portraits",))
    _photo(db_session, pro, minutes=10, tags=("portraits",))
    preview = _preview(client, pro)
    assert preview["card"]["cover_media_asset_id"] == str(main_first)
    assert preview["card"]["cover_url"], "an empty card while ready photos exist"
    assert preview["cover_chosen"] is False
    listed = client.get("/v1/pro/me/portfolio", headers=_h(pro)).json()
    assert [i["media_asset_id"] for i in listed["items"] if i["is_cover"]] == [str(main_first)]
    assert listed["cover_chosen"] is False


def test_without_a_main_niche_photo_the_earliest_ready_photo_is_used(client, db_session):
    pro = _pro(db_session)
    _main(db_session, pro, "portraits")
    _photo(db_session, pro, minutes=0, status=MediaStatus.processing, objects_ready=False)
    _photo(db_session, pro, minutes=1, objects_ready=False)
    earliest_ready = _photo(db_session, pro, minutes=5, tags=("weddings",))
    _photo(db_session, pro, minutes=10)
    assert _preview(client, pro)["card"]["cover_media_asset_id"] == str(earliest_ready)


def test_a_photographer_with_no_photo_has_no_cover(client, db_session):
    pro = _pro(db_session)
    _photo(db_session, pro, status=MediaStatus.processing, objects_ready=False)
    preview = _preview(client, pro)
    assert preview["card"]["cover_media_asset_id"] is None and preview["card"]["cover_url"] is None
    assert preview["cover_chosen"] is False


def test_a_chosen_cover_that_is_not_their_photo_is_never_shown(client, db_session):
    """A cover written before the rules (or by hand) pointing at someone
    else's photo: the card shows their own photo instead."""
    _enable_city_and_flags(db_session, city=(city := _city()), country="PT")
    pro = _pro(db_session, city=city)
    own = _photo(db_session, pro)
    other = _pro(db_session)
    theirs = _photo(db_session, other)
    db_session.get(ProProfile, pro).cover_media_asset_id = theirs
    db_session.commit()
    assert _preview(client, pro)["card"]["cover_media_asset_id"] == str(own)
    assert _client_profile_cover(client, db_session, pro, city) == str(own)


def test_removing_the_cover_falls_back_to_another_photo(client, db_session):
    pro = _pro(db_session)
    # Not live yet, so the portfolio minimum does not apply.
    db_session.get(ProOnboarding, pro).status = ProOnboardingStatus.ready_for_review
    db_session.commit()
    first = _photo(db_session, pro, minutes=0)
    cover = _photo(db_session, pro, minutes=5)
    assert _set(client, pro, cover).status_code == 200
    removed = client.delete(f"/v1/pro/me/portfolio/{cover}", headers=_h(pro))
    assert removed.status_code == 200, removed.text
    assert removed.json()["cover_cleared"] is True
    assert _chosen(db_session, pro) is None
    preview = _preview(client, pro)
    assert preview["card"]["cover_media_asset_id"] == str(first), "the removed photo is still the cover"
    assert preview["card"]["cover_url"]
    listed = client.get("/v1/pro/me/portfolio", headers=_h(pro)).json()
    assert listed["cover_media_asset_id"] == str(first)


def test_a_removed_photo_is_never_the_cover(client, db_session):
    """Even if the profile still names it (removed by a path that did not
    clear it)."""
    pro = _pro(db_session)
    first = _photo(db_session, pro, minutes=0)
    gone = _photo(db_session, pro, minutes=5, status=MediaStatus.deleted)
    db_session.get(ProProfile, pro).cover_media_asset_id = gone
    db_session.commit()
    assert _preview(client, pro)["card"]["cover_media_asset_id"] == str(first)


# --- what clients see ---------------------------------------------------------------------------------


def test_discover_and_the_client_profile_show_the_new_cover_at_once(client, db_session):
    _enable_city_and_flags(db_session, city=(city := _city()), country="PT")
    pro = _pro(db_session, city=city)
    _main(db_session, pro, "portraits")
    first = _photo(db_session, pro, minutes=0)
    chosen = _photo(db_session, pro, minutes=5)
    cover_id, cover_url = _discover_cover(client, pro, city)
    assert cover_id == str(first) and cover_url, "Discover shows an empty card while ready photos exist"
    assert _set(client, pro, chosen).status_code == 200
    cover_id, _ = _discover_cover(client, pro, city)
    assert cover_id == str(chosen), "Discover still shows the old cover after a change"
    assert _client_profile_cover(client, db_session, pro, city) == str(chosen)


def test_a_niche_row_shows_the_cover_when_it_is_tagged_with_that_niche(db_session):
    from app.services.media_urls import resolve_niche_cover_urls

    pro = _pro(db_session)
    _photo(db_session, pro, minutes=0, tags=("portraits",))
    cover = _photo(db_session, pro, minutes=5, tags=("portraits",))
    _photo(db_session, pro, minutes=10, tags=("portraits",))
    urls = resolve_niche_cover_urls(db_session, [pro], niche_slug="portraits", preferred={cover})
    assert f"p/{cover}/t.jpg" in urls[pro]
