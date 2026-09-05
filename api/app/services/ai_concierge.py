from __future__ import annotations

import hashlib
import json
import re
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.chat import AIInteractionLog, ChatMessage, ChatSenderType, ChatThread, ChatThreadStatus, LeadProfile, ProAIProfile, ProAITone
from app.services.chat_concierge import BOOKING_DRAFT_TOOL, build_llm_messages, estimate_prompt_tokens
from app.services.llm import LLMGeneration, get_llm_provider

_EMAIL_RE = re.compile(r"([a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)")
_PHONE_RE = re.compile(r"(\+?\d[\d\-\s]{7,}\d)")
_CARD_RE = re.compile(r"\b(?:\d[ -]*?){13,19}\b")


def get_or_create_pro_ai_profile(db: Session, *, pro_user_id: uuid.UUID) -> ProAIProfile:
    row = db.get(ProAIProfile, pro_user_id)
    if row:
        return row
    row = ProAIProfile(
        pro_user_id=pro_user_id,
        is_enabled=True,
        tone=ProAITone.premium,
        faq=[],
        do_not_say=[],
        preferred_packages=[],
    )
    db.add(row)
    db.flush()
    return row


def get_or_create_lead_profile(db: Session, *, thread_id: uuid.UUID) -> LeadProfile:
    row = db.get(LeadProfile, thread_id)
    if row:
        return row
    row = LeadProfile(thread_id=thread_id, location={}, style_tags=[])
    db.add(row)
    db.flush()
    return row


def generate_ai_reply_for_thread(
    db: Session,
    *,
    thread: ChatThread,
    draft_only: bool = False,
) -> tuple[ChatMessage | None, AIInteractionLog]:
    messages = db.execute(
        select(ChatMessage).where(ChatMessage.thread_id == thread.id).order_by(ChatMessage.created_at.asc())
    ).scalars().all()
    lead = get_or_create_lead_profile(db, thread_id=thread.id)
    ai_profile = get_or_create_pro_ai_profile(db, pro_user_id=thread.pro_user_id)

    prompt_messages = build_llm_messages(thread, messages)
    prompt_hash = hashlib.sha256(json.dumps(prompt_messages, sort_keys=True).encode("utf-8")).hexdigest()
    request_id = str(uuid.uuid4())
    started = datetime.now(timezone.utc)

    generation = _generate_with_fallback(prompt_messages)
    structured = _structured_from_generation(generation, thread=thread, lead=lead)
    safety_flags = _safety_flags(generation.content)

    _update_lead_profile(lead, structured.get("extracted") or {})
    if structured.get("recommendations", {}).get("package_id"):
        snapshot = dict(thread.context_snapshot or {})
        snapshot["booking_request_draft"] = _draft_from_structured(structured, thread=thread)
        thread.context_snapshot = snapshot

    latency_ms = int((datetime.now(timezone.utc) - started).total_seconds() * 1000)
    log_row = AIInteractionLog(
        thread_id=thread.id,
        request_id=request_id,
        model="openai" if type(get_llm_provider()).__name__.lower().startswith("openai") else "mock",
        prompt_hash=prompt_hash,
        input_summary={
            "lead_profile": _lead_to_dict(lead),
            "last_messages": [redact_text(item.content) for item in messages[-8:]],
            "ai_profile_tone": ai_profile.tone.value,
        },
        output_summary=structured,
        safety_flags=safety_flags,
        tokens_in=estimate_prompt_tokens(prompt_messages),
        tokens_out=max(1, generation.usage_tokens),
        latency_ms=latency_ms,
    )
    db.add(log_row)
    db.flush()

    ai_message: ChatMessage | None = None
    if not draft_only:
        if thread.status not in {ChatThreadStatus.open}:
            return None, log_row
        ai_message = ChatMessage(
            thread_id=thread.id,
            sender_type=ChatSenderType.ai,
            sender_user_id=None,
            content=generation.content,
            content_redacted=redact_text(generation.content),
            meta={"structured": structured, "request_id": request_id},
        )
        db.add(ai_message)
        db.flush()
    return ai_message, log_row


