# Listing Card Discovery (Evidence-Based)

## Scope
Goal: implement Pro "Edit Listing Card" without adding new endpoints, using existing endpoints and schemas that already exist in this repository.

Target client-facing surfaces:
- `GET /v1/search/pros`
- `GET /v1/pros/{pro_user_id}/public`
- `GET /v1/client/pros/{pro_user_id}`

## Code Evidence

### A) Search card route and schema
- Route: `api/app/api/v1/search.py` (`@router.get("/search/pros", response_model=SearchResponse)`)
- Fallback payload keys: `api/app/api/v1/search.py` in `_pros_fallback(...)`
- Search schema: `api/app/schemas/search.py` (`SearchProsItem`)
- Search indexing doc (provider path): `api/app/services/search_indexing.py` (`build_pro_document`)

### B) Public pro profile route and schema
- Route: `api/app/api/v1/discovery.py` (`@router.get("/pros/{pro_user_id}/public", response_model=ProPublicProfileResponse)`)
- Schema: `api/app/schemas/discovery.py` (`ProPublicProfileResponse`)

### C) Client pro profile route and schema
- Route: `api/app/api/v1/client_launch.py` (`@router.get("/client/pros/{pro_user_id}", response_model=ClientProProfileResponse)`)
- Schema: `api/app/schemas/client_launch.py` (`ClientProProfileResponse`)

### D) Pro-editable sources
- Pro profile edit: `api/app/api/v1/pro_onboarding.py`
  - `GET /v1/pro/me/profile`
  - `PUT /v1/pro/me/profile`
  - schemas in `api/app/schemas/onboarding.py` (`ProProfileView`, `ProProfileUpdateRequest`)
- Packages edit:
  - `POST /v1/pro/me/packages`
  - `PUT /v1/pro/me/packages/{package_id}`
  - `POST /v1/pro/me/packages/{package_id}/disable`
- Niche edit:
  - `GET /v1/pro/niches/mine`
  - `PUT /v1/pro/niches/mine`
  - `GET /v1/niches`
- Portfolio niche tagging:
  - `POST /v1/pro/me/portfolio/{media_asset_id}/niches`
- Media pipeline:
  - `POST /v1/media/photos/uploads`
  - `POST /v1/media/photos/{media_asset_id}/complete`
  - `GET /v1/media/{media_asset_id}`

## Sample JSON (captured from route schemas/assemblers)

### 1) `GET /v1/search/pros` item
```json
{
  "id": "f6cb90f2-6f8f-4af3-9de8-c2f61f3f23f0",
  "display_name": "Studio Lumiere",
  "headline": "Cinematic wedding stories",
  "cover_media_asset_id": "1e5a6f2e-3b20-4dcb-9b7f-7d0a4078f65f",
  "city": "New York",
  "country": "US",
  "niche_slugs": ["weddings", "portraits"],
  "top_niche": "weddings",
  "price_min": 299.0,
  "price_max": 799.0,
  "avg_rating": 4.9,
  "review_count": 47,
  "completed_gigs_total": 128,
  "last_active_at": "2026-03-05T23:10:00+00:00"
}
```

### 2) `GET /v1/pros/{pro_user_id}/public`
```json
{
  "pro_user_id": "f6cb90f2-6f8f-4af3-9de8-c2f61f3f23f0",
  "display_name": "Studio Lumiere",
  "headline": "Cinematic wedding stories",
  "cover_media_asset_id": "1e5a6f2e-3b20-4dcb-9b7f-7d0a4078f65f",
  "bio": "Editorial + documentary hybrid approach.",
  "city": "New York",
  "country": "US",
  "styles": ["cinematic", "editorial"],
  "packages": [
    {
      "id": "3d9f7d76-e4f9-4f3e-a316-e4d5ca6ce70f",
      "title": "Base Package",
      "price": 299,
      "currency": "EUR",
      "included_photos": 20,
      "extra_photo_price": 15
    }
  ],
  "portfolio_photos": [],
  "portfolio_videos": [],
  "avg_rating": 4.9,
  "review_count": 47,
  "ranking_score": 432.12
}
```

### 3) `GET /v1/client/pros/{pro_user_id}`
```json
{
  "pro_user_id": "f6cb90f2-6f8f-4af3-9de8-c2f61f3f23f0",
  "display_name": "Studio Lumiere",
  "headline": "Cinematic wedding stories",
  "cover_media_asset_id": "1e5a6f2e-3b20-4dcb-9b7f-7d0a4078f65f",
  "bio": "Editorial + documentary hybrid approach.",
  "city": "New York",
  "country": "US",
  "styles": ["cinematic", "editorial"],
  "avg_rating": 4.9,
  "review_count": 47,
  "portfolio_photo_count": 12,
  "portfolio_video_count": 2,
  "packages": [
    {
      "id": "3d9f7d76-e4f9-4f3e-a316-e4d5ca6ce70f",
      "title": "Base Package",
      "price": 299,
      "currency": "EUR",
      "included_photos": 20,
      "extra_photo_price": 15
    }
  ],
  "portfolio_preview_asset_ids": ["1e5a6f2e-3b20-4dcb-9b7f-7d0a4078f65f"],
  "is_guest_view": false
}
```

