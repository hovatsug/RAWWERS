"""People messaging people: a client writes to a photographer before any
booking, the photographer sees it and answers, and each side knows what it
has not read.

Opening a conversation used to require the AI assistant to be switched on:
with the AI flags off it answered 503, so turning the assistant off turned
messaging off. Human messaging is now independent of the assistant, and the
first tests here run with it switched off.

The assistant, when on, is held for two minutes while the photographer is
online, so a person gets the first chance to answer. "Online" is
presence.photographer_is_online, which reads the app's heartbeat; the tests
near the end drive it with real heartbeats, not a stand-in.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from app.models.chat import ChatMessage, ChatSenderType, ChatThread, ChatThreadStatus
from app.models.ops import FeatureFlag, FeatureFlagScope
from app.models.outbox import OutboxEvent
from sqlalchemy import select

from tests.test_client_launch import _enable_city_and_flags, _seed_pro, _seed_user
from app.models.admin import UserRoleType


def _set_flag(db_session, key: str, enabled: bool) -> None:
    row = db_session.query(FeatureFlag).filter_by(key=key).one_or_none()
    if row is None:
        row = FeatureFlag(key=key, scope=FeatureFlagScope.global_scope, rules={})
        db_session.add(row)
    row.is_enabled = enabled
    db_session.commit()


def _ai(db_session, on: bool) -> None:
    _set_flag(db_session, "ai_chat_kill_switch", not on)
    for key in ("ai_chat_enabled_global", "ai_chat_enabled_city", "ai_chat_enabled_pro"):
        _set_flag(db_session, key, on)


def _people(db_session):
    _enable_city_and_flags(db_session)
    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    _seed_user(db_session, client_id, [UserRoleType.client])
    return pro_id, client_id


def _open(client, client_id, pro_id) -> str:
    resp = client.post("/v1/chat/threads", headers={"X-User-Id": client_id}, json={"pro_user_id": pro_id})
    assert resp.status_code == 200, resp.text
    return resp.json()["id"]


def _say(client, user_id, thread_id, text, *, as_pro=False):
    path = f"/v1/pro/chat/threads/{thread_id}/messages" if as_pro else f"/v1/chat/threads/{thread_id}/messages"
    resp = client.post(path, headers={"X-User-Id": user_id}, json={"content": text})
    assert resp.status_code == 200, resp.text
    return resp.json()


def _pro_inbox(client, pro_id) -> dict[str, dict]:
    resp = client.get("/v1/pro/chat/threads", headers={"X-User-Id": pro_id})
    assert resp.status_code == 200, resp.text
    return {t["id"]: t for t in resp.json()}


def _ai_events(db_session, thread_id) -> list[OutboxEvent]:
    db_session.expire_all()
    return [
        e
        for e in db_session.execute(select(OutboxEvent).where(OutboxEvent.topic == "ai.reply.generate")).scalars()
        if e.payload.get("thread_id") == thread_id
    ]


# --- people, with the assistant off -------------------------------------------


def test_a_client_can_message_a_photographer_with_the_assistant_switched_off(client, db_session):
    _ai(db_session, on=False)
    pro_id, client_id = _people(db_session)

    thread_id = _open(client, client_id, pro_id)
    _say(client, client_id, thread_id, "Are you free on the 14th?")

    inbox = _pro_inbox(client, pro_id)
    assert inbox[thread_id]["unread_count"] == 1
    assert inbox[thread_id]["last_message_preview"] == "Are you free on the 14th?"
    _say(client, pro_id, thread_id, "I am - morning or afternoon?", as_pro=True)

    mine = client.get("/v1/chat/threads", headers={"X-User-Id": client_id}).json()["items"]
    assert [t["unread_count"] for t in mine if t["id"] == thread_id] == [1]
    assert _ai_events(db_session, thread_id) == [], "nothing asks the assistant while it is off"
    messages = db_session.execute(select(ChatMessage).where(ChatMessage.thread_id == uuid.UUID(thread_id))).scalars().all()
    assert not [m for m in messages if m.sender_type == ChatSenderType.system and "AI assistant" in m.content], (
        "no 'you are chatting with an AI assistant' notice when no assistant will answer"
    )


def test_reading_a_conversation_clears_its_unread_count_for_that_side_only(client, db_session):
    _ai(db_session, on=False)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    _say(client, client_id, thread_id, "Hello")
    _say(client, client_id, thread_id, "Are you there?")
    assert _pro_inbox(client, pro_id)[thread_id]["unread_count"] == 2

    resp = client.post(f"/v1/chat/threads/{thread_id}/read", headers={"X-User-Id": pro_id})

    assert resp.status_code == 200, resp.text
    assert _pro_inbox(client, pro_id)[thread_id]["unread_count"] == 0
    _say(client, pro_id, thread_id, "Yes, I'm here.", as_pro=True)
    assert _pro_inbox(client, pro_id)[thread_id]["unread_count"] == 0, "your own messages are never unread"
    _say(client, client_id, thread_id, "One more thing")
    assert _pro_inbox(client, pro_id)[thread_id]["unread_count"] == 1, "only what arrived after reading"


def test_the_photographers_badge_counts_conversations_with_something_unread(client, db_session):
    _ai(db_session, on=False)
    pro_id, first = _people(db_session)
    second = str(uuid.uuid4())
    _seed_user(db_session, second, [UserRoleType.client])
    a, b = _open(client, first, pro_id), _open(client, second, pro_id)
    _say(client, first, a, "Hi")
    _say(client, first, a, "Hi again")
    _say(client, second, b, "Hello")

    badge = client.get("/v1/pro/chat/unread", headers={"X-User-Id": pro_id})

    assert badge.status_code == 200, badge.text
    assert badge.json() == {"threads": 2, "messages": 3}
    client.post(f"/v1/chat/threads/{a}/read", headers={"X-User-Id": pro_id})
    assert client.get("/v1/pro/chat/unread", headers={"X-User-Id": pro_id}).json() == {"threads": 1, "messages": 1}


def test_the_inbox_is_ordered_by_the_latest_message_not_by_when_it_was_opened(client, db_session):
    _ai(db_session, on=False)
    pro_id, first = _people(db_session)
    second = str(uuid.uuid4())
    _seed_user(db_session, second, [UserRoleType.client])
    older, newer = _open(client, first, pro_id), _open(client, second, pro_id)
    _say(client, second, newer, "Hi")
    _say(client, first, older, "Still interested?")

    ids = [t["id"] for t in client.get("/v1/pro/chat/threads", headers={"X-User-Id": pro_id}).json()]

    assert ids[:2] == [older, newer]


def test_a_stranger_cannot_mark_someone_elses_conversation_read(client, db_session):
    _ai(db_session, on=False)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    stranger = str(uuid.uuid4())
    _seed_user(db_session, stranger, [UserRoleType.client])

    resp = client.post(f"/v1/chat/threads/{thread_id}/read", headers={"X-User-Id": stranger})

    assert resp.status_code == 403


# --- the assistant, held while the photographer is online ---------------------


@pytest.fixture
def fake_model(monkeypatch):
    """Counts model calls instead of making them."""
    from app.services import ai_concierge

    calls = []
    real = ai_concierge._generate_with_fallback

    def generate(prompt_messages):
        calls.append(prompt_messages)
        return real(prompt_messages)  # the mock provider in tests

    monkeypatch.setattr(ai_concierge, "_generate_with_fallback", generate)
    return calls


def _online(monkeypatch, online: bool):
    from app.services import presence

    monkeypatch.setattr(presence, "photographer_is_online", lambda db, pro_user_id: online)


def _fire(db_session, event: OutboxEvent) -> None:
    """What the dispatcher does with the event once it is due."""
    from app.tasks.outbox_tasks import _dispatch_event

    _dispatch_event(db_session, event.topic, event.payload)
    db_session.commit()


def _ai_messages(db_session, thread_id) -> list[ChatMessage]:
    db_session.expire_all()
    return db_session.execute(
        select(ChatMessage).where(ChatMessage.thread_id == uuid.UUID(thread_id), ChatMessage.sender_type == ChatSenderType.ai)
    ).scalars().all()


def test_with_no_heartbeat_nobody_is_online(db_session):
    from app.services.presence import photographer_is_online

    assert photographer_is_online(db_session, uuid.uuid4()) is False


def test_with_the_photographer_offline_the_assistant_answers_at_once(client, db_session, monkeypatch, fake_model):
    _ai(db_session, on=True)
    _online(monkeypatch, False)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    _say(client, client_id, thread_id, "How much for portraits?")

    [*_, event] = _ai_events(db_session, thread_id)
    assert event.next_attempt_at <= datetime.now(timezone.utc) + timedelta(seconds=5)


def test_while_the_photographer_is_online_the_assistant_waits_two_minutes(client, db_session, monkeypatch, fake_model):
    _ai(db_session, on=True)
    _online(monkeypatch, True)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    before = datetime.now(timezone.utc)
    _say(client, client_id, thread_id, "How much for portraits?")

    [*_, event] = _ai_events(db_session, thread_id)
    assert timedelta(seconds=110) <= event.next_attempt_at - before <= timedelta(seconds=130)


def test_if_nobody_answers_in_time_the_assistant_does_and_says_what_it_is(client, db_session, monkeypatch, fake_model):
    _ai(db_session, on=True)
    _online(monkeypatch, True)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    _say(client, client_id, thread_id, "How much for portraits?")
    [*_, event] = _ai_events(db_session, thread_id)

    _fire(db_session, event)

    [reply] = _ai_messages(db_session, thread_id)
    assert reply.sender_type == ChatSenderType.ai, "labelled as the assistant, never as the photographer"


def test_a_photographer_who_answers_during_the_hold_is_never_overtaken(client, db_session, monkeypatch, fake_model):
    _ai(db_session, on=True)
    _online(monkeypatch, True)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    _say(client, client_id, thread_id, "How much for portraits?")
    [*_, event] = _ai_events(db_session, thread_id)
    _say(client, pro_id, thread_id, "Hi! From EUR 120.", as_pro=True)

    _fire(db_session, event)

    assert fake_model == [], "checked before the model is asked - no call, no cost"
    assert _ai_messages(db_session, thread_id) == []


def test_a_photographer_who_answers_while_the_model_is_writing_is_not_overtaken(client, db_session, monkeypatch):
    """The second check, just before posting: the model can take seconds."""
    from app.services import ai_concierge

    _ai(db_session, on=True)
    _online(monkeypatch, True)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    _say(client, client_id, thread_id, "How much for portraits?")
    [*_, event] = _ai_events(db_session, thread_id)
    real = ai_concierge._generate_with_fallback

    def slow_model(prompt_messages):
        # The photographer replies while the model is still writing - from
        # their own request, as in production, so the dispatcher's copy of
        # the thread is stale.
        from tests.conftest import TestingSessionLocal

        with TestingSessionLocal() as theirs:
            thread = theirs.get(ChatThread, uuid.UUID(thread_id))
            thread.status = ChatThreadStatus.pro_active
            theirs.add(ChatMessage(thread_id=thread.id, sender_type=ChatSenderType.pro, sender_user_id=uuid.UUID(pro_id), content="Hi! From EUR 120.", meta={}))
            theirs.commit()
        return real(prompt_messages)

    monkeypatch.setattr(ai_concierge, "_generate_with_fallback", slow_model)

    _fire(db_session, event)

    assert _ai_messages(db_session, thread_id) == []


def test_a_conversation_the_photographer_has_taken_over_gets_no_assistant(client, db_session, monkeypatch, fake_model):
    _ai(db_session, on=True)
    _online(monkeypatch, False)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    _say(client, pro_id, thread_id, "Hi, I'll take it from here.", as_pro=True)
    _say(client, client_id, thread_id, "Great - how much?")

    assert [e for e in _ai_events(db_session, thread_id) if e.payload.get("after_message_id")] == []


# --- who may read and write, and how much ------------------------------------


def test_only_the_two_people_in_a_conversation_can_read_or_write_it(client, db_session):
    _ai(db_session, on=False)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    stranger, other_pro = str(uuid.uuid4()), str(uuid.uuid4())
    _seed_user(db_session, stranger, [UserRoleType.client])
    _seed_pro(db_session, other_pro)

    assert client.get(f"/v1/chat/threads/{thread_id}", headers={"X-User-Id": stranger}).status_code == 403
    assert client.post(f"/v1/chat/threads/{thread_id}/messages", headers={"X-User-Id": stranger}, json={"content": "hi"}).status_code == 403
    # Another photographer cannot reach it through their own routes either.
    assert client.get(f"/v1/pro/chat/threads/{thread_id}", headers={"X-User-Id": other_pro}).status_code == 404
    assert client.post(f"/v1/pro/chat/threads/{thread_id}/messages", headers={"X-User-Id": other_pro}, json={"content": "hi"}).status_code == 404
    assert thread_id not in _pro_inbox(client, other_pro)


@pytest.mark.parametrize("as_pro", [False, True], ids=["client", "photographer"])
def test_a_message_longer_than_the_configured_cap_is_refused(client, db_session, as_pro):
    from app.core.config import get_settings

    _ai(db_session, on=False)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    cap = get_settings().max_chat_message_length
    path = f"/v1/pro/chat/threads/{thread_id}/messages" if as_pro else f"/v1/chat/threads/{thread_id}/messages"
    who = pro_id if as_pro else client_id

    assert client.post(path, headers={"X-User-Id": who}, json={"content": "x" * cap}).status_code == 200
    too_long = client.post(path, headers={"X-User-Id": who}, json={"content": "x" * (cap + 1)})

    assert too_long.status_code == 422, too_long.text


@pytest.mark.parametrize("as_pro", [False, True], ids=["client", "photographer"])
def test_both_sides_are_rate_limited(client, db_session, monkeypatch, as_pro):
    from app.services import rate_limit

    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "chat_messages", (2, 60))
    _ai(db_session, on=False)
    pro_id, client_id = _people(db_session)
    thread_id = _open(client, client_id, pro_id)
    path = f"/v1/pro/chat/threads/{thread_id}/messages" if as_pro else f"/v1/chat/threads/{thread_id}/messages"
    who = pro_id if as_pro else client_id

    codes = [client.post(path, headers={"X-User-Id": who}, json={"content": f"message {n}"}).status_code for n in range(3)]

    assert codes == [200, 200, 429]


# --- the hold, driven by real presence -----------------------------------------------


@pytest.fixture
def _clean_presence():
    from app.services.cache import get_redis_client

    redis = get_redis_client()
    for key in redis.scan_iter(match="presence:pro:*"):
        redis.delete(key)
    yield


def _hold_seconds(client, db_session, pro_id, client_id) -> float:
    thread_id = _open(client, client_id, pro_id)
    before = datetime.now(timezone.utc)
    _say(client, client_id, thread_id, "Are you free today?")
    [*_, event] = _ai_events(db_session, thread_id)
    return (event.next_attempt_at - before).total_seconds()


def test_a_real_heartbeat_turns_the_hold_on(client, db_session, fake_model, _clean_presence):
    _ai(db_session, on=True)
    pro_id, client_id = _people(db_session)
    assert client.post("/v1/pro/presence/heartbeat", headers={"X-User-Id": pro_id}).status_code == 200

    assert 110 <= _hold_seconds(client, db_session, pro_id, client_id) <= 130


def test_with_no_heartbeat_the_assistant_answers_at_once(client, db_session, fake_model, _clean_presence):
    _ai(db_session, on=True)
    pro_id, client_id = _people(db_session)

    assert _hold_seconds(client, db_session, pro_id, client_id) <= 5


def test_a_hidden_dot_still_holds_the_assistant(client, db_session, fake_model, _clean_presence):
    """Hiding the dot is about what clients see, not about being there: a
    photographer with the app open and the dot hidden still gets the first
    chance to answer."""
    _ai(db_session, on=True)
    pro_id, client_id = _people(db_session)
    client.post("/v1/pro/presence/heartbeat", headers={"X-User-Id": pro_id})
    assert client.put("/v1/pro/presence/visibility", headers={"X-User-Id": pro_id}, json={"visible": False}).status_code == 200

    assert 110 <= _hold_seconds(client, db_session, pro_id, client_id) <= 130


def test_a_heartbeat_gone_stale_no_longer_holds(client, db_session, fake_model, _clean_presence):
    import json
    import time

    from app.core.config import get_settings
    from app.services.cache import get_redis_client

    _ai(db_session, on=True)
    pro_id, client_id = _people(db_session)
    stale = time.time() - get_settings().presence_window_seconds - 10
    get_redis_client().set(f"presence:pro:{pro_id}", json.dumps({"ts": stale, "visible": True}), ex=60)

    assert _hold_seconds(client, db_session, pro_id, client_id) <= 5

