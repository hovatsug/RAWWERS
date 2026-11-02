"""Marketing-use consent, the client's side: the offer, the grant, the credit, and withdrawing.

Owner's decisions (2026-11-01/02):
- Offered after the star-rating step, only if the photographer opted in at
  account level, has not turned "Allow marketing use" off for the booking,
  and the booking is not flagged "Includes children". Optional, unticked,
  separate from the booking and the review.
- The client picks photos one by one and a term (6, 12 or 24 months;
  12 by default), for organic use on RAWWERS's own channels, and confirms
  everyone shown is an adult who agrees, or that they are the parent or
  guardian.
- RAW credit at the grant: 100 points for 12 months, 50 for 6, 150 for 24;
  once per booking; at most 3 grants a month per client; reduced by any
  points the older consent already paid on that booking. No clawback on
  withdrawal.
- "Allow marketing use" locks once a client has granted consent. Turning
  the account opt-in off stops new offers and withdraws nothing.
- A renewal is a new record under the current wording, with no credit.
- Withdrawal changes the status; nothing is deleted.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from sqlalchemy import select

from app.core.config import get_settings
from app.models.admin import ProProfile
from app.models.marketing_consent import MarketingConsent, MarketingWording, MarketingWordingAudience
from app.models.reward import RewardEntryType, RewardLedgerEntry
from app.services import marketing_consent as mc
from tests.delivered import rate
from tests.test_download_payment_gate import fake_stripe  # noqa: F401
from tests.test_review_gate import _delivered


def _booking(client, db_session, *, opted_in=True, rated=True, name="Alex Lens"):
    client_id, gig, gallery, assets = _delivered(client, db_session)
    db_session.add(ProProfile(user_id=gig.pro_user_id, display_name=name))
    db_session.commit()
    if opted_in:
        mc.record_pro_agreement(db_session, gig.pro_user_id, opted_in=True)
        db_session.commit()
    if rated:
        rate(db_session, gig)
    return client_id, gig, assets


def _offer(client, gig, user_id):
    return client.get(f"/v1/gigs/{gig.id}/marketing-consent/offer", headers={"X-User-Id": str(user_id)})


def _grant(client, gig, user_id, assets, term=12, confirmed=True):
    return client.post(
        f"/v1/gigs/{gig.id}/marketing-consent",
        headers={"X-User-Id": str(user_id)},
        json={"media_asset_ids": [str(a) for a in assets], "term_months": term, "people_confirmed": confirmed},
    )


def _credits(db_session, user_id):
    db_session.expire_all()
    return [
        e.amount
        for e in db_session.execute(
            select(RewardLedgerEntry).where(RewardLedgerEntry.user_id == uuid.UUID(str(user_id)), RewardLedgerEntry.reference_type == "marketing_consent")
        ).scalars()
    ]


# --- the offer -----------------------------------------------------------------------------


def test_offered_after_the_rating_when_the_photographer_opted_in(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)

    body = _offer(client, gig, client_id).json()

    assert body["offered"] is True
    assert body["wording_version"] == "client-draft-1" and body["wording_text"].startswith("DRAFT")
    assert body["default_term_months"] == 12
    assert {t["months"]: t["credit"] for t in body["terms"]} == {6: 50, 12: 100, 24: 150}
    assert body["scope"] == "rawwers_organic"
    assert body["photographer_credit"] == "Alex Lens"
    assert {p["media_asset_id"] for p in body["photos"]} == set(assets)


@pytest.mark.parametrize(
    ("setup", "reason"),
    [
        ("not_opted_in", "photographer_not_opted_in"),
        ("vetoed", "photographer_turned_it_off"),
        ("children", "includes_children"),
        ("not_rated", "rate_first"),
    ],
)
def test_not_offered(client, db_session, fake_stripe, setup, reason):
    client_id, gig, _assets = _booking(client, db_session, opted_in=setup != "not_opted_in", rated=setup != "not_rated")
    if setup == "vetoed":
        mc.set_booking_setting(db_session, gig, actor_user_id=gig.pro_user_id, allow_marketing=False)
    if setup == "children":
        mc.set_booking_setting(db_session, gig, actor_user_id=gig.pro_user_id, includes_children=True)
    db_session.commit()

    body = _offer(client, gig, client_id).json()

    assert (body["offered"], body["reason"]) == (False, reason)
    assert _grant(client, gig, client_id, _assets).status_code == 409


def test_a_report_counts_as_the_step_after_which_it_is_offered(client, db_session, fake_stripe):
    from tests.test_review_gate import _report

    client_id, gig, _assets = _booking(client, db_session, rated=False)
    assert _report(client, gig, client_id).status_code == 200
    assert _offer(client, gig, client_id).json()["offered"] is True


def test_only_the_bookings_client_is_offered(client, db_session, fake_stripe):
    _client_id, gig, assets = _booking(client, db_session)
    assert _offer(client, gig, gig.pro_user_id).status_code == 403
    assert _grant(client, gig, gig.pro_user_id, assets).status_code == 403


def test_in_production_with_the_draft_wording_nothing_is_offered(client, db_session, fake_stripe, monkeypatch):
    # Checked on the service: in production the routes also stop taking the
    # test's X-User-Id sign-in.
    client_id, gig, assets = _booking(client, db_session)
    assert mc.offer_for(db_session, gig).offered is True
    monkeypatch.setattr(get_settings(), "app_env", "production")
    offer = mc.offer_for(db_session, gig)
    assert (offer.offered, offer.reason) == (False, "not_available")
    with pytest.raises(mc.MarketingConsentRefused) as refused:
        mc.grant(db_session, gig, client_user_id=uuid.UUID(client_id), asset_ids=[uuid.UUID(assets[0])], term_months=12, people_confirmed=True)
    assert refused.value.status_code == 409
    with pytest.raises(mc.MarketingConsentRefused):
        mc.renew(db_session, uuid.UUID(client_id), [uuid.uuid4()], 12)


# --- the grant -----------------------------------------------------------------------------


def test_a_grant_records_each_photo_with_the_wording_shown_and_the_term(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)

    resp = _grant(client, gig, client_id, assets[:2], term=6)

    assert resp.status_code == 200, resp.text
    rows = db_session.execute(select(MarketingConsent).where(MarketingConsent.gig_id == gig.id)).scalars().all()
    assert {str(r.media_asset_id) for r in rows} == set(assets[:2])
    for row in rows:
        assert (row.status, row.scope, row.term_months, row.people_confirmed) == ("active", "rawwers_organic", 6, True)
        assert row.wording_version == "client-draft-1" and row.wording_text.startswith("DRAFT")
        assert row.photographer_credit == "Alex Lens"
        assert row.pro_user_id == gig.pro_user_id and str(row.client_user_id) == client_id
        assert abs((row.ends_at - row.granted_at) - timedelta(days=182)) < timedelta(days=3)


def test_the_people_shown_must_be_confirmed(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    assert _grant(client, gig, client_id, assets, confirmed=False).status_code == 422


@pytest.mark.parametrize("term", [1, 3, 36])
def test_only_the_offered_terms(client, db_session, fake_stripe, term):
    client_id, gig, assets = _booking(client, db_session)
    assert _grant(client, gig, client_id, assets, term=term).status_code == 422


def test_only_the_clients_own_delivered_photos(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    other_client, other_gig, other_assets = _booking(client, db_session)
    assert _grant(client, gig, client_id, other_assets).status_code == 422
    assert _grant(client, gig, client_id, []).status_code == 422


def test_a_photo_already_given_is_not_offered_or_given_twice(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:3])

    offered = {p["media_asset_id"] for p in _offer(client, gig, client_id).json()["photos"]}
    assert offered == set(assets[3:])
    assert _grant(client, gig, client_id, assets[:1]).status_code == 422


# --- the credit ----------------------------------------------------------------------------


@pytest.mark.parametrize(("term", "credit"), [(6, 50), (12, 100), (24, 150)])
def test_the_credit_follows_the_term(client, db_session, fake_stripe, term, credit):
    client_id, gig, assets = _booking(client, db_session)
    resp = _grant(client, gig, client_id, assets, term=term)
    assert resp.json()["credit"] == credit
    assert _credits(db_session, client_id) == [credit]


def test_one_credit_per_booking(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:2])
    second = _grant(client, gig, client_id, assets[2:4], term=24)
    assert second.status_code == 200 and second.json()["credit"] == 0
    assert _credits(db_session, client_id) == [100]


def test_at_most_three_credited_grants_a_month(client, db_session, fake_stripe):
    first_client, gig, assets = _booking(client, db_session)
    answers = [_grant(client, gig, first_client, assets[:1]).json()["credit"]]
    for _ in range(3):
        # Another booking of the same client.
        _c, other_gig, other_assets = _booking(client, db_session)
        other_gig.client_user_id = uuid.UUID(first_client)
        db_session.commit()
        answers.append(_grant(client, other_gig, first_client, other_assets[:1]).json()["credit"])
    assert answers == [100, 100, 100, 0]
    assert _credits(db_session, first_client) == [100, 100, 100]


def test_points_the_older_consent_paid_on_the_booking_reduce_the_credit(client, db_session, fake_stripe):
    from app.services.rewards import add_reward_entry

    client_id, gig, assets = _booking(client, db_session)
    add_reward_entry(db_session, user_id=uuid.UUID(client_id), amount=80, entry_type=RewardEntryType.earn,
                     reference_type="consent_reward", reference_id=f"{gig.id}:pro_marketing_only")
    db_session.commit()

    assert _grant(client, gig, client_id, assets).json()["credit"] == 20


def test_no_credit_when_the_setting_is_zero(client, db_session, fake_stripe, monkeypatch):
    monkeypatch.setattr(get_settings(), "marketing_consent_credit_points", 0)
    client_id, gig, assets = _booking(client, db_session)
    assert _grant(client, gig, client_id, assets).json()["credit"] == 0
    assert _credits(db_session, client_id) == []


# --- the photographer's switches -------------------------------------------------------------


def test_allow_marketing_locks_once_a_client_has_granted(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:1])
    with pytest.raises(mc.MarketingConsentLocked):
        mc.set_booking_setting(db_session, gig, actor_user_id=gig.pro_user_id, allow_marketing=False)


def test_turning_the_account_opt_in_off_stops_offers_and_withdraws_nothing(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:1])
    mc.record_pro_agreement(db_session, gig.pro_user_id, opted_in=False)
    db_session.commit()

    assert _offer(client, gig, client_id).json()["reason"] == "photographer_not_opted_in"
    db_session.expire_all()
    assert {r.status for r in db_session.execute(select(MarketingConsent).where(MarketingConsent.gig_id == gig.id)).scalars()} == {"active"}


# --- my permissions, withdraw, renew -------------------------------------------------------


def test_my_permissions_list_each_photo_with_its_end_date(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:2])

    items = client.get("/v1/me/marketing-consents", headers={"X-User-Id": client_id}).json()["items"]

    assert {i["media_asset_id"] for i in items} == set(assets[:2])
    for item in items:
        assert item["status"] == "active" and item["ends_at"] and item["photographer_credit"] == "Alex Lens"
        assert item["gig_id"] == str(gig.id)


def test_withdrawing_one_photo_changes_its_status_and_keeps_the_credit(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:2])
    one = client.get("/v1/me/marketing-consents", headers={"X-User-Id": client_id}).json()["items"][0]

    resp = client.post("/v1/me/marketing-consents/withdraw", headers={"X-User-Id": client_id}, json={"consent_ids": [one["id"]]})

    assert resp.status_code == 200 and resp.json()["withdrawn"] == 1
    db_session.expire_all()
    row = db_session.get(MarketingConsent, uuid.UUID(one["id"]))
    assert row.status == "withdrawn" and row.withdrawn_at is not None
    assert _credits(db_session, client_id) == [100], "no clawback"


def test_withdrawing_all(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:3])
    resp = client.post("/v1/me/marketing-consents/withdraw", headers={"X-User-Id": client_id}, json={"all": True})
    assert resp.json()["withdrawn"] == 3
    db_session.expire_all()
    assert {r.status for r in db_session.execute(select(MarketingConsent)).scalars()} == {"withdrawn"}


def test_a_client_cannot_withdraw_someone_elses(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:1])
    (mine,) = client.get("/v1/me/marketing-consents", headers={"X-User-Id": client_id}).json()["items"]
    other_client, _g, _a = _booking(client, db_session)
    resp = client.post("/v1/me/marketing-consents/withdraw", headers={"X-User-Id": other_client}, json={"consent_ids": [mine["id"]]})
    assert resp.json()["withdrawn"] == 0
    db_session.expire_all()
    assert db_session.get(MarketingConsent, uuid.UUID(mine["id"])).status == "active"


def test_a_renewal_is_a_new_record_under_the_current_wording_with_no_credit(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:1])
    (old,) = client.get("/v1/me/marketing-consents", headers={"X-User-Id": client_id}).json()["items"]
    for row in db_session.query(MarketingWording).filter_by(audience=MarketingWordingAudience.client):
        row.is_active = False
    db_session.add(MarketingWording(version="client-draft-2", audience=MarketingWordingAudience.client, text="DRAFT two", is_draft=True, is_active=True))
    db_session.commit()

    resp = client.post("/v1/me/marketing-consents/renew", headers={"X-User-Id": client_id}, json={"consent_ids": [old["id"]], "term_months": 24})

    assert resp.status_code == 200, resp.text
    db_session.expire_all()
    new = db_session.execute(select(MarketingConsent).where(MarketingConsent.renews_consent_id == uuid.UUID(old["id"]))).scalar_one()
    assert (new.wording_version, new.wording_text, new.term_months) == ("client-draft-2", "DRAFT two", 24)
    assert new.ends_at > datetime.fromisoformat(old["ends_at"])
    assert _credits(db_session, client_id) == [100], "no second credit"


def test_withdraw_all_for_an_account_is_ready_for_account_deletion(client, db_session, fake_stripe):
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:2])
    assert mc.withdraw_all_for_account(db_session, uuid.UUID(client_id)) == 2
    db_session.commit()
    db_session.expire_all()
    assert {r.status for r in db_session.execute(select(MarketingConsent)).scalars()} == {"withdrawn"}


def test_a_renewal_earns_nothing_even_when_the_grant_earned_nothing(client, db_session, fake_stripe, monkeypatch):
    monkeypatch.setattr(get_settings(), "marketing_consent_credit_points", 0)
    client_id, gig, assets = _booking(client, db_session)
    _grant(client, gig, client_id, assets[:1])
    (old,) = client.get("/v1/me/marketing-consents", headers={"X-User-Id": client_id}).json()["items"]
    monkeypatch.setattr(get_settings(), "marketing_consent_credit_points", 100)

    client.post("/v1/me/marketing-consents/renew", headers={"X-User-Id": client_id}, json={"consent_ids": [old["id"]], "term_months": 12})

    assert _credits(db_session, client_id) == []
