# Working against the server

From 2026-11-22 the test server is the one place where RAWWERS runs day to
day. The Mac no longer runs the API, the workers, the database or the admin
web. The Mac keeps: the code, the Flutter apps (run against the server), the
Lightroom plug-in (built for the server), and backend test runs.

| Address | What | Who can open it |
|---|---|---|
| `https://api.rawwers.com` | The API the apps and the plug-in call | Anyone (admin, dev and docs routes are hidden) |
| `https://admin.rawwers.com` | The admin web | Only you, behind Cloudflare Access |

What the server is: a TEST deployment (`DEPLOYMENT_MODE=test`). Stripe in
test mode, email only to the addresses in `EMAIL_DEV_ALLOWLIST`, no dev login
shortcut, no `/v1/dev/*` routes, no API docs, Mux not set up yet.

Server commands are run by you, in `/opt/rawwers/src` on the server, after
`ssh root@<SERVER_IP>`. `deploy/scripts/dc` is `docker compose` with the
server's files (see the runbook). An agent working on the code never logs in
to the server: it writes the exact command, you run it and paste the output.

## What changed from the Mac stack

| On the Mac before | On the server now | Guide |
|---|---|---|
| Seeded accounts (pro1@rawwers.dev and others) | None. You make the accounts yourself | [TEST_WORLD.md](TEST_WORLD.md) |
| Dev login shortcut | Normal email and password | |
| Codes and emails in the dev mail log | Your inbox, only for addresses on the allowlist (below) | |
| `stripe listen` | Stripe's test webhook to the server (runbook step 15) | |
| Turning on a city with a dev script | `tools/server/enable-city.py`, run by you on the server | [TEST_WORLD.md](TEST_WORLD.md) |
| Settlement delay set to 0 by `fee_policy_delay.py` | `tools/server/set-settlement-delay.py`, TEST ONLY | [TEST_WORLD.md](TEST_WORLD.md) |
| Delete my test account (`/v1/dev/...`) | Not possible, except the smoke test's own accounts | |
| Fake Mux | None: the video says "not available" until Mux is set up | [MUX_LOCAL_WEBHOOKS.md](MUX_LOCAL_WEBHOOKS.md) |
| Flutter integration tests | Not against the server (they need a local API and `/v1/dev`) | |
| Admin web with `npm run dev` | Not possible against the server (below) | |
| Backend tests in the dev stack's Docker | Native Postgres and Valkey (Redis-compatible) on the Mac, or GitHub Actions | [BACKEND_TESTS.md](BACKEND_TESTS.md) |

## Email: the allowlist

On a test deployment the server sends email only to the addresses listed in
`EMAIL_DEV_ALLOWLIST` (in `/opt/rawwers/.env.production` on the server).

How it matches:
- A comma-separated list. Each entry must equal the whole address. Capital
  letters and spaces around the entries do not matter.
- No wildcards, no whole domains, and no plus-address matching: `you+pro1@`
  must be listed itself, `you@` does not cover it.

Advice: list about 12 plus-addresses in full at the start, so you never have
to come back to it. Gmail delivers every `you+anything@gmail.com` to your own
inbox. For example (your own address in place of `<you>`):

```
EMAIL_DEV_ALLOWLIST=<you>@gmail.com,<you>+admin@gmail.com,<you>+pro1@gmail.com,<you>+pro2@gmail.com,<you>+pro3@gmail.com,<you>+pro4@gmail.com,<you>+client1@gmail.com,<you>+client2@gmail.com,<you>+client3@gmail.com,<you>+client4@gmail.com,<you>+spare1@gmail.com,<you>+spare2@gmail.com
```

Every change to the list needs the services recreated (they read settings
once, at start, and the worker is the one that sends):

```
deploy/scripts/dc up -d --force-recreate api worker worker-photos
```

An address that is not on the list can still register and sign in with a
password (verifying the email is only enforced for accounts that Trust &
Safety has flagged). It never receives a code, so it cannot reset its
password.

## Limits that now apply to you

Behind Cloudflare every device in your home shares one internet address. Two
limits are counted per address, at 30 a minute (`RATE_LIMIT_AUTH_MUTATION_PER_MIN`):

| What | Counted per | Effect for you |
|---|---|---|
| Register | Address | All your phones, simulators and browsers share 30 sign-ups a minute |
| Token refresh | Address | Shared the same way; only matters with many devices open at once |
| Sign in, verify, password reset | Email | One account at a time; unchanged |
| Admin pages | Admin | 60 a minute (a busy dashboard can reach it) |
| Uploads | User | 30 an hour per photographer |

If you hit one, wait a minute. That the server sees your home address (and
not Cloudflare's) is how the API is built (`TRUSTED_PROXY_*`); not verified on
the server yet.

## The daily loop

| You change | How it reaches the server | Time |
|---|---|---|
| The apps (Flutter) | Nothing to deploy: run the app on the Mac against the server, hot reload works | seconds |
| The Lightroom plug-in | Build for the server, reinstall ([LIGHTROOM_CHECKLIST.md](LIGHTROOM_CHECKLIST.md)) | a minute |
| The API or the admin web | Commit, new tag, build the images, pull and restart on the server (runbook steps 9 and 13) | 15 to 25 minutes |
| Server settings | Edit `/opt/rawwers/.env.production`, recreate the services that read it | a minute |

The admin web cannot run on the Mac against the server: the server hides
`/v1/admin` on the public API address, the admin key lives only on the server,
and the API accepts browser calls only from `https://admin.rawwers.com`.
Change it, check it with the end-to-end tests (GitHub), then deploy it.

## Running the apps against the server

```
tools/app/run-client-server.sh     # the client app
tools/app/run-pro-server.sh        # the Pro app
```

They need `app/env/client.server.json` and `app/env/pro.server.json`, made
once from the examples (see [app/README.md](../app/README.md)). A real iPhone
needs nothing extra: the server is plain https.

## Backend tests

- A few test files: `tools/tests/native-db.sh tests/test_x.py` on the Mac,
  with Homebrew's Postgres and Valkey (Redis-compatible), started for the run and stopped after (docs/BACKEND_TESTS.md).
  No Docker.
- The full suite: GitHub Actions, "Backend full suite (manual)", run by
  hand. See [MAC_DOCKER_OFF.md](MAC_DOCKER_OFF.md).

## Related

- [DEPLOY_RUNBOOK.md](DEPLOY_RUNBOOK.md): building, deploying, restarting.
- [TEST_WORLD.md](TEST_WORLD.md): the accounts, the city, a paid booking.
- [MAC_DOCKER_OFF.md](MAC_DOCKER_OFF.md): keeping the dev data, then Docker off.
