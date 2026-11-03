"""The apps' bell: how many notifications are unread, in all or of one
kind (the dot on My orders counts unread Shelf order updates), marking
one kind read, and Shelf links the apps can open."""
import uuid

from app.services.notifications import enqueue_notification
from app.tasks.outbox_tasks import dispatch_outbox_events_task

from tests.test_notifications_v1 import _ensure_user


def _notify(db, user, notification_type, ref=None, action=None):
    enqueue_notification(
        db, user_id=user, notification_type=notification_type, reference_id=ref or str(uuid.uuid4()),
        payload={"title": "T", "body": "B", **({"action": action} if action else {})},
    )
    db.commit()


def _h(user):
    return {"X-User-Id": str(user)}


def _count(client, user, **params):
    resp = client.get("/v1/me/notifications/unread-count", headers=_h(user), params=params)
    assert resp.status_code == 200, resp.text
    return resp.json()["count"]


def test_the_unread_count_counts_only_unread_and_only_theirs(client, db_session):
    me, other = uuid.uuid4(), uuid.uuid4()
    _ensure_user(db_session, me, "me@example.com")
    _ensure_user(db_session, other, "other@example.com")
    for _ in range(3):
        _notify(db_session, me, "booking.request_received")
    _notify(db_session, other, "booking.request_received")
    dispatch_outbox_events_task(limit=100)

    assert _count(client, me) == 3
    first = client.get("/v1/me/notifications", headers=_h(me)).json()["items"][0]
    assert client.post(f"/v1/me/notifications/{first['id']}/read", headers=_h(me)).status_code == 204
    assert _count(client, me) == 2
    assert _count(client, other) == 1


def test_a_count_and_a_read_all_for_one_kind(client, db_session):
    me = uuid.uuid4()
    _ensure_user(db_session, me, "kind@example.com")
    _notify(db_session, me, "shelf.order_shipped")
    _notify(db_session, me, "shelf.order_delivered")
    _notify(db_session, me, "shelf.raww_expiring")
    _notify(db_session, me, "booking.request_received")
    dispatch_outbox_events_task(limit=100)

    assert _count(client, me, type_prefix="shelf.order_") == 2
    assert client.post("/v1/me/notifications/read-all", headers=_h(me), params={"type_prefix": "shelf.order_"}).status_code == 204

    assert _count(client, me, type_prefix="shelf.order_") == 0
    assert _count(client, me) == 2, "the rest stay unread"


def test_read_all_without_a_kind_reads_everything(client, db_session):
    me = uuid.uuid4()
    _ensure_user(db_session, me, "all@example.com")
    _notify(db_session, me, "shelf.order_shipped")
    _notify(db_session, me, "booking.request_received")
    dispatch_outbox_events_task(limit=100)

    client.post("/v1/me/notifications/read-all", headers=_h(me))

    assert _count(client, me) == 0


def test_shelf_links_reach_the_app_as_app_paths(client, db_session):
    """Links must start with "/" to survive; the Shelf's were rawwerspro://
    and were dropped, so its notifications opened nothing. They are app
    paths now."""
    from tests.test_shelf_gear_and_wishlist import _item
    from tests.test_shelf_orders import _order, _ready_pro

    pro = _ready_pro(db_session)
    _ensure_user(db_session, pro, "shelf@example.com")
    assert _order(client, pro, _item(db_session, title="Card")).status_code == 200
    dispatch_outbox_events_task(limit=100)

    [item] = client.get("/v1/me/notifications", headers=_h(pro)).json()["items"]
    assert item["type"] == "shelf.order_placed"
    assert item["action"] == {"label": "My orders", "url": "/wallet/shelf/orders"}
