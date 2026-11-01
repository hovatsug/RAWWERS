"""Dev only: make the Lightroom plug-in's calls against the dev API, without Lightroom.

The same requests, in the same order, as RawwersApi.lua and RawwersUpload.lua:
pair with a code from the pro app, list the gigs, and for each JPEG in a
folder hash it, start it, PUT it (or its parts), finish it - three at a
time, as the plug-in does. Plus the checks the plug-in cannot make on itself.

    python3 -I lightroom/simulate_plugin.py pair --code ABCD-EFGH
    python3 -I lightroom/simulate_plugin.py gigs
    python3 -I lightroom/simulate_plugin.py upload --gig GIG_ID --folder DIR [--stop-after N]
    python3 -I lightroom/simulate_plugin.py status --gallery GALLERY_ID
    python3 -I lightroom/simulate_plugin.py scope         # what the token can and cannot read
    python3 -I lightroom/simulate_plugin.py leak --gig GIG_ID --count N
    python3 -I lightroom/simulate_plugin.py revoked       # after revoking the device in the app
    python3 -I lightroom/simulate_plugin.py forget

Resume: run `upload` with --stop-after 15 (as if Lightroom were killed), then
run it again without: the first 15 are skipped as already in the gallery.

The token is kept in ~/.rawwers/lightroom-sim.json (readable by you only) and
never printed; `forget` deletes it. Only a dev API is accepted (localhost or
a .local host): never production. Standard library only.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import ssl
import sys
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

API = os.environ.get("RAWWERS_API", "http://localhost:8000").rstrip("/")
VERSION = "1.0.0"
STORE = Path.home() / ".rawwers" / "lightroom-sim.json"
WORKERS = 3
MULTIPART_THRESHOLD = 16 * 1024 * 1024
#: Fields the gig list may have (tests/test_delivery_gigs.py, ALLOWED_GIG_FIELDS).
ALLOWED_GIG_FIELDS = {
    "gig_id", "gallery_id", "client_name", "shoot_starts_at", "shoot_starts_at_epoch", "package_title",
    "niche_name", "included_photos", "delivery_state", "photos_in_gallery", "photos_processing",
}


def _tls() -> ssl.SSLContext:
    """Certificates checked as always. A python.org Python on macOS starts
    with none loaded until its "Install Certificates" step is run, and then
    every https call to storage fails; macOS's own bundle stands in."""
    context = ssl.create_default_context()
    if not context.cert_store_stats().get("x509_ca") and os.path.exists("/etc/ssl/cert.pem"):
        context.load_verify_locations("/etc/ssl/cert.pem")
    return context


TLS = _tls()


def stop(message: str) -> None:
    print(f"STOP: {message}", file=sys.stderr)
    sys.exit(1)


def dev_only() -> None:
    host = urllib.parse.urlparse(API).hostname or ""
    if not (host in ("localhost", "127.0.0.1") or host.endswith(".local")):
        stop(f"{API} is not a dev API (localhost or .local). This script never touches production.")


def saved() -> dict:
    try:
        return json.loads(STORE.read_text())
    except (OSError, ValueError):
        return {}


def save(data: dict) -> None:
    STORE.parent.mkdir(mode=0o700, exist_ok=True)
    STORE.write_text(json.dumps(data))
    STORE.chmod(0o600)


def token() -> str:
    value = saved().get("token")
    if not value:
        stop("Not paired. Run `pair --code ...` with a code from the pro app (Settings > Connect Lightroom).")
    return value


class Answer:
    def __init__(self, status: int, body: bytes, headers):
        self.status, self.headers = status, headers
        try:
            self.data = json.loads(body) if body else {}
        except ValueError:
            self.data = {"raw": body[:200].decode(errors="replace")}

    @property
    def ok(self) -> bool:
        return 200 <= self.status < 300

    def message(self) -> str:
        error = self.data.get("error") if isinstance(self.data, dict) else None
        return (error or {}).get("message") or f"HTTP {self.status}"

    def code(self) -> str | None:
        error = self.data.get("error") if isinstance(self.data, dict) else None
        return (error or {}).get("code")


