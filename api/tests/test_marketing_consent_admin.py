"""Marketing-use consent: the admin content library.

Owner's decisions (2026-11-01/02):
- A list of consents with preview thumbnails, the client's first name, the
  photographer, scope, end date and status, with filters. It reads only the
  new per-photo records: they are the only authority for RAWWERS's own use.
- An admin opens an original through a signed link for an ACTIVE consent
  only, and every such access is logged.
- A usage log: "used in <content> on <date>" against one or more consents.
  A content's retire-by date is the earliest end date of its consents; the
  "Expiring soon" list sorts by it.
- "Take down by": for withdrawn or expired consents that have recorded
  uses, the date by which they must come down - 30 days for channels RAWWERS
  owns.
"""
import uuid
from datetime import date, datetime, timedelta, timezone

import pytest
from sqlalchemy import select

from app.models.admin import AdminAuditLog, UserAccount
from app.models.marketing_consent import MarketingConsent, MarketingOriginalAccess
from app.services import marketing_consent as mc
from tests.test_download_payment_gate import fake_stripe  # noqa: F401
from tests.test_marketing_consent_client import _booking

ADMIN = "00000000-0000-0000-0000-0000000000aa"
H = {"X-User-Id": ADMIN}


@pytest.fixture(autouse=True)
def signed(monkeypatch):
    monkeypatch.setattr("app.api.v1.marketing_consent_admin.create_presigned_get", lambda key, expires_in=300: f"https://r2.invalid/{key}?ttl={expires_in}")


def _granted(client, db_session, count=2, client_name="Marta Ribeiro"):
    client_id, gig, assets = _booking(client, db_session)
    db_session.get(UserAccount, uuid.UUID(client_id)).display_name = client_name
    db_session.commit()
    rows, _credit = mc.grant(db_session, gig, client_user_id=uuid.UUID(client_id), asset_ids=[uuid.UUID(a) for a in assets[:count]], term_months=12, people_confirmed=True)
    db_session.commit()
    return client_id, gig, rows


def _library(client, **params):
    resp = client.get("/v1/admin/marketing/consents", headers=H, params=params)
    assert resp.status_code == 200, resp.text
    return resp.json()["items"]


def test_the_library_lists_consents_with_what_an_admin_needs(client, db_session, fake_stripe):
    _client_id, gig, rows = _granted(client, db_session)

    items = _library(client)

    assert {i["id"] for i in items} == {str(r.id) for r in rows}
    item = items[0]
    assert item["client_first_name"] == "Marta"
    assert (item["photographer_credit"], item["pro_user_id"]) == ("Alex Lens", str(gig.pro_user_id))
    assert (item["scope"], item["status"], item["term_months"]) == ("rawwers_organic", "active", 12)
    assert item["ends_at"] and "thumbnail_url" in item
    assert "email" not in str(item).lower()


def test_the_library_filters_by_status_and_photographer(client, db_session, fake_stripe):
    client_id, gig, rows = _granted(client, db_session)
    _other_client, other_gig, other_rows = _granted(client, db_session, count=1)
    mc.withdraw(db_session, uuid.UUID(client_id), [rows[0].id])
    db_session.commit()

    assert {i["id"] for i in _library(client, status="withdrawn")} == {str(rows[0].id)}
    assert {i["id"] for i in _library(client, pro_user_id=str(other_gig.pro_user_id))} == {str(other_rows[0].id)}
    assert len(_library(client, status="active")) == 2


def test_only_an_admin_sees_the_library(client, db_session, fake_stripe):
    client_id, _gig, _rows = _granted(client, db_session)
    assert client.get("/v1/admin/marketing/consents", headers={"X-User-Id": client_id}).status_code == 403


# --- originals ------------------------------------------------------------------------------


def test_an_active_consents_original_opens_through_a_signed_link_and_is_logged(client, db_session, fake_stripe):
    _client_id, _gig, rows = _granted(client, db_session, count=1)

    resp = client.post(f"/v1/admin/marketing/consents/{rows[0].id}/original", headers=H)

    assert resp.status_code == 200, resp.text
    assert resp.json()["url"].startswith("https://r2.invalid/") and resp.json()["expires_in_seconds"] <= 300
    db_session.expire_all()
    (access,) = db_session.execute(select(MarketingOriginalAccess).where(MarketingOriginalAccess.consent_id == rows[0].id)).scalars().all()
    assert str(access.admin_user_id) == ADMIN
    assert db_session.execute(
        select(AdminAuditLog).where(AdminAuditLog.target_id == str(rows[0].id), AdminAuditLog.action == "marketing_original_opened")
    ).scalar_one()


