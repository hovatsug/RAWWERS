"""Which currencies the platform takes, and their per-currency settings
(docs/MULTI_CURRENCY.md 10.1). One row, id 1; with no row the code's
defaults apply (app/services/currencies.py): GBP only."""
from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import DateTime, SmallInteger
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class CurrencySettings(Base):
    __tablename__ = "currency_settings"

    id: Mapped[int] = mapped_column(SmallInteger, primary_key=True, default=1)
    #: ISO codes a package, a Connect account or a display setting may use.
    enabled_currencies: Mapped[list] = mapped_column(JSONB, nullable=False)
    #: The smallest withdrawal per currency, as decimal strings ({"GBP": "45.00"}).
    payout_minimums: Mapped[dict] = mapped_column(JSONB, nullable=False)
    updated_by_admin_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )
