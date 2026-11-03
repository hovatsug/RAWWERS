"""The Stripe reconcile job: payments Stripe took that never reached us.

Every run compares our recent payments not yet recorded as paid with
Stripe, and records a success through the same handler the webhook uses.
What it cannot match, and money Stripe took that we have no record of,
become Money attention items. A fake Stripe client stands in for Stripe."""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal as D
from types import SimpleNamespace

from sqlalchemy import func, select

from app.models.admin import MoneyAttentionItem
from app.models.gig import GigStatus, LedgerEntry, PaymentStatus, StripePayment, StripePaymentKind
from app.services import stripe_reconcile
from app.services.stripe_reconcile import run

from tests.test_photographer_money import _gig, _pro

NOW = datetime.now(timezone.utc)
ADMIN = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}


class FakeStripe:
    """What Stripe says: intents by id, and the recent succeeded ones."""

    def __init__(self, intents=(), missing=()):
        self.intents = {pi.id: pi for pi in intents}
        self.missing = set(missing)
        self.retrieved: list[str] = []

    def retrieve(self, payment_intent_id):
        self.retrieved.append(payment_intent_id)
        if payment_intent_id in self.missing:
            raise stripe_reconcile.NoSuchPaymentIntent(payment_intent_id)
        return self.intents[payment_intent_id]

    def list_succeeded(self, since):
        return [pi for pi in self.intents.values() if pi.status == "succeeded" and pi.created >= int(since.timestamp())]


def _pi(pi_id, status="succeeded", amount_cents=15000, created=None):
    return SimpleNamespace(
        id=pi_id, status=status, amount=amount_cents, amount_received=amount_cents if status == "succeeded" else 0,
        currency="eur", created=int((created or NOW - timedelta(minutes=30)).timestamp()), metadata={},
    )


def _unpaid(db, *, age=timedelta(minutes=30), amount="150.00", kind=StripePaymentKind.base) -> StripePayment:
    pro = _pro(db)
    gig = _gig(db, pro, minimum=amount)
    gig.status = GigStatus.payment_pending
    payment = StripePayment(
        gig_id=gig.id, kind=kind, client_user_id=gig.client_user_id, status=PaymentStatus.pending,
        stripe_payment_intent_id=f"pi_{uuid.uuid4().hex[:16]}", amount=D(amount), currency="EUR", meta={},
        created_at=NOW - age,
    )
    db.add(payment)
    db.commit()
    return payment


def _items(db, kind=None):
    db.expire_all()
    q = select(MoneyAttentionItem)
    if kind:
        q = q.where(MoneyAttentionItem.kind == kind)
    return db.execute(q).scalars().all()


def test_a_success_that_never_reached_us_is_recorded_as_the_webhook_would(db_session):
    payment = _unpaid(db_session)
    fake = FakeStripe([_pi(payment.stripe_payment_intent_id)])

    result = run(db_session, gateway=fake, now=NOW)
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(StripePayment, payment.id).status == PaymentStatus.succeeded
    assert db_session.get(type(payment.gig), payment.gig_id).status == GigStatus.paid
    assert (result.checked, result.recorded, result.flagged) == (1, 1, 0)
    assert result.finished_at is not None and result.dry_run is False


def test_running_again_and_the_late_webhook_change_nothing(db_session):
    from app.api.v1.webhooks import _apply_stripe_event

    payment = _unpaid(db_session)
    fake = FakeStripe([_pi(payment.stripe_payment_intent_id)])
    run(db_session, gateway=fake, now=NOW)
    db_session.commit()
    ledger_rows = db_session.execute(select(func.count()).select_from(LedgerEntry).where(LedgerEntry.gig_id == payment.gig_id)).scalar_one()

    again = run(db_session, gateway=fake, now=NOW + timedelta(minutes=15))
    _apply_stripe_event(db_session, "payment_intent.succeeded", {"id": payment.stripe_payment_intent_id, "amount_received": 15000})
    db_session.commit()

    assert (again.checked, again.recorded) == (0, 0), "a paid row is not ours to check"
    assert db_session.execute(select(func.count()).select_from(LedgerEntry).where(LedgerEntry.gig_id == payment.gig_id)).scalar_one() == ledger_rows
    assert _items(db_session) == []


def test_a_selection_difference_paid_at_stripe_is_recorded_too(db_session):
    """The difference that could stay "already being processed" for good:
    the job records it, so the next submit sees it paid."""
    payment = _unpaid(db_session, kind=StripePaymentKind.difference, amount="40.00")

    result = run(db_session, gateway=FakeStripe([_pi(payment.stripe_payment_intent_id, amount_cents=4000)]), now=NOW)
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(StripePayment, payment.id).status == PaymentStatus.succeeded
    assert result.recorded == 1


def test_a_payment_still_in_progress_at_stripe_is_left_alone(db_session):
    payment = _unpaid(db_session)
    fake = FakeStripe([_pi(payment.stripe_payment_intent_id, status="processing")])

    result = run(db_session, gateway=fake, now=NOW)
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(StripePayment, payment.id).status == PaymentStatus.pending
    assert (result.checked, result.recorded, result.flagged) == (1, 0, 0)


def test_a_payment_too_new_or_too_old_is_not_checked(db_session):
    new = _unpaid(db_session, age=timedelta(minutes=1))
    old = _unpaid(db_session, age=timedelta(days=10))
    fake = FakeStripe([_pi(new.stripe_payment_intent_id), _pi(old.stripe_payment_intent_id, created=NOW - timedelta(days=10))])

    result = run(db_session, gateway=fake, now=NOW)

    assert fake.retrieved == [] and result.checked == 0, "the webhook may still be on its way; old ones are past the window"


