# Acceptance: the whole money path, tested

One marketplace transaction from end to end: sign-up, booking, payment,
delivery, selection, completion, settlement, payout. This is where a bug
becomes a refund RAWWERS owes, so it is tested two ways.

| Level | What | Where | Time |
|---|---|---|---|
| 1 | `api/tests/test_money_journey.py`: the journey through the API's own routes, with only Stripe, R2 and email faked | The Mac (`tools/tests/native-db.sh`) and the sharded full-suite workflow | About 3 minutes |
| 2 | `deploy/scripts/acceptance.py`: one real booking on the deployed **test** server, in Stripe test mode, over the public API, plus a short manual remainder | The Mac, against `https://api.rawwers.com` while it is the test server | About 30 minutes, plus the wait for the earning |

**Required:** the Level 2 run after every deploy that touches money (any
change in `api/` that moves payments, refunds, earnings, payouts or prices),
and once before the first real photographer (DEPLOY_RUNBOOK, DEPLOY_CHECKLIST).

## The rule the tests assume about Stripe's fee

**RAWWERS absorbs Stripe's processing fee out of its 15%.** The
photographer's cash never depends on it. Neither level models the fee:
they check our own records and the transfers, not the platform's real
Stripe balance. Recording the fee per payment is BETA_SCOPE #105.

## Level 1: the journey test

```
tools/tests/native-db.sh tests/test_money_journey.py -q -rxX
```

**Expect:** every scenario passed, and two `XFAIL` lines, naming BETA_SCOPE
#103 and #107 (known bugs kept as strict expected failures: the day one is
fixed its test turns red, and its mark comes off).

