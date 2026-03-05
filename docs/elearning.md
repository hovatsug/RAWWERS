# RAWWERS E-Learning v1

## Overview
Slice #39 adds an e-learning pipeline for pros with:
- school/partner-owned courses (`learning_partner`)
- course lifecycle (`draft -> submitted -> approved/rejected/delisted`)
- paid/free enrollments
- module progress with anti-cheat watch-time caps
- quiz scoring per module
- course + curriculum certificates with public verification codes
- revenue-share accounting (`course_sale`) and fee policy (`learning_fee_policy`)

## Core model
- `learning_partner`: partner profile + payout reference hooks.
- `course`: legacy fields preserved plus v1 fields (`partner_id`, `title_custom`, `pricing_mode`, `status`, `niche_slugs`, `language`, `price_eur`).
- `course_module`: now supports module type + Mux metadata.
- `course_quiz`: per-module quiz payload and pass threshold.
- `enrollment`: now includes `paid`, `stripe_payment_intent_id`, `enrolled_at`.
- `module_progress`: watch-seconds and quiz score state.
- `curriculum_path` + `curriculum_requirement`: mandatory/optional path requirements by niche.
- `certificate`: supports `course` and `curriculum` certificates, plus public `verification_code`.
- `course_sale`: records paid-course gross/platform/partner split.
- `course_review`: admin approval decisions.
- `learning_fee_policy`: platform fee and Mux reserve percentages.

## Progress + anti-cheat rules
`POST /v1/learn/enrollments/{enrollment_id}/modules/{module_id}/progress`
- accepts `watch_seconds_delta` and `position_seconds`.
- max accepted delta is capped per request based on elapsed wall time (`max(30, elapsed+10)`).
- module is completed at >= 90% of duration, plus quiz pass when quiz exists.

## Certificates
- Course certificate issued after all modules complete.
- Curriculum certificate issued when all mandatory courses in active path are completed.
- Public verification endpoint: `GET /v1/learn/certificates/{verification_code}`.

## Revenue share
- Paid enrollment is created with a pending `stripe_payment_intent_id` placeholder.
- `POST /v1/learn/enrollments/{id}/pay` settles enrollment and writes `course_sale`.
- Split uses `learning_fee_policy`:
  - `platform_fee_percent`
  - `mux_cost_reserve_percent` (stored as sale metadata fields)

## API map
### User/pro
- `GET /v1/learn/curricula?niche=`
- `GET /v1/learn/courses?search=&niche=&pricing=`
- `GET /v1/learn/courses/{course_id}`
- `POST /v1/learn/courses/{course_id}/enroll`
- `POST /v1/learn/enrollments/{enrollment_id}/pay`
- `POST /v1/learn/enrollments/{enrollment_id}/modules/{module_id}/progress`
- `POST /v1/learn/enrollments/{enrollment_id}/modules/{module_id}/quiz`
- `GET /v1/learn/certificates/mine`
- `GET /v1/learn/certificates/{verification_code}`

### Partner
- `POST /v1/partner/learn/courses`
- `PUT /v1/partner/learn/courses/{course_id}`
- `POST /v1/partner/learn/courses/{course_id}/submit`
- `GET /v1/partner/learn/courses/mine`

### Admin
- `GET /v1/admin/learn/courses?status=`
- `POST /v1/admin/learn/courses/{course_id}/review`
- `GET /v1/admin/learn/partners`
- `POST /v1/admin/learn/partners`
- `GET /v1/admin/learn/sales?partner_id=`
- `GET /v1/admin/learn/fee-policy`
- `PUT /v1/admin/learn/fee-policy`

## Search + analytics
- Approved courses are indexed through existing `index.course.upsert` outbox flow.
- Added analytics namespace support for `learn.*` events.
- Emitted events include:
  - `learn.enrolled`
  - `learn.module_completed` (via completion flow)
  - `learn.course_completed`
  - `learn.curriculum_completed`
  - `learn.certificate_issued`
  - `learn.paid_course_purchased`

## Moderation hooks
- Course moderation uses admin review endpoint and `course_review` audit rows.
- Future trust/safety integration can consume module metadata and review notes.

