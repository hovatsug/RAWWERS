"""The chat assistant is off for the beta (owner, 2026-11-17).

Outside development, with no flag rows, a client's message reaches the
photographer and nothing is said in the assistant's name: no disclaimer, no
canned reply, no queued reply, on the apps' chat routes and on the older
ones; the photographer's AI draft and the AI call summary are refused.
Development (and this suite) keep the assistant on.
"""
import uuid

import pytest

from app.core.config import get_settings
from app.models.admin import UserRoleType
from app.models.chat import ChatMessage, ChatSenderType
from app.models.outbox import OutboxEvent
from app.services import feature_flags
from app.services.feature_flags import default_flag_state, is_feature_enabled
from app.tasks.outbox_tasks import dispatch_outbox_events_task
from tests.test_ai_concierge_v1 import _seed_pro, _seed_user


@pytest.fixture
def production(monkeypatch):
    """The defaults outside development, with this suite's own environment
    otherwise (setting APP_ENV=production would also switch off the test
    sign-in header): no environment counts as development."""
    monkeypatch.setattr(feature_flags, "DEVELOPMENT_ENVS", frozenset())


@pytest.mark.parametrize("env", ["production", "prod", "staging"])
def test_outside_development_the_assistant_defaults_off(db_session, monkeypatch, env):
    monkeypatch.setattr(get_settings(), "app_env", env)
    assert default_flag_state("ai_chat_enabled_global") is False
    assert default_flag_state("ai_chat_kill_switch") is True
    assert default_flag_state("ai_calls_enabled") is False
    assert is_feature_enabled(db_session, "ai_chat_enabled_global") is False
    assert is_feature_enabled(db_session, "ai_calls_enabled") is False


def test_development_keeps_the_assistant_on(db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "app_env", "development")
    assert is_feature_enabled(db_session, "ai_chat_enabled_global") is True
    assert is_feature_enabled(db_session, "ai_chat_kill_switch") is False
    assert is_feature_enabled(db_session, "ai_calls_enabled") is True


def _people(db_session):
    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    _seed_user(db_session, client_id, UserRoleType.client)
    _seed_pro(db_session, pro_id)
    return pro_id, client_id


def test_a_client_message_reaches_the_photographer_with_no_stand_in_reply(client, db_session, production):
    pro_id, client_id = _people(db_session)
    thread = client.post("/v1/chat/threads", headers={"X-User-Id": client_id}, json={"pro_user_id": pro_id})
    assert thread.status_code == 200, thread.text
    thread_id = thread.json()["id"]
    sent = client.post(f"/v1/chat/threads/{thread_id}/messages", headers={"X-User-Id": client_id},
                       json={"content": "Hi, are you free in June?"})
    assert sent.status_code == 200, sent.text

    # Nothing queued for the assistant, and nothing appears after the outbox runs.
    assert db_session.query(OutboxEvent).filter_by(topic="ai.reply.generate").count() == 0
    dispatch_outbox_events_task(limit=50)
    db_session.expire_all()
    rows = db_session.query(ChatMessage).filter(ChatMessage.thread_id == uuid.UUID(thread_id)).all()
    assert [(m.sender_type, m.content) for m in rows] == [(ChatSenderType.client, "Hi, are you free in June?")]

    # Both apps see the conversation.
    pro_list = client.get("/v1/pro/chat/threads", headers={"X-User-Id": pro_id})
    client_list = client.get("/v1/chat/threads", headers={"X-User-Id": client_id})
    assert thread_id in [t["id"] for t in pro_list.json()]
    assert thread_id in [t["id"] for t in client_list.json()["items"]]
    # The photographer's Messages badge counts it (the in-app signal; there is
    # no email for a new message, see BETA_SCOPE).
    unread = client.get("/v1/pro/chat/unread", headers={"X-User-Id": pro_id}).json()
    assert unread["threads"] == 1 and unread["messages"] == 1
    detail = client.get(f"/v1/pro/chat/threads/{thread_id}", headers={"X-User-Id": pro_id}).json()
    assert [(m["sender_type"], m["content"]) for m in detail["messages"]] == [("client", "Hi, are you free in June?")]


def test_the_older_chat_routes_add_no_assistant_message(client, db_session, production):
    pro_id, client_id = _people(db_session)
    thread_id = client.post(f"/v1/pros/{pro_id}/chats", headers={"X-User-Id": client_id}).json()["thread_id"]
    msg = client.post(f"/v1/chats/{thread_id}/messages", headers={"X-User-Id": client_id}, json={"content": "Let's book"})
    assert msg.status_code == 200, msg.text
    assert [m["sender_type"] for m in msg.json()["appended"]] == ["client"]


def test_the_photographers_ai_draft_is_refused(client, db_session, production):
    pro_id, client_id = _people(db_session)
    thread_id = client.post("/v1/chat/threads", headers={"X-User-Id": client_id}, json={"pro_user_id": pro_id}).json()["id"]
    draft = client.post(f"/v1/pro/chat/threads/{thread_id}/ai-draft", headers={"X-User-Id": pro_id}, json={})
    assert draft.status_code == 409 and draft.json()["error"]["code"] == "feature_disabled"


def test_the_ai_call_summary_is_refused(client, db_session, production):
    from app.models.communication import CallSessionStatus
    from tests.test_consent_one_active import _a_call, _person

    user_id = _person(db_session)
    session = _a_call(client, db_session, user_id)
    session.status = CallSessionStatus.completed
    db_session.commit()
    summary = client.post(f"/v1/calls/{session.id}/ai/summary", headers={"X-User-Id": user_id})
    assert summary.status_code == 409 and summary.json()["error"]["code"] == "feature_disabled"
