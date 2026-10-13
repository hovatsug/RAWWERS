"""An admin's tier decision is kept until an admin removes it, and a
photographer's niches come out in the same order every time.

Both were broken in a way only a recompute showed. An override was written
under a key the recompute never read, and the recompute then replaced the
record: once the hysteresis window had passed, the next recompute - a
review, an accepted booking, a rebuild-all - quietly put the evidence tier
back (proven: elite back to rookie). And tied niches came out in the
database's physical row order, so a photographer's primary niche - which
decides the niche row they are guaranteed a place in - could change on any
recompute: a second rebuild-all changed 58 rows on dev.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from app.models.admin import AdminAuditLog, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.discovery import ProPublicIndex
from app.models.niche import Niche, ProNiche, ProNicheSkill, ProNicheSkillEvent, ProNicheSkillEventType, SkillTier
from app.services.discovery_index import recompute_all_pro_public_indexes, recompute_pro_public_index
from app.services.niche_skills import recompute_pro_niche_skill, recompute_pro_niche_skills
from sqlalchemy import select

ADMIN = uuid.UUID("00000000-0000-0000-0000-0000000000aa")  # the suite's admin (conftest)


def _pro(db_session, *, niches=("portraits",), primary=None) -> uuid.UUID:
    pro = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro))
    db_session.flush()
    db_session.add(UserRole(user_id=pro, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=pro, display_name="Ana", city="Lisbon", country="PT"))
    for slug in niches:
        niche = db_session.execute(select(Niche).where(Niche.slug == slug)).scalar_one()
        db_session.add(ProNiche(pro_user_id=pro, niche_id=niche.id, is_primary=slug == primary))
    db_session.commit()
    return pro


def _niche(db_session, slug="portraits") -> Niche:
    return db_session.execute(select(Niche).where(Niche.slug == slug)).scalar_one()


def _skill(db_session, pro, niche) -> ProNicheSkill:
    db_session.expire_all()
    return db_session.execute(
        select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro, ProNicheSkill.niche_id == niche.id)
    ).scalar_one()


def _override(client, pro, niche, tier="elite", reason="Known to us: ten years of weddings"):
    resp = client.post(
        f"/v1/admin/pros/{pro}/niche-skill/{niche.id}/override",
        headers={"X-User-Id": str(ADMIN)},
        json={"tier": tier, "note": reason},
    )
    assert resp.status_code == 200, resp.text
    return resp.json()


def _a_year_on(db_session, pro, niche):
    """Move every clock the recompute looks at a year into the past."""
    skill = _skill(db_session, pro, niche)
    year = timedelta(days=365)
    for name in ("last_promotion_at", "last_demotion_at", "override_at"):
        if getattr(skill, name) is not None:
            setattr(skill, name, getattr(skill, name) - year)
    db_session.commit()


# --- an override is kept ---------------------------------------------------------


def test_an_override_survives_a_recompute_long_after_the_hysteresis_window(client, db_session):
    pro, niche = _pro(db_session), _niche(db_session)
    recompute_pro_niche_skills(db_session, pro)
    db_session.commit()
    _override(client, pro, niche)
    _a_year_on(db_session, pro, niche)

    recompute_pro_niche_skill(db_session, pro, niche.id)
    db_session.commit()

    skill = _skill(db_session, pro, niche)
    assert skill.tier == SkillTier.elite, "the admin's decision"
    assert skill.evidence_tier == SkillTier.rookie, "what the evidence alone says, kept beside it"
    assert (skill.override_tier, skill.override_by, skill.override_reason) == (SkillTier.elite, ADMIN, "Known to us: ten years of weddings")


def test_an_override_survives_rebuild_all_twice_and_is_counted(client, db_session):
    pro, niche = _pro(db_session), _niche(db_session)
    recompute_pro_niche_skills(db_session, pro)
    db_session.commit()
    _override(client, pro, niche)
    _a_year_on(db_session, pro, niche)

    for _ in range(2):
        result = recompute_all_pro_public_indexes(db_session)
        db_session.commit()
        assert result.overrides_preserved == 1, "exactly the one override, still in force"
        assert _skill(db_session, pro, niche).tier == SkillTier.elite
    assert db_session.get(ProPublicIndex, pro).niche_tiers["portraits"] == "elite"


def test_removing_an_override_returns_to_the_evidence_at_once(client, db_session):
    pro, niche = _pro(db_session), _niche(db_session)
    recompute_pro_niche_skills(db_session, pro)
    db_session.commit()
    _override(client, pro, niche)

    resp = client.request(
        "DELETE",
        f"/v1/admin/pros/{pro}/niche-skill/{niche.id}/override",
        headers={"X-User-Id": str(ADMIN)},
        json={"reason": "Evidence has caught up"},
    )

    assert resp.status_code == 200, resp.text
    skill = _skill(db_session, pro, niche)
    assert skill.tier == SkillTier.rookie, "no hysteresis on removing an admin's decision"
    assert skill.override_tier is None


def test_setting_and_removing_an_override_are_both_audited(client, db_session):
    pro, niche = _pro(db_session), _niche(db_session)
    recompute_pro_niche_skills(db_session, pro)
    db_session.commit()
    _override(client, pro, niche, reason="Portfolio reviewed by the team")
    client.request(
        "DELETE", f"/v1/admin/pros/{pro}/niche-skill/{niche.id}/override", headers={"X-User-Id": str(ADMIN)}, json={"reason": "Done"}
    )

    db_session.expire_all()
    events = db_session.execute(
        select(ProNicheSkillEvent.event_type).where(ProNicheSkillEvent.pro_user_id == pro).order_by(ProNicheSkillEvent.created_at)
    ).scalars().all()
    assert events.count(ProNicheSkillEventType.admin_override) == 1
    assert events.count(ProNicheSkillEventType.override_removed) == 1
    actions = db_session.execute(
        select(AdminAuditLog.action).where(AdminAuditLog.target_id.contains(str(pro)))
    ).scalars().all()
    assert sorted(a for a in actions if a.startswith("niche_skill_override")) == ["niche_skill_override_removed", "niche_skill_override_set"], actions


def test_an_override_does_not_count_as_a_tier_change_for_hysteresis(client, db_session):
    """Hysteresis damps the evidence flapping; an admin's decision is not
    evidence, so setting one must not hold back the evidence later."""
    pro, niche = _pro(db_session), _niche(db_session)
    recompute_pro_niche_skills(db_session, pro)
    db_session.commit()
    before = _skill(db_session, pro, niche)
    promoted, demoted = before.last_promotion_at, before.last_demotion_at

    _override(client, pro, niche)

    after = _skill(db_session, pro, niche)
    assert (after.last_promotion_at, after.last_demotion_at) == (promoted, demoted)


def test_the_admin_view_says_when_the_evidence_disagrees(client, db_session):
    pro, niche = _pro(db_session), _niche(db_session)
    recompute_pro_niche_skills(db_session, pro)
    db_session.commit()
    _override(client, pro, niche)

    items = client.get(f"/v1/admin/pros/{pro}/niche-skill", headers={"X-User-Id": str(ADMIN)}).json()["items"]

    [row] = [i for i in items if i["niche_slug"] == "portraits"]
    assert row["tier"] == "elite" and row["evidence_tier"] == "rookie"
    assert row["evidence_disagrees"] is True
    assert row["active_override"]["reason"] == "Known to us: ten years of weddings"
    assert row["active_override"]["by"] == str(ADMIN)


@pytest.mark.parametrize("as_self", [True, False], ids=["own skills", "public skills"])
def test_every_skills_view_names_its_niche_by_id(client, db_session, as_self):
    # niche_id is required in the shared view; a builder that leaves it out
    # turns the whole response into a 500, not a missing field.
    pro, niche = _pro(db_session), _niche(db_session)
    recompute_pro_niche_skills(db_session, pro)
    db_session.commit()

    path = "/v1/pro/me/skills" if as_self else f"/v1/pros/{pro}/skills"
    resp = client.get(path, headers={"X-User-Id": str(pro)})

    assert resp.status_code == 200, resp.text
    [row] = [i for i in resp.json()["items"] if i["niche_slug"] == "portraits"]
    assert row["niche_id"] == str(niche.id)


def test_an_override_is_not_lost_through_the_per_photographer_recompute(client, db_session):
    """Every booking accepted or review published recomputes the index -
    the path that was losing overrides in ordinary use, not only on deploy."""
    pro, niche = _pro(db_session), _niche(db_session)
    recompute_pro_niche_skills(db_session, pro)
    db_session.commit()
    _override(client, pro, niche)
    _a_year_on(db_session, pro, niche)

    recompute_pro_public_index(db_session, pro)
    db_session.commit()

    assert _skill(db_session, pro, niche).tier == SkillTier.elite


# --- the tie-break -----------------------------------------------------------------


def test_tied_niches_put_the_photographers_own_primary_first(db_session):
    # Written so the database's own order would put the primary last.
    pro = _pro(db_session, niches=("weddings", "portraits", "family", "food"), primary="food")
    recompute_pro_public_index(db_session, pro)
    db_session.commit()

    index = db_session.get(ProPublicIndex, pro)
    assert index.top_niches[0]["slug"] == "food"
    assert index.primary_niche_id == _niche(db_session, "food").id


def test_tied_niches_without_a_primary_follow_the_niche_id(db_session):
    pro = _pro(db_session, niches=("weddings", "portraits", "family"))
    recompute_pro_public_index(db_session, pro)
    db_session.commit()
    first = [n["slug"] for n in db_session.get(ProPublicIndex, pro).top_niches]

    # Rewrite every skill row - which moves it in the table - and recompute.
    for skill in db_session.execute(select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro)).scalars():
        skill.updated_at = datetime.now(timezone.utc)
    db_session.commit()
    recompute_pro_public_index(db_session, pro)
    db_session.commit()

    assert [n["slug"] for n in db_session.get(ProPublicIndex, pro).top_niches] == first
    by_id = sorted(db_session.execute(select(Niche).where(Niche.slug.in_(first))).scalars(), key=lambda n: str(n.id))
    assert first == [n.slug for n in by_id][: len(first)]


def test_tied_niches_follow_the_niche_id_whatever_order_they_arrive_in():
    """Pure ordering, fed the rows backwards: on a small test database
    Postgres happens to return them in id order already, so only this shows
    the tie-break is doing the work. On dev's larger tables it did not, which
    is how a second rebuild-all changed 58 rows."""
    from types import SimpleNamespace

    from app.services.niche_skills import order_niches

    niches = sorted((SimpleNamespace(id=uuid.uuid4()) for _ in range(6)), key=lambda n: str(n.id))
    skill = SimpleNamespace(tier=SkillTier.rookie, score=0, avg_rating=0, gigs_completed=0)
    rows = [(skill, n) for n in reversed(niches)]

    assert [n.id for _, n in order_niches(rows, set())] == [n.id for n in niches]
    primary = niches[3].id
    assert [n.id for _, n in order_niches(rows, {primary})][0] == primary


def test_a_second_rebuild_all_changes_nothing(db_session):
    for niches, primary in ((("weddings", "portraits"), None), (("family", "food", "portraits"), "food"), (("weddings",), "weddings")):
        _pro(db_session, niches=niches, primary=primary)
    recompute_all_pro_public_indexes(db_session)
    db_session.commit()

    def snapshot():
        db_session.expire_all()
        columns = [c.key for c in ProPublicIndex.__table__.columns if c.key not in ("updated_at",)]
        return {row.pro_user_id: tuple(getattr(row, c) for c in columns) for row in db_session.execute(select(ProPublicIndex)).scalars()}

    first = snapshot()
    recompute_all_pro_public_indexes(db_session)
    db_session.commit()

    assert snapshot() == first


# --- the deploy checklist's query for overrides lost before the fix --------------


def _checklist_query() -> str:
    """The query exactly as the deploy checklist prints it - so the one
    tested is the one a person will run."""
    import re
    from pathlib import Path

    doc = (Path(__file__).resolve().parents[2] / "docs" / "DEPLOY_CHECKLIST.md").read_text()
    section = doc[doc.index("Admin tier overrides lost before migration") :]
    block = re.search(r"\n((?:      .*\n)+)", section).group(1)
    return "\n".join(line[6:] for line in block.splitlines())


def test_the_checklists_lost_override_query_finds_exactly_the_lost_one(client, db_session):
    from sqlalchemy import text

    from app.models.niche import ProNicheSkillActorType

    niche = _niche(db_session)
    lost, kept, never = _pro(db_session), _pro(db_session), _pro(db_session)
    for pro in (lost, kept, never):
        recompute_pro_niche_skills(db_session, pro)
    db_session.commit()
    _override(client, kept, niche)
    # What the old code left behind: the event says an admin set elite, and
    # the skill row has no trace of it.
    db_session.add(
        ProNicheSkillEvent(
            pro_user_id=lost,
            niche_id=niche.id,
            event_type=ProNicheSkillEventType.admin_override,
            from_tier="rookie",
            to_tier="elite",
            score_before=0,
            score_after=0,
            reasons={"note": "Ten years of weddings"},
            actor_type=ProNicheSkillActorType.admin,
            actor_user_id=ADMIN,
        )
    )
    db_session.commit()

    rows = db_session.execute(text(_checklist_query())).mappings().all()

    by_pro = {r["pro_user_id"]: r for r in rows}
    assert set(by_pro) == {lost, kept}, "every pro with an override event, nobody else"
    assert by_pro[lost]["override_tier"] is None and by_pro[lost]["tier_now"] == "rookie", "the lost one shows as lost"
    assert by_pro[lost]["to_tier"] == "elite" and by_pro[lost]["reason"] == "Ten years of weddings"
    assert by_pro[kept]["override_tier"] == "elite", "the one still in force shows as kept"
