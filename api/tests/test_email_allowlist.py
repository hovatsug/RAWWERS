"""Only approved emails send (owner's decision, 2026-11-03): nine types,
each with real text. Everything else stays in-app. No provider is wired:
these assert what would be handed to it."""
import uuid
from datetime import datetime, timezone

import pytest
from sqlalchemy import select

from app.models.communication import EmailMessage, Notification
from app.services import email_texts
from app.services.notifications import enqueue_notification
from app.tasks.outbox_tasks import dispatch_outbox_events_task

from tests.test_notifications_v1 import _ensure_user

NINE = {
    "email.verify", "email.reset", "auth.new_login", "booking.request_received", "booking.request_accepted",
    "payment.succeeded", "proofs.gallery_published", "payout.paid", "shelf.order_shipped",
}


class _Provider:
    provider_name = "test"

    def __init__(self):
        self.sent = []

    def send_template_email(self, *, email, template_key, subject, text_body, unsubscribe_url=None):
        self.sent.append({"to": email, "key": template_key, "subject": subject, "body": text_body, "unsubscribe": unsubscribe_url})
        return f"m{len(self.sent)}"

    def send_verification_email(self, **_):
        raise AssertionError("codes go out as approved text, through send_template_email")

    send_password_reset_email = send_verification_email


@pytest.fixture
def provider(monkeypatch):
    p = _Provider()
    monkeypatch.setattr("app.services.mail.get_mail_provider", lambda: p)
    return p


def _user(db, email=None):
    user = uuid.uuid4()
    _ensure_user(db, user, email or f"{user.hex[:8]}@example.com")
    return user


def _with_email(db, user, email):
    """An account the helpers made without an email, given one."""
    from app.models.admin import UserAccount

    account = db.get(UserAccount, user)
    if account is None:
        _ensure_user(db, user, email)
    else:
        account.email = email
        db.commit()


def _deliver(db):
    db.commit()
    dispatch_outbox_events_task(limit=200)
    db.expire_all()


def test_the_nine_are_the_approved_list_and_each_has_real_text():
    assert email_texts.APPROVED == NINE
    samples = {
        "email.verify": {"code": "482913", "minutes": 30},
        "email.reset": {"code": "771204", "minutes": 30},
        "auth.new_login": {"signed_in_at": "2026-11-04T14:05:00+00:00"},
        "booking.request_received": {"requested_start": "2026-11-20T10:00:00+00:00", "expires_at": "2026-11-06T09:00:00+00:00"},
        "booking.request_accepted": {"starts_at": "2026-11-20T10:00:00+00:00", "pro_name": "Ana"},
        "payment.succeeded": {"amount": "96.00", "currency": "EUR", "starts_at": "2026-11-20T10:00:00+00:00"},
        "proofs.gallery_published": {"starts_at": "2026-11-20T10:00:00+00:00"},
        "payout.paid": {"amount": "240.00", "currency": "EUR"},
        "shelf.order_shipped": {"item": "Card", "tracking_code": "RM123456GB", "tracking_url": "https://track.example/RM123456GB"},
    }
    for kind in NINE:
        subject, body = email_texts.render(kind, samples[kind], tz="Europe/London")
        assert subject and body and "{" not in subject + body and "None" not in subject + body, kind
    assert "482913" in email_texts.render("email.verify", samples["email.verify"])[0]
    assert "30 minutes" in email_texts.render("email.reset", samples["email.reset"])[1]
    assert "€96.00" in email_texts.render("payment.succeeded", samples["payment.succeeded"])[0]
    assert "Fri 20 Nov" in email_texts.render("payment.succeeded", samples["payment.succeeded"], tz="Europe/London")[1]
    assert "RM123456GB" in email_texts.render("shelf.order_shipped", samples["shelf.order_shipped"])[1]
    assert "€240.00" in email_texts.render("payout.paid", samples["payout.paid"])[0]


def test_text_reads_well_without_its_optional_facts():
    for kind in NINE - {"email.verify", "email.reset"}:
        subject, body = email_texts.render(kind, {})
        assert "{" not in subject + body and "None" not in subject + body, kind


