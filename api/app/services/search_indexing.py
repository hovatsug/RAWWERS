from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.admin import KYCStatus, ProProfile, UserAccount
from app.models.commerce import CommercePartner, Product, ProductStockStatus
from app.models.discovery import ProPublicIndex
from app.models.learning import Course, InstructorProfile, InstructorStatus
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.outbox import OutboxEvent
from app.models.repair import RepairPartner, RepairPartnerScore
from app.models.studioverse import ContentPack, ContentPackStatus
from app.services.metrics import increment_index_event, increment_index_event_failure
from app.services.outbox import enqueue_outbox_event
from app.services.search_provider import get_index_name, get_search_provider, search_provider_enabled

logger = logging.getLogger(__name__)
settings = get_settings()

TIER_RANK = {
    SkillTier.rookie: 1,
    SkillTier.skilled: 2,
    SkillTier.pro: 3,
    SkillTier.elite: 4,
    SkillTier.master: 5,
}


INDEX_TOPIC_FIELD = {
    "index.pro.upsert": "pro_user_id",
    "index.pro.delete": "pro_user_id",
    "index.course.upsert": "course_id",
    "index.course.delete": "course_id",
    "index.product.upsert": "product_id",
    "index.product.delete": "product_id",
    "index.repair_partner.upsert": "partner_id",
    "index.repair_partner.delete": "partner_id",
    "index.content_pack.upsert": "content_pack_id",
    "index.content_pack.delete": "content_pack_id",
}


def enqueue_index_event(db: Session, *, topic: str, entity_id: uuid.UUID, idempotency_suffix: str | None = None) -> OutboxEvent | None:
    field = INDEX_TOPIC_FIELD.get(topic)
    if not field:
        raise ValueError(f"Unknown index topic: {topic}")
    idem = f"{topic}:{entity_id}:{idempotency_suffix or 'v1'}"
    return enqueue_outbox_event(
        db,
        topic=topic,
        payload={field: str(entity_id)},
        idempotency_key=idem,
        idempotency_scope="search_indexing",
    )


def enqueue_pro_index_upsert(db: Session, pro_user_id: uuid.UUID, *, idempotency_suffix: str | None = None) -> OutboxEvent | None:
    return enqueue_index_event(db, topic="index.pro.upsert", entity_id=pro_user_id, idempotency_suffix=idempotency_suffix)


def enqueue_course_index_upsert(db: Session, course_id: uuid.UUID, *, idempotency_suffix: str | None = None) -> OutboxEvent | None:
    return enqueue_index_event(db, topic="index.course.upsert", entity_id=course_id, idempotency_suffix=idempotency_suffix)


def enqueue_product_index_upsert(db: Session, product_id: uuid.UUID, *, idempotency_suffix: str | None = None) -> OutboxEvent | None:
    return enqueue_index_event(db, topic="index.product.upsert", entity_id=product_id, idempotency_suffix=idempotency_suffix)


def enqueue_repair_partner_index_upsert(db: Session, partner_id: uuid.UUID, *, idempotency_suffix: str | None = None) -> OutboxEvent | None:
    return enqueue_index_event(db, topic="index.repair_partner.upsert", entity_id=partner_id, idempotency_suffix=idempotency_suffix)


def enqueue_content_pack_index_upsert(db: Session, content_pack_id: uuid.UUID, *, idempotency_suffix: str | None = None) -> OutboxEvent | None:
    return enqueue_index_event(db, topic="index.content_pack.upsert", entity_id=content_pack_id, idempotency_suffix=idempotency_suffix)


