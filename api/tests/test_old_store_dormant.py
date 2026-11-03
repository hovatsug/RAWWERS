"""The old commerce store is dormant: The Shelf replaces it (owner,
2026-11-03). With `ecom_enabled` off - the default - none of its user routes
can be reached; its admin routes stay admin-only."""
import uuid

import pytest

from app.models.admin import UserAccount, UserRole, UserRoleType

ROUTES = [
    ("get", "/v1/store/access", None),
    ("get", "/v1/store/products", None),
    ("get", f"/v1/store/products/{uuid.uuid4()}", None),
    ("post", "/v1/store/cart/items", {"product_id": str(uuid.uuid4()), "quantity": 1}),
    ("get", "/v1/store/cart", None),
    ("delete", f"/v1/store/cart/items/{uuid.uuid4()}", None),
    ("post", "/v1/store/checkout", {"shipping_address": {"name": "A", "line1": "X", "city": "Lisbon", "postal_code": "1000", "country": "PT"}}),
    ("get", "/v1/store/orders", None),
    ("get", f"/v1/store/orders/{uuid.uuid4()}", None),
]


@pytest.mark.parametrize(("method", "path", "body"), ROUTES)
def test_a_signed_in_pro_cannot_reach_the_old_store(client, db_session, method, path, body):
    pro = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro))
    db_session.flush()
    db_session.add(UserRole(user_id=pro, role=UserRoleType.pro))
    db_session.commit()

    resp = getattr(client, method)(path, headers={"X-User-Id": str(pro)}, **({"json": body} if body else {}))

    assert resp.status_code == 404, resp.text


def test_its_admin_routes_stay_admin_only(client, db_session):
    assert client.get("/v1/admin/store/products", headers={"X-User-Id": str(uuid.uuid4())}).status_code in (401, 403)
