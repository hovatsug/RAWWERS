"""Any reduction of what a client owes after paying goes through one function.

`apply_price_reduction` sets the final price (from the pricing code, never
its own arithmetic), brings the photographer's earnings and $RAWW down to it,
and refunds the client everything they paid beyond it through the reconciled
refund path - keyed to the reduction, so applying it twice refunds once.

The owner's test booking is the first case: a portraits package of 20 photos
at EUR 4.80 (EUR 79.74 paid), 14 delivered, 11 chosen (EUR 52.43). It became a
refund of EUR 27.31 - 15.96 because 6 photos were never delivered, 11.35
because the client chose 3 fewer than were delivered - and earnings of
41.95 instead of 63.79.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from types import SimpleNamespace

import pytest
from sqlalchemy import select

from app.core.errors import APIError
from app.models.admin import AdminAuditLog, MoneyAttentionItem, RefundCase, UserAccount
from app.models.gallery import ClientSelection, ClientSelectionItem, ProofGallery, ProofGalleryItem, ProofGalleryStatus, SelectionStatus
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.models.price_reduction import DeliveryReviewPolicy, PriceReduction, PriceReductionReason
from app.services.gallery_completion import is_selection_fully_paid
from app.services.niche_catalog import ensure_initial_niches, get_active_niche_by_slug
from app.services.package_pricing import compute_package_total
from app.services.photographer_money import photographer_money
from app.services.price_reduction import ReductionLine, adjust_raww_to_value, apply_price_reduction
from tests.test_booking_close import _create_photo_asset

ADMIN = "00000000-0000-0000-0000-0000000000aa"
D = Decimal


@pytest.fixture
def refunds(monkeypatch):
    """Stripe's refund call, recorded. Never reaches Stripe."""
    made = []

    def create(**kwargs):
        made.append(kwargs)
        return SimpleNamespace(id=f"re_{len(made)}_{uuid.uuid4().hex[:6]}", status="pending")

    monkeypatch.setattr("app.services.price_reduction.stripe.Refund.create", create)
    return made


def _account(db) -> uuid.UUID:
    uid = uuid.uuid4()
    db.add(UserAccount(user_id=uid))
    db.flush()
    return uid


def _booking(db, *, included=20, delivered=14, selected=11, entry_rate="4.80") -> tuple[Gig, ProofGallery, ClientSelection]:
    ensure_initial_niches(db)
    niche = get_active_niche_by_slug(db, "portraits")
    client_id, pro_id = _account(db), _account(db)
    deposit = compute_package_total(db, niche_id=niche.id, entry_rate=D(entry_rate), photo_count=included)
    gig = Gig(
        client_user_id=client_id, pro_user_id=pro_id, niche_id=niche.id, status=GigStatus.paid, currency="EUR",
        amount_minimum=deposit, entry_rate=D(entry_rate), amount_platform_fee=(deposit * D("0.2")).quantize(D("0.01")),
        amount_pro_gross=(deposit * D("0.8")).quantize(D("0.01")), fee_percent=20, retained_percent=15, pro_raww_percent=5,
        client_credit_percent=0, meta={},
    )
    db.add(gig)
    db.flush()
    db.add(StripePayment(gig_id=gig.id, kind=StripePaymentKind.base, client_user_id=client_id, status=PaymentStatus.succeeded,
                         stripe_payment_intent_id=f"pi_base_{gig.id.hex}", amount=deposit, currency="EUR", meta={}))
    gallery = ProofGallery(gig_id=gig.id, pro_user_id=pro_id, client_user_id=client_id, included_photos=included,
                           extra_photo_price=D("7.00"), currency="EUR", status=ProofGalleryStatus.published)
    db.add(gallery)
    db.commit()
    assets = [_create_photo_asset(db, str(pro_id)) for _ in range(delivered)]
    for i, asset in enumerate(assets):
        db.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=i + 1))
    selection = ClientSelection(gallery_id=gallery.id, client_user_id=client_id, version=1, status=SelectionStatus.draft)
    db.add(selection)
    db.flush()
    for asset in assets[:selected]:
        db.add(ClientSelectionItem(selection_id=selection.id, media_asset_id=asset.id))
    db.commit()
    return gig, gallery, selection


def _price(db, gig, n):
    return compute_package_total(db, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=n)


