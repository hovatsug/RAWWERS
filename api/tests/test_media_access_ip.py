"""The client's raw IP on their own downloads, kept for a short time, for
chargeback evidence.

Stripe's dispute evidence asks for the customer's IP address
(`customer_purchase_ip`, and in the access log), and a hash cannot be given
to it. So a log row of the gig's own client keeps the raw IP next to the
hash, until MEDIA_ACCESS_RAW_IP_RETENTION_DAYS have passed - unless the
booking has a chargeback whose evidence is still due. Nobody else's raw IP
is kept: not the photographer's, not a share-link visitor's. The hash stays
as before, for everyone.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from app.models.admin import MoneyAttentionItem
from app.models.gallery import ProofGalleryItem
from app.models.media_rights import MediaAccessAction, MediaAccessLog
from app.services.media_rights import hash_ip, log_media_access, purge_raw_access_ips
from tests.test_media_rights import _create_gallery, _create_gig, _create_photo_asset

IP = "203.0.113.7"


def _gig_with_asset(db_session):
    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    gallery = _create_gallery(db_session, gig)
    asset = _create_photo_asset(db_session, pro_id)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=1))
    db_session.commit()
    return gig, asset


def _log(db_session, gig, asset, *, user_id, share_link_id=None, ip=IP):
    log_media_access(
        db_session, gig_id=gig.id, media_asset_id=asset.id, derivative_kind="full_res", action=MediaAccessAction.download,
        user_id=user_id, share_link_id=share_link_id, ip=ip, user_agent="Safari",
    )
    db_session.commit()
    return db_session.query(MediaAccessLog).order_by(MediaAccessLog.created_at.desc()).first()


def test_the_clients_own_download_keeps_the_raw_ip_and_the_hash(db_session):
    gig, asset = _gig_with_asset(db_session)

    row = _log(db_session, gig, asset, user_id=gig.client_user_id)

    assert row.ip_address == IP
    assert row.ip_hash == hash_ip(IP)


def test_the_photographers_access_keeps_only_the_hash(db_session):
    gig, asset = _gig_with_asset(db_session)

    row = _log(db_session, gig, asset, user_id=gig.pro_user_id)

    assert row.ip_address is None
    assert row.ip_hash == hash_ip(IP)


def test_a_share_link_visitor_keeps_only_the_hash(db_session):
    gig, asset = _gig_with_asset(db_session)

    row = _log(db_session, gig, asset, user_id=None)

    assert row.ip_address is None
    assert row.ip_hash == hash_ip(IP)


def test_the_signed_url_route_keeps_the_clients_ip(client, db_session, monkeypatch):
    gig, asset = _gig_with_asset(db_session)
    client.post(f"/v1/proof-galleries/{db_session.query(ProofGalleryItem).first().gallery_id}/publish", headers={"X-User-Id": str(gig.pro_user_id)})
    monkeypatch.setattr("app.api.v1.media_rights.create_presigned_get", lambda key, expires_in=120: f"https://signed/{key}")

    resp = client.get(
        f"/v1/gigs/{gig.id}/media/{asset.id}/signed-url",
        headers={"X-User-Id": str(gig.client_user_id), "X-Forwarded-For": IP},
        params={"kind": "preview_watermarked"},
    )

    assert resp.status_code == 200, resp.text
    row = db_session.query(MediaAccessLog).filter(MediaAccessLog.gig_id == gig.id).one()
    assert row.ip_address == IP
    assert row.ip_hash == hash_ip(IP)


def _aged(db_session, row, days):
    row.created_at = datetime.now(timezone.utc) - timedelta(days=days)
    db_session.commit()


def test_the_raw_ip_is_cleared_after_the_retention_period_and_the_hash_stays(db_session, monkeypatch):
    monkeypatch.setattr("app.services.media_rights.settings.media_access_raw_ip_retention_days", 120)
    gig, asset = _gig_with_asset(db_session)
    old = _log(db_session, gig, asset, user_id=gig.client_user_id)
    _aged(db_session, old, 121)
    recent = _log(db_session, gig, asset, user_id=gig.client_user_id)
    _aged(db_session, recent, 119)

    cleared = purge_raw_access_ips(db_session)
    db_session.commit()

    assert cleared == 1
    db_session.refresh(old)
    db_session.refresh(recent)
    assert old.ip_address is None and old.ip_hash == hash_ip(IP)
    assert recent.ip_address == IP


def test_the_retention_period_is_the_setting(db_session, monkeypatch):
    monkeypatch.setattr("app.services.media_rights.settings.media_access_raw_ip_retention_days", 30)
    gig, asset = _gig_with_asset(db_session)
    row = _log(db_session, gig, asset, user_id=gig.client_user_id)
    _aged(db_session, row, 31)

    assert purge_raw_access_ips(db_session) == 1


def test_an_open_chargeback_keeps_the_raw_ip_until_its_evidence_is_dealt_with(db_session, monkeypatch):
    monkeypatch.setattr("app.services.media_rights.settings.media_access_raw_ip_retention_days", 120)
    gig, asset = _gig_with_asset(db_session)
    row = _log(db_session, gig, asset, user_id=gig.client_user_id)
    _aged(db_session, row, 200)
    item = MoneyAttentionItem(kind="chargeback_evidence_due", status="open", gig_id=gig.id, client_user_id=gig.client_user_id,
                              stripe_dispute_id="dp_1", amount=gig.amount_minimum, currency="EUR", note="")
    db_session.add(item)
    db_session.commit()

    assert purge_raw_access_ips(db_session) == 0
    db_session.refresh(row)
    assert row.ip_address == IP

    item.status = "resolved"
    db_session.commit()
    assert purge_raw_access_ips(db_session) == 1


def test_the_purge_runs_daily_on_beat():
    from app.tasks.celery_app import celery_app

    entries = [e for e in celery_app.conf.beat_schedule.values() if e["task"] == "app.tasks.scheduled.purge_raw_access_ips"]
    assert len(entries) == 1
    assert entries[0]["schedule"] == timedelta(days=1)
