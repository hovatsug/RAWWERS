from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.admin import ProProfile
from app.models.booking import ProAvailabilityRule, ProBlackoutDate, ProPackage
from app.models.chat import ChatMessage, ChatSenderType, ChatThread
from app.models.chat import PlatformPolicy
from app.services.llm import LLMGeneration, decimal_to_str, get_llm_provider

settings = get_settings()


BOOKING_DRAFT_TOOL = {
    "type": "function",
    "function": {
        "name": "booking_request_draft",
        "description": "Create a booking request draft only when client intent to book is clear.",
        "parameters": {
            "type": "object",
            "properties": {
                "package_id": {"type": "string"},
                "requested_start": {"type": "string"},
                "requested_end": {"type": "string"},
                "location_text": {"type": "string"},
                "notes": {"type": "string"},
            },
            "required": ["package_id", "requested_start", "requested_end"],
        },
    },
}


def snapshot_pro_context(db: Session, pro_user_id: uuid.UUID) -> dict:
    profile = db.get(ProProfile, pro_user_id)
    packages = db.execute(
        select(ProPackage)
        .where(ProPackage.pro_user_id == pro_user_id, ProPackage.is_active.is_(True))
        .order_by(ProPackage.price.asc())
    ).scalars().all()
    rules = db.execute(
        select(ProAvailabilityRule)
        .where(ProAvailabilityRule.pro_user_id == pro_user_id)
        .order_by(ProAvailabilityRule.day_of_week.asc(), ProAvailabilityRule.start_time.asc())
    ).scalars().all()
    blackouts = db.execute(
        select(ProBlackoutDate)
        .where(ProBlackoutDate.pro_user_id == pro_user_id)
        .order_by(ProBlackoutDate.start_at.asc())
        .limit(20)
    ).scalars().all()
    policies = db.execute(select(PlatformPolicy).order_by(PlatformPolicy.key.asc())).scalars().all()

    return {
        "pro_profile": {
            "user_id": str(profile.user_id) if profile else str(pro_user_id),
            "display_name": profile.display_name if profile else None,
            "headline": profile.headline if profile else None,
            "bio": profile.bio if profile else None,
            "city": profile.city if profile else None,
            "country": profile.country if profile else None,
            "styles": profile.styles if profile else [],
            "languages": profile.languages if profile else [],
            "is_accepting_bookings": bool(profile.is_accepting_bookings) if profile else False,
        },
        "packages": [
            {
                "id": str(p.id),
                "title": p.title,
                "description": p.description,
                "duration_minutes": p.duration_minutes,
                "price": decimal_to_str(p.price),
                "currency": p.currency,
                "included_photos": p.included_photos,
                "extra_photo_price": decimal_to_str(p.extra_photo_price),
                "proofs_sla_days": p.proofs_sla_days,
                "finals_sla_days": p.finals_sla_days,
                "addons": p.addons or [],
            }
            for p in packages
        ],
        "availability_summary": {
            "rules": [
                {
                    "day_of_week": r.day_of_week,
                    "start_time": r.start_time.isoformat(),
                    "end_time": r.end_time.isoformat(),
                }
                for r in rules
            ],
            "blackouts": [
                {
                    "start_at": b.start_at.isoformat(),
                    "end_at": b.end_at.isoformat(),
                    "reason": b.reason,
                }
                for b in blackouts
            ],
        },
        "policies": {policy.key: policy.value for policy in policies},
        "booking_request_draft": None,
        "snapshot_at": datetime.utcnow().isoformat(),
    }


def estimate_tokens_for_text(text: str) -> int:
    return max(1, len(text) // 4)


def estimate_prompt_tokens(messages: list[dict[str, str]]) -> int:
    return sum(estimate_tokens_for_text(item.get("content", "")) + 4 for item in messages)


def build_system_prompt(context_snapshot: dict) -> str:
    return (
        "You are RAWWERS Concierge.\n"
        "Use only facts from context_snapshot (profile, packages, availability_summary, policies).\n"
        "Never invent prices, dates, package details, or guarantees.\n"
        "If asked outside those facts, say you will confirm with the photographer.\n"
        "Collect: shoot type/purpose, preferred date/time window, location, people count/special requirements, and optional budget.\n"
        "Recommend up to 3 packages with exact price and included photos from context_snapshot packages.\n"
        "When user agrees to book, include CTA link stub '/bookings/new'.\n"
        "If intent to book is explicit, call tool booking_request_draft.\n"
        f"context_snapshot={context_snapshot}"
    )


def build_llm_messages(thread: ChatThread, history: list[ChatMessage]) -> list[dict[str, str]]:
    messages: list[dict[str, str]] = [{"role": "system", "content": build_system_prompt(thread.context_snapshot)}]
    for msg in history:
        role = "assistant"
        if msg.sender_type == ChatSenderType.client:
            role = "user"
        elif msg.sender_type in {ChatSenderType.pro, ChatSenderType.system}:
            role = "assistant"
        elif msg.sender_type == ChatSenderType.ai:
            role = "assistant"
        messages.append({"role": role, "content": msg.content})
    return messages


def generate_ai_reply(thread: ChatThread, history: list[ChatMessage]) -> LLMGeneration:
    provider = get_llm_provider()
    messages = build_llm_messages(thread, history)
    return provider.generate(
        messages=messages,
        tools=[BOOKING_DRAFT_TOOL],
        params={"context_snapshot": thread.context_snapshot},
    )
