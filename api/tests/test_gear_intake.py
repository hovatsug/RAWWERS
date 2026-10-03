"""Gear intake: a photographer can actually get through the gear gate.

`activate_pro` has refused every photographer without verified gear since the
gate was added, and there was no way to become verified: `verify_from_raw` was
called only by tests and a seed script. These tests drive the path a real
photographer takes - upload a frame, have it read, be told the result - and a
reviewer's path for the cases a machine should not decide.

The frames are header slices of real camera files (see fixtures/raw/README.md),
not synthesised images, because the reader was first "tested" against JPEGs
made by Pillow and failed on every real format that mattered.
"""
import uuid
from decimal import Decimal
from pathlib import Path

import pytest
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.gear_verification import (
    ApertureType,
    CameraModelReference,
    GearVerification,
    LensModelReference,
    SensorSize,
    VerificationStatus,
)
from app.models.repair import GearCategory
from app.services.gear_verify import normalise_model
from sqlalchemy import select

from tests.test_gear_verification import _ready_pro

FIXTURES = Path(__file__).parent / "fixtures" / "raw"


def _fx(name: str) -> bytes:
    return (FIXTURES / name).read_bytes()


# ---------------------------------------------------------------------------
# Scaffolding
# ---------------------------------------------------------------------------


@pytest.fixture
def storage(monkeypatch) -> dict[str, bytes]:
    """The object store, as a dict. Uploads are not executed against R2; the
    tests put the bytes where the presigned URL would have."""
    store: dict[str, bytes] = {}
    monkeypatch.setattr("app.api.v1.media.object_size", lambda key: len(store[key]) if key in store else None)
    monkeypatch.setattr("app.api.v1.media.delete_object", lambda key: store.pop(key, None))
    monkeypatch.setattr(
        "app.api.v1.gear_verification.download_object_range",
        lambda key, start, length: store[key][start : start + length],
    )
    return store


@pytest.fixture
def catalogue(db_session):
    """The reference rows, spelled the way the real cameras spell themselves."""
    for model, display, sensor in [
        ("Canon EOS R5", "Canon EOS R5", SensorSize.full_frame),
        ("Canon EOS R", "Canon EOS R", SensorSize.full_frame),
        ("ILCE-7M4", "Sony A7 IV", SensorSize.full_frame),
        ("NIKON Z 6", "Nikon Z6", SensorSize.full_frame),
        ("X-T4", "Fujifilm X-T4", SensorSize.crop),
    ]:
        db_session.merge(
            CameraModelReference(
                normalised_model=normalise_model(model), make=None, display_name=display, sensor_size=sensor
            )
        )
    db_session.commit()


def _h(user_id) -> dict:
    return {"X-User-Id": str(user_id)}


def _upload(client, storage, pro_id, name: str, data: bytes, *, content_type="application/octet-stream"):
    """create -> (the PUT, done by hand) -> complete, as the app does it."""
    created = client.post(
        "/v1/media/photos/uploads",
        headers=_h(pro_id),
        json={"purpose": "gear_evidence", "content_type": content_type, "file_name": name},
    )
    assert created.status_code == 200, created.text
    body = created.json()
    storage[body["upload"]["storage_key"]] = data
    done = client.post(
        f"/v1/media/photos/{body['media_asset_id']}/complete", headers=_h(pro_id), json={"byte_size": len(data)}
    )
    assert done.status_code == 200, done.text
    return body["media_asset_id"]


def _submit_frame(client, storage, pro_id, name: str, data: bytes):
    asset_id = _upload(client, storage, pro_id, name, data)
    return client.post(
        "/v1/pro/me/gear-verifications", headers=_h(pro_id), json={"evidence_media_asset_id": asset_id}
    )


def _new_pro(db_session) -> uuid.UUID:
    pro_id = _ready_pro(db_session, with_gear=False)
    db_session.commit()
    return pro_id


def _add_package(db_session, pro_id):
    from app.models.booking import ProPackage
    from app.models.niche import Niche

    niche = db_session.execute(select(Niche).where(Niche.slug == "portraits")).scalar_one()
    db_session.add(
        ProPackage(
            pro_user_id=pro_id, niche_id=niche.id, title="Session", duration_minutes=60,
            price=Decimal("5.00"), currency="EUR", included_photos=10,
            extra_photo_price=Decimal("5.00"), proofs_sla_days=3, finals_sla_days=7,
            addons=[], is_active=True,
        )
    )
    db_session.commit()


