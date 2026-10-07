"""Large originals in parts, and retries that do not leave orphans.

R2's own behaviour - presigned part uploads, list_parts, complete - was
verified against the real bucket; these replace it with an in-memory store
and test the rules this API adds on top: who may do what, when, and that
what gets assembled is exactly the file that was declared.
"""
import uuid

import pytest
from app.models.media import MediaAsset, MediaStatus
from sqlalchemy import select

MiB = 1024 * 1024
PART = 5 * MiB


class FakeR2:
    def __init__(self):
        self.uploads: dict[str, dict] = {}  # upload_id -> {key, parts: {n: size}}
        self.completed: list[tuple[str, list]] = []
        self.aborted: list[str] = []

    def create(self, key, content_type):
        upload_id = f"up-{len(self.uploads) + 1}"
        self.uploads[upload_id] = {"key": key, "parts": {}}
        return upload_id

    def part_url(self, key, upload_id, n, expires_in=900):
        return f"https://r2.invalid/{key}?uploadId={upload_id}&partNumber={n}"

    def listed(self, key, upload_id):
        return [{"part_number": n, "size": size, "etag": f'"etag-{n}"'} for n, size in sorted(self.uploads[upload_id]["parts"].items())]

    def complete(self, key, upload_id, parts):
        self.completed.append((upload_id, parts))

    def abort(self, key, upload_id):
        self.aborted.append(upload_id)

    def receive(self, upload_id, n, size):
        """A part arriving at R2 from the phone."""
        self.uploads[upload_id]["parts"][n] = size


@pytest.fixture
def r2(monkeypatch):
    fake = FakeR2()
    for name, fn in [
        ("create_multipart_upload", fake.create),
        ("create_presigned_upload_part", fake.part_url),
        ("list_uploaded_parts", fake.listed),
        ("complete_multipart_upload", fake.complete),
        ("abort_multipart_upload", fake.abort),
        ("create_presigned_put", lambda storage_key, content_type: f"https://r2.invalid/{storage_key}?sig={uuid.uuid4().hex}"),
    ]:
        monkeypatch.setattr(f"app.api.v1.media.{name}", fn)
    monkeypatch.setattr("app.api.v1.media.process_photo_variants.delay", lambda *_a, **_k: None)
    return fake


def _h(user_id):
    return {"X-User-Id": user_id}


def _create(client, user_id, purpose="gear_evidence"):
    body = {"purpose": purpose, "content_type": "application/octet-stream" if purpose == "gear_evidence" else "image/jpeg"}
    body["file_name"] = "DSC0001.ARW" if purpose == "gear_evidence" else "IMG_0001.jpg"
    resp = client.post("/v1/media/photos/uploads", headers=_h(user_id), json=body)
    assert resp.status_code == 200, resp.text
    return resp.json()


def _start(client, user_id, asset_id, size):
    return client.post(f"/v1/media/photos/{asset_id}/multipart", headers=_h(user_id), json={"byte_size": size})


def _upload_id(db_session, asset_id):
    db_session.expire_all()
    return db_session.get(MediaAsset, uuid.UUID(asset_id)).meta["multipart"]["upload_id"]


# ---------------------------------------------------------------------------
# Retries reuse the asset.
# ---------------------------------------------------------------------------


def test_a_retry_gets_a_fresh_url_for_the_same_asset(client, db_session, r2):
    user = str(uuid.uuid4())
    created = _create(client, user, purpose="proof")

    retry = client.post(f"/v1/media/photos/{created['media_asset_id']}/upload-url", headers=_h(user))

    assert retry.status_code == 200, retry.text
    assert retry.json()["storage_key"] == created["upload"]["storage_key"], "the same object, not a new asset"
    assert retry.json()["url"] != created["upload"]["url"], "a used presigned URL is never handed out again"
    assert db_session.execute(select(MediaAsset).where(MediaAsset.owner_user_id == uuid.UUID(user))).scalars().all().__len__() == 1


