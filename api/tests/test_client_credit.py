"""Client credit (owner's decisions, 2026-11-07): what the client sees, the
checkout discount and its cap, the money rules, and the marketing budget.

Credit is shown in euros (points / 100). It is RAWWERS's marketing cost,
out of the platform's retained share: the photographer is paid on the
pre-discount price. At checkout it takes at most `max_discount_percent`
(10%) of the payment. Awards for marketing permissions draw on a monthly
budget (EUR 300, Europe/London months), checked under a lock."""
import threading
import uuid
from datetime import datetime, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models.communication import Notification
from app.models.gig import GigStatus, PaymentStatus, StripePayment
from app.models.reward import DiscountRedemption, DiscountRedemptionStatus, RewardEntryType, RewardLedgerEntry
from app.services import client_credit
from app.services.rewards import add_reward_entry
from app.tasks.outbox_tasks import dispatch_outbox_events_task

from tests.test_booking_close import _ensure_account
from tests.test_client_booking_pay import _booking_with_gig
from tests.test_download_payment_gate import FakeStripe
from tests.test_marketing_consent_client import _booking as _consent_booking
from tests.test_marketing_consent_client import _grant, _offer

ADMIN = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}


@pytest.fixture
def fake_stripe(monkeypatch) -> FakeStripe:
    fake = FakeStripe()
    for name in ("create", "retrieve", "modify", "cancel"):
        monkeypatch.setattr(f"stripe.PaymentIntent.{name}", getattr(fake, name))
    return fake


def _give(db, user, points, reference="admin", ref_id=None):
    entry = add_reward_entry(
        db, user_id=user, amount=points, entry_type=RewardEntryType.earn if points > 0 else RewardEntryType.adjustment,
        reference_type=reference, reference_id=ref_id or str(uuid.uuid4()),
    )
    db.commit()
    return entry


def _h(user):
    return {"X-User-Id": str(user)}


# --- what the client sees ------------------------------------------------------------------


def test_the_balance_and_history_are_in_euros_with_their_kinds(client, db_session, fake_stripe):
    client_id, gig, assets = _consent_booking(client, db_session, name="Ana Lopes")
    assert _grant(client, gig, client_id, assets[:1]).json()["credit_amount"] == "1.00"

    body = client.get("/v1/me/credit", headers=_h(client_id)).json()

    assert body["balance"] == "1.00" and body["max_discount_percent"] == 10
    [item] = body["items"]
    assert (item["kind"], item["amount"], item["photographer_first_name"]) == ("marketing_permission", "1.00", "Ana")


def test_used_and_returned_credit_show_in_the_history(client, db_session, fake_stripe):
    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    booking, gig = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    _give(db_session, uuid.UUID(user_id), 500)

    client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=_h(user_id))
    client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": False}, headers=_h(user_id))

    kinds = [(i["kind"], i["amount"]) for i in client.get("/v1/me/credit", headers=_h(user_id)).json()["items"]]
    assert kinds[:2] == [("returned", "5.00"), ("used_on_booking", "-5.00")]


# --- checkout ------------------------------------------------------------------------------


def test_credit_takes_at_most_10_percent_off_and_the_charge_follows(client, db_session, fake_stripe):
    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    booking, gig = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    _give(db_session, uuid.UUID(user_id), 3000)  # EUR 30, on a EUR 100 booking

    preview = client.get(f"/v1/client/bookings/{booking.id}/credit", headers=_h(user_id)).json()
    resp = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=_h(user_id)).json()

    assert (preview["discount"], preview["total"]) == ("10.00", "90.00")
    assert (resp["credit"], resp["amount"]) == ("10.00", "90.00")
    assert fake_stripe.creates[-1]["amount"] == 9000
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    assert payment.amount == Decimal("90.00")


def test_switching_credit_off_gives_it_back_and_restores_the_charge(client, db_session, fake_stripe):
    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    booking, gig = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    _give(db_session, uuid.UUID(user_id), 500)

    client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=_h(user_id))
    off = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": False}, headers=_h(user_id)).json()

    assert (off["credit"], off["amount"]) == ("0.00", "100.00")
    assert fake_stripe.modifies[-1][1] == 10000
    assert client.get("/v1/me/credit", headers=_h(user_id)).json()["balance"] == "5.00"


def test_the_cap_is_an_admin_setting(client, db_session, fake_stripe):
    assert client.put("/v1/admin/client-credit/settings", json={"max_discount_percent": 25}, headers=ADMIN).status_code == 200
    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    booking, _gig = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    _give(db_session, uuid.UUID(user_id), 3000)

    preview = client.get(f"/v1/client/bookings/{booking.id}/credit", headers=_h(user_id)).json()

    assert preview["discount"] == "25.00"
    assert client.put("/v1/admin/client-credit/settings", json={"max_discount_percent": 10}, headers=_h(user_id)).status_code in (401, 403)


