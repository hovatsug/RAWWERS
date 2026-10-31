# RAWWERS: delivering photos from Lightroom Classic and by folder (discovery, report only)

Save this file verbatim as `docs/briefs/rawwers-delivery-lightroom-folders-prompt.md`, then do the task below.

## Why
The owner is a photographer. Pros edit in Lightroom Classic on a laptop and deliver 400+ photos per job. Picking photos one by one from a phone library does not scale. Two paths are wanted, in this order:
1. **First path:** a Lightroom Classic plugin. In the Export dialog the photographer chooses "Export To: RAWWERS", picks the gig, and exports.
2. **Second path:** the pro app's photo picker also supports folders.

Before building anything we need facts and a plan.

## Decisions already made (do not reopen)
1. This task is discovery only. Change no code.
2. The first path is a Lightroom Classic plugin as an export service provider (not a publish service yet).
3. Pro app only. The client app is not touched.
4. No change to pricing per photo, the selection flow, escrow, or any money logic.
5. Honest findings: say plainly what you could not verify. No secrets in the report (environment variable names only if needed).

## PART A: Discovery (report only; then stop and wait for approval)

### Today
1. **Today's delivery flow, end to end:** the app screens, API endpoints, how files reach storage (presigned URLs or through the API), the photo worker and its statuses, what "Processing" does and how long it takes per photo, derivatives and thumbnails. Limits: maximum photos per gallery, maximum file size, accepted formats, parallel uploads. What happens on a network failure, a lost connection, or the app being killed mid-upload.

### First path: Lightroom Classic plugin
2. **The delivery API for clients that are not the phone app, and what is missing:**
   - a one-time pairing code issued in the pro app;
   - a revocable token that can deliver only for that photographer;
   - listing that photographer's gigs that are waiting for delivery;
   - resumable multipart uploads against Cloudflare R2 (report what R2 supports);
   - idempotent uploads (for example by checksum), so a retry never duplicates a photo;
   - a progress and status endpoint;
   - size and rate limits.
   Typical load: 400 to 1000 JPEGs of 2 to 10 MB each.
3. **Lightroom Classic SDK facts (Lua):**
   - export service provider versus publish service, and what each allows;
   - HTTP and multipart upload support, background tasks, progress display, error handling and retry;
   - where to store a token safely;
   - how a plugin is installed and distributed (the .lrplugin folder, Plug-in Manager), SDK version compatibility, and whether signing is needed;
   - whether Lightroom (cloud) supports plugins at all.
   Verify against Adobe's current documentation. If the SDK or its docs cannot be fetched from here, say exactly what the owner must download.
4. **Testing without Lightroom:** a simulator script that makes the same calls as the plugin against the dev API, and a short manual test checklist the owner can run on his Mac with Lightroom Classic (you cannot run Lightroom).
5. **Security and abuse:** token scope, revocation, a leaked-token scenario, rate limits, size caps.
6. **What the platform expects from exports:** minimum resolution, colour space and format, and what a good export preset looks like for the plugin to suggest.

### Second path: folders in the phone app
7. **An in-app picker that supports folders.** Report both meanings of "folder":
   - (a) **Photos albums:** what the current picker allows, what a library-based picker allows (for example photo_manager with full-library permission, versus the system PHPicker's limits), and how a photographer could select all photos in an album.
   - (b) **Files-app folders:** a directory picker, and whether the picked folder gives the app the file access it needs to upload on iOS (security-scoped access) and on Android (scoped storage).
   For each: packages with pinned versions, licences and maintenance status; permissions and privacy implications (including the permission prompts and App Store review notes); behaviour with 400+ items (time, memory, battery); and your recommendation.

### Wrap-up
8. **A commit plan:** the delivery API foundation first, then the plugin, then the phone folders. For each: which parts change (API, worker, app, plugin), effort, risks.
9. **A "needs a decision from the owner" list.** Then stop.

## Process rules (as always)
Report only. Tests first with break checks when any build step starts. One commit per step. Clean worktree per commit. API suite only for commits that touch `api/`, run once on the whole branch before pushing. Push the branch, never `main`. No secrets in the repo or chat.

## Reporting
Tables for items 1 to 8, then the owner decisions, then stop.
