"""Mux videos whose webhook never came: the job asks Mux and applies what it
hears through the webhook's own handler (services/mux_sync.py)."""
import uuid
from datetime import datetime, timedelta, timezone

from app.core.config import get_settings
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.services import mux_sync
from app.tasks.celery_app import celery_app

NOW = datetime.now(timezone.utc)
STALE = NOW - timedelta(minutes=get_settings().mux_sync_stale_minutes + 1)


class FakeMux:
    def __init__(self, uploads=None, assets=None, fail=()):
        self.uploads, self.assets, self.fail, self.calls = uploads or {}, assets or {}, set(fail), []

    def get_upload(self, upload_id):
        self.calls.append(("upload", upload_id))
        if upload_id in self.fail:
            raise RuntimeError("mux down")
        return self.uploads.get(upload_id)

    def get_asset(self, asset_id):
        self.calls.append(("asset", asset_id))
        return self.assets.get(asset_id)


def _video(db, *, status=MediaStatus.uploading, asset_id=None, updated=STALE, created=None, kind=MediaKind.video):
    v = MediaAsset(
        owner_user_id=uuid.uuid4(), kind=kind, purpose=MediaPurpose.portfolio_reel, provider=MediaProvider.mux,
        provider_upload_id=f"up_{uuid.uuid4().hex[:8]}", provider_asset_id=asset_id, status=status,
        visibility=MediaVisibility.public, meta={}, created_at=created or updated, updated_at=updated,
    )
    db.add(v)
    db.commit()
    # updated_at has an onupdate; set it after the insert so the row is old.
    db.execute(MediaAsset.__table__.update().where(MediaAsset.id == v.id).values(updated_at=updated, created_at=created or updated))
    db.commit()
    db.refresh(v)
    return v


def _ready(asset_id, upload_id, playback="pb"):
    return {"id": asset_id, "status": "ready", "upload_id": upload_id, "playback_ids": [{"id": playback, "policy": "signed"}]}


def test_a_video_stuck_uploading_becomes_ready_from_mux_s_status(db_session):
    v = _video(db_session)
    fake = FakeMux(
        uploads={v.provider_upload_id: {"id": v.provider_upload_id, "status": "asset_created", "asset_id": "as_1"}},
        assets={"as_1": _ready("as_1", v.provider_upload_id, "pb_1")},
    )
    result = mux_sync.sync_waiting_videos(db_session, client=fake, now=NOW)
    db_session.commit()
    db_session.refresh(v)
    assert (v.status, v.provider_asset_id, v.meta["playback_id"]) == (MediaStatus.ready, "as_1", "pb_1")
    assert result.applied == ["video.upload.asset_created", "video.asset.ready"]


def test_it_uses_the_webhook_s_handler(db_session, monkeypatch):
    seen = []
    monkeypatch.setattr("app.api.v1.webhooks._apply_mux_event", lambda db, t, d: seen.append(t))
    v = _video(db_session, status=MediaStatus.processing, asset_id="as_h")
    mux_sync.sync_waiting_videos(db_session, client=FakeMux(assets={"as_h": _ready("as_h", v.provider_upload_id)}), now=NOW)
    assert seen == ["video.asset.ready"]


def test_errors_and_timeouts_fail_the_video(db_session):
    up_err, up_gone, asset_err = _video(db_session), _video(db_session), _video(db_session, status=MediaStatus.processing, asset_id="as_e")
    fake = FakeMux(
        uploads={
            up_err.provider_upload_id: {"id": up_err.provider_upload_id, "status": "errored", "error": {"message": "Not a video"}},
            up_gone.provider_upload_id: {"id": up_gone.provider_upload_id, "status": "timed_out"},
        },
        assets={"as_e": {"id": "as_e", "status": "errored", "errors": {"type": "invalid_input"}}},
    )
    mux_sync.sync_waiting_videos(db_session, client=fake, now=NOW)
    db_session.commit()
    for v in (up_err, up_gone, asset_err):
        db_session.refresh(v)
        assert v.status == MediaStatus.failed, v.provider_upload_id


