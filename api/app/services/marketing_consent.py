"""Marketing-use consent (closed beta): who may be asked, what they agree to, and the rules.

See app/models/marketing_consent.py for the records. For RAWWERS's own
marketing these per-photo records are the only authority; the older
four-level gig consent no longer grants RAWWERS anything (media_rights).
"""
from __future__ import annotations

import calendar
import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.admin import ProProfile
from app.models.gallery import ProofGallery
from app.models.gig import Gig
from app.models.marketing_consent import (
    TERM_CREDIT_PERCENT,
    BookingMarketingSetting,
    MarketingConsent,
    MarketingConsentStatus,
    MarketingScope,
    MarketingWording,
    MarketingWordingAudience,
    ProMarketingAgreement,
    WORDING_LANGUAGES,
)
from app.models.reward import RewardEntryType, RewardLedgerEntry
from app.services.download_gate import has_rated_or_reported, rating_allowed
from app.services.rewards import add_reward_entry

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
        if db.execute(select(MarketingWording.version).where(MarketingWording.audience == audience, MarketingWording.language == "en")).first():
            continue
        db.add(MarketingWording(version=version, audience=audience, language="en", text=text, is_draft=True, is_active=True))
    db.flush()


def _active(db: Session, audience: MarketingWordingAudience, language: str) -> MarketingWording | None:
    return db.execute(
        select(MarketingWording).where(
            MarketingWording.audience == audience, MarketingWording.language == language, MarketingWording.is_active.is_(True)
        )
    ).scalars().first()


def active_wording(db: Session, audience: MarketingWordingAudience, language: str = "en") -> MarketingWording | None:
    """The wording shown in `language`, or the English one when that language
    has none published - or, in production, only a draft."""
    ensure_default_wordings(db)
    wording = _active(db, audience, language) if language != "en" else None
    if wording is not None and not (_production() and wording.is_draft):
        return wording
    return _active(db, audience, "en")


def user_language(db: Session, user_id) -> str:
    """"pt" for someone whose app language is Portuguese, "en" otherwise."""
    from app.services.i18n import get_user_locale_preference

    locale = (get_user_locale_preference(db, user_id=user_id) or "").lower()
    return "pt" if locale.startswith("pt") else "en"


class WordingRefused(Exception):
    def __init__(self, message: str, *, status_code: int = 422):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


def create_wording(db: Session, *, audience: MarketingWordingAudience, language: str, text: str, actor_user_id) -> MarketingWording:
    """A new version, a draft until published. Versions are never edited: a
    change is a new version."""
    if language not in WORDING_LANGUAGES:
        raise WordingRefused("Language must be EN or PT")
    ensure_default_wordings(db)
    text = (text or "").strip()
    if not text:
        raise WordingRefused("Paste the wording")
    count = db.execute(
        select(func.count()).select_from(MarketingWording).where(MarketingWording.audience == audience, MarketingWording.language == language)
    ).scalar_one()
    row = MarketingWording(
        version=f"{audience.value}-{language}-{count + 1}-{uuid.uuid4().hex[:6]}", audience=audience, language=language,
        text=text, is_draft=True, is_active=False, created_by_user_id=actor_user_id,
    )
    db.add(row)
    db.flush()
    return row


def publish_wording(db: Session, version: str, *, reviewed_by: str, note: str, actor_user_id) -> MarketingWording:
    """Make a reviewed version the one shown for its audience and language.
    It needs who reviewed it and a note; once published it is never edited."""
    row = db.get(MarketingWording, version)
    if row is None:
        raise WordingRefused("Version not found", status_code=404)
    reviewed_by, note = (reviewed_by or "").strip(), (note or "").strip()
    if not reviewed_by:
        raise WordingRefused("Say who reviewed it")
    if not note:
        raise WordingRefused("Add a note")
    if row.version in {version for version, _text in DRAFT_WORDING.values()}:
        raise WordingRefused("The placeholder cannot be published; paste the reviewed text as a new version", status_code=409)
    if row.published_at is not None or row.reviewed_by is not None:
        raise WordingRefused("This version was already published; create a new version for any change", status_code=409)
    for other in db.execute(
        select(MarketingWording).where(
            MarketingWording.audience == row.audience, MarketingWording.language == row.language, MarketingWording.is_active.is_(True)
        )
    ).scalars():
        other.is_active = False
    row.is_draft = False
    row.is_active = True
    row.reviewed_by = reviewed_by
    row.review_note = note
    row.published_at = datetime.now(timezone.utc)
    row.published_by_user_id = actor_user_id
    db.flush()
    return row


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


