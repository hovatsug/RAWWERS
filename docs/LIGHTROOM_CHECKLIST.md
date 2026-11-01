# Lightroom Classic plug-in: the owner's checklist

Click by click, on the Mac with Lightroom Classic 15 and the pro simulator (or a phone) signed in as `pro1@rawwers.dev`. About 30 minutes. Everything here is against the dev stack; nothing reaches a real client.

**Before you start**
- The dev API and photo worker run the branch's code, with migrations `0074` and `0075` applied.
- pro1 has a paid booking whose shoot time has passed, not yet sent to the client (the gig list shows it). If not, book one through the loop in `docs/STAGE1_LOOP.md` up to step 3.
- 40 JPEG photos in Lightroom (any 40; a collection named `RAWWERS test` makes it quicker).
- Build the plug-in from the repo root: `lightroom/build.sh --version 1.0.0 --target dev`. It runs the tests first and writes `lightroom/build/rawwers.lrplugin`, pointing at the dev API on this Mac (`http://localhost:8000`; set `RAWWERS_LIGHTROOM_API_URL_DEV` for another dev machine).

Write down anything that differs from **Expect**, with a screenshot.

## 1. Install

1.1 Lightroom Classic > **File > Plug-in Manager...** > **Add**. Choose `lightroom/build/rawwers.lrplugin`. **Done**.

**Expect:** "RAWWERS" in the list, **Installed and running**, no error, version 1.0.0.

## 2. Pair

2.1 In the pro app: **You** tab > **Settings** > **Connect Lightroom** > **Get a pairing code**.

**Expect:** a code like `ABCD-EFGH`, "It works once, until HH:MM (10 minutes)".

2.2 In Lightroom: select one photo > **File > Export...** > at the top, **Export To: RAWWERS**.

**Expect:** a **RAWWERS** section at the top saying "Not connected", a **Pairing code** field, and **This Mac is called**. In File Settings only **JPEG** is offered; in Color Space only **sRGB**. No "Export Location" section.

2.3 Type the code (any case, with or without the dash), change the Mac's name if you like, click **Connect**.

**Expect:** "Connected as Alex ..." (pro1's name). The code field disappears. A **Client** menu appears.

2.4 Back in the app, pull down on Connect Lightroom.

**Expect:** your Mac in **Connected devices**, "Last used" a moment ago, "plug-in 1.0.0".

2.5 Type the same code again in a second Mac or after Disconnect (optional).

**Expect:** "This code is not valid any more..." - a code works once.

## 3. The client list

3.1 Open the **Client** menu.

**Expect:** one row per gig waiting for photos: `First name + initial · date · package · N included · Waiting for photos`. Soonest shoot first. Nothing else about the client: no email, phone or address. A gig already sent to the client from the app is not there.

3.2 Click **Refresh**.

**Expect:** the list reloads without closing the dialog.

3.3 **Metadata** section.

**Expect:** **Remove Location Info** ticked (the plug-in sets it on first use; the SDK does not document this setting, so this step confirms it). Leave **Include** on **All Metadata**: copyright and contact go with each photo, the location does not.

## 4. Export 40 photos

4.1 Select the 40 photos > **File > Export...** > RAWWERS > choose the client > **Export**.

**Expect:** Lightroom's own progress bar at the top left, "Uploading 40 photos to RAWWERS", with "RAWWERS: N of 40 done" as it goes. Note how long it takes.

4.2 When it ends.

**Expect:** a summary: "40 photos uploaded, 0 skipped, already in the gallery, 0 failed", and "Nothing is shown to the client until you send the gallery from the RAWWERS Pro app."

4.3 In the app: **Gigs** > that gig > **Deliver photos**, pull down.

**Expect:** the 40 photos arriving as they are processed (about a minute). Nothing sent to the client: the app still offers **Send to client**.

## 5. Export again: all skipped

5.1 Export the same 40 to the same client.

**Expect:** quickly done; "0 photos uploaded, 40 skipped, already in the gallery". Still 40 in the app, not 80.

## 6. Wi-Fi off mid-export, then re-run

6.1 Select 40 *other* photos (or re-edit 10 of the first so they export differently), export to the same client, and after about 10 have gone, turn Wi-Fi off.

**Expect:** the export keeps trying for about a minute, then the summary names the photos that failed ("Could not reach RAWWERS ..."). It does not hang, and it does not loop forever.

6.2 Turn Wi-Fi on. Export the same selection again.

**Expect:** the ones that went before are skipped; only the missing ones upload. The app shows each photo once.

## 7. Revoke the device

7.1 In the app: Connect Lightroom > your Mac > **Revoke** > **Revoke**.

**Expect:** it leaves the list at once.

7.2 In Lightroom, export one photo to RAWWERS (or open the Export dialog).

**Expect:** "This Mac is no longer connected... Get a new pairing code in the RAWWERS Pro app (Settings > Connect Lightroom)", and the dialog shows the **Pairing code** field again. One message, no repeated errors.

7.3 Pair again with a new code (2.1-2.3).

**Expect:** connected again; the client list is back.

## 8. Restart Lightroom (optional)

8.1 Quit and reopen Lightroom, open Export > RAWWERS.

**Expect:** still "Connected as ..." without typing a code: the token is in the macOS keychain, not in a preset.

## What to send back

The time for 40 photos (4.1), any row where something differed, and the screenshots.
