from fastapi import APIRouter

from app.api.v1.admin import router as admin_router
from app.api.v1.ai_concierge import router as ai_concierge_router
from app.api.v1.auth import router as auth_router
from app.api.v1.chats import router as chats_router
from app.api.v1.client_launch import router as client_launch_router
from app.api.v1.communications import router as communications_router
from app.api.v1.courses import router as courses_router
from app.api.v1.discovery import router as discovery_router
from app.api.v1.disputes import router as disputes_router
from app.api.v1.gamification import router as gamification_router
from app.api.v1.gigs import router as gigs_router
from app.api.v1.media import router as media_router
from app.api.v1.media_rights import router as media_rights_router
from app.api.v1.pro_onboarding import router as pro_onboarding_router
from app.api.v1.proof_galleries import router as proof_gallery_router
from app.api.v1.notifications import router as notifications_router
from app.api.v1.rewards import router as rewards_router
from app.api.v1.risk import router as risk_router
from app.api.v1.repairs import router as repairs_router
from app.api.v1.reviews import router as reviews_router
from app.api.v1.store import router as store_router
from app.api.v1.studioverse import router as studioverse_router
from app.api.v1.search import router as search_router
from app.api.v1.scheduling import router as scheduling_router
from app.api.v1.webhooks import router as webhooks_router
from app.api.v1.payouts import router as payouts_router
from app.api.v1.i18n import router as i18n_router
from app.api.v1.legacy import router as legacy_router
from app.api.v1.prints import router as prints_router

api_router = APIRouter(prefix="/v1")
api_router.include_router(auth_router)
api_router.include_router(admin_router)
api_router.include_router(ai_concierge_router)
api_router.include_router(chats_router)
api_router.include_router(client_launch_router)
api_router.include_router(communications_router)
api_router.include_router(courses_router)
api_router.include_router(discovery_router)
api_router.include_router(disputes_router)
api_router.include_router(gamification_router)
api_router.include_router(gigs_router)
api_router.include_router(media_router)
api_router.include_router(media_rights_router)
api_router.include_router(notifications_router)
api_router.include_router(pro_onboarding_router)
api_router.include_router(proof_gallery_router)
api_router.include_router(rewards_router)
api_router.include_router(risk_router)
api_router.include_router(repairs_router)
api_router.include_router(reviews_router)
api_router.include_router(store_router)
api_router.include_router(studioverse_router)
api_router.include_router(search_router)
api_router.include_router(scheduling_router)
api_router.include_router(webhooks_router)
api_router.include_router(payouts_router)
api_router.include_router(i18n_router)
api_router.include_router(legacy_router)
api_router.include_router(prints_router)