# --- the photographer's side -----------------------------------------------------------------


class MarketingConsentLocked(Exception):
    """A booking's switches cannot change once a client has granted consent."""


def record_pro_agreement(db: Session, pro_user_id, *, opted_in: bool) -> ProMarketingAgreement:
    """A photographer's account-level choice, recorded with the wording they
    were shown and when. Turning it off stops new offers; it withdraws
    nothing already granted."""
    wording = active_wording(db, MarketingWordingAudience.photographer, user_language(db, pro_user_id))
    row = ProMarketingAgreement(pro_user_id=pro_user_id, opted_in=opted_in, wording_version=wording.version)
    db.add(row)
    db.flush()
    return row


def pro_opted_in(db: Session, pro_user_id) -> bool:
    latest = db.execute(
        select(ProMarketingAgreement)
        .where(ProMarketingAgreement.pro_user_id == pro_user_id)
        .order_by(ProMarketingAgreement.recorded_at.desc(), ProMarketingAgreement.id.desc())
    ).scalars().first()
    return bool(latest and latest.opted_in)


def has_grant(db: Session, gig: Gig) -> bool:
    return db.execute(select(MarketingConsent.id).where(MarketingConsent.gig_id == gig.id)).first() is not None


@dataclass(frozen=True)
class BookingSwitches:
    allow_marketing: bool
    includes_children: bool
    #: A client has granted consent on the booking: the switches are fixed.
    locked: bool


def booking_switches(db: Session, gig: Gig) -> BookingSwitches:
    """The photographer's switches for one booking. "Allow marketing use"
    defaults to on for a photographer who has opted in, off otherwise."""
    row = db.get(BookingMarketingSetting, gig.id)
    allow = row.allow_marketing if row else pro_opted_in(db, gig.pro_user_id)
    return BookingSwitches(allow_marketing=allow, includes_children=bool(row and row.includes_children), locked=has_grant(db, gig))


def set_booking_setting(
    db: Session, gig: Gig, *, actor_user_id, allow_marketing: bool | None = None, includes_children: bool | None = None
) -> BookingSwitches:
    if has_grant(db, gig):
        raise MarketingConsentLocked()
    current = booking_switches(db, gig)
    row = db.get(BookingMarketingSetting, gig.id)
    if row is None:
        row = BookingMarketingSetting(gig_id=gig.id, allow_marketing=current.allow_marketing, includes_children=current.includes_children, updated_by_user_id=actor_user_id)
        db.add(row)
    if allow_marketing is not None:
        row.allow_marketing = allow_marketing
    if includes_children is not None:
        row.includes_children = includes_children
    row.updated_by_user_id = actor_user_id
    row.updated_at = datetime.now(timezone.utc)
    db.flush()
    return booking_switches(db, gig)


# --- the client's side -----------------------------------------------------------------------


@dataclass(frozen=True)
class Offer:
    offered: bool
    #: Why not, when not: not_available, rate_first, photographer_not_opted_in,
    #: photographer_turned_it_off, includes_children, nothing_left.
    reason: str | None
    wording: MarketingWording | None = None
    photo_ids: tuple[uuid.UUID, ...] = ()
    photographer_credit: str = ""


def photographer_credit(db: Session, pro_user_id) -> str:
    """How a photographer is credited when their work is used: their display
    name (owner, 2026-11-02; there is no handle yet)."""
    profile = db.get(ProProfile, pro_user_id)
    return (profile.display_name or "").strip() if profile and profile.display_name else "RAWWERS photographer"


def _consented_photo_ids(db: Session, gig: Gig) -> set[uuid.UUID]:
    return set(
        db.execute(
            select(MarketingConsent.media_asset_id).where(
                MarketingConsent.gig_id == gig.id, MarketingConsent.status == MarketingConsentStatus.active.value
            )
        ).scalars()
    )


