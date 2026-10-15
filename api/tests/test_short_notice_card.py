"""A card in "Available now" says how long the photographer has to answer,
so a client asking for a shoot in two hours is not surprised that the answer
is not instant - and is told only what the rule enforces: the photographer
has that long, after which the request lapses. Not a promise that they will
answer."""
from app.core.config import get_settings

from tests.test_available_now import _available, _no_presence_left_over, _seen, _short_notice_pro  # noqa: F401
from tests.test_bookable_time import _no_stripe  # noqa: F401


def _cards(client, pro):
    home = client.get("/v1/client/home?city=Lisbon&country=PT", headers={"X-User-Id": pro.client_id}).json()
    return [c for row in home["rows"] for c in row["items"] if c["pro_user_id"] == pro.id]


def test_an_available_photographers_card_says_how_long_they_have_to_answer(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)

    cards = _cards(client, pro)

    assert cards and {c["answer_within_minutes"] for c in cards} == {get_settings().short_notice_accept_minutes}


def test_it_follows_the_setting(client, db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "short_notice_accept_minutes", 20)
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)

    assert {c["answer_within_minutes"] for c in _cards(client, pro)} == {20}


def test_a_photographer_not_available_now_has_no_such_line(client, db_session):
    pro = _short_notice_pro(db_session)
    _seen(pro)

    assert {c["answer_within_minutes"] for c in _cards(client, pro)} == {None}
