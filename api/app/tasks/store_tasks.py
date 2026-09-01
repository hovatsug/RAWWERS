from __future__ import annotations

import uuid

from app.db.session import SessionLocal
from app.services.store import submit_order_to_partner, sync_partner_products
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.store_tasks.sync_partner_products")
def sync_partner_products_task(partner_id: str) -> int:
    db = SessionLocal()
    try:
        count = sync_partner_products(db, uuid.UUID(partner_id))
        db.commit()
        return count
    finally:
        db.close()


@celery_app.task(name="app.tasks.store_tasks.submit_order_to_partner")
def submit_order_to_partner_task(order_id: str) -> None:
    db = SessionLocal()
    try:
        submit_order_to_partner(db, uuid.UUID(order_id))
        db.commit()
    finally:
        db.close()
