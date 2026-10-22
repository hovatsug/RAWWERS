# RAWWERS: cancellation standard, no-show protection and the WhatsApp channel

This prompt replaces the earlier piecemeal instructions on cancellation, no-shows and high-stakes bookings. It is a discovery task: read the code, write a report, propose a build order, then STOP and wait for approval. No code, no migrations, no commits.

Standing process still applies for anything built later: tests first with break checks, isolated database, at most 3 parallel suites, by-name failure diff against `KNOWN_FAILURES.txt`, a clean worktree per commit, a byte-identical branch check, DEPLOY_CHECKLIST.md entries, and a how-to-see note at the end of each report.

---

## Principles (decided)

1. **One RAWWERS standard.** Cancellation terms are the same for every photographer and are set by RAWWERS only. No per-photographer field, setting or override anywhere. Booking, package and gig routes must reject any such input, and a test proves it.
2. **A refund is the floor.** For a wedding the real protection is prevention, early detection and rescue. Compensation comes last.
3. **Fast and verified.** Two lanes for a no-show: a fast lane that returns money in minutes when the evidence is clear, and a contested lane that holds money while an admin decides.
4. **Fairness is untouched.** Nothing here changes ranking, row membership or row order. Photographer cancellation and no-show consequences are options in the report only, never applied to ranking without my approval.
5. **Honesty about reach.** State plainly, for every feature, what works with no push notifications, no WhatsApp and no SMS.

---

## Part 1: The platform cancellation standard

### Draft schedule (numbers are a draft for me to confirm, so store them as policy, not code)

| Situation | Refund to the client |
|---|---|
| Client cancels more than 7 days before the shoot | 100% |
| Client cancels from 7 days down to 48 hours before | 50% |
| Client cancels under 48 hours before | 0% |
| Short-notice ("Available now") booking | 100% within 15 minutes of paying, then 0% |
| Photographer cancels | 100%, always |
| Client no-show | 0% |
| Photographer no-show | 100%, plus the dispute path |
| Reschedule | One free reschedule more than 48 hours before, if the photographer agrees to a new time |

### Structural rules
- One server function computes the refund and the photographer's share from the gig's schedule. Nothing else computes it.
- The schedule lives in an admin-editable policy row with an audit trail. It is stamped on the gig at payment, so a later change never alters an existing booking.
- A cancellation refund that returns the full amount cancels the gig, releases the calendar hold and revokes finals downloads. A partial cancellation refund also cancels the gig, because the shoot is not happening. An admin goodwill or dispute partial refund leaves the gig alone.
- No $RAWW is created for a cancelled booking.
- Until this is built, self-service refunds stay off outside dev, and the interim rule (the earlier of 24 hours after payment and the shoot start, none once finals are released or the gallery is published) stays. This standard replaces the interim rule.

