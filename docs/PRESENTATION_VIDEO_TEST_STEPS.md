# "Meet the photographer" video: manual test steps (dev, fake Mux)

> **Dev stack only.** The fake Mux and `/v1/dev/fake-mux/*` exist only on a
> local API with `APP_ENV=development`; the Mac no longer runs one (from
> 2026-11-22). The test server has neither: there the video says "Video is
> not available right now" until Mux is set up for it
> ([MUX_LOCAL_WEBHOOKS.md](MUX_LOCAL_WEBHOOKS.md), "The test server"), and
> the check is then DEPLOY_CHECKLIST 4b, not this page. Steps 1 to 10 below
> still describe what the apps do; on the server, the ready video is your own
> clip, not the sample.

For the iOS simulators against dev, with the development fake Mux (BETA_SCOPE #37). The real Mux round trip is a separate check after the first deploy (DEPLOY_CHECKLIST section 4b).

**Before you start**
- In `api/.env`: `MUX_FAKE=true` and `PRESENTATION_VIDEO_ENABLED=true` (set on dev on 2026-11-21). Then recreate the containers (`scratch/rebuild_dev.sh <sha>`, or in `api/`: `docker compose up -d --force-recreate api worker worker-photos beat`).
- **How you know the fake is on:** `curl http://localhost:8000/v1/dev/fake-mux/status` answers `{"fake_mux":"on"}` (a 404 means off). In the app, an upload's address starts with `http://localhost:8000/v1/dev/fake-mux/`, and the ready video is always the same few coloured seconds whatever you uploaded. While the fake is on, dev's real Mux keys are not used at all.
- Put two test clips in the Pro simulator's Photos: `xcrun simctl addmedia 53D5B612-E29B-4180-828E-24DCF3325C03 ~/Developer/RAWWERS-work/scratch/fakemux/upload_12s.mp4 ~/Developer/RAWWERS-work/scratch/fakemux/long_65s.mp4`.
- Pro app as `pro1@rawwers.dev` (live); client app as a client in pro1's city.

**Recording in the app (checked 2026-11-21)**
- **Record a video** opens the app's own camera (front camera first, a switch button, "0:12 of 1:00", stops by itself at 60 seconds). It never records above 1080p:
  - **iOS:** 1080p, 30 fps, video 8 Mbit/s and sound 128 kbit/s: **about 61 MB for 60 seconds**, under the 100 MB limit.
  - **Android:** 720p, 30 fps, at the phone's own bit rate for 720p (the Android camera plugin ignores a set bit rate): usually **60-90 MB for 60 seconds**. 1080p would often be 100-150 MB, over the limit, so Android records 720p; clients are sent 720p at most anyway.
  - Before: the phone's camera screen (image_picker) at its "high" quality: 1080p on iOS, and on Android whatever the camera app chose, up to 4K.
  - The sizes are from the settings, **not measured on a phone**. Check one: record 60 seconds on each phone and look at the size in step 2's upload (Mux's asset, or the dev API log).
- The **simulator has no camera**: there, Record shows "The camera could not open…" with Close. Test recording on a real phone.
- **Choose a video** (the library) sends the file as it is: 4K, or 1080p "Most Compatible" over about 45 seconds, is over 100 MB and refused before anything is sent (LATER #82: compress on the phone).

**Switching to the real Mux later** (the real round trip in dev, before DEPLOY_CHECKLIST 4b)
1. In `api/.env` set `MUX_FAKE=false` (or delete the line), keep `PRESENTATION_VIDEO_ENABLED=true`, and check `MUX_TOKEN_ID`, `MUX_TOKEN_SECRET`, `MUX_SIGNING_KEY_ID`, `MUX_SIGNING_KEY_PRIVATE` and `MUX_WEBHOOK_SECRET` come from your Mux **Development** environment.
2. Mux's webhooks must reach dev: follow "Forwarding to the dev API" in `docs/MUX_LOCAL_WEBHOOKS.md`, and put that endpoint's secret in `MUX_WEBHOOK_SECRET`.
3. The phone uploads straight to Mux, so the simulator needs internet; playback comes from `stream.mux.com`.
4. Recreate the containers. **How you know it is real:** `curl http://localhost:8000/v1/dev/fake-mux/status` answers 404, a new upload appears in Mux (*Video > Direct Uploads*), and the ready video is your own clip.
5. Back to the fake: `MUX_FAKE=true`, recreate.

**Steps**
1. **Open the screen.** Pro app > Settings > Your work > **Your introduction video**. It says "No video yet." with **Choose a video** and **Record a video**.
2. **Upload.** Choose a video > pick the 12-second clip. A card shows **Uploading… N%** with a progress bar, then **Processing your video**.
3. **Ready.** Within about 10-30 seconds the screen shows the poster (the fake's sample image), "Clients see this video (12 seconds)." and the buttons Replace, Record a new video, Delete video. Tap the poster: the fake's sample clip plays (a few coloured seconds; it is the same sample whatever you uploaded).
4. **The client sees it.** Client app > Discover > pro1's profile: the "Meet …" section shows the poster with a play button. Nothing plays until you tap. Tap: the sample plays; tap again to pause.
5. **Replace.** Pro app > Replace with a video from your library > the 12-second clip again. While it uploads and processes, the note says clients still see the current video; the client profile still shows it. When ready, the new one replaces it.
6. **Too long.** Replace > the 65-second clip. The app says "Your video is longer than 60 seconds. Choose or record a shorter one." and nothing uploads.
7. **Delete.** Delete video > the dialog "Delete your video?" > Cancel keeps it; Delete removes it ("Video deleted."). The client profile no longer shows the video (pull to refresh).
8. **A photographer who is not live.** Use a photographer whose onboarding is not approved (for example a new photographer account) with a ready video: their profile is not reachable for clients, and if it were, no video is shown (the server only gives the video for a live photographer).
9. **A failed upload.** Turn the simulator's network off (or stop the API) while "Uploading…" shows: the screen says "The upload stopped. Check your connection and try again." with **Try again**; with the network back, Try again finishes the same upload.
10. **Mux not configured.** Set `MUX_FAKE=false` and empty `MUX_TOKEN_ID`, `MUX_TOKEN_SECRET`, `MUX_SIGNING_KEY_ID` and `MUX_SIGNING_KEY_PRIVATE` (dev's `.env` has the owner's real Mux keys in them: keep a copy to put back), recreate the API. The Pro app's screen shows only "Video is not available right now." with no buttons; the client profile shows no video section. Set it back to `true` afterwards.
