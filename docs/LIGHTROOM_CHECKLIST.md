# Lightroom Classic plug-in: the owner's checklist

## Against the test server (from 2026-11-22)

The Mac no longer runs the API, so the plug-in is built for the test server,
`https://api.rawwers.com`, and paired with a photographer on the server. The
parts below were written for the dev stack; read them with these changes:

| In the parts below | On the server |
|---|---|
| `pro1@rawwers.dev` | Your own test photographer (a `+pro1` address on the allowlist, docs/TEST_WORLD.md) |
| `lightroom/build.sh ... --target dev` | `tools/lightroom/build-for-server.sh` (below) |
| A paid booking from STAGE1_LOOP | A paid booking made on the server (docs/TEST_WORLD.md) |
| `docker exec api-postgres-1 psql ...` (P, P.10) | Not available. Skip that optional step, or remove the niche in the Pro app (part Q) |
| The pro simulator built from the branch | `tools/app/run-pro-server.sh` |

**1. Tell the server the newest plug-in is 1.2.5 (once, server).** The
server's secrets file does not set it yet, so the API says 1.2.3 (the code's
default). In `/opt/rawwers/.env.production` add the line
`LIGHTROOM_PLUGIN_LATEST_VERSION=1.2.5`, then:

```
deploy/scripts/dc up -d --force-recreate api
```

The minimum stays 1.0.0 (not set). The tagged copy of
`deploy/.env.production.example` gets the line from the next tag on; for
`deploy-test-1` it is this manual line.

**2. Build (Mac, repository root).** Docker Desktop must be running: the
build runs the plug-in's tests first in a small Lua 5.1 container. Quit
Docker afterwards.

```
tools/lightroom/build-for-server.sh
```

**You should see** `target: production   server: https://api.rawwers.com   version: 1.2.5`.
It calls `lightroom/build.sh --target production` unchanged (https only, not
this Mac) and writes `lightroom/build/rawwers.lrplugin`.

**3. Replace the dev plug-in (Lightroom).** The dev and server builds have
the same plug-in id, so Lightroom holds only one. **File > Plug-in Manager...**,
select RAWWERS, **Remove**, then **Add** `lightroom/build/rawwers.lrplugin`,
**Done**. **Expect:** RAWWERS, **Installed and running**, version 1.2.5.

**4. Pair again.** Tokens are kept per server address in the macOS
keychain, so the dev token is never sent to the server and the plug-in starts
"Not connected". In the Pro app (signed in on the server): **You > Settings >
Connect Lightroom > Get a pairing code**; in Lightroom, part 2 from 2.2.
**Expect:** "Connected as" your test photographer's name; in the app,
"plug-in 1.2.5" under Connected devices, and no "update available".

**Back to dev** (only if you run a local API again): Remove, then Add a
`--target dev` build; its token is still in the keychain.

Not verified: what the plug-in shows when it is newer than the server's
"latest" (the case before step 1). Do step 1 first.

Click by click, on the Mac with Lightroom Classic 15 and the pro simulator (or a phone) signed in as `pro1@rawwers.dev`. About 30 minutes. The parts below were written against the dev stack; against the test server, start with the section above. Nothing reaches a real client.

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

**Expect:** a summary: "40 photos are in the client's gallery: 40 new, 0 already there.", "0 failed", "The gallery now has 40 photos (N still processing).", and "Nothing is shown to the client until you send the gallery from the RAWWERS Pro app."

4.3 In the app: **Gigs** > that gig > **Deliver photos**, pull down.

**Expect:** the 40 photos arriving as they are processed (about a minute). Nothing sent to the client: the app still offers **Send to client**.

## 5. Export again: all already there (plug-in 1.2.4)

5.1 The delivery export run twice. Export the same 40 to the same client again (Lightroom renders them again, with a new export time in each file).

**Expect:** quickly done; "40 photos are in the client's gallery: 0 new, 40 already there." and "The gallery now has 40 photos." Still 40 in the app (**Gigs** > that gig > **Deliver photos**, pull down), not 80. Before 1.2.4 this put the 40 in a second time.

