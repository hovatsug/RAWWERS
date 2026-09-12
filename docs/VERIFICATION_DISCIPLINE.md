# Verification discipline

Rules that exist because breaking them cost real time on this project. Each
one is here because it caught something that was otherwise invisible, not
because it sounds like good practice.

---

## 1. A zero is a claim. Check the request succeeded before believing it.

**When a count comes back as zero, empty, or absent, confirm the operation
actually ran before treating the zero as data.**

This is the single most repeated failure on this project. Every instance
presented as a clean, plausible zero rather than as an error, which is
exactly why each one nearly slipped through: nothing looked broken.

Eight instances, all the same shape:

| What was checked | What the zero actually meant |
| --- | --- |
| `git log origin/full-history..HEAD \| wc -l` → `0` | The ref did not exist locally. Nine commits were unpushed. |
| `grep` for an endpoint with an unquoted `?` in zsh | The shell glob ate the pattern; the endpoint existed. |
| `POST {"niche_ids": [...]}` → `200`, nothing changed | Hand-written field name. The real shape was `{primary_niche_slug, niches:[...]}`. |
| A webhook test asserting the handler's own logic | The test transcribed the implementation, so it could not disagree with it. |
| `docker compose build api` then "the row did not move" | `worker` is a separate image and still ran the old code. |
| A truncated `psql` listing read as the full set | The rest of the rows were below the cut. |
| `hasattr(row, "bytes_size")` → always `False` | Wrong field name. The column is `bytes`; nothing was ever set. |
| `/v1/client/discover` → "0 photographers" in 4 cities | **HTTP 401.** The parser read `items` out of an error body. |

The last one is the clearest: the check ran, produced a number, and measured
nothing at all. Forty photographers with covers were sitting behind it.

**In practice:** assert the status code before reading the body. Print what
was actually returned when a result is empty. Prefer a check that fails
loudly on a bad request over one that reports zero.

---

## 2. Break every check once against working code.

A check that has never failed has never been shown to be capable of failing.
Revert the fix, confirm the check goes red, restore it.

This caught, among others: a route guard that checked navigation depth
instead of order; a query-count test whose listener was attached to an engine
the request never used, so it counted zero for every input; and a
gallery-ownership test whose fake sat on the wrong side of the logic, so
changing the real rule to "show everything" left it passing.

**The recurring tell:** a fake or a probe positioned *after* the thing it
claims to verify. If the test would pass with the implementation deleted, it
is testing the fake.

---

## 3. Verify a guard in both directions.

A guard that refuses everything is as useless as one that refuses nothing,
because the first person who needs the blocked path deletes it.

The seed guard was checked by attempting real runs: `APP_ENV=production`
refused through both entry points, `development` and `staging` seeded
normally. The storage and Stripe guards were run against the real values they
exist to reject, not only the safe placeholders.

---

## 4. Watch the row move, not the 200.

An accepted request is not an applied change. Confirm the state that was
supposed to change actually changed: the database row, the object in storage,
the rendered pixels.

The watermark work ended by pulling a rewritten object back out of R2 and
looking at it, rather than trusting that the width column said 1600.

---

## 5. Never hand-write an API field name.

Read the model, the schema, or the generated client. Four separate defects
came from guessing: `niche_ids`, `bytes_size`, `body` instead of `requestBody`,
and a `meta` field on a model that has none.

A wrong field name usually fails silently - a `200` with no effect, or a
`hasattr` that is quietly false - which puts it directly in category 1.

---

## 6. Check you are testing the thing the product uses.

`/v1/discover/pros` returns no cover image for anyone. It looks like an
urgent bug and is not: the app calls `/v1/client/discover`, which resolves
covers correctly. Reporting the first would have sent someone to fix dead
code.

Before reporting a finding in an endpoint, confirm something actually calls
it.

---

## 7. Missing imports fail at runtime, not at import time.

Four paths have been taken out by a name that was used but never imported,
because Python only raises when the line runs - and in a deferred annotation,
not even then. `tests/test_no_unbound_names.py` now walks every module in
`app/` and fails on any name loaded but never bound.
