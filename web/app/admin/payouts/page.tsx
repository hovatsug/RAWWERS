"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type PayoutQueueRow } from "@/lib/api/admin";
import {
  AdminButton,
  ConfirmDialog,
  DataTable,
  PageHeader,
  StatusBadge,
  money,
  type Column
} from "@/app/admin/_components/ui";

/**
 * Payout requests awaiting a decision.
 *
 * Everything needed to approve is on the row: who, how much, where the money
 * would actually go, and what their ledger says. A payout approved to an
 * account that cannot receive it is a failure you find out about from the
 * photographer. Both steps - approving, and recording that the money was
 * sent - go through a confirmation that names the amount and the person.
 */
export default function AdminPayoutsPage() {
  const queryClient = useQueryClient();
  const [dialog, setDialog] = useState<{ row: PayoutQueueRow; action: "approve" | "paid" } | null>(null);

  const query = useQuery({ queryKey: ["admin", "payout-queue"], queryFn: () => admin.payoutQueue() });
  const items = query.data?.ok ? query.data.data.items : undefined;
  const waiting = items?.filter((row) => row.status === "requested").length ?? 0;

  const columns: Column<PayoutQueueRow>[] = [
    {
      header: "Photographer",
      cell: (row) => (
        <div>
          <p className="font-medium text-slate-50">{row.display_name || row.email || "Unnamed"}</p>
          <div className="mt-1 flex flex-wrap gap-1">
            {row.lifetime_payouts === 0 ? <StatusBadge label="First payout" tone="info" /> : null}
            {row.exceeds_withdrawable ? <StatusBadge label="More than they can withdraw" tone="attention" /> : null}
          </div>
        </div>
      )
    },
    { header: "Amount", className: "tabular-nums", cell: (row) => <span className="font-semibold">{money(row.amount_eur)}</span> },
    { header: "Status", cell: (row) => <StatusBadge status={row.status} /> },
    {
      // Manual bank transfer is a real route and currently the only one that
      // works end to end, so it is not presented as a problem.
      header: "Goes to",
      cell: (row) => (
        <div className="text-xs">
          <p className="text-slate-300">{destination(row)}</p>
          {row.approval_blocked ? <p className="mt-1 text-amber-200">{row.blocked_reason}</p> : null}
        </div>
      )
    },
    {
      header: "Ledger",
      cell: (row) => (
        <p className="text-xs tabular-nums text-slate-400">
          Withdrawable {money(row.withdrawable_eur)} · available {money(row.available_eur)} · settling {money(row.pending_eur)}
        </p>
      )
    },
    {
      header: "",
      className: "w-px whitespace-nowrap text-right",
      cell: (row) => (
        <div className="flex justify-end gap-2">
          <AdminButton
            disabled={row.approval_blocked || row.status !== "requested"}
            title={row.approval_blocked ? "The money could not actually be sent - see the reason on the row." : undefined}
            onClick={() => setDialog({ row, action: "approve" })}
          >
            Approve…
          </AdminButton>
          <AdminButton
            tone="secondary"
            disabled={!["approved", "processing"].includes(row.status)}
            onClick={() => setDialog({ row, action: "paid" })}
          >
            Mark paid…
          </AdminButton>
        </div>
      )
    }
  ];

  const row = dialog?.row;
  const who = row ? row.display_name || row.email || "this photographer" : "";

  return (
    <>
      <PageHeader
        title="Payouts"
        description={items === undefined ? "Withdrawal requests from photographers." : waiting === 0 ? "Nothing waiting." : `${waiting} waiting on a decision.`}
      />
      <DataTable
        columns={columns}
        rows={items}
        rowKey={(r) => r.payout_request_id}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : query.error ? "Check that the API is reachable." : null}
        onRetry={() => query.refetch()}
        empty={{ title: "No payout requests", body: "Requests appear here when a photographer withdraws." }}
      />

      <ConfirmDialog
        open={dialog?.action === "approve"}
        title={`Approve ${money(row?.amount_eur)} to ${who}?`}
        confirmLabel={`Approve ${money(row?.amount_eur)}`}
        onClose={() => setDialog(null)}
        onConfirm={async () => {
          if (!row) return null;
          const res = await admin.approvePayout(row.payout_request_id);
          if (!res.ok) return res.error.message;
          queryClient.invalidateQueries({ queryKey: ["admin", "payout-queue"] });
          return null;
        }}
      >
        <p>{row ? destination(row) : ""}.</p>
        <p>This commits {money(row?.amount_eur)} of their earnings to this payout.</p>
      </ConfirmDialog>

      <ConfirmDialog
        open={dialog?.action === "paid"}
        title={`Record ${money(row?.amount_eur)} as sent to ${who}?`}
        confirmLabel="Mark paid"
        onClose={() => setDialog(null)}
        onConfirm={async () => {
          if (!row) return null;
          const res = await admin.markPayoutPaid(row.payout_request_id, { method: "manual", note: "paid from admin panel" });
          if (!res.ok) return res.error.message;
          queryClient.invalidateQueries({ queryKey: ["admin", "payout-queue"] });
          return null;
        }}
      >
        <p>Only once the money has actually left the account. The photographer sees this payout as paid.</p>
      </ConfirmDialog>
    </>
  );
}

function destination(row: PayoutQueueRow): string {
  const status = row.payout_account_status.replace(/_/g, " ");
  return row.payout_method === "bank_manual"
    ? `Manual bank transfer — Stripe Connect ${status}`
    : `Stripe Connect — ${status}`;
}
