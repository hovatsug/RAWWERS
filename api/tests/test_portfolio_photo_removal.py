"""A photographer removes their own portfolio photo (BETA_SCOPE #11, first
half, moved up on 2026-11-17).

DELETE /v1/pro/me/portfolio/{id} in the Pro app and the plug-in's DELETE
/v1/delivery/portfolio/{id} share one path (lightroom_portfolio.
remove_own_photo): only the owner's portfolio photo; kept while anything but
the cover uses it; a live photographer keeps the portfolio minimum; files
deleted, skills, tier and Discover recomputed, an audit record; a second
removal answers success and changes nothing. A Lightroom photo removed in
the app is never sent again by a re-publish (1.2.5). Storage is a fake.
"""
import hashlib
import uuid
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models.admin import AdminAuditLog, ProProfile
from app.models.discovery import ProPublicIndex
from app.models.gallery import ClientSelection, ClientSelectionItem, ProofGallery
from app.models.gig import Gig, GigStatus
from app.models.launch_ops import OnboardingRequirement, ProOnboarding, ProOnboardingStatus
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaPurpose, MediaStatus, MediaVariant, MediaVisibility
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
from app.models.niche import Niche, ProNiche, ProNicheSkill
from app.services import rate_limit
from tests.test_delivery_gigs import _pro, _token
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)


@pytest.fixture(autouse=True)
def generous_limits(monkeypatch):
    for name in ("uploads", "auth_mutation", "delivery_token_daily", "portfolio_removal"):
        monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, name, (100_000, 3600))


@pytest.fixture
def deleted(monkeypatch):
    keys = []
    monkeypatch.setattr("app.services.storage.delete_object", keys.append)
    return keys


@pytest.fixture
def slug(db_session):
    return db_session.execute(select(Niche.slug).where(Niche.is_active.is_(True)).order_by(Niche.slug)).scalars().first()


def _niche(db, pro, slug):
    niche = db.execute(select(Niche).where(Niche.slug == slug)).scalar_one()
    db.add(ProNiche(pro_user_id=pro, niche_id=niche.id, is_primary=True))
    db.commit()
    return niche


def _photo(db, pro, slug, *, status=MediaStatus.ready, meta=None) -> uuid.UUID:
    asset = MediaAsset(owner_user_id=pro, kind=MediaKind.photo, purpose=MediaPurpose.portfolio_reel, provider="r2",
                       status=status, visibility=MediaVisibility.public, content_type="image/jpeg",
                       niche_tags=[slug], meta=meta or {})
    db.add(asset)
    db.flush()
    db.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.original, storage_key=f"p/{asset.id}/original.jpg"))
    db.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.thumbnail, storage_key=f"p/{asset.id}/thumb.jpg"))
    db.add(MediaDerivative(media_asset_id=asset.id, kind=MediaDerivativeKind.web_res, storage_key=f"p/{asset.id}/web.jpg",
                           content_type="image/jpeg"))
    db.commit()
    return asset.id


def _photos(db, pro, slug, n):
    return [_photo(db, pro, slug) for _ in range(n)]


def _live(db, pro):
    db.add(ProOnboarding(pro_user_id=pro, status=ProOnboardingStatus.approved_public))
    db.commit()


def _remove(client, pro, asset_id):
    return client.delete(f"/v1/pro/me/portfolio/{asset_id}", headers={"X-User-Id": str(pro)})


def _status(db, asset_id):
    db.expire_all()
    return db.get(MediaAsset, asset_id).status


# --- the photographer's own photo -------------------------------------------------------------------