## Dedicated Listing Card Resource?
Decision: **No**.

There is no dedicated `listingCard`/`searchCard`/`proCard` editable API resource. The listing card is a **derived view** composed from:
- `pro_profile` (`display_name`, `headline`, `city`, `country`, `styles`, `cover_media_asset_id`)
- `pro_package` (min package price anchor for "From €X")
- `pro_public_index` (rating/reviews counts, ranking, top niches, availability/completeness)
- reputation aggregates (`avg_rating`, `review_count`) via index recompute.

Derivation code path:
- `api/app/services/discovery_index.py` -> `recompute_pro_public_index(...)`
- read endpoints then stitch profile + index + package slices in:
  - `api/app/api/v1/search.py`
  - `api/app/api/v1/discovery.py`
  - `api/app/api/v1/client_launch.py`

## Listing Card Field Map

| UI field | Client-visible source endpoint + JSON key | Pro-edit source endpoint + JSON key | Notes |
|---|---|---|---|
| Display name | `/v1/search/pros` -> `display_name`; `/v1/pros/{id}/public` -> `display_name`; `/v1/client/pros/{id}` -> `display_name` | `PUT /v1/pro/me/profile` -> `display_name` | Directly editable. |
| City / area | `/v1/search/pros` -> `city`,`country`; `/v1/pros/{id}/public` -> `city`,`country`; `/v1/client/pros/{id}` -> `city`,`country` | `PUT /v1/pro/me/profile` -> `city`,`country` | Directly editable. |
| Headline | `/v1/search/pros` -> `headline`; `/v1/pros/{id}/public` -> `headline`; `/v1/client/pros/{id}` -> `headline` | `PUT /v1/pro/me/profile` -> `headline` | Added to search payload for parity. |
| Cover image | `/v1/search/pros` -> `cover_media_asset_id`; `/v1/pros/{id}/public` -> `cover_media_asset_id`; `/v1/client/pros/{id}` -> `cover_media_asset_id` | `PUT /v1/pro/me/profile` -> `cover_media_asset_id` | Minimal schema/model extension in existing endpoint, no new endpoint. |
| Niche tags | `/v1/search/pros` -> `niche_slugs`; `/v1/search/pros` -> `top_niche`; `/v1/client/discover` -> `top_niches` | `PUT /v1/pro/niches/mine` -> `niches[]` + `primary_niche_slug` | Controlled vocabulary from `GET /v1/niches`. |
| Pricing anchor (From price) | `/v1/search/pros` -> `price_min`; `/v1/client/discover` -> `min_price`; `/v1/pros/{id}/public` -> derive min from `packages[].price` | package mutations via `POST/PUT /v1/pro/me/packages...` | Current backend uses package base price as anchor; no dedicated per-photo/min-qty card fields. |
| Rating | `/v1/search/pros` -> `avg_rating`; `/v1/pros/{id}/public` -> `avg_rating`; `/v1/client/pros/{id}` -> `avg_rating` | N/A (read-only aggregate) | Derived from review/reputation/index. |
| Reviews count | `/v1/search/pros` -> `review_count`; `/v1/pros/{id}/public` -> `review_count`; `/v1/client/pros/{id}` -> `review_count` | N/A (read-only aggregate) | Derived aggregate. |
| Verified badge | Indirect from `kyc_status` / niche verification in index | N/A (admin/system) | Read-only for listing editor. |
| Availability hint | from `is_accepting_bookings` in index-derived discover/search results | `/v1/pro/me/activate` and profile completeness/package setup | Read-only in listing editor. |

## Editability Decision
- Listing Card is derived: **YES**.
- Save strategy: update underlying resources only.
- No `listing-card` write endpoint added.

## Minimal backend change required
Critical missing field for card customization was cover image pointer.
Implemented minimal change:
- Add `cover_media_asset_id` to `pro_profile`
- Expose through existing:
  - `PUT/GET /v1/pro/me/profile`
  - `GET /v1/search/pros`
  - `GET /v1/pros/{id}/public`
  - `GET /v1/client/pros/{id}`

Migration: `api/alembic/versions/20260305_0038_listing_card_cover_media.py`.

## Verify flow
After saving listing edits in Pro UI:
1. call `GET /v1/pros/{id}/public` and inspect `display_name/headline/cover_media_asset_id`.
2. call `GET /v1/search/pros` and find same pro by id; verify `display_name/headline/cover_media_asset_id` + price/rating fields.
3. call `GET /v1/client/pros/{id}` and verify profile parity.
