"""The whole marketplace transaction, driven through the API's own routes.

One journey: a client and a photographer sign up, the photographer is
onboarded and approved, the client books and pays, the photographer delivers,
the client chooses, the booking completes, the earning settles, the
photographer is paid out. Every step is the HTTP route the apps and the admin
web call, through the test client.

Only the edges are fake:
- Stripe: `FakeStripe` keeps the state Stripe would (intents, charges,
  refunds, transfers, the balance, connected accounts) and sends the events
  Stripe would, built from the events captured from Stripe test mode
  (fixtures/stripe/captured_events.json, the pinned API version) and posted
  to /v1/webhooks/stripe signed with the suite's webhook secret, so the
  signature check is the real one;
- R2: `FakeBucket` is the S3 client behind app.services.storage, in memory;
- email: `MailRecorder` is the mail provider;
- Mux is not on the money path.

What cannot be reached the same way is done as the server would do it, and
named where it happens:
- the workers: `Journey.work()` runs the outbox dispatcher (webhooks, payout
  execution, notifications) and `Journey.settle()` the hourly settlement
  sweep, the same task functions the worker and beat run;
- photo processing: the real task, run synchronously on the fake bucket;
- the 12 portfolio photos and the gear checks, written to the database (they
  need RAW files and an admin's gear review; neither is money);
- the clock, in two places: the payout account was set up weeks before
  the payout (payout_account.updated_at, moved back 30 days at setup), and
  `Journey.jump_past_settlement_delay()` moves the earning's `available_at`
  back once the test has shown the payout refused (earnings_ledger_entry,
  that column only).

Every journey talks from its own made-up internet address, so the shared
rate limiter (Redis) never ties one test to another.

Money is Decimal throughout; every expected amount in the tests is written
out by hand, never read back from the code under test.
"""
from __future__ import annotations

import copy
import hashlib
import hmac
import io
import json
import random
import time
import uuid
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta, timezone
from decimal import Decimal
from pathlib import Path

import stripe
from PIL import Image
from sqlalchemy import select, text

D = Decimal
ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"
ADMIN = {"X-User-Id": ADMIN_ID, "X-Admin-Api-Key": ""}
PASSWORD = "Journey-Passw0rd!"
CAPTURE = json.loads((Path(__file__).parent / "fixtures" / "stripe" / "captured_events.json").read_text())


def cents(amount: Decimal | str) -> int:
    return int((D(str(amount)) * 100).to_integral_value())


def money(minor: int) -> Decimal:
    return (D(int(minor)) / 100).quantize(D("0.01"))


class Obj(dict):
    """A Stripe object: a dict whose keys are also attributes."""

    def __getattr__(self, name):
        try:
            return self[name]
        except KeyError as exc:
            raise AttributeError(name) from exc

    def __setattr__(self, name, value):
        self[name] = value

    def auto_paging_iter(self):
        return iter(self.get("data", []))


# ---------------------------------------------------------------------------
# Stripe
# ---------------------------------------------------------------------------


