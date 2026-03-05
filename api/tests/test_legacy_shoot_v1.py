import uuid
from types import SimpleNamespace

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.legacy_shoot import LegacyBooking, LegacyBookingStatus
from app.models.niche import Niche, ProNicheSkill, SkillTier


def _ensure_user(db_session, user_id: uuid.UUID, *, email: str, roles: list[UserRoleType]) -> None:
    row = db_session.get(UserAccount, user_id)
    if row is None:
        db_session.add(UserAccount(user_id=user_id, email=email))
    for role in roles:
        exists = db_session.query(UserRole).filter_by(user_id=user_id, role=role).first()
        if not exists:
            db_session.add(UserRole(user_id=user_id, role=role))
    db_session.commit()


def _ensure_niche(db_session, slug: str = "portrait") -> uuid.UUID:
    row = db_session.query(Niche).filter_by(slug=slug).first()
    if row:
        return row.id
    niche = Niche(slug=slug, name=slug.title(), description="")
    db_session.add(niche)
    db_session.commit()
    return niche.id


def _mock_stripe(monkeypatch):
    def _create(**kwargs):
        return SimpleNamespace(
            id=f"pi_{uuid.uuid4().hex[:8]}",
            client_secret="cs_test_123",
            amount=kwargs.get("amount", 0),
            status="requires_payment_method",
            customer=None,
        )

    def _retrieve(_id):
        return SimpleNamespace(id=_id, client_secret="cs_test_123", amount=149000, status="requires_payment_method")

    monkeypatch.setattr("app.services.payment_intents.stripe.PaymentIntent.create", _create)
    monkeypatch.setattr("app.services.payment_intents.stripe.PaymentIntent.retrieve", _retrieve)


def test_legacy_marketing_consent_defaults_false(client, db_session, monkeypatch):
    _mock_stripe(monkeypatch)
    client_id = uuid.uuid4()
    _ensure_user(db_session, client_id, email="legacy-client@example.com", roles=[UserRoleType.client])

    resp = client.post("/v1/legacy/checkout", headers={"X-User-Id": str(client_id)}, json={"payment_mode": "full"})
    assert resp.status_code == 200
    legacy_booking_id = resp.json()["legacy_booking_id"]

    detail = client.get(f"/v1/legacy/{legacy_booking_id}", headers={"X-User-Id": str(client_id)})
    assert detail.status_code == 200
    assert detail.json()["marketing_consent"] is False
    assert detail.json()["marketing_channels"] == []

    opt_in = client.put(
        f"/v1/legacy/{legacy_booking_id}/marketing-consent",
        headers={"X-User-Id": str(client_id)},
        json={"consent": True, "channels": ["website", "social"]},
    )
    assert opt_in.status_code == 200
    assert opt_in.json()["consent"] is True
    assert set(opt_in.json()["channels"]) == {"website", "social"}


def test_legacy_brief_schema_validation(client, db_session, monkeypatch):
    _mock_stripe(monkeypatch)
    client_id = uuid.uuid4()
    _ensure_user(db_session, client_id, email="legacy-brief@example.com", roles=[UserRoleType.client])

    checkout = client.post("/v1/legacy/checkout", headers={"X-User-Id": str(client_id)}, json={"payment_mode": "deposit"})
    legacy_booking_id = checkout.json()["legacy_booking_id"]

    bad = client.put(
        f"/v1/legacy/{legacy_booking_id}/brief",
        headers={"X-User-Id": str(client_id)},
        json={"answers": {"identity": {"name": "A"}}, "privacy_level": "private"},
    )
    assert bad.status_code == 422

    good = client.put(
        f"/v1/legacy/{legacy_booking_id}/brief",
        headers={"X-User-Id": str(client_id)},
        json={
            "answers": {
                "identity": {"name": "A", "nickname": "B", "origin": "PT", "values": ["family"]},
                "milestones": ["m1"],
                "people": ["p1"],
                "what_to_preserve": ["legacy"],
                "desired_output": {"storybook": True, "video": True, "voice": True},
                "reference_style": ["classic"],
                "boundaries": ["none"],
                "consent_for_public_use": False,
            },
            "privacy_level": "private",
            "tone": "cinematic",
        },
    )
    assert good.status_code == 200