def test_a_type_not_on_the_list_stays_in_app(db_session, provider):
    user = _user(db_session)
    enqueue_notification(db_session, user_id=user, notification_type="gear.verified", reference_id="g1", payload={"title": "Gear verified", "body": "B"})
    _deliver(db_session)

    assert provider.sent == []
    assert db_session.query(EmailMessage).filter_by(user_id=user).count() == 0
    assert db_session.query(Notification).filter_by(user_id=user).count() == 1
    from app.models.outbox import OutboxEvent, OutboxEventStatus

    [email_event] = db_session.execute(select(OutboxEvent).where(OutboxEvent.topic == "notify.send_email")).scalars().all()
    assert email_event.status == OutboxEventStatus.delivered, "skipped on purpose, not failing and retrying"


def test_an_approved_type_goes_with_its_approved_text(db_session, provider):
    user = _user(db_session, "pro@example.com")
    enqueue_notification(
        db_session, user_id=user, notification_type="booking.request_received", reference_id="b1",
        payload={"title": "New booking request", "body": "A client requested a booking.", "expires_at": "2026-11-06T09:00:00+00:00"},
    )
    _deliver(db_session)

    [mail] = provider.sent
    assert mail["subject"] == "New booking request on RAWWERS"
    assert "Reply by" in mail["body"] and mail["unsubscribe"]
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    assert row.subject == mail["subject"]


def test_the_verification_code_goes_as_approved_text(db_session, provider):
    from app.models.admin import UserAccount
    from app.services.auth_service import _create_email_verification

    user = _user(db_session, "new@example.com")
    code = _create_email_verification(db_session, db_session.get(UserAccount, user))
    _deliver(db_session)

    [mail] = provider.sent
    assert mail["key"] == "email.verify" and mail["subject"] == f"Your RAWWERS code: {code}"
    assert mail["unsubscribe"] is None


def test_launch_invites_and_waitlist_emails_are_not_on_the_list(db_session, provider):
    from app.services.outbox import enqueue_outbox_event

    enqueue_outbox_event(db_session, topic="launch.invite.email", payload={"email": "x@example.com", "code": "C"}, idempotency_key="i1", idempotency_scope="t")
    enqueue_outbox_event(db_session, topic="client.waitlist.confirmation_email", payload={"email": "y@example.com", "city": "L", "country": "PT"}, idempotency_key="w1", idempotency_scope="t")
    _deliver(db_session)

    assert provider.sent == []


def test_a_recorded_payment_tells_the_client_once(db_session, provider):
    from app.api.v1.webhooks import _apply_stripe_event
    from tests.test_stripe_reconcile import _unpaid

    payment = _unpaid(db_session)
    client_user = payment.client_user_id
    _with_email(db_session, client_user, "client@example.com")

    for _ in range(2):
        _apply_stripe_event(db_session, "payment_intent.succeeded", {"id": payment.stripe_payment_intent_id, "amount_received": 15000})
    _deliver(db_session)

    [note] = db_session.execute(select(Notification).where(Notification.user_id == client_user)).scalars().all()
    assert note.type == "payment.succeeded"
    [mail] = provider.sent
    assert mail["subject"] == "Payment received: €150.00"


def test_sending_the_gallery_tells_the_client(client, db_session, provider):
    from tests.test_proof_gallery import _create_gig, _create_photo_asset

    pro_id, client_id = str(uuid.uuid4()), uuid.uuid4()
    gig = _create_gig(db_session, str(client_id), pro_id)
    _with_email(db_session, client_id, "chooser@example.com")
    asset = _create_photo_asset(db_session, pro_id, with_wm=True)
    gallery_id = client.post(
        f"/v1/gigs/{gig.id}/proof-gallery", headers={"X-User-Id": pro_id}, json={"included_photos": 1, "extra_photo_price": "5.00"}
    ).json()["id"]
    client.post(f"/v1/proof-galleries/{gallery_id}/items", headers={"X-User-Id": pro_id}, json={"media_asset_ids": [str(asset.id)]})

    assert client.post(f"/v1/proof-galleries/{gallery_id}/publish", headers={"X-User-Id": pro_id}).status_code == 200
    client.post(f"/v1/proof-galleries/{gallery_id}/publish", headers={"X-User-Id": pro_id})
    _deliver(db_session)

    kinds = [n.type for n in db_session.execute(select(Notification).where(Notification.user_id == client_id)).scalars()]
    assert kinds.count("proofs.gallery_published") == 1, "sending twice is one email"
    assert [m["subject"] for m in provider.sent if m["key"] == "proofs.gallery_published"] == ["Your photos are ready to choose"]