def call(method: str, path: str, body: dict | None = None, *, auth: str | None = None, retries: int = 4) -> Answer:
    """As RawwersApi.request: the token and version headers, JSON, and a
    retry on network errors and 5xx only - never on 4xx."""
    delays = [2, 5, 15, 30][:retries]
    for attempt in range(len(delays) + 1):
        request = urllib.request.Request(f"{API}{path}", method=method, data=None if body is None else json.dumps(body).encode())
        request.add_header("X-Rawwers-Plugin-Version", VERSION)
        request.add_header("Accept", "application/json")
        if body is not None:
            request.add_header("Content-Type", "application/json")
        if auth:
            request.add_header("Authorization", f"Bearer {auth}")
        try:
            with urllib.request.urlopen(request, timeout=60, context=TLS) as response:
                return Answer(response.status, response.read(), response.headers)
        except urllib.error.HTTPError as error:
            answer = Answer(error.code, error.read(), error.headers)
            if error.code < 500 or attempt == len(delays):
                return answer
        except (urllib.error.URLError, TimeoutError, ConnectionError) as error:
            if attempt == len(delays):
                return Answer(0, json.dumps({"error": {"message": f"Could not reach RAWWERS ({error})"}}).encode(), {})
        threading.Event().wait(delays[attempt])
    raise AssertionError("unreachable")


def put(url: str, headers: dict, data: bytes) -> int:
    """As RawwersApi.putToStorage: no token, the URL's own headers."""
    request = urllib.request.Request(url, method="PUT", data=data)
    for field, value in (headers or {}).items():
        request.add_header(field, value)
    for attempt in range(5):
        try:
            with urllib.request.urlopen(request, timeout=120, context=TLS) as response:
                return response.status
        except urllib.error.HTTPError as error:
            if error.code < 500 or attempt == 4:
                return error.code
        except (urllib.error.URLError, TimeoutError, ConnectionError):
            if attempt == 4:
                return 0
        threading.Event().wait([2, 5, 15, 30][attempt])
    return 0


# --- commands --------------------------------------------------------------------------


def cmd_pair(args) -> None:
    answer = call("POST", "/v1/delivery/pair", {"code": args.code, "device_name": args.name, "plugin_version": VERSION})
    if not answer.ok:
        stop(answer.message())
    save({"token": answer.data["token"], "device_id": answer.data["device_id"]})
    print(f"Connected as {answer.data['photographer_name']} (device {answer.data['device_id']}, token {answer.data['token'][:8]}...)")
    if answer.data.get("update_available"):
        print("The API says a newer plug-in is available.")


def cmd_gigs(_args) -> None:
    answer = call("GET", "/v1/delivery/gigs", auth=token())
    if not answer.ok:
        stop(answer.message())
    items = answer.data["items"]
    if not items:
        print("No gigs are waiting for photos.")
    for gig in items:
        state = "In progress, %d uploaded" % gig["photos_in_gallery"] if gig["delivery_state"] == "in_progress" else "Waiting for photos"
        print(f"{gig['gig_id']}  {gig['client_name']:<10} {str(gig['shoot_starts_at'])[:10]}  "
              f"{gig.get('package_title') or gig.get('niche_name') or '-'}  {gig['included_photos']} included  {state}")


