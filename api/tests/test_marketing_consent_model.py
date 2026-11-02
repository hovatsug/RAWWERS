"""Marketing-use consent (closed beta): the records and the rules that hold them.

Owner's decision (2026-11-01/02). The scope is organic use on RAWWERS's own
channels and nothing else: no list of scopes may ever include training an
AI model. Consent records are never deleted. The wording is versioned and a
draft placeholder until the lawyer's exists; in production the feature is
off while the active wording is a draft.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError, IntegrityError

from app.core.config import get_settings
from app.models.admin import UserAccount
from app.models.gig import Gig, GigStatus
from app.models.marketing_consent import (
    TERM_CREDIT_PERCENT,
    MarketingConsent,
    MarketingScope,
    MarketingWording,
    MarketingWordingAudience,
)
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.services.marketing_consent import active_wording, allowed_scopes, ensure_default_wordings, feature_enabled

AI_WORDS = ("ai", "train", "model", "ml", "machine", "dataset", "generative", "llm")


def test_the_only_scope_is_organic_use_on_rawwers_own_channels():
    assert allowed_scopes() == {"rawwers_organic"}
    assert {s.value for s in MarketingScope} == {"rawwers_organic"}


def test_no_scope_can_allow_training_an_ai_model():
    for scope in allowed_scopes() | {s.value for s in MarketingScope}:
        words = scope.lower().replace("-", "_").split("_")
        assert not any(w in AI_WORDS for w in words), scope
        assert "train" not in scope.lower()


def test_terms_and_their_credit_share():
    assert TERM_CREDIT_PERCENT == {6: 50, 12: 100, 24: 150}
    assert get_settings().marketing_consent_credit_points == 100
    assert get_settings().marketing_consent_monthly_cap == 3


def _consent(db_session, **overrides):
    ensure_default_wordings(db_session)
    client_id, pro_id = uuid.uuid4(), uuid.uuid4()
    db_session.add_all([UserAccount(user_id=client_id), UserAccount(user_id=pro_id)])
    db_session.flush()
    gig = Gig(client_user_id=client_id, pro_user_id=pro_id, status=GigStatus.completed, currency="EUR",
              amount_minimum=Decimal("96.00"), amount_platform_fee=Decimal("19.20"), amount_pro_gross=Decimal("76.80"), meta={})
    asset = MediaAsset(owner_user_id=pro_id, kind=MediaKind.photo, purpose=MediaPurpose.proof, provider=MediaProvider.r2,
                       status=MediaStatus.ready, visibility=MediaVisibility.client_only, meta={})
    db_session.add_all([gig, asset])
    db_session.flush()
    wording = active_wording(db_session, MarketingWordingAudience.client)
    now = datetime.now(timezone.utc)
    row = MarketingConsent(
        client_user_id=client_id, gig_id=gig.id, pro_user_id=pro_id, media_asset_id=asset.id,
        wording_version=wording.version, wording_text=wording.text, term_months=12, granted_at=now,
        ends_at=now + timedelta(days=365), photographer_credit="Alex Lens", people_confirmed=True,
    )
    for key, value in overrides.items():
        setattr(row, key, value)
    db_session.add(row)
    db_session.commit()
    return row


def test_a_consent_records_who_what_and_the_exact_text_shown(db_session):
    row = _consent(db_session)
    assert (row.scope, row.status, row.term_months) == ("rawwers_organic", "active", 12)
    assert row.wording_version == "client-draft-1"
    assert row.wording_text.startswith("DRAFT")


def test_the_database_refuses_any_other_scope(db_session):
    with pytest.raises(IntegrityError):
        _consent(db_session, scope="ai_training")
    db_session.rollback()


@pytest.mark.parametrize("term", [1, 3, 36])
def test_the_database_refuses_any_other_term(db_session, term):
    with pytest.raises(IntegrityError):
        _consent(db_session, term_months=term)
    db_session.rollback()


def test_a_consent_is_never_deleted(db_session):
    row = _consent(db_session)
    with pytest.raises(DBAPIError):
        db_session.execute(text("DELETE FROM marketing_consent WHERE id = :id"), {"id": row.id})
        db_session.flush()
    db_session.rollback()
    assert db_session.get(MarketingConsent, row.id) is not None


def test_the_wording_starts_as_an_active_draft_for_each_audience(db_session):
    for audience in MarketingWordingAudience:
        wording = active_wording(db_session, audience)
        assert wording is not None and wording.is_draft and wording.is_active
        assert "DRAFT" in wording.text


def test_outside_production_the_feature_works_with_the_draft(db_session):
    assert feature_enabled(db_session) is True


def test_in_production_the_feature_is_off_while_the_wording_is_a_draft(db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "app_env", "production")
    assert feature_enabled(db_session) is False

    # Reviewed wording for the client only: still off.
    for row in db_session.query(MarketingWording).filter_by(audience=MarketingWordingAudience.client):
        row.is_active = False
    db_session.add(MarketingWording(version="client-v1", audience=MarketingWordingAudience.client, text="Reviewed.", is_draft=False, is_active=True))
    db_session.commit()
    assert feature_enabled(db_session) is False

    for row in db_session.query(MarketingWording).filter_by(audience=MarketingWordingAudience.photographer):
        row.is_active = False
    db_session.add(MarketingWording(version="photographer-v1", audience=MarketingWordingAudience.photographer, text="Reviewed.", is_draft=False, is_active=True))
    db_session.commit()
    assert feature_enabled(db_session) is True


def test_the_migration_seeds_the_same_draft_wording_the_service_falls_back_to():
    import importlib.util
    from pathlib import Path

    from app.services.marketing_consent import DRAFT_WORDING

    path = Path(__file__).resolve().parents[1] / "alembic" / "versions" / "20261102_0077_marketing_consent.py"
    spec = importlib.util.spec_from_file_location("m0077", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    assert DRAFT_WORDING[MarketingWordingAudience.client][1] == module.CLIENT_DRAFT
    assert DRAFT_WORDING[MarketingWordingAudience.photographer][1] == module.PHOTOGRAPHER_DRAFT


def test_in_production_a_reviewed_photographer_wording_alone_is_not_enough(db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "app_env", "production")
    ensure_default_wordings(db_session)
    for row in db_session.query(MarketingWording).filter_by(audience=MarketingWordingAudience.photographer):
        row.is_active = False
    db_session.add(MarketingWording(version="photographer-v1", audience=MarketingWordingAudience.photographer, text="Reviewed.", is_draft=False, is_active=True))
    db_session.commit()
    assert feature_enabled(db_session) is False, "the client's wording is still a draft"
