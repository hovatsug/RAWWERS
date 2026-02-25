from __future__ import annotations

import json
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from typing import Any

import requests

from app.core.config import get_settings
from app.core.errors import APIError


@dataclass
class LLMToolCall:
    name: str
    arguments: dict[str, Any]


@dataclass
class LLMGeneration:
    content: str
    usage_tokens: int
    tool_calls: list[LLMToolCall]


class LLMProvider(ABC):
    @abstractmethod
    def generate(self, messages: list[dict[str, str]], tools: list[dict], params: dict[str, Any] | None = None) -> LLMGeneration:
        raise NotImplementedError


class MockProvider(LLMProvider):
    def generate(self, messages: list[dict[str, str]], tools: list[dict], params: dict[str, Any] | None = None) -> LLMGeneration:
        params = params or {}
        snapshot = params.get("context_snapshot") or {}
        user_message = ""
        for item in reversed(messages):
            if item.get("role") == "user":
                user_message = item.get("content", "")
                break

        packages = (snapshot.get("packages") or [])[:3]
        package_lines = []
        for package in packages:
            package_lines.append(
                f"- {package['title']}: {package['price']} {package['currency']} ({package['included_photos']} photos)"
            )

        normalized = user_message.lower()
        content_parts: list[str] = []
        tool_calls: list[LLMToolCall] = []

        if any(keyword in normalized for keyword in ["weather", "flight", "hotel", "visa", "camera model"]):
            content_parts.append("I can only confirm profile, packages, availability, and platform policies here. I will confirm this with the photographer.")
        elif packages:
            content_parts.append("Based on the photographer profile, here are suitable packages:")
            content_parts.extend(package_lines)
        else:
            content_parts.append("I do not have active package data in this thread yet. I will confirm options with the photographer.")

        content_parts.append(
            "To prepare a booking request, please share: shoot type/purpose, preferred date/time window, location, and number of people/special requirements."
        )

        should_draft = any(keyword in normalized for keyword in ["book", "booking", "reserve", "confirm", "let's do", "go ahead"])
        if should_draft and packages:
            start = datetime.now(timezone.utc).replace(microsecond=0)
            end = start + timedelta(minutes=int(packages[0].get("duration_minutes", 60)))
            draft = {
                "package_id": packages[0]["id"],
                "requested_start": start.isoformat(),
                "requested_end": end.isoformat(),
                "location_text": "TBD",
                "notes": user_message[:400],
            }
            tool_calls.append(LLMToolCall(name="booking_request_draft", arguments=draft))
            content_parts.append("If this looks good, submit your booking request here: /bookings/new")

        content = "\n".join(content_parts)
        token_estimate = max(1, len(content) // 4)
        return LLMGeneration(content=content, usage_tokens=token_estimate, tool_calls=tool_calls)


class OpenAIProvider(LLMProvider):
    def __init__(self) -> None:
        self.settings = get_settings()

    def generate(self, messages: list[dict[str, str]], tools: list[dict], params: dict[str, Any] | None = None) -> LLMGeneration:
        if not self.settings.openai_api_key:
            raise APIError(code="configuration_error", message="OPENAI_API_KEY is required", status_code=503)
        if not self.settings.openai_model:
            raise APIError(code="configuration_error", message="OPENAI_MODEL is required", status_code=503)

        payload = {
            "model": self.settings.openai_model,
            "messages": messages,
            "max_tokens": 400,
        }
        if tools:
            payload["tools"] = tools

        resp = requests.post(
            "https://api.openai.com/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {self.settings.openai_api_key}",
                "Content-Type": "application/json",
            },
            data=json.dumps(payload),
            timeout=20,
        )
        if resp.status_code >= 400:
            raise APIError(code="llm_error", message="OpenAI provider request failed", status_code=502, details={"status_code": resp.status_code})

        body = resp.json()
        choice = (body.get("choices") or [{}])[0]
        message = choice.get("message") or {}
        content = message.get("content") or ""
        usage_tokens = int((body.get("usage") or {}).get("total_tokens") or max(1, len(content) // 4))
        tool_calls: list[LLMToolCall] = []

        for call in message.get("tool_calls") or []:
            fn = call.get("function") or {}
            args_raw = fn.get("arguments") or "{}"
            try:
                args = json.loads(args_raw)
            except json.JSONDecodeError:
                args = {}
            if fn.get("name"):
                tool_calls.append(LLMToolCall(name=fn["name"], arguments=args))

        return LLMGeneration(content=content, usage_tokens=usage_tokens, tool_calls=tool_calls)


def get_llm_provider() -> LLMProvider:
    settings = get_settings()
    provider_name = (settings.llm_provider or "mock").strip().lower()
    if provider_name == "mock":
        return MockProvider()
    if provider_name == "openai":
        return OpenAIProvider()
    raise APIError(code="configuration_error", message=f"Unsupported LLM_PROVIDER '{settings.llm_provider}'", status_code=503)


def decimal_to_str(value: Decimal | None) -> str | None:
    if value is None:
        return None
    return format(value, "f")