def test_a_photo_is_removed_with_its_files_skills_tier_and_discover(client, db_session, deleted, slug):
    pro = _pro(db_session)
    niche = _niche(db_session, pro, slug)
    keep = _photo(db_session, pro, slug)
    gone = _photo(db_session, pro, slug)
    # Skills and the index as they stand with both photos.
    from app.services.discovery_index import recompute_pro_public_index
    from app.services.niche_skills import recompute_pro_niche_skills

    recompute_pro_niche_skills(db_session, pro, niche.id)
    recompute_pro_public_index(db_session, pro)
    db_session.commit()
    assert db_session.get(ProPublicIndex, pro).portfolio_photo_count == 2

    answer = _remove(client, pro, gone)
    assert answer.status_code == 200, answer.text
    assert answer.json() == {"media_asset_id": str(gone), "removed": True, "cover_cleared": False}
    assert _status(db_session, gone) == MediaStatus.deleted
    assert _status(db_session, keep) == MediaStatus.ready
    assert sorted(deleted) == sorted([f"p/{gone}/original.jpg", f"p/{gone}/thumb.jpg", f"p/{gone}/web.jpg"]), "files left in storage"
    assert db_session.get(ProPublicIndex, pro).portfolio_photo_count == 1, "Discover still counts the removed photo"
    skill = db_session.execute(select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro, ProNicheSkill.niche_id == niche.id)).scalar_one()
    assert skill.evidence_portfolio == 1, "the niche's skills still count the removed photo"
    listed = client.get("/v1/pro/me/portfolio", headers={"X-User-Id": str(pro)}).json()
    assert [i["media_asset_id"] for i in listed["items"]] == [str(keep)]
    audit = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_id == str(gone))).scalars().all()
    assert [(a.action, a.actor_user_id, a.meta["source"]) for a in audit] == [("portfolio_photo_removed", pro, "app")]


def test_a_live_photographers_removed_photo_leaves_their_public_profile(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    photos = _photos(db_session, pro, slug, 14)
    _live(db_session, pro)
    assert _remove(client, pro, photos[0]).status_code == 200
    from app.services.lightroom_portfolio import niche_counts

    assert niche_counts(db_session, pro)[slug] == 13
    db_session.expire_all()
    assert db_session.get(ProPublicIndex, pro).portfolio_photo_count == 13


def test_removing_it_again_answers_success_and_changes_nothing(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    photo = _photo(db_session, pro, slug)
    assert _remove(client, pro, photo).json()["removed"] is True
    deleted.clear()
    again = _remove(client, pro, photo)
    assert again.status_code == 200 and again.json()["removed"] is False
    assert deleted == []
    audit = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_id == str(photo))).scalars().all()
    assert len(audit) == 1, "the second removal was recorded"


