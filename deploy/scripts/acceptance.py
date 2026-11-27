#!/usr/bin/env python3
"""Acceptance run: one whole booking on a deployed TEST server, in Stripe
test mode, through the public API. Python 3 standard library only.

What it does, and what stays by hand, is in docs/ACCEPTANCE.md. In short:

    python3 deploy/scripts/acceptance.py book   --api https://api.rawwers.com --confirm-host api.rawwers.com \\
        --pro-email <you>+pro1@gmail.com
    python3 deploy/scripts/acceptance.py payout --api https://api.rawwers.com --confirm-host api.rawwers.com \\
        --run <the run id the book phase printed>

`book`: a new client signs up, books your standing test photographer's
first active package, pays with a Stripe test payment method (publishable
key only), the photographer delivers photos the script makes itself, the
client chooses the package plus a few extras and pays the difference, and
leaves a review. It prints the amounts the booking must show.

`payout`: once the earning is available, the photographer asks for all of
it; you approve it in the admin web (MANUAL); the script waits for paid.

Safety:
- only an https API, named twice (--api and --confirm-host), never a default;
- the Stripe key comes from the environment (RAWWERS_STRIPE_PK) and must be a
  publishable TEST key (pk_test_); a live key (pk_live_) is refused;
- the photographer's password is asked for, never stored or printed; the
  new client's password is made up for this run and kept only in memory;
- the run file (ids and expected amounts only) is written mode 600 in
  ~/Developer/RAWWERS-work/scratch, outside the repository.

Every step prints ok, FAIL or MANUAL. Exit 0: no FAIL (MANUAL steps may
remain). Exit 1: a FAIL. Exit 2: refused before anything was sent.
"""
from __future__ import annotations

import argparse
import base64
import getpass
import hashlib
import http.client
import json
import math
import os
import secrets
import ssl
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta, timezone
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path

STRIPE_API = "https://api.stripe.com"
#: Stripe's test payment methods (docs.stripe.com/testing): funds straight
#: to the available balance outside the US, and a generic decline.
TEST_CARD = "pm_card_bypassPendingInternational"
DEFAULT_STATE_DIR = Path.home() / "Developer" / "RAWWERS-work" / "scratch"
CENT = Decimal("0.01")
#: The Portraits curve (exponential, k 0.08, floor 15% of the entry rate),
#: used only to say what a Portraits quote must be; for another niche the
#: quote is compared by hand (MANUAL).
CURVES = {"portraits": ("exponential", 0.08, Decimal("0.15"))}
EXTRAS = 5

#: A 64 x 48 baseline JPEG. Each photo is this picture with its own comment
#: segment, so every file is valid and has its own sha256.
_JPEG = base64.b64decode(
    "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAoHBwgHBgoICAgLCgoLDhgQDg0NDh0VFhEYIx8lJCIfIiEmKzcvJik0KSEiMEExNDk7Pj4+JS5ESUM8SDc9Pjv/"
    "2wBDAQoLCw4NDhwQEBw7KCIoOzs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozv/wAARCAAwAEADASIAAhEBAxEB/8QA"
    "HwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkK"
    "FhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXG"
    "x8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAEC"
    "AxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOE"
    "hYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDFooorzzuC"
    "iiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA//2Q=="
)


class Refused(Exception):
    """Wrong arguments: nothing is sent."""


def photo(run_id: str, n: int) -> bytes:
    """A small valid JPEG, unique to this run and number."""
    note = f"RAWWERS acceptance {run_id} {n}".encode()
    segment = b"\xff\xfe" + (len(note) + 2).to_bytes(2, "big") + note
    return _JPEG[:2] + segment + _JPEG[2:]


def q2(value) -> Decimal:
    return Decimal(str(value)).quantize(CENT, rounding=ROUND_HALF_UP)


def curve_total(niche: str, entry_rate: Decimal, included: int, photos: int) -> Decimal | None:
    """What `photos` cost on a package of `included` at `entry_rate`, from the
    owner's rule: the package at the entry rate each, extras on the curve,
    rounded once. None for a niche whose curve this script does not know."""
    if niche not in CURVES:
        return None
    _kind, k, floor = CURVES[niche]
    total = entry_rate * min(photos, included)
    for n in range(included + 1, photos + 1):
        total += max(entry_rate * floor, Decimal(str(float(entry_rate) * math.exp(-k * (n - included)))))
    return q2(total)


