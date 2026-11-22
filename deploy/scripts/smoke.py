#!/usr/bin/env python3
"""Smoke test: is the deployed RAWWERS answering the way it should?

Run it on the Mac after every deploy. Python 3 standard library only.

    python3 deploy/scripts/smoke.py --api https://api.rawwers.com --admin https://admin.rawwers.com
    python3 deploy/scripts/smoke.py --api https://api.rawwers.com --admin https://admin.rawwers.com \
        --write api.rawwers.com          # also signs up and signs in a throwaway account

Read-only by default. It never touches money (no booking, no payment).

What it checks:
  - TLS: the certificate is valid for the host (skipped with --insecure-tls,
    for the local rehearsal only);
  - plain http:// is redirected to https://;
  - GET /healthz is 200 (and the release, with --expect-release <commit>);
  - the API docs, openapi.json, /metrics, the admin API and the dev routes
    are NOT reachable on the API host (404);
  - a public listing (GET /v1/niches lists 12 niches) and the exchange rates;
  - CORS: the admin web's origin is allowed, any other origin is not;
  - the web admin: home and login page answer 200;
  - with --write: a throwaway account (smoke-<time>@rawwers.test) signs up,
    signs in, reads /v1/me, sees the print store and Studioverse switched off
    (404), and signs out. On a test deployment no email reaches it (only the
    allowlist is mailed). The account itself is removed on the server with
    `python scripts/delete_smoke_accounts.py` (the runbook says how).

Write steps run only against the API URL given on this command line, and only
when --write names that same host. There is no default URL.

Exit 0: everything passed. Exit 1: something failed (listed at the end).
Exit 2: wrong arguments (nothing was sent).
"""
from __future__ import annotations

import argparse
import http.client
import json
import ssl
import sys
import time
import urllib.error
import urllib.request
from urllib.parse import urlsplit

failures: list[str] = []
CTX: ssl.SSLContext | None = None


def ok(step: str, passed: bool, detail: object = "") -> bool:
    print(("ok    " if passed else "FAIL  ") + step + (f"   ({detail})" if detail and not passed else ""))
    if not passed:
        failures.append(step)
    return passed


def skip(step: str, why: str) -> None:
    print(f"skip  {step}   ({why})")


class _NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


def call(method: str, url: str, *, body: dict | None = None, headers: dict | None = None, follow: bool = True):
    """(status, headers, parsed JSON or text). Status 0 when nothing answered."""
    data = json.dumps(body).encode() if body is not None else None
    request = urllib.request.Request(url, method=method, data=data, headers={"User-Agent": "rawwers-smoke/1", **(headers or {})})
    if data is not None:
        request.add_header("Content-Type", "application/json")
    handlers = [urllib.request.HTTPSHandler(context=CTX)]
    if not follow:
        handlers.append(_NoRedirect())
    opener = urllib.request.build_opener(*handlers)
    try:
        with opener.open(request, timeout=30) as answer:
            raw = answer.read()
            return answer.status, answer.headers, _parse(raw)
    except urllib.error.HTTPError as error:
        return error.code, error.headers, _parse(error.read())
    except (OSError, http.client.HTTPException) as error:
        return 0, {}, str(error)


def _parse(raw: bytes):
    try:
        return json.loads(raw) if raw else None
    except ValueError:
        return raw[:200].decode("utf-8", "replace")


def check_tls(url: str, insecure: bool) -> None:
    parts = urlsplit(url)
    if parts.scheme != "https":
        ok(f"{parts.hostname} uses https", False, url)
        return
    if insecure:
        skip(f"TLS certificate of {parts.hostname}", "--insecure-tls")
        return
    try:
        context = ssl.create_default_context()
        import socket

        with socket.create_connection((parts.hostname, parts.port or 443), timeout=15) as sock, \
                context.wrap_socket(sock, server_hostname=parts.hostname) as tls:
            cert = tls.getpeercert()
        expires = cert.get("notAfter", "?")
        ok(f"TLS certificate of {parts.hostname} is valid (until {expires})", True)
    except Exception as error:  # noqa: BLE001
        ok(f"TLS certificate of {parts.hostname} is valid", False, error)


def check_redirect(url: str, http_port: int) -> None:
    parts = urlsplit(url)
    plain = f"http://{parts.hostname}{'' if http_port == 80 else f':{http_port}'}/"
    status, headers, _ = call("GET", plain, follow=False)
    location = (headers.get("Location") if headers else "") or ""
    ok(f"http://{parts.hostname} redirects to https", status in (301, 302, 307, 308) and location.startswith("https://"), f"{status} {location}")


def _pin_addresses(pins: dict[str, str]) -> None:
    import socket

    real = socket.getaddrinfo

    def getaddrinfo(host, *rest, **kw):
        return real(pins.get(host, host), *rest, **kw)

    socket.getaddrinfo = getaddrinfo
    print("      pinned: " + ", ".join(f"{h} -> {ip}" for h, ip in pins.items()))


