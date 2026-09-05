"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Badge, Button, Card, EmptyState, Input, Select, Skeleton, Textarea } from "@/design-system/primitives";
import { admin, type DisputeRow } from "@/lib/api/admin";

/**
 * Disputes needing a decision.
 *
 * Resolution moves money: a partial refund sends the amount entered here
 * to Stripe and adjusts the photographer's earnings by it. The amount
 * field is therefore never pre-filled with the full booking value.
 */
export default function AdminDisputesPage() {
  const queryClient = useQueryClient();
  const { data, isLoading } = useQuery({
    queryKey: ["admin", "disputes"],
    queryFn: () => admin.disputes()
  });

  if (isLoading) return <Skeleton className="h-40 w-full" />;
  if (!data?.ok) {
    return (
      <Card>
        <p className="text-sm">Could not load disputes.</p>
        <p className="mt-1 text-xs text-neutral-500">{data && !data.ok ? data.error.message : ""}</p>
      </Card>
    );
  }

  const items = Array.isArray(data.data) ? data.data : [];
  const open = items.filter((d) => !d.status.startsWith("resolved") && d.status !== "closed" && d.status !== "cancelled");
  const settled = items.filter((d) => !open.includes(d));

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-xl font-semibold">Disputes</h1>
        <p className="mt-1 text-sm text-neutral-500">
          {open.length === 0 ? "Nothing waiting on you." : `${open.length} waiting on a decision.`}
        </p>
      </div>

      {open.length === 0 ? (
        <EmptyState title="No open disputes" body="Disputes appear here when a client or photographer raises one." />
      ) : (
        open.map((d) => (
          <DisputeCard key={d.id} dispute={d} onDone={() => queryClient.invalidateQueries({ queryKey: ["admin", "disputes"] })} />
        ))
      )}

      {settled.length > 0 ? (
        <>
          <h2 className="pt-4 text-sm font-semibold text-neutral-500">Settled</h2>
          {settled.map((d) => (
            <Card key={d.id}>
              <div className="flex items-center gap-2">
                <Badge variant="emerald">{d.status.replace(/_/g, " ")}</Badge>
                <span className="text-sm text-neutral-400">{d.category?.replace(/_/g, " ")}</span>
              </div>
              {d.reason || d.summary ? <p className="mt-2 text-sm">{d.reason || d.summary}</p> : null}
            </Card>
          ))}
        </>
      ) : null}
    </div>
  );
}

function DisputeCard({ dispute, onDone }: { dispute: DisputeRow; onDone: () => void }) {
  const [decision, setDecision] = useState("partial_refund");
  const [amount, setAmount] = useState("");
  const [rationale, setRationale] = useState("");
  const [error, setError] = useState<string | null>(null);

  const resolve = useMutation({
    mutationFn: () =>
      admin.resolveDispute(dispute.id, decision, rationale, decision === "no_refund" ? undefined : amount),
    onSuccess: (res) => {
      if (!res.ok) {
        setError(res.error.message);
        return;
      }
      setError(null);
      onDone();
    }
  });

  const needsAmount = decision !== "no_refund";
  const canResolve = rationale.trim().length > 0 && (!needsAmount || amount.trim().length > 0);

  return (
    <Card>
      <div className="flex flex-wrap items-center gap-2">
        <Badge variant="amber">{dispute.status.replace(/_/g, " ")}</Badge>
        {dispute.category ? <span className="text-sm text-neutral-400">{dispute.category.replace(/_/g, " ")}</span> : null}
        {dispute.requested_refund_amount ? (
          <span className="text-sm">asked for €{dispute.requested_refund_amount}</span>
        ) : null}
      </div>

      {dispute.reason || dispute.summary ? (
        <p className="mt-2 text-sm">{dispute.reason || dispute.summary}</p>
      ) : null}

      <div className="mt-4 space-y-2">
        <Select value={decision} onChange={(e) => setDecision(e.target.value)}>
          <option value="partial_refund">Refund part of it</option>
          <option value="full_refund">Refund all of it</option>
          <option value="no_refund">No refund</option>
        </Select>
        {needsAmount ? (
          // Never pre-filled: whatever goes in here is sent to Stripe.
          <Input
            placeholder="Amount to refund, e.g. 60.00"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            inputMode="decimal"
          />
        ) : null}
        <Textarea
          placeholder="Why — both sides see this"
          value={rationale}
          onChange={(e) => setRationale(e.target.value)}
          rows={2}
        />
      </div>

      {error ? <p className="mt-2 text-sm text-amber-400">{error}</p> : null}

      <div className="mt-3">
        <Button onClick={() => resolve.mutate()} disabled={!canResolve || resolve.isPending}>
          {resolve.isPending ? "Resolving…" : "Resolve"}
        </Button>
        {!canResolve ? (
          <p className="mt-2 text-xs text-neutral-500">
            {needsAmount && !amount.trim() ? "Enter the amount to refund. " : ""}
            {!rationale.trim() ? "A reason is required — both sides see it." : ""}
          </p>
        ) : null}
      </div>
    </Card>
  );
}