def split(gross: Decimal) -> tuple[Decimal, Decimal, Decimal]:
    """15% kept and 5% RAWW credit, each rounded on its own; the cash is the rest."""
    kept, raww = q2(gross * 15 / 100), q2(gross * 5 / 100)
    return kept, raww, q2(gross - kept - raww)


# --- the network ---------------------------------------------------------------------------


class Http:
    """(status, parsed body). Status 0 when nothing answered."""

    def __init__(self, context: ssl.SSLContext | None = None):
        self.context = context or ssl.create_default_context()

    def __call__(self, method: str, url: str, *, headers: dict | None = None, json_body=None, form=None, data: bytes | None = None):
        headers = {"User-Agent": "rawwers-acceptance/1", **(headers or {})}
        body = data
        if json_body is not None:
            body, headers["Content-Type"] = json.dumps(json_body).encode(), "application/json"
        elif form is not None:
            body, headers["Content-Type"] = urllib.parse.urlencode(form).encode(), "application/x-www-form-urlencoded"
        request = urllib.request.Request(url, method=method, data=body, headers=headers)
        opener = urllib.request.build_opener(urllib.request.HTTPSHandler(context=self.context))
        try:
            with opener.open(request, timeout=60) as answer:
                return answer.status, _parse(answer.read())
        except urllib.error.HTTPError as error:
            return error.code, _parse(error.read())
        except (OSError, http.client.HTTPException) as error:
            return 0, str(error)


def _parse(raw: bytes):
    try:
        return json.loads(raw) if raw else None
    except ValueError:
        return raw[:200].decode("utf-8", "replace")


# --- one run -------------------------------------------------------------------------------


@dataclass
class Step:
    name: str
    status: str  # ok, FAIL, MANUAL
    detail: str = ""


