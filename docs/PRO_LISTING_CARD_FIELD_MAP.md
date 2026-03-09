# PRO Listing Card Field Map

Listing card is derived, not stored as one object.

## Editable fields and source mapping
- Display name
  - Source: pro profile
  - Read: `GET /v1/pro/me/profile`
  - Write: `PUT /v1/pro/me/profile`
- Headline / tagline
  - Source: pro profile
  - Read: `GET /v1/pro/me/profile`
  - Write: `PUT /v1/pro/me/profile`
- City / country
  - Source: pro profile
  - Read: `GET /v1/pro/me/profile`
  - Write: `PUT /v1/pro/me/profile`
- Cover image (media asset id)
  - Source: pro profile field `cover_media_asset_id` when available
  - Read: `GET /v1/pro/me/profile`
  - Write: `PUT /v1/pro/me/profile`
  - Fallback when absent in schema: first/most-recent portfolio media (derived UI behavior)
- Tags / niches
  - Source: pro niches
  - Read: `GET /v1/pro/niches/mine`
  - Write: `PUT /v1/pro/niches/mine`
- Pricing preview (from price)
  - Source: package pricing fields
  - Writes: `POST /v1/pro/me/packages`, `PUT /v1/pro/me/packages/{package_id}`
  - Formula: `fromPrice = pricePerPhoto * minPhotoQty`
  - Never entered as independent value
- Public verification
  - `GET /v1/pros/{pro_user_id}/public`
  - Optional parity check against `GET /v1/search/pros`

## Non-editable display fields
- Rating / review count
  - Display from public profile/search payload
  - No write endpoint in pro catalog
