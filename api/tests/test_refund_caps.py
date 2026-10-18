"""No refund above what is still left on a payment.

Each refund path checked only the original amount: an admin refund the
amount paid, a dispute resolution the amount authorised, a refund case
nothing at all. A dispute refund then an admin refund, or a client refund
then a dispute refund, could each ask for the whole payment again - Stripe
refused the second, as an error, or our records claimed money that never
moved. Now every path caps at what is left: the payment's amount less every
refund already made or under way against it. A refund that failed, or was
cancelled or rejected, leaves its amount refundable.
"""
import uuid
from decimal import Decimal

import pytest
from app.models.admin import Dispute, DisputeCategory, DisputeStatus, RefundCase, RefundCaseStatus, RefundPaymentScope
from app.models.gig import GigStatus
from sqlalchemy import select

from tests.test_refund_routes import _paid_booking, _refund, stripe_refunds  # noqa: F401 - fixture

ADMIN = "00000000-0000-0000-0000-0000000000aa"  # the suite's admin (conftest)


@pytest.fixture
def stripe_all(stripe_refunds, monkeypatch):
    monkeypatch.setattr("app.api.v1.admin.stripe.Refund.create", stripe_refunds.create)
    return stripe_refunds


def _earlier_refund(db_session, gig, amount, status=RefundCaseStatus.refunded, *, legacy=False):
    """A refund already made (or under way) against the booking's first payment."""
    payment_intent = f"pi_{gig.id.hex[:10]}_0"
    payment_id = next(p.id for p in gig.payments if p.stripe_payment_intent_id == payment_intent)
    case = RefundCase(
        gig_id=gig.id,
        payment_scope=RefundPaymentScope.booking_payment,
        reference_id=gig.id,
        # Admin refunds made before this change recorded only the payment row.
        stripe_payment_intent_id=None if legacy else payment_intent,
        amount_authorized=Decimal("100.00"),
        amount_refunded=amount if status == RefundCaseStatus.refunded else Decimal("0.00"),
        status=status,
        amount=amount,
        currency="EUR",
        meta={"stripe_payment_id": str(payment_id)} if legacy else {},
    )
    db_session.add(case)
    db_session.commit()
    return case


def _admin_refund(client, gig, amount=None):
    body = {"reason": "Support"}
    if amount is not None:
        body["amount"] = str(amount)
    return client.post(f"/v1/admin/gigs/{gig.id}/refunds", headers={"X-User-Id": ADMIN}, json=body)


def _dispute(db_session, gig, client_id) -> Dispute:
    dispute = Dispute(
        gig_id=gig.id,
        opened_by_user_id=uuid.UUID(client_id),
        against_user_id=gig.pro_user_id,
        status=DisputeStatus.awaiting_admin,
        category=DisputeCategory.no_show,
        currency="EUR",
        summary="The photographer did not come",
        resolution={},
        meta={},
    )
    db_session.add(dispute)
    db_session.commit()
    return dispute


def _resolve(client, dispute, decision="full_refund", amount=None):
    body = {"decision": decision, "rationale": "Checked"}
    if amount is not None:
        body["amount"] = str(amount)
    return client.post(f"/v1/admin/disputes/{dispute.id}/resolve", headers={"X-User-Id": ADMIN}, json=body)


def _dispute_cases(db_session, dispute) -> list[RefundCase]:
    db_session.expire_all()
    return db_session.execute(select(RefundCase).where(RefundCase.dispute_id == dispute.id)).scalars().all()


def _minor(call) -> int:
    return call["amount"]


# --- admin refunds ----------------------------------------------------------------------


def test_an_admin_refund_cannot_go_above_what_is_left(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("30.00"))

    resp = _admin_refund(client, gig, amount=Decimal("80.00"))

    assert resp.status_code == 422, resp.text
    assert resp.json()["error"]["code"] == "refund_exceeds_remaining"
    assert stripe_all.calls == []