def _admin(db_session) -> uuid.UUID:
    admin_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=admin_id))
    db_session.flush()
    db_session.add(UserRole(user_id=admin_id, role=UserRoleType.admin))
    db_session.commit()
    return admin_id


def _by_category(items, category):
    return [i for i in items if i["category"] == category]


# ---------------------------------------------------------------------------
# The upload: a RAW is not a portfolio photo.
# ---------------------------------------------------------------------------


def test_a_raw_file_can_be_uploaded_as_gear_evidence(client, db_session, storage):
    pro_id = _new_pro(db_session)

    asset_id = _upload(client, storage, pro_id, "IMG_0001.CR3", _fx("canon_eos_r5.cr3.head"))

    view = client.get(f"/v1/media/{asset_id}", headers=_h(pro_id))
    assert view.status_code == 200, view.text
    assert view.json()["status"] == "ready", "evidence was sent to the photo pipeline, which cannot decode a RAW"


def test_evidence_is_private_to_its_owner(client, db_session, storage):
    pro_id = _new_pro(db_session)
    asset_id = _upload(client, storage, pro_id, "IMG_0001.CR3", _fx("canon_eos_r5.cr3.head"))

    assert client.get(f"/v1/media/{asset_id}", headers=_h(_new_pro(db_session))).status_code == 403


def test_a_file_that_is_not_a_camera_file_is_refused_at_upload(client, db_session, storage):
    pro_id = _new_pro(db_session)

    resp = client.post(
        "/v1/media/photos/uploads",
        headers=_h(pro_id),
        json={"purpose": "gear_evidence", "content_type": "application/octet-stream", "file_name": "payload.exe"},
    )

    assert resp.status_code == 422, resp.text


def test_an_upload_over_the_size_cap_is_refused_and_removed(client, db_session, storage, monkeypatch):
    """`byte_size` is whatever the client says it is. The cap is checked
    against the object that is actually in storage."""
    from app.core.config import get_settings

    monkeypatch.setattr(get_settings(), "gear_evidence_max_bytes", 1000)
    pro_id = _new_pro(db_session)
    created = client.post(
        "/v1/media/photos/uploads",
        headers=_h(pro_id),
        json={"purpose": "gear_evidence", "content_type": "application/octet-stream", "file_name": "big.arw"},
    ).json()
    key = created["upload"]["storage_key"]
    storage[key] = b"x" * 5000

    done = client.post(f"/v1/media/photos/{created['media_asset_id']}/complete", headers=_h(pro_id), json={"byte_size": 10})

    assert done.status_code == 422, done.text
    assert key not in storage, "an oversized object was left in the bucket"


# ---------------------------------------------------------------------------
# Verification from a frame.
# ---------------------------------------------------------------------------


def test_a_canon_cr3_verifies_the_body_and_the_lens_from_one_frame(client, db_session, storage, catalogue):
    pro_id = _new_pro(db_session)

    resp = _submit_frame(client, storage, pro_id, "IMG_0001.CR3", _fx("canon_eos_r5.cr3.head"))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    bodies, lenses = _by_category(body["items"], "camera_body"), _by_category(body["items"], "lens")
    assert [b["status"] for b in bodies] == ["verified"]
    assert bodies[0]["model"] == "Canon EOS R5" and bodies[0]["sensor_size"] == "full_frame"
    assert [l["status"] for l in lenses] == ["verified"], "a 50mm prime shot on it should qualify"
    assert body["floor"]["meets_floor"] is True
    assert body["floor"]["missing"] == []


def test_a_serial_is_never_returned_in_full(client, db_session, storage, catalogue):
    pro_id = _new_pro(db_session)
    body = _submit_frame(client, storage, pro_id, "IMG_0001.CR3", _fx("canon_eos_r5.cr3.head")).json()

    text = str(body)
    assert "083023000411" not in text
    assert "0411" in text, "the last digits are what lets a photographer recognise the camera"