def test_no_fresh_url_once_the_upload_is_complete_or_for_someone_else(client, db_session, r2):
    user = str(uuid.uuid4())
    created = _create(client, user, purpose="proof")
    asset_id = created["media_asset_id"]

    assert client.post(f"/v1/media/photos/{asset_id}/upload-url", headers=_h(str(uuid.uuid4()))).status_code == 403
    assert client.post(f"/v1/media/photos/{asset_id}/complete", headers=_h(user), json={"byte_size": 10}).status_code == 200
    assert client.post(f"/v1/media/photos/{asset_id}/upload-url", headers=_h(user)).status_code == 409


# ---------------------------------------------------------------------------
# Parts, and resuming.
# ---------------------------------------------------------------------------


def test_a_58_mb_raw_is_laid_out_in_5_mib_parts(client, db_session, r2):
    user = str(uuid.uuid4())
    asset_id = _create(client, user)["media_asset_id"]

    resp = _start(client, user, asset_id, 58 * MiB)

    assert resp.status_code == 200, resp.text
    assert resp.json() == {"part_size": PART, "part_count": 12}


def test_starting_again_resumes_instead_of_starting_over(client, db_session, r2):
    """What the app does after a dropped connection: start, then ask what arrived."""
    user = str(uuid.uuid4())
    asset_id = _create(client, user)["media_asset_id"]
    _start(client, user, asset_id, 12 * MiB)
    upload_id = _upload_id(db_session, asset_id)
    r2.receive(upload_id, 1, PART)
    r2.receive(upload_id, 2, PART)  # then the connection drops

    again = _start(client, user, asset_id, 12 * MiB)
    held = client.get(f"/v1/media/photos/{asset_id}/multipart/parts", headers=_h(user)).json()

    assert again.json() == {"part_size": PART, "part_count": 3}
    assert _upload_id(db_session, asset_id) == upload_id, "the same upload - the parts already sent are kept"
    assert [p["part_number"] for p in held["parts"]] == [1, 2], "the client sends only part 3"
    assert r2.aborted == []


def test_a_different_file_on_the_same_asset_starts_clean(client, db_session, r2):
    user = str(uuid.uuid4())
    asset_id = _create(client, user)["media_asset_id"]
    _start(client, user, asset_id, 12 * MiB)
    first = _upload_id(db_session, asset_id)

    _start(client, user, asset_id, 30 * MiB)

    assert r2.aborted == [first]
    assert _upload_id(db_session, asset_id) != first


def test_part_urls_only_for_parts_of_this_file(client, db_session, r2):
    user = str(uuid.uuid4())
    asset_id = _create(client, user)["media_asset_id"]
    _start(client, user, asset_id, 12 * MiB)

    ok = client.post(f"/v1/media/photos/{asset_id}/multipart/part-urls", headers=_h(user), json={"part_numbers": [3, 1]})
    bad = client.post(f"/v1/media/photos/{asset_id}/multipart/part-urls", headers=_h(user), json={"part_numbers": [4]})

    assert [p["part_number"] for p in ok.json()["parts"]] == [1, 3]
    assert bad.status_code == 422


# ---------------------------------------------------------------------------
# Completing: exactly the declared file, then the ordinary /complete.
# ---------------------------------------------------------------------------


def test_completing_with_a_part_missing_is_refused_and_names_it(client, db_session, r2):
    user = str(uuid.uuid4())
    asset_id = _create(client, user)["media_asset_id"]
    _start(client, user, asset_id, 12 * MiB)
    upload_id = _upload_id(db_session, asset_id)
    r2.receive(upload_id, 1, PART)
    r2.receive(upload_id, 3, 2 * MiB)

    resp = client.post(f"/v1/media/photos/{asset_id}/multipart/complete", headers=_h(user))

    assert resp.status_code == 422
    assert resp.json()["error"]["details"]["missing_parts"] == [2]
    assert r2.completed == []


