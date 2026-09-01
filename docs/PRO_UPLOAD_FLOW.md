# PRO Upload Flow (Proofs)

## Sequence
1. Ensure gallery exists for gig
- `POST /v1/gigs/{gig_id}/proof-gallery`

2. Create upload target for each photo
- `POST /v1/media/photos/uploads`
- Expected response includes `media_asset_id` and upload target/presigned data.

3. Upload binary to storage target
- Use target URL/method/headers returned by step 2.

4. Mark upload complete
- `POST /v1/media/photos/{media_asset_id}/complete`

5. Attach uploaded media to gallery
- `POST /v1/proof-galleries/{gallery_id}/items`
- Payload includes media ids and ordering metadata.

6. Publish gallery
- `POST /v1/proof-galleries/{gallery_id}/publish`

7. Retrieve downloads/access state
- `GET /v1/proof-galleries/{gallery_id}/downloads`

## Recommended client-side safeguards
- Maintain local upload queue state: `queued -> uploading -> uploaded -> completed -> attached`.
- Retry failed step 3/4 with backoff.
- Block publish until all items are `attached`.
- Require confirmation before publish.

## Missing-field handling
- If upload target schema varies by provider, UI should treat it as opaque and render provider-specific execution from returned fields only.
