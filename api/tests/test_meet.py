"""'Meet the photographer': a photographer's interview, from draft to profile and Discover card.

Optional in every way, and inert where it matters: it never gates onboarding,
never feeds ranking and never sorts anything.
"""
import uuid
from decimal import Decimal
from pathlib import Path

import pytest
from sqlalchemy import select

from app.core.config import get_settings
from app.models.admin import AdminAuditLog, UserRoleType
from app.models.meet import InterviewQuestion
from app.models.niche import SkillTier
from app.services import meet
from app.services.contact_details import find_contact_details
from tests.test_client_home_rows import _city, _clear_home_cache, _home, _pro, _skill  # noqa: F401 - the fixture clears the cache around each test
from tests.test_client_launch import _enable_city_and_flags, _profile, _seed_pro, _seed_user

ADMIN = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}
PRO_ID = "00000000-0000-0000-0000-0000000009c1"
CLIENT_ID = "00000000-0000-0000-0000-0000000009d1"

WHO = "I'm Ana, a portrait photographer in Lisbon."
STYLE = "I work with people who hate being photographed, and my photos are calm and natural."
EXPERIENCE = "We start by chatting, I show you a few frames on the back of the camera, and only then do we try poses."


@pytest.fixture
def pro(client, db_session):
    _seed_pro(db_session, PRO_ID)
    _seed_user(db_session, CLIENT_ID, [UserRoleType.client])
    _enable_city_and_flags(db_session)
    db_session.commit()
    return {"X-User-Id": PRO_ID}


def _questions(client, headers):
    return {q["title"]: q["question_id"] for q in client.get("/v1/pro/me/interview", headers=headers).json()["items"]}


def _save(client, headers, answers: dict[str, str | None]):
    ids = _questions(client, headers)
    return client.put("/v1/pro/me/interview", json={"answers": {ids[t]: a for t, a in answers.items()}}, headers=headers)


def _publish(client, headers):
    return client.post("/v1/pro/me/interview/publish", headers=headers)


def _meet(client):
    return _profile(client, PRO_ID, CLIENT_ID)["meet"]


# --- The questions. ---


def test_the_questions_are_the_five_parts_of_the_video_guide(client, pro):
    items = client.get("/v1/pro/me/interview", headers=pro).json()["items"]
    assert [i["title"] for i in items] == ["Who I am", "My style", "Working with me", "One true detail", "An invitation"]
    assert all(i["max_chars"] > i["min_chars"] for i in items)
    assert items[0]["prompt"] == "Who are you, what do you shoot, and where?"


def test_only_a_photographer_has_an_interview(client, db_session, pro):
    assert client.get("/v1/pro/me/interview", headers={"X-User-Id": CLIENT_ID}).status_code == 403


# --- Absent when empty. ---


def test_the_section_is_absent_with_nothing_published(client, pro):
    assert _meet(client) is None


def test_a_draft_is_not_shown_to_clients(client, pro):
    assert _save(client, pro, {"Who I am": WHO}).status_code == 200
    assert _meet(client) is None


def test_publishing_puts_the_answers_on_the_profile_in_question_order(client, pro):
    _save(client, pro, {"My style": STYLE, "Who I am": WHO})
    assert _publish(client, pro).status_code == 200

    section = _meet(client)
    assert [(i["title"], i["answer"]) for i in section["interview"]] == [("Who I am", WHO), ("My style", STYLE)]
    assert section["video"] is None


def test_a_change_waits_for_the_next_publish(client, pro):
    _save(client, pro, {"Who I am": WHO})
    _publish(client, pro)
    _save(client, pro, {"Who I am": "I'm Ana, and I photograph people in Porto now."})
    assert _meet(client)["interview"][0]["answer"] == WHO

    mine = client.get("/v1/pro/me/interview", headers=pro).json()
    assert mine["has_unpublished_changes"] is True