class FakeStripe:
    """What Stripe holds, for one journey. Patched over the stripe module's
    classes, which every service calls (`stripe.PaymentIntent.create`, ...)."""

    def __init__(self, monkeypatch):
        self.intents: dict[str, Obj] = {}
        self.charges: dict[str, Obj] = {}
        self.refunds: list[Obj] = []
        self.transfers: list[Obj] = []
        self.accounts: dict[str, Obj] = {}
        self.balance: dict[str, int] = {}
        self.by_key: dict[str, Obj] = {}
        self.calls: list[tuple[str, dict]] = []
        for cls, name, fn in [
            (stripe.PaymentIntent, "create", self._pi_create),
            (stripe.PaymentIntent, "retrieve", self._pi_retrieve),
            (stripe.PaymentIntent, "modify", self._pi_modify),
            (stripe.PaymentIntent, "cancel", self._pi_cancel),
            (stripe.PaymentIntent, "list", self._pi_list),
            (stripe.Refund, "create", self._refund_create),
            (stripe.Refund, "list", self._refund_list),
            (stripe.Transfer, "create", self._transfer_create),
            (stripe.Transfer, "list", self._transfer_list),
            (stripe.Balance, "retrieve", self._balance),
            (stripe.Account, "create", self._account_create),
            (stripe.Account, "retrieve", self._account_retrieve),
            (stripe.AccountLink, "create", self._account_link),
        ]:
            monkeypatch.setattr(cls, name, fn)

    @staticmethod
    def _id(prefix: str) -> str:
        return f"{prefix}_{uuid.uuid4().hex[:24]}"

    def _keyed(self, key, make):
        if key and key in self.by_key:
            return self.by_key[key]
        obj = make()
        if key:
            self.by_key[key] = obj
        return obj

    # --- payment intents --------------------------------------------------

    def _pi_create(self, *, amount, currency, metadata=None, idempotency_key=None, **kw):
        self.calls.append(("PaymentIntent.create", {"amount": amount, "currency": currency, "metadata": metadata, **kw}))

        def make():
            pi_id = self._id("pi")
            pi = Obj(
                id=pi_id, object="payment_intent", amount=int(amount), currency=currency, metadata=dict(metadata or {}),
                status="requires_payment_method", client_secret=f"{pi_id}_secret_{uuid.uuid4().hex[:8]}",
                amount_received=0, latest_charge=None, customer=None, last_payment_error=None,
            )
            self.intents[pi_id] = pi
            return pi

        return self._keyed(idempotency_key, make)

    def _pi_retrieve(self, pi_id, **kw):
        return self.intents[pi_id]

    def _pi_modify(self, pi_id, **kw):
        pi = self.intents[pi_id]
        if pi.status != "requires_payment_method":
            raise stripe.InvalidRequestError("This PaymentIntent's amount could not be updated", "amount")
        if "amount" in kw:
            pi.amount = int(kw["amount"])
        return pi

    def _pi_cancel(self, pi_id, **kw):
        pi = self.intents[pi_id]
        if pi.status == "succeeded":
            raise stripe.InvalidRequestError("You cannot cancel this PaymentIntent because it has a status of succeeded.", None)
        pi.status = "canceled"
        return pi

    def _pi_list(self, **kw):
        return Obj(data=list(self.intents.values()), has_more=False)

    def pay(self, pi_id: str) -> Obj:
        """The client's card goes through (the payment sheet)."""
        pi = self.intents[pi_id]
        assert pi.status in ("requires_payment_method", "requires_confirmation", "processing"), pi.status
        charge = Obj(id=self._id("ch"), payment_intent=pi_id, amount=pi.amount, amount_refunded=0, currency=pi.currency)
        self.charges[charge.id] = charge
        pi.status, pi.amount_received, pi.latest_charge, pi.last_payment_error = "succeeded", pi.amount, charge.id, None
        self.balance[pi.currency] = self.balance.get(pi.currency, 0) + pi.amount
        return pi

    def processing(self, pi_id: str) -> Obj:
        """The card was confirmed and the bank is still deciding."""
        pi = self.intents[pi_id]
        pi.status = "processing"
        return pi

    def decline(self, pi_id: str) -> Obj:
        """The client's card is declined: the intent waits for another."""
        pi = self.intents[pi_id]
        pi.status = "requires_payment_method"
        pi.last_payment_error = {"code": "card_declined", "decline_code": "generic_decline", "message": "Your card was declined."}
        return pi

    # --- refunds ----------------------------------------------------------

    def _refund_create(self, *, payment_intent, amount=None, metadata=None, idempotency_key=None, **kw):
        self.calls.append(("Refund.create", {"payment_intent": payment_intent, "amount": amount, "metadata": metadata}))

        def make():
            pi = self.intents[payment_intent]
            charge = self.charges[pi.latest_charge]
            value = int(amount if amount is not None else charge.amount - charge.amount_refunded)
            if value <= 0 or charge.amount_refunded + value > charge.amount:
                raise stripe.InvalidRequestError("Refund amount is greater than the unrefunded amount on the charge", "amount")
            charge.amount_refunded += value
            self.balance[pi.currency] -= value
            refund = Obj(
                id=self._id("re"), object="refund", amount=value, charge=charge.id, payment_intent=payment_intent,
                currency=pi.currency, status="succeeded", metadata=dict(metadata or {}), created=int(time.time()) + len(self.refunds),
                reason=None,
            )
            self.refunds.append(refund)
            return refund

        return self._keyed(idempotency_key, make)

    def _refund_list(self, *, payment_intent=None, limit=None, **kw):
        return Obj(data=[r for r in self.refunds if r.payment_intent == payment_intent], has_more=False)

    # --- transfers and the balance ----------------------------------------

    def _transfer_create(self, *, amount, currency, destination, idempotency_key=None, **kw):
        self.calls.append(("Transfer.create", {"amount": amount, "currency": currency, "destination": destination, **kw}))

        def make():
            source = kw.get("source_transaction")
            if source is not None:
                charge = self.charges[source]
                sent = sum(t.amount for t in self.transfers if t.source_transaction == source)
                if sent + int(amount) > charge.amount:
                    raise stripe.InvalidRequestError("Transfer amount exceeds the source transaction's amount", "amount")
            if self.balance.get(currency, 0) < int(amount):
                raise stripe.InvalidRequestError("Insufficient funds in Stripe account", "amount")
            self.balance[currency] -= int(amount)
            transfer = Obj(
                id=self._id("tr"), object="transfer", amount=int(amount), currency=currency, destination=destination,
                source_transaction=source, transfer_group=kw.get("transfer_group"), metadata=dict(kw.get("metadata") or {}),
                reversed=False, amount_reversed=0,
            )
            self.transfers.append(transfer)
            return transfer

        return self._keyed(idempotency_key, make)

    def _transfer_list(self, *, transfer_group=None, limit=None, **kw):
        return Obj(data=[t for t in self.transfers if t.transfer_group == transfer_group], has_more=False)

    def _balance(self, **kw):
        return Obj(available=[{"currency": c, "amount": a} for c, a in self.balance.items()])

    # --- connected accounts -----------------------------------------------

    def _account_create(self, **kw):
        account = Obj(
            id=self._id("acct"), object="account", type=kw.get("type"), country=kw.get("country"), email=kw.get("email"),
            charges_enabled=False, payouts_enabled=False, details_submitted=False, metadata=dict(kw.get("metadata") or {}),
            requirements={"currently_due": ["external_account"], "past_due": [], "disabled_reason": "requirements.past_due"},
        )
        self.accounts[account.id] = account
        return account

    def _account_retrieve(self, account_id, **kw):
        return self.accounts[account_id]

    def _account_link(self, *, account, **kw):
        return Obj(url=f"https://connect.stripe.invalid/setup/{account}")

    def finish_onboarding(self, account_id: str) -> Obj:
        """The photographer completes Stripe's hosted form."""
        account = self.accounts[account_id]
        account.update(details_submitted=True, payouts_enabled=True, charges_enabled=False,
                       requirements={"currently_due": [], "past_due": [], "disabled_reason": None})
        return account

    # --- what Stripe holds, in money --------------------------------------

    def transfers_to(self, destination: str) -> list[Obj]:
        return [t for t in self.transfers if t.destination == destination]


