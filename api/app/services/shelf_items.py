"""The Shelf's items, for admins: create, edit, compatibility, and the
price helper.

The RAWW price is typed by the admin. The helper only advises: a suggested
price (street price, less the shelf discount, in euros at the settings'
GBP rate, over the RAWW value), what the typed price is worth in euros, the
supplier's cost in euros and the margin, and a warning - never a refusal -
when the price sits outside its level's band.
"""
from __future__ import annotations

import uuid
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.gear_verification import CameraModelReference
from app.models.shelf import SHELF_CURRENCIES, ShelfItem, ShelfItemCompat, ShelfSettings, ShelfStockStatus
from app.services.shelf_settings import LEVELS, shelf_settings

_CENTS = Decimal("0.01")

#: What an admin sets on an item (compatibility goes separately).
FIELDS = (
    "title", "brand", "category", "description", "image_url", "level", "price_raww",
    "street_price", "street_currency", "supplier_cost", "supplier_currency",
    "supplier_name", "supplier_sku", "supplier_url", "stock_status", "active",
)


def to_eur(amount: Decimal, currency: str, settings: ShelfSettings) -> Decimal:
    if currency == "EUR":
        return Decimal(amount).quantize(_CENTS, rounding=ROUND_HALF_UP)
    if currency == "GBP":
        return (Decimal(amount) * settings.gbp_eur_rate).quantize(_CENTS, rounding=ROUND_HALF_UP)
    raise APIError(code="validation_error", message="Prices are in GBP or EUR", status_code=422)


def band_for(level: int, settings: ShelfSettings) -> tuple[int, int | None]:
    """The RAWW range a level's prices should sit in: from its band up to
    (not including) the next level's; the top level has no ceiling."""
    bands = settings.level_band_raww
    return bands[level - 1], (bands[level] if level < LEVELS else None)


def price_helper(
    db: Session,
    *,
    level: int,
    price_raww: int | None,
    street_price: Decimal,
    street_currency: str,
    supplier_cost: Decimal,
    supplier_currency: str,
) -> dict:
    settings = shelf_settings(db)
    street_eur = to_eur(street_price, street_currency, settings)
    suggested = int(
        (street_eur * (Decimal(100 - settings.shelf_discount_percent) / Decimal(100)) / settings.raww_eur_value).quantize(
            Decimal("1"), rounding=ROUND_HALF_UP
        )
    )
    cost_eur = to_eur(supplier_cost, supplier_currency, settings)
    low, high = band_for(level, settings)
    out = {
        "suggested_price_raww": suggested,
        "street_price_eur": street_eur,
        "supplier_cost_eur": cost_eur,
        "band_low_raww": low,
        "band_high_raww": high,
        "price_eur": None,
        "margin_eur": None,
        "band_warning": None,
    }
    if price_raww:
        price_eur = (Decimal(price_raww) * settings.raww_eur_value).quantize(_CENTS, rounding=ROUND_HALF_UP)
        out["price_eur"] = price_eur
        out["margin_eur"] = price_eur - cost_eur
        if price_raww < low:
            out["band_warning"] = f"Below level {level}'s band ({low} RAWW and up)"
        elif high is not None and price_raww >= high:
            out["band_warning"] = f"At or above level {level + 1}'s band ({high} RAWW)"
    return out


def _clean(values: dict) -> dict:
    out = dict(values)
    for key in ("title", "category", "supplier_name"):
        out[key] = (out.get(key) or "").strip()
        if not out[key]:
            raise APIError(code="validation_error", message=f"{key.replace('_', ' ').capitalize()} is required", status_code=422)
    for key in ("brand", "description", "image_url", "supplier_sku", "supplier_url"):
        out[key] = (out.get(key) or "").strip() or None
    out["category"] = out["category"].lower()
    level = out.get("level")
    if isinstance(level, bool) or not isinstance(level, int) or not 1 <= level <= LEVELS:
        raise APIError(code="validation_error", message=f"Level is 1 to {LEVELS}", status_code=422)
    price = out.get("price_raww")
    if isinstance(price, bool) or not isinstance(price, int) or price <= 0:
        raise APIError(code="validation_error", message="The RAWW price must be a whole number above 0", status_code=422)
    for key in ("street_price", "supplier_cost"):
        out[key] = Decimal(str(out[key])).quantize(_CENTS, rounding=ROUND_HALF_UP)
        if out[key] < 0:
            raise APIError(code="validation_error", message=f"{key.replace('_', ' ').capitalize()} cannot be negative", status_code=422)
    for key in ("street_currency", "supplier_currency"):
        out[key] = (out.get(key) or "GBP").upper()
        if out[key] not in SHELF_CURRENCIES:
            raise APIError(code="validation_error", message="Prices are in GBP or EUR", status_code=422)
    try:
        out["stock_status"] = ShelfStockStatus(out.get("stock_status") or ShelfStockStatus.in_stock)
    except ValueError:
        raise APIError(code="validation_error", message="Stock is in_stock or out_of_stock", status_code=422) from None
    out["active"] = bool(out.get("active", True))
    return out


