# CLIENT Endpoints Used

Implemented in:
- `web/lib/api/clientApi.ts`
- `flutter/lib/core/api/client_api.dart`

## Auth / identity
- GET `/v1/me`
- POST `/v1/auth/login`
- POST `/v1/auth/register`
- POST `/v1/auth/logout`
- POST `/v1/auth/refresh`
- POST `/v1/auth/password-reset/request`
- POST `/v1/auth/password-reset/confirm`
- POST `/v1/auth/verify-email/request`
- POST `/v1/auth/verify-email/confirm`

## Discovery / matching
- GET `/v1/client/access`
- GET `/v1/client/discover`
- POST `/v1/client/match`
- GET `/v1/search/pros`
- GET `/v1/pros/{pro_user_id}/public`
- GET `/v1/client/pros/{pro_user_id}`
- POST `/v1/client/waitlist`

## Booking / requests
- POST `/v1/client/bookings/request`
- GET `/v1/client/bookings/{booking_id}`
- POST `/v1/client/bookings/{booking_id}/pay`
- POST `/v1/client/bookings/{booking_request_id}/time-windows`
- GET `/v1/booking-requests/{request_id}`
- POST `/v1/booking-requests/{request_id}/cancel`

## Gigs / gallery / media
- GET `/v1/gigs/{gig_id}`
- GET `/v1/gigs/{gig_id}/consent`
- PUT `/v1/gigs/{gig_id}/consent`
- POST `/v1/gigs/{gig_id}/payments/stripe/create-intent`
- POST `/v1/gigs/{gig_id}/review`
- GET `/v1/gigs/{gig_id}/media`
- GET `/v1/gigs/{gig_id}/media/{media_asset_id}/signed-url`
- GET `/v1/gigs/{gig_id}/media/{media_asset_id}/download`
- GET `/v1/proof-galleries/{gallery_id}`
- POST `/v1/proof-galleries/{gallery_id}/selections`
- POST `/v1/proof-galleries/{gallery_id}/selections/submit`
- POST `/v1/proof-galleries/{gallery_id}/upsell/create-intent`
- GET `/v1/proof-galleries/{gallery_id}/downloads`

## Disputes
- GET `/v1/disputes`
- POST `/v1/disputes`
- GET `/v1/disputes/{dispute_id}`
- POST `/v1/disputes/{dispute_id}/cancel`
- POST `/v1/disputes/{dispute_id}/evidence`
- POST `/v1/disputes/{dispute_id}/messages`

## Preferences / notifications / rewards
- PUT `/v1/me/contact`
- GET `/v1/me/client-preference`
- PUT `/v1/me/client-preference`
- GET `/v1/me/notification-preferences`
- PUT `/v1/me/notification-preferences`
- GET `/v1/me/notifications`
- POST `/v1/me/notifications/read-all`
- POST `/v1/me/notifications/{notification_id}/read`
- GET `/v1/me/rewards/balance`
- GET `/v1/rewards/balance`
- GET `/v1/rewards/ledger`
- POST `/v1/rewards/spend`

## Prints / referrals
- GET `/v1/prints/catalog`
- GET `/v1/prints/orders/mine`
- GET `/v1/prints/orders/{order_id}`
- POST `/v1/prints/orders/{order_id}/pay`
- PUT `/v1/prints/orders/{order_id}`
- POST `/v1/gigs/{gig_id}/prints/orders`
- GET `/v1/me/referral-code`
- POST `/v1/me/referral-code/regenerate`
- GET `/v1/me/referrals/stats`
- GET `/v1/ref/{code}`
- POST `/v1/referrals/claim`

## Analytics
- POST `/v1/analytics`
