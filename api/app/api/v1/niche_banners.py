"""Niche banners, from the admin side. Admins only; every change audited."""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin
from app.core.errors import APIError
from app.models.media_rights import MediaDerivativeKind
from app.models.niche import Niche, NicheBanner
from app.schemas.media import CurrentUser
from app.schemas.niche_banners import (
    AdminBannerLimits,
    AdminBannerRecord,
    AdminNicheBannerDetail,
    AdminNicheBannerList,
    AdminNicheBannerRow,
    BannerEdit,
    BannerSet,
    BannerUploadCompleted,
    BannerUploadStart,
    BannerUploadStarted,
    NicheEdit,
)
from app.services import niche_banners as service

router = APIRouter(tags=["niche-banners"])

#: Long enough to work through a page of previews.
_ADMIN_URL_TTL = 3600


def _niche(db: Session, slug: str) -> Niche:
    niche = db.execute(select(Niche).where(Niche.slug == slug)).scalar_one_or_none()
    if niche is None:
        raise APIError(code="not_found", message="Niche not found", status_code=404)
    return niche


def _records(db: Session, banners: list[NicheBanner]) -> list[AdminBannerRecord]:
    urls = service.image_urls(db, banners, _ADMIN_URL_TTL)
    return [
        AdminBannerRecord(
            banner_id=b.id, media_asset_id=b.media_asset_id, state=b.state, alt_text=b.alt_text,
            focal_x=float(b.focal_x), focal_y=float(b.focal_y), source=b.source, credit=b.credit, licence=b.licence,
            source_url=b.source_url, width=b.width, height=b.height, scrim_opacity=float(b.scrim_opacity),
            created_at=b.created_at, created_by_user_id=b.created_by_user_id, placeholder=b.placeholder,
            tile_url=urls.get(b.media_asset_id, {}).get(MediaDerivativeKind.banner_tile),
            hero_url=urls.get(b.media_asset_id, {}).get(MediaDerivativeKind.banner_hero),
        )
        for b in banners
    ]


@router.get("/admin/niche-banners", response_model=AdminNicheBannerList)
def list_niches(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> AdminNicheBannerList:
    niches = db.execute(select(Niche).order_by(Niche.is_active.desc(), Niche.name)).scalars().all()
    banners = db.execute(select(NicheBanner).where(NicheBanner.state.in_(("current", "previous")))).scalars().all()
    current = {b.niche_id: b for b in banners if b.state == "current"}
    previous = {b.niche_id for b in banners if b.state == "previous"}
    records = {r.banner_id: r for r in _records(db, list(current.values()))}
    items = [
        AdminNicheBannerRow(
            slug=n.slug, name=n.name, is_active=n.is_active, banner_style=n.banner_style, banner_tagline=n.banner_tagline,
            status=service.status_of(n, n.id in current), current=records.get(current[n.id].id) if n.id in current else None,
            has_previous=n.id in previous,
        )
        for n in niches
    ]
    return AdminNicheBannerList(items=items, limits=AdminBannerLimits(**service.limits()))


@router.get("/admin/niche-banners/{slug}", response_model=AdminNicheBannerDetail)
def niche_detail(slug: str, _: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> AdminNicheBannerDetail:
    niche = _niche(db, slug)
    banners = service.history(db, niche)
    records = _records(db, banners)
    current = next((r for r in records if r.state == "current"), None)
    previous = next((r for r in records if r.state == "previous"), None)
    return AdminNicheBannerDetail(
        slug=niche.slug, name=niche.name, is_active=niche.is_active, banner_style=niche.banner_style,
        banner_tagline=niche.banner_tagline, status=service.status_of(niche, current is not None), current=current,
        has_previous=previous is not None, previous=previous, history=records, limits=AdminBannerLimits(**service.limits()),
    )


@router.patch("/admin/niche-banners/{slug}", response_model=AdminNicheBannerDetail)
def edit_niche(slug: str, body: NicheEdit, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)):
    niche = _niche(db, slug)
    service.update_niche(db, niche, admin_user_id=actor.user_id, changes=body.model_dump(exclude_unset=True))
    return niche_detail(slug, actor, db)


@router.post("/admin/niche-banner-uploads", response_model=BannerUploadStarted)
def start_banner_upload(body: BannerUploadStart, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)):
    return service.start_upload(db, admin_user_id=actor.user_id, content_type=body.content_type, file_name=body.file_name)


@router.post("/admin/niche-banner-uploads/{media_asset_id}/complete", response_model=BannerUploadCompleted)
def complete_banner_upload(media_asset_id: uuid.UUID, _: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)):
    done = service.complete_upload(db, media_asset_id=media_asset_id)
    return BannerUploadCompleted(media_asset_id=done.media_asset_id, width=done.width, height=done.height,
                                 scrim_opacity=done.scrim_opacity, placeholder=done.placeholder, warnings=done.warnings)


@router.put("/admin/niche-banners/{slug}/image", response_model=AdminNicheBannerDetail)
def set_banner(slug: str, body: BannerSet, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)):
    niche = _niche(db, slug)
    service.set_banner(db, niche, admin_user_id=actor.user_id, **body.model_dump())
    return niche_detail(slug, actor, db)


@router.patch("/admin/niche-banners/{slug}/image", response_model=AdminNicheBannerDetail)
def edit_banner(slug: str, body: BannerEdit, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)):
    niche = _niche(db, slug)
    service.edit_banner(db, niche, admin_user_id=actor.user_id, changes=body.model_dump(exclude_unset=True))
    return niche_detail(slug, actor, db)


@router.delete("/admin/niche-banners/{slug}/image", response_model=AdminNicheBannerDetail)
def remove_banner(slug: str, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)):
    niche = _niche(db, slug)
    service.remove_banner(db, niche, admin_user_id=actor.user_id)
    return niche_detail(slug, actor, db)


@router.post("/admin/niche-banners/{slug}/image/revert", response_model=AdminNicheBannerDetail)
def revert_banner(slug: str, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)):
    niche = _niche(db, slug)
    service.revert_banner(db, niche, admin_user_id=actor.user_id)
    return niche_detail(slug, actor, db)
