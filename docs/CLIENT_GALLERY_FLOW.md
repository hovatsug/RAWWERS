# CLIENT Gallery Flow

## Core gallery flow
1. Open gallery:
- `GET /v1/proof-galleries/{gallery_id}`
2. Save draft selection:
- `POST /v1/proof-galleries/{gallery_id}/selections`
3. Submit final selection:
- `POST /v1/proof-galleries/{gallery_id}/selections/submit`
4. If extras selected, start upsell payment:
- `POST /v1/proof-galleries/{gallery_id}/upsell/create-intent`
5. Download delivery assets:
- `GET /v1/proof-galleries/{gallery_id}/downloads`

## Gig-media fallback
When downloads are delivered as gig media:
- `GET /v1/gigs/{gig_id}/media`
- `GET /v1/gigs/{gig_id}/media/{media_asset_id}/signed-url`
- `GET /v1/gigs/{gig_id}/media/{media_asset_id}/download`

## Safe UX requirements
- Persist selection count and included/extras counters client-side.
- Confirm before final submit.
- Keep upsell checkout disabled when extras count is zero.