## 6. Wi-Fi off mid-export, then re-run

6.1 Select 40 *other* photos (or re-edit 10 of the first so they export differently), export to the same client, and after about 10 have gone, turn Wi-Fi off.

**Expect:** the export keeps trying for about a minute, then the summary names the photos that failed ("Could not reach RAWWERS ..."). It does not hang, and it does not loop forever.

6.2 The interrupted delivery export. Turn Wi-Fi on. Export the same selection again.

**Expect:** "40 photos are in the client's gallery: N new, M already there." with N + M = 40 (the ones sent before are not sent twice, a photo that was half-sent is finished), and "The gallery now has 80 photos" (40 from part 4, 40 from this selection). In the app each photo once; none stuck on "Uploading" after a few minutes.

## 6b. The same photo in two gigs (plug-in 1.2.4)

6b.1 Pick 3 photos already exported in part 4. Export them to a **different** client (another paid gig of pro1; pick it in the Client menu).

**Expect:** "3 photos are in the client's gallery: 3 new, 0 already there." In the app the 3 photos are in the second gig's **Deliver photos**, and still once each in the first gig's. The same photo in two gigs is allowed.

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

## P. The portfolio (plug-in 1.2.3)

Against dev, with pro1 signed in in the pro app. Build 1.2.3 first: `lightroom/build.sh --version 1.2.3 --target dev`, then in **File > Plug-in Manager** select RAWWERS > **Remove**, then **Add** the new `lightroom/build/rawwers.lrplugin`. Start with pro1 having **no niches** (the niches are set up from Lightroom here; since plug-in 1.2.5 the pro app has its own niches screen too, part Q). To start again from none on dev:

    docker exec api-postgres-1 psql -U postgres -d rawwers -c "DELETE FROM pro_niche WHERE pro_user_id = (SELECT user_id FROM user_account WHERE email = 'pro1@rawwers.dev')"

Have 6 JPEG-able photos ready, one of them very large (a pano or a 100 MP file exported at full size, over 25 MB).

P.1 Plug-in Manager.

**Expect:** RAWWERS **1.2.3**, Installed and running, no diagnostic messages. (1.2.0 could not save the publish service: Save stayed blocked even when connected. 1.2.2 fixes it; P.2, P.4 and P.5 check it.)

P.2 Save works on an already paired Mac, with no new code. On a Mac paired before (Export or an earlier plug-in; the pairing is kept in the keychain), after reloading the plug-in in P.1: Library > **Publish Services** panel (left) > **Set Up...** next to **RAWWERS Portfolio** (or, for a service that exists, right-click it > **Edit Settings...**).

**Expect:** first "Checking the connection to RAWWERS...", then, with no niches, "Connected. You have no niches yet. Choose one to add." and a menu **Add a niche...**. **No** Pairing code field, and the bottom of the window does **not** say "Can't Save Changes". **Save** is enabled (do not click it yet). Only JPEG and sRGB offered. If this Mac is not paired: "Not connected. Type the pairing code from the RAWWERS Pro app...", a **Pairing code** field, and "Can't Save Changes: Connect to RAWWERS first..."; pair as in 2.1-2.3 (the same connection serves Export and Publish) and expect the connected line above, with Save enabled.

P.3 Open the **Add a niche...** menu.

**Expect:** every niche (12 on dev), by name. Choose **Portraits**.

**Expect:** "Adding...", then "Added Portraits, your main niche." The line above becomes "Connected. Your niches: Portraits (main)." and the menu no longer lists Portraits.

P.4 From the same menu, choose **Weddings**.

**Expect:** "Added Weddings." (not main); "Connected. Your niches: Portraits (main), Weddings." Save is still enabled. Click **Save**.

**Expect:** the dialog closes and the service is saved (no "(not saved)"); it shows **Portfolio (main niche)**.

