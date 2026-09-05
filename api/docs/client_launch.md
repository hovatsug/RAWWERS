# Client Launch v1

## Enable a City for Clients
1. Ensure global flags:
- `client_browsing_enabled_global=true`
- `client_booking_enabled=true` (optional per launch phase)
- `guest_discovery_enabled` as needed
2. Enable city gate:
- `PUT /v1/admin/rollout/cities` with `is_client_browsing_enabled=true`
3. Validate:
- `GET /v1/client/access?country=PT&city=Lisbon`

## Recommended Rollout Sequence
1. Turn on browsing in one city with booking disabled.
2. Monitor discovery and profile-view quality.
3. Enable booking in the same city.
4. Monitor booking request rate, payment conversion, and disputes.
5. Expand to additional cities in waves.

## Anti-Scraping Knobs
- `public_read` rate limit bucket (Redis-backed).
- Guest mode via `guest_discovery_enabled`.
- Deep-pagination guard for guests on discovery.
- City gate + global flags to pause launch immediately.

## Funnel KPIs
- `discover_views`
- `pro_profile_views`
- `booking_requests`
- `payments_succeeded`
- `proofs_published`
- `extras_purchased`
- `disputes_opened`

Use:
- `GET /v1/admin/funnel/clients?start_at=...&end_at=...`
to track conversion rates:
- discover -> profile
- profile -> booking
- booking -> payment