def main() -> int:
    global CTX
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--api", required=True, help="the API's base URL, for example https://api.rawwers.com")
    parser.add_argument("--admin", required=True, help="the web admin's base URL, for example https://admin.rawwers.com")
    parser.add_argument("--write", metavar="HOST", help="also sign up a throwaway account; HOST must be the --api host")
    parser.add_argument("--expect-release", metavar="COMMIT", help="the commit /healthz must report")
    parser.add_argument("--insecure-tls", action="store_true", help="do not verify certificates (local rehearsal only)")
    parser.add_argument("--no-redirect-check", action="store_true", help="skip the http->https check")
    parser.add_argument("--http-port", type=int, default=80, help="where plain http answers (the rehearsal uses another port)")
    parser.add_argument("--resolve", action="append", default=[], metavar="HOST:IP",
                        help="send HOST to IP instead of asking DNS, like curl --resolve (rehearsal only)")
    args = parser.parse_args()
    if args.resolve:
        _pin_addresses(dict(item.split(":", 1) for item in args.resolve))

    api = args.api.rstrip("/")
    admin = args.admin.rstrip("/")
    api_host = urlsplit(api).hostname
    for name, url in (("--api", api), ("--admin", admin)):
        if urlsplit(url).scheme not in ("http", "https") or not urlsplit(url).hostname:
            print(f"{name} must be a full URL such as https://api.rawwers.com; got {url!r}. Nothing was sent.")
            return 2
    if args.write is not None and args.write != api_host:
        print(f"--write names {args.write!r} but --api is {api_host!r}. Write steps run only against the host you name. Nothing was sent.")
        return 2
    if args.insecure_tls:
        CTX = ssl._create_unverified_context()  # the rehearsal only; said on screen

    print(f"API   {api}\nadmin {admin}\nmode  {'read and write (throwaway account)' if args.write else 'read-only'}\n")

    check_tls(api, args.insecure_tls)
    check_tls(admin, args.insecure_tls)
    if args.no_redirect_check:
        skip("http -> https redirect", "--no-redirect-check")
    else:
        check_redirect(api, args.http_port)
        check_redirect(admin, args.http_port)

    status, _, health = call("GET", f"{api}/healthz")
    ok("GET /healthz is 200", status == 200 and isinstance(health, dict) and health.get("status") == "ok", f"{status} {health}")
    release = health.get("release") if isinstance(health, dict) else None
    print(f"      release: {release}")
    if args.expect_release:
        ok(f"the release is {args.expect_release}", bool(release) and str(release).startswith(args.expect_release), release)

    for path in ("/docs", "/redoc", "/openapi.json", "/metrics", "/v1/admin/feature-flags", "/v1/dev/environment", "/health/ready"):
        status, _, _ = call("GET", f"{api}{path}")
        ok(f"GET {path} is not reachable (404)", status == 404, status)

    status, _, niches = call("GET", f"{api}/v1/niches")
    ok("GET /v1/niches lists 12 niches", status == 200 and isinstance(niches, list) and len(niches) == 12,
       f"{status} {len(niches) if isinstance(niches, list) else niches}")
    status, _, rates = call("GET", f"{api}/v1/fx/rates")
    ok("GET /v1/fx/rates is 200", status == 200, status)
    print(f"      exchange rates: {json.dumps(rates)[:160] if rates else rates}")

    origin = f"{urlsplit(admin).scheme}://{urlsplit(admin).netloc}"
    preflight = {"Origin": origin, "Access-Control-Request-Method": "POST", "Access-Control-Request-Headers": "content-type"}
    status, headers, _ = call("OPTIONS", f"{api}/v1/auth/login", headers=preflight)
    allowed = headers.get("Access-Control-Allow-Origin") if headers else None
    ok(f"CORS allows {origin}", status == 200 and allowed == origin, f"{status} {allowed}")
    status, headers, _ = call("OPTIONS", f"{api}/v1/auth/login", headers={**preflight, "Origin": "https://evil.invalid"})
    allowed = headers.get("Access-Control-Allow-Origin") if headers else None
    ok("CORS refuses another origin", allowed is None, f"{status} {allowed}")

    for path in ("/", "/login"):
        status, headers, _ = call("GET", f"{admin}{path}", follow=False)
        location = (headers.get("Location") if headers else "") or ""
        if status in (302, 303) and "cloudflareaccess.com" in location:
            ok(f"admin GET {path} is protected by Cloudflare Access (login page)", True)
        else:
            ok(f"admin GET {path} is 200", status == 200, f"{status} {location}")

    if args.write:
        email = f"smoke-{int(time.time())}@rawwers.test"
        password = "Smoke-" + str(int(time.time() * 1000))[-10:] + "-check"
        status, _, account = call("POST", f"{api}/v1/auth/register", body={"email": email, "password": password, "display_name": "Smoke check"})
        ok(f"sign up {email}", status == 201 and isinstance(account, dict) and bool(account.get("user_id")), f"{status} {account}")
        status, _, login = call("POST", f"{api}/v1/auth/login", body={"email": email, "password": password})
        token = login.get("access_token") if isinstance(login, dict) else None
        ok("sign in", status == 200 and bool(token), status)
        if token:
            auth = {"Authorization": f"Bearer {token}"}
            status, _, _ = call("GET", f"{api}/v1/me", headers=auth)
            ok("GET /v1/me is 200", status == 200, status)
            status, _, _ = call("GET", f"{api}/v1/prints/catalog", headers=auth)
            ok("the print store is off (404)", status == 404, status)
            status, _, _ = call("GET", f"{api}/v1/studioverse/packs", headers=auth)
            ok("Studioverse is off (404)", status == 404, status)
            refresh = login.get("refresh_token") if isinstance(login, dict) else None
            status, _, _ = call("POST", f"{api}/v1/auth/logout", body={"refresh_token": refresh} if refresh else {}, headers=auth)
            ok("sign out", status in (200, 204), status)
        print(f"\n      Remove the account on the server: python scripts/delete_smoke_accounts.py --apply  ({email})")

    print()
    if failures:
        print(f"{len(failures)} check(s) FAILED:")
        for step in failures:
            print(f"  - {step}")
        return 1
    print("Everything passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