def test_the_photographer_is_paid_on_the_price_before_credit(client, db_session, fake_stripe):
    """The money rule: EUR 150, EUR 5 credit. The client pays 145; the
    photographer's cash and RAWW credit are on 150; the 5 comes out of the
    platform's share."""
    from app.api.v1.webhooks import _apply_stripe_event
    from app.services.photographer_money import record_gig_earnings

    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    booking, gig = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    gig.amount_minimum, gig.retained_percent, gig.pro_raww_percent = Decimal("150.00"), 15, 5
    db_session.commit()
    _give(db_session, uuid.UUID(user_id), 500)
    resp = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=_h(user_id)).json()
    assert resp["amount"] == "145.00"

    _apply_stripe_event(db_session, "payment_intent.succeeded", {"id": resp["payment_intent_id"], "amount_received": 14500})
    db_session.commit()
    gig.status = GigStatus.completed
    record_gig_earnings(db_session, gig)
    db_session.commit()

    db_session.refresh(gig)
    assert (gig.final_gross, gig.final_pro_cash, gig.final_pro_raww, gig.final_platform_retained) == (
        Decimal("150.00"), Decimal("120.00"), Decimal("7.50"), Decimal("22.50"),
    )
    redemption = db_session.execute(select(DiscountRedemption).where(DiscountRedemption.context_id == gig.id)).scalar_one()
    assert redemption.status == DiscountRedemptionStatus.applied


def test_credit_set_aside_comes_back_when_the_booking_lapses_unpaid(client, db_session, fake_stripe):
    from datetime import timedelta

    from app.services.bookable_time import expire_unpaid_gigs

    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    booking, gig = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    _give(db_session, uuid.UUID(user_id), 500)
    client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=_h(user_id))

    expire_unpaid_gigs(db_session, now=datetime.now(timezone.utc) + timedelta(days=30))
    db_session.commit()

    assert client.get("/v1/me/credit", headers=_h(user_id)).json()["balance"] == "5.00"


# --- the marketing budget ------------------------------------------------------------------


def _budget(db, euros):
    client_credit.settings(db).monthly_marketing_credit_budget_eur = Decimal(euros)
    db.commit()


def test_an_award_exactly_at_the_budget_is_given_and_the_next_is_not(client, db_session, fake_stripe):
    _budget(db_session, "1.00")
    first_client, first_gig, first_assets = _consent_booking(client, db_session)
    second_client, second_gig, second_assets = _consent_booking(client, db_session)

    assert _grant(client, first_gig, first_client, first_assets[:1]).json()["credit_amount"] == "1.00"
    offer = _offer(client, second_gig, second_client).json()
    granted = _grant(client, second_gig, second_client, second_assets[:1])

    assert (offer["credit_available"], offer["credit_unavailable_reason"]) == (False, "budget")
    assert granted.status_code == 200 and granted.json()["credit"] == 0, "permission is still given, without credit"


def test_a_budget_of_zero_awards_nothing(client, db_session, fake_stripe):
    _budget(db_session, "0")
    client_id, gig, assets = _consent_booking(client, db_session)

    assert _offer(client, gig, client_id).json()["credit_unavailable_reason"] == "budget"
    assert _grant(client, gig, client_id, assets[:1]).json()["credit"] == 0


def test_the_monthly_cap_is_said_before_confirming(client, db_session, fake_stripe):
    first_client, gig, assets = _consent_booking(client, db_session)
    _grant(client, gig, first_client, assets[:1])
    for _ in range(2):
        _c, other, other_assets = _consent_booking(client, db_session)
        other.client_user_id = uuid.UUID(first_client)
        db_session.commit()
        _grant(client, other, first_client, other_assets[:1])
    _c, fourth, _a = _consent_booking(client, db_session)
    fourth.client_user_id = uuid.UUID(first_client)
    db_session.commit()

    assert _offer(client, fourth, first_client).json()["credit_unavailable_reason"] == "monthly_cap"


