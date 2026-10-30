# Stage 1 loop: one full test booking, on the simulator, in Stripe test mode

A click-by-click checklist for the owner. One person plays both sides: **Alex Lens** (`pro1@rawwers.dev`, the pro app on the iPhone 17 simulator) and a **client** (`client@rawwers.dev`, the client app on the iPhone 17 Pro simulator). Dev logins use the password `Passw0rd!`. No real money moves and no real people are involved.

The loop: payout setup → booking request → accept → test-card payment → delivery → selection (the booking completes) → review → earnings settle → payout request → admin approval → transfer.

**How to use it.** Every step ends with **Expect:** what you should see, or the exact stored value. A step has passed when what you see matches. If it does not, stop there and report the step number, what you saw and the time - do not work around it.

**Stored values** are read with the read-only queries in the box at each check. Run them from `api/`. They print statuses and amounts, never secrets.

---

## 0. Before you start

### 0.1 Nothing else heavy is running

The loop must **not** run while an API test suite is running. On 2026-10-28 a suite, a Flutter build and two simulators together pushed the Mac's load average to about 200. The app's requests then timed out before reaching the API ("Could not load your earnings.", "Could not check your payout setup.") and Stripe's form took two minutes to load.

Check that no suite is running:

    docker ps --format '{{.Names}}' | grep api-api-run

**Expect:** no output, except the long-running demo presence refresher if you started it (it is light). If a suite *is* running and must not be stopped, lower its priority first and keep it lowered during the loop:

    # the suite's pytest process (the container name is the api-api-run-... line above)
    docker exec <container> sh -c 'for d in /proc/[0-9]*; do case "$(tr "\0" " " < $d/cmdline 2>/dev/null)" in *pytest*) renice -n 19 -p ${d#/proc/};; esac; done'
    # its database connections (run again if the suite opens new ones)
    for p in $(docker exec api-postgres-1 psql -U postgres -At -c "select pid from pg_stat_activity where datname like 'rawwers\_%\_test'"); do docker exec -u postgres api-postgres-1 renice -n 19 -p $p; done

Also: no Flutter builds or Flutter suites during the loop.

### 0.2 The dev stack

    cd api
    docker compose up -d
    docker compose ps --format '{{.Service}} {{.Status}}'

**Expect:** `api` (healthy), `worker`, `beat`, `postgres` (healthy), `redis` (healthy) all `Up`.

The dev API must be built from this branch (it bakes the code into the image). After pulling, or if unsure:

    docker compose build api worker && docker compose up -d --no-deps api worker

Check it serves this branch's status endpoint shape and the return pages:

    curl -s -o /dev/null -w '%{http_code}\n' "http://$(scutil --get LocalHostName).local:8000/v1/payouts/connect/return"

**Expect:** `200`.

`api/.env` (dev, untracked) must point `CONNECT_RETURN_URL` and `CONNECT_REFRESH_URL` at the Mac's `.local` address on port 8000 (`http://<this Mac>.local:8000/v1/payouts/connect/return` and `/refresh`). Check by name only:

    grep -cE '^CONNECT_(RETURN|REFRESH)_URL=http://.*\.local:8000/v1/payouts/connect/(return|refresh)$' .env

**Expect:** `2`.

### 0.3 Stripe webhook forwarding

`stripe listen` forwards Stripe's test-mode events (payments, transfers, and `account.updated` from connected accounts) to the dev API. It reads the test key from `api/.env` through the environment, so the key never appears on a command line; the `grep` hides the signing secret it prints.

    cd api
    STRIPE_API_KEY="$(grep -E '^STRIPE_SECRET_KEY=' .env | cut -d= -f2-)" \
      stripe listen \
        --events payment_intent.succeeded,payment_intent.payment_failed,payment_intent.canceled,charge.refunded,charge.refund.updated,refund.created,refund.updated,refund.failed,charge.dispute.created,transfer.created,transfer.reversed,account.updated \
        --forward-to localhost:8000/v1/webhooks/stripe \
        --forward-connect-to localhost:8000/v1/webhooks/stripe \
      2>&1 | grep --line-buffered -v whsec_

Leave it running in its own terminal.

**Expect:** `Getting ready...`, then nothing until events arrive (the `Ready!` line contains the secret and is hidden). During the loop each event shows as a `-->` line followed by `<-- [200] POST http://localhost:8000/v1/webhooks/stripe`. A `[400]` means the signing secret it uses differs from `STRIPE_WEBHOOK_SECRET` in `api/.env`; it matched on 2026-10-28.

The key in `api/.env` must be a test key (it starts with `sk_test_`). Check without printing it:

    grep -cE '^STRIPE_SECRET_KEY=sk_test_' .env

**Expect:** `1`. If it prints `0`, stop: never run the loop with a live key.

