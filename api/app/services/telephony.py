from __future__ import annotations

import uuid
from abc import ABC, abstractmethod
from dataclasses import dataclass

from app.core.config import get_settings
from app.core.errors import APIError

settings = get_settings()


@dataclass
class TelephonyCreateResult:
    provider_call_id: str
    status: str = "dialing"
    outcome: str | None = None


class TelephonyProvider(ABC):
    supports_transcription: bool = False

    @abstractmethod
    def create_outbound_call(self, to_e164: str, from_e164: str, webhook_url: str, metadata: dict) -> TelephonyCreateResult:
        raise NotImplementedError

    @abstractmethod
    def end_call(self, provider_call_id: str) -> None:
        raise NotImplementedError

    def verify_webhook_signature(self, payload: bytes, signature: str | None) -> bool:
        return True


class MockTelephonyProvider(TelephonyProvider):
    supports_transcription = True

    def create_outbound_call(self, to_e164: str, from_e164: str, webhook_url: str, metadata: dict) -> TelephonyCreateResult:
        session_id = metadata.get("call_session_id") or str(uuid.uuid4())
        return TelephonyCreateResult(provider_call_id=f"mock-call-{session_id}", status="completed", outcome="connected")

    def end_call(self, provider_call_id: str) -> None:
        return None


class GenericTelephonyProvider(TelephonyProvider):
    supports_transcription = False

    def create_outbound_call(self, to_e164: str, from_e164: str, webhook_url: str, metadata: dict) -> TelephonyCreateResult:
        if not from_e164:
            raise APIError(code="configuration_error", message="TELEPHONY_FROM_E164 is required", status_code=503)
        # Scaffold-only provider.
        call_id = f"provider-call-{uuid.uuid4()}"
        return TelephonyCreateResult(provider_call_id=call_id, status="dialing")

    def end_call(self, provider_call_id: str) -> None:
        return None

    def verify_webhook_signature(self, payload: bytes, signature: str | None) -> bool:
        if not settings.telephony_webhook_secret:
            return False
        return bool(signature) and signature == settings.telephony_webhook_secret


def get_telephony_provider() -> TelephonyProvider:
    provider_name = (settings.telephony_provider or "mock").strip().lower()
    if provider_name == "mock":
        return MockTelephonyProvider()
    return GenericTelephonyProvider()