def test_a_sony_body_that_publishes_no_serial_waits_for_a_person(client, db_session, storage, catalogue):
    """Real Sony files carry no readable serial. That is a queue item, not a
    rejection, and the photographer is told it is the platform they are waiting on."""
    pro_id = _new_pro(db_session)

    body = _submit_frame(client, storage, pro_id, "DSC06674.ARW", _fx("sony_ilce7m4.arw.head")).json()

    sony = _by_category(body["items"], "camera_body")[0]
    assert sony["status"] == "pending_review"
    assert "serial" in sony["review_reason"].lower()
    assert body["floor"]["awaiting_review"] == 1
    assert body["floor"]["meets_floor"] is False


def test_a_crop_body_is_rejected_with_the_reason(client, db_session, storage, catalogue):
    pro_id = _new_pro(db_session)

    body = _submit_frame(client, storage, pro_id, "DSCF0266.RAF", _fx("fujifilm_xt4.raf.head")).json()

    fuji = _by_category(body["items"], "camera_body")[0]
    assert fuji["status"] == "rejected"
    assert "full-frame" in fuji["review_reason"]
    assert body["floor"]["meets_floor"] is False


def test_submitting_the_same_frame_twice_does_not_duplicate_the_gear(client, db_session, storage, catalogue):
    pro_id = _new_pro(db_session)

    first = _submit_frame(client, storage, pro_id, "A.CR3", _fx("canon_eos_r5.cr3.head")).json()
    second = _submit_frame(client, storage, pro_id, "B.CR3", _fx("canon_eos_r5.cr3.head")).json()

    assert [i["id"] for i in first["items"]] == [i["id"] for i in second["items"]]
    rows = db_session.execute(select(GearVerification).where(GearVerification.pro_user_id == pro_id)).scalars().all()
    assert len(rows) == 2, f"{len(rows)} rows for one body and one lens"


def test_a_serial_less_body_is_not_queued_twice_for_the_same_camera(client, db_session, storage, catalogue):
    """A second frame from the same Sony would otherwise put the same camera in
    the review queue again, once per lens the photographer uploads."""
    pro_id = _new_pro(db_session)

    _submit_frame(client, storage, pro_id, "A.ARW", _fx("sony_ilce7m4.arw.head"))
    _submit_frame(client, storage, pro_id, "B.ARW", _fx("sony_ilce7m4.arw.head"))

    pending = db_session.execute(
        select(GearVerification).where(
            GearVerification.pro_user_id == pro_id, GearVerification.status == VerificationStatus.pending_review
        )
    ).scalars().all()
    assert len(pending) == 1


def test_the_same_camera_cannot_be_verified_by_two_photographers(client, db_session, storage, catalogue):
    first, second = _new_pro(db_session), _new_pro(db_session)
    assert _submit_frame(client, storage, first, "A.CR3", _fx("canon_eos_r5.cr3.head")).status_code == 200

    resp = _submit_frame(client, storage, second, "A.CR3", _fx("canon_eos_r5.cr3.head"))

    assert resp.status_code == 409, resp.text
    assert "already registered" in resp.json()["error"]["message"]


def test_releasing_gear_frees_it_for_its_next_owner(client, db_session, storage, catalogue):
    first, second = _new_pro(db_session), _new_pro(db_session)
    body = _submit_frame(client, storage, first, "A.CR3", _fx("canon_eos_r5.cr3.head")).json()
    for item in body["items"]:
        assert client.delete(f"/v1/pro/me/gear-verifications/{item['id']}", headers=_h(first)).status_code == 204

    assert _submit_frame(client, storage, second, "A.CR3", _fx("canon_eos_r5.cr3.head")).status_code == 200


def test_nobody_can_release_someone_elses_gear(client, db_session, storage, catalogue):
    owner, other = _new_pro(db_session), _new_pro(db_session)
    body = _submit_frame(client, storage, owner, "A.CR3", _fx("canon_eos_r5.cr3.head")).json()

    resp = client.delete(f"/v1/pro/me/gear-verifications/{body['items'][0]['id']}", headers=_h(other))

    assert resp.status_code == 404


def test_a_file_with_no_camera_data_is_refused_with_a_reason(client, db_session, storage, catalogue):
    pro_id = _new_pro(db_session)

    resp = _submit_frame(client, storage, pro_id, "notes.jpg", b"this is not a photograph" * 200)

    assert resp.status_code == 422, resp.text
    assert "camera data" in resp.json()["error"]["message"]


# ---------------------------------------------------------------------------
# Whose evidence it is, and what it is.
# ---------------------------------------------------------------------------


