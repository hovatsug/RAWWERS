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