def test_pro_assignment_eligibility_enforced(client, db_session, monkeypatch):
    _mock_stripe(monkeypatch)
    admin_id = uuid.UUID("00000000-0000-0000-0000-0000000000aa")
    client_id = uuid.uuid4()
    pro_id = uuid.uuid4()
    _ensure_user(db_session, admin_id, email="admin@example.com", roles=[UserRoleType.admin])
    _ensure_user(db_session, client_id, email="legacy-client2@example.com", roles=[UserRoleType.client])
    _ensure_user(db_session, pro_id, email="legacy-pro@example.com", roles=[UserRoleType.pro])

    niche_id = _ensure_niche(db_session, "portrait")
    db_session.add(
        ProNicheSkill(
            pro_user_id=pro_id,
            niche_id=niche_id,
            tier=SkillTier.pro,
            capability_score=80,
            certification_score=20,
            verified=False,
            score=45,
        )
    )
    db_session.commit()

    checkout = client.post("/v1/legacy/checkout", headers={"X-User-Id": str(client_id)}, json={"payment_mode": "full"})
    legacy_booking_id = checkout.json()["legacy_booking_id"]

    denied = client.post(
        f"/v1/admin/legacy/{legacy_booking_id}/assign-pro",
        headers={"X-User-Id": str(admin_id)},
        json={"pro_user_id": str(pro_id), "admin_override": False},
    )
    assert denied.status_code == 403

    allowed = client.post(
        f"/v1/admin/legacy/{legacy_booking_id}/assign-pro",
        headers={"X-User-Id": str(admin_id)},
        json={"pro_user_id": str(pro_id), "admin_override": True},
    )
    assert allowed.status_code == 200


def test_vault_access_control_and_review_workflow(client, db_session, monkeypatch):
    _mock_stripe(monkeypatch)
    admin_id = uuid.UUID("00000000-0000-0000-0000-0000000000aa")
    client_id = uuid.uuid4()
    pro_id = uuid.uuid4()
    other_id = uuid.uuid4()
    _ensure_user(db_session, admin_id, email="admin2@example.com", roles=[UserRoleType.admin])
    _ensure_user(db_session, client_id, email="legacy-client3@example.com", roles=[UserRoleType.client])
    _ensure_user(db_session, pro_id, email="legacy-pro2@example.com", roles=[UserRoleType.pro])
    _ensure_user(db_session, other_id, email="legacy-other@example.com", roles=[UserRoleType.client])

    niche_id = _ensure_niche(db_session, "portrait")
    db_session.add(
        ProNicheSkill(
            pro_user_id=pro_id,
            niche_id=niche_id,
            tier=SkillTier.master,
            capability_score=95,
            certification_score=60,
            verified=True,
            score=95,
        )
    )
    db_session.commit()

    checkout = client.post("/v1/legacy/checkout", headers={"X-User-Id": str(client_id)}, json={"payment_mode": "deposit"})
    legacy_booking_id = checkout.json()["legacy_booking_id"]

    assign = client.post(
        f"/v1/admin/legacy/{legacy_booking_id}/assign-pro",
        headers={"X-User-Id": str(admin_id)},
        json={"pro_user_id": str(pro_id), "admin_override": False},
    )
    assert assign.status_code == 200

    upload = client.post(
        f"/v1/pro/legacy/{legacy_booking_id}/vault/upload",
        headers={"X-User-Id": str(pro_id)},
        json={"type": "storybook_pdf", "content_type": "application/pdf", "bytes": 1234},
    )
    assert upload.status_code == 200
    vault_item_id = upload.json()["vault_item_id"]

    denied = client.get(f"/v1/legacy/{legacy_booking_id}/vault", headers={"X-User-Id": str(other_id)})
    assert denied.status_code == 403

    submit = client.post(
        f"/v1/pro/legacy/{legacy_booking_id}/reviews/submit",
        headers={"X-User-Id": str(pro_id)},
        json={"stage": "final_delivery", "vault_item_ids": [vault_item_id]},
    )
    assert submit.status_code == 200
    review_id = submit.json()["id"]

    respond = client.post(
        f"/v1/legacy/{legacy_booking_id}/reviews/{review_id}/respond",
        headers={"X-User-Id": str(client_id)},
        json={"response": "approved", "notes": "looks great"},
    )
    assert respond.status_code == 200

    booking = db_session.get(LegacyBooking, uuid.UUID(legacy_booking_id))
    assert booking is not None
    assert booking.status == LegacyBookingStatus.delivered
