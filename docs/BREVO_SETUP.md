# Brevo: what it takes to send RAWWERS email

Status (2026-11-04): **not wired.** Every email still goes to the console provider, which logs it and reports success. What is ready:

- **The nine approved emails**, with real text (`api/app/services/email_texts.py`). Every other notification stays in-app.
- **Signed unsubscribe links** and the public `/unsubscribe` page (`services/unsubscribe.py`).
- **The `List-Unsubscribe` headers** each email must carry (`unsubscribe.headers_for`).
- **Dedupe, per-user switches, quiet hours and the daily cap**, in `notifications._send_email_from_payload`.

This page lists what the owner must do in Brevo and DNS, what the code must still do, and how to test it before the beta.

## 1. What you do (Brevo account, DNS, secrets)

Do these in order. Nothing is sent until the code in section 2 exists, so none of this risks real email going out early.

1. **Account.** Create the Brevo account for RAWWERS (company details, EU data region). Sign Brevo's data processing agreement (GDPR: Brevo is a processor of email addresses and message content).
2. **Sending domain.** Use a subdomain, so marketing tools or other senders on the main domain never affect it. For example `mail.rawwers.com`. In Brevo, open *Senders, Domains & Dedicated IPs → Domains → Add a domain*. Brevo then shows the records to add.
3. **DNS records**, exactly as Brevo shows them, at your DNS host:
   - **Brevo's verification record** (TXT).
   - **DKIM**: the record or records Brevo gives. This is what proves the mail is yours.
   - **SPF**: the subdomain's TXT record must include Brevo's SPF include. A domain may have only one SPF record: if one exists, add Brevo's `include:` to it rather than adding a second record.
   - **DMARC**: a TXT record at `_dmarc.<domain>`. Start with `v=DMARC1; p=none; rua=mailto:dmarc@rawwers.com`. After two clean weeks of reports, move to `p=quarantine`. Gmail and Yahoo require a DMARC record for bulk senders.

   Then press *Authenticate* in Brevo. All of them must show green before any test send.
4. **Sender.** Add the sender address and name, for example `RAWWERS <hello@mail.rawwers.com>`. The address must accept replies, or set a reply-to such as `support@rawwers.com`. Do not use a no-reply address: people reply to booking emails.
5. **API key.** Under *SMTP & API → API keys*, create one key used only by the API, named e.g. `rawwers-api-production`. Store it as the secret `BREVO_API_KEY`, one per environment (staging and production each get their own). Never put it in the apps.
6. **Webhook for delivery events.** Under *Transactional → Settings → Webhook*, add `https://<API_PUBLIC_URL>/v1/webhooks/brevo` with these events: delivered, soft bounce, hard bounce, blocked, spam (complaint), invalid email, unsubscribed, error. Protect it with a long random token. Use the URL form Brevo supports (a query parameter or basic-auth user), and store the token as `BREVO_WEBHOOK_TOKEN`. This URL does not exist yet (section 2).
7. **Secrets already listed in DEPLOY_CHECKLIST**, needed before the first real email:
   - `UNSUBSCRIBE_SIGNING_KEYS`;
   - `API_PUBLIC_URL` (where one-click unsubscribe lands);
   - `APP_PUBLIC_URL` (where the `/unsubscribe` page is).
8. **Plan.** The free plan's daily limit is enough for the closed beta. Check the current limit and pick a plan before the public launch.

## 2. What the code must do (not built)

### Sending
- **A `BrevoMailProvider`** in `api/app/services/mail.py`, implementing `send_template_email`. The two code emails already go through it, with approved text. It calls Brevo's transactional email API (`POST /v3/smtp/email`, header `api-key`) with:
  - sender and reply-to from settings;
  - `to` (one recipient), `subject` and `textContent` from `email_texts`;
  - the headers from `unsubscribe.headers_for(unsubscribe_url)`, sent on every email that has a link and never on security mail;
  - a tag with the `template_key`, so Brevo's reports split by email.

  It returns Brevo's `messageId`, which is stored as `email_message.provider_message_id`.
