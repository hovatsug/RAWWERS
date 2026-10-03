"""Admin: finding a review and deciding about it.

The public list shows published reviews only and needs a photographer id, so
before this a moderator could not find a review to act on, nor see one already
hidden in order to restore it. These cover the list a moderator works from and
the rules on the decision itself.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from app.models.admin import AdminAuditLog, ProProfile, UserAccount
from app.models.review import ProReputation, Review, ReviewStatus
from sqlalchemy import select

from tests.test_reviews import _create_gig, _post_review

ADMIN = "00000000-0000-0000-0000-0000000000aa"
URL = "/v1/admin/reviews"


@pytest.fixture(autouse=True)
def _no_index_rebuild(monkeypatch):
    monkeypatch.setattr("app.api.v1.reviews.rebuild_pro_index.delay", lambda *_a, **_k: None)


def _review(client, db_session, *, rating=5, text=None, pro_id=None, client_email=None, pro_name=None):
    client_id, pro_id = str(uuid.uuid4()), pro_id or str(uuid.uuid4())
    if client_email:
        db_session.add(UserAccount(user_id=uuid.UUID(client_id), email=client_email))
    if pro_name and db_session.get(ProProfile, uuid.UUID(pro_id)) is None:
        db_session.add(UserAccount(user_id=uuid.UUID(pro_id)))
        db_session.flush()
        db_session.add(ProProfile(user_id=uuid.UUID(pro_id), display_name=pro_name))
    db_session.commit()
    gig = _create_gig(db_session, client_id, pro_id)
    return _post_review(client, gig, client_id, rating=rating, text=text)


def _moderate(client, review_id, action, reason="Breaks the review policy"):
    return client.post(f"{URL}/{review_id}/moderate", headers={"X-User-Id": ADMIN}, json={"action": action, "reason": reason})


def _list(client, **params):
    resp = client.get(URL, headers={"X-User-Id": ADMIN}, params=params)
    assert resp.status_code == 200, resp.text
    return resp.json()


# ---------------------------------------------------------------------------
# The list.
# ---------------------------------------------------------------------------


def test_the_list_names_who_wrote_it_about_whom(client, db_session):
    _review(client, db_session, rating=1, text="Never turned up", client_email="ana@example.test", pro_name="Rui Foto")

    [row] = _list(client)["items"]

    assert row["client_email"] == "ana@example.test"
    assert row["pro_display_name"] == "Rui Foto"
    assert row["rating"] == 1 and row["text"] == "Never turned up"
    assert row["status"] == "published"
    assert row["last_moderation"] is None


def test_a_hidden_review_is_still_listed_so_it_can_be_restored(client, db_session):
    kept = _review(client, db_session)
    hidden = _review(client, db_session)
    assert _moderate(client, hidden["id"], "hidden").status_code == 200

    body = _list(client, status="hidden")

    assert [r["id"] for r in body["items"]] == [hidden["id"]]
    assert body["counts"] == {"published": 1, "hidden": 1, "removed": 0}
    assert [r["id"] for r in _list(client, status="published")["items"]] == [kept["id"]]


def test_each_row_carries_the_last_decision_and_why(client, db_session):
    posted = _review(client, db_session)
    _moderate(client, posted["id"], "hidden", reason="Names a third party")
    _moderate(client, posted["id"], "published", reason="Edited by the client")

    [row] = _list(client)["items"]

    assert row["last_moderation"]["action"] == "published"
    assert row["last_moderation"]["reason"] == "Edited by the client"
    assert row["last_moderation"]["actor_user_id"] == ADMIN


def test_low_ratings_and_search_narrow_the_list(client, db_session):
    _review(client, db_session, rating=5, text="Lovely")
    low = _review(client, db_session, rating=2, text="Photos arrived late", pro_name="Rui Foto")
    _review(client, db_session, rating=1, text="Rude", client_email="troll@example.test")

    assert {r["text"] for r in _list(client, rating_max=2)["items"]} == {"Photos arrived late", "Rude"}
    assert [r["id"] for r in _list(client, q="arrived late")["items"]] == [low["id"]]
    assert [r["text"] for r in _list(client, q="rui")["items"]] == ["Photos arrived late"]
    assert [r["text"] for r in _list(client, q="troll@")["items"]] == ["Rude"]


def test_newest_first_and_paged(client, db_session):
    ids = [_review(client, db_session)["id"] for _ in range(3)]
    base = datetime.now(timezone.utc)
    for age, review_id in enumerate(ids):  # the first posted is the oldest
        db_session.get(Review, uuid.UUID(review_id)).created_at = base - timedelta(hours=10 - age)
    db_session.commit()

    first = _list(client, limit=2)
    second = _list(client, limit=2, offset=2)

    assert [r["id"] for r in first["items"]] == [ids[2], ids[1]]
    assert [r["id"] for r in second["items"]] == [ids[0]]
    assert first["total"] == 3


def test_only_an_admin_can_list_reviews(client, db_session):
    _review(client, db_session)
    assert client.get(URL, headers={"X-User-Id": str(uuid.uuid4())}).status_code == 403


# ---------------------------------------------------------------------------
# The decision.
# ---------------------------------------------------------------------------


def test_moderating_needs_a_reason_and_changes_nothing_without_one(client, db_session):
    posted = _review(client, db_session)

    for reason in (None, "   "):
        resp = client.post(
            f"{URL}/{posted['id']}/moderate", headers={"X-User-Id": ADMIN}, json={"action": "hidden", "reason": reason}
        )
        assert resp.status_code == 422

    db_session.expire_all()
    assert db_session.get(Review, uuid.UUID(posted["id"])).status == ReviewStatus.published
    assert db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_type == "review")).first() is None


def test_the_same_decision_twice_is_refused_and_logged_once(client, db_session):
    posted = _review(client, db_session)
    assert _moderate(client, posted["id"], "hidden").status_code == 200

    again = _moderate(client, posted["id"], "hidden")

    assert again.status_code == 409
    db_session.expire_all()
    entries = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_type == "review")).scalars().all()
    assert len(entries) == 1


def test_restoring_puts_it_back_in_the_rating(client, db_session):
    pro_id = str(uuid.uuid4())
    good = _review(client, db_session, rating=5, pro_id=pro_id)
    _review(client, db_session, rating=1, pro_id=pro_id)

    _moderate(client, good["id"], "removed")
    db_session.expire_all()
    assert db_session.get(ProReputation, uuid.UUID(pro_id)).review_count == 1

    assert _moderate(client, good["id"], "published", reason="Removed by mistake").status_code == 200
    db_session.expire_all()
    rep = db_session.get(ProReputation, uuid.UUID(pro_id))
    assert rep.review_count == 2
    assert str(rep.avg_rating) == "3.00"