### Report first
1. Where cancellation and refunds are decided today: client cancel of a booking request, gig cancel, cancel-slot, reschedule-request, client refund, admin refund and its retry, dispute no-show claims, admin goodwill. Map each to the new standard.
2. How it fits the gig statuses, including the refunded status from the money work, and which statuses release the hold.
3. Earnings for each case: pending, available, and already paid out. Propose a clawback or negative-balance path for a refund that arrives after payout. State what happens to the platform's share. Stripe generally keeps processing fees on a refund, so state that cost.
4. How short-notice bookings are identified (use the snapshot flag stored on the request and gig).
5. How the schedule is shown in one plain line before payment ("Free cancellation up to 7 days before. 50% up to 48 hours before. No refund after that."), on the receipt and in the terms, and how that text is generated from the policy so it can never disagree with the code.
6. Reschedule: how "one free reschedule" interacts with holds, notice rules and the six-path agreement, and what happens when the photographer declines the new time.
7. Stripe mechanics for partial refunds, reusing the idempotency design from the money work (stable key for unknown outcomes, new key only after a terminal failure, check Stripe's refunded total first). Ledger lines written once per refund id.
8. Flag for a lawyer: UK and EU consumer rules on cancelling distance-sold services, including exceptions for dated services. Do not encode legal conclusions. Launch is UK first.

---

## Part 2: Photographer no-show

### Report first
1. **Reporting window.** Clients can report from 15 minutes after the start time. Reports later than that, up to 24 hours, go to review.
2. **Check-in and evidence.** A photographer "I've arrived" button that records a timestamp and a coarse location captured only at the moment of check-in, with consent. Report privacy implications and retention. Other evidence that already exists: chat timestamps, the photographer's response to the report, photos uploaded during the shoot window, and claim history on both sides.
3. **Fast lane.** If the client reports, the photographer has not checked in, and there is no photographer response within 30 minutes of the report, the client gets an automatic refund or a replacement credit.
4. **Contested lane.** If the photographer asserts they arrived, or the evidence conflicts, the money is held and an admin decides within an SLA you propose (a draft of 48 hours). Investigation decides consequences and detects false claims. In the fast lane it does not decide whether the client is refunded.
5. **Replacement.** Candidates are Available-now photographers with fresh presence in the client's city, same niche first, plus the opt-in emergency-cover pool from Part 3. Report both designs: broadcast to several with the first accept winning, and client-chosen. The winner must be atomic, every other hold released, and the replacement photographer must explicitly accept (no unilateral gig creation). The client sets a budget that defaults to the amount paid.
6. **Money.** The original payment is applied to the replacement through an internal ledger link. Only the leftover goes back to the client as a partial refund, and the client tops up if the replacement costs more. Invariant: funded plus refunded never exceeds the original captured amount. Report feasibility with the current Stripe and ledger design, and treatment of the platform share and $RAWW.
7. **Photographer consequences.** Options only. Silence should be the worst outcome: a silent no-show means suspension and clawback, while early notice (illness, an accident) gets a lighter outcome. No ranking or row effects.
8. **Abuse.** A client falsely claiming a no-show after the shoot happened. Propose limits, claim history signals and the evidence that defeats a false claim.

---

## Part 3: High-stakes bookings

### Definition (default, configurable, my decision to confirm)
A booking is high-stakes if its package is full-day, or its niche is weddings. Make this a configuration, not a hardcoded rule, and report what changes if it is weddings only.

### Report first
1. **Confirmation cadence.** Reminders at 7 days, 48 hours, 24 hours and the morning of. The photographer must confirm at 48 hours. An unconfirmed booking escalates to ops. The client sees "Photographer confirmed".
2. **Day-of check-ins.** "On my way" and "I've arrived". No "on my way" one hour before triggers alerts to the photographer and ops. Not arrived 15 minutes before the start starts the rescue automatically.
3. **Calling.** Whether the existing outbound calling feature can ring the photographer, and what it would take.
4. **Emergency-cover pool.** Opt-in photographers who are free on a given date (use the calendars) and accept a cover bonus. Propose what the bonus is and how it is funded. Do not decide.
5. **Consequences and compensation beyond a refund.** Options only: terms limited to a refund plus a rescue effort, a goodwill credit, a capped guarantee funded from a reserve, insurance. State the funding and legal questions each raises. Nothing is advertised as a guarantee until it is funded.
6. **Photographer cancellations inside 7 days.** Options for consequences, and keeping earnings on hold until delivery.
7. **Closed beta.** Recommend whether weddings are excluded or handled by hand until prevention and a reliable channel exist.

---

## Part 4: The WhatsApp channel

Use the official WhatsApp Business Platform (Cloud API). Never use unofficial libraries or QR-code automation: they break the terms and a banned number takes out the channel exactly when it is needed.

Build it as one channel inside the generic notification mechanism (email through Brevo is the first channel), with per-channel preferences, a delivery log and status webhooks. If that mechanism does not exist yet, report that and propose building it first. No one-off sends.

### Report first
1. Compare the Cloud API directly, a provider (Twilio, Brevo's WhatsApp offering, 360dialog or similar), and anything already in the stack (the outbound call feature). Report API, webhook, template-management and cost differences.
2. List every template needed: confirmation requests at 7 days, 48 hours, 24 hours and the morning of, day-of alerts, the rescue broadcast, client updates. Keep all of them strictly utility, with no promotional wording (a utility template that reads as marketing is reclassified at a higher price). Template messages are the only message type that can be sent outside a 24-hour customer service window, so every alert needs an approved template.
3. Opt-in capture, phone number verification by one-time code, STOP handling.
4. Button replies ("Confirm", "Can't make it", "Accept", "Decline"): idempotent, and an atomic first-accept for the rescue broadcast.
5. Delivery-status and reply webhooks with signature verification, and a message log.
6. Fallback ladder with timings: WhatsApp, then SMS, then an automated call, then an ops alert and a human call for high-stakes bookings. A delivered message is not a confirmation: only a button reply counts.
7. Quiet-hours rules, and whether day-of alerts are exempt.
8. A cost estimate for 100 photographers and 1,000 clients in the UK, Portugal and Brazil from Meta's current rate card. Note that from 1 October 2026 free-form replies and utility templates inside the customer service window are also charged.
9. Privacy: minimal message content (no full addresses, no client phone number), what Meta retains, UK GDPR basis.
10. Setup steps the owner must do (Meta business verification, display name, phone number, template approvals) with expected lead times. These start before any code.
11. Local development with Meta's test number, and what is blocked until deployment (webhooks need a public URL, the same limitation as Stripe, Mux and Brevo).
12. What still works if WhatsApp is down.

---

## Open decisions (report options with a recommendation, do not decide)
- The exact refund numbers and the 15-minute, 48-hour and 7-day boundaries.
- The no-show SLA and the fast-lane timings.
- The high-stakes definition.
- The cover bonus, and how it and any guarantee are funded.
- Consequences for silent no-shows and late cancellations.
- Whether RAWWERS acts as agent or seller (this decides liability and needs a lawyer; incorporation is not decided).

## Tests required when building is approved
- Table-driven boundaries: exactly 7 days, exactly 48 hours, exactly 15 minutes, with time zones and DST.
- Snapshot immunity: changing the policy never changes an existing gig.
- Two photographers accepting a rescue at once: exactly one wins and every other hold is released.
- Double refund attempts and concurrent requests: one refund, one ledger line.
- Invariant test: funded plus refunded never exceeds the captured amount.
- A false no-show claim after the shoot happened.
- Booking, package and gig routes reject any per-photographer cancellation input.
- Break checks on every rule, and a by-name failure diff.

## Final deliverable of this task
A written report covering Parts 1 to 4, what works with no push, WhatsApp or SMS, a proposed build order in small commits, the owner-setup list with lead times, and DEPLOY_CHECKLIST.md entries for the blocks-real-client-launch list. Then stop.
