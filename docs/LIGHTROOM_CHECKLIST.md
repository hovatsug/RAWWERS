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

## P. The portfolio (plug-in 1.2.0)

Against dev, with pro1 signed in in the pro app. Build 1.2.0 first: `lightroom/build.sh --version 1.2.0 --target dev`, then in **File > Plug-in Manager** select RAWWERS > **Remove**, then **Add** the new `lightroom/build/rawwers.lrplugin`. Start with pro1 having **no niches** (the pro app has no niche screen; the niches are set up from Lightroom here). To start again from none on dev:

    docker exec api-postgres-1 psql -U postgres -d rawwers -c "DELETE FROM pro_niche WHERE pro_user_id = (SELECT user_id FROM user_account WHERE email = 'pro1@rawwers.dev')"

Have 6 JPEG-able photos ready, one of them very large (a pano or a 100 MP file exported at full size, over 25 MB).

P.1 Plug-in Manager.

**Expect:** RAWWERS **1.2.0**, Installed and running.

P.2 Library > **Publish Services** panel (left) > **Set Up...** next to **RAWWERS Portfolio** (or right-click the service > **Edit Settings...**).

**Expect:** the publish service dialog with a **RAWWERS Portfolio** section. If this Mac is not paired: a **Pairing code** field (pair as in 2.1-2.3; the same connection serves Export and Publish). Once connected, with no niches: "Connected. You have no niches yet. Choose one to add." and a menu **Add a niche...**. Only JPEG and sRGB offered.

P.3 Open the **Add a niche...** menu.

**Expect:** every niche (12 on dev), by name. Choose **Portraits**.

**Expect:** "Adding...", then "Added Portraits, your main niche." The line above becomes "Connected. Your niches: Portraits (main)." and the menu no longer lists Portraits.

P.4 From the same menu, choose **Weddings**.

**Expect:** "Added Weddings." (not main); "Connected. Your niches: Portraits (main), Weddings." Click **Save**.

P.5 In the panel the service shows **Portfolio (main niche)**. Right-click the service > **Create Published Collection...**, name it "Second niche".

**Expect:** a **RAWWERS** box with a **Niche** menu: Portraits (main), Weddings, then **Add a niche...**. **Create** stays disabled until a niche is chosen.

P.6 In that menu choose **Add a niche...**.

**Expect:** a dialog "Add a niche to your RAWWERS profile" with a menu of the niches pro1 does not have (no Portraits, no Weddings). **Cancel** first: nothing is added and the menu shows what it showed before. Choose **Add a niche...** again, pick **Food**, **Add**.

**Expect:** the dialog closes, the collection's niche is now **Food**, the note says "Added Food. The photos of this collection go there.", and the menu no longer ends with **Add a niche...** (3 niches, the most). **Create** is enabled. Click **Create**.

P.7 The maximum. Right-click the service > **Edit Settings...**.

**Expect:** "Connected. Your niches: Portraits (main), Food, Weddings. That is the most you can have (3)." and no **Add a niche...** menu. Create another published collection: its **Niche** menu lists the three niches and no **Add a niche...**. Cancel it.

P.8 (Optional) The server's refusal at the maximum. With the service settings open at 3 niches, nothing can be chosen, so lower the maximum while a menu is showing: first, on dev, remove Food again (`DELETE FROM pro_niche WHERE pro_user_id = (SELECT user_id FROM user_account WHERE email = 'pro1@rawwers.dev') AND niche_id = (SELECT id FROM niche WHERE slug = 'food')`), open **Edit Settings...** (the menu is back, 2 of 3), then set the maximum to 2:

    docker exec api-postgres-1 psql -U postgres -d rawwers -c "INSERT INTO onboarding_requirement (id, key, value) VALUES (gen_random_uuid(), 'niches_max', '{\"count\": 2}') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value"

and choose any niche from the menu.

**Expect:** "You can have at most 2 niches, and you have 2. To change one, remove a niche in the RAWWERS Pro app first." Nothing added. Put the maximum back to 3 (the same command with 3) and add Food again from the menu.

P.9 Drag 3 photos onto **Portfolio (main niche)** and 2 onto **Second niche**. Select the service, click **Publish**.

**Expect:** Lightroom's progress "Publishing N photos to RAWWERS", then for each collection a message "Published to RAWWERS - 3 photos sent to your RAWWERS portfolio (Portraits)..." (and 2 for Food). The photos move to **Published Photos**.


P.10 Pro app: **You > Portfolio**, pull to refresh after a minute.

**Expect:** the 5 new photos, newest first; the 3 tagged with the main niche, the 2 with the second. Open one full screen: it looks as a photo uploaded from the phone does.

P.11 On the client simulator: open pro1's profile.

**Expect:** the new photos in the portfolio, under their niches.

P.12 In Lightroom, click **Publish** again on the service with nothing changed.

**Expect:** nothing to publish (Lightroom shows no new or modified photos); nothing changes in the app.

P.13 Edit one published photo in Develop (e.g. exposure +1). It moves to **Modified Photos to Re-Publish**. Click **Publish**.

**Expect:** "1 photo sent..."; in the app, after a minute, the edited version is there and the old one is gone (still 5 photos, not 6).

P.14 Remove one photo from **Second niche** (select it > Delete key > **Remove**), then **Publish**.

**Expect:** the photo goes to **Deleted Photos to Remove**, then disappears from the collection after Publish; in the app the portfolio shows 4 photos. A photo uploaded from the phone is never removed by this (check one is still there if pro1 has any).

P.15 Drag the photo over 25 MB onto a collection (export settings: no resize, quality 100), **Publish**.

**Expect:** "Some photos were not published", naming it: "Larger than 25 MB. Export it smaller." Nothing new in the app.

P.16 (Optional) Publish more than 100 photos in one hour.

**Expect:** the first 100 go; after that the rest are listed as not published with the server's message "Too many requests", and publishing again an hour later sends them. Uploading from the pro app in the same hour still works (the app keeps its own 30 an hour).

P.17 Revoke this Mac in the pro app (part 7), then **Publish** a modified photo.

**Expect:** a message saying this Mac is no longer connected and to type a new pairing code in the publish service settings; nothing is sent. Re-pair via **Edit Settings...** on the service.

P.18 Plug-in 1.0.0 against this server (optional, needs the 1.0.0 build): Export To: RAWWERS still delivers to a gig, and the dialog says a newer plug-in is available.

## What to send back

The time for 40 photos (4.1), the time for P.9, any row where something differed, and the screenshots.