def test_a_part_of_the_wrong_size_is_refused(client, db_session, r2):
    """The declared size is what /complete's size limits are judged on, so
    the assembled file has to be that size - not a padded or truncated one."""
    user = str(uuid.uuid4())
    asset_id = _create(client, user)["media_asset_id"]
    _start(client, user, asset_id, 12 * MiB)
    upload_id = _upload_id(db_session, asset_id)
    r2.receive(upload_id, 1, PART)
    r2.receive(upload_id, 2, PART)
    r2.receive(upload_id, 3, 9 * MiB)  # last part should be 2 MiB

    resp = client.post(f"/v1/media/photos/{asset_id}/multipart/complete", headers=_h(user))

    assert resp.status_code == 422
    assert resp.json()["error"]["details"]["wrong_parts"] == [3]


def test_a_whole_file_is_assembled_from_r2s_own_list_and_then_completes_as_usual(client, db_session, r2):
    user = str(uuid.uuid4())
    asset_id = _create(client, user, purpose="proof")["media_asset_id"]
    _start(client, user, asset_id, 12 * MiB)
    upload_id = _upload_id(db_session, asset_id)
    for n, size in [(1, PART), (2, PART), (3, 2 * MiB)]:
        r2.receive(upload_id, n, size)

    assembled = client.post(f"/v1/media/photos/{asset_id}/multipart/complete", headers=_h(user))
    completed = client.post(f"/v1/media/photos/{asset_id}/complete", headers=_h(user), json={"byte_size": 12 * MiB})

    assert assembled.status_code == 200, assembled.text
    assert r2.completed == [(upload_id, [(1, '"etag-1"'), (2, '"etag-2"'), (3, '"etag-3"')])]
    assert completed.status_code == 200, completed.text
    db_session.expire_all()
    asset = db_session.get(MediaAsset, uuid.UUID(asset_id))
    assert asset.status == MediaStatus.processing
    assert "multipart" not in asset.meta


def test_size_limits_follow_the_purpose(client, db_session, r2):
    user = str(uuid.uuid4())
    raw = _create(client, user)["media_asset_id"]
    photo = _create(client, user, purpose="proof")["media_asset_id"]

    assert _start(client, user, raw, 140 * MiB).status_code == 200, "a big RAW is what gear evidence is"
    assert _start(client, user, raw, 151 * 1000 * 1000).status_code == 422
    assert _start(client, user, photo, 26 * 1000 * 1000).status_code == 422, "a photo keeps the photo limit"


def test_only_the_owner_can_touch_the_parts(client, db_session, r2):
    user, other = str(uuid.uuid4()), str(uuid.uuid4())
    asset_id = _create(client, user)["media_asset_id"]
    _start(client, user, asset_id, 12 * MiB)

    assert _start(client, other, asset_id, 12 * MiB).status_code == 403
    assert client.get(f"/v1/media/photos/{asset_id}/multipart/parts", headers=_h(other)).status_code == 403
    assert client.post(f"/v1/media/photos/{asset_id}/multipart/part-urls", headers=_h(other), json={"part_numbers": [1]}).status_code == 403
    assert client.post(f"/v1/media/photos/{asset_id}/multipart/complete", headers=_h(other)).status_code == 403


def test_abort_lets_r2_drop_the_parts(client, db_session, r2):
    user = str(uuid.uuid4())
    asset_id = _create(client, user)["media_asset_id"]
    _start(client, user, asset_id, 12 * MiB)
    upload_id = _upload_id(db_session, asset_id)

    assert client.post(f"/v1/media/photos/{asset_id}/multipart/abort", headers=_h(user)).status_code == 200
    assert r2.aborted == [upload_id]
    assert client.get(f"/v1/media/photos/{asset_id}/multipart/parts", headers=_h(user)).status_code == 409