def _submit(client, gallery, gig):
    resp = client.post(f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": str(gig.client_user_id)})
    assert resp.status_code == 200, resp.text
    return resp.json()


def _reductions(db, gig):
    db.expire_all()
    return db.execute(select(PriceReduction).where(PriceReduction.gig_id == gig.id)).scalars().all()


def _items(db, gig, kind):
    db.expire_all()
    return db.execute(select(MoneyAttentionItem).where(MoneyAttentionItem.gig_id == gig.id, MoneyAttentionItem.kind == kind)).scalars().all()


# --- the owner's booking ------------------------------------------------------------------


def test_the_owners_booking_refunds_the_difference_by_reason(client, db_session, refunds):
    gig, gallery, _ = _booking(db_session)
    p20, p14, p11 = _price(db_session, gig, 20), _price(db_session, gig, 14), _price(db_session, gig, 11)

    _submit(client, gallery, gig)

    [reduction] = _reductions(db_session, gig)
    assert reduction.lines == [
        {"reason_code": "photographer_non_delivery", "amount": str(p20 - p14)},
        {"reason_code": "client_selected_fewer", "amount": str(p14 - p11)},
    ]
    assert (reduction.from_amount, reduction.to_amount, reduction.refund_amount) == (p20, p11, p20 - p11)
    assert [r["amount"] for r in refunds] == [int((p20 - p11) * 100)]
    if p20 == D("79.74"):  # the curve the owner's booking was priced on
        assert (p20 - p14, p14 - p11, p20 - p11) == (D("15.96"), D("11.35"), D("27.31"))


def test_one_refund_case_carries_the_breakdown(client, db_session, refunds):
    gig, gallery, _ = _booking(db_session)
    _submit(client, gallery, gig)

    [case] = db_session.execute(select(RefundCase).where(RefundCase.gig_id == gig.id)).scalars().all()
    assert case.meta["source"] == "price_reduction"
    assert [line["reason_code"] for line in case.meta["lines"]] == ["photographer_non_delivery", "client_selected_fewer"]


def test_the_photographer_earns_on_what_was_chosen(client, db_session, refunds):
    gig, gallery, _ = _booking(db_session)
    _submit(client, gallery, gig)

    db_session.refresh(gig)
    assert gig.status == GigStatus.completed
    p11 = _price(db_session, gig, 11)
    assert gig.final_gross == p11
    assert photographer_money(db_session, gig.pro_user_id).lifetime == gig.final_pro_cash


def test_short_delivery_is_flagged_for_an_admin_never_a_strike(client, db_session, refunds):
    from app.models.admin import ProFaultEvent

    gig, gallery, _ = _booking(db_session)
    _submit(client, gallery, gig)

    [flag] = _items(db_session, gig, "photographer_short_delivery")
    assert "Delivered 14 of 20" in flag.note
    assert db_session.execute(select(ProFaultEvent)).first() is None


def test_the_short_delivery_threshold_is_policy(client, db_session, refunds):
    db_session.add(DeliveryReviewPolicy(id=1, shortfall_min_photos=7))
    db_session.commit()
    gig, gallery, _ = _booking(db_session)  # 6 short
    _submit(client, gallery, gig)

    assert _items(db_session, gig, "photographer_short_delivery") == []


def test_choosing_fewer_from_a_full_gallery_is_only_the_clients_choice(client, db_session, refunds):
    gig, gallery, _ = _booking(db_session, delivered=20, selected=15)
    _submit(client, gallery, gig)

    [reduction] = _reductions(db_session, gig)
    assert [line["reason_code"] for line in reduction.lines] == ["client_selected_fewer"]
    assert _items(db_session, gig, "photographer_short_delivery") == []


def test_choosing_everything_reduces_nothing(client, db_session, refunds):
    gig, gallery, _ = _booking(db_session, delivered=20, selected=20)
    _submit(client, gallery, gig)
    assert _reductions(db_session, gig) == [] and refunds == []


def test_the_refund_does_not_lock_the_finals(client, db_session, refunds):
    gig, gallery, selection = _booking(db_session)
    _submit(client, gallery, gig)
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    payment.amount_refunded = _price(db_session, gig, 20) - _price(db_session, gig, 11)  # the refund settled
    db_session.commit()

    db_session.refresh(selection)
    assert is_selection_fully_paid(db_session, gig=gig, gallery=gallery, selection=selection)


def test_the_quote_shows_the_refund_before_confirming(client, db_session):
    gig, gallery, _ = _booking(db_session)
    resp = client.get(f"/v1/proof-galleries/{gallery.id}/selection-quote", headers={"X-User-Id": str(gig.client_user_id)})

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert D(body["amount_total"]) == _price(db_session, gig, 11)
    assert D(body["refund_amount"]) == _price(db_session, gig, 20) - _price(db_session, gig, 11)
    assert D(body["amount_due"]) == D("0.00")


# --- the function's rules -------------------------------------------------------------------


def _completed(db, **kw) -> Gig:
    gig, _, _ = _booking(db, **kw)
    return gig


def _reduce(db, gig, *, to, lines, key="k1", note="Photos missing"):
    return apply_price_reduction(
        db, gig, new_final=D(to), lines=[ReductionLine(c, D(a)) for c, a in lines], note=note, source="admin",
        key=key, actor_user_id=uuid.UUID(ADMIN),
    )


def test_applying_the_same_reduction_twice_refunds_once(db_session, refunds):
    gig = _completed(db_session)
    p20 = _price(db_session, gig, 20)
    first = _reduce(db_session, gig, to=p20 - 10, lines=[("admin_goodwill", "10.00")])
    again = _reduce(db_session, gig, to=p20 - 10, lines=[("admin_goodwill", "10.00")])
    db_session.commit()

    assert first.id == again.id and len(refunds) == 1


def test_reasons_are_data(db_session, refunds):
    gig = _completed(db_session)
    p20 = _price(db_session, gig, 20)
    with pytest.raises(APIError):
        _reduce(db_session, gig, to=p20 - 10, lines=[("made_up_reason", "10.00")])

    from app.services.price_reduction import ensure_default_reasons

    ensure_default_reasons(db_session)
    db_session.get(PriceReductionReason, "admin_goodwill").is_active = False
    db_session.commit()
    with pytest.raises(APIError):
        _reduce(db_session, gig, to=p20 - 10, lines=[("admin_goodwill", "10.00")])


def test_the_reasons_must_add_up_and_a_note_is_required(db_session, refunds):
    gig = _completed(db_session)
    p20 = _price(db_session, gig, 20)
    with pytest.raises(APIError):
        _reduce(db_session, gig, to=p20 - 10, lines=[("admin_goodwill", "9.00")])
    with pytest.raises(APIError):
        _reduce(db_session, gig, to=p20 - 10, lines=[("admin_goodwill", "10.00")], note="  ")
    assert refunds == []


def test_a_reduction_after_a_partial_refund_refunds_only_the_rest(db_session, refunds):
    gig = _completed(db_session)
    p20 = _price(db_session, gig, 20)
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    payment.amount_refunded = D("5.00")
    db_session.add(RefundCase(gig_id=gig.id, requested_by_user_id=uuid.UUID(ADMIN), stripe_payment_intent_id=payment.stripe_payment_intent_id,
                              status="succeeded", amount=D("5.00"), currency="EUR", meta={"stripe_payment_id": str(payment.id)}))
    db_session.commit()

    reduction = _reduce(db_session, gig, to=p20 - 10, lines=[("admin_goodwill", "10.00")])

    assert reduction.refund_amount == D("5.00")


def test_an_open_chargeback_refuses_and_says_why(db_session, refunds):
    gig = _completed(db_session)
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    payment.status = PaymentStatus.disputed
    db_session.commit()

    with pytest.raises(APIError) as refused:
        _reduce(db_session, gig, to=_price(db_session, gig, 20) - 10, lines=[("admin_goodwill", "10.00")])
    assert refused.value.code == "chargeback_open"
    assert refunds == []


def test_a_refused_refund_leaves_the_client_owed_visibly(db_session, monkeypatch):
    def refuse(**kwargs):
        raise RuntimeError("card expired")

    monkeypatch.setattr("app.services.price_reduction.stripe.Refund.create", refuse)
    gig = _completed(db_session)
    reduction = _reduce(db_session, gig, to=_price(db_session, gig, 20) - 10, lines=[("admin_goodwill", "10.00")])
    db_session.commit()

    assert reduction.refund_amount == D("0.00")
    [owed] = _items(db_session, gig, "client_owed")
    assert owed.amount == D("10.00") and "admin_goodwill" in owed.note


def test_several_payments_refund_the_most_recent_first_and_say_so(db_session, refunds):
    gig = _completed(db_session)
    later = StripePayment(gig_id=gig.id, kind=StripePaymentKind.difference, client_user_id=gig.client_user_id, status=PaymentStatus.succeeded,
                          stripe_payment_intent_id=f"pi_diff_{gig.id.hex}", amount=D("8.00"), currency="EUR", meta={},
                          created_at=datetime.now(timezone.utc) + timedelta(minutes=5))
    db_session.add(later)
    gig.amount_final = _price(db_session, gig, 20) + D("8.00")
    db_session.commit()

    _reduce(db_session, gig, to=_price(db_session, gig, 20) - 2, lines=[("admin_goodwill", "10.00")])
    db_session.commit()

    assert [r["payment_intent"] for r in refunds] == [later.stripe_payment_intent_id, f"pi_base_{gig.id.hex}"]
    assert [r["amount"] for r in refunds] == [800, 200]
    audit = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.action == "price_reduction_refund")).scalar_one()
    assert audit.meta["refund_order"] == "most recent payment first"