@dataclass
class Run:
    api: str
    http: object
    ask: object  # (prompt, secret) -> str
    out: object = print
    sleep: object = time.sleep
    state_dir: Path = DEFAULT_STATE_DIR
    publishable_key: str | None = None
    poll_seconds: int = 300
    steps: list[Step] = field(default_factory=list)
    state: dict = field(default_factory=dict)

    # -- reporting --

    def ok(self, name: str, detail: str = "") -> None:
        self._step(Step(name, "ok", detail))

    def fail(self, name: str, detail: str = "") -> None:
        self._step(Step(name, "FAIL", detail))

    def manual(self, name: str, detail: str) -> None:
        self._step(Step(name, "MANUAL", detail))

    def _step(self, step: Step) -> None:
        self.steps.append(step)
        self.out(f"{step.status:<7} {step.name}" + (f"   ({step.detail})" if step.detail else ""))

    def check(self, name: str, passed: bool, detail: str = "") -> bool:
        (self.ok if passed else self.fail)(name, "" if passed else detail)
        return passed

    def table(self) -> int:
        self.out("")
        self.out(f"{'step':<52} result")
        for step in self.steps:
            self.out(f"{step.name:<52} {step.status}")
        fails = [s for s in self.steps if s.status == "FAIL"]
        manual = [s for s in self.steps if s.status == "MANUAL"]
        self.out(f"\n{len(self.steps) - len(fails) - len(manual)} ok, {len(fails)} FAIL, {len(manual)} MANUAL")
        return 1 if fails else 0

    # -- the API --

    def call(self, method: str, path: str, token: str | None = None, *, body=None):
        headers = {"Authorization": f"Bearer {token}"} if token else {}
        return self.http(method, f"{self.api}{path}", headers=headers, json_body=body)

    def need(self, name: str, answer, want: int = 200):
        status, body = answer
        if status != want:
            message = body.get("error", {}).get("message") if isinstance(body, dict) and isinstance(body.get("error"), dict) else body
            self.fail(name, f"HTTP {status}: {str(message)[:160]}")
            raise Stop(name)
        return body

    def sign_in(self, email: str, password: str) -> str:
        return self.need("sign in", self.call("POST", "/v1/auth/login", body={"email": email, "password": password}))["access_token"]

    def poll(self, name: str, fetch, done, *, every: int = 5):
        waited = 0
        while True:
            value = fetch()
            if done(value):
                return value
            if waited >= self.poll_seconds:
                self.fail(name, f"still not done after {waited} s")
                raise Stop(name)
            self.sleep(every)
            waited += every

    # -- Stripe, with the publishable key only --

    def confirm_payment(self, name: str, intent_id: str, client_secret: str, amount: Decimal, currency: str) -> bool:
        how = (f"pay it in the client app with the test card 4000 0000 0000 0077 (any future date, any CVC): "
               f"{amount} {currency}, then press Enter")
        if not self.publishable_key:
            self.manual(name, f"no RAWWERS_STRIPE_PK: {how}")
            self.ask(f"MANUAL: {how}", False)
            return False
        status, body = self.http(
            "POST", f"{STRIPE_API}/v1/payment_intents/{urllib.parse.quote(intent_id)}/confirm",
            headers={"Authorization": f"Bearer {self.publishable_key}"},
            form={"client_secret": client_secret, "payment_method": TEST_CARD},
        )
        if status == 200 and isinstance(body, dict) and body.get("status") in ("succeeded", "processing"):
            self.ok(name)
            return True
        reason = body.get("error", {}).get("message", "") if isinstance(body, dict) and isinstance(body.get("error"), dict) else ""
        self.manual(name, f"Stripe did not confirm it with the publishable key (HTTP {status}: {reason[:120]}): {how}")
        self.ask(f"MANUAL: {how}", False)
        return False

    # -- the run file --

    def save(self) -> Path:
        self.state_dir.mkdir(parents=True, exist_ok=True)
        path = self.state_dir / f"acceptance-{self.state['run']}.json"
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
        with os.fdopen(fd, "w") as handle:
            json.dump(self.state, handle, indent=2, sort_keys=True)
        os.chmod(path, 0o600)
        return path

    def load(self, run_id: str) -> None:
        path = self.state_dir / f"acceptance-{run_id}.json"
        if not path.exists():
            raise Refused(f"no run file {path}")
        self.state = json.loads(path.read_text())
        if self.state.get("api") != self.api:
            raise Refused(f"run {run_id} was made against {self.state.get('api')}, not {self.api}")

    # -- the phases --

    def book(self, pro_email: str, *, run_id: str | None = None, today: date | None = None) -> None:
        run = run_id or datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S") + "-" + secrets.token_hex(2)
        self.state = {"run": run, "api": self.api, "pro_email": pro_email, "phase": "book"}
        pro = self.sign_in(pro_email, self.ask(f"Password for {pro_email}: ", True))
        me = self.need("photographer's account", self.call("GET", "/v1/me", pro))
        self.state["pro_user_id"] = me["user_id"]
        setup = self.need("payout setup", self.call("GET", "/v1/pro/payouts/connect/status", pro))
        if setup.get("account_status") != "active":
            self.fail("payout setup", f"{setup.get('account_status')}: finish Stripe's form in the Pro app (Settings > Getting paid)")
            raise Stop("payout setup")
        self.ok("payout setup is active")
        self.manual("payout account older than 24 hours",
                    "a payout asked for within 24 hours of a payout-account change is frozen as a possible takeover: "
                    "use a photographer whose payout setup was finished at least a day before the payout phase")

        packages = self.need("packages", self.call("GET", f"/v1/pro/{me['user_id']}/packages"))
        package = next((p for p in packages if p.get("is_active")), None)
        if package is None:
            self.fail("packages", "the photographer has no active package")
            raise Stop("packages")
        entry, included, currency = Decimal(str(package["price"])), int(package["included_photos"]), package["currency"]
        niche = self._niche_slug(package)
        self.state.update(package_id=package["id"], currency=currency, entry_rate=str(entry), included=included, niche=niche)
        self.ok("package", f"{included} photos at {entry} {currency}")

        email = f"acceptance-{run}@rawwers.test"
        password = secrets.token_urlsafe(18)
        self.need("client signs up", self.call("POST", "/v1/auth/register", body={"email": email, "password": password}), want=201)
        client = self.sign_in(email, password)
        self.ok("client signs up and signs in")

        start = self._first_start(client, me["user_id"], package["id"], today or date.today())
        made = self.need("booking request", self.call("POST", "/v1/client/bookings/request", client, body={
            "pro_user_id": me["user_id"], "niche_slug": niche, "package_id": package["id"],
            "date_window": {"start_at": start["start_at"], "end_at": start["end_at"]}, "location": "Acceptance run",
        }))
        booking_id = made["booking_id"]
        self.state["booking_id"] = booking_id
        accepted = self.need("photographer accepts", self.call("POST", f"/v1/booking-requests/{booking_id}/accept", pro, body={}))
        self.state["gig_id"] = gig_id = accepted["gig_id"]
        self.save()
        self.ok("booking request and accept")

        deposit = q2(entry * included)
        pay = self.need("checkout", self.call("POST", f"/v1/client/bookings/{booking_id}/pay", client, body={"payment_mode": "full"}))
        self.check("deposit is the package at the entry rate", q2(pay["amount"]) == deposit, f"{pay['amount']} not {deposit}")
        self.confirm_payment("booking payment", pay["payment_intent_id"], pay["payment_intent_client_secret"], deposit, currency)
        self.poll("booking paid", lambda: self.call("GET", f"/v1/client/bookings/{booking_id}", client)[1],
                  lambda b: isinstance(b, dict) and b.get("gig_status") in ("paid", "completed"))
        self.ok("booking paid (the webhook arrived)")

        self.manual("settlement delay", "to pay out today, run set-settlement-delay.py --apply on the server NOW "
                    "(docs/TEST_WORLD.md 9a), then press Enter; otherwise the earning waits 7 days")
        self.ask("MANUAL: settlement delay set (or not wanted)? Press Enter", False)

        photos = included + EXTRAS
        gallery = self._deliver(pro, gig_id, photos, included, entry, run)
        self.state["gallery_id"] = gallery
        self.save()

        self.need("selection saved", self.call("POST", f"/v1/proof-galleries/{gallery}/selections", client,
                                               body={"media_asset_ids": self.state["photo_ids"][:photos]}))
        quote = self.need("selection quote", self.call("GET", f"/v1/proof-galleries/{gallery}/selection-quote", client))
        expected_total = curve_total(niche, entry, included, photos)
        if expected_total is None:
            self.manual("selection total", f"{quote['amount_total']} {currency}: compare with the niche's curve by hand")
            expected_total = q2(quote["amount_total"])
        else:
            self.check("selection total from the owner's rule", q2(quote["amount_total"]) == expected_total,
                       f"server {quote['amount_total']}, expected {expected_total}")
        difference = q2(expected_total - deposit)
        self.check("difference to pay", q2(quote["amount_due"]) == difference, f"server {quote['amount_due']}, expected {difference}")
        submitted = self.need("selection submitted", self.call("POST", f"/v1/proof-galleries/{gallery}/selections/submit", client))
        if submitted.get("difference_required"):
            self.confirm_payment("difference payment", submitted["difference_payment_intent_id"],
                                 submitted["difference_payment_intent_client_secret"], difference, currency)
        self.poll("booking completed", lambda: self.call("GET", f"/v1/client/bookings/{booking_id}", client)[1],
                  lambda b: isinstance(b, dict) and b.get("gig_status") == "completed")
        self.ok("booking completed")
        self.need("review", self.call("POST", f"/v1/gigs/{gig_id}/review", client,
                                      body={"rating": 5, "tags": [], "would_book_again": True}))
        self.ok("review posted")

        kept, raww, cash = split(expected_total)
        self.state.update(total=str(expected_total), kept=str(kept), raww=str(raww), cash=str(cash), phase="booked")
        self._check_earning(pro, expected_total, cash)
        self.manual("admin money page", f"Admin > the booking's money: final {expected_total}, kept {kept}, RAWW {raww}, "
                    f"cash {cash} {currency}; payments {deposit} and {difference}")
        path = self.save()
        self.out(f"\nRun {run}: the payout phase continues it (--run {run}). Run file: {path}")

    def payout(self) -> None:
        pro_email = self.state["pro_email"]
        pro = self.sign_in(pro_email, self.ask(f"Password for {pro_email}: ", True))
        cash, currency = Decimal(self.state["cash"]), self.state["currency"]
        self._check_earning(pro, Decimal(self.state["total"]), cash)
        balance = self.need("balance", self.call("GET", "/v1/pro/earnings/balance", pro))
        if q2(balance["withdrawable"]) < cash:
            self.manual("earning available", f"withdrawable is {balance['withdrawable']} {currency}, the booking's cash is {cash}: "
                        "run tools/server/settle-now.py --apply on the server (or wait for the hourly sweep, or the 7 days), "
                        "then run this phase again")
            return
        self.ok("earning available")
        requested = self.need("payout request", self.call("POST", "/v1/pro/payouts/request", pro, body={"amount": str(cash)}))
        self.state["payout_id"] = requested["id"]
        self.save()
        self.check("payout requested", requested["status"] == "requested" and q2(requested["amount"]) == cash,
                   f"{requested['status']} {requested['amount']}")
        self.manual("admin approves", f"Admin > Payouts: the {cash} {currency} row, GOES TO Stripe Connect active > Approve, then press Enter")
        self.ask("MANUAL: approved in the admin web? Press Enter", False)
        paid = self.poll("payout paid", lambda: self._payout(pro, requested["id"]), lambda p: p and p.get("status") in ("paid", "failed"))
        if not self.check("payout paid", paid["status"] == "paid", f"{paid['status']}: {paid.get('failure_reason')}"):
            return
        after = self.need("balance after", self.call("GET", "/v1/pro/earnings/balance", pro))
        self.check("paid out includes the booking's cash", q2(after["paid_out"]) >= cash, f"paid_out {after['paid_out']}")
        self.manual("transfer in Stripe", f"Stripe (test mode) > Connect > the photographer's account > transfers: "
                    f"{cash} {currency} in all, from the booking's charges")
        self.manual("settlement delay restored", "if you set it to 0: set-settlement-delay.py --restore --apply on the server")
        self.state["phase"] = "paid"
        self.save()

    # -- helpers --

    def _niche_slug(self, package: dict) -> str:
        for niche in self.need("niches", self.call("GET", "/v1/niches")):
            if str(niche.get("id")) == str(package["niche_id"]):
                return niche["slug"]
        self.fail("package's niche", f"niche {package['niche_id']} is not listed")
        raise Stop("niche")

    def _first_start(self, client: str, pro_id: str, package_id: str, today: date) -> dict:
        start, end = today + timedelta(days=7), today + timedelta(days=35)
        query = urllib.parse.urlencode({"package_id": package_id, "from": start.isoformat(), "to": end.isoformat()})
        calendar = self.need("calendar", self.call("GET", f"/v1/client/pros/{pro_id}/availability?{query}", client))
        for day in calendar.get("days", []):
            if day.get("start_times"):
                self.ok("a bookable time", day["start_times"][0]["start_at"])
                return day["start_times"][0]
        self.fail("a bookable time", "no time offered in the next five weeks: give the photographer working hours")
        raise Stop("calendar")

    def _deliver(self, pro: str, gig_id: str, photos: int, included: int, entry: Decimal, run: str) -> str:
        gallery = self.need("proof gallery", self.call("POST", f"/v1/gigs/{gig_id}/proof-gallery", pro,
                                                       body={"included_photos": included, "extra_photo_price": str(entry)}))["id"]
        ids = []
        for n in range(photos):
            payload = photo(run, n)
            started = self.need("photo upload", self.call("POST", "/v1/media/photos/uploads", pro, body={
                "purpose": "proof", "content_type": "image/jpeg", "file_name": f"ACC_{n:04d}.jpg",
                "gallery_id": gallery, "sha256": hashlib.sha256(payload).hexdigest(),
            }))
            url = started["upload"]["url"]
            if urllib.parse.urlsplit(url).scheme != "https":
                self.fail("photo upload", "the upload address is not https")
                raise Stop("upload")
            status, _ = self.http("PUT", url, headers={"Content-Type": "image/jpeg"}, data=payload)
            if status not in (200, 201):
                self.fail("photo upload", f"the storage answered {status}")
                raise Stop("upload")
            self.need("photo sent", self.call("POST", f"/v1/media/photos/{started['media_asset_id']}/complete", pro,
                                              body={"byte_size": len(payload)}))
            ids.append(started["media_asset_id"])
        self.state["photo_ids"] = ids
        for media_id in ids:
            self.poll("photo processed", lambda m=media_id: self.call("GET", f"/v1/media/{m}", pro)[1],
                      lambda m: isinstance(m, dict) and m.get("status") in ("ready", "failed"))
        self.ok(f"{photos} photos uploaded and processed")
        self.need("photos in the gallery", self.call("POST", f"/v1/proof-galleries/{gallery}/items", pro, body={"media_asset_ids": ids}))
        self.need("gallery sent", self.call("POST", f"/v1/proof-galleries/{gallery}/publish", pro))
        self.ok("gallery sent to the client")
        return gallery

    def _check_earning(self, pro: str, total: Decimal, cash: Decimal) -> None:
        ledger = self.need("earnings ledger", self.call("GET", "/v1/pro/earnings/ledger", pro))
        mine = [e for e in ledger.get("items", []) if str(e.get("source_id")) == self.state["gig_id"]]
        self.check("one earning for the booking", len(mine) == 1, f"{len(mine)} entries")
        if len(mine) == 1:
            entry = mine[0]
            self.check("earning: gross and cash", (q2(entry["gross"]), q2(entry["net"])) == (total, cash),
                       f"gross {entry['gross']} net {entry['net']}, expected {total} and {cash}")

    def _payout(self, pro: str, payout_id: str):
        listed = self.call("GET", "/v1/pro/payouts", pro)[1]
        items = listed.get("items", []) if isinstance(listed, dict) else []
        return next((p for p in items if p.get("id") == payout_id), None)


