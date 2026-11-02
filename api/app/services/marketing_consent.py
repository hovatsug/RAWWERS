"""Marketing-use consent (closed beta): who may be asked, what they agree to, and the rules.

See app/models/marketing_consent.py for the records. For RAWWERS's own
marketing these per-photo records are the only authority; the older
four-level gig consent no longer grants RAWWERS anything (media_rights).
"""
from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.marketing_consent import MarketingScope, MarketingWording, MarketingWordingAudience

#: The placeholder wordings the feature starts with. Not legally reviewed:
#: in production the feature stays off while either is the active one.
DRAFT_WORDING = {
    MarketingWordingAudience.client: (
        "client-draft-1",
        "DRAFT - not legally reviewed. You let RAWWERS show the photos you choose on RAWWERS's own channels "
        "(organic posts only, no advertising) for the term you pick, credited to your photographer. You can "
        "withdraw at any time in Settings > Marketing permissions; RAWWERS then takes them down within 30 days. "
        "Everyone shown is an adult who agrees, or you are their parent or guardian.",
    ),
    MarketingWordingAudience.photographer: (
        "photographer-draft-1",
        "DRAFT - not legally reviewed. RAWWERS may ask your clients whether it can feature photos from your "
        "bookings on its own channels. You keep ownership; RAWWERS gets a non-exclusive licence for its own "
        "marketing only, and always credits you by name. You can turn it off for any booking before the client "
        "is asked, and it is never offered for a booking that includes children.",
    ),
}


def allowed_scopes() -> frozenset[str]:
    """Every scope a consent may carry. Organic use on RAWWERS's own channels,
    nothing else - and never the training of any AI model."""
    return frozenset(scope.value for scope in MarketingScope)


def ensure_default_wordings(db: Session) -> None:
    """The draft placeholder for each audience, active, if none exists yet."""
    for audience, (version, text) in DRAFT_WORDING.items():
        if db.execute(select(MarketingWording.version).where(MarketingWording.audience == audience)).first():
            continue
        db.add(MarketingWording(version=version, audience=audience, text=text, is_draft=True, is_active=True))
    db.flush()


def active_wording(db: Session, audience: MarketingWordingAudience) -> MarketingWording | None:
    ensure_default_wordings(db)
    return db.execute(
        select(MarketingWording).where(MarketingWording.audience == audience, MarketingWording.is_active.is_(True))
    ).scalars().first()


def _production() -> bool:
    return (get_settings().app_env or "").strip().lower() in {"prod", "production"}


def feature_enabled(db: Session) -> bool:
    """Off in production while either active wording is still a draft; on
    elsewhere, so the beta flow can be built and tried with the draft."""
    if not _production():
        return True
    for audience in MarketingWordingAudience:
        wording = active_wording(db, audience)
        if wording is None or wording.is_draft:
            return False
    return True
