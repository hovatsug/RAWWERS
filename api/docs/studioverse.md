# Studioverse v1

## Pack lifecycle
- Creator creates a draft pack under `/v1/studioverse/packs`.
- Creator can update while status is `draft` or `rejected`.
- Submission (`/submit`) validates license + consent rules and moves status to `submitted`.
- Admin review approves or rejects.
- Approval triggers `index.content_pack.upsert`; takedown/delist triggers `index.content_pack.delete`.

## Licensing
- Licenses live in `content_license` and are referenced by `content_pack.license_code`.
- Default licenses seeded:
  - `standard_personal`
  - `standard_commercial`
- License terms are stored in JSON for deterministic policy enforcement.

## Consent rules
- Pack sources are tracked in `pack_source_reference`.
- For `source_type=gig`, submission enforces:
  - `gig_usage_consent` exists for the same gig/pro.
  - `consent_level` satisfies `requires_consent_level`.
  - `evidence.derivative_only = true` is present.
- This blocks re-uploading protected client originals unless explicitly consented.

## Royalties and settlement
- Royalty split uses `royalty_rule` (default 80/20 creator/platform).
- On paid order:
  - entitlement is created in `content_pack_entitlement`
  - royalty row is created in `royalty_ledger_entry`.
- RAWW credits settlement uses reward ledger entries:
  - buyer debit (`spend`)
  - creator credit (`earn`)
  - platform treasury credit (`earn`).
- Refund reversal marks royalty entry as `reversed`, expires entitlement, and posts clawback/refund adjustments in rewards ledger.

## Moderation operations
- Admin list: `GET /v1/admin/studioverse/packs?status=`
- Admin review: `POST /v1/admin/studioverse/packs/{id}/review`
- Admin takedown: `POST /v1/admin/studioverse/packs/{id}/takedown`
- Admin actions are audit logged via `admin_audit_log`.

## Search index shape
- Index: `{SEARCH_INDEX_PREFIX}_content_packs`
- Fields:
  - `id`, `title`, `description`, `status`, `category`
  - `niche_slugs`, `tags`
  - `price_eur`, `price_raww`
  - `creator_name`, `rating`, `updated_at`

## Operational protections
- Rate limits:
  - checkout: `payments` bucket
  - list/detail/download: `public_read` bucket
- Abuse signals:
  - excessive download attempts beyond entitlement limit
  - suspicious refund patterns (service hook ready)
- Analytics emitted:
  - `studioverse.pack_submitted`
  - `studioverse.pack_approved`
  - `studioverse.purchase_succeeded`
  - `studioverse.download`