def test_someone_elses_evidence_cannot_be_used(client, db_session, storage, catalogue):
    owner, thief = _new_pro(db_session), _new_pro(db_session)
    asset_id = _upload(client, storage, owner, "A.CR3", _fx("canon_eos_r5.cr3.head"))

    resp = client.post("/v1/pro/me/gear-verifications", headers=_h(thief), json={"evidence_media_asset_id": asset_id})

    assert resp.status_code == 403, resp.text


def test_only_gear_evidence_can_be_used_as_evidence(client, db_session, storage, catalogue):
    """A portfolio photo is not proof of what a photographer shoots on."""
    pro_id = _new_pro(db_session)
    created = client.post(
        "/v1/media/photos/uploads",
        headers=_h(pro_id),
        json={"purpose": "portfolio_reel", "content_type": "image/jpeg", "file_name": "p.jpg"},
    ).json()

    resp = client.post(
        "/v1/pro/me/gear-verifications", headers=_h(pro_id), json={"evidence_media_asset_id": created["media_asset_id"]}
    )

    assert resp.status_code == 422, resp.text


def test_evidence_that_never_finished_uploading_cannot_be_used(client, db_session, storage, catalogue):
    pro_id = _new_pro(db_session)
    created = client.post(
        "/v1/media/photos/uploads",
        headers=_h(pro_id),
        json={"purpose": "gear_evidence", "content_type": "application/octet-stream", "file_name": "a.cr3"},
    ).json()

    resp = client.post(
        "/v1/pro/me/gear-verifications", headers=_h(pro_id), json={"evidence_media_asset_id": created["media_asset_id"]}
    )

    assert resp.status_code == 409, resp.text


def test_a_client_who_is_not_a_photographer_cannot_use_any_of_it(client, db_session, storage, catalogue):
    client_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=client_id))
    db_session.flush()
    db_session.add(UserRole(user_id=client_id, role=UserRoleType.client))
    db_session.commit()

    assert client.get("/v1/pro/me/gear-verifications", headers=_h(client_id)).status_code == 403
    assert client.post(
        "/v1/pro/me/gear-verifications/lighting", headers=_h(client_id), json={"model": "AD600"}
    ).status_code == 403


# ---------------------------------------------------------------------------
# The reason this exists: a photographer can go live.
# ---------------------------------------------------------------------------


def test_a_photographer_can_go_live_after_verifying_gear_through_the_app_path(client, db_session, storage, catalogue):
    """Not the seed script and not a hand-built row: upload, verify, activate."""
    pro_id = _new_pro(db_session)
    _add_package(db_session, pro_id)

    refused = client.post("/v1/pro/me/activate", headers=_h(pro_id))
    assert refused.status_code == 409, refused.text
    assert "Verified gear required" in refused.json()["error"]["message"]

    assert _submit_frame(client, storage, pro_id, "IMG_0001.CR3", _fx("canon_eos_r5.cr3.head")).status_code == 200

    allowed = client.post("/v1/pro/me/activate", headers=_h(pro_id))
    assert allowed.status_code == 200, allowed.text
    assert allowed.json()["is_accepting_bookings"] is True


def test_the_onboarding_checks_follow_the_verification(client, db_session, storage, catalogue):
    pro_id = _new_pro(db_session)
    before = client.get("/v1/pro/onboarding/checks", headers=_h(pro_id)).json()["checks"]
    assert before["gear_verified"] is False

    _submit_frame(client, storage, pro_id, "IMG_0001.CR3", _fx("canon_eos_r5.cr3.head"))

    after = client.get("/v1/pro/onboarding/checks", headers=_h(pro_id)).json()["checks"]
    assert after["gear_verified"] is True and after["gear_missing"] == []


# ---------------------------------------------------------------------------
# Lighting is declared, and is not a photograph.
# ---------------------------------------------------------------------------


def test_lighting_is_declared_without_a_photo_and_recorded_as_such(client, db_session, catalogue):
    pro_id = _new_pro(db_session)

    resp = client.post(
        "/v1/pro/me/gear-verifications/lighting",
        headers=_h(pro_id),
        json={"make": "Godox", "model": "AD600 Pro", "notes": "Two heads and a softbox"},
    )

    assert resp.status_code == 200, resp.text
    item = resp.json()
    assert item["category"] == "lighting" and item["status"] == "declared"
    # What they typed, not whatever camera happened to be in a photo.
    assert item["make"] == "Godox" and item["model"] == "AD600 Pro"
    row = db_session.get(GearVerification, uuid.UUID(item["id"]))
    assert row.status == VerificationStatus.declared and row.category == GearCategory.lighting