### 0.4 Dev only: settle earnings at once

> **DEV DATA CHANGE ONLY. NEVER DO THIS IN PRODUCTION. RESTORE IT AFTER THE LOOP (step 12).**
>
> Earnings normally wait `settlement_delay_days` (7) before they can be withdrawn. For the loop we set it to 0 on the dev database, so the booking's earning can be paid out the same evening.

The web admin has **no screen** for the fee policy. Its API (`PUT /v1/admin/finance/fee-policy`) replaces **every** fee field it takes, so changing only the delay safely means: read the whole policy, save it, change that one field, send every field back, and read it again to check. `docs/stage1-loop/fee_policy_delay.py` does exactly that, and `restore` (step 12.1) puts the saved values back the same way.

- **Safeguards:** it accepts only a dev API (localhost or a `.local` host), and it refuses to run twice without a restore in between.
- **What it asks for:** the admin password (`Passw0rd!`), which is not echoed. The admin API key is read from `web/.env.local` into the environment, so it never appears on a command line. No key, password or token is ever printed.
- **The saved copy:** `~/.rawwers/fee-policy-before-stage1-loop.json`, outside the repo. It holds only fee percentages and day counts, no secrets.

First, the whole row as it is now (one row; this includes three columns the API does not touch). Keep this output: step 12.1 compares against it.

    cd api
    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select id, fee_percent_gigs, fee_percent_extras, fee_percent_studioverse, settlement_delay_days, dispute_hold_days, retained_percent, pro_raww_percent, max_client_credit_percent from platform_fee_policy"

**Expect:** one line, `<id>|20|20|20|7|14|15|5|10` on 2026-10-29.

Then set the delay to 0 (from the repo root):

    cd ..
    RAWWERS_ADMIN_API_KEY="$(grep -E '^ADMIN_API_KEY=' web/.env.local | cut -d= -f2-)" \
      python3 -I docs/stage1-loop/fee_policy_delay.py set0

**Expect:**

    Password for admin@rawwers.dev:
    before: fee_percent_gigs=20, fee_percent_extras=20, fee_percent_studioverse=20, settlement_delay_days=7, dispute_hold_days=14
    saved to /Users/<you>/.rawwers/fee-policy-before-stage1-loop.json
    now: fee_percent_gigs=20, fee_percent_extras=20, fee_percent_studioverse=20, settlement_delay_days=0, dispute_hold_days=14
    OK: settlement_delay_days is 0, every other field unchanged.

Any line starting `STOP:` means nothing more was changed after that point. Read the message, and do not carry on with the loop until it is resolved.

Do this **before step 6**: an earning's "available from" time is fixed when it is recorded (when the client confirms their selection), from the delay in force at that moment. An earning recorded while the delay was 7 keeps its 7 days.

### 0.5 The simulators

    xcrun simctl boot 53D5B612-E29B-4180-828E-24DCF3325C03   # iPhone 17: pro app
    xcrun simctl boot BE71B153-80FA-4330-AE99-C790F6A62E07   # iPhone 17 Pro: client app
    open -a Simulator

Both apps must be built from this branch. The pro app at least must include B2 and B3 (the payout return link and the setup states):

    cd app
    flutter build ios --simulator --debug --flavor pro -t lib/main_pro.dart --dart-define-from-file=env/pro.json
    xcrun simctl install 53D5B612-E29B-4180-828E-24DCF3325C03 "build/ios/iphonesimulator/RAWWERS Pro.app"
    flutter build ios --simulator --debug --flavor client -t lib/main_client.dart --dart-define-from-file=env/client.json
    xcrun simctl install BE71B153-80FA-4330-AE99-C790F6A62E07 build/ios/iphonesimulator/RAWWERS.app

(Do this before step 0.1's "nothing heavy" applies - each build takes a few minutes and loads the Mac.)

**Expect:** both apps open on their sign-in screen or, if already signed in, on You (pro) and Discover (client).

---

## 1. Payout setup (the pro)

On the **iPhone 17**, in **RAWWERS Pro**, signed in as `pro1@rawwers.dev`.

**1.1** Tap **You**, then the gear icon (**Settings**), then **Getting paid**.

**Expect** one of these on the Payouts screen:

| What it says | Means | Next |
|---|---|---|
| **Payouts are set up**, chip **Ready** | pro1 finished onboarding (it did on 2026-10-28) | Skip to **1.5** |
| **You can't be paid yet** · button **Set up payouts** | no Stripe account yet | 1.2 |
| **Setup isn't finished** · **Still needed** list · **Continue setup** | started, not submitted | 1.2 |

![Not started](stage1-loop/payouts-not-started.png) ![In progress](stage1-loop/payouts-in-progress.png)

**1.2** Tap **Set up payouts** (or **Continue setup**). Stripe's form opens in a sheet *inside* the app.

**Expect:** a Stripe page titled for RAWWERS, in a sheet with **Done** at the top. Stay in the sheet: **do not tap the compass ("Open in Safari") button** - Stripe's setup links work once, and reopening one in Safari lands on "This setup link expired" (seen on 2026-10-28).

**1.3** Fill in Stripe's test-mode form (values from Stripe's test-mode documentation; any other test value works the same):