def test_concurrent_grants_never_exceed_the_budget(client, db_session, fake_stripe):
    """Ten awards of EUR 1 at once against a EUR 3 budget: three are given."""
    from app.db.session import SessionLocal
    from app.services.marketing_consent import _credit

    _budget(db_session, "3.00")
    bookings = [_consent_booking(client, db_session) for _ in range(10)]
    barrier = threading.Barrier(len(bookings))
    results: list[bool] = []

    def award(gig_id, client_id):
        db = SessionLocal()
        try:
            from app.models.gig import Gig

            gig = db.get(Gig, gig_id)
            barrier.wait()
            entry = _credit(db, gig, uuid.UUID(client_id), 12)
            db.commit()
            results.append(entry is not None)
        finally:
            db.close()

    threads = [threading.Thread(target=award, args=(gig.id, client_id)) for client_id, gig, _ in bookings]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    assert results.count(True) == 3
    assert client_credit.awarded_eur(db_session) == Decimal("3.00")


def test_the_month_is_londons_calendar_month():
    key, start, end = client_credit.month_bounds(datetime(2026, 11, 30, 23, 59, tzinfo=timezone.utc))
    assert (key, start, end) == ("2026-11", datetime(2026, 11, 1, tzinfo=timezone.utc), datetime(2026, 12, 1, tzinfo=timezone.utc))
    # Summer time: 31 July 23:30 UTC is already 1 August in London.
    assert client_credit.month_bounds(datetime(2026, 7, 31, 23, 30, tzinfo=timezone.utc))[0] == "2026-08"


def test_last_months_awards_do_not_count(client, db_session, fake_stripe):
    _budget(db_session, "1.00")
    first_client, first_gig, first_assets = _consent_booking(client, db_session)
    _grant(client, first_gig, first_client, first_assets[:1])
    for entry in db_session.execute(select(RewardLedgerEntry)).scalars():
        entry.created_at = datetime(2026, 1, 15, tzinfo=timezone.utc)
    db_session.commit()

    second_client, second_gig, second_assets = _consent_booking(client, db_session)
    assert _grant(client, second_gig, second_client, second_assets[:1]).json()["credit_amount"] == "1.00"


def test_admins_are_told_at_80_and_100_percent_once_each(client, db_session, fake_stripe):
    from app.core.config import get_settings

    _budget(db_session, "5.00")
    for _ in range(5):
        client_id, gig, assets = _consent_booking(client, db_session)
        _grant(client, gig, client_id, assets[:1])
    dispatch_outbox_events_task(limit=500)

    admin = next(iter(get_settings().admin_user_id_set()))
    titles = [n.title for n in db_session.execute(select(Notification).where(Notification.user_id == admin, Notification.type == "admin.marketing_budget")).scalars()]
    assert sorted(titles) == ["Marketing credit budget at 100%", "Marketing credit budget at 80%"]


def test_each_award_tells_the_client_once(client, db_session, fake_stripe):
    client_id, gig, assets = _consent_booking(client, db_session)
    _grant(client, gig, client_id, assets[:1])
    _grant(client, gig, client_id, assets[1:2])
    dispatch_outbox_events_task(limit=500)

    notes = db_session.execute(select(Notification).where(Notification.user_id == uuid.UUID(client_id), Notification.type == "reward.credit_earned")).scalars().all()
    assert [n.title for n in notes] == ["You earned €1.00 credit"]


def test_a_grant_without_credit_is_recorded(client, db_session, fake_stripe):
    from app.models.discovery import AnalyticsEvent

    _budget(db_session, "0")
    client_id, gig, assets = _consent_booking(client, db_session)
    _grant(client, gig, client_id, assets[:1])

    event = db_session.execute(select(AnalyticsEvent).where(AnalyticsEvent.event_name == "consent.granted_without_credit")).scalar_one()
    assert event.properties["reason"] == "budget"


def test_the_admin_month(client, db_session, fake_stripe):
    _budget(db_session, "300.00")
    client_id, gig, assets = _consent_booking(client, db_session)
    _grant(client, gig, client_id, assets[:1])

    body = client.get("/v1/admin/client-credit/budget", headers=ADMIN).json()

    assert (body["budget"], body["awarded"], body["remaining"], body["outstanding"]) == ("300.00", "1.00", "299.00", "1.00")
    assert client.get("/v1/admin/client-credit/budget", headers=_h(client_id)).status_code in (401, 403)


def test_the_same_award_delivered_twice_is_one_notice(client, db_session, fake_stripe):
    client_id, gig, assets = _consent_booking(client, db_session)
    _grant(client, gig, client_id, assets[:1])
    entry = db_session.execute(select(RewardLedgerEntry).where(RewardLedgerEntry.reference_type == "marketing_consent")).scalar_one()

    client_credit.notify_credit_earned(db_session, entry)
    db_session.commit()
    dispatch_outbox_events_task(limit=500)

    notes = db_session.execute(select(Notification).where(Notification.user_id == uuid.UUID(client_id), Notification.type == "reward.credit_earned")).scalars().all()
    assert len(notes) == 1
