# Media Rights and Consent

## Entitlement model
- `gig_media_entitlement` governs access per gig/user/type.
- Entitlement types:
  - `view_proofs`: allows watermarked proof viewing.
  - `download_finals`: allows included final deliveries.
  - `download_extras`: adds extra final download allowance after upsell payment.
  - `share_link_manage`: allows creating share links.
- Entitlements are time-aware (`valid_from`, `valid_until`) and auditable via metadata.

## Consent levels
- Consent is stored in `gig_usage_consent` and versioned in `gig_usage_consent_event`.
- Levels:
  - `none`: no marketing usage.
  - `pro_marketing_only`: pro can use assets in approved channels.
  - `rawwers_marketing_only`: RAWWERS can use assets in approved channels.
  - `both_pro_and_rawwers`: both can use assets in approved channels.
- `scope.channels` can restrict channel-level use (for example: `website`, `social`, `ads`, `portfolio`).
- Snapshot is created at booking (`snapshot_at_booking=true`) and changes generate immutable events.

## Share-link security
- Public links use opaque random tokens.
- Only SHA-256 token hashes are stored (`token_hash`), with server-side pepper.
- Share links support:
  - strict scope (`proofs`, `finals`, `selected_only`)
  - expiration (`expires_at`)
  - view limits (`max_views`)
  - explicit revocation (`is_revoked`)
- Public endpoint is IP rate-limited.

## Watermark policy
- Watermarked previews are deterministic:
  - text template from config (default `RAWWERS`)
  - optional pro display-name suffix (`RAWWERS • {pro}`)
  - fixed bottom-right positioning with proportional padding
- Generated derivatives are stored privately and tracked in `media_derivative`.

## Signed URL strategy
- Raw storage keys are never returned to clients.
- Downloads/preview access always returns short-lived signed URLs.
- TTL is constrained to 60-300 seconds (default 120).
- Access events are logged in `media_access_log` (user/share-link context, derivative kind, action, hashed IP, user agent).
