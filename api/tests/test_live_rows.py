""""Available now" and "Online now": two live rows at the top of Discover and
of every niche page.

Live means computed on every request, after the cached rows - availability
and presence change by the minute and the home response is cached until the
public index changes. A photographer who switches off or goes quiet is gone
on the very next request.

  Online now     presence fresh (the dot's five minutes) AND the dot visible.
                 A photographer who hides their dot is not in it.
  Available now  switched on, presence fresh (two minutes), at least one
                 active short-notice package (in the niche, on a niche page),
                 and at least one real bookable start in the next 24 hours
                 from the one availability rule every booking path uses.

Order is never ranking: Available by preparation time, then a daily
rotation; Online by the daily rotation alone. So a photographer with no
completed work is on equal terms with the most established one. A row with
nobody in it is absent, not empty, and the ranked rows below are untouched.
"""
import time
import uuid
from datetime import date, datetime, timedelta, timezone

import pytest
from app.core.config import get_settings
from app.models.booking import ProBlackoutDate, ProPackage
from app.models.discovery import ProPublicIndex
from app.services import live_rows, presence

from tests.test_available_now import (  # noqa: F401 - _no_presence_left_over is autouse
    _available,
    _no_presence_left_over,
    _prep,
    _seen,
    _short_notice_pro,
    _toggle,
)
from tests.test_bookable_time import _no_stripe, _pro  # noqa: F401 - _no_stripe is autouse

LIVE = ("available_now", "online_now")


def _home(client, viewer, niche=None):
    url = "/v1/client/home?city=Lisbon&country=PT" + (f"&niche_slug={niche}" if niche else "")
    resp = client.get(url, headers={"X-User-Id": viewer})
    assert resp.status_code == 200, resp.text
    return resp.json()


def _row(home, key) -> list[str] | None:
    for row in home["rows"]:
        if row["key"] == key:
            return [c["pro_user_id"] for c in row["items"]]
    return None


def _checks(monkeypatch) -> list:
    """Who the availability rule was asked about - the per-photographer
    cost the cheap checks before it exist to avoid."""
    calls = []
    real = live_rows.bookable_windows
    monkeypatch.setattr(live_rows, "bookable_windows", lambda *a, **k: calls.append(k["pro_user_id"]) or real(*a, **k))
    return calls


def _hide(client, pro, hidden=True):
    resp = client.put("/v1/pro/presence/visibility", headers={"X-User-Id": pro.id}, json={"visible": not hidden})
    assert resp.status_code == 200, resp.text


# --- who is in each row --------------------------------------------------------


def test_available_and_online_photographers_lead_the_home_screen(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)

    home = _home(client, pro.client_id)

    assert [row["key"] for row in home["rows"][:2]] == list(LIVE)
    assert _row(home, "available_now") == [pro.id]
    assert _row(home, "online_now") == [pro.id]
    titles = {row["key"]: (row["title"], row["subtitle"]) for row in home["rows"][:2]}
    assert titles == {
        "available_now": ("Available now", "Can shoot in the next 24 hours"),
        "online_now": ("Online now", "Open to chat right now"),
    }


def test_nobody_live_means_no_live_rows_and_the_ranked_rows_unchanged(client, db_session):
    pro = _short_notice_pro(db_session)
    quiet = _home(client, pro.client_id)
    assert not {row["key"] for row in quiet["rows"]} & set(LIVE), "absent, never empty"

    _available(client, db_session, pro)
    live = _home(client, pro.client_id)

    ranked = lambda home: [(r["key"], [c["pro_user_id"] for c in r["items"]]) for r in home["rows"] if r["key"] not in LIVE]  # noqa: E731
    assert ranked(live) == ranked(quiet)


def test_switching_off_takes_effect_on_the_very_next_request(client, db_session, monkeypatch):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    assert _row(_home(client, pro.client_id), "available_now") == [pro.id]  # and now cached

    assert _toggle(client, pro, on=False).status_code == 200
    checks = _checks(monkeypatch)

    assert _row(_home(client, pro.client_id), "available_now") is None
    assert checks == [], "switched off is ruled out before the availability rule is asked"


def test_the_live_rows_come_with_cached_responses_too(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)

    first, second = _home(client, pro.client_id), _home(client, pro.client_id)  # the second from the cache

    assert _row(first, "available_now") == _row(second, "available_now") == [pro.id]
    assert _row(second, "online_now") == [pro.id]


def test_going_quiet_takes_effect_on_the_very_next_request(client, db_session, monkeypatch):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    assert _row(_home(client, pro.client_id), "available_now") == [pro.id]

    _seen(pro, seconds_ago=get_settings().available_now_fresh_seconds + 10)  # still within the dot's 5 minutes
    checks = _checks(monkeypatch)
    home = _home(client, pro.client_id)
    assert checks == [], "gone quiet is ruled out before the availability rule is asked"

    assert _row(home, "available_now") is None
    assert _row(home, "online_now") == [pro.id]