def test_lighting_needs_a_model(client, db_session, catalogue):
    pro_id = _new_pro(db_session)

    resp = client.post("/v1/pro/me/gear-verifications/lighting", headers=_h(pro_id), json={"model": "  "})

    assert resp.status_code == 422, resp.text


def test_declared_lighting_satisfies_the_lighting_requirement_and_says_so(client, db_session, storage, catalogue):
    from app.models.niche import Niche, ProNiche

    pro_id = _new_pro(db_session)
    wedding = db_session.execute(select(Niche).where(Niche.slug == "weddings")).scalar_one()
    db_session.add(ProNiche(pro_user_id=pro_id, niche_id=wedding.id, is_primary=True))
    db_session.commit()
    _submit_frame(client, storage, pro_id, "IMG_0001.CR3", _fx("canon_eos_r5.cr3.head"))
    before = client.get("/v1/pro/me/gear-verifications", headers=_h(pro_id)).json()["floor"]
    assert before["lighting_required"] is True and before["meets_floor"] is False
    assert before["missing"] == ["lighting"]

    client.post("/v1/pro/me/gear-verifications/lighting", headers=_h(pro_id), json={"model": "AD600 Pro"})

    after = client.get("/v1/pro/me/gear-verifications", headers=_h(pro_id)).json()["floor"]
    assert after["meets_floor"] is True
    assert after["lighting_is_declared"] is True, "declared lighting was presented as if it had been proven"


# ---------------------------------------------------------------------------
# The review queue.
# ---------------------------------------------------------------------------


def _queue(client, admin_id, status="pending_review"):
    resp = client.get(f"/v1/admin/gear-verifications?status={status}", headers=_h(admin_id))
    assert resp.status_code == 200, resp.text
    return resp.json()["items"]


def _pending_sony(client, db_session, storage):
    pro_id = _new_pro(db_session)
    _submit_frame(client, storage, pro_id, "DSC.ARW", _fx("sony_ilce7m4.arw.head"))
    return pro_id


def test_the_queue_lists_what_is_waiting_with_enough_to_decide(client, db_session, storage, catalogue):
    pro_id = _pending_sony(client, db_session, storage)
    admin_id = _admin(db_session)

    items = _queue(client, admin_id)

    assert len(_by_category(items, "camera_body")) == 1
    row = _by_category(items, "camera_body")[0]
    assert row["pro_user_id"] == str(pro_id)
    assert row["model"] == "ILCE-7M4" and "serial" in row["review_reason"].lower()
    assert row["exif_snapshot"]["model"] == "ILCE-7M4"


def test_only_an_admin_can_see_or_decide(client, db_session, storage, catalogue):
    pro_id = _pending_sony(client, db_session, storage)
    item = _queue(client, _admin(db_session))[0]

    assert client.get("/v1/admin/gear-verifications", headers=_h(pro_id)).status_code == 403
    assert client.post(f"/v1/admin/gear-verifications/{item['id']}/approve", headers=_h(pro_id), json={}).status_code == 403
    assert client.post(
        f"/v1/admin/gear-verifications/{item['id']}/reject", headers=_h(pro_id), json={"reason": "no"}
    ).status_code == 403


def test_approving_a_known_model_that_lacked_a_serial_needs_nothing_more(client, db_session, storage, catalogue):
    pro_id = _pending_sony(client, db_session, storage)
    admin_id = _admin(db_session)
    body = _by_category(_queue(client, admin_id), "camera_body")[0]

    resp = client.post(
        f"/v1/admin/gear-verifications/{body['id']}/approve", headers=_h(admin_id), json={"note": "Serial checked by hand"}
    )

    assert resp.status_code == 200, resp.text
    row = db_session.get(GearVerification, uuid.UUID(body["id"]))
    db_session.refresh(row)
    assert row.status == VerificationStatus.verified and row.sensor_size == SensorSize.full_frame
    assert row.reviewed_by == admin_id and row.reviewed_at is not None and row.review_note == "Serial checked by hand"
    assert _by_category(_queue(client, admin_id), "camera_body") == []