def test_unpublishing_takes_the_section_away(client, pro):
    _save(client, pro, {"Who I am": WHO})
    _publish(client, pro)
    assert client.post("/v1/pro/me/interview/unpublish", headers=pro).status_code == 200
    assert _meet(client) is None


# --- Lengths. ---


def test_an_answer_cannot_be_saved_over_its_limit(client, pro):
    limit = client.get("/v1/pro/me/interview", headers=pro).json()["items"][0]["max_chars"]
    resp = _save(client, pro, {"Who I am": "x" * (limit + 1)})
    assert resp.status_code == 422
    assert str(limit) in resp.json()["error"]["message"]


def test_a_draft_may_be_short_but_cannot_be_published_short(client, pro):
    assert _save(client, pro, {"Who I am": "Ana."}).status_code == 200
    resp = _publish(client, pro)
    assert resp.status_code == 422
    assert "Who I am" in resp.json()["error"]["message"] and "at least" in resp.json()["error"]["message"]


def test_nothing_to_publish_says_so(client, pro):
    resp = _publish(client, pro)
    assert resp.status_code == 422
    assert "at least one" in resp.json()["error"]["message"].lower()


# --- Contact details: a warning, never a block. ---


@pytest.mark.parametrize(
    "text, kinds",
    [
        ("Write to ana.lens@example.com any time", ["email"]),
        ("Call me on +351 912 345 678", ["phone"]),
        ("Find me at instagram.com/analens", ["link"]),
        ("Message me on WhatsApp", ["link"]),
        ("I'm @ana.lens everywhere", ["handle"]),
        ("I shoot on a 50mm lens since 2018, and deliver 20 photos", []),
        ("I carry 24 35 85 primes", []),
        ("Hi, I'm Ana, a portrait photographer in Lisbon.", []),
    ],
)
def test_the_contact_filter(text, kinds):
    assert find_contact_details(text) == kinds


def test_contact_details_warn_but_still_save_and_publish(client, pro):
    resp = _save(client, pro, {"Who I am": "I'm Ana in Lisbon, write to ana.lens@example.com"})
    assert resp.status_code == 200
    item = resp.json()["items"][0]
    assert "contact details" in item["warning"] and "email" in item["warning"]
    assert _publish(client, pro).status_code == 200, "a warning must never block"


def test_plain_words_have_no_warning(client, pro):
    item = _save(client, pro, {"Who I am": WHO}).json()["items"][0]
    assert item["warning"] is None


# --- The admin's questions. ---


def _admin_questions(client):
    return {q["key"]: q for q in client.get("/v1/admin/interview-questions", headers=ADMIN).json()}


def test_an_admin_edits_a_question_and_clients_read_the_new_title(client, db_session, pro):
    _save(client, pro, {"Who I am": WHO})
    _publish(client, pro)
    who = _admin_questions(client)["who"]
    resp = client.patch(f"/v1/admin/interview-questions/{who['id']}", json={"title": "About me"}, headers=ADMIN)
    assert resp.status_code == 200, resp.text
    assert _meet(client)["interview"][0]["title"] == "About me"

    log = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_type == "interview_question")).scalar_one()
    assert log.action == "interview_question_updated"
    assert log.meta["title"] == {"from": "Who I am", "to": "About me"}


def test_a_question_s_lengths_must_make_sense(client, pro):
    who = _admin_questions(client)["who"]
    resp = client.patch(f"/v1/admin/interview-questions/{who['id']}", json={"min_chars": 300, "max_chars": 200}, headers=ADMIN)
    assert resp.status_code == 422


def test_a_retired_question_hides_its_answers(client, pro):
    _save(client, pro, {"Who I am": WHO, "My style": STYLE})
    _publish(client, pro)
    style = _admin_questions(client)["style"]
    client.patch(f"/v1/admin/interview-questions/{style['id']}", json={"is_active": False}, headers=ADMIN)
    assert [i["title"] for i in _meet(client)["interview"]] == ["Who I am"]


