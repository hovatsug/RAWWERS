"""What clients are told about how quickly a photographer replies.

The label replaced a mean of accept/decline times that left out every request
nobody answered. These pin the rules that make it honest - and the ones that
keep it from doing harm: it never orders anyone, a slow bucket is not shown
while the platform cannot yet tell a photographer a request arrived, and
clients never see the raw minutes.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.booking import BookingRequest, BookingRequestStatus, BookingRequestTransition, ProPackage
from app.models.discovery import ProPublicIndex
from app.models.niche import Niche
from app.schemas.client_launch import ClientDiscoverCard, ClientProProfileResponse
from app.schemas.discovery import ProPublicProfileResponse
from app.services.cache import get_public_index_version
from app.services.discovery_index import recompute_pro_public_index
from app.services.response_time import ResponseBucket, client_label
from app.services.scheduling import expire_pending_booking_requests

from tests.test_discovery import _seed_pro

S = BookingRequestStatus


def _pro_with_package(db_session) -> tuple[uuid.UUID, uuid.UUID]:
    pro = uuid.UUID(_seed_pro(db_session))
    niche_id = db_session.query(Niche).filter_by(slug="portraits").first().id
    package = ProPackage(
        pro_user_id=pro,
        niche_id=niche_id,
        title="Pkg",
        duration_minutes=60,
        price=Decimal("100.00"),
        currency="EUR",
        included_photos=10,
        extra_photo_price=Decimal("10.00"),
        proofs_sla_days=3,
        finals_sla_days=7,
        addons=[],
        is_active=True,
    )
    db_session.add(package)
    db_session.commit()
    return pro, package.id


def _request(db_session, pro, package_id, *, answered_after: timedelta | None, outcome=S.accepted, window=timedelta(hours=24), ago=timedelta(days=3)):
    """A request made `ago`, resolved `answered_after` later as `outcome`.
    answered_after=None with outcome=expired is a request nobody answered."""
    asked = datetime.now(timezone.utc) - ago
    request = BookingRequest(
        pro_user_id=pro,
        client_user_id=uuid.uuid4(),
        package_id=package_id,
        requested_start=asked + timedelta(days=10),
        requested_end=asked + timedelta(days=10, hours=1),
        status=outcome,
        expires_at=asked + window,
        created_at=asked,
    )
    db_session.add(request)
    db_session.flush()
    resolved = asked + (answered_after if answered_after is not None else window)
    db_session.add(
        BookingRequestTransition(
            booking_request_id=request.id,
            from_status=S.pending,
            to_status=outcome,
            actor_user_id=pro,  # the sweep records the photographer even for an expiry
            created_at=resolved,
        )
    )
    db_session.commit()
    return request


def _index(db_session, pro) -> ProPublicIndex:
    index = recompute_pro_public_index(db_session, pro)
    db_session.commit()
    return index


def test_two_resolved_requests_are_not_a_history_yet(db_session):
    pro, package = _pro_with_package(db_session)
    _request(db_session, pro, package, answered_after=timedelta(minutes=5))
    _request(db_session, pro, package, answered_after=timedelta(minutes=5))

    index = _index(db_session, pro)

    assert index.response_bucket == ResponseBucket.no_history
    assert client_label(index.response_bucket) == "No response history yet"

    _request(db_session, pro, package, answered_after=timedelta(minutes=5))
    assert _index(db_session, pro).response_bucket == ResponseBucket.within_hour


def test_ignored_requests_count_as_slow_not_as_missing(db_session):
    """Two quick answers and three ignored requests. The old mean read only the
    two answers: 'within an hour'. An expiry counts as just past its window,
    so this is slower than a day - and clients are shown nothing."""
    pro, package = _pro_with_package(db_session)
    for _ in range(2):
        _request(db_session, pro, package, answered_after=timedelta(minutes=10))
    for _ in range(3):
        _request(db_session, pro, package, answered_after=None, outcome=S.expired)

    index = _index(db_session, pro)

    assert index.response_median_minutes == 24 * 60 + 1
    assert index.response_bucket == ResponseBucket.over_day
    assert client_label(index.response_bucket) is None


def test_a_client_withdrawing_before_any_reply_is_not_the_photographers_response(db_session):
    pro, package = _pro_with_package(db_session)
    for _ in range(3):
        _request(db_session, pro, package, answered_after=timedelta(minutes=10))
    for _ in range(5):
        _request(db_session, pro, package, answered_after=timedelta(hours=20), outcome=S.cancelled)

    assert _index(db_session, pro).response_bucket == ResponseBucket.within_hour


def test_only_the_last_ten_count(db_session):
    """Someone who used to be slow and is quick now is quick."""
    pro, package = _pro_with_package(db_session)
    for _ in range(10):
        _request(db_session, pro, package, answered_after=None, outcome=S.expired, ago=timedelta(days=30))
    for _ in range(10):
        _request(db_session, pro, package, answered_after=timedelta(minutes=20), ago=timedelta(days=2))

    assert _index(db_session, pro).response_bucket == ResponseBucket.within_hour


def test_slow_is_stored_but_never_shown_to_clients(db_session):
    pro, package = _pro_with_package(db_session)
    for _ in range(3):
        _request(db_session, pro, package, answered_after=timedelta(hours=40), window=timedelta(hours=48), outcome=S.declined)

    index = _index(db_session, pro)

    assert index.response_bucket == ResponseBucket.over_day
    assert client_label(index.response_bucket) is None


def test_how_fast_someone_replies_never_moves_them_in_the_rankings(db_session):
    fast, fast_pkg = _pro_with_package(db_session)
    slow, slow_pkg = _pro_with_package(db_session)
    for _ in range(3):
        _request(db_session, fast, fast_pkg, answered_after=timedelta(minutes=2))
        _request(db_session, slow, slow_pkg, answered_after=None, outcome=S.expired)

    fast_index, slow_index = _index(db_session, fast), _index(db_session, slow)

    assert fast_index.response_bucket != slow_index.response_bucket
    assert fast_index.ranking_score == slow_index.ranking_score


def test_an_expiry_refreshes_the_label_and_invalidates_cached_cards(db_session):
    pro, package = _pro_with_package(db_session)
    for _ in range(3):
        _request(db_session, pro, package, answered_after=timedelta(minutes=5))
    for _ in range(3):
        # Still pending, past its deadline: the sweep's to expire.
        request = BookingRequest(
            pro_user_id=pro,
            client_user_id=uuid.uuid4(),
            package_id=package,
            requested_start=datetime.now(timezone.utc) + timedelta(days=10),
            requested_end=datetime.now(timezone.utc) + timedelta(days=10, hours=1),
            status=S.pending,
            created_at=datetime.now(timezone.utc) - timedelta(hours=25),
            expires_at=datetime.now(timezone.utc) - timedelta(hours=1),
        )
        db_session.add(request)
    db_session.commit()
    assert _index(db_session, pro).response_bucket == ResponseBucket.within_hour
    version = get_public_index_version()

    expire_pending_booking_requests(db_session, limit=None)
    db_session.commit()

    db_session.expire_all()
    # Six resolved: three in 5 minutes, three expired. An even sample takes
    # the higher middle value - an expiry - so the label goes.
    assert db_session.get(ProPublicIndex, pro).response_bucket == ResponseBucket.over_day
    assert get_public_index_version() > version


def test_clients_get_a_sentence_never_the_minutes(client, db_session):
    pro, package = _pro_with_package(db_session)
    for _ in range(3):
        _request(db_session, pro, package, answered_after=timedelta(minutes=37))
    _index(db_session, pro)

    body = client.get(f"/v1/pros/{pro}/public")

    assert body.status_code == 200, body.text
    assert body.json()["response_label"] == "Usually replies within an hour"
    for schema in (ProPublicProfileResponse, ClientDiscoverCard, ClientProProfileResponse):
        exposed = [name for name in schema.model_fields if "response" in name]
        assert exposed == ["response_label"], (schema.__name__, exposed)


def test_cards_carry_only_a_positive_label_and_the_profile_says_when_there_is_no_history(client, db_session):
    from app.api.v1.client_launch import _cards_from_index

    new, _ = _pro_with_package(db_session)
    quick, quick_pkg = _pro_with_package(db_session)
    for _ in range(3):
        _request(db_session, quick, quick_pkg, answered_after=timedelta(minutes=10))
    new_index, quick_index = _index(db_session, new), _index(db_session, quick)

    cards = {card.pro_user_id: card for card in _cards_from_index(db_session, [new_index, quick_index])}
    assert cards[new].response_label is None, "on a card it would sit on almost everyone"
    assert cards[quick].response_label == "Usually replies within an hour"

    from app.models.admin import UserRoleType
    from tests.test_client_launch import _enable_city_and_flags, _seed_user

    _enable_city_and_flags(db_session)
    viewer = str(uuid.uuid4())
    _seed_user(db_session, viewer, [UserRoleType.client])
    profile = client.get(f"/v1/client/pros/{new}", params={"country": "PT", "city": "Lisbon"}, headers={"X-User-Id": viewer})
    assert profile.status_code == 200, profile.text
    assert profile.json()["response_label"] == "No response history yet"


def _backfill_sql() -> str:
    import importlib.util
    from pathlib import Path

    path = Path(__file__).resolve().parents[1] / "alembic" / "versions" / "20261007_0056_response_bucket.py"
    spec = importlib.util.spec_from_file_location("migration_0056", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.BACKFILL_SQL


def test_the_migration_backfill_agrees_with_the_python_rule_on_every_edge(db_session):
    """Existing rows are filled in by SQL, everything after by Python: two
    implementations of one rule, so they are run against the same awkward
    histories and must agree exactly."""
    from sqlalchemy import text, update

    from app.services.response_time import bucket_for, response_median_minutes

    m = lambda n: timedelta(minutes=n)  # noqa: E731
    histories = {
        "two only": [dict(answered_after=m(5))] * 2,
        "exactly three": [dict(answered_after=m(15), outcome=S.declined)] * 3,
        "exactly an hour": [dict(answered_after=m(60))] * 3,
        "a minute over an hour": [dict(answered_after=m(61))] * 3,
        "exactly six hours": [dict(answered_after=m(360))] * 3,
        "exactly a day": [dict(answered_after=m(1440), window=timedelta(hours=48))] * 3,
        "a minute over a day": [dict(answered_after=m(1441), window=timedelta(hours=48))] * 3,
        "a hair under an hour": [dict(answered_after=timedelta(minutes=59, seconds=59, milliseconds=900))] * 3,
        "even count, median between minutes": [dict(answered_after=m(10))] * 2 + [dict(answered_after=m(11))] * 2,
        "even count, fractional midpoint": [dict(answered_after=m(60)), dict(answered_after=m(61)), dict(answered_after=m(1)), dict(answered_after=m(500))],
        "expired on a 48h window": [dict(answered_after=None, outcome=S.expired, window=timedelta(hours=48))] * 2 + [dict(answered_after=m(5))],
        "swept late, still its window": [dict(answered_after=timedelta(hours=30), outcome=S.expired)] * 3,
        "old slow, recent quick": [dict(answered_after=None, outcome=S.expired, ago=timedelta(days=40))] * 5
        + [dict(answered_after=m(3), ago=timedelta(days=2))] * 10,
        "old quick, recent slow": [dict(answered_after=m(3), ago=timedelta(days=40))] * 5
        + [dict(answered_after=None, outcome=S.expired, ago=timedelta(days=2))] * 10,
        # Ten recent split evenly, so the eleventh-newest - if it were read -
        # would move the median from 100 minutes to 3.
        "the eleventh does not count": [dict(answered_after=m(3), ago=timedelta(days=40))]
        + [dict(answered_after=m(3), ago=timedelta(days=2))] * 5
        + [dict(answered_after=m(100), ago=timedelta(days=2))] * 5,
        "median exactly on an expired request": [dict(answered_after=m(30))] * 2
        + [dict(answered_after=None, outcome=S.expired)] * 3,
        # The lower middle value would be a reply in 20 minutes.
        "5 replied, 5 expired": [dict(answered_after=m(20))] * 5 + [dict(answered_after=None, outcome=S.expired)] * 5,
        # A short-notice request has 30 minutes; ignoring it is no faster a
        # reply than ignoring an ordinary one.
        "short-notice requests expired after 30 minutes": [dict(answered_after=None, outcome=S.expired, window=m(30))] * 3,
        "cancellations between": [dict(answered_after=m(20), outcome=S.cancelled)] * 4 + [dict(answered_after=m(40))] * 3,
        "answered before it was asked": [dict(answered_after=m(-5))] * 3,
        "none at all": [],
    }
    pros: dict[str, uuid.UUID] = {}
    for name, requests in histories.items():
        pro, package = _pro_with_package(db_session)
        for kwargs in requests:
            _request(db_session, pro, package, **kwargs)
        _index(db_session, pro)
        pros[name] = pro
    # As the migration finds them: the new columns at their defaults.
    db_session.execute(
        update(ProPublicIndex)
        .where(ProPublicIndex.pro_user_id.in_(pros.values()))
        .values(response_median_minutes=None, response_bucket="no_history")
    )
    db_session.commit()

    db_session.execute(text(_backfill_sql()))
    db_session.commit()
    db_session.expire_all()

    for name, pro in pros.items():
        minutes, _ = response_median_minutes(db_session, pro)
        row = db_session.get(ProPublicIndex, pro)
        assert (row.response_median_minutes, row.response_bucket) == (minutes, bucket_for(minutes).value), name

    bucket = lambda name: db_session.get(ProPublicIndex, pros[name]).response_bucket  # noqa: E731
    # The fixtures do reach the edges they are named for.
    assert bucket("exactly an hour") == "within_hour" and bucket("a minute over an hour") == "few_hours"
    assert bucket("exactly a day") == "within_day" and bucket("a minute over a day") == "over_day"
    median = lambda name: db_session.get(ProPublicIndex, pros[name]).response_median_minutes  # noqa: E731
    # An even sample takes the higher middle value.
    assert median("even count, median between minutes") == 11
    assert bucket("even count, fractional midpoint") == "few_hours"  # 1, 60, 61, 500: the higher middle is 61
    assert median("5 replied, 5 expired") == 24 * 60 + 1 and bucket("5 replied, 5 expired") == "over_day"
    # An expiry is just past its window, however late the sweep ran.
    assert median("median exactly on an expired request") == 24 * 60 + 1
    assert median("swept late, still its window") == 24 * 60 + 1
    # An expiry counts as the standard day and a minute, whatever its own window.
    assert median("expired on a 48h window") == 24 * 60 + 1
    assert median("short-notice requests expired after 30 minutes") == 24 * 60 + 1
    assert bucket("short-notice requests expired after 30 minutes") == "over_day"
    assert bucket("old slow, recent quick") == "within_hour" and bucket("old quick, recent slow") == "over_day"
    assert bucket("two only") == bucket("none at all") == "no_history"
    assert median("the eleventh does not count") == 100