def test_approving_an_unknown_body_needs_its_sensor_size(client, db_session, storage, catalogue):
    """Approving without it would produce a verified row that still cannot
    satisfy the floor, which is a confusing way to be wrong."""
    pro_id = _new_pro(db_session)
    # A Canon R5 frame, with the model removed from the reference table.
    db_session.query(CameraModelReference).filter_by(normalised_model=normalise_model("Canon EOS R5")).delete()
    db_session.commit()
    _submit_frame(client, storage, pro_id, "A.CR3", _fx("canon_eos_r5.cr3.head"))
    admin_id = _admin(db_session)
    body = _by_category(_queue(client, admin_id), "camera_body")[0]
    assert "reference list" in body["review_reason"]

    missing = client.post(f"/v1/admin/gear-verifications/{body['id']}/approve", headers=_h(admin_id), json={})
    crop = client.post(
        f"/v1/admin/gear-verifications/{body['id']}/approve", headers=_h(admin_id), json={"sensor_size": "crop"}
    )
    ok = client.post(
        f"/v1/admin/gear-verifications/{body['id']}/approve", headers=_h(admin_id), json={"sensor_size": "full_frame"}
    )

    assert missing.status_code == 422 and crop.status_code == 422, "approved without a usable sensor size"
    assert ok.status_code == 200, ok.text
    floor = client.get("/v1/pro/me/gear-verifications", headers=_h(pro_id)).json()["floor"]
    assert floor["has_full_frame_body"] is True


def test_approving_can_teach_the_reference_table_so_the_next_photographer_needs_no_review(
    client, db_session, storage, catalogue
):
    first, second = _new_pro(db_session), _new_pro(db_session)
    db_session.query(CameraModelReference).filter_by(normalised_model=normalise_model("Canon EOS R")).delete()
    db_session.commit()
    _submit_frame(client, storage, first, "A.CR3", _fx("canon_eos_r.cr3.head"))
    admin_id = _admin(db_session)
    body = _by_category(_queue(client, admin_id), "camera_body")[0]

    client.post(
        f"/v1/admin/gear-verifications/{body['id']}/approve",
        headers=_h(admin_id),
        json={"sensor_size": "full_frame", "add_to_reference": True},
    )

    learnt = db_session.get(CameraModelReference, normalise_model("Canon EOS R"))
    assert learnt is not None and learnt.sensor_size == SensorSize.full_frame
    # A different photographer, same model, different physical camera: no queue.
    db_session.commit()
    # Different physical body and lens: same models, different serials.
    second_frame = (
        _fx("canon_eos_r.cr3.head").replace(b"033021004689", b"033021000001").replace(b"8500000000", b"8500000001")
    )
    result = _submit_frame(client, storage, second, "B.CR3", second_frame).json()
    assert _by_category(result["items"], "camera_body")[0]["status"] == "verified"


def test_approval_cannot_hand_two_photographers_the_same_serial(client, db_session, storage, catalogue):
    first = _new_pro(db_session)
    _submit_frame(client, storage, first, "A.CR3", _fx("canon_eos_r5.cr3.head"))
    # A second photographer's pending row for the very same serial.
    second = _new_pro(db_session)
    dup = GearVerification(
        pro_user_id=second, category=GearCategory.camera_body, status=VerificationStatus.pending_review,
        make="Canon", model="Canon EOS R5", serial_number="083023000411", review_reason="test",
    )
    db_session.add(dup)
    db_session.commit()
    admin_id = _admin(db_session)

    resp = client.post(
        f"/v1/admin/gear-verifications/{dup.id}/approve", headers=_h(admin_id), json={"sensor_size": "full_frame"}
    )

    assert resp.status_code == 409, resp.text


