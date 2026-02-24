from fastapi import APIRouter

from app.api.v1.admin import router as admin_router
from app.api.v1.disputes import router as disputes_router
from app.api.v1.gigs import router as gigs_router
from app.api.v1.media import router as media_router
from app.api.v1.proof_galleries import router as proof_gallery_router
from app.api.v1.webhooks import router as webhooks_router

api_router = APIRouter(prefix="/v1")
api_router.include_router(admin_router)
api_router.include_router(disputes_router)
api_router.include_router(gigs_router)
api_router.include_router(media_router)
api_router.include_router(proof_gallery_router)
api_router.include_router(webhooks_router)
