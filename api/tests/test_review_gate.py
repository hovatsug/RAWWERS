"""Originals are released only after the client rates the photographer, or reports a problem.

Owner's decision (2026-11-01): originals - every download path, "Save all" in
the app included - wait until the client of the booking has given a star
rating, or has used "Report a problem". One tap on a star is enough; text and
video stay optional. Reporting a problem unlocks the download at once, opens
an issue an admin sees, and puts the photographer's earning for the booking
on hold through the existing hold (it waits for an admin, not for a date).
Previews, thumbnails and the selection flow are not gated.

One rating per booking, from that booking's client only, once the selection
is paid and the photos delivered - every review is tied to a real paid
booking.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.core.config import get_settings
from app.models.admin import MoneyAttentionItem, UserRole, UserRoleType
from app.models.gig import GigStatus
from app.models.payouts import EarningsEntryStatus, EarningsHold, EarningsHoldReason, EarningsLedgerEntry, EarningsSourceType
from app.services.media_urls import FINALS_DOWNLOAD_URL_TTL_SECONDS
from app.services.payouts import settle_due_earnings_entries
from tests.test_download_payment_gate import _downloads, _setup, _signed_final, _submit, fake_stripe  # noqa: F401


def _delivered(client, db_session, **kw):
    """A booking whose selection is submitted and fully paid: the photos are
    the client's, and only the review gate stands between them and the files."""
    client_id, gig, gallery, assets = _setup(db_session, photos=12, **kw)
    assert _submit(client, gallery, client_id).status_code == 200
    db_session.refresh(gig)
    assert gig.status == GigStatus.completed
    return client_id, gig, gallery, assets


def _rate(client, gig, user_id, rating=5, **body):
    return client.post(f"/v1/gigs/{gig.id}/review", json={"rating": rating, **body}, headers={"X-User-Id": str(user_id)})


def _report(client, gig, user_id, reason="photos_missing", note=None):
    body = {"reason": reason}
    if note is not None:
        body["note"] = note
    return client.post(f"/v1/gigs/{gig.id}/problem-report", json=body, headers={"X-User-Id": str(user_id)})


def _code(resp):
    return resp.json()["error"]["code"]


# --- the gate ------------------------------------------------------------------------------