def _deliver(gig: str, path: Path, auth: str, position: int, export_id: str) -> tuple[str, str, str | None]:
    """One photo, as RawwersUpload.deliver: start, PUT or parts, finish.
    `position` is its place in the export (from 1) and `export_id` the
    export's name, as the plug-in sends them."""
    data = path.read_bytes()
    sha = hashlib.sha256(data).hexdigest()
    started = call("POST", f"/v1/delivery/gigs/{gig}/uploads",
                   {"file_name": path.name, "content_type": "image/jpeg", "byte_size": len(data), "sha256": sha,
                    "position": position, "export_id": export_id}, auth=auth)
    if started.status == 401:
        return path.name, "reauth", started.message()
    if not started.ok:
        return path.name, "failed", started.message()
    body = started.data
    if body["duplicate"]:
        return path.name, "skipped", None
    asset = body["media_asset_id"]
    if body["use_multipart"]:
        parts = call("POST", f"/v1/delivery/uploads/{asset}/multipart", {"byte_size": len(data)}, auth=auth)
        if not parts.ok:
            return path.name, "failed", parts.message()
        size, count = parts.data["part_size"], parts.data["part_count"]
        held = call("GET", f"/v1/delivery/uploads/{asset}/multipart/parts", auth=auth)
        done = {p["part_number"] for p in held.data.get("parts", [])} if held.ok else set()
        missing = [n for n in range(1, count + 1) if n not in done]
        for i in range(0, len(missing), 20):
            urls = call("POST", f"/v1/delivery/uploads/{asset}/multipart/part-urls", {"part_numbers": missing[i:i + 20]}, auth=auth)
            if not urls.ok:
                return path.name, "failed", urls.message()
            for part in urls.data["parts"]:
                offset = (part["part_number"] - 1) * size
                if put(part["url"], {}, data[offset:offset + size]) != 200:
                    return path.name, "failed", "storage refused a part"
        assembled = call("POST", f"/v1/delivery/uploads/{asset}/multipart/complete", auth=auth)
        if not assembled.ok:
            return path.name, "failed", assembled.message()
    else:
        status = put(body["upload"]["url"], body["upload"]["headers"], data)
        if status == 403:
            fresh = call("POST", f"/v1/delivery/uploads/{asset}/url", auth=auth)
            status = put(fresh.data["url"], fresh.data["headers"], data) if fresh.ok else status
        if status != 200:
            return path.name, "failed", f"storage answered {status}"
    finished = call("POST", f"/v1/delivery/uploads/{asset}/complete", {"byte_size": len(data), "sha256": sha}, auth=auth)
    if not finished.ok:
        return path.name, "failed", finished.message()
    return path.name, "uploaded", body["gallery_id"]


def cmd_upload(args) -> None:
    auth = token()
    files = sorted(p for p in Path(args.folder).iterdir() if p.suffix.lower() in (".jpg", ".jpeg"))
    if args.stop_after:
        files = files[: args.stop_after]
        print(f"Sending the first {len(files)} only, as if the export were killed there.")
    results, stopped = [], threading.Event()
    # One name per run, as the plug-in names each export: a second run goes
    # after the first in the gallery.
    export_id = f"sim-{int(time.time() * 1000)}"

    def one(numbered: tuple[int, Path]):
        position, path = numbered
        if stopped.is_set():
            return path.name, "not sent", None
        result = _deliver(args.gig, path, auth, position, export_id)
        if result[1] == "reauth":
            stopped.set()
        print(f"  {result[1]:<9} {result[0]}" + (f": {result[2]}" if result[1] in ("failed", "reauth") else ""), flush=True)
        return result

    with ThreadPoolExecutor(WORKERS) as pool:
        results = list(pool.map(one, enumerate(files, start=1)))
    counts = {state: sum(1 for _, s, _ in results if s == state) for state in ("uploaded", "skipped", "failed", "reauth", "not sent")}
    print(f"\n{counts['uploaded']} uploaded, {counts['skipped']} skipped (already in the gallery), "
          f"{counts['failed']} failed, {counts['not sent']} not sent")
    if counts["reauth"]:
        print("The device is no longer connected: pair again with a new code.")
    gallery = next((g for _, s, g in results if s == "uploaded" and g), None)
    if gallery:
        print(f"Gallery {gallery}: `status --gallery {gallery}` shows the photos joining it as they are processed.")


def cmd_status(args) -> None:
    answer = call("GET", f"/v1/delivery/galleries/{args.gallery}/status", auth=token())
    if not answer.ok:
        stop(answer.message())
    d = answer.data
    print(f"gallery {d['gallery_status']}: {d['photos_in_gallery']} in the gallery, {d['processing']} processing, "
          f"{d['uploading']} uploading, {len(d['failed'])} failed")
    for f in d["failed"]:
        print(f"  failed {f['file_name']}: {f['reason']}")


