# Payouts v1

## Ledger-first philosophy

Payouts are derived from deterministic earnings ledger entries, not from provider callbacks.

- `earnings_ledger_entry` is the source of truth for pro earnings.
- Each source (`gig_base`, `extra_images`, `studioverse_sale`) is idempotent by `(source_type, source_id, pro_user_id)`.
- Amounts are EUR-only in v1 and stored as `numeric(12,2)`.
- Fee snapshot is stored per entry in `metadata` for auditability.

## Settlement and hold rules

1. Entry creation:
- `gross_eur` from verified paid source.
- `platform_fee_eur` from current `platform_fee_policy` snapshot.
- `net_eur = gross_eur - platform_fee_eur`.
- Initial status: `pending` (or `held` if matching active hold exists).

2. Availability worker:
- Periodically promotes due entries (`now >= available_at`) from `pending` to `available`.
- If source-scoped or hold-all hold exists, entry remains `held`.

3. Disputes/refunds:
- On dispute open against pro, create `earnings_hold` for related source.
- On no-refund resolution, release relevant holds.
- On refund success, reverse related earnings entries (`status=reversed`) and release related holds.

## Payout flow

1. Pro requests payout (`/v1/pro/payouts/request`):
- amount must be >= minimum (`€50` by default).
- amount must be <= withdrawable balance (`available - reserved allocations`).
- rate limited to 2 requests per 7 days.

2. Admin approves payout:
- deterministic allocations are created (`payout_allocation`) against available entries.
- outbox event `payout.execute` is enqueued.

3. Execution:
- Manual mode: request moves to `processing`, then admin marks paid with reference.
- Stripe Connect mode: transfer is created using payout request idempotency key.

## Stripe Connect migration path

The ledger and allocation model is provider-agnostic.

- Existing `payout_request` and `payout_allocation` remain unchanged.
- `payout_account` already stores Connect account IDs.
- `payout_request.reference` stores provider transfer/payout identifiers.
- Future migration only changes execution worker behavior, not earnings accounting.

## Tax and invoice hooks

- `tax_profile` stores VAT profile placeholders (country/legal name/VAT/address reference).
- Invoice generation is not enforced in v1 but ledger metadata is sufficient for invoice generation jobs.

## Ops runbook

### Daily payout operations
- Review `/v1/admin/payouts?status=requested`.
- Approve valid payouts, then execute/manual mark paid.
- Verify `payout_event` timeline and audit logs for each payout.

### Reconciliation
- Compare paid payout requests vs provider references in `payout_request.reference`.
- Investigate any `failed` status and retry after fixing account/method details.

### Hold and refund incidents
- Create manual holds via `/v1/admin/holds/create` for risk/compliance events.
- Release holds when risk clears via `/v1/admin/holds/{hold_id}/release`.
- For confirmed fraud/refund, reverse affected earnings entries (automatic in refund/dispute flow).

### Emergency controls
- Pause approvals operationally and keep requests in `requested`.
- For provider outages, keep payouts in manual mode and defer mark-paid until transfer confirmation.