def test_dry_run_changes_nothing_and_says_what_it_would_do(db_session):
    payment = _unpaid(db_session)
    unknown = _pi("pi_unknown_dry")
    fake = FakeStripe([_pi(payment.stripe_payment_intent_id), unknown])

    result = run(db_session, gateway=fake, now=NOW, dry_run=True)
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(StripePayment, payment.id).status == PaymentStatus.pending
    assert _items(db_session) == []
    assert result.dry_run is True and (result.recorded, result.flagged) == (1, 1)
    assert {d["action"] for d in result.details} == {"would_record", "would_flag_unknown"}


def test_money_stripe_took_that_we_have_no_record_of_is_flagged_once(db_session):
    fake = FakeStripe([_pi("pi_nobody_knows", amount_cents=4200)])

    run(db_session, gateway=fake, now=NOW)
    run(db_session, gateway=fake, now=NOW + timedelta(minutes=15))
    db_session.commit()

    [item] = _items(db_session, "stripe_payment_unknown")
    assert (item.stripe_payment_intent_id, item.amount, item.currency, item.status) == ("pi_nobody_knows", D("42.00"), "EUR", "open")


def test_a_payment_stripe_does_not_know_is_flagged(db_session):
    payment = _unpaid(db_session)
    fake = FakeStripe(missing=[payment.stripe_payment_intent_id])

    result = run(db_session, gateway=fake, now=NOW)
    db_session.commit()

    [item] = _items(db_session, "stripe_payment_unmatched")
    assert (item.gig_id, item.stripe_payment_intent_id, item.amount) == (payment.gig_id, payment.stripe_payment_intent_id, D("150.00"))
    assert result.flagged == 1


def test_a_success_the_handler_cannot_apply_is_flagged(db_session, monkeypatch):
    payment = _unpaid(db_session)
    fake = FakeStripe([_pi(payment.stripe_payment_intent_id)])
    monkeypatch.setattr("app.services.stripe_reconcile.apply_missed_success", lambda db, pi: True)

    run(db_session, gateway=fake, now=NOW)
    db_session.commit()

    [item] = _items(db_session, "stripe_success_not_recorded")
    assert item.gig_id == payment.gig_id


def test_one_failure_does_not_stop_the_rest(db_session, monkeypatch):
    first, second = _unpaid(db_session), _unpaid(db_session)
    fake = FakeStripe([_pi(first.stripe_payment_intent_id), _pi(second.stripe_payment_intent_id)])
    real = stripe_reconcile.apply_missed_success

    def flaky(db, pi):
        if pi.id == first.stripe_payment_intent_id:
            raise RuntimeError("boom")
        return real(db, pi)

    monkeypatch.setattr("app.services.stripe_reconcile.apply_missed_success", flaky)

    result = run(db_session, gateway=fake, now=NOW)
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(StripePayment, second.id).status == PaymentStatus.succeeded
    assert [i.stripe_payment_intent_id for i in _items(db_session, "stripe_reconcile_error")] == [first.stripe_payment_intent_id]
    assert result.recorded == 1


def test_an_extras_purchase_paid_at_stripe_is_recorded_too(db_session):
    from app.models.gallery import ClientSelection, ProofGallery, ProofGalleryStatus, SelectionStatus, UpsellPurchase, UpsellPurchaseStatus

    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="100.00")
    gallery = ProofGallery(
        gig_id=gig.id, pro_user_id=pro, client_user_id=gig.client_user_id, status=ProofGalleryStatus.published,
        included_photos=10, extra_photo_price=D("5.00"), currency="EUR",
    )
    db_session.add(gallery)
    db_session.flush()
    selection = ClientSelection(gallery_id=gallery.id, client_user_id=gig.client_user_id, version=1, status=SelectionStatus.submitted)
    db_session.add(selection)
    db_session.flush()
    upsell = UpsellPurchase(
        gallery_id=gallery.id, selection_id=selection.id, extra_count=2, amount=D("10.00"), currency="EUR",
        status=UpsellPurchaseStatus.pending, stripe_payment_intent_id="pi_upsell_missed", created_at=NOW - timedelta(minutes=30),
    )
    db_session.add(upsell)
    db_session.commit()

    result = run(db_session, gateway=FakeStripe([_pi("pi_upsell_missed", amount_cents=1000)]), now=NOW)
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(UpsellPurchase, upsell.id).status == UpsellPurchaseStatus.succeeded
    assert result.recorded == 1


def test_without_stripe_configured_it_records_a_run_and_calls_nothing(db_session, monkeypatch):
    monkeypatch.setattr(stripe_reconcile.settings, "stripe_secret_key", "")

    result = run(db_session, now=NOW)

    assert result.error == "stripe_not_configured" and result.checked == 0


def test_the_job_runs_on_the_interval_setting():
    from app.core.config import get_settings
    from app.tasks.celery_app import celery_app

    entry = celery_app.conf.beat_schedule["stripe-reconcile"]
    assert entry["task"] == "app.tasks.scheduled.stripe_reconcile"
    assert entry["schedule"] == timedelta(seconds=get_settings().stripe_reconcile_interval_seconds)
    assert get_settings().stripe_reconcile_interval_seconds == 900


def test_admin_sees_the_last_run(client, db_session):
    run(db_session, gateway=FakeStripe([_pi("pi_nobody_knows_2", amount_cents=500)]), now=NOW, dry_run=True)
    db_session.commit()

    body = client.get("/v1/admin/money-attention", headers=ADMIN).json()

    last = body["stripe_check"]
    assert last["dry_run"] is True and last["flagged"] == 1 and last["error"] is None
    assert last["finished_at"] is not None
