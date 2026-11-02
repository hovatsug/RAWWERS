"""Marketing wording: versions an admin creates and publishes once a lawyer has reviewed them.

Owner's decision (2026-11-02): a version is pasted in EN or PT and starts as
a draft. Publishing needs "reviewed by" and a note, and is logged with the
admin and the time. A published version is never edited: a change is a new
version. In production marketing consent is offered only when the version
shown is a reviewed one.
"""
from sqlalchemy import select

from app.core.config import get_settings
from app.models.admin import AdminAuditLog
from app.models.marketing_consent import MarketingWording, MarketingWordingAudience
from app.services import marketing_consent as mc

ADMIN = "00000000-0000-0000-0000-0000000000aa"
H = {"X-User-Id": ADMIN}


def _create(client, audience="client", language="en", text="Reviewed wording, version 1."):
    resp = client.post("/v1/admin/marketing/wordings", headers=H, json={"audience": audience, "language": language, "text": text})
    assert resp.status_code == 200, resp.text
    return resp.json()


def _publish(client, version, reviewed_by="Dr. Ana Costa, Costa & Lda", note="Reviewed against the beta terms"):
    return client.post(f"/v1/admin/marketing/wordings/{version}/publish", headers=H, json={"reviewed_by": reviewed_by, "note": note})


def test_a_draft_cannot_be_published_without_reviewed_by(client, db_session):
    version = _create(client)["version"]

    resp = _publish(client, version, reviewed_by="  ")

    assert resp.status_code == 422
    db_session.expire_all()
    row = db_session.get(MarketingWording, version)
    assert (row.is_draft, row.is_active, row.published_at) == (True, False, None)


def test_publishing_needs_a_note(client, db_session):
    version = _create(client)["version"]
    assert _publish(client, version, note="").status_code == 422


def test_the_list_shows_versions_with_status_and_language(client, db_session):
    created = _create(client, language="pt", text="Texto revisto.")
    items = client.get("/v1/admin/marketing/wordings", headers=H).json()["items"]
    by_version = {i["version"]: i for i in items}
    assert by_version["client-draft-1"]["status"] == "draft" and by_version["client-draft-1"]["in_use"] is True
    assert (by_version[created["version"]]["status"], by_version[created["version"]]["language"]) == ("draft", "pt")


def test_publishing_replaces_the_version_shown_and_is_logged(client, db_session):
    version = _create(client)["version"]

    resp = _publish(client, version)

    assert resp.status_code == 200, resp.text
    assert (resp.json()["status"], resp.json()["in_use"], resp.json()["reviewed_by"]) == ("published", True, "Dr. Ana Costa, Costa & Lda")
    db_session.expire_all()
    assert db_session.get(MarketingWording, "client-draft-1").is_active is False
    assert mc.active_wording(db_session, MarketingWordingAudience.client).version == version
    log = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_id == version, AdminAuditLog.action == "marketing_wording_published")).scalar_one()
    assert str(log.actor_user_id) == ADMIN and log.reason == "Reviewed against the beta terms" and log.created_at is not None


def test_a_published_version_is_never_changed(client, db_session):
    version = _create(client)["version"]
    _publish(client, version)

    again = _publish(client, version, reviewed_by="Someone else")

    assert again.status_code == 409
    db_session.expire_all()
    assert db_session.get(MarketingWording, version).reviewed_by == "Dr. Ana Costa, Costa & Lda"
    paths = {getattr(r, "path", "") for r in client.app.routes}
    assert not any(p.startswith("/v1/admin/marketing/wordings/{version}") and p.endswith("}") for p in paths), "no edit route"


def test_in_production_it_is_offered_only_once_reviewed_wordings_are_published(client, db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "app_env", "production")
    assert mc.feature_enabled(db_session) is False
    mc.publish_wording(db_session, mc.create_wording(db_session, audience=MarketingWordingAudience.client, language="en", text="C", actor_user_id=None).version, reviewed_by="Lawyer", note="ok", actor_user_id=None)
    assert mc.feature_enabled(db_session) is False, "the photographer's wording is still the draft"
    mc.publish_wording(db_session, mc.create_wording(db_session, audience=MarketingWordingAudience.photographer, language="en", text="P", actor_user_id=None).version, reviewed_by="Lawyer", note="ok", actor_user_id=None)
    assert mc.feature_enabled(db_session) is True


def test_a_portuguese_speaker_sees_the_published_pt_wording(client, db_session):
    import uuid

    from app.models.admin import UserAccount
    from app.services.i18n import upsert_user_locale_preference

    user = uuid.uuid4()
    db_session.add(UserAccount(user_id=user))
    db_session.flush()
    upsert_user_locale_preference(db_session, user_id=user, locale="pt-PT")
    pt = mc.create_wording(db_session, audience=MarketingWordingAudience.client, language="pt", text="Texto revisto.", actor_user_id=None)
    mc.publish_wording(db_session, pt.version, reviewed_by="Advogada", note="ok", actor_user_id=None)

    assert mc.active_wording(db_session, MarketingWordingAudience.client, mc.user_language(db_session, user)).version == pt.version
    assert mc.active_wording(db_session, MarketingWordingAudience.client, "en").version == "client-draft-1"


def test_only_an_admin_manages_wording(client, db_session):
    import uuid

    assert client.get("/v1/admin/marketing/wordings", headers={"X-User-Id": str(uuid.uuid4())}).status_code in (401, 403)


def test_the_seeded_placeholder_cannot_be_published(client, db_session):
    client.get("/v1/admin/marketing/wordings", headers=H)
    assert _publish(client, "client-draft-1").status_code == 409
