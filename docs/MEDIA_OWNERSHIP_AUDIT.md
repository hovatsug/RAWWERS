# Media ownership audit (2026-11-18)

**Why.** Until 2026-11-18, `PUT /v1/pro/me/profile` accepted any photo id as the cover, including another photographer's. It was fixed in the cover job (BETA_SCOPE #74). This audit checks every other non-admin route that takes a photo, media, file or upload id from the caller, and records whether the caller is checked as allowed to use it.

**How.** I read the code of every router in `api/app/api/v1/`. I also looked at each request schema field and path parameter that names a media asset, upload, file, image, storage key or vault item. Admin routes were not audited and are listed at the end.

**Dev data.** Read-only queries on 2026-11-18 (`scratch/audit/holes.sql`) found no cross-owner reference anywhere. The counts were 0 for each of these:
- a profile cover that is not the photographer's own photo;
- a content pack's cover or previews that are not the creator's own;
- a pack file that points at a stored photo;
- a gallery item that is not the photographer's own;
- dispute or repair evidence that is not the sender's own;
- a review video that is not the reviewer's own;
- gear evidence that is not the photographer's own.

Dev has 0 content packs and 0 print orders.

Status values:
- **checked:** the caller's right to use the id is checked.
- **missing:** no such check.
- **partial:** some check, but the caller can still use media they should not.
- **n/a:** the route takes no media id, or the id comes from a signed source.

## Table

