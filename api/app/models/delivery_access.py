"""How a desktop tool - the Lightroom Classic plugin - delivers for one photographer.

The photographer asks the pro app for a pairing code and types it into the
plugin; the plugin exchanges it for a delivery token. The plugin never sees
the photographer's password, and the token can do nothing but deliver: list
the gigs waiting for photos, upload to them, and read their progress.

Only hashes are stored, the way refresh tokens are: a database copy is of no
use for calling the API.
"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import DateTime, ForeignKey, Index, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class DeliveryPairingCode(Base):
    """One code, ten minutes, one use. Issuing a new one retires the last."""

    __tablename__ = "delivery_pairing_code"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user_account.user_id"), nullable=False, index=True)
    code_hash: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    #: Exchanged for a token, or retired by a newer code. Either way, spent.
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class DeliveryToken(Base):
    """A device that can deliver for one photographer until revoked, or until
    90 days pass without it being used."""

    __tablename__ = "delivery_token"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user_account.user_id"), nullable=False, index=True)
    token_hash: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    #: The token's first characters, shown beside the device so the
    #: photographer can tell two Macs apart. Not enough to use.
    token_prefix: Mapped[str] = mapped_column(Text, nullable=False)
    #: What the plugin calls the machine, e.g. "Ana's MacBook Pro - Lightroom Classic".
    device_name: Mapped[str] = mapped_column(Text, nullable=False)
    plugin_version: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    last_used_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    #: "photographer", "password_reset", "sign_out_everywhere", "expired" - why it stopped.
    revoked_reason: Mapped[str | None] = mapped_column(Text, nullable=True)


Index("ix_delivery_token_pro_active", DeliveryToken.pro_user_id, DeliveryToken.revoked_at)
