# RAWWERS — Mux, and the photographer presentation video

One short introduction video per photographer, uploaded in the pro app, streamed through Mux, shown on the photographer's profile in the client app.

This is NOT a videography marketplace, NOT video for proofs or finals, and NOT live video. Those stay out of scope. Photo galleries keep using R2 exactly as they do today.

Discovery first, report, stop for approval. No code until approved. Follow the standing process: tests first with break checks, isolated database, no more than 3 parallel suites, by-name failure diff against `KNOWN_FAILURES.txt`, clean worktree per commit, byte-identical branch check, DEPLOY_CHECKLIST.md entries, a how-to-see note at the end.

---

## Credentials (the owner does this, not you)

The owner creates the Mux account and puts the values in `api/.env`:
`MUX_TOKEN_ID`, `MUX_TOKEN_SECRET`, `MUX_WEBHOOK_SECRET`, and signing key id and private key only if signed playback is chosen.

Rules for you:
- Never print these in logs, errors, API payloads or commit messages.
- Add settings for them, plus a feature flag `PRESENTATION_VIDEO_ENABLED` (default off outside dev).
- If the flag is on and a credential is missing, fail loudly at startup, not at first upload.
- Tests must never call real Mux. Add a conftest guard like the existing Stripe and R2 guards that refuses real Mux credentials during tests, and put a fake client behind an interface seam.

---

## Report first

1. **What Mux code already exists.** The upload path was found to send video to Mux, and a `video playback-token` route exists that no test calls. Report everything: client code, config, models with a video kind, routes, and what is dead, untested or wired to nothing. Don't assume.
2. **Data model.** Reuse the existing media model or add a dedicated table? Requirements: at most one active presentation per photographer, a status machine (awaiting upload, processing, ready, rejected, failed, removed), the Mux upload id, asset id and playback id, duration, `passthrough` carrying our internal id, moderation fields (hidden by whom and why), and timestamps. Recommend one and say why.
3. **Upload mechanism.** Check Mux's current docs for direct uploads: creating the upload URL, `new_asset_settings`, `cors_origin`, `passthrough`, timeouts, and chunked or resumable uploads from a mobile client. The video goes from the phone straight to Mux, never through our API. We already built stall timeouts and resumable parts for R2. Report whether that client logic can be generalized for Mux or whether a second uploader is genuinely needed. Don't build a second one without saying so.
4. **Limits and cost settings.** Propose and verify against current Mux docs: maximum duration (DECIDED: 60 seconds, with a small tolerance of about 2 seconds, because a phone recording that stops at "one minute" often lands slightly over; the client pre-check and the server-side rejection must share one limit and one tolerance, defined in a single place), maximum file size, accepted formats (iPhone HEVC), cost-minimizing asset settings (such as baseline video quality and a resolution cap). Mux can't cap duration at upload time, so report how an over-long video is rejected after processing (the webhook carries the duration): delete the asset, mark the status rejected, tell the photographer why. Also report a client-side pre-check on the picked file.
5. **Playback policy.** Public or signed playback? Report the tradeoffs: caching, removal and revocation, hotlinking, token lifetime, key management. My lean is public playback ids for this promotional video, with deleting the playback id and the asset as the revocation mechanism, because it behaves like public portfolio content. Signed playback is the later answer for any paid or private video. Recommend one and note that finals and proofs stay out of scope.
6. **Webhooks.** Signature verification (the `Mux-Signature` header, timestamp tolerance), idempotency on replays, and use of the existing outbox pattern. Events to handle: upload asset created, asset ready, asset errored, upload cancelled or errored, asset deleted. Local development can't receive webhooks, which is the same trap as `stripe listen`. Propose a polling reconciliation (a periodic job plus a fetch when the photographer opens the status screen) so nothing depends on the webhook, and document the tunnel option in `api/README.md` next to the Stripe note.
7. **Lifecycle and cost control.**
   - Replace: upload the new video, swap when it is ready, delete the old Mux asset.
   - Remove: delete the Mux asset.
   - Ban, deactivate, delist or account deletion: stop serving the video and delete the asset.
   - Abandoned uploads: a cleanup job.
   - Admin: hide and remove, with a reason, audited.
8. **Where it appears.**
   - Client profile: a poster frame with a play button in the identity block, no autoplay, sound only after a tap, fullscreen player. Report placement and confirm it doesn't crowd the portfolio and packages sections.
   - Pro app: pick or record (camera recording stops at the cap with a visible countdown; a video picked from the library is checked before upload, and a too-long one gets a clear message telling the photographer to trim it first), upload progress, then states Uploading, Processing, Ready, Rejected or Failed, using the existing state patterns, with preview, replace and remove, plus a "Before you record" guide screen (shown the first time, and reachable from the upload screen) using the copy in `rawwers-intro-video-guide.md`: the short version on the screen and the full guide behind "See the full guide". Report whether this copy can be updated from the server without an app release, or has to ship inside the build.
   - The listing preview screen must show exactly what clients will see.
   - Not on cards.
9. **Flutter playback.** Check `video_player` and any alternative. Do a dry run on a scratch copy first, given the earlier analyzer and codegen dependency conflict. Report the iOS and Android build impact and any camera, microphone or photo-library permission changes.
10. **Posters.** How the poster frame is obtained (Mux image URL with a time parameter), and reuse of the new disk cache for posters.
11. **Gating and fairness.**
    - Who may upload: live photographers only? The video is optional and must not become an onboarding gate.
    - It must NOT feed ranking or any row ordering. Prove it with a test, as with the response-time label.
    - Does it touch the completeness score? Recommend no.
12. **Rate limits and abuse.** Photographer role and live status required to create an upload, one upload in flight at a time, a daily cap, and rate limits on the creation endpoint.
13. **Plan and cost facts.** From Mux's current docs and pricing page, report the free plan's limits and the price of the first paid plan. As I understand it the free plan stores only a small number of videos, which covers dev and demo but not a beta with 100 photographers. Estimate storage and delivery for 100 and for 1,000 photographers at your proposed settings. Add the plan upgrade to the "blocks beta" list in DEPLOY_CHECKLIST.md.
14. **Which Mux environment to test against** (free plan environment, or the older test-mode flag, whose assets are clipped and watermarked), so the one real end-to-end check reflects a real presentation video.

## Build, after approval, in this order, with a report after each

1. Backend: settings and flag, the Mux client behind an interface with a fake, model and migration (up, down, up), create-upload, status and remove endpoints, the webhook handler, the reconciliation job, admin hide and remove, lifecycle cleanup.
2. Regenerated client.
3. Pro app.
4. Client app.
5. Demo data and docs. The seed can't create a real Mux asset without keys, so make it an optional script that uploads one short real asset when keys exist, and otherwise leave the profile without a video and explain how to add one.

## Verification

- Webhook: a bad signature is refused, a stale timestamp is refused, replays are idempotent, and a webhook that arrives out of order is handled.
- State machine: every legal transition, and illegal ones rejected.
- Removal and replace call the fake client's delete.
- A banned or delisted photographer's video is never returned in any payload.
- Over-duration video is rejected and deleted.
- Ranking and row order are unchanged by having a video.
- No secrets in logs or payloads, with a scan like the last-seen scan.
- One documented manual end-to-end run against real Mux with the owner's keys.
- Break checks on each rule, migration up/down/up, by-name failure diff against the 28.

## Constraints

- Don't touch payment, entitlement, proof, finals or R2 photo logic.
- No new vendor beyond Mux.
- Discovery report first. No commits until approved.