def _set_compat(db: Session, item: ShelfItem, camera_models: list[str]) -> list[str]:
    wanted = sorted({m.strip() for m in camera_models if m and m.strip()})
    known = set(db.execute(select(CameraModelReference.normalised_model).where(CameraModelReference.normalised_model.in_(wanted or [""]))).scalars())
    unknown = [m for m in wanted if m not in known]
    if unknown:
        raise APIError(code="validation_error", message=f"Not in the camera catalogue: {', '.join(unknown)}", status_code=422)
    db.execute(delete(ShelfItemCompat).where(ShelfItemCompat.item_id == item.id))
    for model in wanted:
        db.add(ShelfItemCompat(item_id=item.id, camera_model=model))
    db.flush()
    return wanted


def compat_for(db: Session, item_ids: list[uuid.UUID]) -> dict[uuid.UUID, list[str]]:
    out: dict[uuid.UUID, list[str]] = {i: [] for i in item_ids}
    for item_id, model in db.execute(
        select(ShelfItemCompat.item_id, ShelfItemCompat.camera_model).where(ShelfItemCompat.item_id.in_(item_ids or [uuid.uuid4()]))
    ):
        out[item_id].append(model)
    return {k: sorted(v) for k, v in out.items()}


def create_item(db: Session, *, values: dict, camera_models: list[str], actor_user_id: uuid.UUID) -> ShelfItem:
    item = ShelfItem(**_clean({k: values.get(k) for k in FIELDS}), created_by_user_id=actor_user_id)
    db.add(item)
    db.flush()
    _set_compat(db, item, camera_models)
    return item


def update_item(db: Session, *, item_id: uuid.UUID, values: dict, camera_models: list[str] | None) -> tuple[ShelfItem, dict]:
    item = db.get(ShelfItem, item_id)
    if item is None:
        raise APIError(code="not_found", message="Item not found", status_code=404)
    current = {k: getattr(item, k) for k in FIELDS}
    merged = _clean({**current, **{k: v for k, v in values.items() if k in FIELDS}})
    changes = {}
    for key, value in merged.items():
        if getattr(item, key) != value:
            changes[key] = {"from": _plain(getattr(item, key)), "to": _plain(value)}
            setattr(item, key, value)
    if camera_models is not None:
        before = compat_for(db, [item.id])[item.id]
        after = _set_compat(db, item, camera_models)
        if before != after:
            changes["camera_models"] = {"from": before, "to": after}
    db.flush()
    return item, changes


def _plain(value):
    if isinstance(value, Decimal):
        return str(value)
    if isinstance(value, ShelfStockStatus):
        return value.value
    return value


def resolve_camera_model(db: Session, *, category, camera_model: str | None, model_text: str | None) -> str | None:
    """The catalogue key for a gear item: the one picked, checked against the
    catalogue; else, for a camera body typed by hand, the catalogue entry its
    model normalises to, if any; else none (free text is still allowed)."""
    from app.models.repair import GearCategory
    from app.services.gear_verify import normalise_model

    if camera_model:
        if db.get(CameraModelReference, camera_model) is None:
            raise APIError(code="validation_error", message="That camera is not in the catalogue", status_code=422)
        return camera_model
    if category == GearCategory.camera_body and model_text:
        key = normalise_model(model_text)
        if key and db.get(CameraModelReference, key) is not None:
            return key
    return None