@pytest.mark.parametrize("ended", ["withdrawn", "expired"])
def test_no_original_once_a_consent_has_ended(client, db_session, fake_stripe, ended):
    client_id, _gig, rows = _granted(client, db_session, count=1)
    if ended == "withdrawn":
        mc.withdraw(db_session, uuid.UUID(client_id), None)
    else:
        rows[0].ends_at = datetime.now(timezone.utc) - timedelta(days=1)
        db_session.flush()
        assert mc.expire_due(db_session) == 1
    db_session.commit()

    resp = client.post(f"/v1/admin/marketing/consents/{rows[0].id}/original", headers=H)

    assert resp.status_code == 409
    assert db_session.execute(select(MarketingOriginalAccess)).first() is None


# --- the usage log, retire-by, expiring soon, take down by -------------------------------------


def _use(client, name, consents, used_on="2026-11-02"):
    resp = client.post(
        "/v1/admin/marketing/uses",
        headers=H,
        json={"content_name": name, "used_on": used_on, "consent_ids": [str(c.id) for c in consents]},
    )
    assert resp.status_code == 200, resp.text
    return resp.json()


def test_a_use_retires_by_the_earliest_end_date_of_its_consents(client, db_session, fake_stripe):
    _c, _g, rows = _granted(client, db_session)
    rows[0].ends_at = datetime(2027, 3, 1, tzinfo=timezone.utc)
    rows[1].ends_at = datetime(2027, 9, 1, tzinfo=timezone.utc)
    db_session.commit()

    use = _use(client, "Instagram reel: autumn portraits", rows)

    assert use["content_name"] == "Instagram reel: autumn portraits"
    assert use["used_on"] == "2026-11-02"
    assert use["retire_by"] == "2027-03-01"
    assert {c["id"] for c in use["consents"]} == {str(r.id) for r in rows}


def test_a_renewal_moves_the_retire_by_date(client, db_session, fake_stripe):
    client_id, _g, rows = _granted(client, db_session, count=1)
    use = _use(client, "Blog post", rows)
    (renewal,) = mc.renew(db_session, uuid.UUID(client_id), [rows[0].id], 24)
    db_session.commit()

    (listed,) = [u for u in client.get("/v1/admin/marketing/uses", headers=H).json()["items"] if u["id"] == use["id"]]

    assert listed["retire_by"] == renewal.ends_at.date().isoformat()


def test_only_active_consents_can_be_used(client, db_session, fake_stripe):
    client_id, _g, rows = _granted(client, db_session, count=1)
    mc.withdraw(db_session, uuid.UUID(client_id), None)
    db_session.commit()
    resp = client.post("/v1/admin/marketing/uses", headers=H, json={"content_name": "X", "used_on": "2026-11-02", "consent_ids": [str(rows[0].id)]})
    assert resp.status_code == 409
    assert client.post("/v1/admin/marketing/uses", headers=H, json={"content_name": "X", "used_on": "2026-11-02", "consent_ids": []}).status_code == 422


def test_expiring_soon_sorts_uses_by_retire_by(client, db_session, fake_stripe):
    _c, _g, late = _granted(client, db_session, count=1)
    _c2, _g2, soon = _granted(client, db_session, count=1)
    late[0].ends_at = datetime(2027, 6, 1, tzinfo=timezone.utc)
    soon[0].ends_at = datetime(2027, 1, 15, tzinfo=timezone.utc)
    db_session.commit()
    _use(client, "Later", late)
    _use(client, "Sooner", soon)

    items = client.get("/v1/admin/marketing/expiring", headers=H).json()["items"]

    assert [i["content_name"] for i in items] == ["Sooner", "Later"]


def test_take_down_by_is_thirty_days_after_a_used_consent_ends(client, db_session, fake_stripe):
    client_id, _g, rows = _granted(client, db_session)
    _use(client, "Homepage banner", rows[:1])
    _unused = rows[1]
    mc.withdraw(db_session, uuid.UUID(client_id), None)
    db_session.commit()
    withdrawn_at = db_session.get(MarketingConsent, rows[0].id).withdrawn_at

    items = client.get("/v1/admin/marketing/take-down", headers=H).json()["items"]

    assert [(i["consent_id"], i["content_name"]) for i in items] == [(str(rows[0].id), "Homepage banner")], "unused ones need no take-down"
    assert items[0]["take_down_by"] == (withdrawn_at + timedelta(days=30)).date().isoformat()
    assert items[0]["reason"] == "withdrawn"


def test_an_expired_consent_renewed_in_time_needs_no_take_down(client, db_session, fake_stripe):
    client_id, _g, rows = _granted(client, db_session, count=1)
    _use(client, "Newsletter", rows)
    mc.renew(db_session, uuid.UUID(client_id), [rows[0].id], 12)
    rows[0].ends_at = datetime.now(timezone.utc) - timedelta(days=1)
    db_session.flush()
    assert mc.expire_due(db_session) == 1
    db_session.commit()

    assert client.get("/v1/admin/marketing/take-down", headers=H).json()["items"] == []