def cmd_scope(_args) -> None:
    """What the token reads, and what it cannot."""
    auth, problems = token(), []
    gigs = call("GET", "/v1/delivery/gigs", auth=auth)
    for gig in gigs.data.get("items", []):
        extra = set(gig) - ALLOWED_GIG_FIELDS
        if extra:
            problems.append(f"gig list has fields outside the allowed list: {sorted(extra)}")
        name = gig.get("client_name", "")
        if "@" in name or any(ch.isdigit() for ch in name) or (" " in name and not name.endswith(".")):
            problems.append(f"client name is more than a first name and initial: {name!r}")
    print(f"gig list: {len(gigs.data.get('items', []))} gigs, fields {sorted(ALLOWED_GIG_FIELDS)}")
    for method, path in [
        ("GET", "/v1/gigs"), ("GET", "/v1/pro/earnings/balance"), ("GET", "/v1/pro/earnings/ledger"),
        ("GET", "/v1/pro/payouts"), ("GET", "/v1/chats"), ("GET", "/v1/client/bookings"), ("GET", "/v1/me"),
        ("GET", "/v1/pro/lightroom/devices"), ("POST", "/v1/pro/lightroom/pairing-code"),
        ("GET", f"/v1/proof-galleries/{uuid.uuid4()}"),
    ]:
        answer = call(method, path, auth=auth, retries=0)
        ok = answer.status in (401, 403, 404, 405)
        print(f"  {method} {path}: {answer.status} {'refused, as it should be' if ok else 'READABLE'}")
        if not ok:
            problems.append(f"{method} {path} answered {answer.status}")
    print("SCOPE OK: the token reads only the delivery routes" if not problems else "SCOPE PROBLEMS:\n  " + "\n  ".join(problems))
    if problems:
        sys.exit(1)


def cmd_leak(args) -> None:
    """A leaked token, used from elsewhere: as many starts as it can get.
    With the default cap (5000 a day per device) this would need 5000; set
    RATE_LIMIT_DELIVERY_TOKEN_UPLOADS_PER_DAY low in api/.env to watch it
    stop (STOP and restore it after). Nothing is uploaded: the starts are
    never finished, so nothing reaches the gallery."""
    auth, statuses = token(), []
    for n in range(args.count):
        answer = call("POST", f"/v1/delivery/gigs/{args.gig}/uploads",
                      {"file_name": f"leak_{n}.jpg", "content_type": "image/jpeg", "byte_size": 1000, "sha256": uuid.uuid4().hex * 2},
                      auth=auth, retries=0)
        statuses.append(answer.status)
        if answer.status == 429:
            print(f"Stopped by the cap after {n} starts: {answer.message()}")
            break
        if answer.status == 401:
            print(f"Refused after {n} starts: {answer.message()} (revoked)")
            break
    else:
        print(f"{args.count} starts accepted; the cap was not reached.")
    print("statuses:", {s: statuses.count(s) for s in sorted(set(statuses))})


def cmd_revoked(_args) -> None:
    for method, path in [("GET", "/v1/delivery/me"), ("GET", "/v1/delivery/gigs")]:
        answer = call(method, path, auth=token(), retries=0)
        print(f"{method} {path}: {answer.status} {answer.code()} - {answer.message()}")
        if answer.status != 401:
            stop("the token still works: revoke the device in the pro app first")
    print("REVOKED: the plug-in would now ask for a new pairing code.")


def cmd_forget(_args) -> None:
    STORE.unlink(missing_ok=True)
    print("Forgotten.")


def main() -> None:
    dev_only()
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("pair")
    p.add_argument("--code", required=True)
    p.add_argument("--name", default="Simulator (no Lightroom)")
    sub.add_parser("gigs")
    p = sub.add_parser("upload")
    p.add_argument("--gig", required=True)
    p.add_argument("--folder", required=True)
    p.add_argument("--stop-after", type=int, default=0)
    p = sub.add_parser("status")
    p.add_argument("--gallery", required=True)
    sub.add_parser("scope")
    p = sub.add_parser("leak")
    p.add_argument("--gig", required=True)
    p.add_argument("--count", type=int, default=50)
    sub.add_parser("revoked")
    sub.add_parser("forget")
    args = parser.parse_args()
    {"pair": cmd_pair, "gigs": cmd_gigs, "upload": cmd_upload, "status": cmd_status, "scope": cmd_scope,
     "leak": cmd_leak, "revoked": cmd_revoked, "forget": cmd_forget}[args.command](args)


if __name__ == "__main__":
    main()
