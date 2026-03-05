"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  listPayouts,
  approvePayout,
  rejectPayout,
  markPayoutPaid,
  getFeePolicy,
  updateFeePolicy
} from "@/api/routes/adminPayouts";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";
import { Button } from "@/components/forms/Button";
import { ConfirmDialog } from "@/components/overlays/ConfirmDialog";
import { formatCurrency } from "@/lib/format";
import { JsonEditorCard } from "@/components/shared/JsonEditorCard";
import { recordAndTrackAdminAction } from "@/core/audit/audit";

export default function PayoutsPage() {
  const queryClient = useQueryClient();
  const feePolicy = useQuery({ queryKey: ["admin", "finance-fee-policy"], queryFn: getFeePolicy });
  const [action, setAction] = useState<{ type: "approve" | "reject" | "paid"; id: string } | null>(null);

  const mutation = useMutation({
    mutationFn: async ({ type, id }: { type: "approve" | "reject" | "paid"; id: string }) => {
      if (type === "approve") return approvePayout(id);
      if (type === "reject") return rejectPayout(id);
      return markPayoutPaid(id);
    },
    onSuccess: async (_, vars) => {
      await recordAndTrackAdminAction({ action: `payouts.${vars.type}`, entityType: "payout", entityId: vars.id });
      queryClient.invalidateQueries({ queryKey: ["admin", "payouts"] });
    }
  });

  return (
    <div className="space-y-6">
      <PageHeader title="Payouts" subtitle="Approve, reject and mark payout requests." />
      <ListPage
        queryKey={["admin", "payouts"]}
        queryFn={listPayouts}
        columns={[
          { key: "id", title: "Request", render: (r: any) => String(r.payout_request_id || r.id || "-") },
          { key: "pro", title: "Pro User", render: (r: any) => String(r.pro_user_id || "-") },
          { key: "amount", title: "Amount", render: (r: any) => formatCurrency(r.amount) },
          { key: "status", title: "Status", render: (r: any) => r.status || "-" },
          {
            key: "actions",
            title: "Actions",
            render: (r: any) => (
              <div className="flex gap-2" onClick={(e) => e.stopPropagation()}>
                <Button onClick={() => setAction({ type: "approve", id: String(r.payout_request_id || r.id) })}>Approve</Button>
                <Button variant="secondary" onClick={() => setAction({ type: "reject", id: String(r.payout_request_id || r.id) })}>Reject</Button>
                <Button variant="danger" onClick={() => setAction({ type: "paid", id: String(r.payout_request_id || r.id) })}>Mark Paid</Button>
              </div>
            )
          }
        ]}
      />
      <JsonEditorCard
        title="Fee Policy"
        value={feePolicy.data || {}}
        onSave={async (value) => {
          await updateFeePolicy(value);
          queryClient.invalidateQueries({ queryKey: ["admin", "finance-fee-policy"] });
        }}
      />
      <ConfirmDialog
        open={!!action}
        title="Confirm payout action"
        description={`Apply ${action?.type} for payout request ${action?.id}?`}
        onCancel={() => setAction(null)}
        onConfirm={() => {
          if (!action) return;
          mutation.mutate(action);
          setAction(null);
        }}
        confirmLabel="Confirm"
        danger={action?.type === "reject" || action?.type === "paid"}
      />
    </div>
  );
}