def test_without_a_rating_the_originals_are_refused_with_a_code_the_app_knows(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _delivered(client, db_session)

    downloads = _downloads(client, gallery, client_id)
    single = _signed_final(client, gig, assets[0], client_id)

    for resp in (downloads, single):
        assert resp.status_code == 403, resp.text
        assert _code(resp) == "review_required"
        assert "Rate your photographer" in resp.json()["error"]["message"]


@pytest.mark.parametrize("kind", ["full_res", "web_res"])
def test_a_direct_request_for_any_full_size_copy_is_refused(client, db_session, fake_stripe, kind):
    client_id, gig, _gallery, assets = _delivered(client, db_session)
    resp = client.get(f"/v1/gigs/{gig.id}/media/{assets[0]}/signed-url", params={"kind": kind}, headers={"X-User-Id": client_id})
    assert resp.status_code in (403, 404)
    if resp.status_code == 403:
        assert _code(resp) == "review_required"


def test_one_star_unlocks_at_once(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _delivered(client, db_session)

    assert _rate(client, gig, client_id, rating=1).status_code == 200

    resp = _downloads(client, gallery, client_id)
    assert resp.status_code == 200, resp.text
    assert len(resp.json()["urls"]) == 12
    assert _signed_final(client, gig, assets[0], client_id).status_code == 200


def test_previews_thumbnails_and_the_selection_are_not_gated(client, db_session, fake_stripe):
    client_id, gig, gallery, assets = _delivered(client, db_session)

    for kind in ("thumbnail", "preview_watermarked"):
        resp = client.get(f"/v1/gigs/{gig.id}/media/{assets[0]}/signed-url", params={"kind": kind}, headers={"X-User-Id": client_id})
        assert resp.status_code != 403 or _code(resp) != "review_required", kind
    gallery_view = client.get(f"/v1/proof-galleries/{gallery.id}", headers={"X-User-Id": client_id})
    assert gallery_view.status_code == 200
    quote = client.get(f"/v1/proof-galleries/{gallery.id}/selection-quote", headers={"X-User-Id": client_id})
    assert quote.status_code == 200


def test_an_admin_is_not_gated(client, db_session, fake_stripe):
    _client_id, _gig, gallery, _assets = _delivered(client, db_session)
    admin_id = uuid.uuid4()
    from app.models.admin import UserAccount

    db_session.add(UserAccount(user_id=admin_id))
    db_session.flush()
    db_session.add(UserRole(user_id=admin_id, role=UserRoleType.admin))
    db_session.commit()
    assert _downloads(client, gallery, str(admin_id)).status_code == 200


def test_unpaid_comes_first_then_the_rating(client, db_session, fake_stripe):
    # Unpaid photos are refused for that reason, not for a missing rating
    # the client could not yet give.
    client_id, _gig, gallery, _assets = _setup(db_session, photos=30)
    assert _submit(client, gallery, client_id).status_code == 200
    assert _downloads(client, gallery, client_id).status_code == 402


def test_a_booking_that_cannot_be_rated_is_not_gated(client, db_session, fake_stripe):
    # No niche, no review (the review route refuses it): asking for one would
    # leave "Report a problem" as the only way to one's own photos.
    client_id, gig, gallery, _assets = _delivered(client, db_session)
    gig.niche_id = None
    db_session.commit()
    assert _downloads(client, gallery, client_id).status_code == 200


# --- who may rate, and when ----------------------------------------------------------------


def test_only_the_bookings_client_may_rate_or_report(client, db_session, fake_stripe):
    _client_id, gig, _gallery, _assets = _delivered(client, db_session)
    stranger = uuid.uuid4()
    from app.models.admin import UserAccount

    db_session.add(UserAccount(user_id=stranger))
    db_session.commit()

    assert _rate(client, gig, stranger).status_code == 403
    assert _report(client, gig, stranger).status_code == 403
    assert _rate(client, gig, gig.pro_user_id).status_code == 403


def test_a_rating_or_report_before_the_selection_is_paid_is_refused(client, db_session, fake_stripe):
    client_id, gig, gallery, _assets = _setup(db_session, photos=30)
    assert _submit(client, gallery, client_id).status_code == 200  # a difference is now owed

    assert _rate(client, gig, client_id).status_code == 409
    assert _report(client, gig, client_id).status_code == 409


def test_a_rating_or_report_before_the_photos_are_delivered_is_refused(client, db_session, fake_stripe):
    client_id, gig, _gallery, _assets = _setup(db_session, photos=12)  # nothing submitted yet

    assert _rate(client, gig, client_id).status_code == 409
    assert _report(client, gig, client_id).status_code == 409


def test_a_completed_booking_with_nothing_released_cannot_be_rated(client, db_session, fake_stripe):
    # The status alone is not enough: "completed" with no paid, delivered
    # photos is not a real booking to review.
    client_id, gig, _gallery, _assets = _setup(db_session, photos=12)
    gig.status = GigStatus.completed
    db_session.commit()

    assert _rate(client, gig, client_id).status_code == 409


@pytest.mark.parametrize("status", [GigStatus.refunded, GigStatus.cancelled_by_client, GigStatus.disputed])
def test_a_booking_delivered_and_then_refunded_cancelled_or_disputed_cannot_be_rated(client, db_session, fake_stripe, status):
    client_id, gig, _gallery, _assets = _delivered(client, db_session)
    gig.status = status
    db_session.commit()
    assert _rate(client, gig, client_id).status_code == 409


def test_one_rating_per_booking(client, db_session, fake_stripe):
    client_id, gig, _gallery, _assets = _delivered(client, db_session)
    assert _rate(client, gig, client_id).status_code == 200
    assert _rate(client, gig, client_id, rating=2).status_code == 409


# --- report a problem ----------------------------------------------------------------------


def test_reporting_a_problem_unlocks_and_holds_the_photographers_earning(client, db_session, fake_stripe):
    client_id, gig, gallery, _assets = _delivered(client, db_session)

    resp = _report(client, gig, client_id, reason="photos_missing", note="Only 12 of the 20 I expected")

    assert resp.status_code == 200, resp.text
    assert resp.json()["reason"] == "photos_missing"
    assert _downloads(client, gallery, client_id).status_code == 200
    db_session.expire_all()
    (hold,) = db_session.execute(select(EarningsHold).where(EarningsHold.source_id == gig.id)).scalars().all()
    assert (hold.reason, hold.source_type, hold.pro_user_id, hold.released_at) == (
        EarningsHoldReason.client_reported_problem, EarningsSourceType.gig_base.value, gig.pro_user_id, None,
    )
    (item,) = db_session.execute(
        select(MoneyAttentionItem).where(MoneyAttentionItem.gig_id == gig.id, MoneyAttentionItem.kind == "client_reported_problem")
    ).scalars().all()
    assert (item.kind, item.status, item.client_user_id) == ("client_reported_problem", "open", gig.client_user_id)
    assert "photos_missing" in item.note and "Only 12 of the 20" in item.note


def test_a_held_earning_waits_for_an_admin_not_for_a_date(client, db_session, fake_stripe):
    client_id, gig, _gallery, _assets = _delivered(client, db_session)
    # Completing the booking recorded the photographer's earning for it.
    entry = db_session.execute(
        select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_type == EarningsSourceType.gig_base, EarningsLedgerEntry.source_id == gig.id)
    ).scalar_one_or_none()
    if entry is None:
        entry = EarningsLedgerEntry(
            pro_user_id=gig.pro_user_id, source_type=EarningsSourceType.gig_base, source_id=gig.id,
            gross_eur=Decimal("40.00"), platform_fee_eur=Decimal("8.00"), net_eur=Decimal("32.00"),
            status=EarningsEntryStatus.pending, available_at=datetime.now(timezone.utc) + timedelta(days=7), meta={},
        )
        db_session.add(entry)
        db_session.commit()
    assert entry.status in (EarningsEntryStatus.pending, EarningsEntryStatus.available)

    assert _report(client, gig, client_id).status_code == 200
    db_session.expire_all()
    entry = db_session.get(EarningsLedgerEntry, entry.id)
    assert entry.status == EarningsEntryStatus.held

    entry.available_at = datetime.now(timezone.utc) - timedelta(days=1)
    db_session.commit()
    settle_due_earnings_entries(db_session)
    db_session.commit()
    db_session.expire_all()
    assert db_session.get(EarningsLedgerEntry, entry.id).status == EarningsEntryStatus.held


def test_one_report_per_booking(client, db_session, fake_stripe):
    client_id, gig, _gallery, _assets = _delivered(client, db_session)
    assert _report(client, gig, client_id).status_code == 200
    assert _report(client, gig, client_id, reason="other").status_code == 409
    db_session.expire_all()
    assert len(db_session.execute(select(EarningsHold).where(EarningsHold.source_id == gig.id)).scalars().all()) == 1


@pytest.mark.parametrize("body", [{"reason": "not-a-reason"}, {"reason": "other", "note": "x" * 1001}, {}])
def test_a_report_needs_a_reason_from_the_list(client, db_session, fake_stripe, body):
    client_id, gig, _gallery, _assets = _delivered(client, db_session)
    resp = client.post(f"/v1/gigs/{gig.id}/problem-report", json=body, headers={"X-User-Id": client_id})
    assert resp.status_code == 422


def test_a_report_after_a_rating_is_still_allowed(client, db_session, fake_stripe):
    client_id, gig, _gallery, _assets = _delivered(client, db_session)
    assert _rate(client, gig, client_id).status_code == 200
    assert _report(client, gig, client_id).status_code == 200


# --- links signed before the gate ----------------------------------------------------------


def test_links_signed_before_the_gate_are_short_lived(client, db_session, fake_stripe, monkeypatch):
    # A link already handed out keeps working until it expires; these are
    # the longest it can: 10 minutes for "Save all", 5 for a single file,
    # whatever the setting says.
    assert FINALS_DOWNLOAD_URL_TTL_SECONDS <= 600
    monkeypatch.setattr(get_settings(), "media_signed_url_ttl_seconds", 86_400)
    client_id, gig, _gallery, assets = _delivered(client, db_session)
    assert _rate(client, gig, client_id).status_code == 200

    resp = _signed_final(client, gig, assets[0], client_id)

    assert resp.status_code == 200
    assert resp.json()["expires_in_seconds"] <= 300