| Scenario | What it proves |
|---|---|
| 1, euros | Sign-up, onboarding and approval, Stripe payout setup, a booking of 20 photos at 4.80 = 96.00, 10 extras 31.74, completion at 127.74 = 19.16 kept + 6.39 RAWW + 102.19 cash, one earning, refused before 7 days and allowed after, transfers 96.00 and 6.19 (one from each charge) |
| 2, pounds | London, the 5.00 Rookie cap, 107.81 = 16.17 + 5.39 + 86.25, the 45.00 minimum, one transfer in pence |
| 3a | Fewer photos delivered than included: the gap refunded (photographer_non_delivery), the earning lowered, the short-delivery flag |
| 3b | A difference paid for a selection that became cheaper: refunded in full (duplicate_payment) |
| 4a | An admin price reduction after completion; a second one after the payout shows as an adjustment owed |
| 4b | An admin refund before completion: the booking earns what was kept |
| 5 | Every webhook delivered twice, then the whole history again, then under new event ids: nothing counted twice |
| 6 | A declined card, then a retry: the same PaymentIntent, one payment |
| 7 | Client credit at checkout: at most 10% off, out of the platform's share; the photographer paid on the full price |
| 8 | A photographer-fault finding (no money moves), then a lost chargeback: the earning reversed, what was paid out owed back as an adjustment (XFAIL #107: the RAWW credit stays) |
| 9 | A lost chargeback with no finding: the platform absorbs it (the amount and Stripe's 20.00 fee); the earning untouched |
| probe | Extras bought on a flat-priced booking, the payment's event re-sent (XFAIL #103: the download count doubles) |

Each test uses its own database and its own made-up internet address, so it
does not depend on any other test or on the order the suite runs in.
`api/tests/test_acceptance_against_the_api.py` also runs the Level 2 script
itself against the API's routes, with no network.

## Level 2: one real booking on the test server

### Before you start (once)

| # | What | Why |
|---|---|---|
| 1 | The test world (docs/TEST_WORLD.md): London (and Lisbon) switched on, your admin | Without it nothing can be booked |
| 2 | A **standing test photographer** per currency, approved, with working hours on most days, a Portraits package of **at most 25 photos** within the Rookie cap, and Stripe's payout form finished in the Pro app | The script books their first active package; the upload limit is 30 photos an hour and it sends the package plus 5 |
| 3 | **The photographer's payout account set up more than 24 hours before the payout phase.** A payout asked for within 24 hours of any change to the payout account is frozen as a possible takeover (found by the Level 1 clock) | Otherwise the payout request is refused |
| 4 | The Stripe **publishable test key** (`pk_test_...`) from Stripe (test mode) > Developers > API keys, put in your shell without echoing: `read -rs RAWWERS_STRIPE_PK && export RAWWERS_STRIPE_PK` | The script confirms payments with it; without it each payment is a manual step in the client app. A live key is refused |
| 5 | Each standing photographer can be paid at most **twice in 7 days** | At most two full runs a week per photographer |

### The run

**Mac**, from the repository:

```
python3 deploy/scripts/acceptance.py book --api https://api.rawwers.com --confirm-host api.rawwers.com --pro-email <you>+pro1@gmail.com
```

It asks for the photographer's password (not shown, never stored). It stops
once at **MANUAL: settlement delay**: to pay out the same day, run on the
server `set-settlement-delay.py --apply` (docs/TEST_WORLD.md 9a) now, then
press Enter. At the end it prints a table (`ok`, `FAIL`, `MANUAL`) and the
run id.

When the earning is available (after the delay, and after the hourly sweep
or `settle-now.py --apply` on the server):

```
python3 deploy/scripts/acceptance.py payout --api https://api.rawwers.com --confirm-host api.rawwers.com --run <run id>
```

It stops at **MANUAL: admin approves**: approve the row in the admin web,
then press Enter; it waits for **paid**.

`settle-now.py` (TEST ONLY) runs the hourly sweep once, from the Mac:

```
ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python -' < tools/server/settle-now.py
ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python - --apply' < tools/server/settle-now.py
```

**You should see:** `due now: 1 earning(s); ...`, `DRY RUN`, then
`Swept: 1 earning(s) settled`. It refuses unless `DEPLOYMENT_MODE` is
exactly `test`.

### What it proves, and what it does not

| Proved by the script | Not proved (manual, or not at all) |
|---|---|
| The public API takes a booking from request to payout, with real webhooks from Stripe test mode and real uploads to R2 | Stripe's hosted onboarding (done once by hand) |
| The deposit is the package at the entry rate; the selection's total and the difference follow the owner's rule (Portraits) | Another niche's curve (the total is shown; compare it by hand) |
| One earning for the booking, with the expected gross and cash | The 7-day wait itself when the delay was set to 0 (Level 1 proves the wait) |
| The payout request, and the payout reaching paid | The transfers in Stripe, refunds, price reductions, chargebacks (Level 1 covers them; on the server, by hand) |
| | That Stripe accepts a test payment method with a publishable key: if it does not, each payment becomes a MANUAL step in the client app (card `4000 0000 0000 0077`) |

Accounts pile up: a client made by a run has money on it and cannot be
deleted; the test-world reset (docs/TEST_WORLD.md) clears them.

### The manual checklist (each run)

- [ ] The standing photographer's payout account was set up more than 24 hours ago.
- [ ] Settlement delay: set to 0 before the selection if paying out today; **restored** after (`set-settlement-delay.py --restore --apply`).
- [ ] Admin > the booking's money: the final price, kept, RAWW and cash the script printed.
- [ ] Admin > Payouts: approve the row (GOES TO: Stripe Connect, active).
- [ ] Stripe (test mode) > Connect > the photographer's account: the transfers add up to the cash, from the booking's charges.
- [ ] Any MANUAL payment: paid in the client app with the test card, for the amount the script names.
- [ ] The table has no FAIL. Write the result below.

## What passed on which tag

| Date | Tag | Level 1 (`test_money_journey.py`) | Level 2 run id | Level 2 result (ok / FAIL / MANUAL) | Who |
|---|---|---|---|---|---|
| | | | | | |
