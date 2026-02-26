from app.models.admin import (
    AdminAuditLog,
    BanAction,
    DeliverySlaSnapshot,
    Dispute,
    DisputeEvidence,
    DisputeEvent,
    DisputeMessage,
    EntitlementHold,
    GigContractSnapshot,
    ProQualityPenalty,
    ProProfile,
    RefundEvent,
    RefundPolicy,
    RefundCase,
    UserAccount,
    UserRole,
)
from app.models.gallery import (
    ClientSelection,
    ClientSelectionItem,
    PackagePricing,
    ProofGallery,
    ProofGalleryItem,
    UpsellPurchase,
)
from app.models.discovery import AnalyticsEvent, ProPublicIndex
from app.models.commerce import (
    Cart,
    CartItem,
    CommerceOrder,
    CommercePartner,
    OrderItem,
    OrderPayment,
    PriceRule,
    Product,
    StoreAccessOverride,
    StoreAccessPolicy,
)
from app.models.gamification import (
    CycleEvent,
    CyclePoints,
    Milestone,
    MilestoneCompletion,
    MilestoneProgress,
    PerformanceCycle,
    ProCredential,
)
from app.models.learning import (
    Certificate,
    Course,
    CourseModule,
    Enrollment,
    InstructorProfile,
    Lesson,
    LessonProgress,
    NicheProgramRequirement,
    QuizAttempt,
    QuizQuestion,
)
from app.models.launch_ops import (
    InviteCode,
    InviteWave,
    OnboardingRequirement,
    ProOnboarding,
    ProOnboardingEvent,
    RolloutCity,
    RolloutFlagOverride,
)
from app.models.niche import CertificationRecord, Niche, ProNiche, ProNicheSkill
from app.models.outbox import IdempotencyKey, OutboxEvent
from app.models.ops import AbuseSignal, FeatureFlag, WebhookSecurityLog
from app.models.auth import AuthEventLog, EmailVerification, ImpersonationSession, PasswordReset, SessionRefreshToken
from app.models.booking import (
    BookingRequest,
    BookingRequestTransition,
    ProAvailabilityRule,
    ProBlackoutDate,
    ProPackage,
)
from app.models.chat import ChatHandoff, ChatMessage, ChatThread, PlatformPolicy
from app.models.client_rewards_pricing import (
    ConsentRewardPolicy,
    ExtraImagePricingPolicy,
    ExtraImagePurchase,
    ProExtraImagePrice,
    ShareFraudSetting,
    ShareLinkEngagement,
    ShareLinkView,
    ShareRewardGrant,
    ShareRewardThreshold,
)
from app.models.communication import (
    CallEvent,
    CallSession,
    ContactConsent,
    EmailMessage,
    FollowupJob,
    FollowupRule,
    Notification,
    NotificationEvent,
    NotificationPreference,
    NotificationTopicPreference,
    ScheduledNotification,
    UserContact,
)
from app.models.gig import Gig, GigTransition, LedgerEntry, StripePayment, StripeWebhookEvent
from app.models.media import Base, MediaAsset, MediaObject, WebhookEvent
from app.models.media_rights import (
    GigMediaEntitlement,
    GigUsageConsent,
    GigUsageConsentEvent,
    MediaAccessLog,
    MediaDerivative,
    ShareLink,
)
from app.models.review import ProReputation, Review, ReviewReply
from app.models.repair import (
    GearBenefitOverride,
    GearBenefitPolicy,
    GearItem,
    LoanerEvent,
    LoanerRequest,
    RepairEvent,
    RepairPartner,
    RepairPartnerScore,
    RepairTicket,
)
from app.models.reward import (
    DiscountRedemption,
    ReferralAttribution,
    ReferralCode,
    ReminderJob,
    RewardBalance,
    RewardLedgerEntry,
    RewardRule,
)

__all__ = ["Base"]
