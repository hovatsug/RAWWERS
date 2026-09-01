from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, get_locale, require_admin
from app.models.i18n import I18nBundle
from app.schemas.i18n import (
    I18nBundleCreateRequest,
    I18nBundleFetchResponse,
    I18nBundleView,
    I18nLocaleListResponse,
    I18nMissingKeysResponse,
)
from app.services.audit import add_admin_audit_log
from app.services.i18n import (
    DEFAULT_LOCALE,
    SUPPORTED_LOCALES,
    activate_bundle,
    audit_missing_keys,
    get_active_bundle,
    invalidate_bundle_cache,
    normalize_locale,
)

router = APIRouter(tags=["i18n"])


@router.get("/i18n/bundles", response_model=I18nBundleFetchResponse)
def get_i18n_bundle(
    locale: str | None = None,
    namespace: str = "core",
    request_locale: str = Depends(get_locale),
    db: Session = Depends(get_db_session),
) -> I18nBundleFetchResponse:
    selected_locale = normalize_locale(locale or request_locale or DEFAULT_LOCALE)
    payload = get_active_bundle(db, locale=selected_locale, namespace=namespace)
    if payload.version == 0 and selected_locale != DEFAULT_LOCALE:
        payload = get_active_bundle(db, locale=DEFAULT_LOCALE, namespace=namespace)
    db.commit()
    return I18nBundleFetchResponse(locale=payload.locale, namespace=payload.namespace, version=payload.version, content=payload.content)


@router.get("/admin/i18n/locales", response_model=I18nLocaleListResponse)
def admin_i18n_locales(
    _: CurrentUser = Depends(require_admin),
) -> I18nLocaleListResponse:
    return I18nLocaleListResponse(locales=list(SUPPORTED_LOCALES))


@router.get("/admin/i18n/bundles", response_model=list[I18nBundleView])
def admin_list_i18n_bundles(
    locale: str | None = None,
    namespace: str | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[I18nBundleView]:
    stmt = select(I18nBundle)
    if locale:
        stmt = stmt.where(I18nBundle.locale == normalize_locale(locale))
    if namespace:
        stmt = stmt.where(I18nBundle.namespace == namespace)
    rows = db.execute(stmt.order_by(I18nBundle.locale.asc(), I18nBundle.namespace.asc(), I18nBundle.version.desc())).scalars().all()
    return [I18nBundleView.model_validate(row, from_attributes=True) for row in rows]


@router.post("/admin/i18n/bundles", response_model=I18nBundleView)
def admin_create_i18n_bundle(
    body: I18nBundleCreateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> I18nBundleView:
    row = I18nBundle(
        locale=normalize_locale(body.locale),
        namespace=body.namespace,
        version=body.version,
        content=body.content or {},
        is_active=bool(body.is_active),
    )
    db.add(row)
    db.flush()
    if row.is_active:
        activate_bundle(db, bundle_id=row.id)

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="i18n_bundle",
        target_id=str(row.id),
        action="i18n_bundle_create",
        metadata={"locale": row.locale, "namespace": row.namespace, "version": row.version, "is_active": row.is_active},
    )
    invalidate_bundle_cache(locale=row.locale, namespace=row.namespace)
    db.commit()
    db.refresh(row)
    return I18nBundleView.model_validate(row, from_attributes=True)


@router.post("/admin/i18n/bundles/{bundle_id}/activate", response_model=I18nBundleView)
def admin_activate_i18n_bundle(
    bundle_id: uuid.UUID,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> I18nBundleView:
    row = activate_bundle(db, bundle_id=bundle_id)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="i18n_bundle",
        target_id=str(row.id),
        action="i18n_bundle_activate",
        metadata={"locale": row.locale, "namespace": row.namespace, "version": row.version},
    )
    db.commit()
    db.refresh(row)
    return I18nBundleView.model_validate(row, from_attributes=True)


@router.get("/admin/i18n/missing-keys", response_model=I18nMissingKeysResponse)
def admin_i18n_missing_keys(
    locale: str,
    namespace: str,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> I18nMissingKeysResponse:
    report = audit_missing_keys(db, locale=locale, namespace=namespace)
    db.commit()
    return I18nMissingKeysResponse(locale=normalize_locale(locale), namespace=namespace, missing=report["missing"], unused=report["unused"])