| Field | Enter |
|---|---|
| Phone | `000 000 0000`, SMS code `000000` (or tap Stripe's "Use test code") |
| Email | any address |
| Name | any |
| Date of birth | `01/01/1901` (verifies instantly in test mode) |
| Address line 1 | `address_full_match`, any Lisbon city and postcode |
| ID number, if asked | `000000000` |
| Website, if asked | `https://accessible.stripe.com` |
| Bank (IBAN) | `PT50000201231234567890154` |

Accept and submit. Work steadily: a setup link left open for about 13 minutes expired twice on 2026-10-28. If you see **This setup link expired**, tap **Back to RAWWERS Pro**, then **Continue setup** for a fresh one.

**1.4** Stripe shows its last page, then **You can go back to the app**. Tap **Back to RAWWERS Pro**, then **Open**.

![Return page](stage1-loop/connect-return-page.png) ![Expired link page](stage1-loop/connect-refresh-page.png)

**Expect:** the sheet closes and you are back on the **same Payouts screen** (never an error page). The setup card shows a moment's spinner on its button, then **Payouts are set up** with **Ready**. If Stripe is still checking, it says **Stripe is checking your details** - wait a minute and tap **Check again**.

If it says **Couldn't check your payout setup. Check your connection and try again.**, tap **Try again** (Stripe calls from this network sometimes take 10-20 seconds).

![Under review](stage1-loop/payouts-under-review.png) ![Error](stage1-loop/payouts-error.png)

**1.5 Check: the screen and the stored status agree.**

    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select pa.status, pa.payout_method from payout_account pa join user_account u on u.user_id = pa.pro_user_id where u.email = 'pro1@rawwers.dev'"

**Expect:**

| Payouts screen | Stored (`status|payout_method`) |
|---|---|
| **Payouts are set up**, **Ready** | `active|stripe_connect` |
| **Stripe is checking your details** | `pending_verification|stripe_connect` |
| **Setup isn't finished** / **Stripe needs something else from you** | `pending_verification|stripe_connect` |

**If the screen and the stored value do not match this table, STOP the loop and report both.** They come from one server mapping, so a mismatch is a bug, not a timing issue (the screen re-reads Stripe each time it opens, and stores what it reads).

Continue only with **Ready** / `active`.

---

## 2. Booking request (the client)

On the **iPhone 17 Pro**, in **RAWWERS**, signed in as `client@rawwers.dev`.

**2.1** On **Discover**, find **Alex Lens** (search, or a city row) and open the profile.

**2.2** Pick a package and tap **Request this package**. Pick a date and time from the calendar, fill **Where is the shoot?**, and tap **Send request**.

Choose a package whose price is **at least €15**: payouts start at €50.00, Alex already has €41.95 ready to withdraw, and roughly a quarter of the price goes to the platform fee and credits.

**Expect:** the request is sent and appears under **Bookings** as waiting for the photographer.

---

## 3. Accept (the pro)

**3.1** In RAWWERS Pro, tap **Requests**. The new request is at the top. Tap **Accept**.

**Expect:** the request moves to accepted.

    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select g.status from gig g join user_account u on u.user_id = g.pro_user_id where u.email = 'pro1@rawwers.dev' order by g.created_at desc limit 1"

**Expect:** `accepted` or `payment_pending`.

---

## 4. Payment (the client)

**4.1** In RAWWERS, tap **Bookings**, open the booking. It says **Payment due**. Tap **Pay now**.

**4.2** In Stripe's payment sheet, enter card **`4000 0000 0000 0077`**, expiry any future date (e.g. `12/34`), CVC `123`, any postcode. Pay.

This test card puts the money straight into the platform's *available* test balance, so the transfer in step 10 has funds.

**Expect:** **Payment sent. This updates as soon as it clears.**, then the booking shows as confirmed. In the `stripe listen` terminal: `--> payment_intent.succeeded` and `<-- [200]`.

    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select g.status from gig g join user_account u on u.user_id = g.pro_user_id where u.email = 'pro1@rawwers.dev' order by g.created_at desc limit 1"

**Expect:** `paid`. The money is now held by the platform; nothing is in Alex's Wallet yet.

---

## 5. Delivery (the pro)

**5.1** In RAWWERS Pro, tap **Gigs**, open the new gig, then **Deliver photos**.

**5.2** Tap **Add photos** and pick several from the simulator's photo library (it has sample photos). Wait until none says **Processing**.

**5.3** Tap **Send to client**, and confirm **Send these to your client?**.

**Expect:** the gallery shows as **Delivered**.

---

## 6. Selection (the client) - the booking completes here

Step 0.4 (delay 0) must be done before this step.

**6.1** In RAWWERS, open the booking under **Bookings**. Tap **Choose your photos**.

**6.2** Tap photos to choose them. Choose **no more than the package includes**: the button then reads **Confirm selection**, not **Pay €…** (choosing more asks for an extra payment, which is fine but adds steps).

**6.3** Tap **Confirm selection**, then confirm **Confirm your selection?**.

**Expect:** the booking shows the photos as yours to keep (**View your photos**).

    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select g.status from gig g join user_account u on u.user_id = g.pro_user_id where u.email = 'pro1@rawwers.dev' order by g.created_at desc limit 1"
    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select e.status, e.net_eur, e.available_at <= now() as due from earnings_ledger_entry e join user_account u on u.user_id = e.pro_user_id where u.email = 'pro1@rawwers.dev' order by e.created_at desc limit 1"

**Expect:** `completed`, then `pending|<net amount>|t` - Alex's earning exists, is still pending, and is already due (`t`) because the delay is 0. If the last column is `f`, step 0.4 was done too late: the earning waits 7 days; the loop cannot finish tonight.

---

## 6b. More photos than the package includes (optional: two bookings)

Run the loop twice. **Booking 1** takes exactly what the package includes, so nothing more is charged. **Booking 2** takes more, so the client pays a second, smaller charge at selection (a *difference* payment). Each booking goes through steps 2 to 11. Only steps 5 and 6 change, as described below.

The fee policy stays at a delay of 0 (step 0.4) through **both** bookings. Restore it (12.1) only after booking 2.

**Uploads.** Delivery uploads normally count against a limit of 30 per hour. For this loop, `api/.env` sets `RATE_LIMIT_UPLOADS_PER_HOUR=200` (dev only, untracked, set 2026-10-30). Step 12.3 removes it. Check it is active (from `api/`):

    docker compose exec -T api python -c "from app.services.rate_limit import RATE_LIMIT_RULES as r; print(r['uploads'])"

**Expect:** `(200, 3600)`.

### 6b.1 The package and its price

Alex has one package. Book it both times.

| | |
|---|---|
| Package | **Portraits Starter** (60 min) |
| Price per photo (entry rate) | €4.80 (the package's `price`) |
| Photos included | 20 |
| Niche and tier | portraits, rookie (the tier only sets which per-photo prices Alex may charge; the curve belongs to the niche) |
| Curve | exponential, k = 0.08, floor 15% of €4.80 = **€0.72** |

The price of the n-th photo:

- photos 1 to 10: €4.80 each;
- photo n > 10: the larger of €0.72 and 4.80 × e^(-0.08 × (n - 10)).

The total for N photos adds the unrounded prices of photos 1 to N and rounds once, to the cent, at the end. The client pays the total for 20 when booking. At selection the app charges *total(N) - total(20)*. Choosing fewer than 20 refunds the difference instead.

Photos 1 to 10 come to 10 × 4.80 = **48.00**. From photo 11 on:

| n | e^(-0.08(n-10)) | 4.80 × that | price of photo n | running total | rounded |
|---|---|---|---|---|---|
| 11 | 0.923116 | 4.430958 | 4.430958 | 52.430958 | 52.43 |
| 12 | 0.852144 | 4.090290 | 4.090290 | 56.521249 | 56.52 |
| 13 | 0.786628 | 3.775814 | 3.775814 | 60.297062 | 60.30 |
| 14 | 0.726149 | 3.485515 | 3.485515 | 63.782578 | 63.78 |
| 15 | 0.670320 | 3.217536 | 3.217536 | 67.000114 | 67.00 |
| 16 | 0.618783 | 2.970160 | 2.970160 | 69.970274 | 69.97 |
| 17 | 0.571209 | 2.741804 | 2.741804 | 72.712078 | 72.71 |
| 18 | 0.527292 | 2.531004 | 2.531004 | 75.243081 | 75.24 |
| 19 | 0.486752 | 2.336411 | 2.336411 | 77.579492 | 77.58 |
| **20** | 0.449329 | 2.156779 | 2.156779 | 79.736271 | **79.74** (paid at booking) |
| 21 | 0.414783 | 1.990958 | 1.990958 | 81.727229 | 81.73 |
| 22 | 0.382893 | 1.837886 | 1.837886 | 83.565115 | 83.57 |
| 23 | 0.353455 | 1.696582 | 1.696582 | 85.261698 | 85.26 |
| 24 | 0.326280 | 1.566143 | 1.566143 | 86.827841 | 86.83 |
| 25 | 0.301194 | 1.445732 | 1.445732 | 88.273573 | 88.27 |
| 26 | 0.278037 | 1.334579 | 1.334579 | 89.608152 | 89.61 |
| 27 | 0.256661 | 1.231972 | 1.231972 | 90.840124 | 90.84 |
| 28 | 0.236928 | 1.137253 | 1.137253 | 91.977377 | 91.98 |
| 29 | 0.218712 | 1.049817 | 1.049817 | 93.027194 | 93.03 |
| **30** | 0.201897 | 0.969103 | 0.969103 | 93.996297 | **94.00** |
| 31 | 0.186374 | 0.894595 | 0.894595 | 94.890892 | 94.89 |
| 32 | 0.172045 | 0.825815 | 0.825815 | 95.716708 | 95.72 |
| 33 | 0.158817 | 0.762324 | 0.762324 | 96.479031 | 96.48 |
| 34 | 0.146607 | 0.703713 | **0.72 (floor)** | 97.199031 | 97.20 |
| 35 | 0.135335 | 0.649609 | 0.72 (floor) | 97.919031 | 97.92 |
| 36 | 0.124930 | 0.599665 | 0.72 (floor) | 98.639031 | 98.64 |
| 37 | 0.115325 | 0.553561 | 0.72 (floor) | 99.359031 | 99.36 |
| 38 | 0.106459 | 0.511001 | 0.72 (floor) | 100.079031 | 100.08 |
| 39 | 0.098274 | 0.471713 | 0.72 (floor) | 100.799031 | 100.80 |
| **40** | 0.090718 | 0.435446 | 0.72 (floor) | 101.519031 | **101.52** |

These are the server's own numbers: on 2026-10-30, `compute_total_for_photo_count` in the dev API returned 79.74, 86.83, 94.00 and 101.52 for 20, 24, 30 and 40 photos.

### 6b.2 The fee on extra photos, and Alex's net

Alex's bookings are priced by the curve. Extra photos are therefore **not** a separate "extra images" purchase. They are a second payment on the same booking (`difference`), and the booking earns **one** entry (`gig_base`) for its whole final price. That entry is split at the rates stored on the booking when Alex accepted it: **20%** = 15% kept by the platform + 5% returned to Alex as $RAWW credit. Client credit is 0% (Alex's setting).

The policy's separate `fee_percent_extras` (20%) applies only to older bookings priced without the curve. It is not used here. An `extra_images` earnings entry for these bookings is a failure (6b.6).

Rounding: 15% and 5% of the whole final price are each rounded to the cent, and Alex's cash is the remainder.

| Photos chosen | Final price | Already paid | **Charged at selection** | 15% kept | 5% $RAWW to Alex | Fee (20%) | **Alex's net (cash)** | of which from the extras |
|---|---|---|---|---|---|---|---|---|
| 20 (booking 1) | 79.74 | 79.74 | **0.00** | 11.96 | 3.99 | 15.95 | **63.79** | - |
| 30 (booking 2) | 94.00 | 79.74 | **14.26** | 14.10 | 4.70 | 18.80 | **75.20** | 11.41 |
| 40 (booking 2) | 101.52 | 79.74 | **21.78** | 15.23 | 5.08 | 20.31 | **81.21** | 17.42 |

Step by step:

- **20:** 79.74 × 15% = 11.961 → 11.96; × 5% = 3.987 → 3.99; 79.74 - 11.96 - 3.99 = **63.79**.
- **30:** photos 21 to 30 = 1.990958 + 1.837886 + 1.696582 + 1.566143 + 1.445732 + 1.334579 + 1.231972 + 1.137253 + 1.049817 + 0.969103 = 14.260025. Total 79.736271 + 14.260025 = 93.996297 → **94.00**. Charge 94.00 - 79.74 = **14.26**. Split: 94.00 × 15% = 14.10; × 5% = 4.70; 94.00 - 14.10 - 4.70 = **75.20**.
- **40:** photos 31 to 33 = 0.894595 + 0.825815 + 0.762324 = 2.482734. Photos 34 to 40 hit the floor: 7 × 0.72 = 5.04. Total 93.996297 + 2.482734 + 5.04 = 101.519031 → **101.52**. Charge 101.52 - 79.74 = **21.78**. Split: 101.52 × 15% = 15.228 → 15.23; × 5% = 5.076 → 5.08; 101.52 - 15.23 - 5.08 = **81.21**.
- The extras' share of Alex's net is net(N) - 63.79, which is 80% of the charge: 14.26 × 0.8 = 11.408 → 11.41; 21.78 × 0.8 = 17.424 → 17.42.

### 6b.3 Booking 1: deliver about 24, choose exactly 20

**Step 5:** add **24** photos. Wait until none says **Processing**, then **Send to client**.

**Step 6:** choose **exactly 20**.

**Expect on the selection screen:** **20 chosen** · **Nothing more to pay** · **One more adds EUR 1.99** · button **Confirm selection**.

Do not choose 19: the screen would read **Final price EUR 77.58 - you'll be refunded EUR 2.16**, and a refund would start.

After **Confirm selection**, run the checks (from `api/`; each reads the latest booking of pro1):

    G="with g as (select g.* from gig g join user_account u on u.user_id = g.pro_user_id where u.email = 'pro1@rawwers.dev' order by g.created_at desc limit 1)"
    docker compose exec -T postgres psql -U postgres -d rawwers -At \
      -c "$G select (select count(*) from proof_gallery_item i join proof_gallery pg on pg.id = i.gallery_id where pg.gig_id = g.id) as delivered, (select count(*) from client_selection_item si join client_selection cs on cs.id = si.selection_id join proof_gallery pg on pg.id = cs.gallery_id where pg.gig_id = g.id and cs.status = 'submitted') as chosen from g" \
      -c "$G select g.status, g.amount_minimum, g.amount_final, g.final_gross, g.final_platform_retained, g.final_pro_raww, g.final_pro_cash from g" \
      -c "$G select sp.kind, sp.status, sp.amount, sp.amount_refunded from stripe_payment sp, g where sp.gig_id = g.id order by sp.created_at" \
      -c "$G select e.source_type, e.status, e.gross_eur, e.platform_fee_eur, e.net_eur, e.metadata->>'fee_percent', e.available_at <= now() from earnings_ledger_entry e, g where e.pro_user_id = g.pro_user_id and (e.source_id = g.id or e.metadata->>'gig_id' = g.id::text)"

**Expect** exactly these four blocks, one line each:

    24|20
    completed|79.74|79.74|79.74|11.96|3.99|63.79
    base|succeeded|79.74|0.00
    gig_base|pending|79.74|15.95|63.79|20|t

**`stripe listen`:** one `--> payment_intent.succeeded` / `<-- [200]` at step 4, and **nothing** at step 6.

Then continue with steps 7 to 11, using the amounts in 6b.5.

### 6b.4 Booking 2: deliver all 40, choose 30 or 40

**Step 5:** add **40** photos. Wait until none says **Processing**, then **Send to client**.

**Step 6:** choose **30** (10 extras) or all **40** (20 extras).

**Expect on the selection screen:**

| Chosen | Lines | Button |
|---|---|---|
| 30 | **30 chosen** · **EUR 14.26 to pay** · **One more adds EUR 0.89** | **Pay EUR 14.26** |
| 40 | **40 chosen** · **EUR 21.78 to pay** (no "One more" line: there is no 41st photo) | **Pay EUR 21.78** |

**6b.4.1** Tap the button and confirm. Then, **before paying**, run the checks from 6b.3.

**Expect (30 / 40):**

    40|30                                   40|40
    paid|79.74|94.00||||                    paid|79.74|101.52||||
    base|succeeded|79.74|0.00               base|succeeded|79.74|0.00
    (no earnings line yet)                  (no earnings line yet)

A third line `difference|pending|14.26|0.00` (or `21.78`) may already be there: the charge is created when you confirm and is not yet paid. That is fine.

**6b.4.2** In Stripe's sheet, pay with **`4000 0000 0000 0077`** (as in step 4). The screen reads **Your selection is locked in** until the payment clears, then the booking shows **View your photos**.

**`stripe listen`:** a second `--> payment_intent.succeeded` / `<-- [200]`.

**6b.4.3** Run the checks again.

**Expect (30):**

    40|30
    completed|79.74|94.00|94.00|14.10|4.70|75.20
    base|succeeded|79.74|0.00
    difference|succeeded|14.26|0.00
    gig_base|pending|94.00|18.80|75.20|20|t

**Expect (40):**

    40|40
    completed|79.74|101.52|101.52|15.23|5.08|81.21
    base|succeeded|79.74|0.00
    difference|succeeded|21.78|0.00
    gig_base|pending|101.52|20.31|81.21|20|t

Then continue with steps 7 to 11.

### 6b.5 Payouts: €50 after each booking

Payouts start at €50.00. The figures below are checked against the dev database on 2026-10-30.

| When | Ready to withdraw (after step 8 settles) | Payout to request (step 9.2) | Left after it is paid |
|---|---|---|---|
| Before booking 1 | €41.95 (the 2026-09-23 booking; no payout requests yet) | - | - |
| After booking 1 | 41.95 + 63.79 = **€105.74** | **€105.74** (all of it) | €0.00 |
| After booking 2, chose 30 | **€75.20** | **€75.20** | €0.00 |
| After booking 2, chose 40 | **€81.21** | **€81.21** | €0.00 |

Each booking clears €50 on its own, so neither payout depends on the old balance. Withdrawing everything each time makes the next check exact: after booking 2, ready to withdraw is that booking's net and nothing else.

If you request only €50.00 after booking 1, €55.74 stays. Ready to withdraw after booking 2 is then 55.74 + 75.20 = €130.94, or 55.74 + 81.21 = €136.95.

The platform's Stripe **test** balance had €2,804.50 available on 2026-10-30, so the transfers have funds.

Ready to withdraw, as stored (from `api/`):

    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select coalesce(sum(e.net_eur) filter (where e.status = 'available'), 0) from earnings_ledger_entry e join user_account u on u.user_id = e.pro_user_id where u.email = 'pro1@rawwers.dev'"

This sums every settled earning, including those already paid out. So it reads **41.95** before booking 1, **105.74** after booking 1, and **180.94** (30) or **186.95** (40) after booking 2, whatever was withdrawn. The app's **ready to withdraw** is this sum minus what was paid out or requested.

### 6b.6 STOP if

Stop at the first of these. Report the step, what you saw, the query output and the time:

- The selection screen shows a different amount from 6b.3 or 6b.4 (for example, anything but **Pay EUR 14.26** for 30). The app and the server price from one function, so any difference is a bug.
- Booking 1 at 20 photos asks for any payment, or mentions a refund.
- The amount Stripe charges differs from the button.
- More than one `difference` line, any line `failed` or with `amount_refunded` above 0.00, or any `charge.refunded` / `refund.*` event in `stripe listen`.
- Any `extra_images` earnings line, or more than one earnings line for the booking. Extras would then be paid twice.
- The earnings `gross_eur` differs from `amount_final`, or the net differs from the 6b.2 table.
- The booking is still `paid` a minute after the difference payment's `<-- [200]`, or `stripe listen` shows anything other than `[200]`.
- Ready to withdraw, after step 8, differs from 6b.5.
- A payout ends `failed` (step 10).

---

## 7. Review (the client)

**7.1** In the booking, tap **Leave a review**, choose a rating, optionally write **What was it like?**, tap **Post review**.

**Expect:** the review shows on the booking.

---

## 8. Earnings settle

The settlement sweep runs on `beat` every hour. To run it now (the same task, run once):

    docker compose exec -T worker python -c "from app.tasks.payouts_tasks import run_settlement_scan_task as t; print('settled:', t())"

**Expect:** `settled: 1` (or more). Then:

    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select e.status from earnings_ledger_entry e join user_account u on u.user_id = e.pro_user_id where u.email = 'pro1@rawwers.dev' order by e.created_at desc limit 1"

**Expect:** `available`.

**8.1** In RAWWERS Pro, open **You → Settings → Getting paid** and pull down to refresh.

**Expect:** the top card's **ready to withdraw** amount is €41.95 plus this booking's net; **Earned, still settling** is €0.00; the setup card still says **Payouts are set up**.

![Ready, earning settling](stage1-loop/payouts-ready-earning-settling.png) ![Ready to withdraw](stage1-loop/payouts-ready-to-withdraw.png)

*(Screenshots from the test harness: the second shows €41.95, the balance before this loop's booking.)*

---

## 9. Payout request (the pro)

**9.1** Tap **Wallet**. Scroll to **Request a payout**.

**Expect:** **Verified · Payouts go to your verified account.**, an **Amount (€)** field and a **Request payout** button. If instead it says payouts start at €50.00, the balance is under the minimum: book again (step 2).

![Wallet, Request payout](stage1-loop/wallet-request-payout.png)

*(Harness screenshot with fixture amounts; the card at the bottom is the one to use.)*

**9.2** Enter an amount between €50.00 and the amount available to withdraw. Tap **Request payout**.

**Expect:** the request is accepted; **Requested** in the Wallet shows that amount.

    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select pr.status, pr.amount_eur from payout_request pr join user_account u on u.user_id = pr.pro_user_id where u.email = 'pro1@rawwers.dev' order by pr.created_at desc limit 1"

**Expect:** `requested|<the amount>`.

---

## 10. Admin approval (the web admin)

**10.1** Start the web admin (in `web/`): `npm run dev`. Open `http://localhost:3000/login`.

**10.2** Sign in as `admin@rawwers.dev` / `Passw0rd!` and tap **Login**.

**10.3** In the sidebar, under **MONEY**, click **Payouts**. The page lists withdrawal requests; the dev data includes many seeded demo requests.

![Admin payouts](stage1-loop/admin-payouts.png)

**10.4** Find the row for **Alex Lens** with the amount from 9.2.

**Expect on that row:** status **Requested**; **GOES TO** reads **Stripe Connect — active**. If it reads *Manual bank transfer*, or anything other than `active`, stop: approving would not send money to Stripe.

Do **not** approve any other row: the seeded demo requests are manual bank transfers.

**10.5** Click **Approve…** on Alex's row. The dialog reads **Approve €<amount> to Alex Lens?** and **Stripe Connect — active.** Click **Approve €<amount>**.

**Expect:** the row's status changes to **Approved**, and within a few seconds (the worker sends the transfer) to **Paid**. In the `stripe listen` terminal: `--> transfer.created` and `<-- [200]`.

Do **not** click **Mark paid…**: that is for manual bank transfers, where no money moves through Stripe.

    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select pr.status, pr.reference->>'stripe_transfer_id' is not null as has_transfer, pr.failure_reason from payout_request pr join user_account u on u.user_id = pr.pro_user_id where u.email = 'pro1@rawwers.dev' order by pr.created_at desc limit 1"

**Expect:** `paid|t|` - paid, with a Stripe transfer id, and no failure reason. If it says `failed|f|<reason>`, stop and report the reason (it is Stripe's own message; no secret in it).

---

## 11. After the payout: the screen and the stored status agree

**11.1** In RAWWERS Pro, open **Wallet** and pull down.

**Expect:** **Paid out** has grown by the amount; **Requested** is back to €0.00.

**11.2** Open **You → Settings → Getting paid** and pull down.

**Expect:** **Payouts are set up**, chip **Ready**; **ready to withdraw** has dropped by the amount paid.

    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select pa.status, pa.payout_method from payout_account pa join user_account u on u.user_id = pa.pro_user_id where u.email = 'pro1@rawwers.dev'"

**Expect:** `active|stripe_connect`.

**If the Payouts screen says anything other than Payouts are set up, or the stored status is not `active`, STOP and report both.**

---

## 12. Put dev back

**12.1 Restore the fee policy** to exactly what was saved in 0.4 (from the repo root):

    RAWWERS_ADMIN_API_KEY="$(grep -E '^ADMIN_API_KEY=' web/.env.local | cut -d= -f2-)" \
      python3 -I docs/stage1-loop/fee_policy_delay.py restore

**Expect:** the `saved`, `before restore` and `now` lines, then `OK: the fee policy is back to the saved values.` The `now` line must match `saved` field for field. If it says `STOP: since the save, these changed too: ...`, something else changed the policy during the loop: it has not overwritten it. Report that and do not fix it by hand.

Then the whole row again, from `api/`:

    docker compose exec -T postgres psql -U postgres -d rawwers -At -c "select id, fee_percent_gigs, fee_percent_extras, fee_percent_studioverse, settlement_delay_days, dispute_hold_days, retained_percent, pro_raww_percent, max_client_credit_percent from platform_fee_policy"

**Expect:** exactly the line you kept from 0.4.

**12.2** Stop `stripe listen` (Ctrl-C) and the web admin's `npm run dev`.

**12.3 Put the upload limit back** (only if 6b raised it). Before the loop, `api/.env` did not set `RATE_LIMIT_UPLOADS_PER_HOUR`, so the code default of 30 applied. Remove the two lines added on 2026-10-30, reload the API, and check (from `api/`):

    sed -i '' -e '/^# Stage 1 loop only (2026-10-30)/d' -e '/^RATE_LIMIT_UPLOADS_PER_HOUR=200$/d' .env
    grep -c '^RATE_LIMIT_UPLOADS_PER_HOUR' .env
    docker compose up -d api
    docker compose exec -T api python -c "from app.services.rate_limit import RATE_LIMIT_RULES as r; print(r['uploads'])"

**Expect:** `0`, then (once `api` is healthy again) `(30, 3600)`. Use `up -d`, not `restart`: `restart` does not re-read `.env`.

Nothing else was changed outside the apps' own flows.

---

## What the screenshots could and could not show

The screenshots above come from two places: the Payouts screen states and the Wallet from the app's screenshot harness (`app/test/screenshots/`), with test data, not the dev database; the return pages and the admin Payouts queue from a headless browser against the dev stack on 2026-10-28.

**Not reached (no screenshot):** I cannot tap the simulators, so these are described from the code and from the owner's gate run, not shown:

- Stripe's hosted onboarding form (1.3) and the iOS **Open in "RAWWERS Pro"?** prompt (1.4);
- the client app's booking request, payment sheet, delivered gallery, selection and review (steps 2, 4, 6, 7);
- the pro app's Requests, Gigs and delivery screens with *this loop's* booking (steps 3, 5);
- the admin's Approve dialog and Alex's row (10.4-10.5) - the queue screenshot shows only seeded demo requests;
- the Wallet and Payouts screens with this loop's real amounts (8.1, 9, 11).
