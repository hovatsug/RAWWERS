"""Exchange rates for display and reporting, never for money
(docs/MULTI_CURRENCY.md 4.1)."""
from __future__ import annotations

import uuid
from datetime import date, datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, CheckConstraint, Date, DateTime, Numeric, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class FxRate(Base):
    """One published reference rate: units of `quote` per one `base` (EUR),
    on the publication day `as_of`. Never edited: a new day is a new row."""

    __tablename__ = "fx_rate"
    __table_args__ = (
        UniqueConstraint("base", "quote", "as_of", name="uq_fx_rate_base_quote_as_of"),
        CheckConstraint("rate > 0", name="ck_fx_rate_positive"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    base: Mapped[str] = mapped_column(CHAR(3), nullable=False)
    quote: Mapped[str] = mapped_column(CHAR(3), nullable=False, index=True)
    rate: Mapped[Decimal] = mapped_column(Numeric(18, 8), nullable=False)
    #: The publication day (the ECB's date), not when we fetched it.
    as_of: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    #: "ecb" for the European Central Bank's euro reference rates.
    source: Mapped[str] = mapped_column(Text, nullable=False)