def test_an_admin_refund_without_an_amount_refunds_what_is_left(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("30.00"))

    resp = _admin_refund(client, gig)

    assert resp.status_code == 200, resp.text
    [call] = stripe_all.calls
    assert _minor(call) == 7000


def test_a_refund_under_way_counts_as_much_as_one_made(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("100.00"), status=RefundCaseStatus.pending)

    resp = _admin_refund(client, gig, amount=Decimal("10.00"))

    assert resp.status_code == 422, resp.text
    assert stripe_all.calls == []


@pytest.mark.parametrize("status", [RefundCaseStatus.failed, RefundCaseStatus.cancelled, RefundCaseStatus.rejected])
def test_a_refund_that_never_happened_leaves_its_amount_refundable(client, db_session, stripe_all, status):
    gig, _client, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("100.00"), status=status)

    resp = _admin_refund(client, gig, amount=Decimal("100.00"))

    assert resp.status_code == 200, resp.text
    assert _minor(stripe_all.calls[0]) == 10000


def test_an_older_admin_refund_recorded_without_its_payment_intent_still_counts(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("60.00"), legacy=True)

    resp = _admin_refund(client, gig, amount=Decimal("50.00"))

    assert resp.status_code == 422, resp.text


def test_an_admin_refund_names_the_payment_it_refunds(client, db_session, stripe_all):
    """So the next refund - and the one-active-refund rule - can see it."""
    gig, _client, _pro = _paid_booking(db_session)

    resp = _admin_refund(client, gig, amount=Decimal("40.00"))

    assert resp.status_code == 200, resp.text
    case = db_session.get(RefundCase, uuid.UUID(resp.json()["id"]))
    assert case.stripe_payment_intent_id == f"pi_{gig.id.hex[:10]}_0"


def test_across_payments_the_cap_is_per_payment(client, db_session, stripe_all):
    """100 + 20 paid, 100 of the first already back: 20 is left, all of it
    on the second payment."""
    gig, _client, _pro = _paid_booking(db_session, payments=2)
    _earlier_refund(db_session, gig, Decimal("100.00"))

    assert _admin_refund(client, gig, amount=Decimal("21.00")).status_code == 422
    resp = _admin_refund(client, gig, amount=Decimal("20.00"))

    assert resp.status_code == 200, resp.text
    [call] = stripe_all.calls
    assert call["payment_intent"] == f"pi_{gig.id.hex[:10]}_1"
    assert _minor(call) == 2000


# --- dispute resolutions ----------------------------------------------------------------


def test_a_full_refund_decision_refunds_only_what_is_left(client, db_session, stripe_all):
    gig, client_id, _pro = _paid_booking(db_session, status=GigStatus.disputed)
    _earlier_refund(db_session, gig, Decimal("80.00"))
    dispute = _dispute(db_session, gig, client_id)

    assert _resolve(client, dispute).status_code == 200

    [case] = _dispute_cases(db_session, dispute)
    assert case.amount == Decimal("20.00")


def test_a_named_amount_above_what_is_left_is_capped(client, db_session, stripe_all):
    gig, client_id, _pro = _paid_booking(db_session, status=GigStatus.disputed)
    _earlier_refund(db_session, gig, Decimal("80.00"))
    dispute = _dispute(db_session, gig, client_id)

    assert _resolve(client, dispute, decision="partial_refund", amount=Decimal("50.00")).status_code == 200

    assert [c.amount for c in _dispute_cases(db_session, dispute)] == [Decimal("20.00")]


def test_nothing_left_means_no_refund_case(client, db_session, stripe_all):
    gig, client_id, _pro = _paid_booking(db_session, status=GigStatus.disputed)
    _earlier_refund(db_session, gig, Decimal("100.00"))
    dispute = _dispute(db_session, gig, client_id)

    assert _resolve(client, dispute).status_code == 200

    assert _dispute_cases(db_session, dispute) == []


# --- refund cases, when the money is asked for -----------------------------------------