def _client_photo_ids(db: Session, gig: Gig) -> list[uuid.UUID]:
    from app.services.media_rights import unlocked_final_asset_ids

    gallery = db.execute(select(ProofGallery).where(ProofGallery.gig_id == gig.id)).scalar_one_or_none()
    return list(unlocked_final_asset_ids(db, gallery=gallery)) if gallery else []


def offer_for(db: Session, gig: Gig) -> Offer:
    """Whether this booking's client may be asked now, and which photos."""
    if not feature_enabled(db):
        return Offer(False, "not_available")
    if not rating_allowed(db, gig):
        return Offer(False, "not_available")
    if not has_rated_or_reported(db, gig):
        return Offer(False, "rate_first")
    if not pro_opted_in(db, gig.pro_user_id):
        return Offer(False, "photographer_not_opted_in")
    switches = booking_switches(db, gig)
    if switches.includes_children:
        return Offer(False, "includes_children")
    if not switches.allow_marketing:
        return Offer(False, "photographer_turned_it_off")
    given = _consented_photo_ids(db, gig)
    photos = tuple(pid for pid in _client_photo_ids(db, gig) if pid not in given)
    if not photos:
        return Offer(False, "nothing_left")
    return Offer(
        True,
        None,
        wording=active_wording(db, MarketingWordingAudience.client, user_language(db, gig.client_user_id)),
        photo_ids=photos,
        photographer_credit=photographer_credit(db, gig.pro_user_id),
    )


def credit_for_term(term_months: int) -> int:
    return get_settings().marketing_consent_credit_points * TERM_CREDIT_PERCENT[term_months] // 100


def _ends_at(start: datetime, term_months: int) -> datetime:
    """`term_months` calendar months after `start`, on the same day (the last
    of the month when that day does not exist)."""
    month = start.month - 1 + term_months
    year, month = start.year + month // 12, month % 12 + 1
    day = min(start.day, calendar.monthrange(year, month)[1])
    return start.replace(year=year, month=month, day=day)


class MarketingConsentRefused(Exception):
    def __init__(self, message: str, *, status_code: int = 422):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


def _credit(db: Session, gig: Gig, client_user_id, term_months: int) -> RewardLedgerEntry | None:
    """The RAW credit for a grant: once per booking, at most the monthly cap
    a month, less any points the older consent already paid on the booking
    - one reward per booking. Through the reward ledger, whose own rules
    (frozen rewards, the balance floor) apply."""
    settings = get_settings()
    already = db.execute(
        select(RewardLedgerEntry.id).where(
            RewardLedgerEntry.user_id == client_user_id,
            RewardLedgerEntry.reference_type == CREDIT_REFERENCE,
            RewardLedgerEntry.reference_id == str(gig.id),
        )
    ).first()
    if already:
        return None
    month_start = datetime.now(timezone.utc).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    this_month = db.execute(
        select(func.count()).select_from(RewardLedgerEntry).where(
            RewardLedgerEntry.user_id == client_user_id,
            RewardLedgerEntry.reference_type == CREDIT_REFERENCE,
            RewardLedgerEntry.entry_type == RewardEntryType.earn,
            RewardLedgerEntry.created_at >= month_start,
        )
    ).scalar_one()
    if this_month >= settings.marketing_consent_monthly_cap:
        return None
    amount = credit_for_term(term_months) - _older_consent_points(db, gig, client_user_id)
    if amount <= 0:
        return None
    return add_reward_entry(
        db,
        user_id=client_user_id,
        amount=amount,
        entry_type=RewardEntryType.earn,
        reference_type=CREDIT_REFERENCE,
        reference_id=str(gig.id),
        metadata={"term_months": term_months},
        min_balance_floor=settings.reward_balance_floor,
    )


def _older_consent_points(db: Session, gig: Gig, client_user_id) -> int:
    """What the older four-level consent has paid on this booking, net of
    its clawbacks: the new credit is reduced by it, one reward per booking."""
    from app.services.client_rewards_pricing import net_consent_points

    return max(0, net_consent_points(db, gig_id=gig.id, client_user_id=client_user_id))


#: The reward ledger's reference for a marketing-consent credit; the booking
#: is the reference id, which is what makes it once per booking.
CREDIT_REFERENCE = "marketing_consent"