P.5 After Connect with a fresh code, Save works. In the pro app, **Settings > Connect Lightroom**, remove this Mac. In Lightroom, right-click the service > **Edit Settings...**.

**Expect:** "Not connected. Type a new pairing code: this Mac's pairing was removed or has expired...", a **Pairing code** field, no niche menu, and "Can't Save Changes: Connect to RAWWERS again: type a new pairing code from the RAWWERS Pro app." Save is disabled. Get a new code in the pro app, type it, click **Connect**.

**Expect:** "Connecting...", then "Connected. Your niches: Portraits (main), Weddings."; the Pairing code field goes away, "Can't Save Changes" goes away and **Save** is enabled. Click **Save**.

P.6 (Optional) Server unreachable. Turn Wi-Fi off (or stop the dev API: `docker stop api-api-1`), then **Edit Settings...**.

**Expect:** after up to a minute of retries, "Could not check the connection to RAWWERS. Check the internet connection, then click Check again.", a **Check again** button, no Pairing code field, never "Connected", and "Can't Save Changes: Could not reach RAWWERS to check the connection." Turn Wi-Fi on (or `docker start api-api-1`), click **Check again**: "Connected. ..." and Save enabled, with no new code. Cancel.

P.7 Right-click the service > **Create Published Collection...**, name it "Second niche".

**Expect:** a **RAWWERS** box with a **Niche** menu: Portraits (main), Weddings, then **Add a niche...**. **Create** stays disabled until a niche is chosen.

P.8 In that menu choose **Add a niche...**.

**Expect:** a dialog "Add a niche to your RAWWERS profile" with a menu of the niches pro1 does not have (no Portraits, no Weddings). **Cancel** first: nothing is added and the menu shows what it showed before. Choose **Add a niche...** again, pick **Food**, **Add**.

**Expect:** the dialog closes, the collection's niche is now **Food**, the note says "Added Food. The photos of this collection go there.", and the menu no longer ends with **Add a niche...** (3 niches, the most). **Create** is enabled. Click **Create**.

P.9 The maximum. Right-click the service > **Edit Settings...**.

**Expect:** "Connected. Your niches: Portraits (main), Food, Weddings. That is the most you can have (3)." and no **Add a niche...** menu. Create another published collection: its **Niche** menu lists the three niches and no **Add a niche...**. Cancel it.

P.10 (Optional) The server's refusal at the maximum. With the service settings open at 3 niches, nothing can be chosen, so lower the maximum while a menu is showing: first, on dev, remove Food again (`DELETE FROM pro_niche WHERE pro_user_id = (SELECT user_id FROM user_account WHERE email = 'pro1@rawwers.dev') AND niche_id = (SELECT id FROM niche WHERE slug = 'food')`), open **Edit Settings...** (the menu is back, 2 of 3), then set the maximum to 2:

    docker exec api-postgres-1 psql -U postgres -d rawwers -c "INSERT INTO onboarding_requirement (id, key, value) VALUES (gen_random_uuid(), 'niches_max', '{\"count\": 2}') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value"

and choose any niche from the menu.

**Expect:** "You can have at most 2 niches, and you have 2. To change one, remove a niche in the RAWWERS Pro app first." Nothing added. Put the maximum back to 3 (the same command with 3) and add Food again from the menu.

P.11 Drag 3 photos onto **Portfolio (main niche)** and 2 onto **Second niche**. Select the service, click **Publish**.

**Expect:** Lightroom's progress "Publishing N photos to RAWWERS", then for each collection a message "Published to RAWWERS - 3 photos are in your RAWWERS portfolio (Portraits): 3 new, 0 already there. ... Portraits now has 3 photos on RAWWERS." (and 2 for Food). The photos move to **Published Photos**.


P.12 Pro app: **You > Portfolio**, pull to refresh after a minute.

**Expect:** the 5 new photos, newest first; the 3 tagged with the main niche, the 2 with the second. Open one full screen: it looks as a photo uploaded from the phone does.