def test_a_photo_still_processing_can_be_removed(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    _live(db_session, pro)
    photo = _photo(db_session, pro, slug, status=MediaStatus.processing)
    assert _remove(client, pro, photo).status_code == 200
    assert _status(db_session, photo) == MediaStatus.deleted


# --- only the owner ---------------------------------------------------------------------------------


def test_another_photographers_photo_is_refused_and_untouched(client, db_session, deleted, slug):
    owner, me = _pro(db_session), _pro(db_session)
    _niche(db_session, owner, slug)
    theirs = _photo(db_session, owner, slug)
    answer = _remove(client, me, theirs)
    assert answer.status_code == 404
    assert _status(db_session, theirs) == MediaStatus.ready
    assert deleted == []


def test_a_photo_that_is_not_a_portfolio_photo_is_refused(client, db_session, deleted, slug):
    pro = _pro(db_session)
    other = MediaAsset(owner_user_id=pro, kind=MediaKind.photo, purpose=MediaPurpose.proof, provider="r2",
                       status=MediaStatus.ready, visibility=MediaVisibility.public, content_type="image/jpeg", meta={})
    db_session.add(other)
    db_session.commit()
    assert _remove(client, pro, other.id).status_code == 404
    assert _status(db_session, other.id) == MediaStatus.ready


def test_a_client_cannot_call_it(client, db_session, slug):
    assert client.delete(f"/v1/pro/me/portfolio/{uuid.uuid4()}", headers={"X-User-Id": str(uuid.uuid4())}).status_code in (401, 403)


# --- used by something else ---------------------------------------------------------------------------


def test_a_photo_in_a_clients_selection_is_refused(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    photo = _photo(db_session, pro, slug)
    customer = uuid.uuid4()
    gig = Gig(client_user_id=customer, pro_user_id=pro, status=GigStatus.paid, currency="EUR", amount_minimum=Decimal("100.00"),
              amount_platform_fee=Decimal("20.00"), amount_pro_gross=Decimal("80.00"), meta={})
    db_session.add(gig)
    db_session.flush()
    gallery = ProofGallery(gig_id=gig.id, pro_user_id=pro, client_user_id=customer, included_photos=10,
                           extra_photo_price=Decimal("7.00"), currency="EUR")
    db_session.add(gallery)
    db_session.flush()
    selection = ClientSelection(gallery_id=gallery.id, client_user_id=customer, version=1)
    db_session.add(selection)
    db_session.flush()
    db_session.add(ClientSelectionItem(selection_id=selection.id, media_asset_id=photo))
    db_session.commit()

    answer = _remove(client, pro, photo)
    assert answer.status_code == 409 and answer.json()["error"]["code"] == "photo_in_use"
    assert "a client's selection" in answer.json()["error"]["message"]
    assert _status(db_session, photo) == MediaStatus.ready
    assert deleted == []


def test_a_photo_named_in_a_dispute_is_refused(client, db_session, deleted, slug):
    """A JSON list of photo ids, which no foreign key shows."""
    from app.models.admin import Dispute, DisputeCategory, DisputeMessage, DisputeStatus

    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    photo = _photo(db_session, pro, slug)
    dispute = Dispute(opened_by_user_id=uuid.uuid4(), against_user_id=pro, status=DisputeStatus.open,
                      category=DisputeCategory.no_show, currency="EUR", summary="e2e")
    db_session.add(dispute)
    db_session.flush()
    db_session.add(DisputeMessage(dispute_id=dispute.id, sender_user_id=pro, message="see this", evidence_media_asset_ids=[str(photo)]))
    db_session.commit()
    answer = _remove(client, pro, photo)
    assert answer.status_code == 409 and "a dispute" in answer.json()["error"]["message"]
    assert _status(db_session, photo) == MediaStatus.ready


def test_the_cover_may_be_removed_and_is_cleared(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    photo = _photo(db_session, pro, slug)
    db_session.get(ProProfile, pro).cover_media_asset_id = photo
    db_session.commit()
    answer = _remove(client, pro, photo)
    assert answer.status_code == 200
    assert answer.json()["cover_cleared"] is True
    db_session.expire_all()
    assert db_session.get(ProProfile, pro).cover_media_asset_id is None


# --- the portfolio minimum for a live photographer ---------------------------------------------------


def test_a_live_photographer_cannot_drop_below_the_minimum(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    photos = _photos(db_session, pro, slug, 12)
    _live(db_session, pro)
    answer = _remove(client, pro, photos[0])
    assert answer.status_code == 409 and answer.json()["error"]["code"] == "portfolio_minimum"
    assert answer.json()["error"]["message"].startswith("Add another photo first, then remove this one.")
    assert _status(db_session, photos[0]) == MediaStatus.ready
    assert deleted == []
    # One more, and one can go.
    _photo(db_session, pro, slug)
    assert _remove(client, pro, photos[0]).status_code == 200


def test_the_minimum_is_the_admin_setting(client, db_session, deleted, slug):
    row = db_session.execute(select(OnboardingRequirement).where(OnboardingRequirement.key == "portfolio_min_items")).scalar_one_or_none()
    before = dict(row.value) if row else None
    if row is None:
        row = OnboardingRequirement(key="portfolio_min_items", value={"count": 3})
        db_session.add(row)
    else:
        row.value = {"count": 3}
    db_session.commit()
    try:
        pro = _pro(db_session)
        _niche(db_session, pro, slug)
        photos = _photos(db_session, pro, slug, 4)
        _live(db_session, pro)
        assert _remove(client, pro, photos[0]).status_code == 200
        assert _remove(client, pro, photos[1]).json()["error"]["code"] == "portfolio_minimum"
    finally:
        if before is None:
            db_session.delete(row)
        else:
            row.value = before
        db_session.commit()


def test_a_photographer_not_yet_live_may_remove_any_photo(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    photos = _photos(db_session, pro, slug, 3)
    db_session.add(ProOnboarding(pro_user_id=pro, status=ProOnboardingStatus.ready_for_review))
    db_session.commit()
    for photo in photos:
        assert _remove(client, pro, photo).status_code == 200


# --- the rate limit ------------------------------------------------------------------------------------


def test_removals_are_rate_limited(client, db_session, deleted, slug, monkeypatch):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "portfolio_removal", (2, 3600))
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    photos = _photos(db_session, pro, slug, 3)
    assert _remove(client, pro, photos[0]).status_code == 200
    assert _remove(client, pro, photos[1]).status_code == 200
    third = _remove(client, pro, photos[2])
    assert third.status_code == 429
    assert _status(db_session, photos[2]) == MediaStatus.ready


# --- the plug-in: the same rules, and never sending a removed photo again -------------------------------

SHA = hashlib.sha256(b"P_0413").hexdigest()


def _h(token):
    return {"Authorization": f"Bearer {token}", "X-Rawwers-Plugin-Version": "1.2.5"}


def _publish(client, token, slug, *, previous=None, key="lr:photo-1:collection-1", sha=SHA):
    return client.post(
        "/v1/delivery/portfolio/uploads",
        headers=_h(token),
        json={"niche_slug": slug, "file_name": "P_0413.jpg", "content_type": "image/jpeg", "byte_size": 6_000_000,
              "sha256": sha, "publish_key": key, "previous_id": str(previous) if previous else None},
    )


def _lightroom_photo(client, db, token, slug):
    body = _publish(client, token, slug).json()
    asset = db.get(MediaAsset, uuid.UUID(body["media_asset_id"]))
    asset.status = MediaStatus.ready
    db.commit()
    return asset.id


def test_a_lightroom_photo_removed_in_the_app_is_never_sent_again_by_a_republish(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    token = _token(client, pro)
    photo = _lightroom_photo(client, db_session, token, slug)
    assert _remove(client, pro, photo).status_code == 200

    listing = client.get("/v1/delivery/portfolio", headers=_h(token)).json()
    assert listing["removed_in_app"] == [str(photo)]
    # An edit re-published (Lightroom names the photo it replaces): refused, nothing started.
    before = db_session.execute(select(MediaAsset.id).where(MediaAsset.owner_user_id == pro)).all()
    again = _publish(client, token, slug, previous=photo, sha=hashlib.sha256(b"edited").hexdigest())
    assert again.status_code == 409 and again.json()["error"]["code"] == "photo_removed_in_app"
    assert "add it back" in again.json()["error"]["message"]
    db_session.expire_all()
    assert db_session.execute(select(MediaAsset.id).where(MediaAsset.owner_user_id == pro)).all() == before
    # Added to the collection again (no previous photo): the photographer's choice, sent anew.
    anew = _publish(client, token, slug, key="lr:photo-1:collection-1")
    assert anew.status_code == 200 and anew.json()["media_asset_id"] != str(photo)


def test_a_photo_the_plugin_removed_itself_is_not_reported_as_removed_in_the_app(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    token = _token(client, pro)
    photo = _lightroom_photo(client, db_session, token, slug)
    assert client.delete(f"/v1/delivery/portfolio/{photo}", headers=_h(token)).status_code == 200
    assert client.get("/v1/delivery/portfolio", headers=_h(token)).json()["removed_in_app"] == []
    audit = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_id == str(photo))).scalars().all()
    assert [a.meta["source"] for a in audit] == ["lightroom"]


def test_the_plugin_keeps_a_live_photographer_at_the_minimum_too(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    token = _token(client, pro)
    photo = _lightroom_photo(client, db_session, token, slug)
    _photos(db_session, pro, slug, 11)
    _live(db_session, pro)
    answer = client.delete(f"/v1/delivery/portfolio/{photo}", headers=_h(token))
    assert answer.status_code == 409 and answer.json()["error"]["code"] == "portfolio_minimum"
    assert _status(db_session, photo) == MediaStatus.ready


def test_the_app_removes_a_photo_published_from_lightroom(client, db_session, deleted, slug):
    pro = _pro(db_session)
    _niche(db_session, pro, slug)
    token = _token(client, pro)
    photo = _lightroom_photo(client, db_session, token, slug)
    assert _remove(client, pro, photo).status_code == 200
    db_session.expire_all()
    assert db_session.get(MediaAsset, photo).meta["removed"] == "app"
    # Lightroom then asks to remove it too (taken out of the collection): already gone, success.
    assert client.delete(f"/v1/delivery/portfolio/{photo}", headers=_h(token)).status_code == 200