def grant(
    db: Session, gig: Gig, *, client_user_id, asset_ids: list[uuid.UUID], term_months: int, people_confirmed: bool
) -> tuple[list[MarketingConsent], int]:
    """Record the client's consent for each photo, and credit them. Returns
    the records and the credit given (0 when none)."""
    if term_months not in TERM_CREDIT_PERCENT:
        raise MarketingConsentRefused("Choose 6, 12 or 24 months")
    if not people_confirmed:
        raise MarketingConsentRefused("Confirm that everyone shown is an adult who agrees, or that you are their parent or guardian")
    offer = offer_for(db, gig)
    if not offer.offered:
        raise MarketingConsentRefused("These photos cannot be offered for RAWWERS marketing", status_code=409)
    chosen = list(dict.fromkeys(asset_ids))
    if not chosen or any(pid not in offer.photo_ids for pid in chosen):
        raise MarketingConsentRefused("Choose from your own photos of this booking that are not already shared")
    now = datetime.now(timezone.utc)
    rows = [
        MarketingConsent(
            client_user_id=client_user_id,
            gig_id=gig.id,
            pro_user_id=gig.pro_user_id,
            media_asset_id=pid,
            wording_version=offer.wording.version,
            wording_text=offer.wording.text,
            scope=MarketingScope.rawwers_organic.value,
            term_months=term_months,
            granted_at=now,
            ends_at=_ends_at(now, term_months),
            status=MarketingConsentStatus.active.value,
            photographer_credit=offer.photographer_credit,
            people_confirmed=True,
        )
        for pid in chosen
    ]
    db.add_all(rows)
    db.flush()
    entry = _credit(db, gig, client_user_id, term_months)
    return rows, int(entry.amount) if entry else 0


def my_consents(db: Session, client_user_id) -> list[MarketingConsent]:
    return list(
        db.execute(
            select(MarketingConsent)
            .where(MarketingConsent.client_user_id == client_user_id)
            .order_by(MarketingConsent.granted_at.desc())
        ).scalars()
    )


def withdraw(db: Session, client_user_id, consent_ids: list[uuid.UUID] | None) -> int:
    """Withdraw the client's own active consents (all of them when no ids are
    given). The status changes; nothing is deleted, and no credit is taken
    back (owner, 2026-11-02)."""
    stmt = select(MarketingConsent).where(
        MarketingConsent.client_user_id == client_user_id, MarketingConsent.status == MarketingConsentStatus.active.value
    )
    if consent_ids is not None:
        stmt = stmt.where(MarketingConsent.id.in_(consent_ids))
    now = datetime.now(timezone.utc)
    rows = db.execute(stmt).scalars().all()
    for row in rows:
        row.status = MarketingConsentStatus.withdrawn.value
        row.withdrawn_at = now
    db.flush()
    return len(rows)


def withdraw_all_for_account(db: Session, user_id) -> int:
    """For account deletion, when it exists (a launch requirement; not hooked
    into anything yet): every consent the account has given, withdrawn."""
    return withdraw(db, user_id, None)


def renew(db: Session, client_user_id, consent_ids: list[uuid.UUID], term_months: int) -> list[MarketingConsent]:
    """A renewal is a new record under the current wording, running on from
    the end of the one it renews. No credit (owner, 2026-11-02)."""
    if term_months not in TERM_CREDIT_PERCENT:
        raise MarketingConsentRefused("Choose 6, 12 or 24 months")
    if not feature_enabled(db):
        raise MarketingConsentRefused("Not available", status_code=409)
    wording = active_wording(db, MarketingWordingAudience.client, user_language(db, client_user_id))
    rows = db.execute(
        select(MarketingConsent).where(
            MarketingConsent.id.in_(consent_ids),
            MarketingConsent.client_user_id == client_user_id,
            MarketingConsent.status == MarketingConsentStatus.active.value,
        )
    ).scalars().all()
    if len(rows) != len(set(consent_ids)):
        raise MarketingConsentRefused("Only your own active permissions can be renewed")
    now = datetime.now(timezone.utc)
    renewed = []
    for old in rows:
        renewed.append(
            MarketingConsent(
                client_user_id=old.client_user_id,
                gig_id=old.gig_id,
                pro_user_id=old.pro_user_id,
                media_asset_id=old.media_asset_id,
                wording_version=wording.version,
                wording_text=wording.text,
                scope=old.scope,
                term_months=term_months,
                granted_at=now,
                ends_at=_ends_at(max(now, old.ends_at), term_months),
                status=MarketingConsentStatus.active.value,
                photographer_credit=old.photographer_credit,
                people_confirmed=old.people_confirmed,
                renews_consent_id=old.id,
            )
        )
    db.add_all(renewed)
    db.flush()
    return renewed