- **Settings**: `MAIL_PROVIDER` (`console` | `brevo`), `BREVO_API_KEY`, `MAIL_FROM_ADDRESS`, `MAIL_FROM_NAME`, `MAIL_REPLY_TO`, `BREVO_WEBHOOK_TOKEN`. `get_mail_provider()` picks the provider by `MAIL_PROVIDER`. In production the API refuses to start on `console`, as it does without `ADDRESS_ENCRYPTION_KEYS`.
- **Failures.**
  - *Rate limits and server errors* (429, 5xx): leave the outbox event to retry with back-off.
  - *Address or content errors* (4xx other than 429): mark the `email_message` failed with Brevo's reason. Do not retry.
  - *A timeout:* the send may have happened, so do not resend blindly. Mark it `unknown`, and let the webhook (or Brevo's message log) settle it. A duplicate booking email is worse than a late one.
- **Allow-list stays the gate.** Only `email_texts.APPROVED` types send. Adding a type means adding its approved text and its test.

### Bounces and complaints (the webhook)
- **`POST /v1/webhooks/brevo`.** It checks the token and finds the `email_message` by Brevo's message id. It updates the status (`delivered`, `bounced`, `complained`, `blocked`) and keeps Brevo's reason. Replaying the same event changes nothing.
- **A suppression list** (new table, one row per address): reason, when, and from which event. `_send_email_from_payload` checks it before sending.

  | Brevo event | What it does to the address |
  |---|---|
  | Hard bounce, invalid email | Suppressed for all email. The address does not exist. |
  | Blocked | Suppressed; Brevo already refuses it. |
  | Spam complaint | Treated as unsubscribe from everything except security (`channel_email_enabled = false`) and suppressed for non-security email. Never mailed marketing again. |
  | Soft bounce | Counted. Three within 7 days suppresses non-security email for 30 days, then it is tried again. |
  | Unsubscribed (Brevo's own link, should not happen since we send our own) | The same as our "Stop all emails". |
- **Security mail** (codes, password reset, new sign-in) still goes to a soft-bounced or complained address, but never to a hard-bounced or invalid one: it cannot arrive.
- **An admin page listing suppressions**: who, why, when. An admin can lift one with a note, for example after the person fixes their mailbox. It is audit-logged.
- **When the address changes**, the account's old suppression does not follow it.

### Content still owed
- **Portuguese** for all nine (`email_texts`, keyed by the person's locale). English only today.
- **HTML layout (optional).** Plain text is sent today. If HTML is added, it carries the same text plus the logo, and keeps a plain-text part.
- **A footer on non-security mail**: who sends it, why the person gets it, the unsubscribe link, and a postal address if marketing is ever added.

## 3. Test plan

### Automated (CI, no Brevo account needed)
- **Provider.** Against a stub of Brevo's HTTP API, the provider sends the right sender, subject, text, tag and both unsubscribe headers. It sends no headers on security mail. It retries on 429 and 5xx, stops on other 4xx, and marks a timeout `unknown`.
- **Webhook.**
  - A wrong token is refused.
  - Each event updates its `email_message`, and replaying an event changes nothing.
  - A hard bounce suppresses the address, and the next email to it is not sent.
  - A complaint switches email off except security.
  - Three soft bounces suppress the address for 30 days.
  - Security mail still goes after a complaint and not after a hard bounce.
- **Startup.** Production with `MAIL_PROVIDER=console`, or without `BREVO_API_KEY`, refuses to start.
- **Already in place:** `tests/test_email_allowlist.py` (the nine and their text, and nothing else sends) and `tests/test_unsubscribe.py` (signing, rotation, the page, one-click, security exempt).

### Staging, with the staging Brevo key
1. **Authentication.** Send one test email to a Gmail, an Outlook and an iCloud address. In each, open *Show original* (or the headers) and check that SPF, DKIM and DMARC all say `pass` for the sending domain.
2. **Deliverability.** Send one email to the address mail-tester.com gives and aim for 9/10 or better. Fix what it reports.
3. **The nine, one by one,** from the real flows on a staging account you own. Check each subject, body, date (in the person's time zone), amount and link:
   1. sign up (the verification code);
   2. forgot password (the reset code);
   3. sign in on a new device;
   4. as a client, request a booking (the photographer's email);
   5. as the photographer, accept it (the client's email, with the pay-by time);
   6. pay with a Stripe test card (the receipt);
   7. send the gallery (photos ready);
   8. mark a payout paid (payout on its way);
   9. mark a Shelf order shipped with a tracking code (the pro's email with tracking).
4. **Nothing else sends.** Trigger a notification that is not on the list, for example verify a piece of gear, and check Brevo's log shows no email for it.
5. **Unsubscribe.**
   - Gmail shows an *Unsubscribe* button next to the sender: press it. The person's switch for that topic goes off, and the next email of that topic is not sent; in-app it still shows.
   - Open the link in the email body: the page asks first, and only the button changes anything.
   - A security email still arrives afterwards.
6. **Bounces.**
   - Send to an address that does not exist at a domain you own. The hard-bounce event arrives, the address is suppressed, and a second send is skipped.
   - Replay a spam-complaint event from Brevo's webhook log and check its effect.
7. **Limits.** Send more than the daily cap (`RATE_LIMIT_NOTIFICATIONS_EMAIL_PER_DAY`, 20) of non-urgent mail to one person. Check the rest wait, and that quiet hours defer non-urgent mail.

### Before production
- **All of the staging list passes** with the production domain and key, sent to the team's own addresses only.
- **DMARC reports are clean** for a week, then move DMARC to `p=quarantine`.
- **The webhook is live**, and an alert is set for any rise in hard bounces or complaints. Brevo can suspend senders whose complaint rate passes about 0.1%.
