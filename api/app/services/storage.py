from __future__ import annotations

import io
from datetime import datetime
from functools import lru_cache
from uuid import uuid4

import boto3
from botocore.client import BaseClient
from botocore.exceptions import ClientError

from app.core.config import get_settings

settings = get_settings()


@lru_cache(maxsize=1)
def get_s3_client() -> BaseClient:
    # Cached because constructing a boto3 client is not cheap - botocore loads
    # and parses the service model on every construction. That was tolerable
    # when the only callers were one-per-request upload endpoints, but signing
    # a page of discover thumbnails calls this once per image. Clients are safe
    # to share across the threadpool; only session construction is not.
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


def object_exists(storage_key: str) -> bool:
    client = get_s3_client()
    try:
        client.head_object(Bucket=settings.r2_bucket, Key=storage_key)
        return True
    except ClientError as exc:
        if exc.response.get("Error", {}).get("Code") in {"404", "NoSuchKey", "NotFound"}:
            return False
        raise


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


def object_size(storage_key: str) -> int | None:
    """The size of what is actually in the bucket, or None if nothing is.

    Used where a client-reported size cannot be trusted: a presigned PUT does
    not bound what gets uploaded, so the only real number is the object's own.
    """
    client = get_s3_client()
    try:
        return int(client.head_object(Bucket=settings.r2_bucket, Key=storage_key)["ContentLength"])
    except ClientError as exc:
        if exc.response.get("Error", {}).get("Code") in {"404", "NoSuchKey", "NotFound"}:
            return None
        raise


def download_object_range(storage_key: str, start: int, length: int) -> bytes:
    """A slice of an object, without reading the rest.

    A RAW's metadata is in its first few dozen kilobytes; fetching the other
    fifty megabytes to read it would be the whole cost of the request.
    """
    client = get_s3_client()
    response = client.get_object(
        Bucket=settings.r2_bucket, Key=storage_key, Range=f"bytes={start}-{start + length - 1}"
    )
    return response["Body"].read()


def delete_object(storage_key: str) -> None:
    client = get_s3_client()
    client.delete_object(Bucket=settings.r2_bucket, Key=storage_key)


def upload_object_bytes(storage_key: str, payload: bytes, content_type: str = "image/jpeg") -> None:
    client = get_s3_client()
    client.put_object(Bucket=settings.r2_bucket, Key=storage_key, Body=payload, ContentType=content_type)