P.13 On the client simulator: open pro1's profile.

**Expect:** the new photos in the portfolio, under their niches.

P.14 In Lightroom, click **Publish** again on the service with nothing changed.

**Expect:** nothing to publish (Lightroom shows no new or modified photos); nothing changes in the app.

P.15 Publish the same photo twice (1.2.3). In **Published Photos** of **Portfolio (main niche)**, select 2 photos, right-click > **Mark to Re-publish** (Lightroom renders them again, with a new export time in each file), then **Publish**.

**Expect:** "2 photos are in your RAWWERS portfolio (Portraits): 0 new, 2 already there. Portraits now has 3 photos on RAWWERS." Both go back to **Published Photos**. In the pro app (pull to refresh) and on the client's view of pro1's profile (Portraits and All): no photo twice, no new "Processing" tile.

P.16 Publish after an interrupted upload. Drag 10 new photos onto **Portfolio (main niche)**, click **Publish**, and after 2 or 3 are done click the **X** on Lightroom's progress bar (or turn Wi-Fi off). Then (Wi-Fi back on) click **Publish** again.

**Expect:** the first run says "Stopped. Publish again to send the rest." (or names the photos it could not send, in plain words, never "current state"); the second says "10 photos are in your RAWWERS portfolio (Portraits): N new, M already there." with N + M = 10, and the total is 13. In the app: 13 photos in Portraits, none twice, none stuck on "Processing" after a few minutes, none labelled "Untagged".

P.17 The same photo in two niches. Drag one photo already published in **Portfolio (main niche)** onto **Second niche** (Food), **Publish**.

**Expect:** "1 photo is in your RAWWERS portfolio (Food): 1 new, 0 already there." In the app the photo is there twice: once under Portraits, once under Food (both show in All). This is allowed.

P.18 Edit one published photo in Develop (e.g. exposure +1). It moves to **Modified Photos to Re-Publish**. Click **Publish**.

**Expect:** "1 photo is in your RAWWERS portfolio (Portraits): 1 new, 0 already there."; in the app, after a minute, the edited version is there and the old one is gone (the count does not grow).

P.19 Remove one photo from **Second niche** (select it > Delete key > **Remove**), then **Publish**.

**Expect:** the photo goes to **Deleted Photos to Remove**, then disappears from the collection after Publish; in the app the portfolio shows 4 photos. A photo uploaded from the phone is never removed by this (check one is still there if pro1 has any).

P.20 Drag the photo over 25 MB onto a collection (export settings: no resize, quality 100), **Publish**.

**Expect:** "Some photos were not published", naming it: "Larger than 25 MB. Export it smaller." Nothing new in the app.

P.21 (Optional) Publish more than 100 photos in one hour.

**Expect:** the first 100 go; after that the rest are listed as not published with the server's message "Too many requests", and publishing again an hour later sends them. Uploading from the pro app in the same hour still works (the app keeps its own 30 an hour).

P.22 Revoke this Mac in the pro app (part 7), then **Publish** a modified photo.

**Expect:** a message saying this Mac is no longer connected and to type a new pairing code in the publish service settings; nothing is sent. Re-pair via **Edit Settings...** on the service.

P.23 Plug-in 1.0.0 against this server (optional, needs the 1.0.0 build): Export To: RAWWERS still delivers to a gig, and the dialog says a newer plug-in is available.

## Q. Niches and photos removed in the Pro app (plug-in 1.2.5)

Against dev at the branch's code (the API and the photo worker rebuilt with `scratch/rebuild_dev.sh`), with the 1.2.5 dev package installed (P.1's steps, with the 1.2.5 folder) and the pro app on the iOS simulator built from the same commit. Start from the end of part P: pro1 has Portraits (main), Weddings and Food; **Portfolio (main niche)** and **Second niche** (Food) have published photos.

Q.1 Plug-in Manager. **Expect:** RAWWERS **1.2.5**, Installed and running, no diagnostic messages.

