# API Endpoints Catalog

Auto-generated from FastAPI route decorators in `api/app/api/v1` and `api/app/main.py`.

Total endpoints: **403**

| Method | Path | Description |
|---|---|---|
| `GET` | `/health/ready` | Health ready. |
| `GET` | `/health/replica` | Health replica. |
| `GET` | `/healthz` | Healthcheck. |
| `GET` | `/metrics` | Metrics. |
| `GET` | `/v1/admin/abuse/signals` | List abuse signals. |
| `POST` | `/v1/admin/abuse/signals/{signal_id}/resolve` | Resolve abuse signal. |
| `PUT` | `/v1/admin/ai/feature-flags` | Admin: ai feature flags. |
| `GET` | `/v1/admin/ai/logs` | Admin: list ai logs. |
| `GET` | `/v1/admin/consent/events` | Admin: list consent events. |
| `GET` | `/v1/admin/courses` | Admin: list courses. |
| `POST` | `/v1/admin/courses/{course_id}/unpublish` | Admin: unpublish course. |
| `GET` | `/v1/admin/disputes` | List disputes. |
| `GET` | `/v1/admin/disputes/{dispute_id}` | Get dispute detail admin. |
| `POST` | `/v1/admin/disputes/{dispute_id}/resolve` | Admin: resolve dispute. |
| `POST` | `/v1/admin/disputes/{dispute_id}/set-status` | Admin: set dispute status. |
| `POST` | `/v1/admin/disputes/{dispute_id}/status` | Update dispute status. |
| `POST` | `/v1/admin/entitlement-holds/{hold_id}/release` | Release entitlement hold admin. |
| `GET` | `/v1/admin/feature-flags` | List feature flags. |
| `PUT` | `/v1/admin/feature-flags/{key}` | Put feature flag. |
| `GET` | `/v1/admin/finance/fee-policy` | Get fee policy admin. |
| `PUT` | `/v1/admin/finance/fee-policy` | Put fee policy admin. |
| `GET` | `/v1/admin/finance/pros` | List finance pros admin. |
| `GET` | `/v1/admin/finance/pros/{pro_user_id}` | Get finance pro detail admin. |
| `POST` | `/v1/admin/followups/rebuild` | Admin: rebuild followups. |
| `POST` | `/v1/admin/followups/rules/seed` | Admin: seed followup rules. |
| `GET` | `/v1/admin/funnel/clients` | Admin: client funnel. |
| `POST` | `/v1/admin/gamification/cycles` | Admin: upsert cycle. |
| `PUT` | `/v1/admin/gamification/cycles` | Admin: upsert cycle. |
| `POST` | `/v1/admin/gamification/milestones` | Admin: upsert milestone. |
| `PUT` | `/v1/admin/gamification/milestones` | Admin: upsert milestone. |
| `POST` | `/v1/admin/gamification/recompute` | Admin: gamification recompute. |
| `POST` | `/v1/admin/gigs/{gig_id}/refunds` | Create admin refund. |
| `POST` | `/v1/admin/gigs/{gig_id}/status` | Update gig status. |
| `POST` | `/v1/admin/holds/create` | Create hold admin. |
| `POST` | `/v1/admin/holds/{hold_id}/release` | Release hold admin. |
| `GET` | `/v1/admin/i18n/bundles` | Admin: list i18n bundles. |
| `POST` | `/v1/admin/i18n/bundles` | Admin: create i18n bundle. |
| `POST` | `/v1/admin/i18n/bundles/{bundle_id}/activate` | Admin: activate i18n bundle. |
| `GET` | `/v1/admin/i18n/locales` | Admin: i18n locales. |
| `GET` | `/v1/admin/i18n/missing-keys` | Admin: i18n missing keys. |
| `POST` | `/v1/admin/impersonate/end` | Impersonate end. |
| `POST` | `/v1/admin/impersonate/start` | Impersonate start. |
| `POST` | `/v1/admin/index/pro/rebuild-all` | Rebuild all index. |
| `POST` | `/v1/admin/index/pro/{pro_user_id}/rebuild` | Rebuild single pro index. |
| `POST` | `/v1/admin/instructors/{user_id}/approve` | Approve instructor. |
| `POST` | `/v1/admin/instructors/{user_id}/reject` | Reject instructor. |
| `GET` | `/v1/admin/invites/codes` | List invite codes. |
| `POST` | `/v1/admin/invites/codes/{code}/revoke` | Revoke invite code. |
| `GET` | `/v1/admin/invites/waves` | List invite waves. |
| `POST` | `/v1/admin/invites/waves` | Create wave. |
| `POST` | `/v1/admin/invites/waves/{wave_id}/generate` | Generate wave codes. |
| `POST` | `/v1/admin/jobs/expire-booking-requests` | Expire booking requests job. |
| `POST` | `/v1/admin/jobs/recompute-niche-skills` | Recompute niche skills job. |
| `GET` | `/v1/admin/learn/courses` | Admin: learn courses. |
| `POST` | `/v1/admin/learn/courses/{course_id}/review` | Admin: review course. |
| `GET` | `/v1/admin/learn/fee-policy` | Admin: get learning fee policy. |
| `PUT` | `/v1/admin/learn/fee-policy` | Admin: upsert learning fee policy. |
| `GET` | `/v1/admin/learn/partners` | Admin: learning partners. |
| `POST` | `/v1/admin/learn/partners` | Admin: upsert learning partner. |
| `GET` | `/v1/admin/learn/sales` | Admin: learning sales. |
| `GET` | `/v1/admin/legacy/orders` | Admin: legacy orders. |
| `POST` | `/v1/admin/legacy/{legacy_booking_id}/assign-pro` | Admin: legacy assign pro. |
| `GET` | `/v1/admin/legacy/{legacy_booking_id}/audit` | Admin: legacy audit. |
| `POST` | `/v1/admin/legacy/{legacy_booking_id}/set-status` | Admin: legacy set status. |
| `POST` | `/v1/admin/niche-skill/recalc` | Admin: niche skill recalc. |
| `GET` | `/v1/admin/niches` | Admin: list niches. |
| `PUT` | `/v1/admin/niches` | Admin: upsert niche. |
| `GET` | `/v1/admin/niches/{niche_id}/tier-policy` | Admin: get niche tier policy. |
| `PUT` | `/v1/admin/niches/{niche_id}/tier-policy` | Admin: put niche tier policy. |
| `POST` | `/v1/admin/niches/{niche_slug}/requirements` | Admin: set niche requirements. |
| `GET` | `/v1/admin/notifications/logs` | Admin: notification logs. |
| `POST` | `/v1/admin/notifications/resend` | Admin: notification resend. |
| `GET` | `/v1/admin/onboarding/pros` | List pro onboarding. |
| `POST` | `/v1/admin/onboarding/pros/{pro_user_id}/approve` | Approve pro onboarding. |
| `POST` | `/v1/admin/onboarding/pros/{pro_user_id}/reject` | Reject pro onboarding. |
| `POST` | `/v1/admin/onboarding/pros/{pro_user_id}/set-status` | Set pro onboarding status admin. |
| `GET` | `/v1/admin/ops/metrics-summary` | Ops metrics summary. |
| `GET` | `/v1/admin/payouts` | List payouts admin. |
| `POST` | `/v1/admin/payouts/{payout_request_id}/approve` | Approve payout admin. |
| `POST` | `/v1/admin/payouts/{payout_request_id}/mark-paid` | Mark paid payout admin. |
| `POST` | `/v1/admin/payouts/{payout_request_id}/reject` | Reject payout admin. |
| `GET` | `/v1/admin/pricing/extra-image-policies` | List extra image pricing policies. |
| `PUT` | `/v1/admin/pricing/extra-image-policies` | Upsert extra image pricing policies. |
| `GET` | `/v1/admin/pricing/pro-extra-image-price/{pro_user_id}` | List pro extra image prices. |
| `PUT` | `/v1/admin/pricing/pro-extra-image-price/{pro_user_id}` | Upsert pro extra image prices. |
| `GET` | `/v1/admin/prints/catalog/products` | Admin: get products. |
| `PUT` | `/v1/admin/prints/catalog/products` | Admin: put product. |
| `GET` | `/v1/admin/prints/orders` | Admin: orders. |
| `GET` | `/v1/admin/prints/orders/{order_id}` | Admin: order detail. |
| `POST` | `/v1/admin/prints/orders/{order_id}/set-status` | Admin: set status. |
| `POST` | `/v1/admin/prints/orders/{order_id}/set-tracking` | Admin: set tracking. |
| `GET` | `/v1/admin/prints/partners` | Admin: get partners. |
| `PUT` | `/v1/admin/prints/partners` | Admin: put partner. |
| `PUT` | `/v1/admin/pros/{pro_user_id}/ai-profile` | Admin: put ai profile. |
| `GET` | `/v1/admin/pros/{pro_user_id}/niche-skill` | Admin: get pro niche skill. |
| `POST` | `/v1/admin/pros/{pro_user_id}/niche-skill/{niche_id}/override` | Admin: override niche skill v2. |
| `POST` | `/v1/admin/pros/{pro_user_id}/niches/{niche_slug}/recompute` | Admin: recompute pro niche skill. |
| `POST` | `/v1/admin/pros/{pro_user_id}/skills/{niche_slug}/override` | Override pro niche skill. |
| `POST` | `/v1/admin/pros/{user_id}/kyc` | Update pro kyc. |
| `GET` | `/v1/admin/raww/caps` | List raww caps. |
| `PUT` | `/v1/admin/raww/caps` | Put raww caps. |
| `POST` | `/v1/admin/raww/clawback` | Post raww clawback. |
| `GET` | `/v1/admin/raww/issuance-rules` | List raww issuance rules. |
| `PUT` | `/v1/admin/raww/issuance-rules` | Put raww issuance rules. |
| `GET` | `/v1/admin/raww/mints` | Get raww mints. |
| `GET` | `/v1/admin/raww/multiplier-policy` | Get raww multiplier policy. |
| `PUT` | `/v1/admin/raww/multiplier-policy` | Put raww multiplier policy. |
| `DELETE` | `/v1/admin/referrals/blacklist/{user_id}` | Admin: unblacklist referrer. |
| `POST` | `/v1/admin/referrals/blacklist/{user_id}` | Admin: blacklist referrer. |
| `GET` | `/v1/admin/referrals/policy` | Admin: get referral policy. |
| `PUT` | `/v1/admin/referrals/policy` | Admin: put referral policy. |
| `GET` | `/v1/admin/referrals/report` | Admin: referrals report. |
| `GET` | `/v1/admin/refunds` | List refunds. |
| `POST` | `/v1/admin/refunds/{refund_case_id}/retry` | Retry refund case. |
| `GET` | `/v1/admin/repairs/loaners` | Admin: list loaners. |
| `POST` | `/v1/admin/repairs/loaners/{loaner_request_id}/set-status` | Admin: set loaner status. |
| `POST` | `/v1/admin/repairs/overrides/{pro_user_id}` | Admin: upsert gear override. |
| `GET` | `/v1/admin/repairs/partners` | Admin: list repair partners. |
| `POST` | `/v1/admin/repairs/partners` | Admin: create repair partner. |
| `PUT` | `/v1/admin/repairs/partners/{partner_id}` | Admin: update repair partner. |
| `POST` | `/v1/admin/repairs/partners/{partner_id}/recompute-score` | Admin: recompute partner score. |
| `POST` | `/v1/admin/repairs/partners/{partner_id}/set-active` | Admin: set partner active. |
| `GET` | `/v1/admin/repairs/policy` | Admin: get gear policy. |
| `PUT` | `/v1/admin/repairs/policy` | Admin: update gear policy. |
| `GET` | `/v1/admin/repairs/tickets` | Admin: list repair tickets. |
| `POST` | `/v1/admin/repairs/tickets/{ticket_id}/assign-partner` | Admin: assign partner. |
| `POST` | `/v1/admin/repairs/tickets/{ticket_id}/set-quote` | Admin: set quote. |
| `POST` | `/v1/admin/repairs/tickets/{ticket_id}/set-status` | Admin: set ticket status. |
| `POST` | `/v1/admin/reviews/{review_id}/moderate` | Moderate review. |
| `POST` | `/v1/admin/rewards/adjust` | Admin: adjust rewards. |
| `GET` | `/v1/admin/rewards/consent-policies` | List consent reward policies. |
| `PUT` | `/v1/admin/rewards/consent-policies` | Upsert consent reward policies. |
| `GET` | `/v1/admin/rewards/rules` | Admin: list reward rules. |
| `POST` | `/v1/admin/rewards/rules/{code}` | Admin: upsert reward rule. |
| `GET` | `/v1/admin/rewards/share-fraud-settings` | Get share fraud settings admin. |
| `PUT` | `/v1/admin/rewards/share-fraud-settings` | Put share fraud settings admin. |
| `GET` | `/v1/admin/rewards/share-grants` | List share reward grants. |
| `GET` | `/v1/admin/rewards/share-thresholds` | List share thresholds. |
| `PUT` | `/v1/admin/rewards/share-thresholds` | Upsert share thresholds. |
| `GET` | `/v1/admin/risk/rules` | Admin: list risk rules. |
| `PUT` | `/v1/admin/risk/rules/{rule_id}` | Admin: put risk rule. |
| `GET` | `/v1/admin/risk/users` | Admin: list risk users. |
| `GET` | `/v1/admin/risk/users/{user_id}` | Admin: get risk user. |
| `POST` | `/v1/admin/risk/users/{user_id}/clear-action` | Admin: clear risk action. |
| `POST` | `/v1/admin/risk/users/{user_id}/set-score` | Admin: set risk score. |
| `GET` | `/v1/admin/rollout/cities` | List rollout cities. |
| `PUT` | `/v1/admin/rollout/cities` | Upsert rollout cities. |
| `POST` | `/v1/admin/rollout/cities/bulk-enable` | Bulk enable rollout cities. |
| `GET` | `/v1/admin/rollout/overrides/{user_id}` | Get rollout override. |
| `PUT` | `/v1/admin/rollout/overrides/{user_id}` | Put rollout override. |
| `GET` | `/v1/admin/scheduling/conflicts` | Admin: scheduling conflicts. |
| `POST` | `/v1/admin/search/purge` | Admin: search purge. |
| `POST` | `/v1/admin/search/rebuild` | Admin: search rebuild. |
| `GET` | `/v1/admin/search/status` | Admin: search status. |
| `POST` | `/v1/admin/share-links/{share_link_id}/revoke` | Admin: revoke share link. |
| `POST` | `/v1/admin/store/orders/{order_id}/update-status` | Admin: store order update status. |
| `POST` | `/v1/admin/store/overrides/{pro_user_id}` | Admin: store override. |
| `GET` | `/v1/admin/store/partners` | Admin: store partners. |
| `POST` | `/v1/admin/store/partners` | Admin: store partner create. |
| `PUT` | `/v1/admin/store/partners/{partner_id}` | Admin: store partner update. |
| `POST` | `/v1/admin/store/partners/{partner_id}/sync` | Admin: store partner sync. |
| `GET` | `/v1/admin/store/policy` | Admin: store policy get. |
| `PUT` | `/v1/admin/store/policy` | Admin: store policy update. |
| `GET` | `/v1/admin/store/price-rules` | Admin: store price rules. |
| `POST` | `/v1/admin/store/price-rules` | Admin: store price rule create. |
| `PUT` | `/v1/admin/store/price-rules/{rule_id}` | Admin: store price rule update. |
| `GET` | `/v1/admin/store/products` | Admin: store products. |
| `POST` | `/v1/admin/store/products` | Admin: store product create. |
| `PUT` | `/v1/admin/store/products/{product_id}` | Admin: store product update. |
| `GET` | `/v1/admin/studioverse/packs` | Admin: list studioverse packs. |
| `POST` | `/v1/admin/studioverse/packs/{pack_id}/review` | Admin: review studioverse pack. |
| `POST` | `/v1/admin/studioverse/packs/{pack_id}/takedown` | Admin: takedown studioverse pack. |
| `GET` | `/v1/admin/users` | List users. |
| `GET` | `/v1/admin/users/{user_id}` | Get user detail. |
| `POST` | `/v1/admin/users/{user_id}/ban` | Update user ban. |
| `POST` | `/v1/admin/users/{user_id}/roles` | Update user roles. |
| `POST` | `/v1/analytics` | Create analytics event. |
| `POST` | `/v1/auth/login` | Login. |
| `POST` | `/v1/auth/logout` | Logout. |
| `POST` | `/v1/auth/password-reset/confirm` | Password reset confirm. |
| `POST` | `/v1/auth/password-reset/request` | Password reset request. |
| `POST` | `/v1/auth/refresh` | Refresh. |
| `POST` | `/v1/auth/register` | Register. |
| `POST` | `/v1/auth/verify-email/confirm` | Verify email confirm. |
| `POST` | `/v1/auth/verify-email/request` | Verify email request. |
| `GET` | `/v1/booking-requests/{request_id}` | Get booking request. |
| `POST` | `/v1/booking-requests/{request_id}/accept` | Accept booking request. |
| `POST` | `/v1/booking-requests/{request_id}/cancel` | Cancel booking request. |
| `POST` | `/v1/booking-requests/{request_id}/decline` | Decline booking request. |
| `POST` | `/v1/calls/request` | Request outbound call. |
| `POST` | `/v1/calls/{call_session_id}/ai/summary` | Summarize call. |
| `POST` | `/v1/chat/threads` | Create chat thread v1. |
| `GET` | `/v1/chat/threads/{thread_id}` | Get chat thread v1. |
| `POST` | `/v1/chat/threads/{thread_id}/create-booking` | Create booking from chat. |
| `POST` | `/v1/chat/threads/{thread_id}/messages` | Post chat message v1. |
| `GET` | `/v1/chats/{thread_id}` | Get chat thread. |
| `POST` | `/v1/chats/{thread_id}/close` | Close chat. |
| `POST` | `/v1/chats/{thread_id}/create-booking-request` | Create booking request from chat. |
| `POST` | `/v1/chats/{thread_id}/messages` | Append chat message. |
| `POST` | `/v1/chats/{thread_id}/takeover` | Pro takeover. |
| `GET` | `/v1/client/access` | Get client access. |
| `POST` | `/v1/client/bookings/request` | Client booking request. |
| `GET` | `/v1/client/bookings/{booking_id}` | Client booking status. |
| `POST` | `/v1/client/bookings/{booking_id}/pay` | Client booking pay. |
| `POST` | `/v1/client/bookings/{booking_request_id}/time-windows` | Submit booking time windows. |
| `GET` | `/v1/client/discover` | Client discover. |
| `POST` | `/v1/client/match` | Client match. |
| `GET` | `/v1/client/pros/{pro_user_id}` | Client pro profile. |
| `POST` | `/v1/client/waitlist` | Create waitlist entry. |
| `GET` | `/v1/courses` | List courses. |
| `GET` | `/v1/courses/{course_id}` | Get course. |
| `POST` | `/v1/courses/{course_id}/enroll` | Enroll course. |
| `POST` | `/v1/discover/match` | Discover match. |
| `GET` | `/v1/discover/pros` | Discover pros. |
| `GET` | `/v1/disputes` | List disputes. |
| `POST` | `/v1/disputes` | Create dispute endpoint. |
| `GET` | `/v1/disputes/{dispute_id}` | Get dispute. |
| `POST` | `/v1/disputes/{dispute_id}/cancel` | Cancel dispute. |
| `POST` | `/v1/disputes/{dispute_id}/evidence` | Add dispute evidence compat. |
| `POST` | `/v1/disputes/{dispute_id}/messages` | Add dispute message. |
| `POST` | `/v1/enrollments/{enrollment_id}/lessons/{lesson_id}/progress` | Update lesson progress. |
| `POST` | `/v1/enrollments/{enrollment_id}/lessons/{lesson_id}/quiz-attempt` | Submit quiz attempt. |
| `POST` | `/v1/gigs` | Create gig. |
| `GET` | `/v1/gigs/{gig_id}` | Get gig. |
| `POST` | `/v1/gigs/{gig_id}/cancel-slot` | Cancel slot. |
| `GET` | `/v1/gigs/{gig_id}/consent` | Get gig consent. |
| `PUT` | `/v1/gigs/{gig_id}/consent` | Put gig consent. |
| `GET` | `/v1/gigs/{gig_id}/media` | List gig media. |
| `GET` | `/v1/gigs/{gig_id}/media/{media_asset_id}/download` | Download media. |
| `GET` | `/v1/gigs/{gig_id}/media/{media_asset_id}/signed-url` | Get media signed url. |
| `POST` | `/v1/gigs/{gig_id}/payments/stripe/create-intent` | Create payment intent. |
| `POST` | `/v1/gigs/{gig_id}/prints/orders` | Create gig print order. |
| `POST` | `/v1/gigs/{gig_id}/proof-gallery` | Create proof gallery. |
| `POST` | `/v1/gigs/{gig_id}/refunds/stripe` | Create refund. |
| `POST` | `/v1/gigs/{gig_id}/reschedule-request` | Create reschedule request. |
| `POST` | `/v1/gigs/{gig_id}/review` | Create review for gig. |
| `POST` | `/v1/gigs/{gig_id}/share-links` | Create share link. |
| `GET` | `/v1/i18n/bundles` | Get i18n bundle. |
| `POST` | `/v1/instructor/courses` | Instructor create course. |
| `PUT` | `/v1/instructor/courses/{course_id}` | Instructor update course. |
| `POST` | `/v1/instructor/courses/{course_id}/modules` | Instructor create module. |
| `POST` | `/v1/instructor/courses/{course_id}/publish` | Instructor publish course. |
| `POST` | `/v1/instructor/modules/{module_id}/lessons` | Instructor create lesson. |
| `GET` | `/v1/learn/certificates/mine` | Learn my certificates. |
| `GET` | `/v1/learn/certificates/{verification_code}` | Learn verify certificate. |
| `GET` | `/v1/learn/courses` | Learn courses. |
| `GET` | `/v1/learn/courses/{course_id}` | Learn course detail. |
| `POST` | `/v1/learn/courses/{course_id}/enroll` | Learn enroll course. |
| `GET` | `/v1/learn/curricula` | Learn curricula. |
| `POST` | `/v1/learn/enrollments/{enrollment_id}/modules/{module_id}/progress` | Learn module progress. |
| `POST` | `/v1/learn/enrollments/{enrollment_id}/modules/{module_id}/quiz` | Learn module quiz. |
| `POST` | `/v1/learn/enrollments/{enrollment_id}/pay` | Learn settle enrollment payment. |
| `POST` | `/v1/legacy/checkout` | Legacy checkout. |
| `GET` | `/v1/legacy/{legacy_booking_id}` | Legacy get. |
| `PUT` | `/v1/legacy/{legacy_booking_id}/brief` | Legacy put brief. |
| `PUT` | `/v1/legacy/{legacy_booking_id}/marketing-consent` | Legacy marketing consent put. |
| `POST` | `/v1/legacy/{legacy_booking_id}/reviews/{review_id}/respond` | Legacy review respond. |
| `GET` | `/v1/legacy/{legacy_booking_id}/vault` | Legacy vault list. |
| `POST` | `/v1/legacy/{legacy_booking_id}/vault/{vault_item_id}/download` | Legacy vault download. |
| `GET` | `/v1/me` | Me. |
| `GET` | `/v1/me/certificates` | My certificates. |
| `GET` | `/v1/me/client-preference` | Get client preference. |
| `PUT` | `/v1/me/client-preference` | Put client preference. |
| `POST` | `/v1/me/consent` | Set my consent. |
| `PUT` | `/v1/me/contact` | Upsert my contact. |
| `GET` | `/v1/me/enrollments` | My enrollments. |
| `GET` | `/v1/me/game/quests` | My milestones. |
| `GET` | `/v1/me/game/seasons/current` | My current cycle. |
| `GET` | `/v1/me/gamification/credentials` | My credentials. |
| `GET` | `/v1/me/gamification/cycle/current` | My current cycle. |
| `GET` | `/v1/me/gamification/milestones` | My milestones. |
| `GET` | `/v1/me/locale` | Me locale. |
| `PUT` | `/v1/me/locale` | Update me locale. |
| `GET` | `/v1/me/notification-preferences` | Get my notification preferences. |
| `PUT` | `/v1/me/notification-preferences` | Put my notification preferences. |
| `GET` | `/v1/me/notification-topic-preferences` | Get my topic preferences. |
| `PUT` | `/v1/me/notification-topic-preferences` | Put my topic preferences. |
| `GET` | `/v1/me/notifications` | Get my notifications. |
| `POST` | `/v1/me/notifications/read-all` | Read all notifications. |
| `POST` | `/v1/me/notifications/{notification_id}/read` | Read notification. |
| `GET` | `/v1/me/referral-code` | My referral code v2. |
| `POST` | `/v1/me/referral-code/regenerate` | Regenerate my referral code. |
| `GET` | `/v1/me/referrals/stats` | My referral stats. |
| `GET` | `/v1/me/rewards/balance` | Rewards balance. |
| `POST` | `/v1/me/upgrade-to-pro` | Upgrade to pro. |
| `POST` | `/v1/media/photos/uploads` | Create photo upload. |
| `POST` | `/v1/media/photos/{media_asset_id}/complete` | Complete photo upload. |
| `POST` | `/v1/media/videos/mux/uploads` | Create mux upload. |
| `POST` | `/v1/media/videos/{media_asset_id}/playback-token` | Create playback token. |
| `GET` | `/v1/media/{media_asset_id}` | Get media asset. |
| `GET` | `/v1/niches` | List niches. |
| `POST` | `/v1/partner/learn/courses` | Partner create course. |
| `GET` | `/v1/partner/learn/courses/mine` | Partner my courses. |
| `PUT` | `/v1/partner/learn/courses/{course_id}` | Partner update course. |
| `POST` | `/v1/partner/learn/courses/{course_id}/submit` | Partner submit course. |
| `GET` | `/v1/prints/catalog` | Prints catalog. |
| `GET` | `/v1/prints/orders/mine` | My orders. |
| `GET` | `/v1/prints/orders/{order_id}` | My order detail. |
| `PUT` | `/v1/prints/orders/{order_id}` | Update order. |
| `POST` | `/v1/prints/orders/{order_id}/pay` | Pay order. |
| `POST` | `/v1/pro/bookings/{booking_request_id}/confirm-slot` | Confirm booking slot. |
| `GET` | `/v1/pro/chat/threads` | List pro threads. |
| `GET` | `/v1/pro/chat/threads/{thread_id}` | Get pro thread. |
| `POST` | `/v1/pro/chat/threads/{thread_id}/ai-draft` | Ai draft for pro. |
| `POST` | `/v1/pro/chat/threads/{thread_id}/messages` | Post pro message. |
| `GET` | `/v1/pro/earnings/balance` | Get my earnings balance. |
| `GET` | `/v1/pro/earnings/ledger` | Get my earnings ledger. |
| `GET` | `/v1/pro/legacy/assigned` | Pro legacy assigned. |
| `POST` | `/v1/pro/legacy/{legacy_booking_id}/mark-shoot-done` | Pro mark shoot done. |
| `POST` | `/v1/pro/legacy/{legacy_booking_id}/reviews/submit` | Pro review submit. |
| `POST` | `/v1/pro/legacy/{legacy_booking_id}/vault/upload` | Pro vault upload. |
| `POST` | `/v1/pro/me/activate` | Activate pro. |
| `POST` | `/v1/pro/me/availability/blackouts` | Create blackout. |
| `POST` | `/v1/pro/me/availability/rules` | Replace availability rules. |
| `GET` | `/v1/pro/me/gear-benefits/access` | My gear benefit access. |
| `GET` | `/v1/pro/me/gear-items` | List my gear items. |
| `POST` | `/v1/pro/me/gear-items` | Create gear item. |
| `PUT` | `/v1/pro/me/gear-items/{gear_item_id}` | Update gear item. |
| `PUT` | `/v1/pro/me/niches` | Update my niches. |
| `POST` | `/v1/pro/me/packages` | Create package. |
| `PUT` | `/v1/pro/me/packages/{package_id}` | Update package. |
| `POST` | `/v1/pro/me/packages/{package_id}/disable` | Disable package. |
| `POST` | `/v1/pro/me/portfolio/{media_asset_id}/niches` | Tag portfolio media niches. |
| `GET` | `/v1/pro/me/profile` | Get my pro profile. |
| `PUT` | `/v1/pro/me/profile` | Update my pro profile. |
| `GET` | `/v1/pro/me/skills` | Get my niche skills. |
| `GET` | `/v1/pro/niches/mine` | Get my selected niches. |
| `PUT` | `/v1/pro/niches/mine` | Put my selected niches. |
| `GET` | `/v1/pro/onboarding` | Get my onboarding. |
| `GET` | `/v1/pro/onboarding/checks` | Get onboarding checks. |
| `POST` | `/v1/pro/onboarding/complete-profile` | Complete profile onboarding stage. |
| `POST` | `/v1/pro/onboarding/configure-packages` | Complete packages onboarding stage. |
| `POST` | `/v1/pro/onboarding/select-niches` | Complete niches onboarding stage. |
| `POST` | `/v1/pro/onboarding/start` | Start my onboarding. |
| `POST` | `/v1/pro/onboarding/submit-kyc` | Submit kyc onboarding stage. |
| `POST` | `/v1/pro/onboarding/upload-portfolio` | Complete portfolio onboarding stage. |
| `GET` | `/v1/pro/payouts` | Get my payouts. |
| `GET` | `/v1/pro/payouts/account` | Get my payout account. |
| `PUT` | `/v1/pro/payouts/account` | Put my payout account. |
| `POST` | `/v1/pro/payouts/request` | Request my payout. |
| `GET` | `/v1/pro/scheduling/availability-rules` | Get my availability rules. |
| `PUT` | `/v1/pro/scheduling/availability-rules` | Put my availability rules. |
| `GET` | `/v1/pro/scheduling/exceptions` | Get my scheduling exceptions. |
| `PUT` | `/v1/pro/scheduling/exceptions` | Put my scheduling exceptions. |
| `GET` | `/v1/pro/scheduling/policy` | Get my scheduling policy. |
| `PUT` | `/v1/pro/scheduling/policy` | Put my scheduling policy. |
| `GET` | `/v1/pro/scheduling/slots` | Get my candidate slots. |
| `GET` | `/v1/pro/{pro_user_id}/availability` | Get public availability. |
| `GET` | `/v1/pro/{pro_user_id}/packages` | List pro packages. |
| `GET` | `/v1/proof-galleries/{gallery_id}` | Get gallery. |
| `GET` | `/v1/proof-galleries/{gallery_id}/downloads` | Get download links. |
| `POST` | `/v1/proof-galleries/{gallery_id}/items` | Add gallery items. |
| `POST` | `/v1/proof-galleries/{gallery_id}/publish` | Publish gallery. |
| `POST` | `/v1/proof-galleries/{gallery_id}/selections` | Save selection. |
| `POST` | `/v1/proof-galleries/{gallery_id}/selections/submit` | Submit selection. |
| `POST` | `/v1/proof-galleries/{gallery_id}/upsell/create-intent` | Create upsell intent. |
| `POST` | `/v1/pros/{pro_user_id}/booking-requests` | Create booking request. |
| `POST` | `/v1/pros/{pro_user_id}/chats` | Create chat thread. |
| `GET` | `/v1/pros/{pro_user_id}/public` | Get public pro profile. |
| `GET` | `/v1/pros/{pro_user_id}/reviews` | List pro reviews. |
| `GET` | `/v1/pros/{pro_user_id}/skills` | Get pro niche skills. |
| `GET` | `/v1/ref/{code}` | Referral landing. |
| `POST` | `/v1/referrals/claim` | Claim referral. |
| `GET` | `/v1/referrals/me` | My referral code. |
| `GET` | `/v1/repairs/partners` | List repair partners. |
| `POST` | `/v1/repairs/tickets` | Create repair ticket. |
| `GET` | `/v1/repairs/tickets/{ticket_id}` | Get repair ticket. |
| `POST` | `/v1/repairs/tickets/{ticket_id}/approve-quote` | Approve quote. |
| `POST` | `/v1/repairs/tickets/{ticket_id}/close` | Close ticket. |
| `POST` | `/v1/repairs/tickets/{ticket_id}/decline-quote` | Decline quote. |
| `POST` | `/v1/repairs/tickets/{ticket_id}/request-loaner` | Request loaner. |
| `POST` | `/v1/reviews/{review_id}/reply` | Create review reply. |
| `GET` | `/v1/rewards/balance` | Rewards balance. |
| `GET` | `/v1/rewards/ledger` | Rewards ledger. |
| `POST` | `/v1/rewards/spend` | Reserve reward spend. |
| `GET` | `/v1/search/courses` | Search courses. |
| `GET` | `/v1/search/products` | Search products. |
| `GET` | `/v1/search/pros` | Search pros. |
| `GET` | `/v1/search/repair-partners` | Search repair partners. |
| `GET` | `/v1/share/{token}` | View share link. |
| `POST` | `/v1/share/{token}/cta-click` | Track share cta click. |
| `POST` | `/v1/share/{token}/ping` | Ping share link. |
| `GET` | `/v1/store/access` | Store access. |
| `GET` | `/v1/store/cart` | Store cart. |
| `POST` | `/v1/store/cart/items` | Store cart add item. |
| `DELETE` | `/v1/store/cart/items/{item_id}` | Store cart delete item. |
| `POST` | `/v1/store/checkout` | Store checkout. |
| `GET` | `/v1/store/orders` | My store orders. |
| `GET` | `/v1/store/orders/{order_id}` | My store order detail. |
| `GET` | `/v1/store/products` | Store products. |
| `GET` | `/v1/store/products/{product_id}` | Store product detail. |
| `GET` | `/v1/studioverse/orders/mine` | List my studioverse orders. |
| `POST` | `/v1/studioverse/orders/{order_id}/download` | Download content pack. |
| `GET` | `/v1/studioverse/packs` | List marketplace packs. |
| `POST` | `/v1/studioverse/packs` | Create content pack draft. |
| `GET` | `/v1/studioverse/packs/mine` | List my content packs. |
| `GET` | `/v1/studioverse/packs/{pack_id}` | Marketplace pack detail. |
| `PUT` | `/v1/studioverse/packs/{pack_id}` | Update content pack draft. |
| `POST` | `/v1/studioverse/packs/{pack_id}/checkout` | Checkout content pack. |
| `POST` | `/v1/studioverse/packs/{pack_id}/submit` | Submit content pack. |
| `POST` | `/v1/webhooks/mux` | Endpoint handler. |
| `POST` | `/v1/webhooks/stripe` | Endpoint handler. |
| `POST` | `/v1/webhooks/telephony` | Endpoint handler. |