| Route | Id it accepts | Status | Where |
|---|---|---|---|
| `PUT /v1/pro/me/profile` | `cover_media_asset_id` | checked (fixed 2026-11-18) | `services/profile_cover.set_cover` |
| `PUT /v1/pro/me/portfolio/{media_asset_id}/cover` | path id | checked | `services/profile_cover.set_cover` |
| `POST /v1/pro/me/portfolio/{media_asset_id}/niches` | path id | checked (owner, portfolio photo or video) | `api/v1/pro_onboarding.py` `tag_portfolio_media_niches` |
| `DELETE /v1/pro/me/portfolio/{media_asset_id}` | path id | checked | `services/lightroom_portfolio.remove_own_photo` |
| `/v1/pro/me/packages*`, `/v1/pro/me/extra-image-price` (packages and add-ons) | none | n/a | — |
| `POST /v1/media/photos/uploads` | `gallery_id` | checked (the gallery's photographer, gallery open) | `api/v1/media.py` `_delivery_gallery_id` |
| `POST /v1/media/photos/{id}/complete`, `/upload-url`, `/multipart`, `/multipart/part-urls`, `GET /multipart/parts`, `/multipart/complete`, `/multipart/abort` | path id | checked (owner) | `api/v1/media.py` `_ensure_owner`, `_uploading_original` |
| `POST /v1/media/videos/{id}/playback-token` | path id, `playback_id` | checked (public or owner; the playback id must be this video's) | `api/v1/media.py` `_ensure_read_access` |
| `GET /v1/media/{id}` | path id | checked (public or owner) | `api/v1/media.py` `_ensure_read_access` |
| `POST /v1/proof-galleries/{id}/items` | `media_asset_ids` | checked (the gallery's photographer; their own photos) | `api/v1/proof_galleries.py` `add_gallery_items` |
| `POST /v1/proof-galleries/{id}/selections` | `media_asset_ids` | checked (the gallery's client; photos in the gallery) | `_validate_selected_items_belong_to_gallery` |
| `POST /v1/proof-galleries/{id}/addons` | `media_asset_ids` | checked (the client; photos in the gallery) | `services/selection_addons.start` |
| `GET /v1/gigs/{gig_id}/media/{id}/signed-url`, `/download` | path id, `kind`, `share_token` | checked (a participant; in the booking's gallery; the client's unlock rules). **Two gaps fixed 2026-11-20:** a share token served any copy, and a copy kind not named in the rules was served unchecked | `api/v1/media_rights.py` `_signed_url_response`, `_enforce_client_access` |
| `POST /v1/gigs/{gig_id}/share-links` | `media_asset_ids` | checked (participant with the share right; photos in the booking's gallery; the link shows watermarked previews only) | `api/v1/media_rights.py` `create_share_link` |
| `POST /v1/delivery/gigs/{gig_id}/uploads` | `gig_id` | checked (the device's photographer's gig) | `api/v1/delivery.py` `_open_gallery` |
| `/v1/delivery/uploads/{id}/url`, `/multipart*`, `/complete` | path id | checked (own plug-in upload) | `api/v1/delivery.py` `_own_delivery` |
| `GET /v1/delivery/galleries/{id}/status` | path id | checked | `api/v1/delivery.py` `delivery_status` |
| `POST /v1/delivery/portfolio/uploads` | `previous_id` | checked (only their own Lightroom photo is replaced) | `services/lightroom_portfolio.refuse_resending_removed`, `replaceable` |
| `DELETE /v1/delivery/portfolio/{id}` | path id | checked | `services/lightroom_portfolio.remove_own_photo` |
| `POST /v1/gigs/{gig_id}/review` | `video_media_asset_id` | checked (their own Mux review video, or one an admin owns) | `api/v1/reviews.py` `_validate_review_video_asset` |
| `POST /v1/disputes/{id}/messages` | `evidence_media_asset_ids` | checked (own, private) | `api/v1/disputes.py` `add_dispute_message` |
| `POST /v1/repairs/tickets` | `evidence_media_asset_ids` | checked (own) | `services/repair.validate_evidence_ownership` |
| `POST /v1/pro/me/gear-verifications` | `evidence_media_asset_id` | checked (own, gear evidence, ready) | `api/v1/gear_verification.py` |
| `POST /v1/gigs/{gig_id}/marketing-consent` | `media_asset_ids` | checked (the booking's client; photos in the offer) | `services/marketing_consent.grant` |
| `POST /v1/me/marketing-consents/withdraw`, `/renew` | consent ids | checked (own consents) | `services/marketing_consent.withdraw`, `renew` |
| `POST /v1/instructor/courses`, `PUT /v1/instructor/courses/{id}`, `POST /v1/instructor/modules/{id}/lessons` | thumbnail, intro and lesson video ids | checked (own) | `services/learning.validate_course_media_ownership` |
| `POST /v1/studioverse/packs`, `PUT /v1/studioverse/packs/{id}` | `cover_media_asset_id`, `preview_media_asset_ids` | **missing → fixed 2026-11-18** | `services/studioverse.own_pack_media` |
| `POST /v1/studioverse/packs`, `PUT /v1/studioverse/packs/{id}` | `pack_file_storage_key` (a raw storage key) | **missing, open; Studioverse off outside development since 2026-11-20** (see below) | `api/v1/studioverse.py` |
| `POST /v1/studioverse/orders/{id}/download` | order id | checked (buyer, paid, entitlement) | `api/v1/studioverse.py` |
| `POST /v1/legacy/{id}/vault/{vault_item_id}/download` | vault item id | checked (booking access; the item is the booking's) | `services/legacy_shoot.issue_vault_download` |
| `POST /v1/pro/legacy/{id}/vault/upload` | none (the server makes the key) | checked (assigned photographer or admin) | `services/legacy_shoot.issue_vault_upload` |
| `POST /v1/gigs/{gig_id}/prints/orders`, `PUT /v1/prints/orders/{id}` | `selected_media[].media_asset_id` | **partial, open; print routes off (`ecom_enabled`) since 2026-11-20** (see below) | `services/prints_fulfillment._validate_selected_media` |
| `/v1/pros/{id}/chats`, `/v1/chats/*` | none (text messages only) | n/a | — |
| `POST /v1/webhooks/mux` | asset and upload ids from Mux | n/a (the signature is verified) | `api/v1/webhooks.py` |

## Fixed

**A content pack's cover and previews (2026-11-18).** A creator could name any media id. The id was never turned into a URL, so no image leaked. But another photographer's photo named in a pack counted as "used in a content pack", and its real owner could then not remove it from their portfolio (`lightroom_portfolio.depended_on`).

Both ids must now be the creator's own uploads, not removed, and the cover must be a photo. Anything else is a 404, as with the profile cover.

The fix also found a 500: any pack sent with preview ids failed to save, because the ids were written to JSON as UUID objects. They are now stored as strings. Tests: `api/tests/test_studioverse_pack_media.py`.

**A share token stood in for paying (2026-11-20).** On `GET /v1/gigs/{gig_id}/media/{id}/signed-url` (and `/download`), the booking's client who sent a valid share token got whatever copy they asked for, `full_res` included, for any photo the link covered; a link of a gallery's proofs covers every proof. The token now gives the watermarked preview or the thumbnail only, as `GET /v1/share/{token}` does. No app sends a share token to this route.

**Copies not named in the rules were served unchecked (2026-11-20).** The client rules named the previews and the paid copies; any other kind (a banner's, a Shelf item's, the new card copy) fell through with no check. A photographer may put one of their portfolio photos in a client's gallery, so its card copy, unwatermarked, was reachable that way once it existed. Any other kind is now refused. Tests: `api/tests/test_card_copy.py`.

**The card copy (2026-11-20)** is made for portfolio photos only, never for a client's proof, and is served only through the cover resolvers, which take covers and portfolio photos (`media_urls.resolve_sized_image_urls`).

## Open, with a recommendation

**Studioverse `pack_file_storage_key`.** This is a raw storage key, taken as sent. Studioverse has no upload route for pack files, and its routes are mounted with no feature flag. It needs:
- a photographer whose profile is approved for the public;
- an admin's approval of the pack;
- a purchase.

With those, a buyer gets a signed download of whatever key the creator named. That could be another client's original.

An allowlist of key prefixes would not be enough, and a proper fix needs an upload route for pack files (a new flow). Studioverse is not in the beta (no app uses it).

**Done for the beta (owner, 2026-11-18; built 2026-11-20):** `studioverse_enabled` is off outside development; all Studioverse user routes (creator, marketplace, checkout, orders, download) answer as routes that do not exist, before any login check. Its admin routes stay. **Before Studioverse ever opens** (BETA_SCOPE #79): a pack-file upload that records the file as the creator's own media, and downloads only of that.

**Prints `selected_media`.** The client must be the booking's client, the booking must have its finals delivered, and the client must hold the finals-download entitlement. Each photo must be in the booking's gallery with a ready full-resolution copy.

It does **not** check that the photo is one the client unlocked (their selection or paid add-ons, `media_rights.unlocked_final_asset_ids`). A client could order a print of a photo they never chose or paid for, and its full-resolution file would go to the print partner.

The print store is LATER (BETA_SCOPE #39), and dev has no print orders. **Since 2026-11-20 every user print route answers 404 while `ecom_enabled` is off** (it is off by default everywhere). **Precondition before prints open** (owner, recorded in BETA_SCOPE #39): limit `selected_media` to `unlocked_final_asset_ids`. The prints test fixture needs a paid selection for that.

## Admin routes (listed, not audited)

- `/v1/admin/niche-banners/*`: banner uploads and the banner image's `media_asset_id`.
- `/v1/admin/store/products` (`images_media_asset_ids`).
- `/v1/admin/shelf/items/{id}/images/*`.
- `/v1/admin/marketing/consents/{id}/original` and `/v1/admin/marketing/uses` (the marketing library).
- `/v1/admin/studioverse/packs/*`.
- `/v1/admin/pros/{id}/review` (the portfolio and cover preview).
- `/v1/admin/gear-verifications*` (evidence links).
- `/v1/admin/legacy/*`.
- `/v1/admin/share-links/{id}/revoke`.
- `/v1/admin/prints/*`.
- The dev-only routes (`api/v1/dev_only.py`, which answer 404 outside development and test).