Q.2 Pro app: **Settings > Your niches**. **Expect:** Portraits with **Main**, Food and Weddings with **Make main**; "You can have up to 3. You need at least 1."; no **Add a niche** button, and "You have the most niches you can (3). Remove one to add another."

Q.3 Remove **Food** (the **X** on its row). **Expect:** "Remove Food?" saying the photos tagged Food stay in the portfolio, the packages stay, and a Lightroom collection publishing to Food stops until another niche is chosen. Tap **Remove**. **Expect:** Food is gone from the list. (If pro1 has a booking in Food that is not finished: "You have a booking in Food that is not finished...", and Food stays.)

Q.4 In Lightroom, edit one photo of **Second niche** (Food) in Develop, then **Publish**. **Expect:** nothing is sent, and the message "This collection publishes to a niche that is no longer one of yours ("food"). Niches are removed in the RAWWERS Pro app. Nothing was sent. Edit the collection (right-click > Edit Collection) and choose another niche." The photo stays in **Modified Photos to Re-Publish**.

Q.5 Right-click **Second niche** > **Edit Collection...**. **Expect:** the Niche menu lists Portraits (main) and Weddings, and **Add a niche...** (2 of 3 now). Choose **Weddings**, **Save**, **Publish**. **Expect:** "1 photo is in your RAWWERS portfolio (Weddings): 1 new, 0 already there."

Q.6 Service settings: right-click the service > **Edit Settings...**. **Expect:** "Connected. Your niches: Portraits (main), Weddings." and the **Add a niche...** menu, with the text "Adds it to your RAWWERS profile. Remove niches in the RAWWERS Pro app: Settings > Your niches."

Q.7 Pro app: **Settings > Portfolio**, open a photo published from **Portfolio (main niche)**, tap **Remove from portfolio**. **Expect:** "Remove from portfolio?" with "This photo disappears from your profile and from Discover. It cannot be recovered." Tap **Remove**. **Expect:** the viewer closes, "Removed from your portfolio.", the photo is gone from the grid.

Q.8 In Lightroom, select **Portfolio (main niche)** and look at that photo (still in **Published Photos**). Open the **Comments** panel (right side of Library) and click its refresh. **Expect:** a comment from RAWWERS: "Removed from your RAWWERS portfolio in the RAWWERS Pro app, so it was not sent again. To publish it again, take it out of this collection, publish, then add it back." (Comments for a published collection may also refresh by themselves after a publish.)

Q.9 Edit that same photo in Develop, then **Publish**. **Expect:** it is **not** sent: the dialog says "1 photo not sent again: removed from your portfolio in the RAWWERS Pro app (<file name>). To publish one again, take it out of this collection, publish, then add it back." Lightroom also lists it as not published, with the same reason, and keeps it in **Modified Photos to Re-Publish**. In the pro app nothing new appears.

Q.10 Edit another photo of the same collection and **Publish**. **Expect:** it is replaced as before (P.18), and the dialog also says "1 photo of this collection was removed in the RAWWERS Pro app: shown as published here, but not on RAWWERS..." if the photo of Q.7 is still in the collection.

Q.11 Publish it again by choice: take the removed photo out of the collection (Delete key > **Remove**), **Publish** (it disappears; RAWWERS answers that it is gone already), then drag it back in and **Publish**. **Expect:** "1 photo is in your RAWWERS portfolio (Portraits): 1 new, 0 already there."; it is back in the app.

Q.12 The minimum (needs pro1 approved for the public, as on dev, and exactly 12 ready portfolio photos; skip otherwise). In the pro app try to remove one more photo. **Expect:** "Add another photo first, then remove this one. A live listing needs at least 12 photos." and the photo stays. Taking one out of a collection in Lightroom and publishing gives the same reason ("RAWWERS could not remove 1 photo(s): ...") and Lightroom keeps it in **Deleted Photos to Remove**.

## What to send back

The time for 40 photos (4.1), the time for P.11, any row where something differed (parts P and Q), and the screenshots.