def test_a_video_still_on_its_way_is_left_and_asked_again_next_time(db_session):
    v = _video(db_session)
    fake = FakeMux(uploads={v.provider_upload_id: {"id": v.provider_upload_id, "status": "waiting"}})
    mux_sync.sync_waiting_videos(db_session, client=fake, now=NOW)
    db_session.commit()
    db_session.refresh(v)
    assert v.status == MediaStatus.uploading
    assert mux_sync.due_videos(db_session, now=NOW) == [v]


def test_only_stale_young_mux_videos_are_asked_about(db_session):
    asked = _video(db_session)
    _video(db_session, updated=NOW - timedelta(minutes=1))  # its webhook may still come
    _video(db_session, updated=NOW - timedelta(hours=get_settings().mux_sync_max_age_hours + 1))  # given up on
    _video(db_session, status=MediaStatus.ready, asset_id="as_r")  # settled
    assert mux_sync.due_videos(db_session, now=NOW) == [asked]
    fake = FakeMux()
    mux_sync.sync_waiting_videos(db_session, client=fake, now=NOW)
    assert fake.calls == [("upload", asked.provider_upload_id)]


def test_running_it_after_the_webhook_changes_nothing(db_session):
    v = _video(db_session, status=MediaStatus.processing, asset_id="as_w")
    fake = FakeMux(assets={"as_w": _ready("as_w", v.provider_upload_id, "pb_w")})
    mux_sync.sync_waiting_videos(db_session, client=fake, now=NOW)
    db_session.commit()
    db_session.refresh(v)
    before = (v.status, dict(v.meta))
    fake.calls.clear()
    mux_sync.sync_waiting_videos(db_session, client=fake, now=NOW + timedelta(hours=1))
    db_session.commit()
    db_session.refresh(v)
    assert fake.calls == []  # ready: not asked again
    assert (v.status, dict(v.meta)) == before


def test_one_video_failing_to_read_does_not_stop_the_others(db_session):
    broken, fine = _video(db_session), _video(db_session, status=MediaStatus.processing, asset_id="as_f")
    fake = FakeMux(assets={"as_f": _ready("as_f", fine.provider_upload_id)}, fail={broken.provider_upload_id})
    result = mux_sync.sync_waiting_videos(db_session, client=fake, now=NOW)
    db_session.commit()
    db_session.refresh(fine)
    assert result.errors == 1
    assert fine.status == MediaStatus.ready


def test_the_job_is_scheduled_from_its_setting():
    entry = celery_app.conf.beat_schedule["mux-sync"]
    assert entry["task"] == "app.tasks.scheduled.mux_sync"
    assert entry["schedule"] == timedelta(seconds=get_settings().mux_sync_interval_seconds)
    assert celery_app.conf.task_routes["app.tasks.scheduled.mux_sync"] == {"queue": "media"}


def test_the_client_reads_uploads_and_assets_and_treats_404_as_gone(monkeypatch):
    from app.services.mux import MuxClient

    class R:
        def __init__(self, code, data=None):
            self.status_code, self._data = code, data

        def json(self):
            return {"data": self._data}

    urls = []

    def fake_get(url, auth=None, timeout=None):
        urls.append(url)
        return R(404) if url.endswith("/gone") else R(200, {"id": url.rsplit("/", 1)[1]})

    monkeypatch.setattr("app.services.mux.requests.get", fake_get)
    c = MuxClient()
    assert c.get_upload("up_1") == {"id": "up_1"}
    assert c.get_asset("as_1") == {"id": "as_1"}
    assert c.get_asset("gone") is None
    assert urls == ["https://api.mux.com/video/v1/uploads/up_1", "https://api.mux.com/video/v1/assets/as_1", "https://api.mux.com/video/v1/assets/gone"]