def test_a_case_that_no_longer_fits_is_not_sent_to_stripe(client, db_session, stripe_all):
    """Two cases each sized when nothing had been refunded: the second must
    not go out once the first has taken the money."""
    from app.services.disputes import initiate_refund_case

    gig, _client, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("70.00"))
    late = _earlier_refund(db_session, gig, Decimal("50.00"), status=RefundCaseStatus.pending)

    initiate_refund_case(db_session, late.id)
    db_session.commit()

    assert stripe_all.calls == []
    db_session.expire_all()
    row = db_session.get(RefundCase, late.id)
    assert row.status == RefundCaseStatus.failed
    assert row.meta.get("failure_reason") == "exceeds_remaining"


def test_a_case_that_fits_goes_out(client, db_session, stripe_all):
    from app.services.disputes import initiate_refund_case

    gig, _client, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("50.00"))
    case = _earlier_refund(db_session, gig, Decimal("50.00"), status=RefundCaseStatus.pending)

    initiate_refund_case(db_session, case.id)
    db_session.commit()

    [call] = stripe_all.calls
    assert _minor(call) == 5000


# --- the client's own refund -------------------------------------------------------------


def test_the_client_refund_asks_only_for_what_is_left_and_records_it(client, db_session, stripe_all):
    gig, client_id, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("30.00"))

    resp = _refund(client, gig, client_id)

    assert resp.status_code == 200, resp.text
    [call] = stripe_all.calls
    assert _minor(call) == 7000
    db_session.expire_all()
    [case] = db_session.execute(
        select(RefundCase).where(RefundCase.gig_id == gig.id, RefundCase.status == RefundCaseStatus.refund_initiated)
    ).scalars().all()
    assert case.amount == Decimal("70.00")
    assert case.meta["stripe_refund_id"] == resp.json()["refund_id"]


def test_nothing_left_for_the_client_to_refund(client, db_session, stripe_all):
    gig, client_id, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("100.00"))

    resp = _refund(client, gig, client_id)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "nothing_to_refund"
    assert stripe_all.calls == []


def test_the_client_asking_again_gets_the_same_refund(client, db_session, stripe_all):
    gig, client_id, _pro = _paid_booking(db_session)
    first = _refund(client, gig, client_id)

    second = _refund(client, gig, client_id)

    assert second.status_code == 200, second.text
    assert second.json()["refund_ids"] == first.json()["refund_ids"]
    assert len(stripe_all.by_key) == 1


def test_an_extra_images_dispute_refunds_only_what_is_left_of_the_purchase(client, db_session, stripe_all):
    """A purchase is one payment with no allocation step, so the cap is the
    only thing between a full-refund decision and its original total."""
    from app.models.client_rewards_pricing import ExtraImagePurchase, ExtraImagePurchaseStatus

    gig, client_id, pro_id = _paid_booking(db_session)
    purchase = ExtraImagePurchase(
        gig_id=gig.id,
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=None,
        included_images=1,
        selected_images=3,
        extra_images=2,
        unit_price_applied=Decimal("10.00"),
        unit_price_configured=Decimal("10.00"),
        policy_unit_price_min=Decimal("0.00"),
        policy_unit_price_max=None,
        subtotal=Decimal("20.00"),
        points_spent=0,
        discounts_total=Decimal("0.00"),
        total=Decimal("20.00"),
        stripe_payment_intent_id=f"pi_extra_{gig.id.hex[:8]}",
        status=ExtraImagePurchaseStatus.paid,
        share_link_id=None,
        meta={},
    )
    db_session.add(purchase)
    db_session.flush()
    earlier = _earlier_refund(db_session, gig, Decimal("15.00"))
    earlier.stripe_payment_intent_id = purchase.stripe_payment_intent_id
    earlier.payment_scope = RefundPaymentScope.extra_image_purchase
    dispute = _dispute(db_session, gig, client_id)
    dispute.extra_purchase_id = purchase.id
    db_session.commit()

    assert _resolve(client, dispute).status_code == 200

    assert [c.amount for c in _dispute_cases(db_session, dispute)] == [Decimal("5.00")]
