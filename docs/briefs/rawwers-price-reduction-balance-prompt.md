# RAWWERS — Price reduced after payment: refund, earnings, wallet balance, photographer accountability

Save this file verbatim as `docs/briefs/rawwers-price-reduction-balance-prompt.md`, then do the task below.

## What happened (owner's test booking, dev)

- The client paid **€63.79**.
- About 20 photos were not delivered and the price was reduced. Booked amount **€52.43**, platform fee **€10.48**, photographer cash earned **€41.95** (52.43 − 10.48 = 41.95).
- The pro app Wallet shows **"Available to withdraw €63.79"**. It should show €41.95. The wallet credited the photographer with the client's whole original payment and never followed the price drop.
- **The client was never refunded the difference** (63.79 − 52.43 = €11.36, unless part of that is a client-side fee or VAT; find out). Nothing on the "Money to act on" admin page flagged it either.
- If a payout had been approved on this balance, RAWWERS would have overpaid by €21.84 on one booking.

The existing payout tests check limits against the balance. None checks that the balance itself is right.

## Decisions already made (do not reopen)

1. **The client always gets the full price difference back** when the amount they owe is lowered after payment. Automatically, through the existing reconciled refund path. Not discretionary.
2. **The photographer is paid only for what was delivered.** No earnings on undelivered work. This is accounting, not a penalty.
3. **A photographer who fails to deliver what was sold is accountable**, but only after a recorded fault finding (never automatic on a guess), with a proportionate, graduated ladder, due process (notice, chance to respond, appeal), and no new ranking inputs (see Part C).
4. Policy numbers (strike thresholds, windows, reason codes) are **data**: stored in an admin-editable policy row, not hardcoded.
5. Honesty-first copy. No hardcoded numbers or amounts anywhere. The server is the source of truth; the app only displays.

## Process rules (as always)

Tests first, and prove every new rule with a break check (break the rule, the test must fail). Isolated DB per run (`make test-isolated`), max 3 parallel suites. Full suite diffed by name against `docs/KNOWN_FAILURES.txt` (26 known). A clean worktree per commit, byte-identical branch check at the end. Each commit gets a DEPLOY_CHECKLIST.md entry if it needs one, and a "how to see it" note. Stop and report where this brief says to. Do not edit data in dev to "make it right": give me the repair steps instead.

---

## PART A — Discovery (report only; build nothing; then stop and wait for approval)

Read the code, not the docstrings. Report every item.

### A1. This booking, line by line
- Every payment on the booking: amount, type (base, difference, extras, content pack), status, Stripe id.
- Every ledger line (client side and photographer side): type, amount, reference, status, created_at, and which of them add up to 63.79.
- What the 11.36 between the client's payment (63.79) and the booked amount (52.43) is: a client service fee, VAT, or the overpayment from the price reduction. Where is each stamped on the gig (stamped-at-creation fields), and where does each go in the ledger? Is VAT collected anywhere, and where is it tracked?
- The gig's status history. Was a gallery delivered? How many photos were delivered, and how many were expected?

### A2. How the price got reduced
- Find every code path that can lower what a client owes or what a photographer earns **after** a payment exists: undelivered or partially delivered photos, an admin price edit, a dispute resolved with a partial refund, extras or selection changes, any sweep or job. For each: who or what triggers it, what it changes (gig final amount, platform fee, earnings, ledger, RAW credit), and whether it refunds the client or records that the client is owed.
- Which one did this booking go through? If it cannot be told from the data, say so.
- Which paths lower the amount **without** touching the earnings ledger, and which refund the client **without** reducing earnings.

### A3. The wallet and the money functions
- Which function computes "Available to withdraw", which computes "Pending / On hold / Reserved", and which computes the "All time / Cash earned" card? Do they read different sources? Where does the RAW credit line come from, and is it ever included in a withdrawable sum?
- The amount a Stripe Connect transfer would actually send when a payout is requested, approved and marked paid for this account. Report only; send nothing.
- Whether the payout request limit uses the same function as the Wallet.
- The display problem on "All time": Booked 52.43 − fees 10.48 + RAW credit 2.62 shown as a column does not add up to Cash earned 41.95 (the credit is not cash). Describe how the card is built.

