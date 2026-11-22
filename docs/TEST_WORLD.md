# The test world on the server

How to go from an empty test server to a paid booking: an admin, a city that
is switched on, a client, a listed photographer with packages, a Stripe test
payout account, and a booking paid with a test card. For the test server only
(`DEPLOYMENT_MODE=test`, Stripe in test mode). About an hour the first time.

Background: [WORKING_AGAINST_THE_SERVER.md](WORKING_AGAINST_THE_SERVER.md)
(the allowlist, the limits). Commands marked **Mac** run in the repository on
your Mac; **server** in `/opt/rawwers/src` after `ssh root@<SERVER_IP>`.

## Two worlds: pounds and euros

The photographer's money follows their own country: a photographer in a UK
city works in pounds, one in a euro country in euros. Their Stripe payout
account is opened in the same country.

| World | City | Photographer's currency | Stripe payout account |
|---|---|---|---|
| Pounds | London, GB | GBP | GB |
| Euros | Lisbon, PT | EUR | PT |

Make one photographer in each to see both. The pound price caps are
PROVISIONAL (docs/PRICE_CAPS.md): fine for testing.

## The recipe

| # | Step | Where | Notes |
|---|---|---|---|
| 1 | The admin account | Runbook step 20 | Once per database |
| 2 | Switch the cities on | Mac, `tools/server/enable-city.py` (below) | Without it nobody can sign up as a photographer there and clients see nothing |
| 3 | A client | Client app: register with `<you>+client1@gmail.com` | The verify code arrives by email (it is on the allowlist) |
| 4 | A photographer | Pro app: register with `<you>+pro1@gmail.com`, then onboarding (below) | City London, country GB (or Lisbon, PT) |
| 5 | Approve and list them | Admin > Home: the photographer under "ready to approve" > **Approve** | Approve sets identity checked and listed for the public |
| 6 | Stripe test payout account | Pro app: You > Settings > Getting paid | Stripe's test values (below) |
| 7 | A paid booking | Client app: request, Pro app: accept, client pays with a test card | `4242 4242 4242 4242`, any future date, any CVC; `4000 0000 0000 0077` puts the money straight into the available balance |
| 8 | Deliver and select | Pro app (or Lightroom) delivers, client chooses | The booking completes when the client confirms |
| 9 | Payout | Pro app: Wallet > withdraw; Admin > Payouts > Approve | Earnings wait 7 days, unless step 9a |

### 2. Switch the cities on

**Mac**, from the repository (the script goes to the API container over SSH;
the server's checkout is the deploy tag, which does not have it):

```
ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python -' < tools/server/enable-city.py
```

**You should see:** `before  London, GB: not listed (off)`, the same for
Lisbon, `would switch on ...` twice and `DRY RUN: nothing written`. Then the
same command with `--apply`:

```
ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python - --apply' < tools/server/enable-city.py
```

**You should see:** two `after ... photographer sign-up on, client browsing
on` lines and `Done: 2 city(ies) switched on`. Running it again says
`already on: nothing to change`. Another city:
`... python - --city Manchester --country GB --apply'`.

It writes through the API's own admin route code, so each city has an admin
audit record (`rollout_city_upsert`) naming your admin. It refuses to run
unless the server's `DEPLOYMENT_MODE` is `test`. With more than one admin, add
`--admin-email <you>+admin@gmail.com`.

### 4. The photographer's onboarding

In the Pro app, in this order (each screen says what is missing):

| Stage | What it needs |
|---|---|
| Start | City and country (London, GB) |
| Profile | Name, bio, city; the profile at least 60% complete |
| Portfolio | **12 photos** at least |
| Gear | A camera that meets the floor for the chosen niches (the camera list comes from the reference data). Gear waiting for review shows on the admin's photographer page; approval is refused until it is cleared |
| Packages | At least one active package, and an extra-photo price for each niche that has a package. Prices within the caps for the photographer's tier |
| Niches | At least one |
| Identity | Submit; your approval in step 5 counts as the check |

**The tier a new photographer starts at: Rookie,** in every niche. The tier is
worked out per niche from completed bookings, rating and score; Skilled, the
next one, needs at least 5 completed bookings, a 4.2 rating and a score of 25
(api/app/services/niche_skills.py). So a new photographer's packages must fit
the **Rookie** price caps of their currency (docs/PRICE_CAPS.md; Portraits
Rookie in pounds, for example, is 5.00 a photo). An admin can set a tier by
hand per niche, which stays until removed.

### 6. Stripe test payout account

In the Pro app, Getting paid opens Stripe's own form, in test mode. Use
Stripe's test values: phone `000 000 0000`, SMS code `000000`; for a GB
account sort code `10-88-00` and account number `00012345`; for a PT account
IBAN `PT50000201231234567890154`; date of birth `1901-01-01` passes the
identity check. **Expect:** back in the app, "Payouts are set up", Ready.
(Stripe's published test values, from memory and not checked against
Stripe's page today: if the form asks for something else, Stripe's
"Testing Connect" page lists the current ones.)

### 9a. Same-day payout (TEST ONLY)

Earnings wait `settlement_delay_days` (7 on the server) before they can be
withdrawn. To try the whole payout path in one evening, set it to 0 **before
step 8** (the wait is fixed when the earning is recorded, when the client
confirms the selection):

```
ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python -' < tools/server/set-settlement-delay.py
ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python - --apply' < tools/server/set-settlement-delay.py
```

**You should see:** `TEST ONLY: ...`, `before: ... settlement_delay_days=7 ...`,
then `after : ... settlement_delay_days=0 ...` and every other field the same.
It goes through the API's own admin route code (audit record
`platform_fee_policy_updated`) and refuses unless `DEPLOYMENT_MODE` is `test`.

