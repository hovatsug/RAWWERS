"""What the Lightroom plugin's delivery token can see and do.

The brief: the token may return only these fields, for the photographer's
own gigs - client first name and last initial, shoot date, niche or package,
included photo count, delivery state - and nothing else about the client
(no email, phone, address, messages or payment details), nothing about
earnings or other photographers. Uploads go through the pro app's own
upload code, into a gallery still being put together, with a daily cap per
device on top of the hourly bucket.

Storage and the broker are fakes: no network in tests.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.gallery import ProofGallery, ProofGalleryItem, ProofGalleryStatus
from app.models.gig import Gig, GigStatus
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.services import rate_limit
from app.services.delivery_gigs import client_short_name

SHA = "ab" * 32
NOW = datetime.now(timezone.utc)

#: Exactly what a gig in the client picker may say.
ALLOWED_GIG_FIELDS = {
    "gig_id",
    "gallery_id",
    "client_name",
    "shoot_starts_at",
    "shoot_starts_at_epoch",
    "package_title",
    "niche_name",
    "included_photos",
    "delivery_state",
    "photos_in_gallery",
    "photos_processing",
}

#: What the client and the money look like in the database; none of it may
#: reach the plugin.
CLIENT_SECRETS = ["Maria", "Silva", "ana.silva@example.test", "+351910000001", "Rua Secreta", "SECRET-NOTE", "79.74", "63.79"]


@pytest.fixture(autouse=True)
def fakes(monkeypatch):
    signed = lambda storage_key, content_type, expires_in=900: f"https://r2.invalid/{storage_key}?sig={uuid.uuid4().hex}"
    monkeypatch.setattr("app.services.photo_uploads.create_presigned_put", signed)
    monkeypatch.setattr("app.api.v1.media.create_presigned_put", signed)
    monkeypatch.setattr("app.api.v1.media.create_multipart_upload", lambda key, content_type: f"up-{uuid.uuid4().hex}")
    monkeypatch.setattr("app.api.v1.media.process_photo_variants.delay", lambda *_a, **_k: None)
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pair_ip", (100_000, 600))
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pair_all", (100_000, 600))
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pairing_issue", (100_000, 3600))


def _pro(db_session) -> uuid.UUID:
    pro = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro))
    db_session.flush()
    db_session.add(UserRole(user_id=pro, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=pro, display_name="Alex Lens"))
    db_session.commit()
    return pro


def _token(client, pro) -> str:
    code = client.post("/v1/pro/lightroom/pairing-code", headers={"X-User-Id": str(pro)}).json()["code"]
    paired = client.post("/v1/delivery/pair", json={"code": code, "device_name": f"Mac {uuid.uuid4().hex[:4]}"})
    assert paired.status_code == 200, paired.text
    return paired.json()["token"]


def _h(token):
    return {"Authorization": f"Bearer {token}", "X-Rawwers-Plugin-Version": "1.0.0"}


def _client(db_session, name="Ana Maria Silva") -> uuid.UUID:
    client_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=client_id, display_name=name, email=f"{uuid.uuid4().hex[:6]}.ana.silva@example.test", phone_e164=f"+3519{uuid.uuid4().int % 10**8:08d}"))
    db_session.commit()
    return client_id


def _gig(db_session, pro, *, client_id=None, status=GigStatus.paid, starts=NOW - timedelta(days=2), gallery_status=None, items=0) -> Gig:
    client_id = client_id or _client(db_session)
    gig = Gig(
        client_user_id=client_id,
        pro_user_id=pro,
        status=status,
        currency="EUR",
        amount_minimum=Decimal("79.74"),
        amount_platform_fee=Decimal("15.95"),
        amount_pro_gross=Decimal("63.79"),
        scheduled_start=starts,
        scheduled_end=starts + timedelta(hours=1) if starts else None,
        meta={
            "pricing_snapshot": {"package_title": "Portraits Starter", "included_photos": 20, "extra_photo_price": "4.80"},
            "niche_name": "Portraits",
            "client_notes": "SECRET-NOTE",
            "location_text": "Rua Secreta 12, Lisboa",
        },
    )
    db_session.add(gig)
    db_session.flush()
    if gallery_status is not None:
        gallery = ProofGallery(
            gig_id=gig.id,
            pro_user_id=pro,
            client_user_id=client_id,
            included_photos=20,
            extra_photo_price=Decimal("4.80"),
            currency="EUR",
            status=gallery_status,
        )
        db_session.add(gallery)
        db_session.flush()
        for n in range(items):
            asset = MediaAsset(
                owner_user_id=pro,
                kind=MediaKind.photo,
                purpose=MediaPurpose.proof,
                provider=MediaProvider.r2,
                status=MediaStatus.ready,
                visibility=MediaVisibility.client_only,
                meta={},
            )
            db_session.add(asset)
            db_session.flush()
            db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=n + 1))
    db_session.commit()
    return gig


def _start(client, token, gig_id, *, sha=SHA, size=6_000_000, name="IMG_0412.jpg"):
    return client.post(
        f"/v1/delivery/gigs/{gig_id}/uploads",
        headers=_h(token),
        json={"file_name": name, "content_type": "image/jpeg", "byte_size": size, "sha256": sha},
    )


# --- what the picker shows -------------------------------------------------------------


def test_a_shot_paid_gig_is_listed_with_only_the_allowed_fields(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)

    (item,) = client.get("/v1/delivery/gigs", headers=_h(token)).json()["items"]

    assert set(item) == ALLOWED_GIG_FIELDS
    assert item["gig_id"] == str(gig.id)
    assert item["client_name"] == "Ana S."
    assert item["package_title"] == "Portraits Starter"
    assert item["niche_name"] == "Portraits"
    assert item["included_photos"] == 20
    assert item["delivery_state"] == "waiting_for_photos"
    assert item["gallery_id"] is None
    assert item["shoot_starts_at_epoch"] == int(gig.scheduled_start.timestamp())


def test_nothing_else_about_the_client_or_the_money_reaches_the_plugin(client, db_session):
    pro = _pro(db_session)
    client_id = _client(db_session)
    gig = _gig(db_session, pro, client_id=client_id)
    token = _token(client, pro)
    started = _start(client, token, gig.id)
    gallery_id = started.json()["gallery_id"]
    asset_id = started.json()["media_asset_id"]

    said = [
        client.get("/v1/delivery/me", headers=_h(token)).text,
        client.get("/v1/delivery/gigs", headers=_h(token)).text,
        started.text,
        client.get(f"/v1/delivery/galleries/{gallery_id}/status", headers=_h(token)).text,
        client.post(f"/v1/delivery/uploads/{asset_id}/url", headers=_h(token)).text,
    ]
    account = db_session.get(UserAccount, client_id)
    for text in said:
        for secret in [*CLIENT_SECRETS, account.email, account.phone_e164, str(client_id)]:
            assert secret not in text, f"{secret!r} reached the plugin: {text[:200]}"


def test_no_delivery_route_returns_a_field_outside_its_own_list(client, db_session):
    # Guard against a field added to a response model later: every key the
    # gig list returns is in the allowed list, recursively.
    pro = _pro(db_session)
    _gig(db_session, pro)
    _gig(db_session, pro, gallery_status=ProofGalleryStatus.draft, items=2)
    token = _token(client, pro)
    for item in client.get("/v1/delivery/gigs", headers=_h(token)).json()["items"]:
        assert set(item) <= ALLOWED_GIG_FIELDS
        assert not any(isinstance(v, (dict, list)) for v in item.values()), "a nested object could carry anything"


@pytest.mark.parametrize(
    "case",
    ["future_shoot", "cancelled", "completed", "refunded", "sent_to_client", "selection_made", "other_photographer"],
)
def test_gigs_that_cannot_take_photos_from_here_are_not_listed(client, db_session, case):
    pro = _pro(db_session)
    other = _pro(db_session)
    kwargs = {
        "future_shoot": {"starts": NOW + timedelta(days=3)},
        "cancelled": {"status": GigStatus.cancelled_by_client},
        "completed": {"status": GigStatus.completed},
        "refunded": {"status": GigStatus.refunded},
        "sent_to_client": {"gallery_status": ProofGalleryStatus.published},
        "selection_made": {"gallery_status": ProofGalleryStatus.selection_submitted},
        "other_photographer": {},
    }[case]
    _gig(db_session, other if case == "other_photographer" else pro, **kwargs)
    token = _token(client, pro)

    assert client.get("/v1/delivery/gigs", headers=_h(token)).json()["items"] == []


def test_a_shoot_marked_done_is_listed_even_before_its_start(client, db_session):
    pro = _pro(db_session)
    _gig(db_session, pro, status=GigStatus.shoot_done, starts=NOW + timedelta(hours=2))
    assert len(client.get("/v1/delivery/gigs", headers=_h(_token(client, pro))).json()["items"]) == 1


def test_a_gallery_in_progress_is_listed_with_its_count(client, db_session):
    pro = _pro(db_session)
    _gig(db_session, pro, gallery_status=ProofGalleryStatus.draft, items=30)
    (item,) = client.get("/v1/delivery/gigs", headers=_h(_token(client, pro))).json()["items"]
    assert item["delivery_state"] == "in_progress"
    assert item["photos_in_gallery"] == 30


def test_the_soonest_shoot_comes_first(client, db_session):
    pro = _pro(db_session)
    later = _gig(db_session, pro, starts=NOW - timedelta(days=1))
    sooner = _gig(db_session, pro, starts=NOW - timedelta(days=9))
    undated = _gig(db_session, pro, starts=None)
    items = client.get("/v1/delivery/gigs", headers=_h(_token(client, pro))).json()["items"]
    assert [i["gig_id"] for i in items] == [str(sooner.id), str(later.id), str(undated.id)]


@pytest.mark.parametrize(
    ("name", "shown"),
    [
        ("Ana Maria Silva", "Ana S."),
        ("ana silva", "ana S."),
        ("Ana", "Ana"),
        (None, "Client"),
        ("", "Client"),
        ("ana@example.test", "Client"),
        ("+351 910 000 001", "Client"),
        ("Ana 2nd", "Client"),
    ],
)
def test_a_client_is_a_first_name_and_an_initial(name, shown):
    assert client_short_name(name) == shown


# --- uploading -------------------------------------------------------------------------


def test_the_first_photo_makes_the_gallery_with_the_bookings_terms(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)

    started = _start(client, token, gig.id)

    assert started.status_code == 200, started.text
    body = started.json()
    assert body["duplicate"] is False and body["use_multipart"] is False
    assert body["upload"]["method"] == "PUT" and body["upload"]["url"].startswith("https://r2.invalid/")
    gallery = db_session.get(ProofGallery, uuid.UUID(body["gallery_id"]))
    assert (gallery.gig_id, gallery.status, gallery.included_photos, gallery.extra_photo_price) == (
        gig.id,
        ProofGalleryStatus.draft,
        20,
        Decimal("4.80"),
    )
    asset = db_session.get(MediaAsset, uuid.UUID(body["media_asset_id"]))
    assert (asset.delivery_gallery_id, asset.checksum, asset.purpose, asset.visibility) == (
        gallery.id,
        SHA,
        MediaPurpose.proof,
        MediaVisibility.client_only,
    )


def test_the_same_file_again_is_skipped(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)
    first = _start(client, token, gig.id).json()
    db_session.get(MediaAsset, uuid.UUID(first["media_asset_id"])).status = MediaStatus.ready
    db_session.commit()

    again = _start(client, token, gig.id).json()

    assert again["duplicate"] is True and again["upload"] is None
    assert again["media_asset_id"] == first["media_asset_id"]


def test_a_large_file_is_sent_in_parts(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)

    started = _start(client, token, gig.id, size=30_000_000).json()
    assert started["use_multipart"] is True and started["upload"] is None

    parts = client.post(f"/v1/delivery/uploads/{started['media_asset_id']}/multipart", headers=_h(token), json={"byte_size": 30_000_000})
    assert parts.status_code == 200, parts.text
    assert parts.json()["part_count"] >= 2


def test_a_file_over_50_mb_is_refused_by_name(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    refused = _start(client, _token(client, pro), gig.id, size=50_000_001, name="DSC_9999.jpg")
    assert refused.status_code == 422
    assert "DSC_9999.jpg" in refused.json()["error"]["message"]


@pytest.mark.parametrize("status", [ProofGalleryStatus.published, ProofGalleryStatus.selection_submitted])
def test_a_gallery_already_sent_takes_nothing_from_here(client, db_session, status):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, gallery_status=status)
    refused = _start(client, _token(client, pro), gig.id)
    assert refused.status_code == 409
    assert refused.json()["error"]["code"] == "gallery_sent"


def test_another_photographers_gig_and_uploads_are_out_of_reach(client, db_session):
    owner, other = _pro(db_session), _pro(db_session)
    gig = _gig(db_session, owner)
    owner_token, other_token = _token(client, owner), _token(client, other)
    asset_id = _start(client, owner_token, gig.id).json()["media_asset_id"]
    gallery_id = db_session.get(MediaAsset, uuid.UUID(asset_id)).delivery_gallery_id

    assert _start(client, other_token, gig.id).status_code == 404
    for method, path, body in [
        ("POST", f"/v1/delivery/uploads/{asset_id}/url", None),
        ("POST", f"/v1/delivery/uploads/{asset_id}/complete", {"byte_size": 1, "sha256": SHA}),
        ("POST", f"/v1/delivery/uploads/{asset_id}/multipart", {"byte_size": 30_000_000}),
        ("GET", f"/v1/delivery/uploads/{asset_id}/multipart/parts", None),
        ("GET", f"/v1/delivery/galleries/{gallery_id}/status", None),
    ]:
        assert client.request(method, path, headers=_h(other_token), json=body).status_code == 404, path


def test_a_photo_the_app_uploaded_is_not_reachable_through_the_token(client, db_session):
    pro = _pro(db_session)
    asset = MediaAsset(
        owner_user_id=pro,
        kind=MediaKind.photo,
        purpose=MediaPurpose.portfolio_reel,
        provider=MediaProvider.r2,
        status=MediaStatus.uploading,
        visibility=MediaVisibility.public,
        meta={},
    )
    db_session.add(asset)
    db_session.commit()
    assert client.post(f"/v1/delivery/uploads/{asset.id}/url", headers=_h(_token(client, pro))).status_code == 404


def test_finishing_needs_the_hash_the_upload_started_with(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)
    asset_id = _start(client, token, gig.id).json()["media_asset_id"]

    wrong = client.post(f"/v1/delivery/uploads/{asset_id}/complete", headers=_h(token), json={"byte_size": 6_000_000, "sha256": "cd" * 32})
    assert wrong.status_code == 409 and wrong.json()["error"]["code"] == "checksum_mismatch"

    right = client.post(f"/v1/delivery/uploads/{asset_id}/complete", headers=_h(token), json={"byte_size": 6_000_000, "sha256": SHA.upper()})
    assert right.status_code == 200, right.text
    db_session.expire_all()
    assert db_session.get(MediaAsset, uuid.UUID(asset_id)).status == MediaStatus.processing


def test_each_device_has_a_daily_cap(client, db_session, monkeypatch):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_token_daily", (2, 86400))
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    first, second = _token(client, pro), _token(client, pro)

    codes = [_start(client, first, gig.id, sha=f"{n:064x}").status_code for n in range(3)]
    assert codes == [200, 200, 429]
    assert _start(client, second, gig.id, sha=f"{9:064x}").status_code == 200, "the cap is per device"


def test_the_daily_cap_is_5000():
    assert rate_limit.RATE_LIMIT_RULES["delivery_token_daily"] == (5000, 86400)


def test_status_says_what_is_in_the_gallery_still_going_and_failed(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)
    ids = [_start(client, token, gig.id, sha=f"{n:064x}", name=f"IMG_{n}.jpg").json()["media_asset_id"] for n in range(3)]
    gallery_id = db_session.get(MediaAsset, uuid.UUID(ids[0])).delivery_gallery_id
    processing, failed = db_session.get(MediaAsset, uuid.UUID(ids[1])), db_session.get(MediaAsset, uuid.UUID(ids[2]))
    processing.status = MediaStatus.processing
    failed.status = MediaStatus.failed
    failed.meta = {**failed.meta, "failure_reason": "The file that arrived does not match its SHA-256."}
    db_session.commit()

    status = client.get(f"/v1/delivery/galleries/{gallery_id}/status", headers=_h(token)).json()

    assert (status["uploading"], status["processing"], status["photos_in_gallery"], status["gallery_status"]) == (1, 1, 0, "draft")
    assert status["failed"] == [{"media_asset_id": ids[2], "file_name": "IMG_2.jpg", "reason": "The file that arrived does not match its SHA-256."}]


def test_a_device_revoked_mid_export_stops_at_the_next_photo(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)
    assert _start(client, token, gig.id, sha=f"{1:064x}").status_code == 200
    (device,) = client.get("/v1/pro/lightroom/devices", headers={"X-User-Id": str(pro)}).json()["items"]
    client.delete(f"/v1/pro/lightroom/devices/{device['id']}", headers={"X-User-Id": str(pro)})

    refused = _start(client, token, gig.id, sha=f"{2:064x}")
    assert refused.status_code == 401
    assert refused.json()["error"]["code"] == "delivery_token_revoked"
