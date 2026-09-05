import uuid

from app.models.media import MediaAsset, MediaKind


def test_photo_upload_creation_and_owner_enforcement(client, db_session, user_id, monkeypatch):
    monkeypatch.setattr(
        "app.api.v1.media.create_presigned_put",
        lambda storage_key, content_type: f"https://signed.example/{storage_key}",
    )
    monkeypatch.setattr("app.api.v1.media.process_photo_variants.delay", lambda media_asset_id: None)

    create_resp = client.post(
        "/v1/media/photos/uploads",
        headers={"X-User-Id": user_id},
        json={"purpose": "proof", "content_type": "image/jpeg", "file_name": "test.jpg"},
    )
    assert create_resp.status_code == 200
    payload = create_resp.json()
    media_asset_id = payload["media_asset_id"]

    asset = db_session.get(MediaAsset, uuid.UUID(media_asset_id))
    assert asset is not None
    assert asset.kind == MediaKind.photo

    other_user = str(uuid.uuid4())
    complete_resp = client.post(
        f"/v1/media/photos/{media_asset_id}/complete",
        headers={"X-User-Id": other_user},
        json={"byte_size": 1024},
    )
    assert complete_resp.status_code == 403
