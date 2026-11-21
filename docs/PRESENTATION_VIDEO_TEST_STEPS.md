# "Meet the photographer" video: manual test steps (dev, fake Mux)

For the iOS simulators against dev, with the development fake Mux (BETA_SCOPE #37). The real Mux round trip is a separate check after the first deploy (DEPLOY_CHECKLIST section 4b).

**Before you start**
- In `api/.env`: `MUX_FAKE=true` and `PRESENTATION_VIDEO_ENABLED=true`. Then recreate the containers (`scratch/rebuild_dev.sh <sha>`, or in `api/`: `docker compose up -d --force-recreate api worker worker-photos beat`).
- Check the fake is on: `curl http://localhost:8000/v1/dev/fake-mux/status` answers `{"fake_mux":"on"}`.
- Put two test clips in the Pro simulator's Photos: `xcrun simctl addmedia 53D5B612-E29B-4180-828E-24DCF3325C03 ~/Developer/RAWWERS-work/scratch/fakemux/upload_12s.mp4 ~/Developer/RAWWERS-work/scratch/fakemux/long_65s.mp4`.
- Pro app as `pro1@rawwers.dev` (live); client app as a client in pro1's city.

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