def test_a_new_question_is_asked_of_photographers(client, pro):
    resp = client.post(
        "/v1/admin/interview-questions",
        json={"prompt": "Where do you like to shoot?", "title": "Where I shoot", "min_chars": 10, "max_chars": 200},
        headers=ADMIN,
    )
    assert resp.status_code == 200, resp.text
    assert "Where I shoot" in _questions(client, pro)


def test_only_an_admin_edits_questions(client, pro):
    assert client.get("/v1/admin/interview-questions", headers=pro).status_code == 403
    who = _admin_questions(client)["who"]
    assert client.patch(f"/v1/admin/interview-questions/{who['id']}", json={"title": "x"}, headers=pro).status_code == 403


# --- The Discover card's teaser. ---


def test_a_card_shows_a_teaser_only_where_there_is_one(client, db_session):
    _city(db_session)
    with_interview = _pro(db_session, name="Talks", gigs=3, niche_slug="weddings")
    without = _pro(db_session, name="Quiet", gigs=2, niche_slug="weddings")
    for p in (with_interview, without):
        _skill(db_session, p, "weddings", SkillTier.pro)
    from app.models.admin import UserRole

    db_session.add(UserRole(user_id=with_interview, role=UserRoleType.pro))
    db_session.commit()
    viewer = uuid.uuid4()
    _seed_user(db_session, str(viewer))

    cards = {c["display_name"]: c for c in _home(client, viewer)["niche:weddings"]["items"]}
    assert cards["Talks"]["teaser"] is None, "nothing published yet"

    headers = {"X-User-Id": str(with_interview)}
    _save(client, headers, {"Who I am": "I'm Marco, a wedding photographer in Lisbon. I've shot sixty weddings."})
    _publish(client, headers)

    cards = {c["display_name"]: c for c in _home(client, viewer)["niche:weddings"]["items"]}
    assert cards["Talks"]["teaser"] == {"kind": "interview", "line": "I'm Marco, a wedding photographer in Lisbon."}
    assert cards["Quiet"]["teaser"] is None, "no empty placeholder"


def test_a_long_first_sentence_is_cut_to_one_line():
    limit = get_settings().interview_teaser_max_chars
    line = meet._first_sentence("word " * 80, limit)
    assert len(line) <= limit and line.endswith("…")


# --- Inert where it matters. ---


def test_publishing_changes_no_ranking(client, db_session, pro):
    from app.services.discovery_index import recompute_pro_public_index

    before = recompute_pro_public_index(db_session, uuid.UUID(PRO_ID)).ranking_score
    db_session.commit()
    _save(client, pro, {"Who I am": WHO, "My style": STYLE, "Working with me": EXPERIENCE})
    _publish(client, pro)
    after = recompute_pro_public_index(db_session, uuid.UUID(PRO_ID)).ranking_score
    assert Decimal(after) == Decimal(before)


def test_nothing_that_ranks_sorts_or_onboards_reads_the_interview():
    root = Path(__file__).resolve().parents[1] / "app"
    readers = {
        str(path.relative_to(root))
        for path in root.rglob("*.py")
        if any(name in path.read_text() for name in ("ProInterviewAnswer", "InterviewQuestion", "services.meet", "services import meet"))
    }
    # The model, its registration, its schemas, the service, its routes, and
    # the client responses that show it. Not the index, the ranking, any
    # row's order or onboarding.
    assert readers == {
        "models/meet.py", "db/base.py", "schemas/meet.py", "services/meet.py", "api/v1/meet.py", "api/v1/client_launch.py",
    }


def test_the_video_slot_is_off_by_default(client, pro):
    assert get_settings().presentation_video_enabled is False
    _save(client, pro, {"Who I am": WHO})
    _publish(client, pro)
    assert _meet(client)["video"] is None


def test_the_default_questions_are_written_once(db_session):
    meet.ensure_default_questions(db_session)
    meet.ensure_default_questions(db_session)
    db_session.commit()
    assert len(db_session.execute(select(InterviewQuestion)).scalars().all()) == len(meet.DEFAULT_QUESTIONS)