def _sample(event_type: str) -> dict:
    if event_type in CAPTURE["samples"]:
        return CAPTURE["samples"][event_type]
    for scenario in CAPTURE["refund_scenarios"].values():
        for event in scenario["events"]:
            if event["type"] == event_type:
                return event
    raise KeyError(f"no captured sample of {event_type}")


def stripe_event(event_type: str, obj: dict, *, event_id: str | None = None) -> dict:
    """An event as Stripe sends it: the captured sample, carrying our object
    over the sample's own fields."""
    event = copy.deepcopy(_sample(event_type))
    event["id"] = event_id or f"evt_{uuid.uuid4().hex[:24]}"
    event["created"] = int(time.time())
    event["data"]["object"] = {**event["data"]["object"], **copy.deepcopy(dict(obj))}
    event["data"].pop("previous_attributes", None)
    return event


def signature(body: bytes, secret: str) -> str:
    ts = int(time.time())
    mac = hmac.new(secret.encode(), f"{ts}.".encode() + body, hashlib.sha256).hexdigest()
    return f"t={ts},v1={mac}"


# ---------------------------------------------------------------------------
# R2 and email
# ---------------------------------------------------------------------------


class _NotFound(Exception):
    pass


class FakeBucket:
    """The S3 client behind app.services.storage, in memory."""

    def __init__(self, monkeypatch):
        from botocore.exceptions import ClientError

        self._client_error = ClientError
        self.objects: dict[str, bytes] = {}
        monkeypatch.setattr("app.services.storage.get_s3_client", lambda: self)

    def _missing(self, key):
        return self._client_error({"Error": {"Code": "404", "Message": "Not Found"}}, "HeadObject")

    def generate_presigned_url(self, ClientMethod=None, Params=None, ExpiresIn=None, **kw):
        method = ClientMethod or kw.get("ClientMethod") or "get_object"
        return f"https://r2.invalid/{Params['Key']}?method={method}&sig={uuid.uuid4().hex[:12]}"

    def head_object(self, Bucket, Key):
        if Key not in self.objects:
            raise self._missing(Key)
        return {"ContentLength": len(self.objects[Key])}

    def get_object(self, Bucket, Key, Range=None):
        if Key not in self.objects:
            raise self._missing(Key)
        data = self.objects[Key]
        if Range:
            start, end = Range.removeprefix("bytes=").split("-")
            data = data[int(start): int(end) + 1]
        return {"Body": io.BytesIO(data)}

    def put_object(self, Bucket, Key, Body, ContentType=None, **kw):
        self.objects[Key] = Body if isinstance(Body, bytes) else Body.read()

    def delete_object(self, Bucket, Key):
        self.objects.pop(Key, None)

    def receive(self, upload_url: str, payload: bytes) -> None:
        """The phone's PUT to a presigned URL."""
        key = upload_url.removeprefix("https://r2.invalid/").split("?", 1)[0]
        self.objects[key] = payload