def process_index_event(db: Session, topic: str, payload: dict) -> None:
    if topic not in INDEX_TOPIC_FIELD:
        return
    increment_index_event(topic)
    provider = get_search_provider()
    try:
        if topic == "index.pro.upsert":
            pro_id = uuid.UUID(payload["pro_user_id"])
            doc = build_pro_document(db, pro_id)
            if doc is None:
                provider.delete_documents(get_index_name("pros"), [str(pro_id)])
            else:
                provider.upsert_documents(get_index_name("pros"), [doc])
            return
        if topic == "index.pro.delete":
            provider.delete_documents(get_index_name("pros"), [payload["pro_user_id"]])
            return

        if topic == "index.course.upsert":
            course_id = uuid.UUID(payload["course_id"])
            doc = build_course_document(db, course_id)
            if doc is None:
                provider.delete_documents(get_index_name("courses"), [str(course_id)])
            else:
                provider.upsert_documents(get_index_name("courses"), [doc])
            return
        if topic == "index.course.delete":
            provider.delete_documents(get_index_name("courses"), [payload["course_id"]])
            return

        if topic == "index.product.upsert":
            product_id = uuid.UUID(payload["product_id"])
            doc = build_product_document(db, product_id)
            if doc is None:
                provider.delete_documents(get_index_name("products"), [str(product_id)])
            else:
                provider.upsert_documents(get_index_name("products"), [doc])
            return
        if topic == "index.product.delete":
            provider.delete_documents(get_index_name("products"), [payload["product_id"]])
            return

        if topic == "index.repair_partner.upsert":
            partner_id = uuid.UUID(payload["partner_id"])
            doc = build_repair_partner_document(db, partner_id)
            if doc is None:
                provider.delete_documents(get_index_name("repair_partners"), [str(partner_id)])
            else:
                provider.upsert_documents(get_index_name("repair_partners"), [doc])
            return
        if topic == "index.repair_partner.delete":
            provider.delete_documents(get_index_name("repair_partners"), [payload["partner_id"]])
            return
        if topic == "index.content_pack.upsert":
            content_pack_id = uuid.UUID(payload["content_pack_id"])
            doc = build_content_pack_document(db, content_pack_id)
            if doc is None:
                provider.delete_documents(get_index_name("content_packs"), [str(content_pack_id)])
            else:
                provider.upsert_documents(get_index_name("content_packs"), [doc])
            return
        if topic == "index.content_pack.delete":
            provider.delete_documents(get_index_name("content_packs"), [payload["content_pack_id"]])
            return
    except Exception:
        increment_index_event_failure(topic)
        raise


def build_pro_document(db: Session, pro_user_id: uuid.UUID) -> dict | None:
    idx = db.get(ProPublicIndex, pro_user_id)
    profile = db.get(ProProfile, pro_user_id)
    if not idx or not profile:
        return None
    if idx.kyc_status != KYCStatus.approved or not idx.is_accepting_bookings:
        return None

    skills = db.execute(
        select(ProNicheSkill, Niche)
        .join(Niche, Niche.id == ProNicheSkill.niche_id)
        .where(ProNicheSkill.pro_user_id == pro_user_id)
    ).all()

    niche_slugs: list[str] = []
    niche_tiers: dict[str, str] = {}
    niche_tier_rank: dict[str, int] = {}
    niche_capability: dict[str, int] = {}
    confidence: dict[str, float] = {}
    for skill, niche in skills:
        niche_slugs.append(niche.slug)
        niche_tiers[niche.slug] = skill.tier.value
        niche_tier_rank[niche.slug] = TIER_RANK.get(skill.tier, 0)
        niche_capability[niche.slug] = int(skill.capability_score)
        confidence[niche.slug] = float(skill.confidence)

    top_niche = None
    if idx.top_niches:
        top_niche = idx.top_niches[0].get("slug")

    return {
        "id": str(pro_user_id),
        "display_name": profile.display_name,
        "city": idx.city,
        "country": idx.country,
        "niche_slugs": niche_slugs,
        "top_niche": top_niche,
        "niche_tiers": niche_tiers,
        "niche_tier_rank": niche_tier_rank,
        "niche_capability": niche_capability,
        "confidence": confidence,
        "price_min": float(idx.min_package_price) if idx.min_package_price is not None else None,
        "price_max": float(idx.max_package_price) if idx.max_package_price is not None else None,
        "avg_rating": float(idx.avg_rating),
        "review_count": int(idx.review_count),
        "completed_gigs_total": int(idx.gigs_completed),
        "media_preview_urls": [],
        "last_active_at": idx.updated_at.isoformat() if idx.updated_at else None,
        "is_kyc_approved": True,
        "is_available": bool(idx.is_accepting_bookings),
    }


