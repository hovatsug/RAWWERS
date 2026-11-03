"""Shipping addresses are encrypted on the server, for prints too.

Before 2026-11-03 the prints path stored whatever "encrypted_fields" the
client sent, which the server could neither check nor read.
"""
import uuid

import pytest
from cryptography.fernet import Fernet
from sqlalchemy import select

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.prints import ShippingAddress
from app.services import addresses
from app.services.prints_fulfillment import upsert_shipping_address

ADDRESS = {"name": "Ana", "line1": "Rua das Flores 1", "city": "Lisbon", "postal_code": "1000-001", "country": "PT"}


def test_a_print_address_is_encrypted_on_the_server(db_session):
    user = uuid.uuid4()
    row = upsert_shipping_address(db_session, user_id=user, payload=ADDRESS)
    db_session.commit()

    stored = db_session.execute(select(ShippingAddress).where(ShippingAddress.id == row.id)).scalar_one()
    assert "Flores" not in str(stored.encrypted_fields)
    assert addresses.decrypt(stored.encrypted_fields)["line1"] == "Rua das Flores 1"
    assert stored.postal_code_hash and "1000" not in stored.postal_code_hash


def test_a_client_sent_encrypted_blob_is_refused_for_prints(db_session):
    with pytest.raises(APIError) as refused:
        upsert_shipping_address(db_session, user_id=uuid.uuid4(), payload={**ADDRESS, "encrypted_fields": {"line1": "Street"}})
    assert refused.value.status_code == 422


def test_a_saved_print_address_can_be_reused_by_its_owner_only(db_session):
    owner = uuid.uuid4()
    row = upsert_shipping_address(db_session, user_id=owner, payload=ADDRESS)

    assert upsert_shipping_address(db_session, user_id=owner, payload={"address_id": str(row.id)}).id == row.id
    with pytest.raises(APIError):
        upsert_shipping_address(db_session, user_id=uuid.uuid4(), payload={"address_id": str(row.id)})


def test_production_needs_its_own_key(monkeypatch):
    monkeypatch.setattr(get_settings(), "app_env", "production")
    monkeypatch.setattr(get_settings(), "address_encryption_keys", "")
    with pytest.raises(RuntimeError):
        addresses.encrypt(ADDRESS)


def test_keys_rotate_newest_first_and_old_addresses_still_read(monkeypatch):
    old, new = Fernet.generate_key().decode(), Fernet.generate_key().decode()
    monkeypatch.setattr(get_settings(), "address_encryption_keys", old)
    stored = addresses.encrypt(ADDRESS)

    monkeypatch.setattr(get_settings(), "address_encryption_keys", f"{new},{old}")
    assert addresses.decrypt(stored)["city"] == "Lisbon"
    monkeypatch.setattr(get_settings(), "address_encryption_keys", new)
    assert addresses.decrypt(stored) is None, "without the old key it cannot be read"


def test_a_legacy_client_blob_reads_as_no_address():
    assert addresses.decrypt({"line1": "Street"}) is None
