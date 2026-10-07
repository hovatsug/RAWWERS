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


#: Derivatives do not change once made, so whoever holds one may keep it for
#: 30 days. Not `immutable`: re-running derivative generation writes the same
#: key, rarely.
_DERIVATIVE_MAX_AGE = 2592000


def derivative_cache_control(visibility) -> str:
    """`public` only for a photo anyone may see (portfolio work); `private`
    for everything else - a client's proofs, and above all `web_res`, the
    unwatermarked copy released only once paid for. `private` still lets the
    viewer's own device keep it; it forbids any shared cache from doing so.
    Decided from the photo, not the derivative kind, so a new derivative
    cannot be made public by default."""
    from app.models.media import MediaVisibility

    scope = "public" if visibility == MediaVisibility.public else "private"
    return f"{scope}, max-age={_DERIVATIVE_MAX_AGE}"


def upload_object_bytes(
    storage_key: str, payload: bytes, content_type: str = "image/jpeg", cache_control: str | None = None
) -> None:
    client = get_s3_client()
    extra = {"CacheControl": cache_control} if cache_control else {}
    client.put_object(Bucket=settings.r2_bucket, Key=storage_key, Body=payload, ContentType=content_type, **extra)


# ---------------------------------------------------------------------------
# Multipart upload, for large originals.
#
# The client sends a large file in parts, each to its own presigned URL, and
# can ask which parts arrived - so a dropped connection resumes from the last
# part instead of byte zero. R2 implements this part of the S3 API natively
# (create, presigned upload_part, list_parts, complete all verified against
# the real bucket), so no upload server sits in the path: bytes still go
# straight from the phone to R2.
# ---------------------------------------------------------------------------

#: 5 MiB, R2's minimum for every part but the last. A part cannot be resumed
#: partway, so a failure costs the whole part, and on a slow link a big part
#: may never finish: against real R2 at ~10 KB/s up, 8 MiB parts took 14
#: minutes each and the connection was reset before one completed. A 58 MB
#: RAW is 12 parts.
MULTIPART_PART_SIZE = 5 * 1024 * 1024


def create_multipart_upload(storage_key: str, content_type: str) -> str:
    client = get_s3_client()
    return client.create_multipart_upload(Bucket=settings.r2_bucket, Key=storage_key, ContentType=content_type)["UploadId"]


def create_presigned_upload_part(storage_key: str, upload_id: str, part_number: int, expires_in: int = 900) -> str:
    client = get_s3_client()
    return client.generate_presigned_url(
        "upload_part",
        Params={"Bucket": settings.r2_bucket, "Key": storage_key, "UploadId": upload_id, "PartNumber": part_number},
        ExpiresIn=expires_in,
    )


def list_uploaded_parts(storage_key: str, upload_id: str) -> list[dict]:
    """Every part R2 holds for this upload: number, size and ETag."""
    client = get_s3_client()
    parts: list[dict] = []
    marker = 0
    while True:
        page = client.list_parts(
            Bucket=settings.r2_bucket, Key=storage_key, UploadId=upload_id, PartNumberMarker=marker
        )
        parts.extend(
            {"part_number": p["PartNumber"], "size": p["Size"], "etag": p["ETag"]} for p in page.get("Parts", [])
        )
        if not page.get("IsTruncated"):
            return parts
        marker = page["NextPartNumberMarker"]


def complete_multipart_upload(storage_key: str, upload_id: str, parts: list[tuple[int, str]]) -> None:
    client = get_s3_client()
    client.complete_multipart_upload(
        Bucket=settings.r2_bucket,
        Key=storage_key,
        UploadId=upload_id,
        MultipartUpload={"Parts": [{"PartNumber": n, "ETag": etag} for n, etag in sorted(parts)]},
    )


def abort_multipart_upload(storage_key: str, upload_id: str) -> None:
    client = get_s3_client()
    client.abort_multipart_upload(Bucket=settings.r2_bucket, Key=storage_key, UploadId=upload_id)