def test_rejecting_needs_a_reason_and_leaves_the_floor_unmet(client, db_session, storage, catalogue):
    pro_id = _pending_sony(client, db_session, storage)
    admin_id = _admin(db_session)
    body = _by_category(_queue(client, admin_id), "camera_body")[0]

    without = client.post(f"/v1/admin/gear-verifications/{body['id']}/reject", headers=_h(admin_id), json={})
    # Present but blank: the schema lets this through, so it is the service that must refuse it.
    blank = client.post(
        f"/v1/admin/gear-verifications/{body['id']}/reject", headers=_h(admin_id), json={"reason": "   "}
    )
    ok = client.post(
        f"/v1/admin/gear-verifications/{body['id']}/reject",
        headers=_h(admin_id),
        json={"reason": "Serial does not match the box photo"},
    )

    assert without.status_code == 422
    assert blank.status_code == 422, "a rejection with no reason the photographer could read was accepted"
    assert ok.status_code == 200, ok.text
    mine = client.get("/v1/pro/me/gear-verifications", headers=_h(pro_id)).json()
    rejected = _by_category(mine["items"], "camera_body")[0]
    assert rejected["status"] == "rejected" and "box photo" in rejected["review_reason"]
    assert mine["floor"]["has_full_frame_body"] is False


def test_a_decision_can_only_be_made_once(client, db_session, storage, catalogue):
    _pending_sony(client, db_session, storage)
    admin_id = _admin(db_session)
    body = _by_category(_queue(client, admin_id), "camera_body")[0]
    assert client.post(f"/v1/admin/gear-verifications/{body['id']}/approve", headers=_h(admin_id), json={}).status_code == 200

    again = client.post(f"/v1/admin/gear-verifications/{body['id']}/reject", headers=_h(admin_id), json={"reason": "x"})

    assert again.status_code == 409, again.text


def test_a_lens_of_unknown_aperture_needs_an_aperture_type_to_be_approved(client, db_session, storage, catalogue):
    """A Canon zoom writes 0 for its aperture: unknown, so a human decides."""
    pro_id = _new_pro(db_session)
    frame = _zoom_frame()
    _submit_frame(client, storage, pro_id, "zoom.jpg", frame)
    admin_id = _admin(db_session)
    lens = _by_category(_queue(client, admin_id), "lens")[0]

    missing = client.post(f"/v1/admin/gear-verifications/{lens['id']}/approve", headers=_h(admin_id), json={})
    variable = client.post(
        f"/v1/admin/gear-verifications/{lens['id']}/approve", headers=_h(admin_id), json={"aperture_type": "variable_zoom"}
    )
    ok = client.post(
        f"/v1/admin/gear-verifications/{lens['id']}/approve", headers=_h(admin_id), json={"aperture_type": "fixed_zoom"}
    )

    assert missing.status_code == 422 and variable.status_code == 422
    # Two different refusals, and each has to be the right one: not knowing the
    # aperture is not the same as knowing it disqualifies.
    assert "prime" in missing.json()["error"]["message"].lower()
    assert "variable" in variable.json()["error"]["message"].lower()
    assert ok.status_code == 200, ok.text


def _zoom_frame() -> bytes:
    import io

    from PIL import Image
    from PIL.TiffImagePlugin import IFDRational

    exif = Image.Exif()
    exif[0x010F], exif[0x0110] = "Canon", "Canon EOS R5"
    exif[0x8769] = {
        0xA431: "083023009999",
        0xA434: "RF24-70mm F2.8 L IS USM",
        0xA432: (IFDRational(24, 1), IFDRational(70, 1), IFDRational(0, 1), IFDRational(0, 1)),
    }
    buffer = io.BytesIO()
    Image.new("RGB", (8, 8)).save(buffer, format="JPEG", exif=exif)
    return buffer.getvalue()


# ---------------------------------------------------------------------------
# The gate the live admin panel actually calls.
#
# The commit that introduced the gear floor said every approval enforced it. The
# combined `POST /admin/pros/{id}/approve` - the one the review panel calls - did
# not, and no test noticed because the only approval tests were for the older
# `/admin/onboarding/pros/{id}/approve`.
# ---------------------------------------------------------------------------