def test_a_hidden_dot_keeps_a_photographer_out_of_online_now_but_not_available_now(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)

    _hide(client, pro)
    home = _home(client, pro.client_id)

    assert _row(home, "online_now") is None
    assert _row(home, "available_now") == [pro.id]
    [card] = [c for r in home["rows"] for c in r["items"] if r["key"] == "available_now"]
    assert card["online"] is False


def test_switched_on_with_no_short_notice_package_left_is_not_available(client, db_session, monkeypatch):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    package = db_session.get(ProPackage, uuid.UUID(pro.package_id))
    package.short_notice_ok = False
    db_session.commit()
    checks = _checks(monkeypatch)

    assert _row(_home(client, pro.client_id), "available_now") is None
    assert checks == [], "no short-notice package is ruled out before the availability rule is asked"


def test_switched_on_with_no_real_start_in_the_next_24_hours_is_not_available(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    now = datetime.now(timezone.utc)
    db_session.add(ProBlackoutDate(pro_user_id=pro.uuid, start_at=now - timedelta(hours=1), end_at=now + timedelta(hours=26), reason="away"))
    db_session.commit()

    home = _home(client, pro.client_id)

    assert _row(home, "available_now") is None
    assert _row(home, "online_now") == [pro.id], "still online - only not bookable"


def test_a_niche_page_has_its_own_live_rows(client, db_session):
    pro = _short_notice_pro(db_session)  # a portraits package
    _available(client, db_session, pro)

    portraits = _home(client, pro.client_id, niche="portraits")
    weddings = _home(client, pro.client_id, niche="weddings")

    assert [row["key"] for row in portraits["rows"][:2]] == list(LIVE)
    assert portraits["rows"][0]["title"] == "Available now in Portraits"
    assert _row(weddings, "available_now") is None and _row(weddings, "online_now") is None


def test_on_a_niche_page_the_short_notice_package_must_be_in_that_niche(client, db_session):
    """A wedding photographer whose only short-notice package is a portrait
    session is online on the weddings page, but not available there."""
    from app.models.niche import Niche, ProNicheSkill, SkillTier
    from sqlalchemy import select

    pro = _short_notice_pro(db_session)  # its short-notice package is portraits
    weddings = db_session.execute(select(Niche).where(Niche.slug == "weddings")).scalar_one()
    db_session.get(ProPublicIndex, pro.uuid).primary_niche_id = weddings.id
    if not db_session.execute(
        select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro.uuid, ProNicheSkill.niche_id == weddings.id)
    ).scalar_one_or_none():
        db_session.add(ProNicheSkill(pro_user_id=pro.uuid, niche_id=weddings.id, tier=SkillTier.rookie))
    db_session.commit()
    _available(client, db_session, pro)

    page = _home(client, pro.client_id, niche="weddings")

    assert _row(page, "online_now") == [pro.id]
    assert _row(page, "available_now") is None
    assert _row(_home(client, pro.client_id, niche="portraits"), "available_now") == [pro.id]


def test_the_ready_in_time_is_on_the_card_wherever_it_appears(client, db_session):
    pro = _short_notice_pro(db_session)
    _seen(pro)
    assert _prep(client, pro, 90).status_code == 200

    home = _home(client, pro.client_id)

    cards = [c for r in home["rows"] for c in r["items"] if c["pro_user_id"] == pro.id]
    assert len(cards) >= 2, "in the live row and a ranked one"
    assert {c["ready_in_minutes"] for c in cards} == {90}


def test_not_available_means_no_ready_in_time(client, db_session):
    pro = _short_notice_pro(db_session)
    _seen(pro)

    home = _home(client, pro.client_id)

    assert {c["ready_in_minutes"] for r in home["rows"] for c in r["items"]} == {None}


# --- order ----------------------------------------------------------------------------


def test_the_daily_rotation_is_deterministic_and_changes_by_day_and_viewer():
    ids = [uuid.UUID(int=n) for n in range(1, 21)]
    day = date(2026, 10, 14)

    order = sorted(ids, key=lambda i: live_rows.rotation_key(i, day=day, seed="viewer-a"))
    assert order == sorted(ids, key=lambda i: live_rows.rotation_key(i, day=day, seed="viewer-a")), "same day, same viewer"
    assert order != sorted(ids, key=lambda i: live_rows.rotation_key(i, day=day + timedelta(days=1), seed="viewer-a"))
    assert order != sorted(ids, key=lambda i: live_rows.rotation_key(i, day=day, seed="viewer-b"))
    assert order != ids, "not simply the id order"


def test_available_now_orders_by_preparation_time_then_the_rotation(client, db_session, monkeypatch):
    slow, quick, also_quick = (_short_notice_pro(db_session) for _ in range(3))
    for pro, minutes in ((slow, 240), (quick, 90), (also_quick, 90)):
        _seen(pro)
        assert _prep(client, pro, minutes).status_code == 200
    viewer = slow.client_id
    seed = live_rows.viewer_seed(uuid.UUID(viewer), "PT", "Lisbon")
    today = live_rows.rotation_day()
    tied = sorted([quick.id, also_quick.id], key=lambda i: live_rows.rotation_key(uuid.UUID(i), day=today, seed=seed))

    assert _row(_home(client, viewer), "available_now") == tied + [slow.id]


