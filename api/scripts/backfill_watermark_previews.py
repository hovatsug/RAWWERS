"""Re-render watermarked previews that were written before they were downscaled.

Every preview produced before the WATERMARK_PREVIEW_MAX_PX change was written
at the original's full size and carried only a corner mark, so what a client
browsed before paying was a near-original. Fixing the pipeline does not fix
what is already in the bucket; this rewrites those objects.

WHAT IS AND IS NOT REVERSIBLE
-----------------------------
Overwriting an oversized preview is *intended* loss: a 4288px image with a
crop-away corner label should not exist, and the replacement is regenerated
from the original at any time. That part is safe to lose.

Overwriting an **original** is not recoverable, and the schema puts that one
step away: `_upsert_derivative` stores the `full_res` derivative under the
original's own storage key, so a full_res row and an original MediaObject
share a key (116 of 116 in dev). If this script's filter ever widened, or a
preview row ever carried such a key, it would destroy the photographer's
master file. `_protected_keys()` therefore builds the set of every original
and full_res key up front and refuses to write to any of them, regardless of
what the query returned. The check is structural, not a comment.

Regenerating from a missing source is handled by skipping: a row whose
original is absent or undownloadable is reported and left exactly as it is,
never partially written.

Default is a dry run that reports every row it would touch, the source it
would rebuild from, and what it would become. Nothing is written without
--apply.

    docker compose exec api python scripts/backfill_watermark_previews.py
    docker compose exec api python scripts/backfill_watermark_previews.py --apply
"""
from __future__ import annotations

import argparse
import io
import sys

from PIL import Image
from sqlalchemy import select

from app.db.session import SessionLocal
from app.models.media import MediaAsset, MediaObject, MediaVariant, ObjectStatus
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
from app.services.storage import download_object_bytes, upload_object_bytes
from app.tasks.media_tasks import WATERMARK_PREVIEW_MAX_PX, watermarked_preview


def _protected_keys(db) -> set[str]:
    """Keys that must never be written: originals, and the full_res
    derivatives that share their storage key with one."""
    originals = db.execute(
        select(MediaObject.storage_key).where(MediaObject.variant == MediaVariant.original)
    ).scalars().all()
    full_res = db.execute(
        select(MediaDerivative.storage_key).where(MediaDerivative.kind == MediaDerivativeKind.full_res)
    ).scalars().all()
    return set(originals) | set(full_res)


def _original_for(db, asset_id) -> MediaObject | None:
    return db.execute(
        select(MediaObject).where(
            MediaObject.media_asset_id == asset_id,
            MediaObject.variant == MediaVariant.original,
            MediaObject.status == ObjectStatus.ready,
        )
    ).scalar_one_or_none()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="actually overwrite (default: report only)")
    args = parser.parse_args()

    db = SessionLocal()
    try:
        protected = _protected_keys(db)
        print(f"protected keys (originals + full_res): {len(protected)}\n")

        targets = [
            (row, False)
            for row in db.execute(
                select(MediaObject).where(
                    MediaObject.variant == MediaVariant.watermark_preview,
                    MediaObject.status == ObjectStatus.ready,
                    MediaObject.width > WATERMARK_PREVIEW_MAX_PX,
                )
            ).scalars().all()
        ] + [
            (row, True)
            for row in db.execute(
                select(MediaDerivative).where(
                    MediaDerivative.kind == MediaDerivativeKind.preview_watermarked,
                    MediaDerivative.width > WATERMARK_PREVIEW_MAX_PX,
                )
            ).scalars().all()
        ]

        if not targets:
            print("nothing over the size limit - nothing to do")
            return 0

        planned, blocked, skipped = [], [], []
        for row, include_footer in targets:
            label = f"{row.storage_key} ({row.width}x{row.height})"
            if row.storage_key in protected:
                blocked.append(f"{label}: key belongs to an original or full_res - REFUSING")
                continue
            asset = db.get(MediaAsset, row.media_asset_id)
            if not asset:
                skipped.append(f"{label}: asset row missing")
                continue
            original = _original_for(db, row.media_asset_id)
            if not original:
                skipped.append(f"{label}: no ready original to rebuild from")
                continue
            planned.append((row, include_footer, asset, original, label))

        print(f"would rewrite : {len(planned)}")
        for _, footer, _, original, label in planned:
            print(f"    {label}  <- {original.storage_key}{'  [+footer]' if footer else ''}")
        if skipped:
            print(f"\nwould skip    : {len(skipped)}")
            for line in skipped:
                print(f"    {line}")
        if blocked:
            print(f"\nBLOCKED       : {len(blocked)}")
            for line in blocked:
                print(f"    {line}")

        if not args.apply:
            print("\nreport only - nothing written. Pass --apply to rewrite.")
            return 0

        print(f"\napplying to {len(planned)} objects...")
        rewritten = 0
        for row, include_footer, asset, original, label in planned:
            try:
                source = Image.open(io.BytesIO(download_object_bytes(original.storage_key))).convert("RGB")
            except Exception as exc:
                print(f"    skip {label}: could not read source ({exc})")
                continue

            rendered = watermarked_preview(db, asset, source, include_powered_by=include_footer)
            buffer = io.BytesIO()
            rendered.save(buffer, format="JPEG", quality=85)
            payload = buffer.getvalue()

            # Re-checked at the point of writing, not only at planning time.
            if row.storage_key in protected:
                print(f"    REFUSING {label}: protected key")
                continue
            upload_object_bytes(row.storage_key, payload, content_type="image/jpeg")

            row.width, row.height = rendered.width, rendered.height
            # MediaDerivative records the size in a column named `bytes`;
            # MediaObject has no size column at all. Set it explicitly rather
            # than by duck-typing - `hasattr(row, "bytes_size")` was false for
            # both (the name belongs to _upsert_derivative's parameter, not to
            # either model), so the derivative's size was silently left stale.
            if isinstance(row, MediaDerivative):
                row.bytes = len(payload)
            rewritten += 1
            print(f"    rewrote {label} -> {rendered.width}x{rendered.height}")

        db.commit()
        print(f"\ndone: {rewritten} rewritten, {len(planned) - rewritten} left unchanged")
        return 0
    finally:
        db.close()


if __name__ == "__main__":
    sys.exit(main())
