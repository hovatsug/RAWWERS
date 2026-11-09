# Brevo: how RAWWERS sends email

Status (2026-11-09): **wired, dev only.** The API sends the nine approved emails through Brevo's transactional API. Production stays off until `EMAIL_SENDING_ENABLED=true` is set there after the deploy.

## What is built

- **The nine approved emails, and only those** (`api/app/services/email_texts.py`). Every other notification stays in-app.
  - Sent from the outbox: verify email (the code), password reset (the code).
  - Sent as notifications: new sign-in, new booking request (to the photographer), booking accepted (to the client), payment received (to the client), photos ready to choose (to the client), payout on its way (to the photographer), Shelf order shipped with tracking (to the photographer).
- **One way out:** `services/mail.send_email`. Nothing else calls a provider, and a test fails if code does.
- **The provider:** `BrevoMailProvider` (`POST https://api.brevo.com/v3/smtp/email`, header `api-key`). Each email carries:
  - the sender and reply-to from the settings;
  - one recipient;
  - the approved subject, as text plus the same text in simple HTML;
  - a tag with the email's type, so Brevo's reports split by type.

  Non-security mail adds a footer with the unsubscribe link, plus the `List-Unsubscribe` and `List-Unsubscribe-Post` headers. Security mail (codes, new sign-in, reset) has neither. Brevo's `messageId` is stored on `email_message.provider_message_id`.
- **Failures:**
  - 429 or 5xx: the message is marked failed and the outbox retries with back-off. The next try sends it, once.
  - Any other 4xx: marked failed with Brevo's reason, not retried.
  - A timeout: marked failed ("may have been sent"), and **not** resent. A duplicate email is worse than a late one.
- **Safety:**
  - **`EMAIL_SENDING_ENABLED`**. Unset, it is **off in production and on elsewhere**. While it is off, or without `BREVO_API_KEY` and `BREVO_SENDER_EMAIL`, email only goes to the console log.
  - **Production with sending on refuses to start** unless `BREVO_API_KEY`, `BREVO_SENDER_EMAIL` and `UNSUBSCRIBE_SIGNING_KEYS` are all set.
  - **Outside production** (dev and staging), Brevo is called **only** for an address on `EMAIL_DEV_ALLOWLIST`: exact addresses, comma-separated, no domains, not case-sensitive. An empty list delivers nothing. Any other address is recorded as `blocked` (`not_on_dev_allowlist`), and Brevo is never called.
  - The test suite clears `BREVO_API_KEY` (the dev `.env` holds a real one), so no test can reach Brevo.
- **Unsubscribe** (f7341f0, unchanged here):
  - links signed with `UNSUBSCRIBE_SIGNING_KEYS` (rotatable);
  - a public `/unsubscribe` page whose button POSTs (opening the link changes nothing);
  - per-topic and "all" switches;
  - one-click `POST /v1/email/unsubscribe`;
  - security mail is exempt.
- **Bounces and complaints:** `POST /v1/webhooks/brevo`, below.

## Settings

| Variable | Dev `.env` | Production |
|---|---|---|
| `BREVO_API_KEY` | set | its own key |
| `BREVO_SENDER_EMAIL` | `rawwers@rawwers.com` | the same, or what you choose |
| `BREVO_SENDER_NAME` | default `RAWWERS` | `RAWWERS` |
| `BREVO_REPLY_TO` | optional | optional (`support@rawwers.com`?) |
| `EMAIL_SENDING_ENABLED` | unset (on) | `true` only when ready |
| `EMAIL_DEV_ALLOWLIST` | **your one test address** | not used |
| `BREVO_WEBHOOK_TOKEN` | empty (route off) | a long random token |
| `UNSUBSCRIBE_SIGNING_KEYS` | optional (dev key) | required |
| `API_PUBLIC_URL`, `APP_PUBLIC_URL` | localhost | the https URLs |

`BREVO_MCP_SERVER_KEY` in the dev `.env` is not read by the API.

All of these are read by `api`, `worker`, `worker-photos` and `beat`: the worker does the sending, from the outbox. After changing `.env`, recreate them (`docker compose up -d --force-recreate api worker worker-photos beat`); `restart` does not re-read the file.

## Brevo's authorised IPs

Brevo refuses an API key used from an IP it does not know: `401 "We have detected you are using an unrecognised IP address …"`. The first dev send (2026-11-09) hit this. In Brevo, *Security → Authorised IPs*: add the dev machine's public IP (it changes with the network), or turn the restriction off for the dev key. Production: add the server's outbound IP for the production key. The API treats this 401 as a rejection: logged, not retried.