def test_a_reduction_leaves_the_status_alone(db_session, refunds):
    gig = _completed(db_session)
    _reduce(db_session, gig, to=_price(db_session, gig, 20) - 10, lines=[("admin_goodwill", "10.00")])
    assert gig.status == GigStatus.paid


def test_a_reduction_after_payout_owes_back_and_tells_an_admin(db_session, refunds):
    from app.models.payouts import EarningsLedgerEntry
    from app.services.payouts import approve_payout_request, create_payout_request, mark_payout_paid_manual, settle_due_earnings_entries
    from app.services.photographer_money import record_gig_earnings

    gig = _completed(db_session)
    gig.status = GigStatus.completed
    record_gig_earnings(db_session, gig)
    for row in db_session.execute(select(EarningsLedgerEntry)).scalars():
        row.available_at = datetime.now(timezone.utc) - timedelta(minutes=1)
    db_session.commit()
    settle_due_earnings_entries(db_session)
    cash = photographer_money(db_session, gig.pro_user_id).available
    payout = create_payout_request(db_session, pro_user_id=gig.pro_user_id, amount_eur=cash)
    approve_payout_request(db_session, payout_request_id=payout.id, admin_user_id=uuid.UUID(ADMIN))
    mark_payout_paid_manual(db_session, payout_request_id=payout.id, admin_user_id=uuid.UUID(ADMIN), reference={})
    db_session.commit()

    _reduce(db_session, gig, to=_price(db_session, gig, 20) - 20, lines=[("admin_goodwill", "20.00")])
    db_session.commit()

    money = photographer_money(db_session, gig.pro_user_id)
    assert money.available < 0 and money.withdrawable == D("0.00")
    [item] = _items(db_session, gig, "photographer_adjustment_owed")
    assert item.amount == money.adjustment_owed


