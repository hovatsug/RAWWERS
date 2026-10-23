"""Load chosen niche banners through the admin upload service.

Not a separate path: each image is started, PUT to its presigned URL, completed
and attached exactly as the admin page does it, with its stock source record.
Images come from the Pexels page the candidate was chosen on, downloaded once
and stored in our bucket - never hotlinked. No image file is kept in this repo.

    picks.json   {"weddings": "B", "food": "text", ...}   (a letter, or "text" for Text only)
    candidates   the candidates.json written beside the contact sheet

    docker compose run --rm -v ~/RAWWERS-niche-banners:/nb api \
        python scripts/load_niche_banners.py /nb/picks.json /nb/candidates.json --admin-email admin@rawwers.dev [--apply]

Dry run unless --apply: says what it would do and touches nothing.
"""
from __future__ import annotations

import argparse
import json
import sys
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import app.db.base  # noqa: E402,F401 - every model registered
from sqlalchemy import select  # noqa: E402

from app.db.session import SessionLocal  # noqa: E402
from app.models.admin import UserAccount  # noqa: E402
from app.models.niche import Niche  # noqa: E402
from app.services import niche_banners  # noqa: E402

#: Pexels serves a resized JPEG from the original's URL; wide enough for the
#: hero, well under the upload cap.
DOWNLOAD_WIDTH = 3200
LICENCE = "Pexels licence (https://www.pexels.com/license/)"


def download(url: str) -> bytes:
    sized = f"{url}?auto=compress&cs=tinysrgb&fm=jpg&w={DOWNLOAD_WIDTH}"
    req = urllib.request.Request(sized, headers={"User-Agent": "rawwers-banner-loader/1"})
    with urllib.request.urlopen(req, timeout=120) as r:
        return r.read()


def put(url: str, headers: dict, payload: bytes) -> None:
    req = urllib.request.Request(url, data=payload, method="PUT", headers=headers)
    with urllib.request.urlopen(req, timeout=120) as r:
        if r.status >= 300:
            raise RuntimeError(f"upload refused: {r.status}")


def plan(picks: dict, candidates: dict) -> list[tuple[str, str, dict | None]]:
    """(slug, "image" | "text", candidate) per pick; refuses anything unknown."""
    steps = []
    for slug, choice in picks.items():
        if slug not in candidates:
            raise SystemExit(f"{slug}: no candidates for this niche")
        if str(choice).strip().lower() in ("text", "text only"):
            steps.append((slug, "text", None))
            continue
        match = [c for c in candidates[slug] if c["choice"].split()[-1].upper() == str(choice).strip().upper()]
        if not match:
            raise SystemExit(f"{slug}: no candidate {choice!r}")
        steps.append((slug, "image", match[0]))
    return steps


def load(db, steps, *, admin_user_id, apply: bool, fetch=download, send=put) -> list[str]:
    lines = []
    for slug, kind, cand in steps:
        niche = db.execute(select(Niche).where(Niche.slug == slug)).scalar_one_or_none()
        if niche is None:
            raise SystemExit(f"{slug}: no such niche")
        if kind == "text":
            lines.append(f"{slug}: Text only")
            if apply:
                niche_banners.update_niche(db, niche, admin_user_id=admin_user_id, changes={"banner_style": "text"})
            continue
        lines.append(f"{slug}: {cand['choice']} - Pexels {cand['pexels_id']} by {cand['photographer']}")
        if not apply:
            continue
        started = niche_banners.start_upload(db, admin_user_id=admin_user_id, content_type="image/jpeg", file_name=f"{slug}-banner.jpg")
        send(started.upload.url, started.upload.headers, fetch(cand["original"]))
        done = niche_banners.complete_upload(db, media_asset_id=started.media_asset_id)
        niche_banners.set_banner(
            db, niche, admin_user_id=admin_user_id, media_asset_id=done.media_asset_id,
            alt_text=(cand.get("pexels_alt") or f"{niche.name} photography").strip(), focal_x=0.5, focal_y=0.5,
            source="stock", credit=cand["photographer"], licence=LICENCE, source_url=cand["pexels_page"],
        )
        if niche.banner_style != "image":
            niche_banners.update_niche(db, niche, admin_user_id=admin_user_id, changes={"banner_style": "image"})
        for warning in done.warnings:
            lines.append(f"  warning: {warning}")
    return lines


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("picks")
    parser.add_argument("candidates")
    parser.add_argument("--admin-email", required=True)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    steps = plan(json.loads(Path(args.picks).read_text()), json.loads(Path(args.candidates).read_text()))
    with SessionLocal() as db:
        admin = db.execute(select(UserAccount).where(UserAccount.email == args.admin_email)).scalar_one_or_none()
        if admin is None:
            raise SystemExit(f"no account {args.admin_email}")
        for line in load(db, steps, admin_user_id=admin.user_id, apply=args.apply):
            print(line)
    print("applied" if args.apply else "dry run - nothing changed; add --apply")


if __name__ == "__main__":
    main()
