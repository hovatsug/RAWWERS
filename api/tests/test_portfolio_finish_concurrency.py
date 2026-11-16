"""Two photos of one photographer finished at the same moment (dev, 2026-11-16).

Lightroom finishes several photos at once. Before 1.2.3 each finish
recomputed the photographer's niche skills after committing the photo, and
two of them deadlocked on `pro_niche_skill`: "deadlock detected", a 500,
and a photo left without its niche. Since 1.2.3 a finish takes a
per-photographer lock before it recomputes anything, and the recompute
walks the niches in a fixed order.

These tests run against the real Postgres of the test run, with one
connection per thread, as two API workers would.
"""
import threading
import uuid

import pytest
from sqlalchemy import event, select
from sqlalchemy.engine import Engine

from app.api.v1 import delivery as delivery_routes
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.models.niche import Niche, ProNiche
from app.schemas.delivery import DeliveryCompleteRequest
from app.services import niche_skills
from tests.conftest import TestingSessionLocal
from tests.test_delivery_gigs import _pro
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture: no broker)

ROUNDS = 25


def _photographer(db_session, niche_count=4):
    pro = _pro(db_session)
    niches = db_session.execute(select(Niche).where(Niche.is_active.is_(True)).order_by(Niche.slug)).scalars().all()[:niche_count]
    for n, niche in enumerate(niches):
        db_session.add(ProNiche(pro_user_id=pro, niche_id=niche.id, is_primary=n == 0))
    db_session.commit()
    return pro, [n.slug for n in niches]


def _waiting_photo(db_session, pro, slug):
    sha = uuid.uuid4().hex * 2
    asset = MediaAsset(
        owner_user_id=pro, kind=MediaKind.photo, purpose=MediaPurpose.portfolio_reel, provider=MediaProvider.r2,
        status=MediaStatus.uploading, visibility=MediaVisibility.public, content_type="image/jpeg", checksum=sha,
        meta={"lightroom_niche": slug, "source": "lightroom"},
    )
    db_session.add(asset)
    db_session.commit()
    return asset.id, sha


def _finish_in_own_session(pro, asset_id, sha, barrier, errors):
    db = TestingSessionLocal()
    try:
        device = delivery_routes.DeliveryDevice(pro_user_id=pro, device_id=uuid.uuid4(), plugin_version="1.2.3")
        barrier.wait(timeout=30)
        delivery_routes.finish_upload(asset_id, DeliveryCompleteRequest(byte_size=500_000, sha256=sha), device, db)
    except Exception as exc:  # noqa: BLE001 - every failure is the finding
        errors.append(f"{type(exc).__name__}: {str(exc).splitlines()[0][:160]}")
        db.rollback()
    finally:
        db.close()


def test_two_photos_finished_at_once_never_deadlock_and_both_get_their_niche(db_session):
    pro, slugs = _photographer(db_session)
    errors: list[str] = []
    finished = []
    for round_ in range(ROUNDS):
        # Two different niches, as two collections publishing at once.
        a = _waiting_photo(db_session, pro, slugs[round_ % len(slugs)])
        b = _waiting_photo(db_session, pro, slugs[(round_ + 1) % len(slugs)])
        barrier = threading.Barrier(2)
        threads = [threading.Thread(target=_finish_in_own_session, args=(pro, *photo, barrier, errors)) for photo in (a, b)]
        for t in threads:
            t.start()
        for t in threads:
            t.join(timeout=120)
        finished += [a[0], b[0]]
    assert errors == [], f"{len(errors)} of {2 * ROUNDS} finishes failed: {errors[:3]}"
    db_session.expire_all()
    rows = db_session.execute(select(MediaAsset).where(MediaAsset.id.in_(finished))).scalars().all()
    assert all(r.status == MediaStatus.processing for r in rows)
    assert all(r.niche_tags == [r.meta["lightroom_niche"]] for r in rows)


def _statements_during(db_session, fn):
    """The SQL `fn` sends, whatever engine or connection it goes through."""
    seen: list[tuple[str, dict]] = []
    db_session.commit()
    db_session.close()

    def record(conn, cursor, statement, parameters, context, executemany):
        seen.append((statement, parameters))

    event.listen(Engine, "before_cursor_execute", record)
    try:
        fn()
    finally:
        event.remove(Engine, "before_cursor_execute", record)
    return seen


def test_a_finish_takes_the_photographers_lock_before_any_skill_row(db_session):
    """The deterministic half: whatever the timing, the lock comes first."""
    pro, slugs = _photographer(db_session)
    asset_id, sha = _waiting_photo(db_session, pro, slugs[1])
    device = delivery_routes.DeliveryDevice(pro_user_id=pro, device_id=uuid.uuid4(), plugin_version="1.2.3")
    seen = _statements_during(
        db_session,
        lambda: delivery_routes.finish_upload(asset_id, DeliveryCompleteRequest(byte_size=500_000, sha256=sha), device, db_session)
    )
    lock = next(i for i, (s, _p) in enumerate(seen) if "FROM pro_profile" in s and "FOR UPDATE" in s)
    first_skill_write = next(i for i, (s, _p) in enumerate(seen) if s.lstrip().upper().startswith(("UPDATE PRO_NICHE_SKILL", "INSERT INTO PRO_NICHE_SKILL")))
    first_photo_write = next(i for i, (s, _p) in enumerate(seen) if s.lstrip().upper().startswith("UPDATE MEDIA_ASSET"))
    assert lock < first_skill_write and lock < first_photo_write


def test_the_recompute_walks_the_niches_in_one_fixed_order(db_session):
    """Every recompute of a photographer writes their skill rows in niche-id order."""
    pro, _slugs = _photographer(db_session, niche_count=6)
    niche_skills.recompute_pro_niche_skills(db_session, pro)  # rows exist
    db_session.commit()
    ids_by_skill = {}
    for skill in db_session.execute(select(niche_skills.ProNicheSkill).where(niche_skills.ProNicheSkill.pro_user_id == pro)).scalars():
        ids_by_skill[str(skill.id)] = str(skill.niche_id)

    seen = _statements_during(db_session, lambda: niche_skills.recompute_pro_niche_skills(db_session, pro))
    db_session.rollback()
    order = []
    for statement, params in seen:
        if statement.lstrip().upper().startswith("UPDATE PRO_NICHE_SKILL"):
            for p in params if isinstance(params, (list, tuple)) else [params]:
                skill_id = str(p.get("pro_niche_skill_id"))
                if skill_id in ids_by_skill:
                    order.append(ids_by_skill[skill_id])
    assert len(order) >= 6
    assert order == sorted(order, key=lambda niche_id: uuid.UUID(niche_id)), "the niches were not walked in id order"