# --- $RAWW --------------------------------------------------------------------------------


def _mint(db, gig, raww=108, on="79.74"):
    from app.models.proof_of_gigs import RawwMintEvent, RawwMintEventStatus

    mint = RawwMintEvent(event_type="gig.completed", pro_user_id=gig.pro_user_id, reference_type="gig", reference_id=gig.id,
                         raww_awarded=raww, multiplier_snapshot={"eur_value": on}, status=RawwMintEventStatus.minted)
    db.add(mint)
    db.commit()
    return mint


def _raww_balance(db, user_id):
    from app.models.reward import RewardLedgerEntry

    return sum(r.amount for r in db.execute(select(RewardLedgerEntry).where(RewardLedgerEntry.user_id == user_id)).scalars())


def test_raww_comes_down_in_proportion_once(db_session, refunds):
    gig = _completed(db_session)
    _mint(db_session, gig, raww=108, on=str(_price(db_session, gig, 20)))
    gig.amount_final = _price(db_session, gig, 11)
    db_session.commit()

    first = adjust_raww_to_value(db_session, gig)
    again = adjust_raww_to_value(db_session, gig)
    db_session.commit()

    keep = int(108 * _price(db_session, gig, 11) / _price(db_session, gig, 20))
    assert first == 108 - keep and again == 0
    assert _raww_balance(db_session, gig.pro_user_id) == -(108 - keep)


