# What the privacy notice must say

RAWWERS has no privacy notice yet (DEPLOY_CHECKLIST.md, section 5). This file
collects, as each feature is built, what that notice must cover, in plain
words a lawyer can turn into the final text. It is input, not the notice,
and it draws no legal conclusions.

## Your IP address when you view or download your photos

**Draft wording:**

> When you view or download the photos from your booking, we record the
> date and time, the device or browser you used, and your IP address. We
> keep your IP address for 120 days, or for longer only while a payment
> dispute about that booking is still open, and then delete it. We use it
> only to show your bank or card issuer that the photos were delivered, if
> a payment for that booking is disputed. We keep a scrambled form of it
> (which cannot be turned back into your address) for longer, to detect
> misuse of shared links.

**What the code does** (so the text can be checked against it):

- Recorded on every view or download of a booking's photos by the booking's
  own client: `media_access_log.ip_address`, next to `ip_hash` (a peppered
  SHA-256) and the user agent.
- Not recorded raw for anyone else: the photographer, or a visitor through a
  share link, gets the hash only.
- Cleared after `MEDIA_ACCESS_RAW_IP_RETENTION_DAYS` (120) by the daily
  `purge_raw_access_ips` job, except while the booking has a chargeback
  whose evidence is still due (an open "Chargeback: evidence due" item).
- The hash is not cleared by that job; how long it is kept is not yet
  decided anywhere and the notice needs a figure.
- Not shown in any screen or API response. Read only to prepare chargeback
  evidence, which an admin reviews and submits to Stripe.
- Shared with: Stripe, and through it the card issuer, only as dispute
  evidence for that booking.

**For the lawyer:** the purpose is defending a payment dispute (a legal
claim); likely basis legitimate interests (UK GDPR Art. 6(1)(f)), to be
confirmed, along with the retention period.

## Backups (deleted data stays in them until they expire)

**Draft wording:**

> Encrypted copies of the database are kept for disaster recovery: one a
> day for 35 days and one a month for 12 months. When an account is
> deleted it is removed from the live service at once, but it remains in
> these copies until they expire, at most 12 months later. The copies are
> never used except to recover from a failure; if one is restored,
> deletions made since that copy are carried out again.

**What the code does** (deploy/scripts/backup-offsite.sh,
docs/RESTORE_PLAYBOOK.md):

- Every night at 03:30 UTC a full copy of the database, encrypted on the
  server with a key only the owner holds, goes to a separate Cloudflare R2
  bucket (EU jurisdiction if offered); the first copy of each month is kept
  12 months, the others 35 days, a copy made before each deploy 35 days.
  Every 6 hours before the first real payment: those extra copies are kept 3
  days.
- The bucket's locks stop anyone deleting a copy early, including us; the
  lifecycle rules delete each copy when its time is up.
- **Anything deleted on a schedule is also in the copies until they expire**:
  for example a client's raw IP address, cleared from the live database
  after 120 days (above), stays in the monthly copies up to 12 months. The
  IP wording above needs the same "except in backups" sentence.
- A restore is followed by carrying out again the deletions made since the
  copy (RESTORE_PLAYBOOK.md, "Carry out deletions again"). Account deletion
  itself is not built yet (BETA_SCOPE #9).

**For the lawyer:** whether 12 months is proportionate for the monthly
copies, and how the notice should describe deleted data that remains in
backups.