def test_a_newcomer_is_on_equal_terms_with_an_established_photographer(client, db_session, monkeypatch):
    """Gigs, rating and tier are not inputs: with the rotation in the
    newcomer's favour the newcomer leads, and in the other's favour the
    established photographer does - nothing else decides."""
    established, newcomer = _short_notice_pro(db_session), _short_notice_pro(db_session)
    row = db_session.get(ProPublicIndex, established.uuid)
    row.gigs_completed, row.ranking_score, row.review_count = 80, 99, 60
    db_session.commit()
    for pro in (established, newcomer):
        _available(client, db_session, pro)

    for first in (newcomer, established):
        monkeypatch.setattr(live_rows, "rotation_key", lambda pro_id, *, day, seed, _f=first.uuid: "0" if pro_id == _f else "1")
        home = _home(client, newcomer.client_id)
        assert _row(home, "available_now")[0] == first.id
        assert _row(home, "online_now")[0] == first.id


def test_online_now_ignores_preparation_time(client, db_session, monkeypatch):
    slow, quick = _short_notice_pro(db_session), _short_notice_pro(db_session)
    for pro, minutes in ((slow, 360), (quick, 90)):
        _seen(pro)
        assert _prep(client, pro, minutes).status_code == 200
    monkeypatch.setattr(live_rows, "rotation_key", lambda pro_id, *, day, seed: "0" if pro_id == slow.uuid else "1")

    home = _home(client, slow.client_id)

    assert _row(home, "online_now") == [slow.id, quick.id]
    assert _row(home, "available_now") == [quick.id, slow.id]


# --- cost and failure -----------------------------------------------------------------


def test_the_availability_check_runs_on_a_capped_candidate_set(client, db_session, monkeypatch):
    pros = [_short_notice_pro(db_session) for _ in range(3)]
    for pro in pros:
        _available(client, db_session, pro)
    monkeypatch.setattr(live_rows, "AVAILABLE_CANDIDATE_CAP", 2)
    calls = []
    real = live_rows.bookable_windows
    monkeypatch.setattr(live_rows, "bookable_windows", lambda *a, **k: calls.append(k["pro_user_id"]) or real(*a, **k))

    row = _row(_home(client, pros[0].client_id), "available_now")

    assert len(set(calls)) == 2
    assert len(row) == 2


def test_presence_is_one_batched_lookup_for_both_rows(client, db_session, monkeypatch):
    pros = [_short_notice_pro(db_session) for _ in range(3)]
    for pro in pros:
        _available(client, db_session, pro)
    calls = []
    real = presence._mget
    monkeypatch.setattr(presence, "_mget", lambda keys: calls.append(len(keys)) or real(keys))

    _home(client, pros[0].client_id)

    # One for both live rows and the dot on every card.
    assert len(calls) == 1, calls


def test_if_redis_cannot_answer_there_are_no_live_rows_and_no_error(client, db_session, monkeypatch):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)

    def down(keys):
        raise ConnectionError("redis down")

    monkeypatch.setattr(presence, "_mget", down)
    home = _home(client, pro.client_id)

    assert not {row["key"] for row in home["rows"]} & set(LIVE)
    assert home["rows"], "the ranked rows still come"
    # Handled where Redis is read, not only by the route's last-resort guard.
    live = live_rows.compute(db_session, eligible=[pro.uuid], niche_id=None, seed="s")
    assert (live.available, live.online, live.ready_in) == ([], [], {})


def test_anything_else_failing_in_the_live_rows_leaves_the_rest_of_the_screen(client, db_session, monkeypatch):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)

    def broken(*args, **kwargs):
        raise RuntimeError("a bug in the live rows")

    monkeypatch.setattr(live_rows, "compute", broken)
    home = _home(client, pro.client_id)

    assert not {row["key"] for row in home["rows"]} & set(LIVE)
    assert home["rows"]


def test_no_payload_says_when_anyone_was_last_seen_or_until_when_they_are_available(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    from app.models.booking import ProSchedulingPolicy
    from app.services.cache import get_redis_client
    import json

    ts = json.loads(get_redis_client().get(f"presence:pro:{pro.uuid}"))["ts"]
    until = db_session.get(ProSchedulingPolicy, pro.uuid).available_until
    leaks = (
        str(int(ts)),
        datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M"),
        until.strftime("%Y-%m-%dT%H:%M"),
    )

    for niche in (None, "portraits"):
        resp = client.get(
            "/v1/client/home?city=Lisbon&country=PT" + (f"&niche_slug={niche}" if niche else ""),
            headers={"X-User-Id": pro.client_id},
        )
        assert _row(resp.json(), "available_now") == [pro.id]
        assert not any(leak in resp.text for leak in leaks)
        for word in ("seen", "heartbeat", "last_active", "available_until"):
            assert word not in resp.text, word
