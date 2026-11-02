"""Marketing-use consent for the closed beta: RAWWERS's own use of a client's photos.

Owner's decision (2026-11-01/02). Built beside the older four-level
`GigUsageConsent` (media_rights), which stays for a photographer's own
marketing and content packs. For RAWWERS's own marketing the per-photo
records here are the only authority, and the admin content library reads
only them.

- `MarketingWording`: the text people agree to, versioned. A placeholder
  ("draft") until the lawyer's wording exists; in production the feature is
  off while the active wording is a draft (services/marketing_consent.py).
- `ProMarketingAgreement`: a photographer's account-level opt-in (default
  off), one row per change: what they chose, under which wording, when.
- `BookingMarketingSetting`: per booking, the photographer's "Allow
  marketing use" (their veto) and "Includes children" (no consent offered).
- `MarketingConsent`: one row per photo a client agreed to, never deleted
  (a trigger refuses it): who, which photo, booking and photographer, the
  wording version and the exact text shown, the term, the scope, and its
  status - a withdrawal or expiry changes the status, nothing else.
- `MarketingContentUse` (+ its consents): "used in <content> on <date>".
- `MarketingOriginalAccess`: every time an admin opened an original.
"""
from __future__ import annotations

import enum
import uuid
from datetime import date, datetime, timezone

from sqlalchemy import (
    DDL,
    Boolean,
    CheckConstraint,
    Date,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    Text,
    event,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


def _now() -> datetime:
    return datetime.now(timezone.utc)


class MarketingScope(str, enum.Enum):
    """What a consent allows. Closed beta: organic posts on RAWWERS's own
    channels, nothing else - no advertising, no third parties, and never
    training any AI model (a test holds the list to that)."""

    rawwers_organic = "rawwers_organic"


class MarketingConsentStatus(str, enum.Enum):
    active = "active"
    withdrawn = "withdrawn"
    expired = "expired"


class MarketingWordingAudience(str, enum.Enum):
    client = "client"
    photographer = "photographer"


#: The terms a client may choose, in months, and the share of the credit
#: setting each earns (owner, 2026-11-02): a longer term earns more.
TERM_CREDIT_PERCENT = {6: 50, 12: 100, 24: 150}
DEFAULT_TERM_MONTHS = 12


class MarketingWording(Base):
    __tablename__ = "marketing_wording"

    version: Mapped[str] = mapped_column(Text, primary_key=True)
    audience: Mapped[MarketingWordingAudience] = mapped_column(
        Enum(MarketingWordingAudience, name="marketing_wording_audience", native_enum=False, length=32), nullable=False
    )
    text: Mapped[str] = mapped_column(Text, nullable=False)
    #: A placeholder nobody has legally reviewed.
    is_draft: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    #: The one shown now, per audience.
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)


class ProMarketingAgreement(Base):
    __tablename__ = "pro_marketing_agreement"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    opted_in: Mapped[bool] = mapped_column(Boolean, nullable=False)
    wording_version: Mapped[str] = mapped_column(Text, ForeignKey("marketing_wording.version"), nullable=False)
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now, index=True)


class BookingMarketingSetting(Base):
    __tablename__ = "booking_marketing_setting"

    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), primary_key=True)
    allow_marketing: Mapped[bool] = mapped_column(Boolean, nullable=False)
    includes_children: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    updated_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)


class MarketingConsent(Base):
    __tablename__ = "marketing_consent"
    __table_args__ = (
        # The scope list is the enum above and nothing else, in the database too.
        CheckConstraint("scope IN ('rawwers_organic')", name="ck_marketing_consent_scope"),
        CheckConstraint("term_months IN (6, 12, 24)", name="ck_marketing_consent_term"),
        CheckConstraint("status IN ('active', 'withdrawn', 'expired')", name="ck_marketing_consent_status"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    client_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    media_asset_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=False, index=True)
    wording_version: Mapped[str] = mapped_column(Text, ForeignKey("marketing_wording.version"), nullable=False)
    #: The exact text the client was shown, whatever the wording row says later.
    wording_text: Mapped[str] = mapped_column(Text, nullable=False)
    scope: Mapped[str] = mapped_column(Text, nullable=False, default=MarketingScope.rawwers_organic.value)
    term_months: Mapped[int] = mapped_column(Integer, nullable=False)
    granted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)
    ends_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    status: Mapped[str] = mapped_column(Text, nullable=False, default=MarketingConsentStatus.active.value, index=True)
    withdrawn_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    expired_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    #: How the photographer is credited when the photo is used: their
    #: display name at the time of the grant.
    photographer_credit: Mapped[str] = mapped_column(Text, nullable=False)
    #: The client confirmed everyone shown is an adult who agrees, or that
    #: they are the parent or guardian.
    people_confirmed: Mapped[bool] = mapped_column(Boolean, nullable=False)
    #: A renewal is a new record; this points at the one it renews.
    renews_consent_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("marketing_consent.id"), nullable=True)
    #: When the in-app "ends in 30 days" prompt was sent.
    renewal_prompted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class MarketingContentUse(Base):
    __tablename__ = "marketing_content_use"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_name: Mapped[str] = mapped_column(Text, nullable=False)
    used_on: Mapped[date] = mapped_column(Date, nullable=False)
    #: On a channel RAWWERS owns: taken down within 30 days of a consent ending.
    owned_channel: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    recorded_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)


class MarketingContentUseConsent(Base):
    __tablename__ = "marketing_content_use_consent"

    use_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("marketing_content_use.id"), primary_key=True)
    consent_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("marketing_consent.id"), primary_key=True)


class MarketingOriginalAccess(Base):
    __tablename__ = "marketing_original_access"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    consent_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("marketing_consent.id"), nullable=False, index=True)
    admin_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    accessed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)


#: Consent records are never deleted: a withdrawal or an expiry changes the
#: status. The database refuses a DELETE, whatever code asks for it.
NO_DELETE_FUNCTION = DDL(
    """
    CREATE OR REPLACE FUNCTION marketing_consent_no_delete() RETURNS trigger AS $$
    BEGIN
        RAISE EXCEPTION 'marketing_consent rows are never deleted; withdraw or expire them';
    END;
    $$ LANGUAGE plpgsql;
    """
)
NO_DELETE_TRIGGER = DDL(
    "CREATE TRIGGER marketing_consent_no_delete BEFORE DELETE ON marketing_consent "
    "FOR EACH ROW EXECUTE FUNCTION marketing_consent_no_delete();"
)
event.listen(MarketingConsent.__table__, "after_create", NO_DELETE_FUNCTION.execute_if(dialect="postgresql"))
event.listen(MarketingConsent.__table__, "after_create", NO_DELETE_TRIGGER.execute_if(dialect="postgresql"))
