# Foundation #20 Notifications + Messaging v1

## Scope
- In-app notifications with read/unread and action deep links.
- Email notifications via provider abstraction (`MailProvider`).
- User preferences by channel and topic.
- Quiet-hours deferral (timezone-aware) and digest-mode readiness.
- Outbox-backed, idempotent delivery with dedupe keys and retry-safe processing.
- Admin visibility and resend for failed email sends.

## Data Model
- `notification_preference`
- `notification_topic_preference`
- `notification` (extended with `topic`, `type`, `action`, `severity`, `read_at`, `metadata`)
- `email_message`
- `notification_event`
- `scheduled_notification`

## Topics and Types (v1)
Supported baseline type keys include:
- `booking.request_received`
- `booking.request_accepted`
- `booking.request_declined`
- `payment.succeeded`
- `payment.failed`
- `proofs.gallery_published`
- `proofs.selection_due_reminder`
- `proofs.delivery_completed`
- `review.request`
- `course.completed`
- `certificate.issued`
- `store.order_paid`
- `store.order_shipped`
- `repair.quote_sent`
- `repair.return_shipped`
- `loaner.approved`
- `title.awarded`
- `quest.completed`
- `auth.new_login`
- `password.reset`

## Outbox Topics
Domain code emits:
- `notify.create_inapp`
- `notify.send_email`

Dispatcher processes these topics and handles:
- preference checks
- rate limits
- dedupe checks
- quiet-hours scheduling
- email logging and status updates

## Template Registry
Template rendering is centralized in `app/services/notifications.py`:
- `template_key` is notification `type`.
- Each template resolves `subject`, `title`, and `body`.
- Action URLs are sanitized and only allow app-relative links (must start with `/`).

## Quiet Hours Behavior
- If quiet hours are enabled and the event is non-critical:
  - email is deferred into `scheduled_notification`.
- If `NOTIFICATION_CRITICAL_BYPASS_QUIET_HOURS=true`:
  - `critical` severity sends immediately.
- Deferred notifications are drained by the outbox worker loop.

## Rate Limits
Configured through #17 limiter buckets:
- `notifications_email` (default `20/day/user`)
- `notifications_inapp` (default `60/day/user`)
- `notifications_burst` (default `30/min/principal+type`)

## API
User endpoints:
- `GET /v1/me/notifications`
- `POST /v1/me/notifications/{id}/read`
- `POST /v1/me/notifications/read-all`
- `GET /v1/me/notification-preferences`
- `PUT /v1/me/notification-preferences`
- `GET /v1/me/notification-topic-preferences`
- `PUT /v1/me/notification-topic-preferences`

Admin endpoints:
- `GET /v1/admin/notifications/logs`
- `POST /v1/admin/notifications/resend`

## Adding a New Notification from a Domain Event
1. In the domain service, call `enqueue_notification(...)`.
2. Provide:
   - `user_id`
   - `notification_type`
   - `reference_type` + `reference_id`
   - optional payload (`title/body/action` overrides)
3. Commit transaction; outbox dispatcher handles actual delivery.

## Security Notes
- Logs avoid exposing email local-part and secrets.
- Notification payloads should avoid full PII and payment method details.
- Action links are sanitized to prevent external unsafe redirects.
- Email flows include unsubscribe link generation for topic-level controls.
