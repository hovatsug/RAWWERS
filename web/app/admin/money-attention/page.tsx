"use client";

import Link from "next/link";
import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type MoneyAttentionItem } from "@/lib/api/admin";
import { AdminButton, ConfirmDialog, DataTable, PageHeader, StatusBadge, money, type Column } from "@/app/admin/_components/ui";

/**
 * Money a person has to act on, raised by refund and chargeback
 * reconciliation: a client still owed after their refund failed, a refund
 * made in the Stripe dashboard rather than through RAWWERS, a chargeback
 * whose evidence is due, a chargeback lost and absorbed.
 *
 * Nothing else tells anyone about these yet - no email, no alert - so this
 * page and its sidebar count are the alert. A chargeback with evidence due
 * sorts first, overdue before due, because missing that deadline loses it.
 */

const KIND: Record<string, string> = {
  client_owed: "Client owed",
  refund_outside_rawwers: "Refund made in Stripe",
  chargeback_evidence_due: "Chargeback: evidence due",
  chargeback_lost: "Chargeback lost",
  pro_shut_out_booking: "Booking with a banned or suspended photographer",
  photographer_short_delivery: "Fewer photos delivered than included",
  photographer_adjustment_owed: "Photographer owes back (paid out before a reduction)"
};

function dueLabel(dueAt: string | null): { text: string; overdue: boolean } | null {
  if (!dueAt) return null;
  const due = new Date(dueAt);
  const overdue = due.getTime() < Date.now();
  const when = due.toLocaleString("en-GB", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" });
  return { text: overdue ? `Overdue since ${when}` : `Due ${when}`, overdue };
}

function byUrgency(a: MoneyAttentionItem, b: MoneyAttentionItem): number {
  const due = (item: MoneyAttentionItem) => (item.due_at ? new Date(item.due_at).getTime() : Number.POSITIVE_INFINITY);
  // Deadlines first; otherwise the longest-waiting first.
  return due(a) - due(b) || a.created_at.localeCompare(b.created_at);
}

export default function AdminMoneyAttentionPage() {
  const queryClient = useQueryClient();
  const [closing, setClosing] = useState<MoneyAttentionItem | null>(null);
  const query = useQuery({ queryKey: ["admin", "money-attention"], queryFn: () => admin.moneyAttention() });
  const items = query.data?.ok ? [...query.data.data.items].filter((i) => i.status === "open").sort(byUrgency) : undefined;

  const columns: Column<MoneyAttentionItem>[] = [
    {
      header: "What",
      cell: (row) => {
        const due = dueLabel(row.due_at);
        return (
          <div>
            <p className="font-medium text-slate-50">{KIND[row.kind] ?? row.kind.replace(/_/g, " ")}</p>
            {due ? <StatusBadge label={due.text} tone={due.overdue ? "attention" : "info"} /> : null}
          </div>
        );
      }
    },
    { header: "Amount", className: "tabular-nums", cell: (row) => <span className="font-semibold">{money(row.amount, row.currency)}</span> },
    {
      header: "Details",
      cell: (row) => (
        <div>
          <p className="max-w-md whitespace-pre-line text-xs text-slate-400">{row.note}</p>
          {row.gig_id ? (
            <Link href={`/admin/bookings/${row.gig_id}`} className="text-xs text-sky-300 underline">
              Booking money
            </Link>
          ) : null}
        </div>
      )
    },
    {
      header: "Stripe",
      cell: (row) => <p className="font-mono text-[11px] text-slate-500">{row.stripe_dispute_id ?? row.stripe_refund_id ?? "—"}</p>
    },
    {
      header: "",
      className: "w-px whitespace-nowrap text-right",
      cell: (row) => <AdminButton onClick={() => setClosing(row)}>Close…</AdminButton>
    }
  ];

  return (
    <>
      <PageHeader
        title="Money to act on"
        description={
          items === undefined
            ? "Clients owed, refunds made in Stripe, and chargebacks."
            : items.length === 0
              ? "Nothing to act on."
              : `${items.length} open. Close each one by saying what was done.`
        }
      />
      <DataTable
        columns={columns}
        rows={items}
        rowKey={(row) => row.id}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : query.error ? "Check that the API is reachable." : null}
        onRetry={() => query.refetch()}
        empty={{ title: "Nothing to act on", body: "Failed refunds and chargebacks appear here." }}
      />
      <ConfirmDialog
        open={closing !== null}
        title={closing ? `Close: ${KIND[closing.kind] ?? closing.kind} (${money(closing.amount, closing.currency)})` : ""}
        confirmLabel="Close item"
        reason={{ label: "What was done", placeholder: "e.g. paid back by bank transfer; evidence submitted in Stripe" }}
        onClose={() => setClosing(null)}
        onConfirm={async (note) => {
          if (!closing) return null;
          const res = await admin.resolveMoneyAttention(closing.id, note);
          if (!res.ok) return res.error.message;
          queryClient.invalidateQueries({ queryKey: ["admin", "money-attention"] });
          return null;
        }}
      >
        <p>{closing?.note}</p>
      </ConfirmDialog>
    </>
  );
}