# --- the daily job ---------------------------------------------------------------------------

#: How long before its end a permission prompts the client to renew.
RENEWAL_PROMPT_DAYS = 30


def expire_due(db: Session, *, now: datetime | None = None, limit: int = 1000) -> int:
    """Active consents past their end date become expired. The status
    changes; nothing is deleted."""
    now = now or datetime.now(timezone.utc)
    rows = db.execute(
        select(MarketingConsent)
        .where(MarketingConsent.status == MarketingConsentStatus.active.value, MarketingConsent.ends_at <= now)
        .order_by(MarketingConsent.ends_at.asc())
        .limit(limit)
    ).scalars().all()
    for row in rows:
        row.status = MarketingConsentStatus.expired.value
        row.expired_at = now
    db.flush()
    return len(rows)


def send_renewal_prompts(db: Session, *, now: datetime | None = None) -> int:
    """An in-app prompt to the client, once, for active permissions ending
    within RENEWAL_PROMPT_DAYS and not already renewed: one notification per
    client per run, naming how many photos. Email comes later (Brevo).
    Returns how many clients were prompted."""
    from app.services.notifications import enqueue_notification

    now = now or datetime.now(timezone.utc)
    renewed = select(MarketingConsent.renews_consent_id).where(MarketingConsent.renews_consent_id.is_not(None))
    rows = db.execute(
        select(MarketingConsent).where(
            MarketingConsent.status == MarketingConsentStatus.active.value,
            MarketingConsent.renewal_prompted_at.is_(None),
            MarketingConsent.ends_at > now,
            MarketingConsent.ends_at <= now + timedelta(days=RENEWAL_PROMPT_DAYS),
            MarketingConsent.id.not_in(renewed),
        )
    ).scalars().all()
    by_client: dict[uuid.UUID, list[MarketingConsent]] = {}
    for row in rows:
        by_client.setdefault(row.client_user_id, []).append(row)
    for client_user_id, consents in by_client.items():
        first_end = min(c.ends_at for c in consents)
        count = len(consents)
        enqueue_notification(
            db,
            user_id=client_user_id,
            notification_type="marketing_consent.renewal",
            payload={
                "title": "Your photos' marketing permission ends soon",
                "body": f"RAWWERS may feature {count} {'photo' if count == 1 else 'photos'} of yours until "
                f"{first_end.strftime('%d %b %Y')}. Renew to keep them featured, or let them end.",
                "action": {"label": "Review", "url": "/account/marketing-permissions"},
            },
            reference_type="marketing_consent",
            reference_id=f"{client_user_id}:{now.date().isoformat()}",
        )
        for consent in consents:
            consent.renewal_prompted_at = now
    db.flush()
    return len(by_client)


# --- the admin content library -----------------------------------------------------------------

#: How long after a used consent ends the content must be down, on channels
#: RAWWERS owns.
TAKE_DOWN_DAYS_OWNED = 30


def renewal_of(db: Session, consent: MarketingConsent) -> MarketingConsent | None:
    """The active record that renews this one, if any (following renewals of
    renewals to the latest)."""
    current = consent
    latest = None
    for _ in range(50):  # a chain of renewals; bounded
        nxt = db.execute(
            select(MarketingConsent)
            .where(MarketingConsent.renews_consent_id == current.id, MarketingConsent.status == MarketingConsentStatus.active.value)
            .order_by(MarketingConsent.ends_at.desc())
        ).scalars().first()
        if nxt is None:
            return latest
        latest = current = nxt
    return latest


def effective_end(db: Session, consent: MarketingConsent) -> datetime:
    """When this permission really ends: its own end, or its renewal's."""
    renewed = renewal_of(db, consent)
    return renewed.ends_at if renewed is not None else consent.ends_at