def _fully_ready_pro(db_session, *, status=None):
    """Passes the four content checks, so the only open question is gear."""
    from app.models.booking import ProPackage
    from app.models.client_rewards_pricing import ProExtraImagePrice
    from app.models.launch_ops import ProOnboardingStatus
    from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
    from app.models.niche import Niche, ProNiche

    pro_id = _ready_pro(db_session, with_gear=False, status=status or ProOnboardingStatus.ready_for_review)
    niche = db_session.execute(select(Niche).where(Niche.slug == "portraits")).scalar_one()
    db_session.add(ProNiche(pro_user_id=pro_id, niche_id=niche.id, is_primary=True))
    db_session.add(
        ProPackage(
            pro_user_id=pro_id, niche_id=niche.id, title="Session", duration_minutes=60,
            price=Decimal("5.00"), currency="EUR", included_photos=10,
            extra_photo_price=Decimal("5.00"), proofs_sla_days=3, finals_sla_days=7,
            addons=[], is_active=True,
        )
    )
    db_session.add(ProExtraImagePrice(pro_user_id=pro_id, niche_id=niche.id, configured_unit_price=Decimal("5.00")))
    for _ in range(12):
        db_session.add(
            MediaAsset(
                owner_user_id=pro_id, kind=MediaKind.photo, purpose=MediaPurpose.portfolio_reel,
                provider=MediaProvider.r2, status=MediaStatus.ready, visibility=MediaVisibility.public,
                content_type="image/jpeg", meta={},
            )
        )
    db_session.commit()
    return pro_id


def test_the_combined_admin_approval_refuses_a_photographer_without_gear(client, db_session, catalogue):
    pro_id = _fully_ready_pro(db_session)
    admin_id = _admin(db_session)

    resp = client.post(f"/v1/admin/pros/{pro_id}/approve", headers=_h(admin_id), json={})

    assert resp.status_code == 409, resp.text
    assert "gear" in resp.json()["error"]["message"].lower(), "approved a photographer whose gear was never checked"


def test_the_combined_admin_approval_allows_a_photographer_with_verified_gear(client, db_session, storage, catalogue):
    pro_id = _fully_ready_pro(db_session)
    _submit_frame(client, storage, pro_id, "IMG_0001.CR3", _fx("canon_eos_r5.cr3.head"))
    admin_id = _admin(db_session)

    resp = client.post(f"/v1/admin/pros/{pro_id}/approve", headers=_h(admin_id), json={})

    assert resp.status_code == 200, resp.text


def test_the_review_queue_reports_gear_so_a_reviewer_is_not_told_a_photographer_is_ready(client, db_session, catalogue):
    pro_id = _fully_ready_pro(db_session)
    admin_id = _admin(db_session)

    rows = client.get("/v1/admin/pros/review-queue", headers=_h(admin_id)).json()["items"]

    mine = next(r for r in rows if r["pro_user_id"] == str(pro_id))
    assert mine["ready_to_approve"] is False
    assert "gear_verified" in mine["missing"]


def test_verifying_the_last_missing_piece_moves_the_photographer_to_ready_for_review(
    client, db_session, storage, catalogue
):
    """Status only advances when something asks it to. Without this, a
    photographer who finishes gear last stays at kyc_approved and never appears
    in the review queue as ready."""
    from app.models.launch_ops import ProOnboarding, ProOnboardingStatus

    pro_id = _fully_ready_pro(db_session, status=ProOnboardingStatus.kyc_approved)
    assert db_session.get(ProOnboarding, pro_id).status == ProOnboardingStatus.kyc_approved

    _submit_frame(client, storage, pro_id, "IMG_0001.CR3", _fx("canon_eos_r5.cr3.head"))

    db_session.expire_all()
    assert db_session.get(ProOnboarding, pro_id).status == ProOnboardingStatus.ready_for_review


def test_approving_the_last_missing_piece_moves_the_photographer_to_ready_for_review(
    client, db_session, storage, catalogue
):
    from app.models.launch_ops import ProOnboarding, ProOnboardingStatus

    pro_id = _fully_ready_pro(db_session, status=ProOnboardingStatus.kyc_approved)
    _submit_frame(client, storage, pro_id, "DSC.ARW", _fx("sony_ilce7m4.arw.head"))
    db_session.expire_all()
    assert db_session.get(ProOnboarding, pro_id).status == ProOnboardingStatus.kyc_approved, "still waiting on a person"
    admin_id = _admin(db_session)
    for item in _queue(client, admin_id):
        # The Sony body has no serial; its lens is a fixed-aperture zoom or prime read from the file.
        client.post(f"/v1/admin/gear-verifications/{item['id']}/approve", headers=_h(admin_id), json={"aperture_type": "prime"} if item["category"] == "lens" else {})

    db_session.expire_all()
    assert db_session.get(ProOnboarding, pro_id).status == ProOnboardingStatus.ready_for_review