class Stop(Exception):
    """A step failed; the run stops there (the table says which)."""


# --- the command line ------------------------------------------------------------------------


def check_target(api: str, confirm_host: str) -> str:
    parts = urllib.parse.urlsplit(api)
    if parts.scheme != "https" or not parts.hostname:
        raise Refused("--api must be an https address")
    if parts.path not in ("", "/") or parts.query:
        raise Refused("--api is the host only, without a path")
    if parts.hostname != confirm_host:
        raise Refused(f"--confirm-host must repeat the API's host ({parts.hostname})")
    return f"https://{parts.netloc}"


def check_key(key: str | None) -> str | None:
    if not key:
        return None
    key = key.strip()
    if key.startswith("pk_live_"):
        raise Refused("RAWWERS_STRIPE_PK is a LIVE publishable key: this runs in Stripe test mode only")
    if not key.startswith("pk_test_"):
        raise Refused("RAWWERS_STRIPE_PK must be a publishable test key (pk_test_...)")
    return key


def _ask(prompt: str, secret: bool) -> str:
    return getpass.getpass(prompt) if secret else input(prompt)


def main(argv: list[str], *, http=None, ask=_ask, out=print, environ=os.environ, sleep=time.sleep, state_dir: Path | None = None) -> int:
    parser = argparse.ArgumentParser(prog="acceptance.py", description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("phase", choices=["book", "payout"])
    parser.add_argument("--api", required=True)
    parser.add_argument("--confirm-host", required=True)
    parser.add_argument("--pro-email")
    parser.add_argument("--run", help="the run id the book phase printed (payout phase)")
    parser.add_argument("--state-dir", type=Path, help=argparse.SUPPRESS)
    try:
        args = parser.parse_args(argv)
    except SystemExit as exit_:
        return 2 if exit_.code else 0
    try:
        api = check_target(args.api, args.confirm_host)
        key = check_key(environ.get("RAWWERS_STRIPE_PK"))
        if args.phase == "book" and not args.pro_email:
            raise Refused("book needs --pro-email (your standing test photographer)")
        if args.phase == "payout" and not args.run:
            raise Refused("payout needs --run (the id the book phase printed)")
        run = Run(api=api, http=http or Http(), ask=ask, out=out, sleep=sleep,
                  state_dir=args.state_dir or state_dir or DEFAULT_STATE_DIR, publishable_key=key)
        if args.phase == "payout":
            run.load(args.run)
    except Refused as refused:
        out(f"REFUSED: {refused}")
        return 2
    if key is None:
        out("No RAWWERS_STRIPE_PK: each payment will be a MANUAL step in the client app.")
    try:
        if args.phase == "book":
            run.book(args.pro_email)
        else:
            run.payout()
    except Stop:
        pass
    return run.table()


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
