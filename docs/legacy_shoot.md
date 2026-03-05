# Legacy Shoot v1

RAWWERS Legacy Shoot is a premium product for high-emotion storytelling: curated booking, structured legacy brief, secure vault, and staged deliverables with explicit client approvals.

## Product Narrative

- Premium product code: `legacy_shoot`
- High-touch curation with admin-assisted pro assignment
- Default privacy posture: private by default, explicit opt-in for marketing

## Legacy Brief Schema (v1)

The `answers` payload must include:

- `identity`: object (must include `name`)
- `milestones`: list
- `people`: list
- `what_to_preserve`
- `desired_output`: object
- `reference_style`
- `boundaries`: list
- `consent_for_public_use`: boolean

Optional structured fields:

- `tone`: `cinematic|documentary|intimate|heroic|minimalist`
- `privacy_level`: `private|family_only|public_opt_in`

## Vault Privacy Model

Vault assets are private R2 objects exposed only via short-lived signed URLs.

Access allowed only for:

- legacy booking client
- assigned pro
- admin users

Every vault operation logs an audit event in `vault_access_log`:

- `view`
- `download`
- `upload`

## Workflow

1. Client checkout creates `gig` + `legacy_booking` + Stripe PaymentIntent.
2. Client submits legacy brief (`brief_submitted`).
3. Admin assigns eligible pro (or override).
4. Scheduling updates booking to `scheduled`.
5. Pro marks shoot done (`shoot_done` -> `edit_in_progress`).
6. Pro uploads vault drafts and submits review (`client_review`).
7. Client approves or requests changes.
8. Final approval on `final_delivery` marks booking `delivered`.

## Eligibility and Curation

Default eligibility rules in `premium_product.eligibility_rules`:

```json
{
  "min_tier": "elite",
  "niche": "portrait"
}
```

Admin can assign with `admin_override=true` when curation requires exceptions.

## Operational Runbook

- Monitor `legacy.*` analytics events for funnel health:
  - `legacy.checkout_started`
  - `legacy.paid`
  - `legacy.brief_submitted`
  - `legacy.pro_assigned`
  - `legacy.review_requested`
  - `legacy.delivered`
- Use admin endpoints for assignment/status and full vault audit review.
- For disputes, legacy gigs are tagged with `legacy_dispute_default=admin_review` in gig metadata.

## API Surface

Client:

- `POST /v1/legacy/checkout`
- `GET /v1/legacy/{legacy_booking_id}`
- `PUT /v1/legacy/{legacy_booking_id}/brief`
- `GET /v1/legacy/{legacy_booking_id}/vault`
- `POST /v1/legacy/{legacy_booking_id}/vault/{vault_item_id}/download`
- `POST /v1/legacy/{legacy_booking_id}/reviews/{review_id}/respond`
- `PUT /v1/legacy/{legacy_booking_id}/marketing-consent`

Pro:

- `GET /v1/pro/legacy/assigned`
- `POST /v1/pro/legacy/{legacy_booking_id}/mark-shoot-done`
- `POST /v1/pro/legacy/{legacy_booking_id}/vault/upload`
- `POST /v1/pro/legacy/{legacy_booking_id}/reviews/submit`

Admin:

- `GET /v1/admin/legacy/orders`
- `POST /v1/admin/legacy/{legacy_booking_id}/assign-pro`
- `POST /v1/admin/legacy/{legacy_booking_id}/set-status`
- `GET /v1/admin/legacy/{legacy_booking_id}/audit`
