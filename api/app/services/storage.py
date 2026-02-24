from __future__ import annotations

import io
from datetime import datetime
from uuid import uuid4

import boto3
from botocore.client import BaseClient

from app.core.config import get_settings

settings = get_settings()


def get_s3_client() -> BaseClient:
    return boto3.client(
        "s3",
        endpoint_url=settings.r2_endpoint_url,
        aws_access_key_id=settings.r2_access_key_id,
        aws_secret_access_key=settings.r2_secret_access_key,
        region_name=settings.r2_region,
    )


def generate_photo_storage_key(user_id: str, file_name: str | None = None) -> str:
    suffix = file_name.rsplit(".", 1)[-1].lower() if file_name and "." in file_name else "bin"
    date_prefix = datetime.utcnow().strftime("%Y/%m/%d")
    return f"users/{user_id}/photos/{date_prefix}/{uuid4()}.{suffix}"


def generate_variant_key(original_key: str, variant: str, ext: str = "jpg") -> str:
    base = original_key.rsplit(".", 1)[0]
    return f"{base}_{variant}.{ext}"


def create_presigned_put(storage_key: str, content_type: str, expires_in: int = 900) -> str:
    client = get_s3_client()
    return client.generate_presigned_url(
        ClientMethod="put_object",
        Params={
            "Bucket": settings.r2_bucket,
            "Key": storage_key,
            "ContentType": content_type,
        },
        ExpiresIn=expires_in,
    )


def create_presigned_get(storage_key: str, expires_in: int = 900) -> str:
    client = get_s3_client()
    return client.generate_presigned_url(
        ClientMethod="get_object",
        Params={"Bucket": settings.r2_bucket, "Key": storage_key},
        ExpiresIn=expires_in,
    )


def download_object_bytes(storage_key: str, max_bytes: int = 25 * 1024 * 1024) -> bytes:
    client = get_s3_client()
    response = client.get_object(Bucket=settings.r2_bucket, Key=storage_key)
    body = response["Body"]
    stream = io.BytesIO()
    chunk_size = 1024 * 256
    total = 0
    while True:
        chunk = body.read(chunk_size)
        if not chunk:
            break
        total += len(chunk)
        if total > max_bytes:
            raise ValueError("File exceeds size limit")
        stream.write(chunk)
    return stream.getvalue()


def upload_object_bytes(storage_key: str, payload: bytes, content_type: str = "image/jpeg") -> None:
    client = get_s3_client()
    client.put_object(Bucket=settings.r2_bucket, Key=storage_key, Body=payload, ContentType=content_type)
