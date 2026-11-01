"""Uploads started and never finished are removed after about a day.

Owner's decision 4 (2026-11-01): a job removes uploads left unfinished for
about 24 hours, on top of the storage rule that aborts unfinished multipart
uploads after a day (docs/DEPLOY_CHECKLIST.md). An export killed half way,
or a phone that lost its connection, leaves a photo waiting for bytes that
will never come; it holds the file's place (the same file to the same
gallery is "already there") and, in parts, storage the bucket pays for.

What must hold: only photos still waiting for their bytes, untouched for
the whole period; the parts are aborted and whatever arrived is deleted;
the same file can then be sent again; a storage error leaves the photo for
the next run instead of losing track of it.

Storage is a fake: no network in tests.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from sqlalchemy import select

import app.services.unfinished_uploads as unfinished
from app.core.config import get_settings
from app.models.media import (
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
from app.tasks.celery_app import celery_app
from tests.test_delivery_gigs import _gig, _pro, _start, _token

NOW = datetime(2026, 11, 1, 12, 0, tzinfo=timezone.utc)


@pytest.fixture
def storage(monkeypatch):
    calls = {"aborted": [], "deleted": [], "fail": set()}

    def abort(key, upload_id):
        if key in calls["fail"]:
            raise RuntimeError("storage is down")
        calls["aborted"].append((key, upload_id))

    def delete(key):
        if key in calls["fail"]:
            raise RuntimeError("storage is down")
        calls["deleted"].append(key)

    monkeypatch.setattr(unfinished, "abort_multipart_upload", abort)
    monkeypatch.setattr(unfinished, "delete_object", delete)
    return calls


def _upload(db_session, *, status=MediaStatus.uploading, idle=timedelta(hours=25), multipart=False, kind=MediaKind.photo,
            purpose=MediaPurpose.proof):
    touched = NOW - idle
    meta = {"file_name": "IMG_1.jpg"}
    if multipart:
        meta["multipart"] = {"upload_id": f"up-{uuid.uuid4().hex}", "byte_size": 40_000_000, "part_size": 16_777_216, "part_count": 3}
    asset = MediaAsset(
        owner_user_id=uuid.uuid4(),
        kind=kind,
        purpose=purpose,
        provider=MediaProvider.r2,
        status=status,
        visibility=MediaVisibility.client_only,
        content_type="image/jpeg",
        checksum="cd" * 32,
        meta=meta,
        created_at=touched,
        updated_at=touched,
    )
    db_session.add(asset)
    db_session.flush()
    key = f"users/{asset.owner_user_id}/photos/{asset.id}.jpg"
    db_session.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.original, storage_key=key, status=ObjectStatus.created))
    db_session.commit()
    return asset.id, key


def _run(db_session):
    removed = unfinished.remove_unfinished_uploads(db_session, now=NOW)
    db_session.commit()
    db_session.expire_all()
    return removed


def _original(db_session, asset_id):
    return db_session.execute(
        select(MediaObject).where(MediaObject.media_asset_id == asset_id, MediaObject.variant == MediaVariant.original)
    ).scalar_one()


def test_an_upload_left_unfinished_for_a_day_is_removed(db_session, storage):
    asset_id, key = _upload(db_session)

    assert _run(db_session) == 1

    asset = db_session.get(MediaAsset, asset_id)
    assert asset.status == MediaStatus.deleted
    assert asset.meta["removed"] == "unfinished_upload"
    assert _original(db_session, asset_id).status == ObjectStatus.failed
    assert storage["deleted"] == [key]


def test_its_parts_are_aborted_so_storage_stops_keeping_them(db_session, storage):
    asset_id, key = _upload(db_session, multipart=True)
    upload_id = db_session.get(MediaAsset, asset_id).meta["multipart"]["upload_id"]

    _run(db_session)

    assert storage["aborted"] == [(key, upload_id)]
    assert "multipart" not in db_session.get(MediaAsset, asset_id).meta


def test_an_upload_touched_within_the_day_is_left_alone(db_session, storage):
    asset_id, _key = _upload(db_session, idle=timedelta(hours=23))

    assert _run(db_session) == 0
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.uploading
    assert storage["deleted"] == [] and storage["aborted"] == []


@pytest.mark.parametrize("status", [MediaStatus.processing, MediaStatus.ready, MediaStatus.failed, MediaStatus.deleted])
def test_a_photo_whose_bytes_arrived_is_never_touched(db_session, storage, status):
    asset_id, _key = _upload(db_session, status=status, idle=timedelta(days=30))

    assert _run(db_session) == 0
    assert db_session.get(MediaAsset, asset_id).status == status
    assert storage["deleted"] == []


def test_a_photo_created_but_never_sent_is_removed_too(db_session, storage):
    asset_id, _key = _upload(db_session, status=MediaStatus.created)

    assert _run(db_session) == 1
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.deleted


def test_a_video_is_not_this_jobs_business(db_session, storage):
    asset_id, _key = _upload(db_session, kind=MediaKind.video)

    assert _run(db_session) == 0
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.uploading


def test_a_storage_error_leaves_the_photo_for_the_next_run(db_session, storage):
    broken_id, broken_key = _upload(db_session)
    fine_id, _ = _upload(db_session)
    storage["fail"].add(broken_key)

    assert _run(db_session) == 1

    assert db_session.get(MediaAsset, broken_id).status == MediaStatus.uploading
    assert db_session.get(MediaAsset, fine_id).status == MediaStatus.deleted
    storage["fail"].clear()
    assert _run(db_session) == 1
    assert db_session.get(MediaAsset, broken_id).status == MediaStatus.deleted


def test_one_run_takes_a_bounded_batch(db_session, storage):
    ids = [_upload(db_session)[0] for _ in range(3)]

    assert unfinished.remove_unfinished_uploads(db_session, now=NOW, limit=2) == 2
    db_session.commit()
    db_session.expire_all()
    assert sorted(db_session.get(MediaAsset, i).status.value for i in ids) == ["deleted", "deleted", "uploading"]


def test_the_period_is_a_day_and_a_setting():
    assert get_settings().unfinished_upload_max_age_hours == 24


def test_the_job_runs_every_hour_on_the_general_queue():
    entry = celery_app.conf.beat_schedule["remove-unfinished-uploads"]
    assert entry["task"] == "app.tasks.scheduled.remove_unfinished_uploads"
    assert entry["schedule"] == timedelta(hours=1)
    assert celery_app.conf.task_routes["app.tasks.scheduled.remove_unfinished_uploads"] == {"queue": "media"}


def test_the_same_file_can_be_sent_again_once_its_old_start_is_removed(client, db_session, storage, monkeypatch):
    monkeypatch.setattr("app.services.photo_uploads.create_presigned_put", lambda storage_key, content_type, expires_in=900: f"https://r2.invalid/{storage_key}")
    monkeypatch.setattr("app.api.v1.media.create_presigned_put", lambda storage_key, content_type, expires_in=900: f"https://r2.invalid/{storage_key}")
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)
    first = _start(client, token, gig.id).json()
    stale = db_session.get(MediaAsset, uuid.UUID(first["media_asset_id"]))
    stale.updated_at = NOW - timedelta(hours=30)
    db_session.commit()

    _run(db_session)
    again = _start(client, token, gig.id).json()

    assert again["duplicate"] is False and again["media_asset_id"] != first["media_asset_id"]
    assert db_session.get(MediaAsset, uuid.UUID(first["media_asset_id"])).status == MediaStatus.deleted