def build_course_document(db: Session, course_id: uuid.UUID) -> dict | None:
    course = db.get(Course, course_id)
    if not course or not course.is_published:
        return None
    instructor = db.get(InstructorProfile, course.instructor_user_id)
    if not instructor or instructor.status != InstructorStatus.approved:
        return None
    niche = db.get(Niche, course.niche_id)
    user = db.get(UserAccount, course.instructor_user_id)
    return {
        "id": str(course.id),
        "title": course.title,
        "summary": course.summary,
        "niche_slug": niche.slug if niche else None,
        "level": course.level.value,
        "is_mandatory": bool(course.is_mandatory),
        "price": float(course.price) if course.price is not None else None,
        "currency": course.currency,
        "instructor_name": user.display_name if user else None,
        "is_published": True,
        "updated_at": course.updated_at.isoformat() if course.updated_at else None,
    }


def build_product_document(db: Session, product_id: uuid.UUID) -> dict | None:
    row = db.get(Product, product_id)
    if not row:
        return None
    partner = db.get(CommercePartner, row.partner_id)
    if not partner or not partner.is_active or not row.is_available:
        return None
    return {
        "id": str(row.id),
        "title": row.title,
        "description": row.description,
        "category": row.category,
        "brand": row.brand,
        "price": float(row.partner_price),
        "is_available": bool(row.is_available),
        "stock_status": row.stock_status.value,
        "shipping_estimate_days": row.shipping_estimate_days,
        "partner_name": partner.name,
        "updated_at": row.updated_at.isoformat() if row.updated_at else None,
    }


def build_repair_partner_document(db: Session, partner_id: uuid.UUID) -> dict | None:
    row = db.get(RepairPartner, partner_id)
    if not row or not row.is_active:
        return None
    score = db.get(RepairPartnerScore, partner_id)
    score_summary = {
        "avg_quote_hours": float(score.avg_quote_hours) if score and score.avg_quote_hours is not None else None,
        "avg_turnaround_days": float(score.avg_turnaround_days) if score and score.avg_turnaround_days is not None else None,
        "loaner_fulfillment_rate": float(score.loaner_fulfillment_rate) if score and score.loaner_fulfillment_rate is not None else None,
    }


def build_content_pack_document(db: Session, content_pack_id: uuid.UUID) -> dict | None:
    row = db.get(ContentPack, content_pack_id)
    if not row or row.status != ContentPackStatus.approved:
        return None
    creator = db.get(ProProfile, row.creator_user_id)
    return {
        "id": str(row.id),
        "title": row.title,
        "description": row.description,
        "category": row.category.value,
        "status": row.status.value,
        "niche_slugs": row.niche_slugs or [],
        "tags": row.tags or [],
        "price_eur": float(row.price_eur) if row.price_eur is not None else None,
        "price_raww": int(row.price_raww) if row.price_raww is not None else None,
        "creator_name": creator.display_name if creator else None,
        "rating": None,
        "updated_at": row.updated_at.isoformat() if row.updated_at else None,
    }
    return {
        "id": str(row.id),
        "name": row.name,
        "country": row.country,
        "city": row.city,
        "categories_supported": row.categories_supported or [],
        "brands_supported": row.brands_supported or [],
        "loaner_supported": bool(row.loaner_supported),
        "loaner_categories": row.loaner_categories or [],
        "sla_quote_hours": row.sla_quote_hours,
        "sla_turnaround_days": row.sla_turnaround_days,
        "score_summary": score_summary,
        "is_active": bool(row.is_active),
        "updated_at": row.updated_at.isoformat() if row.updated_at else None,
    }


def provider_status() -> dict:
    provider = get_search_provider()
    out = {
        "provider": settings.search_provider,
        "enabled": bool(search_provider_enabled()),
        "search_index_prefix": settings.search_index_prefix,
        "indexes": [],
    }
    for key in ["pros", "courses", "products", "repair_partners", "content_packs"]:
        index_name = get_index_name(key)
        try:
            stats = provider.index_stats(index_name)
        except Exception as exc:
            stats = {"index_name": index_name, "error": str(exc)}
        out["indexes"].append(stats)
    return out


def latest_index_sync_at(db: Session) -> str | None:
    index_topics = list(INDEX_TOPIC_FIELD.keys())
    value = db.execute(
        select(func.max(OutboxEvent.updated_at)).where(OutboxEvent.topic.in_(index_topics))
    ).scalar_one_or_none()
    if not value:
        return None
    if value.tzinfo is None:
        value = value.replace(tzinfo=timezone.utc)
    return value.isoformat()
