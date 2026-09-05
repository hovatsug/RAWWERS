import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.commerce import CommerceOrder, CommercePartner, PartnerAPIType, PriceRule, PriceRuleAppliesTo, PriceRuleDiscountType, Product, ProductStockStatus, StoreOrderStatus
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.reward import DiscountRedemption, DiscountRedemptionStatus, RedemptionContextType, RewardBalance
from app.services.store import sync_partner_products

ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"


class DummyStripePI:
    def __init__(self, pi_id: str = "pi_store_1", client_secret: str = "sec_store_1", status: str = "requires_payment_method"):
        self.id = pi_id
        self.client_secret = client_secret
        self.status = status


def _ensure_user_role(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()
    row = db_session.query(UserRole).filter_by(user_id=uid, role=role).first()
    if not row:
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()


def _set_pro_profile(db_session, pro_id: str, *, kyc: KYCStatus):
    uid = uuid.UUID(pro_id)
    profile = db_session.get(ProProfile, uid)
    if not profile:
        profile = ProProfile(user_id=uid)
        db_session.add(profile)
    profile.kyc_status = kyc
    db_session.commit()


def _set_tier(db_session, pro_id: str, tier: SkillTier, niche_slug: str = "portraits"):
    niche = db_session.query(Niche).filter_by(slug=niche_slug).first()
    assert niche is not None
    row = db_session.query(ProNicheSkill).filter_by(pro_user_id=uuid.UUID(pro_id), niche_id=niche.id).first()
    if not row:
        row = ProNicheSkill(
            pro_user_id=uuid.UUID(pro_id),
            niche_id=niche.id,
            capability_score=70,
            certification_score=70,
            confidence=Decimal("0.70"),
            tier=tier,
            evidence_gigs=10,
            evidence_reviews=5,
            evidence_portfolio=5,
            breakdown={},
        )
        db_session.add(row)
    row.tier = tier
    db_session.commit()


def _create_partner_product(db_session, sku: str = "SKU-1", price: str = "100.00"):
    partner = CommercePartner(name="EU Partner", country="PT", api_type=PartnerAPIType.manual, api_config={}, is_active=True)
    db_session.add(partner)
    db_session.flush()
    product = Product(
        partner_id=partner.id,
        partner_sku=sku,
        title="Prime Lens",
        description="Lens",
        category="lens",
        brand="Canon",
        images_media_asset_ids=[],
        attributes={},
        currency="EUR",
        msrp_price=Decimal("120.00"),
        partner_price=Decimal(price),
        is_available=True,
        stock_status=ProductStockStatus.in_stock,
        shipping_estimate_days=3,
    )
    db_session.add(product)
    db_session.commit()
    db_session.refresh(product)
    return partner, product


def _prepare_eligible_pro(db_session, pro_id: str, tier: SkillTier = SkillTier.skilled):
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _set_pro_profile(db_session, pro_id, kyc=KYCStatus.approved)
    _set_tier(db_session, pro_id, tier)


def test_store_access_gating_with_kyc_tier_and_override(client, db_session):
    pro_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _set_pro_profile(db_session, pro_id, kyc=KYCStatus.unsubmitted)
    _set_tier(db_session, pro_id, SkillTier.pro)

    denied_kyc = client.get("/v1/store/access", headers={"X-User-Id": pro_id})
    assert denied_kyc.status_code == 200
    assert denied_kyc.json()["allowed"] is False
    assert denied_kyc.json()["reason"] == "kyc_required"

    _set_pro_profile(db_session, pro_id, kyc=KYCStatus.approved)
    _set_tier(db_session, pro_id, SkillTier.rookie)
    denied_tier = client.get("/v1/store/access", headers={"X-User-Id": pro_id})
    assert denied_tier.status_code == 200
    assert denied_tier.json()["allowed"] is False
    assert denied_tier.json()["reason"] == "tier_below_policy"

    _set_tier(db_session, pro_id, SkillTier.skilled)
    allowed = client.get("/v1/store/access", headers={"X-User-Id": pro_id})
    assert allowed.status_code == 200
    assert allowed.json()["allowed"] is True

    block = client.post(
        f"/v1/admin/store/overrides/{pro_id}",
        headers={"X-User-Id": ADMIN_ID},
        json={"is_allowed": False, "reason": "ops", "expires_at": None},
    )
    assert block.status_code == 200
    denied_override = client.get("/v1/store/access", headers={"X-User-Id": pro_id})
    assert denied_override.json()["allowed"] is False
    assert denied_override.json()["reason"] == "override_blocked"

    allow_override = client.post(
        f"/v1/admin/store/overrides/{pro_id}",
        headers={"X-User-Id": ADMIN_ID},
        json={"is_allowed": True, "reason": "ops", "expires_at": (datetime.now(timezone.utc) + timedelta(days=1)).isoformat()},
    )
    assert allow_override.status_code == 200
    allowed_override = client.get("/v1/store/access", headers={"X-User-Id": pro_id})
    assert allowed_override.json()["allowed"] is True
    assert allowed_override.json()["reason"] == "override_allowed"


def test_price_rule_applied_correctly_by_tier(client, db_session, monkeypatch):
    pro_low = str(uuid.uuid4())
    pro_high = str(uuid.uuid4())
    _prepare_eligible_pro(db_session, pro_low, SkillTier.skilled)
    _prepare_eligible_pro(db_session, pro_high, SkillTier.pro)
    _, product = _create_partner_product(db_session, sku="SKU-TIER", price="100.00")
    db_session.add(
        PriceRule(
            partner_id=product.partner_id,
            applies_to=PriceRuleAppliesTo.sku,
            match_value="SKU-TIER",
            discount_type=PriceRuleDiscountType.percent,
            discount_value=Decimal("10.00"),
            min_tier=SkillTier.pro,
            is_active=True,
        )
    )
    db_session.commit()
    monkeypatch.setattr("app.services.store.stripe.PaymentIntent.create", lambda **kwargs: DummyStripePI(pi_id=str(uuid.uuid4())))

    for uid in [pro_low, pro_high]:
        client.post("/v1/store/cart/items", headers={"X-User-Id": uid}, json={"product_id": str(product.id), "quantity": 1})

    low_checkout = client.post(
        "/v1/store/checkout",
        headers={"X-User-Id": pro_low},
        json={"shipping_address": {"name": "A", "line1": "X", "city": "Lisbon", "postal_code": "1000", "country": "PT"}},
    )
    high_checkout = client.post(
        "/v1/store/checkout",
        headers={"X-User-Id": pro_high},
        json={"shipping_address": {"name": "B", "line1": "Y", "city": "Porto", "postal_code": "2000", "country": "PT"}},
    )
    assert low_checkout.status_code == 200
    assert high_checkout.status_code == 200
    assert Decimal(low_checkout.json()["order"]["total"]) == Decimal("100.00")
    assert Decimal(high_checkout.json()["order"]["total"]) == Decimal("90.00")


def test_cart_partner_restriction_enforced(client, db_session):
    pro_id = str(uuid.uuid4())
    _prepare_eligible_pro(db_session, pro_id, SkillTier.pro)
    _, product_1 = _create_partner_product(db_session, sku="SKU-A", price="50.00")
    _, product_2 = _create_partner_product(db_session, sku="SKU-B", price="70.00")

    first = client.post("/v1/store/cart/items", headers={"X-User-Id": pro_id}, json={"product_id": str(product_1.id), "quantity": 1})
    assert first.status_code == 200
    second = client.post("/v1/store/cart/items", headers={"X-User-Id": pro_id}, json={"product_id": str(product_2.id), "quantity": 1})
    assert second.status_code == 422


def test_checkout_creates_order_snapshot_and_reserves_points(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    _prepare_eligible_pro(db_session, pro_id, SkillTier.pro)
    _, product = _create_partner_product(db_session, sku="SKU-POINTS", price="100.00")
    db_session.add(RewardBalance(user_id=uuid.UUID(pro_id), balance=5000))
    db_session.commit()

    monkeypatch.setattr("app.services.store.stripe.PaymentIntent.create", lambda **kwargs: DummyStripePI(pi_id="pi_checkout_points", client_secret="sec_checkout"))
    client.post("/v1/store/cart/items", headers={"X-User-Id": pro_id}, json={"product_id": str(product.id), "quantity": 1})
    resp = client.post(
        "/v1/store/checkout",
        headers={"X-User-Id": pro_id},
        json={
            "shipping_address": {"name": "Pro", "line1": "Street 1", "city": "Lisbon", "postal_code": "1000", "country": "PT"},
            "points_to_spend": 1000,
        },
    )
    assert resp.status_code == 200
    payload = resp.json()
    order_id = payload["order"]["id"]
    assert payload["order"]["status"] == StoreOrderStatus.payment_pending.value
    assert Decimal(payload["order"]["subtotal"]) == Decimal("100.00")
    redemption = db_session.query(DiscountRedemption).filter_by(context_type=RedemptionContextType.commerce_order, context_id=uuid.UUID(order_id)).first()
    assert redemption is not None
    assert redemption.status == DiscountRedemptionStatus.reserved
    assert payload["order"]["points_spent"] > 0


def test_payment_success_finalizes_redemption_and_advances_order(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    _prepare_eligible_pro(db_session, pro_id, SkillTier.pro)
    _, product = _create_partner_product(db_session, sku="SKU-WH", price="100.00")
    db_session.add(RewardBalance(user_id=uuid.UUID(pro_id), balance=5000))
    db_session.commit()

    monkeypatch.setattr("app.services.store.stripe.PaymentIntent.create", lambda **kwargs: DummyStripePI(pi_id="pi_order_paid", client_secret="sec_order_paid"))
    monkeypatch.setattr("app.api.v1.webhooks.submit_order_to_partner_task.delay", lambda *_args, **_kwargs: (_ for _ in ()).throw(RuntimeError("no celery")))
    client.post("/v1/store/cart/items", headers={"X-User-Id": pro_id}, json={"product_id": str(product.id), "quantity": 1})
    checkout = client.post(
        "/v1/store/checkout",
        headers={"X-User-Id": pro_id},
        json={
            "shipping_address": {"name": "Pro", "line1": "Street 1", "city": "Lisbon", "postal_code": "1000", "country": "PT"},
            "points_to_spend": 500,
        },
    )
    order_id = checkout.json()["order"]["id"]

    event_payload = {
        "id": "evt_store_order_paid_1",
        "type": "payment_intent.succeeded",
        "data": {"object": {"id": "pi_order_paid"}},
    }
    wh1 = client.post("/v1/webhooks/stripe", json=event_payload)
    wh2 = client.post("/v1/webhooks/stripe", json=event_payload)
    assert wh1.status_code == 200
    assert wh2.status_code == 200

    order = db_session.get(CommerceOrder, uuid.UUID(order_id))
    assert order is not None
    assert order.status in {StoreOrderStatus.paid, StoreOrderStatus.submitted_to_partner}
    redemption = db_session.query(DiscountRedemption).filter_by(context_type=RedemptionContextType.commerce_order, context_id=order.id).first()
    assert redemption is not None
    assert redemption.status == DiscountRedemptionStatus.applied


def test_admin_sync_products_and_update_order_status(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    _prepare_eligible_pro(db_session, pro_id, SkillTier.pro)
    partner = CommercePartner(
        name="Feed Partner",
        country="DE",
        api_type=PartnerAPIType.feed_url,
        api_config={"feed_url": "https://example.com/feed.json", "disable_missing": True},
        is_active=True,
    )
    db_session.add(partner)
    db_session.commit()

    class DummyResp:
        headers = {"content-type": "application/json"}

        @staticmethod
        def raise_for_status():
            return None

        @staticmethod
        def json():
            return [
                {
                    "partner_sku": "SYNC-1",
                    "title": "Tripod Pro",
                    "category": "tripod",
                    "brand": "Manfrotto",
                    "currency": "EUR",
                    "partner_price": "89.00",
                    "stock_status": "in_stock",
                    "is_available": True,
                }
            ]

    monkeypatch.setattr("app.services.store.requests.get", lambda *_args, **_kwargs: DummyResp())
    monkeypatch.setattr("app.api.v1.store.sync_partner_products_task.delay", lambda pid: sync_partner_products(db_session, uuid.UUID(pid)))

    sync_resp = client.post(f"/v1/admin/store/partners/{partner.id}/sync", headers={"X-User-Id": ADMIN_ID})
    assert sync_resp.status_code == 200
    product = db_session.query(Product).filter_by(partner_id=partner.id, partner_sku="SYNC-1").first()
    assert product is not None

    monkeypatch.setattr("app.services.store.stripe.PaymentIntent.create", lambda **kwargs: DummyStripePI(pi_id="pi_admin_status", client_secret="sec_admin_status"))
    client.post("/v1/store/cart/items", headers={"X-User-Id": pro_id}, json={"product_id": str(product.id), "quantity": 1})
    checkout = client.post(
        "/v1/store/checkout",
        headers={"X-User-Id": pro_id},
        json={"shipping_address": {"name": "A", "line1": "X", "city": "Berlin", "postal_code": "10115", "country": "DE"}},
    )
    order_id = checkout.json()["order"]["id"]
    update_status = client.post(
        f"/v1/admin/store/orders/{order_id}/update-status",
        headers={"X-User-Id": ADMIN_ID},
        json={"status": "shipped", "tracking": {"carrier": "DHL", "tracking_number": "DHL123"}},
    )
    assert update_status.status_code == 200
    assert update_status.json()["status"] == "shipped"