def redact_text(content: str) -> str:
    value = _EMAIL_RE.sub("[redacted_email]", content or "")
    value = _PHONE_RE.sub("[redacted_phone]", value)
    value = _CARD_RE.sub("[redacted_card]", value)
    return value


def _generate_with_fallback(messages: list[dict[str, str]]) -> LLMGeneration:
    provider = get_llm_provider()
    try:
        return provider.generate(
            messages=messages,
            tools=[BOOKING_DRAFT_TOOL],
            params={"response_schema": "chat_intent"},
        )
    except Exception:
        return LLMGeneration(
            content="I am the AI assistant for this photographer. Share your date, location, style, and budget so I can recommend a package.",
            usage_tokens=64,
            tool_calls=[],
        )


def _structured_from_generation(generation: LLMGeneration, *, thread: ChatThread, lead: LeadProfile) -> dict:
    payload = {
        "intent": "collect_info",
        "extracted": {},
        "recommendations": {},
        "actions": [],
    }
    if generation.tool_calls:
        call = generation.tool_calls[0]
        payload["intent"] = "create_booking"
        payload["recommendations"] = {"package_id": call.arguments.get("package_id"), "reasons": ["client_intent_detected"]}
        payload["actions"] = [{"type": "create_booking_request", "payload": call.arguments}]
        payload["extracted"] = {
            "notes": call.arguments.get("notes"),
            "location": {"text": call.arguments.get("location_text")},
        }
        return payload

    text = generation.content.lower()
    if "book" in text or "reserve" in text:
        payload["intent"] = "recommend"
    if "handoff" in text:
        payload["intent"] = "handoff"
    payload["extracted"] = {
        "notes": redact_text(generation.content)[:500],
        "location": lead.location or {},
    }
    package_ids = thread_package_ids(thread)
    if package_ids:
        payload["recommendations"] = {"package_id": package_ids[0], "reasons": ["default_top_package"]}
    return payload


def _update_lead_profile(lead: LeadProfile, extracted: dict) -> None:
    if extracted.get("niche_slug"):
        lead.niche_slug = str(extracted["niche_slug"])
    if isinstance(extracted.get("location"), dict):
        lead.location = extracted["location"]
    if extracted.get("budget_min") is not None:
        lead.budget_min = Decimal(str(extracted["budget_min"]))
    if extracted.get("budget_max") is not None:
        lead.budget_max = Decimal(str(extracted["budget_max"]))
    if extracted.get("style_tags"):
        lead.style_tags = list(extracted["style_tags"])
    if extracted.get("notes"):
        lead.notes = str(extracted["notes"])[:2000]


def _lead_to_dict(lead: LeadProfile) -> dict:
    return {
        "niche_slug": lead.niche_slug,
        "desired_date": lead.desired_date.isoformat() if lead.desired_date else None,
        "date_flex_days": lead.date_flex_days,
        "location": lead.location or {},
        "budget_min": str(lead.budget_min) if lead.budget_min is not None else None,
        "budget_max": str(lead.budget_max) if lead.budget_max is not None else None,
        "style_tags": lead.style_tags or [],
        "notes": lead.notes,
    }


def _draft_from_structured(structured: dict, *, thread: ChatThread) -> dict:
    payload = ((structured.get("actions") or [{}])[0]).get("payload") or {}
    if not payload.get("package_id"):
        package_ids = thread_package_ids(thread)
        if package_ids:
            payload["package_id"] = package_ids[0]
    return payload


def thread_package_ids(thread: ChatThread) -> list[str]:
    items = (thread.context_snapshot or {}).get("packages") or []
    out: list[str] = []
    for item in items:
        try:
            out.append(str(uuid.UUID(item["id"])))
        except Exception:
            continue
    return out


def _safety_flags(content: str) -> dict:
    lower = (content or "").lower()
    flags = {
        "contains_payment_card_prompt": "card number" in lower,
        "contains_password_prompt": "password" in lower,
        "contains_government_id_prompt": "passport" in lower or "ssn" in lower,
    }
    return flags