### A4. Dev audit of every photographer
For each photographer with ledger lines: available + pending + on hold + reserved + paid out vs lifetime cash earned. List every account that does not reconcile and by how much. Check whether any payout in dev was requested or paid on an inflated balance. Also list every booking where the client paid more than the gig's current amount and no refund exists.

### A5. Fault and accountability today
- What `pro_fault_event` records, who can write it, and what reads it. (I believe ranking reads it only through `disputes_count`, and the match score's dispute penalty and the "high reliability" reason. Confirm exactly where, and confirm nothing else reads it.)
- What a photographer sees today when they are found at fault. Is there any notice, appeal or strike count? Is there any account-level consequence (booking pause, suspension)?
- How suspensions and bans work and what they revoke.
- The notification channels that exist today for telling a photographer something (in-app only? email prints to console).

### A6. The repair for this booking
Propose exact steps and the expected end state: client refunded €11.36 (or whatever A1 shows), photographer cash €41.95, platform keeps €10.48, wallet shows €41.95, and the "All time" card agrees. Do not run it, and do not use the partial-refund route to do it unless you can show it gives exactly that end state (a partial refund reduces earnings by the refunded share, which would be wrong here).

### A7. Report format
One table of findings per area, then a short list of "needs a decision from the owner". Say plainly where a rule is missing, where two code paths disagree, and anything that would make a real payout wrong. Then **stop and wait**.

---

## PART B — Build (after I approve the report)

Order: B1, B2, B3, then Part C. Each its own commit.

### B1. One source of truth for photographer money
- One function computes a photographer's withdrawable cash and lifetime cash earned from the ledger. The Wallet cards, the payout request limit, the payout approval and the Stripe transfer amount all call it. No second implementation.
- The photographer is credited only: booked amount − platform fee. Never the client's service fee, VAT, or any amount refunded to the client.
- Invariant test across scenarios: `available + pending + on_hold + reserved + paid_out == lifetime cash earned`. Scenarios: completed, difference payment, extras, price reduced, refunded, part-refunded, disputed, chargeback won, chargeback lost, payout requested, payout paid, payout rejected, RAW credit minted and reversed.
- A test that a payout request can never exceed withdrawable cash, and that approval re-checks it.
- Wallet card layout: Booked, Platform fees, Cash earned add up. The RAW credit is a separate line below, labelled as gear credit that is not withdrawable, never inside the sum.
- Break checks for each rule above.

### B2. One function for any reduction after payment
Any path that lowers the amount a client owes after payment goes through **one** function, which does three things in one transaction:

1. Updates the gig's amount fields (final amount, platform fee, VAT or client fee if stamped), using the **same pricing code that computes the charge** (one function, two callers, like the selection quote). It never reimplements the math.
2. Recomputes the photographer's earnings from the new amount (ledger adjustment, remainder-based money math, RAW credit adjusted or reversed to match).
3. Refunds the client the **full difference between what they paid and what the new amount requires** through the existing reconciled refund path: a refund case, one refund in flight per payment, `amount_refunded` updated, one ledger line per refund id. Idempotent: the same reduction applied twice refunds once (key the refund to the reduction event).

Rules:
- Every reduction needs a **reason code** from admin-editable data: `photographer_non_delivery`, `client_selected_fewer`, `mutual_agreement`, `admin_goodwill`, `dispute_resolution`. Free-text note required. Audited with the actor.
- If the refund cannot be issued or fails, the reduction does not silently complete: raise a "client owed" item on "Money to act on" with the amount, the booking, and the reason. Never a silent state.
- The refund never exceeds what is left on the payment (existing cap). Several payments on a booking: refund from the most recent first, and say so in the audit trail.
- Admin-only to trigger manually. System-driven reductions (if A2 finds any) use the same function.
- A reduction does not touch the gig's status unless the existing state machine already requires it.
- Tests: one per path found in A2, each with break checks that fail if any of the three parts is missing. Also: reduce twice (idempotent), reduce after a partial refund exists, reduce with a chargeback open (refuse and explain), reduce below what was already paid out (negative-balance case; see below).
- **After payout:** if earnings were already paid out and the reduction lowers them, do not silently go negative. Record a receivable against the photographer's future earnings (a clawback line) and raise an admin item. Do not build collection beyond that.

### B3. The "client owed" alerts
Make sure any state where a client is owed money (a reduction whose refund is pending or failed, a price below what was paid) appears on "Money to act on" with the amount, oldest first. Add a test. An admin closes it with a note saying what was done.

---

## PART C — Photographer accountability for non-delivery

Principle: **pay for what was delivered; hold people accountable for what they promised and did not deliver; do it fairly and visibly to them; never by guesswork.**

### C1. When it applies
Only when a reduction carries the reason code `photographer_non_delivery` **and** an admin has recorded a fault finding on it (this writes `pro_fault_event`, as today). The system never decides fault on its own. A reduction for `client_selected_fewer`, `mutual_agreement`, `admin_goodwill` is never a penalty.

### C2. Due process
- Before a finding takes effect, the photographer is notified (in-app; also email once it exists) with what happened, the booking, the amount, and **7 days (configurable) to respond or contest**.
- Their response is stored with the finding. An admin confirms or withdraws it after the window or on their reply. A withdrawn finding leaves no strike.
- The photographer can see their own findings and strike count in the pro app. Never public. Never shown to clients.

### C3. Consequences ladder (all values in the admin-editable policy row)
1. **Always**: no earnings on undelivered work (Part B). Not a penalty.
2. **First confirmed finding in the rolling window (default 12 months)**: a recorded warning, shown to the photographer with plain copy on what is expected.
3. **Second**: their new-booking acceptance is paused until an admin reviews it (the existing booking-acceptance gate; the training re-take is available as an option the admin can require). Existing bookings are not touched.
4. **Third or more**: suspension review by an admin (the existing suspension path, which revokes sessions and switches off Available now).
5. **Severity override**: an admin can mark a single finding as severe (for example, no delivery at all for a wedding or other high-stakes booking) and skip steps. This needs a note and is audited.
6. Optional, default OFF and listed as an owner decision: goodwill credit to the client funded by clawing back a capped share of the photographer's earnings. Do not build it unless I say so.

### C4. Ranking
**No new ranking inputs.** Fault findings keep affecting ranking only through the narrow path that exists today (`disputes_count`, the match score's dispute penalty, the "high reliability" reason). Add or keep a test that holds this: fault events are read in that one place only. Strikes, warnings and pauses never feed ranking. Response time, presence and video never feed ranking either.

### C5. Fairness and safety rails
- Rate of findings per admin and per photographer is visible on the admin page so abuse is detectable.
- A photographer cannot be penalised for a reduction that happened because of the client's choice or a platform bug. The reason code is required and is shown to the photographer.
- Every step is audited (who, when, what, note).
- Penalties are never applied retroactively to findings made before this policy exists.

---

## Admin and app surfaces (minimal)
- Admin: on the booking, a "Reduce price" action (reason code, note, preview of the client's refund and the photographer's new earnings **before** confirming). On the photographer page: findings, strikes, response and decision. Policy row editable.
- Pro app: Wallet cards fixed (B1); "Findings" list in settings with the contest action.
- Client app: the refund shows as a refund with the reason in plain words.

## Reporting
For Part A: the report and stop. For Part B and C: per commit, what changed for users, test and break-check counts, full-suite diff by name against the known failures, the migration up/down/up result, any data repair as steps (not run), the DEPLOY_CHECKLIST.md entries, and "how to see it" with dev logins.

## Not in this task
No notifications build (email via Brevo and WhatsApp are separate). No cancellation standard (separate brief). No payout collection. No change to ranking inputs. No Stripe live-mode changes.