With the delay at 0 **the payout path is exercised, but the 7-day behaviour
is not proven.** When the payout test is done, put it back:

```
ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python - --restore --apply' < tools/server/set-settlement-delay.py
```

**You should see:** `Restored: settlement_delay_days was 0, now 7`. The go-live
checklist checks it (DEPLOY_CHECKLIST, "settlement delay is the real value").

## More accounts

Every address you sign up with must be on `EMAIL_DEV_ALLOWLIST` to receive
its code: list about 12 plus-addresses at the start
([WORKING_AGAINST_THE_SERVER.md](WORKING_AGAINST_THE_SERVER.md)). Accounts
cannot be deleted yet (only the smoke test's own `smoke-<number>@rawwers.test`
accounts, with `scripts/delete_smoke_accounts.py`). Use a new plus-address for
a fresh start, or reset the database (below).

Register is limited to 30 a minute per internet address, shared by all your
devices; signing up many accounts in a row can hit it. Wait a minute.

## RESET the test database

> **TEST SERVER ONLY. NEVER once real users or real money exist.** This
> throws away every account, booking, payment record and setting in the
> database. Stripe's test data (connected accounts, payments) and the photos
> in R2 stay where they are; nothing on the server refers to them afterwards.

**1. Dump first** (server), and keep the file name it prints:

```
deploy/scripts/backup-now.sh
```

**You should see:** `OK: /var/backups/rawwers/rawwers-<time>.dump`.

**2. Stop what uses the database, empty it** (server):

```
deploy/scripts/dc stop api worker worker-photos beat web
deploy/scripts/dc exec -T postgres sh -c 'dropdb -U "$POSTGRES_USER" "$POSTGRES_DB" && createdb -U "$POSTGRES_USER" "$POSTGRES_DB"'
deploy/scripts/dc exec -T redis redis-cli FLUSHALL
```

(Redis holds only caches, queues and rate-limit counters.)

**3. Migrate and load the reference data** (server; runbook steps 11 and 12):

```
deploy/scripts/dc run --rm migrate
deploy/scripts/dc run --rm api python scripts/bootstrap_reference_data.py
deploy/scripts/dc up -d
```

**You should see:** `Running upgrade ...` lines; then the bootstrap's
`Done: ... row(s) added` (the pound caps line says PROVISIONAL); then every
service healthy (`deploy/scripts/dc ps`).

**4. The admin again** (runbook step 20). Your admin account is gone with the
database, and the new one has a **new id**: put it in `ADMIN_USER_IDS` in the
secrets file and `deploy/scripts/dc up -d --force-recreate api`.

**5. The cities again:** `tools/server/enable-city.py --apply` (step 2 above).

**6. Settlement delay:** a new database starts at 7 days. Nothing to restore.

To undo a reset: restore the dump from step 1 (runbook step 21, "Restore a
backup for real").
