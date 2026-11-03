"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type RawwLedgerRow } from "@/lib/api/admin";
import { AdminButton, DataTable, FieldLabel, Notice, PageHeader, Panel, StatusBadge, TextField, type Column } from "@/app/admin/_components/ui";

/**
 * One photographer's RAWW: the balance and every entry, newest first. An
 * adjustment (a return after shipping, a correction) needs a note, and is
 * logged with the admin and the time.
 */

const KIND: Record<string, string> = {
  earn_booking: "Booking credit",
  reverse_booking: "Refund or price change",
  spend_order: "Shelf order",
  refund_order: "Order cancelled",
  expire: "Expired",
  admin_adjust: "Adjustment",
  earn_extras: "Extras credit",
  reverse_extras: "Extras refunded"
};

function newRequestId(): string {
  return Array.from(crypto.getRandomValues(new Uint8Array(16)), (b) => b.toString(16).padStart(2, "0")).join("");
}

export default function RawwLedgerPage() {
  const queryClient = useQueryClient();
  const [pro, setPro] = useState("");
  const [shown, setShown] = useState("");
  const [amount, setAmount] = useState("");
  const [note, setNote] = useState("");
  const [requestId, setRequestId] = useState(newRequestId);
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  const query = useQuery({
    queryKey: ["admin", "shelf", "raww", shown],
    queryFn: () => admin.rawwLedger(shown),
    enabled: Boolean(shown)
  });
  const data = query.data?.ok ? query.data.data : null;

  const adjust = async () => {
    const res = await admin.rawwAdjust(shown, Number(amount), note, requestId);
    if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
    setMessage({ tone: "success", text: `Adjusted by ${res.data.amount} RAWW.` });
    setAmount("");
    setNote("");
    setRequestId(newRequestId());
    queryClient.invalidateQueries({ queryKey: ["admin", "shelf", "raww", shown] });
  };

  const columns: Column<RawwLedgerRow>[] = [
    { header: "When", className: "whitespace-nowrap", cell: (row) => new Date(row.created_at).toLocaleString("en-GB") },
    { header: "What", cell: (row) => KIND[row.kind] ?? row.kind },
    { header: "RAWW", className: "tabular-nums", cell: (row) => (row.amount > 0 ? `+${row.amount}` : row.amount) },
    { header: "", cell: (row) => <StatusBadge label={row.status} tone={row.status === "pending" ? "attention" : "neutral"} /> },
    { header: "Note", cell: (row) => row.note ?? "" }
  ];

  return (
    <>
      <PageHeader title="RAWW ledger" description="One photographer's RAWW, every entry. Adjustments need a note." />
      <div className="space-y-4">
        {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
        <Panel className="flex flex-wrap items-end gap-3 p-4">
          <div className="min-w-80">
            <FieldLabel htmlFor="pro">Photographer (user id)</FieldLabel>
            <TextField id="pro" value={pro} onChange={(e) => setPro(e.target.value)} />
          </div>
          <AdminButton disabled={!pro.trim()} onClick={() => setShown(pro.trim())}>
            Show
          </AdminButton>
        </Panel>
        {data ? (
          <>
            <Panel className="flex flex-wrap items-end gap-6 p-4">
              <div>
                <div className="text-xs uppercase text-slate-400">Spendable</div>
                <div className="text-xl tabular-nums">{data.spendable} RAWW</div>
              </div>
              <div>
                <div className="text-xs uppercase text-slate-400">Pending</div>
                <div className="text-xl tabular-nums">{data.pending} RAWW</div>
              </div>
              <div className="ml-auto flex flex-wrap items-end gap-3">
                <div>
                  <FieldLabel htmlFor="amount">Adjust by (RAWW, minus to take off)</FieldLabel>
                  <TextField id="amount" inputMode="numeric" value={amount} onChange={(e) => setAmount(e.target.value.replace(/[^0-9-]/g, ""))} />
                </div>
                <div className="min-w-72">
                  <FieldLabel htmlFor="note">Note (required)</FieldLabel>
                  <TextField id="note" value={note} onChange={(e) => setNote(e.target.value)} />
                </div>
                <AdminButton disabled={!note.trim() || !Number(amount)} onClick={adjust}>
                  Adjust
                </AdminButton>
              </div>
            </Panel>
            <DataTable
              columns={columns}
              rows={data.items}
              rowKey={(row) => row.id}
              loading={query.isLoading}
              error={null}
              onRetry={() => query.refetch()}
              empty={{ title: "No RAWW yet", body: "Entries appear as bookings settle and orders are placed." }}
            />
          </>
        ) : query.data && !query.data.ok ? (
          <Notice tone="error">{query.data.error.message}</Notice>
        ) : null}
      </div>
    </>
  );
}
