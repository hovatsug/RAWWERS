"""Marketing-use consent, the photographer's side.

Owner's decisions (2026-11-01/02): the marketing clause is an account-level
opt-in, off by default, recorded with the date and the wording version.
Per booking, "Allow marketing use" (on by default for a photographer who
opted in) is the photographer's veto, and "Includes children" means no
consent is offered; both lock once a client has granted consent. Turning
the opt-in off stops new offers and withdraws nothing.
"""
import uuid

from sqlalchemy import select

from app.models.admin import UserRole, UserRoleType
from app.models.marketing_consent import ProMarketingAgreement
from app.services import marketing_consent as mc
from tests.delivered import rate
from tests.test_download_payment_gate import fake_stripe  # noqa: F401
from tests.test_review_gate import _delivered


def _pro_booking(client, db_session):
    client_id, gig, _gallery, assets = _delivered(client, db_session)
    db_session.add(UserRole(user_id=gig.pro_user_id, role=UserRoleType.pro))
    db_session.commit()
    return client_id, gig, assets


def _h(user_id):
    return {"X-User-Id": str(user_id)}


def test_the_opt_in_is_off_until_the_photographer_turns_it_on(client, db_session, fake_stripe):
    _client_id, gig, _assets = _pro_booking(client, db_session)

    body = client.get("/v1/pro/me/marketing-agreement", headers=_h(gig.pro_user_id)).json()

    assert body["opted_in"] is False and body["recorded_at"] is None
    assert body["wording_version"] == "photographer-draft-1" and body["wording_text"].startswith("DRAFT")


def test_opting_in_is_recorded_with_the_wording_and_the_date(client, db_session, fake_stripe):
    _client_id, gig, _assets = _pro_booking(client, db_session)

    on = client.put("/v1/pro/me/marketing-agreement", headers=_h(gig.pro_user_id), json={"opted_in": True})
    off = client.put("/v1/pro/me/marketing-agreement", headers=_h(gig.pro_user_id), json={"opted_in": False})

    assert on.status_code == 200 and on.json()["opted_in"] is True and on.json()["recorded_at"]
    assert off.json()["opted_in"] is False
    rows = db_session.execute(select(ProMarketingAgreement).where(ProMarketingAgreement.pro_user_id == gig.pro_user_id)).scalars().all()
    assert [(r.opted_in, r.wording_version) for r in sorted(rows, key=lambda r: r.recorded_at)] == [
        (True, "photographer-draft-1"),
        (False, "photographer-draft-1"),
    ], "every change kept, never overwritten"


def test_only_a_photographer_has_an_agreement(client, db_session, fake_stripe):
    client_id, _gig, _assets = _pro_booking(client, db_session)
    assert client.put("/v1/pro/me/marketing-agreement", headers=_h(client_id), json={"opted_in": True}).status_code == 403


def test_a_bookings_switches_default_from_the_opt_in(client, db_session, fake_stripe):
    _client_id, gig, _assets = _pro_booking(client, db_session)
    url = f"/v1/pro/gigs/{gig.id}/marketing-settings"

    assert client.get(url, headers=_h(gig.pro_user_id)).json() == {
        "allow_marketing": False, "includes_children": False, "locked": False, "opted_in": False,
    }
    client.put("/v1/pro/me/marketing-agreement", headers=_h(gig.pro_user_id), json={"opted_in": True})
    assert client.get(url, headers=_h(gig.pro_user_id)).json()["allow_marketing"] is True


def test_the_photographer_turns_a_booking_off_or_flags_children(client, db_session, fake_stripe):
    _client_id, gig, _assets = _pro_booking(client, db_session)
    client.put("/v1/pro/me/marketing-agreement", headers=_h(gig.pro_user_id), json={"opted_in": True})
    url = f"/v1/pro/gigs/{gig.id}/marketing-settings"

    off = client.put(url, headers=_h(gig.pro_user_id), json={"allow_marketing": False})
    children = client.put(url, headers=_h(gig.pro_user_id), json={"includes_children": True})

    assert off.json()["allow_marketing"] is False
    assert children.json() == {"allow_marketing": False, "includes_children": True, "locked": False, "opted_in": True}


def test_only_the_bookings_photographer_sets_its_switches(client, db_session, fake_stripe):
    client_id, gig, _assets = _pro_booking(client, db_session)
    url = f"/v1/pro/gigs/{gig.id}/marketing-settings"
    assert client.put(url, headers=_h(client_id), json={"allow_marketing": False}).status_code == 403
    assert client.get(url, headers=_h(uuid.uuid4())).status_code in (403, 404)


def test_the_switches_lock_once_a_client_has_granted(client, db_session, fake_stripe):
    client_id, gig, assets = _pro_booking(client, db_session)
    client.put("/v1/pro/me/marketing-agreement", headers=_h(gig.pro_user_id), json={"opted_in": True})
    rate(db_session, gig)
    mc.grant(db_session, gig, client_user_id=uuid.UUID(client_id), asset_ids=[uuid.UUID(assets[0])], term_months=12, people_confirmed=True)
    db_session.commit()
    url = f"/v1/pro/gigs/{gig.id}/marketing-settings"

    assert client.get(url, headers=_h(gig.pro_user_id)).json()["locked"] is True
    resp = client.put(url, headers=_h(gig.pro_user_id), json={"allow_marketing": False})
    assert resp.status_code == 409
    assert client.put(url, headers=_h(gig.pro_user_id), json={"includes_children": True}).status_code == 409
