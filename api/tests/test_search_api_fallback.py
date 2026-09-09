import uuid

from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.models.admin import KYCStatus, ProProfile, UserAccount
from app.models.discovery import ProPublicIndex


class FailingProvider:
    def search(self, *args, **kwargs):
        raise RuntimeError("search down")

    def upsert_documents(self, *args, **kwargs):
        return None

    def delete_documents(self, *args, **kwargs):
        return None

    def index_stats(self, index_name):
        return {"index_name": index_name, "documents": 0}


def test_search_fallback_when_provider_fails(client, db_session, monkeypatch):
    monkeypatch.setattr("app.api.v1.search.search_provider_enabled", lambda: True)
    monkeypatch.setattr("app.api.v1.search.get_search_provider", lambda: FailingProvider())

    pro_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro_id, display_name="Fallback Pro"))
    # The profile below points at this row, and a single flush does not
    # reliably insert the parent first - so make it explicit.
    db_session.flush()
    db_session.add(
        ProProfile(
            user_id=pro_id,
            display_name="Fallback Pro",
            city="Porto",
            country="PT",
            is_accepting_bookings=True,
            kyc_status=KYCStatus.approved,
        )
    )
    # GET /v1/search/pros joins ProOnboarding on approved_public, the same
    # publish gate discover enforces, so an indexed pro without this row is
    # invisible however well the index matches.
    db_session.add(
        ProOnboarding(
            pro_user_id=pro_id,
            status=ProOnboardingStatus.approved_public,
            current_city={"city": "Porto", "country": "PT"},
        )
    )
    db_session.add(
        ProPublicIndex(
            pro_user_id=pro_id,
            city="Porto",
            country="PT",
            is_accepting_bookings=True,
            kyc_status=KYCStatus.approved,
            completeness_score=70,
            styles=[],
            top_niches=[],
            portfolio_photo_count=0,
            portfolio_video_count=0,
            gigs_completed=0,
            gigs_cancelled=0,
            disputes_count=0,
            avg_rating=0,
            review_count=0,
            ranking_score=100,
        )
    )
    db_session.commit()

    resp = client.get("/v1/search/pros?q=Fallback")
    assert resp.status_code == 200
    payload = resp.json()
    assert payload["used_fallback"] is True
    assert payload["total"] >= 1
