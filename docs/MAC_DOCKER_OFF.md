# Turning Docker off on the Mac

From 2026-11-22 the test server is where RAWWERS runs
([WORKING_AGAINST_THE_SERVER.md](WORKING_AGAINST_THE_SERVER.md)). The Mac's
dev stack (the API, workers, database and Redis in Docker) is no longer
needed day to day. This page keeps its data first, then stops it.

**The order matters: dump, check the dump, then stop. Nothing is deleted on
this page until the very last section, and that one is optional.**

## What is where

| What | Where | Kept by |
|---|---|---|
| The dev database (accounts, bookings, the Stage 1 loop's history) | A Docker volume **without a name** (a long id), attached to the container `api-postgres-1`, about 1 GB | Step 1 below |
| Redis (caches, queues) | Another unnamed volume, attached to `api-redis-1` | Nothing to keep |
| Photos and videos | Cloudflare R2 and Mux, not on the Mac | They stay there |
| Settings with real keys | `api/.env`, `api/.env.bak-connect-verify`, `web/.env.local`, `app/env/client.json`, `app/env/pro.json` (git ignores them) | Leave them on the Mac; never copy them into the repository |
| Lightroom simulator settings | `~/.rawwers/lightroom-sim.json` | Leave it |
| Your scratch and helper scripts | `~/Developer/RAWWERS-work/scratch`, `~/Developer/RAWWERS-work/tools` | Leave them |

**Why "unnamed" matters:** `docker compose down` removes the containers. The
volume stays on disk, but nothing points at it any more: the next
`docker compose up` makes a new, empty database, and any Docker clean-up
(`docker volume prune`, Docker Desktop's "Clean up" or "Reset") then deletes
the old one. `docker compose down -v` deletes it at once. So: never `down`
before step 2 has passed. `docker compose stop` is safe (it keeps the
containers and their volumes).

## 1. Dump the dev database (Mac)

Into a folder outside the repository (the repository is public; even an
ignored folder in it is one `git add -f` away from being published):

```
mkdir -p ~/Developer/RAWWERS-work/backups
docker exec api-postgres-1 pg_dump -U postgres -d rawwers -Fc > ~/Developer/RAWWERS-work/backups/rawwers-dev-$(date +%Y-%m-%d).dump
ls -lh ~/Developer/RAWWERS-work/backups/
```

**You should see:** a file of tens to hundreds of MB (not 0 bytes).
**If not:** `docker ps` must list `api-postgres-1` as Up; start it with
`docker compose start postgres` in `api/`.

Write down two counts from the live database, to compare in step 2:

```
docker exec api-postgres-1 psql -U postgres -d rawwers -At -c "select (select count(*) from user_account), (select count(*) from gig)"
```

## 2. Check the dump by restoring it (Mac)

Restore it into a throwaway Postgres container and count the same two tables.
This proves the file is complete, not only readable.

```
docker run -d --name rawwers-restore-check -e POSTGRES_PASSWORD=check postgres:16
until docker exec rawwers-restore-check pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
docker exec rawwers-restore-check createdb -U postgres rawwers
docker exec -i rawwers-restore-check pg_restore -U postgres -d rawwers --no-owner --exit-on-error < ~/Developer/RAWWERS-work/backups/rawwers-dev-<date>.dump
docker exec rawwers-restore-check psql -U postgres -d rawwers -At -c "select (select count(*) from user_account), (select count(*) from gig)"
docker rm -f rawwers-restore-check
```

**You should see:** the restore ends without an error, and the two counts are
the same as in step 1 (`<accounts>|<gigs>`).
**If not:** stop here. Do not go on to step 3; keep the stack as it is and ask
the developer. (A note about the `plpgsql` extension or ownership is harmless
with `--no-owner`; any `ERROR:` line is not.)

Keep the dump. Copy it somewhere off the Mac too if you want it to survive the
Mac (an external disk; not a public place: it holds test accounts' emails).

## 3. Stop the dev stack, keep everything (Mac)

```
cd ~/Developer/RAWWERS/api
docker compose stop
```

`stop`, not `down`: the containers and their volumes stay, so a later
`docker compose start` brings back exactly the same database.

## 4. Quit Docker Desktop

Docker menu > **Quit Docker Desktop**. Quitting deletes nothing: images,
volumes and containers are kept inside Docker's disk image until you start it
again.

**Other projects in Docker.** Docker Desktop also holds these projects'
containers and data. Quitting Docker stops them too (on 2026-11-22 all of them
were already stopped); none of this page touches their data:

| Project | Its volumes |
|---|---|
| pact | `pact_db-data` |
| recastwebs | `recastwebs_postgres_data`, `recastwebs_email_archive_data`, `recastwebs_logs_data`, `recastwebs_pdfs_data`, `recastwebs_screenshots_data` |
| site-daniella | `site-daniella_postgres_data`, `site-daniella_caddy_data`, `site-daniella_caddy_config` |
| ritagame | `ritagame_db_data` |

## When Docker is still needed

| For | How |
|---|---|
| A few backend test files | Not Docker: `tools/tests/native-db.sh` (Homebrew's Postgres and Redis-compatible Valkey, started for the run and stopped after) |
| The full backend suite | GitHub Actions, "Backend full suite (manual)" |
| Building the server images (runbook step 9) | Docker Desktop, for the build only, until the GitHub image build is fixed (after the first deploy) |
| Building the Lightroom plug-in | Docker Desktop, for its Lua tests (`tools/lightroom/build-for-server.sh`) |
| The Flutter integration tests, the end-to-end tests on the Mac | Docker Desktop, for that run only |

Start Docker Desktop for those, quit it afterwards. The dev stack stays
stopped (`docker compose start` in `api/` brings it back if ever needed).

## If `docker compose down` was ALREADY run

The database volume is then detached but probably still on disk. **Do NOT run
any prune or clean-up command** (`docker volume prune`, `docker system prune`,
Docker Desktop "Clean up" or "Reset to factory defaults") until a dump of it
has been restore-tested as in step 2.

**1. Find it.** Detached volumes are "dangling":

```
docker volume ls -f dangling=true
```

The dev database's volume has a 64-character name. To see which one is a
Postgres data folder, look at each without changing it (`:ro` = read-only):

```
docker run --rm -v <volume name>:/v:ro alpine sh -c 'cat /v/PG_VERSION 2>/dev/null && du -sh /v'
```

**You should see:** `16` and about 1 GB for the dev database (on 2026-11-22
its volume's name began `bb71a05bf9e9`). A volume that prints nothing is not a
Postgres folder.

**2. Copy it, then open the copy.** Postgres cannot start on a read-only
folder (it writes while starting), so the original is mounted read-only and
copied into a new volume; only the copy is ever started:

```
docker volume create rawwers-dev-recovered
docker run --rm -v <volume name>:/from:ro -v rawwers-dev-recovered:/to alpine sh -c 'cp -a /from/. /to/'
docker run -d --name rawwers-recover -v rawwers-dev-recovered:/var/lib/postgresql/data postgres:16
until docker exec rawwers-recover pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
docker exec rawwers-recover psql -U postgres -d rawwers -At -c "select (select count(*) from user_account), (select count(*) from gig)"
```

**3. Dump it and test the dump:** step 1's `pg_dump` with `rawwers-recover`
in place of `api-postgres-1`, then step 2. Only then:
`docker rm -f rawwers-recover` and `docker volume rm rawwers-dev-recovered`.
The original volume is still untouched; it can go in the clean-up below.

## Clean-up (optional, last, only after step 2 passed)

Docker on the Mac holds about **48 GB of images and 34 GB of build cache**
(2026-11-22). Freeing it is safe for the data **only after the dump is
restore-tested**, and it slows the next image build (everything is built
again).

```
docker builder prune            # the build cache; asks first
docker image prune -a           # images no container uses; asks first
```

Neither touches volumes. `docker volume prune` (or `docker system prune
--volumes`) would delete the detached dev database and any other project's
detached volume: do not use it unless you have checked every volume it lists.