class MailRecorder:
    provider_name = "journey"

    def __init__(self, monkeypatch):
        self.sent: list[dict] = []
        monkeypatch.setattr("app.services.mail.get_mail_provider", lambda: self)

    def send_template_email(self, *, email, template_key, subject, text_body, unsubscribe_url=None):
        self.sent.append({"to": email, "key": template_key})
        return f"m{len(self.sent)}"

    def keys_to(self, email: str) -> list[str]:
        return [m["key"] for m in self.sent if m["to"] == email]


def jpeg(seed: int) -> bytes:
    """A small, distinct photograph."""
    rng = random.Random(seed)
    image = Image.new("RGB", (1600, 1067), (rng.randrange(256), rng.randrange(256), rng.randrange(256)))
    for _ in range(12):
        x, y = rng.randrange(1500), rng.randrange(1000)
        image.paste((rng.randrange(256), rng.randrange(256), rng.randrange(256)), (x, y, x + 100, y + 60))
    buffer = io.BytesIO()
    image.save(buffer, "JPEG", quality=85)
    return buffer.getvalue()


# ---------------------------------------------------------------------------
# The journey
# ---------------------------------------------------------------------------


@dataclass
class Person:
    email: str
    user_id: str
    token: str = ""

    @property
    def headers(self) -> dict:
        return {"Authorization": f"Bearer {self.token}"}


@dataclass
class World:
    """Where the photographer works and what they charge."""

    city: str
    country: str
    currency: str
    timezone: str
    entry_rate: Decimal
    included_photos: int
    cap: Decimal
    niche: str = "portraits"


LISBON_EUR = World("Lisbon", "PT", "EUR", "Europe/Lisbon", D("4.80"), 20, D("6.00"))
LONDON_GBP = World("London", "GB", "GBP", "Europe/London", D("4.50"), 20, D("5.00"))


@dataclass
class Booking:
    request_id: str
    gig_id: str = ""
    gallery_id: str = ""
    photo_ids: list[str] = field(default_factory=list)
    base_intent: str = ""
    difference_intent: str = ""