## The sending domain: what Brevo needs verified

The sender is `rawwers@rawwers.com`, on the root domain, which also receives mail through Zoho. Public DNS on 2026-11-09 shows:

| Record | Found | What to do |
|---|---|---|
| Brevo verification (`TXT rawwers.com "brevo-code:…"`) | present | none |
| DKIM (`brevo1._domainkey`, `brevo2._domainkey` CNAMEs to `…dkim.brevo.com`) | present | none; check Brevo shows them green |
| SPF (`TXT rawwers.com "v=spf1 …"`) | `v=spf1 include:dc-8e814c8572._spfm.rawwers.com ~all`, **and that include does not resolve** | **Fix.** Replace it with one record naming both senders, for example `v=spf1 include:zohomail.eu include:spf.brevo.com ~all`. Keep one SPF record only. |
| DMARC (`TXT _dmarc.rawwers.com`) | `v=DMARC1; p=quarantine; adkim=r; aspf=r; rua=…` | none. It passes through Brevo's DKIM (aligned on rawwers.com). |

As it stands, SPF fails for every sender on the domain, Zoho included. DMARC still passes through DKIM, but some receivers score a broken SPF down. In Brevo, open *Senders, Domains & Dedicated IPs → Domains → rawwers.com*: all its checks must be green before a production send.

**Root domain or a subdomain.** Sending from the root domain shares its reputation with your own mailbox. A subdomain (`mail.rawwers.com`) keeps them apart, at the cost of a second set of records. Either works for the beta; this is your call.

## The delivery-event webhook (`POST /v1/webhooks/brevo`)

- **Off while `BREVO_WEBHOOK_TOKEN` is empty** (answers 404). That is the case in dev, where Brevo cannot reach `localhost`.
- **In production:** in Brevo, *Transactional → Settings → Webhook*, add `https://api.rawwers.com/v1/webhooks/brevo`. Pass the token as `Authorization: Bearer <token>` (Brevo's webhook authentication) or as `?token=<token>` in the URL. A wrong or missing token gets 401. Subscribe to these events: hard bounce, soft bounce, blocked, spam (complaint), invalid email, unsubscribed, delivered, error.
- **What each event does** (`services/brevo_events.py`, `services/email_suppression.py`, migration `0091`):

  | Brevo event | Effect |
  |---|---|
  | hard bounce, invalid email, blocked | Nothing is sent to the address again, not even security mail: it cannot arrive. |
  | spam (complaint) | The account's email is switched off. Non-security mail is never sent again; security mail still goes. |
  | unsubscribed (Brevo's own link) | The same as our "Stop all emails". |
  | soft bounce | Counted. Three within 7 days stop non-security mail for 30 days. |
  | delivered, opened, others | Recorded on the message only. |

  Every event is recorded on its `email_message` (`metadata.delivery` and `metadata.delivery_events`). Replaying one changes nothing. A suppression only grows. It is keyed by address, so a new address starts clean.

## Still to do

- **Production:** a Brevo key for production, `BREVO_WEBHOOK_TOKEN`, the webhook above, and `EMAIL_SENDING_ENABLED=true`, all after the deploy.
- **An admin page for suppressions** (list them, lift one with a note). Today they are lifted in the database only.
- **Portuguese** for the nine.
- **Launch and waitlist emails** are not on the approved list, so nothing is sent for them.
- **Verify and reset codes** have no `email_message` row of their own. Their send is logged, and Brevo's log has them.

## How to send one real test email (dev)

1. In `api/.env`, set `EMAIL_DEV_ALLOWLIST=<your test address>`. That address only.
2. Rebuild and recreate the API and the workers, so they run this code and read `.env`:

   ```sh
   cd api
   docker compose build api worker worker-photos beat
   docker compose up -d --force-recreate api worker worker-photos beat
   ```
3. Trigger a password reset for an account whose email is that address. The fastest way is to register with it in either app, which sends the verify code. Or:

   ```sh
   curl -X POST localhost:8000/v1/auth/password-reset/request \
     -H 'content-type: application/json' \
     -d '{"email":"<your test address>"}'
   ```
4. Check `docker compose logs worker | grep mail_brevo_sent` (the address is masked in the log). The email arrives from `RAWWERS <rawwers@rawwers.com>`. In the mail client, *Show original* should show SPF, DKIM and DMARC. Expect SPF to fail until the record above is fixed.
5. Any other address is logged as `mail_blocked … not_on_dev_allowlist`, and Brevo is not called.