def test_a_paid_payout_tells_the_photographer_once(db_session, provider):
    from app.services.payouts import approve_payout_request, mark_payout_paid_manual
    from tests.test_photographer_money import _earned, _payout, _settle, _pro

    pro = _pro(db_session)
    _with_email(db_session, pro, "payee@example.com")
    _earned(db_session, pro)
    _settle(db_session, pro)
    row = _payout(db_session, pro, "50.00")
    approve_payout_request(db_session, payout_request_id=row.id, admin_user_id=uuid.uuid4())
    mark_payout_paid_manual(db_session, payout_request_id=row.id, admin_user_id=uuid.uuid4(), reference={"bank": "x"})
    _deliver(db_session)

    notes = db_session.execute(select(Notification).where(Notification.user_id == pro, Notification.type == "payout.paid")).scalars().all()
    assert len(notes) == 1
    assert [m["subject"] for m in provider.sent if m["key"] == "payout.paid"] == ["Your payout of €50.00 is on its way"]


def test_a_shipped_shelf_order_email_carries_its_tracking(client, db_session, provider):
    from tests.test_shelf_gear_and_wishlist import _item
    from tests.test_shelf_orders import _order, _ready_pro

    pro = _ready_pro(db_session)
    _with_email(db_session, pro, "shelfpro@example.com")
    order = _order(client, pro, _item(db_session, title="Card")).json()
    admin = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}
    client.post(f"/v1/admin/shelf/orders/{order['id']}/ordered", headers=admin, json={"supplier_order_ref": "WEX-1"})
    client.post(f"/v1/admin/shelf/orders/{order['id']}/shipped", headers=admin, json={"tracking_code": "RM123456GB", "tracking_url": "https://track.example/RM1"})
    _deliver(db_session)

    shipped = [m for m in provider.sent if m["key"] == "shelf.order_shipped"]
    assert len(shipped) == 1 and "RM123456GB" in shipped[0]["body"] and "https://track.example/RM1" in shipped[0]["body"]
    assert not [m for m in provider.sent if m["key"] in ("shelf.order_placed", "shelf.order_ordered")], "the rest stay in-app"


def test_a_new_sign_in_says_when(db_session, provider):
    user = _user(db_session, "signin@example.com")
    enqueue_notification(
        db_session, user_id=user, notification_type="auth.new_login", reference_id="l1",
        payload={"signed_in_at": datetime(2026, 11, 4, 14, 5, tzinfo=timezone.utc).isoformat()},
    )
    _deliver(db_session)

    [mail] = provider.sent
    assert mail["subject"] == "New sign-in to your RAWWERS account" and "4 Nov" in mail["body"]
    assert mail["unsubscribe"] is None


def test_accepting_a_request_tells_the_client_to_pay(client, db_session, provider, monkeypatch):
    from types import SimpleNamespace

    from tests.test_answering_a_request import _accept, _request, _weekly_pro

    def fake(pi_id):
        return SimpleNamespace(id=pi_id, client_secret=f"{pi_id}_secret", status="requires_payment_method", amount=12000, currency="eur", metadata={})

    monkeypatch.setattr("app.services.payment_intents.stripe.PaymentIntent.create", lambda **kwargs: fake(f"pi_{uuid.uuid4().hex[:8]}"))
    monkeypatch.setattr("app.services.payment_intents.stripe.PaymentIntent.retrieve", fake)

    pro = _weekly_pro(db_session)
    request, start, end = _request(db_session, pro)
    _with_email(db_session, request.client_user_id, "booker@example.com")

    assert _accept(client, pro, request, start, end).status_code == 200
    _accept(client, pro, request, start, end)
    _deliver(db_session)

    notes = db_session.execute(
        select(Notification).where(Notification.user_id == request.client_user_id, Notification.type == "booking.request_accepted")
    ).scalars().all()
    assert len(notes) == 1, "accepting again is the same booking, and one email"
    [mail] = [m for m in provider.sent if m["key"] == "booking.request_accepted"]
    assert "accepted your booking" in mail["subject"] and "Pay by" in mail["body"]