class Journey:
    def __init__(self, client, db, monkeypatch, world: World = LISBON_EUR):
        from app.core.config import get_settings

        self.client, self.db, self.world = client, db, world
        self.stripe = FakeStripe(monkeypatch)
        self.bucket = FakeBucket(monkeypatch)
        self.mail = MailRecorder(monkeypatch)
        self.secret = get_settings().stripe_webhook_secret.split(",")[0].strip()
        self.posted: list[dict] = []
        #: Stripe delivers every event twice, the second time with the same
        #: event id (a retried delivery), applied by the worker each time.
        self.echo = False
        self._announced: set[str] = set()
        # Celery's broker is the test Redis, which no worker reads: queued
        # tasks are run here instead (work(), process()).
        monkeypatch.setattr("app.api.v1.media.process_photo_variants.delay", lambda *a, **k: None)
        # Our own internet address (rate limits are counted per address).
        client.headers["X-Forwarded-For"] = f"10.{random.randrange(1, 250)}.{random.randrange(1, 250)}.{random.randrange(1, 250)}"
        self._seed = random.randrange(1_000_000)
        self._seed_admin()

    # --- plumbing ---------------------------------------------------------

    def call(self, method: str, path: str, who=None, *, expect: int = 200, **kw):
        headers = ADMIN if who == "admin" else (who.headers if who is not None else {})
        resp = self.client.request(method, path, headers={**headers, **kw.pop("headers", {})}, **kw)
        assert resp.status_code == expect, f"{method} {path}: {resp.status_code} {resp.text}"
        self.db.expire_all()
        return resp.json() if resp.content and resp.headers.get("content-type", "").startswith("application/json") else None

    def _seed_admin(self):
        from app.models.admin import UserAccount, UserRole, UserRoleType

        aid = uuid.UUID(ADMIN_ID)
        if not self.db.get(UserAccount, aid):
            self.db.add(UserAccount(user_id=aid, email="admin@journey.invalid"))
            self.db.add(UserRole(user_id=aid, role=UserRoleType.admin))
            self.db.commit()

    def send(self, event_type: str, obj: dict, *, event_id: str | None = None, work: bool = True) -> dict:
        """Stripe sends an event: signed, posted to the webhook, then applied
        by the worker."""
        event = stripe_event(event_type, obj, event_id=event_id)
        body = json.dumps(event).encode()
        resp = self.client.post("/v1/webhooks/stripe", content=body, headers={"stripe-signature": signature(body, self.secret)})
        assert resp.status_code == 200, f"webhook {event_type}: {resp.status_code} {resp.text}"
        self.posted.append(event)
        if work:
            self.work()
        if self.echo:
            again = self.client.post("/v1/webhooks/stripe", content=body, headers={"stripe-signature": signature(body, self.secret)})
            assert again.status_code == 200, f"webhook {event_type} again: {again.status_code} {again.text}"
            if work:
                self.work()
        return event

    def replay_all(self, *, new_ids: bool) -> int:
        """Stripe sends every event again: the same event, or the same object
        under a new event id (as a retried delivery or a second, related
        event would carry it)."""
        events = list(self.posted)
        echo, self.echo = self.echo, False
        for event in events:
            obj = event["data"]["object"]
            if new_ids:
                self.send(event["type"], obj)
            else:
                self.send(event["type"], obj, event_id=event["id"])
        del self.posted[len(events):]
        self.echo = echo
        return len(events)

    def work(self) -> int:
        """The worker: the outbox, until it is empty."""
        from app.tasks.outbox_tasks import dispatch_outbox_events_task

        total = 0
        for _ in range(20):
            done = dispatch_outbox_events_task(limit=500)
            total += done
            if not done:
                break
        self.db.expire_all()
        return total

    def settle(self) -> int:
        """The hourly settlement sweep."""
        from app.tasks.payouts_tasks import run_settlement_scan_task

        changed = run_settlement_scan_task()
        self.db.expire_all()
        return changed

    def jump_past_settlement_delay(self, pro: Person) -> int:
        """The clock: the photographer's earnings fall due now. The one
        direct write (earnings_ledger_entry.available_at)."""
        count = self.db.execute(
            text("UPDATE earnings_ledger_entry SET available_at = now() - interval '1 second' "
                 "WHERE pro_user_id = :pro AND status IN ('pending', 'held') AND available_at > now()"),
            {"pro": pro.user_id},
        ).rowcount
        self.db.commit()
        return count

    # --- people -----------------------------------------------------------

    def sign_up(self, label: str) -> Person:
        email = f"journey-{label}-{uuid.uuid4().hex[:10]}@example.com"
        made = self.call("POST", "/v1/auth/register", expect=201, json={"email": email, "password": PASSWORD, "display_name": label.title()})
        person = Person(email=email, user_id=made["user_id"])
        self.sign_in(person)
        return person

    def sign_in(self, person: Person) -> None:
        person.token = self.call("POST", "/v1/auth/login", json={"email": person.email, "password": PASSWORD})["access_token"]

    def open_city(self) -> None:
        w = self.world
        self.call("PUT", "/v1/admin/rollout/cities", "admin", json=[{
            "country": w.country, "city": w.city, "is_pro_onboarding_enabled": True, "is_client_browsing_enabled": True, "metadata": {},
        }])

    def set_price_cap(self) -> None:
        w = self.world
        self.call("PUT", "/v1/admin/pricing/niche-package-price-caps", "admin", json={"items": [
            {"niche_slug": w.niche, "tier": "rookie", "entry_price_min": "0.50", "entry_price_max": str(w.cap), "currency": w.currency},
        ]})

    def photographer(self, *, client_credit_percent: int = 0) -> Person:
        """Sign-up to approved and listed, with working hours and a Stripe
        payout account that is ready."""
        w = self.world
        pro = self.sign_up("pro")
        self.call("POST", "/v1/me/upgrade-to-pro", pro)
        self.sign_in(pro)
        self.call("POST", "/v1/pro/onboarding/start", pro, json={"city": w.city, "country": w.country})
        self.call("PUT", "/v1/pro/me/profile", pro, json={
            "display_name": "Journey Pro", "headline": "Portraits", "bio": "Portraits in the city, natural light.",
            "city": w.city, "country": w.country, "languages": ["en"], "styles": ["natural"],
            "client_credit_percent": client_credit_percent,
        })
        self._raise_completeness(pro)
        self.call("POST", "/v1/pro/onboarding/complete-profile", pro)
        self._portfolio(pro)
        self.call("POST", "/v1/pro/onboarding/upload-portfolio", pro)
        # The order the onboarding moves through: packages, then niches.
        self.package_id = self.call("POST", "/v1/pro/me/packages", pro, json={
            "title": "Portraits", "niche_slug": w.niche, "duration_minutes": 60, "price": str(w.entry_rate),
            "currency": w.currency, "included_photos": w.included_photos, "extra_photo_price": str(w.entry_rate),
            "proofs_sla_days": 3, "finals_sla_days": 7, "addons": [],
        })["id"]
        self.call("PUT", "/v1/pro/me/extra-image-price", pro, json={"items": [{"niche_slug": w.niche, "unit_price": str(w.entry_rate)}]})
        self.call("POST", "/v1/pro/onboarding/configure-packages", pro)
        self.call("PUT", "/v1/pro/me/niches", pro, json={"primary_niche_slug": w.niche, "niches": [{"slug": w.niche, "is_primary": True}]})
        self.call("POST", "/v1/pro/onboarding/select-niches", pro)
        self.call("POST", "/v1/pro/onboarding/submit-kyc", pro)
        self._gear(pro)
        # The identity check, then approval for the public (Admin > Home > Approve).
        self.call("POST", f"/v1/admin/pros/{pro.user_id}/kyc", "admin", json={"kyc_status": "approved", "note": "journey"})
        self.call("POST", f"/v1/admin/pros/{pro.user_id}/approve", "admin", json={"note": "journey"})
        self.call("PUT", "/v1/pro/scheduling/availability-rules", pro, json={"rules": [
            {"weekday": day, "start_local": "09:00", "end_local": "18:00", "timezone": w.timezone} for day in range(7)
        ]})
        self.connect(pro)
        return pro

    def _raise_completeness(self, pro: Person) -> None:
        from app.models.admin import ProProfile

        profile = self.db.get(ProProfile, uuid.UUID(pro.user_id))
        if profile.completeness_score < 60:
            # A cover photo and the rest of the profile raise it in the app;
            # not money.
            profile.completeness_score = 80
            self.db.commit()

    def _portfolio(self, pro: Person) -> None:
        """Twelve ready portfolio photos (written: their processing is not money)."""
        from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility

        for _ in range(12):
            self.db.add(MediaAsset(
                owner_user_id=uuid.UUID(pro.user_id), kind=MediaKind.photo, purpose=MediaPurpose.portfolio_reel,
                provider=MediaProvider.r2, status=MediaStatus.ready, visibility=MediaVisibility.public,
                content_type="image/jpeg", meta={},
            ))
        self.db.commit()

    def _gear(self, pro: Person) -> None:
        """A full-frame body and a prime, verified (written: the check reads
        RAW headers and an admin reviews it; not money)."""
        from app.models.gear_verification import CameraModelReference, LensModelReference, SensorSize, ApertureType
        from app.models.repair import GearCategory
        from app.services.gear_verify import normalise_model, verify_from_raw
        from tests.test_gear_verification import _frame

        self.db.merge(CameraModelReference(normalised_model=normalise_model("ILCE-7M4"), make="Sony", display_name="Sony A7 IV",
                                           sensor_size=SensorSize.full_frame))
        self.db.merge(LensModelReference(normalised_model=normalise_model("FE 85mm F1.4 GM"), make="Sony",
                                         display_name="FE 85mm F1.4 GM", aperture_type=ApertureType.prime))
        self.db.flush()
        pid = uuid.UUID(pro.user_id)
        verify_from_raw(self.db, pro_user_id=pid, category=GearCategory.camera_body, data=_frame())
        verify_from_raw(self.db, pro_user_id=pid, category=GearCategory.lens,
                        data=_frame(lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4)))
        self.db.commit()

    def connect(self, pro: Person) -> str:
        """Stripe payout setup: the account, the hosted form (finished at
        Stripe), back in the app the status is read, and account.updated."""
        account_id = self.call("POST", "/v1/pro/payouts/connect/account", pro)["stripe_connect_account_id"]
        self.call("POST", "/v1/pro/payouts/connect/onboarding-link", pro)
        account = self.stripe.finish_onboarding(account_id)
        self.send("account.updated", account)
        status = self.call("GET", "/v1/pro/payouts/connect/status", pro)
        assert status["account_status"] == "active", status
        self.account_id = account_id
        self._payouts_set_up_weeks_ago(pro)
        return account_id

    def _payouts_set_up_weeks_ago(self, pro: Person) -> None:
        """The clock, part one: the payout account was set up when the
        photographer joined, weeks before any payout. A payout asked for
        within 24 hours of an account change is frozen as a possible
        takeover (trust_safety.evaluate_payout_anomaly_rule); that is not
        the journey. The one other direct write: payout_account.updated_at."""
        self.db.execute(
            text("UPDATE payout_account SET updated_at = now() - interval '30 days' WHERE pro_user_id = :pro"),
            {"pro": pro.user_id},
        )
        self.db.commit()

    # --- booking ----------------------------------------------------------

    def shoot_time(self, weeks: int = 3) -> tuple[datetime, datetime]:
        from zoneinfo import ZoneInfo

        day = date.today() + timedelta(weeks=weeks)
        day += timedelta(days=(2 - day.weekday()) % 7)  # a Wednesday
        start = datetime(day.year, day.month, day.day, 11, 0, tzinfo=ZoneInfo(self.world.timezone)).astimezone(timezone.utc)
        return start, start + timedelta(minutes=60)

    def book(self, client: Person, pro: Person, *, weeks: int = 3) -> Booking:
        start, end = self.shoot_time(weeks)
        made = self.call("POST", "/v1/client/bookings/request", client, json={
            "pro_user_id": pro.user_id, "niche_slug": self.world.niche, "package_id": self.package_id,
            "date_window": {"start_at": start.isoformat(), "end_at": end.isoformat()}, "location": self.world.city,
        })
        booking = Booking(request_id=made["booking_id"])
        accepted = self.call("POST", f"/v1/booking-requests/{booking.request_id}/accept", pro, json={})
        booking.gig_id = accepted["gig_id"]
        return booking

    def checkout(self, client: Person, booking: Booking, *, use_credit: bool | None = None) -> dict:
        body = {"payment_mode": "full"}
        if use_credit is not None:
            body["use_credit"] = use_credit
        paid = self.call("POST", f"/v1/client/bookings/{booking.request_id}/pay", client, json=body)
        booking.base_intent = paid["payment_intent_id"]
        return paid

    def card_pays(self, pi_id: str) -> None:
        self.send("payment_intent.succeeded", self.stripe.pay(pi_id))

    def card_declined(self, pi_id: str) -> None:
        self.send("payment_intent.payment_failed", self.stripe.decline(pi_id))

    # --- delivery and selection -------------------------------------------

    def deliver(self, pro: Person, booking: Booking, count: int) -> None:
        import app.tasks.media_tasks as tasks

        gallery = self.call("POST", f"/v1/gigs/{booking.gig_id}/proof-gallery", pro, json={
            "included_photos": self.world.included_photos, "extra_photo_price": str(self.world.entry_rate),
        })
        booking.gallery_id = gallery["id"]
        for n in range(count):
            photo = jpeg(self._seed + n)
            started = self.call("POST", "/v1/media/photos/uploads", pro, json={
                "purpose": "proof", "content_type": "image/jpeg", "file_name": f"IMG_{n:04d}.jpg",
                "gallery_id": booking.gallery_id, "sha256": hashlib.sha256(photo).hexdigest(),
            })
            self.bucket.receive(started["upload"]["url"], photo)
            self.call("POST", f"/v1/media/photos/{started['media_asset_id']}/complete", pro, json={"byte_size": len(photo)})
            tasks.process_photo_variants.push_request(retries=0)
            try:
                tasks.process_photo_variants.run(started["media_asset_id"])
            finally:
                tasks.process_photo_variants.pop_request()
            booking.photo_ids.append(started["media_asset_id"])
        self.call("POST", f"/v1/proof-galleries/{booking.gallery_id}/items", pro, json={"media_asset_ids": booking.photo_ids})
        self.call("POST", f"/v1/proof-galleries/{booking.gallery_id}/publish", pro)
        self.work()

    def choose(self, client: Person, booking: Booking, count: int) -> dict:
        self.call("POST", f"/v1/proof-galleries/{booking.gallery_id}/selections", client,
                  json={"media_asset_ids": booking.photo_ids[:count]})
        quote = self.call("GET", f"/v1/proof-galleries/{booking.gallery_id}/selection-quote", client)
        submitted = self.call("POST", f"/v1/proof-galleries/{booking.gallery_id}/selections/submit", client)
        if submitted.get("difference_required"):
            booking.difference_intent = submitted["difference_payment_intent_id"]
        self.work()
        return {"quote": quote, "submitted": submitted}

    def review(self, client: Person, booking: Booking) -> None:
        self.call("POST", f"/v1/gigs/{booking.gig_id}/review", client, json={"rating": 5, "tags": [], "would_book_again": True})

    # --- payouts ----------------------------------------------------------

    def request_payout(self, pro: Person, amount: Decimal, *, expect: int = 200) -> dict:
        return self.call("POST", "/v1/pro/payouts/request", pro, expect=expect, json={"amount": str(amount)})

    def approve_payout(self, payout_id: str) -> dict:
        approved = self.call("POST", f"/v1/admin/payouts/{payout_id}/approve", "admin")
        self.work()  # payout.execute: the transfers
        return approved

    def announce_refunds(self) -> int:
        """Stripe tells us of each refund it made: refund.created, then
        charge.refunded with the charge's new total refunded."""
        sent = 0
        for refund in list(self.stripe.refunds):
            if refund.id in self._announced:
                continue
            self._announced.add(refund.id)
            charge = self.stripe.charges[refund.charge]
            self.send("refund.created", refund)
            self.send("charge.refunded", {
                "id": charge.id, "object": "charge", "payment_intent": charge.payment_intent, "amount": charge.amount,
                "amount_captured": charge.amount, "amount_refunded": charge.amount_refunded,
                "refunded": charge.amount_refunded == charge.amount, "currency": charge.currency,
            })
            sent += 1
        return sent

    def confirm_transfers(self) -> None:
        """Stripe tells us of each transfer it made."""
        for transfer in list(self.stripe.transfers):
            if not any(e["type"] == "transfer.created" and e["data"]["object"]["id"] == transfer.id for e in self.posted):
                self.send("transfer.created", transfer)

    # --- reading the money ------------------------------------------------

    def gig(self, booking: Booking):
        from app.models.gig import Gig

        self.db.expire_all()
        return self.db.get(Gig, uuid.UUID(booking.gig_id))

    def payments(self, booking: Booking) -> list:
        from app.models.gig import StripePayment

        return self.db.execute(
            select(StripePayment).where(StripePayment.gig_id == uuid.UUID(booking.gig_id)).order_by(StripePayment.created_at)
        ).scalars().all()

    def captured(self, booking: Booking) -> list:
        """The booking's ledger: each payment captured, in order."""
        from app.models.gig import LedgerEntry, LedgerEntryType

        return [row.amount for row in self.db.execute(
            select(LedgerEntry).where(LedgerEntry.gig_id == uuid.UUID(booking.gig_id),
                                      LedgerEntry.entry_type == LedgerEntryType.payment_captured).order_by(LedgerEntry.created_at)
        ).scalars().all()]

    def attention_items(self, booking: Booking) -> list:
        """What the admin's money queue holds for the booking: (kind, amount)."""
        from app.models.admin import MoneyAttentionItem

        return [(row.kind, row.amount) for row in self.db.execute(
            select(MoneyAttentionItem).where(MoneyAttentionItem.gig_id == uuid.UUID(booking.gig_id)).order_by(MoneyAttentionItem.created_at)
        ).scalars().all()]

    def reductions(self, booking: Booking) -> list:
        """The booking's price reductions: (source, from, to, lines, refund)."""
        from app.models.price_reduction import PriceReduction

        return [(r.source, r.from_amount, r.to_amount, [(x["reason_code"], D(x["amount"])) for x in r.lines], r.refund_amount)
                for r in self.db.execute(
                    select(PriceReduction).where(PriceReduction.gig_id == uuid.UUID(booking.gig_id)).order_by(PriceReduction.created_at)
                ).scalars().all()]

    def refund_cases(self, booking: Booking) -> list:
        from app.models.admin import RefundCase

        return [(c.status.value, c.amount) for c in self.db.execute(
            select(RefundCase).where(RefundCase.gig_id == uuid.UUID(booking.gig_id)).order_by(RefundCase.created_at)
        ).scalars().all()]

    def entries(self, pro: Person) -> list:
        from app.models.payouts import EarningsLedgerEntry

        return self.db.execute(
            select(EarningsLedgerEntry).where(EarningsLedgerEntry.pro_user_id == uuid.UUID(pro.user_id))
        ).scalars().all()

    def wallet(self, pro: Person):
        from app.services.photographer_money import photographer_money

        self.db.expire_all()
        return photographer_money(self.db, uuid.UUID(pro.user_id))

    def raww(self, pro: Person) -> list:
        from app.models.shelf import ProRawwLedgerEntry

        return self.db.execute(
            select(ProRawwLedgerEntry).where(ProRawwLedgerEntry.pro_user_id == uuid.UUID(pro.user_id))
        ).scalars().all()

    def payout_events(self, payout_id: str) -> list[str]:
        from app.models.payouts import PayoutEvent

        return sorted(row.type for row in self.db.execute(
            select(PayoutEvent).where(PayoutEvent.payout_request_id == uuid.UUID(payout_id))
        ).scalars().all())

    def payout_transfers(self, payout_id: str) -> list:
        from app.models.payouts import PayoutTransfer

        return self.db.execute(
            select(PayoutTransfer).where(PayoutTransfer.payout_request_id == uuid.UUID(payout_id))
        ).scalars().all()


class KnownBug(AssertionError):
    """A check that fails today because of a bug logged in BETA_SCOPE. Tests
    mark it `xfail(raises=KnownBug, strict=True)`: the suite stays green,
    any other failure still fails, and the test turns red the day the bug
    is fixed (then remove the mark)."""


def known_bug(condition: bool, message: str) -> None:
    if not condition:
        raise KnownBug(message)


def assert_split_reconciles(gig) -> None:
    """Every share of the booking back to its gross, to the cent."""
    shares = gig.final_platform_retained + gig.final_pro_raww + gig.final_pro_cash + (gig.final_client_raww or D("0.00"))
    assert shares == gig.final_gross, (shares, gig.final_gross)


def assert_wallet_balances(wallet) -> None:
    parts = wallet.available + wallet.requested + wallet.reserved + wallet.paid_out + wallet.pending + wallet.on_hold
    assert parts == wallet.lifetime, (parts, wallet.lifetime)
