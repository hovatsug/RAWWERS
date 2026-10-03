"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type DisputeRow } from "@/lib/api/admin";
import { isOpenDispute } from "@/app/admin/labels";
import {
  AdminButton,
  ConfirmDialog,
  DataTable,
  FieldLabel,
  PageHeader,
  SelectField,
  StatusBadge,
  TextField,
  money,
  words,
  type Column
} from "@/app/admin/_components/ui";

/**
 * Disputes needing a decision.
 *
 * Resolution moves money: a refund sends the amount entered here to Stripe
 * and takes it from the photographer's earnings. So the decision is made in
 * a confirmation that states the amount and who it goes to, the amount is
 * never pre-filled with the booking value, and the reason - which both sides
 * read - is required.
 */
export default function AdminDisputesPage() {
  const queryClient = useQueryClient();
  const [resolving, setResolving] = useState<DisputeRow | null>(null);

  const query = useQuery({ queryKey: ["admin", "disputes"], queryFn: () => admin.disputes() });
  const all = query.data?.ok && Array.isArray(query.data.data) ? query.data.data : undefined;
  const open = all?.filter(isOpenDispute);
  const settled = all?.filter((d) => !isOpenDispute(d));
  const error = query.data && !query.data.ok ? query.data.error.message : query.error ? "Check that the API is reachable." : null;

  const summary: Column<DisputeRow> = {
    header: "What happened",
    cell: (d) => <p className="max-w-md text-slate-300">{d.reason || d.summary || "—"}</p>
  };
  const openColumns: Column<DisputeRow>[] = [
    { header: "Status", cell: (d) => <StatusBadge status={d.status} /> },
    { header: "Category", cell: (d) => <span className="capitalize">{words(d.category)}</span> },
    summary,
    {
      header: "Asked for",
      className: "tabular-nums",
      cell: (d) => (d.requested_refund_amount ? money(d.requested_refund_amount, d.currency || "EUR") : "—")
    },
    {
      header: "",
      className: "w-px whitespace-nowrap text-right",
      cell: (d) => <AdminButton onClick={() => setResolving(d)}>Resolve…</AdminButton>
    }
  ];
  const settledColumns: Column<DisputeRow>[] = [
    { header: "Outcome", cell: (d) => <StatusBadge status={d.status} /> },
    { header: "Category", cell: (d) => <span className="capitalize">{words(d.category)}</span> },
    summary
  ];

  return (
    <>
      <PageHeader
        title="Disputes"
        description={open === undefined ? "Disputes raised by clients or photographers." : open.length === 0 ? "Nothing waiting on you." : `${open.length} waiting on a decision.`}
      />
      <DataTable
        columns={openColumns}
        rows={open}
        rowKey={(d) => d.id}
        loading={query.isLoading}
        error={error}
        onRetry={() => query.refetch()}
        empty={{ title: "No open disputes", body: "Disputes appear here when a client or photographer raises one." }}
      />

      {settled && settled.length > 0 ? (
        <section className="mt-8">
          <h2 className="mb-3 text-sm font-semibold text-slate-400">Settled</h2>
          <DataTable columns={settledColumns} rows={settled} rowKey={(d) => d.id} empty={{ title: "Nothing settled yet" }} />
        </section>
      ) : null}

      {resolving ? (
        <ResolveDialog
          dispute={resolving}
          onClose={() => setResolving(null)}
          onDone={() => queryClient.invalidateQueries({ queryKey: ["admin", "disputes"] })}
        />
      ) : null}
    </>
  );
}

const DECISIONS = {
  partial_refund: "Refund part of it",
  full_refund: "Refund all of it",
  no_refund: "No refund"
} as const;
type Decision = keyof typeof DECISIONS;

function ResolveDialog({ dispute, onClose, onDone }: { dispute: DisputeRow; onClose: () => void; onDone: () => void }) {
  const [decision, setDecision] = useState<Decision>("partial_refund");
  const [amount, setAmount] = useState("");
  const needsAmount = decision !== "no_refund";
  const amountOk = !needsAmount || /^\d+(\.\d{1,2})?$/.test(amount.trim());
  const currency = dispute.currency || "EUR";

  return (
    <ConfirmDialog
      open
      title="Resolve this dispute"
      confirmLabel={needsAmount && amountOk ? `Refund ${money(amount.trim(), currency)}` : "Resolve with no refund"}
      tone={needsAmount ? "danger" : "primary"}
      canConfirm={amountOk}
      reason={{ label: "Reason — both sides read this", placeholder: "What you decided and why" }}
      onClose={onClose}
      onConfirm={async (reason) => {
        const res = await admin.resolveDispute(dispute.id, decision, reason, needsAmount ? amount.trim() : undefined);
        if (!res.ok) return res.error.message;
        onDone();
        return null;
      }}
    >
      <p className="text-slate-400">{dispute.reason || dispute.summary || "No description given."}</p>
      <div>
        <FieldLabel htmlFor="dispute-decision">Decision</FieldLabel>
        <SelectField id="dispute-decision" value={decision} onChange={(e) => setDecision(e.target.value as Decision)}>
          {Object.entries(DECISIONS).map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </SelectField>
      </div>
      {needsAmount ? (
        <div>
          {/* Never pre-filled: whatever goes in here is sent to Stripe. */}
          <FieldLabel htmlFor="dispute-amount">Amount to refund ({currency})</FieldLabel>
          <TextField
            id="dispute-amount"
            inputMode="decimal"
            placeholder={dispute.requested_refund_amount ? `They asked for ${dispute.requested_refund_amount}` : "e.g. 60.00"}
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
          <p className="mt-1 text-xs text-amber-200">
            {amountOk
              ? `${money(amount.trim(), currency)} goes back to the client through Stripe and is taken from the photographer's earnings.`
              : "Enter the amount to refund, e.g. 60.00."}
          </p>
        </div>
      ) : (
        <p className="text-xs text-slate-400">No money moves. Any holds on the photographer&apos;s earnings for this booking are released.</p>
      )}
    </ConfirmDialog>
  );
}
