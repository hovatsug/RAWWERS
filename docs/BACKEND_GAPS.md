# Backend gaps

Confirmed backend behavior that the Flutter rebuild (F-0–F-8) needs to design around or route around, rather than something to silently paper over client-side. Entries here are verified against the running API or its source, not assumed. Append as F-6/F-7 discovery turns up more (the original task brief calls for several: canonical chat route family, review-gates-download, `GET /v1/client/bookings` — none of those are independently confirmed yet, so they're not listed below until they are).

## `complete_photo_upload` is not idempotent

`POST /v1/media/photos/{media_asset_id}/complete` only succeeds while the asset's status is still `uploading` or `created`; it transitions to `processing` on success and rejects a second call with a 409 `invalid_state` (`api/app/api/v1/media.py`, `complete_photo_upload`).

**Why this matters on mobile specifically:** the classic bad-signal failure mode — the request reaches the server, the server processes it and returns 200, but the client never receives the response (connection drops, app backgrounds, timeout fires first) — leaves the client believing the call failed. If the app auto-retries in that state, the retry 409s even though the upload actually succeeded. Confirmed in F-3: `PhotoUploadService` deliberately calls `complete` at most once and never auto-retries it, surfacing the failure to the caller instead. A real fix (an idempotency key, or accepting a repeat call in the already-`processing`/already-`ready` state as a no-op success) would need to happen server-side; not in scope for the Flutter rebuild.
