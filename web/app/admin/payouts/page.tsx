"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Badge, Button, Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { admin, type PayoutQueueRow } from "@/lib/api/admin";

/**
 * Payout requests awaiting a decision.
 *
 * Everything needed to approve is on the row: who, how much, where the
 * money would actually go, and what their ledger says. A payout approved
 * to an account that cannot receive it is a failure you find out about
 * from the photographer.
 */
export default function AdminPayoutsPage() {
  const queryClient = useQueryClient();
  const [note, setNote] = useState<string | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["admin", "payout-queue"],
    queryFn: () => admin.payoutQueue()
  });

  const act = useMutation({
    mutationFn: async ({ id, action }: { id: string; action: "approve" | "paid" }) =>
      action === "approve"
        ? admin.approvePayout(id)
        : admin.markPayoutPaid(id, { method: "manual", note: "paid from admin panel" }),
    onSuccess: (res) => {
      setNote(res.ok ? null : res.error.message);
      queryClient.invalidateQueries({ queryKey: ["admin", "payout-queue"] });
    }
  });

  if (isLoading) return <Skeleton className="h-40 w-full" />;
  if (!data?.ok) {
    return (
      <Card>
        <p className="text-sm">Could not load the payout queue.</p>
        <p className="mt-1 text-xs text-neutral-500">{data && !data.ok ? data.error.message : ""}</p>
      </Card>
    );
  }

  const items = data.data.items;

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-xl font-semibold">Payouts</h1>
        <p className="mt-1 text-sm text-neutral-500">
          {items.length === 0 ? "Nothing waiting." : `${items.length} waiting on a decision.`}
        </p>
      </div>

      {note ? <Card><p className="text-sm text-amber-400">{note}</p></Card> : null}

      {items.length === 0 ? (
        <EmptyState title="No payout requests" body="Requests appear here when a photographer withdraws." />
      ) : (
        items.map((row) => <PayoutRow key={row.payout_request_id} row={row} onAct={act.mutate} busy={act.isPending} />)
      )}
    </div>
  );
}

function PayoutRow({
  row,
  onAct,
  busy
}: {
  row: PayoutQueueRow;
  onAct: (v: { id: string; action: "approve" | "paid" }) => void;
  busy: boolean;
}) {
  return (
    <Card>
      <div className="flex flex-wrap items-center gap-2">
        <span className="font-medium">{row.display_name || row.email || "Unnamed"}</span>
        <span className="text-lg font-semibold">€{row.amount_eur}</span>
        <Badge>{row.status}</Badge>
        {row.lifetime_payouts === 0 ? <Badge variant="violet">First payout</Badge> : null}
        {row.exceeds_withdrawable ? <Badge variant="amber">More than they can withdraw</Badge> : null}
      </div>

      {/* Method and status stated plainly. Manual bank transfer is a real
          route and currently the only one that works end to end, so it is
          not presented as a problem. */}
      <p className="mt-2 text-sm text-neutral-400">
        {row.payout_method === "bank_manual"
          ? `Manual bank transfer — Stripe Connect ${row.payout_account_status.replace(/_/g, " ")}`
          : `Stripe Connect — ${row.payout_account_status.replace(/_/g, " ")}`}
      </p>
      <p className="mt-1 text-xs text-neutral-500">
        Withdrawable €{row.withdrawable_eur} · available €{row.available_eur} · settling €{row.pending_eur}
      </p>

      {row.approval_blocked ? (
        <p className="mt-2 text-sm text-amber-400">{row.blocked_reason}</p>
      ) : null}

      <div className="mt-3 flex gap-2">
        <Button
          onClick={() => onAct({ id: row.payout_request_id, action: "approve" })}
          disabled={busy || row.approval_blocked || row.status !== "requested"}
        >
          Approve
        </Button>
        <Button
          variant="glass"
          onClick={() => onAct({ id: row.payout_request_id, action: "paid" })}
          disabled={busy || !["approved", "processing"].includes(row.status)}
        >
          Mark paid
        </Button>
      </div>
      {row.approval_blocked ? (
        <p className="mt-2 text-xs text-neutral-500">
          Approving is disabled because the money could not actually be sent — not because the panel is stuck.
        </p>
      ) : null}
    </Card>
  );
}