def test_a_full_refund_after_a_partial_reversal_takes_back_only_the_rest(db_session, refunds):
    from app.services.proof_of_gigs import reverse_raww_mints_for_refund

    gig = _completed(db_session)
    _mint(db_session, gig, raww=108, on=str(_price(db_session, gig, 20)))
    gig.amount_final = _price(db_session, gig, 11)
    db_session.commit()
    adjust_raww_to_value(db_session, gig)
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    payment.amount_refunded = payment.amount  # then refunded in full
    db_session.commit()
    reverse_raww_mints_for_refund(db_session, gig_id=gig.id, reason="full_refund")
    db_session.commit()

    assert _raww_balance(db_session, gig.pro_user_id) == -108


def test_raww_is_minted_on_the_final_price(db_session):
    from app.models.proof_of_gigs import RawwIssuanceEventType
    from app.services.proof_of_gigs import _resolve_context

    gig = _completed(db_session)
    gig.amount_final = _price(db_session, gig, 11)
    db_session.commit()

    context = _resolve_context(db_session, event_type=RawwIssuanceEventType.gig_completed, payload={"gig_id": str(gig.id)})

    assert context.eur_value == _price(db_session, gig, 11)


# --- the admin route ------------------------------------------------------------------------


def test_the_admin_previews_before_reducing(client, db_session, refunds):
    gig = _completed(db_session)
    p20 = _price(db_session, gig, 20)

    preview = client.post(
        f"/v1/admin/gigs/{gig.id}/price-reductions/preview", headers={"X-User-Id": ADMIN},
        json={"lines": [{"reason_code": "admin_goodwill", "amount": "10.00"}]},
    )
    assert preview.status_code == 200, preview.text
    body = preview.json()
    assert D(body["to_amount"]) == p20 - 10 and D(body["client_refund"]) == D("10.00")
    assert refunds == [] and _reductions(db_session, gig) == []

    applied = client.post(
        f"/v1/admin/gigs/{gig.id}/price-reductions", headers={"X-User-Id": ADMIN},
        json={"lines": [{"reason_code": "admin_goodwill", "amount": "10.00"}], "note": "Late delivery", "idempotency_key": "ui-1"},
    )
    assert applied.status_code == 200, applied.text
    assert len(refunds) == 1


def test_only_an_admin_may_reduce(client, db_session, refunds):
    gig = _completed(db_session)
    resp = client.post(
        f"/v1/admin/gigs/{gig.id}/price-reductions", headers={"X-User-Id": str(gig.client_user_id)},
        json={"lines": [{"reason_code": "admin_goodwill", "amount": "10.00"}], "note": "x", "idempotency_key": "ui-2"},
    )
    assert resp.status_code == 403
    assert refunds == []


def test_a_partial_refund_reverses_a_proportional_share_of_raww(db_session):
    from app.services.proof_of_gigs import reverse_raww_mints_for_refund

    gig = _completed(db_session)
    p20, p11 = _price(db_session, gig, 20), _price(db_session, gig, 11)
    _mint(db_session, gig, raww=108, on=str(p20))
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    payment.amount_refunded = p20 - p11  # part refunded
    db_session.commit()

    reverse_raww_mints_for_refund(db_session, gig_id=gig.id, reason="refund_or_dispute")
    db_session.commit()

    assert _raww_balance(db_session, gig.pro_user_id) == -(108 - int(108 * p11 / p20))


def test_the_client_sees_the_refund_and_why_in_plain_words(client, db_session, refunds):
    from app.api.v1.client_launch import _client_refunds

    gig, gallery, _ = _booking(db_session)
    _submit(client, gallery, gig)

    [refund] = _client_refunds(db_session, gig)
    assert refund["amount"] == _price(db_session, gig, 20) - _price(db_session, gig, 11)
    assert refund["reasons"] == [
        "Fewer photos were delivered than your package included.",
        "You chose fewer photos than your deposit covered.",
    ]


def test_a_reduction_brings_raww_down_with_the_price(db_session, refunds):
    gig = _completed(db_session)
    p20 = _price(db_session, gig, 20)
    _mint(db_session, gig, raww=108, on=str(p20))

    _reduce(db_session, gig, to=p20 / 2, lines=[("admin_goodwill", str(p20 - p20 / 2))])
    db_session.commit()

    assert _raww_balance(db_session, gig.pro_user_id) < 0
