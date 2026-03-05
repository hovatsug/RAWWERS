"use client";

import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { listRefunds, retryRefund } from "@/api/routes/adminRefunds";
import { createGigRefund } from "@/api/routes/adminDisputes";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";
import { Button } from "@/components/forms/Button";
import { ConfirmDialog } from "@/components/overlays/ConfirmDialog";
import { Modal } from "@/components/overlays/Modal";
import { Input } from "@/components/forms/Input";

export default function RefundsPage() {
  const queryClient = useQueryClient();
  const [retryId, setRetryId] = useState<string | null>(null);
  const [createOpen, setCreateOpen] = useState(false);
  const [gigId, setGigId] = useState("");
  const [amount, setAmount] = useState("");
  const [reason, setReason] = useState("");

  const retryMutation = useMutation({
    mutationFn: (id: string) => retryRefund(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "refunds"] })
  });
  const createMutation = useMutation({
    mutationFn: () => createGigRefund(gigId, { amount: Number(amount), reason }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "refunds"] });
      setCreateOpen(false);
    }
  });

  return (
    <div className="space-y-4">
      <PageHeader
        title="Refunds"
        subtitle="Manage refund cases and retries"
        actions={<Button onClick={() => setCreateOpen(true)}>Create Refund</Button>}
      />
      <ListPage
        queryKey={["admin", "refunds"]}
        queryFn={listRefunds}
        columns={[
          { key: "id", title: "Case", render: (r: any) => String(r.refund_case_id || r.id || "-") },
          { key: "status", title: "Status", render: (r: any) => r.status || "-" },
          {
            key: "actions",
            title: "Actions",
            render: (r: any) => (
              <Button variant="secondary" onClick={(e) => { e.stopPropagation(); setRetryId(String(r.refund_case_id || r.id)); }}>
                Retry
              </Button>
            )
          }
        ]}
      />
      <ConfirmDialog
        open={!!retryId}
        title="Retry refund"
        description={`Retry refund case ${retryId}?`}
        onCancel={() => setRetryId(null)}
        onConfirm={() => {
          if (retryId) retryMutation.mutate(retryId);
          setRetryId(null);
        }}
      />
      <Modal open={createOpen} onClose={() => setCreateOpen(false)} title="Create admin refund">
        <div className="space-y-3">
          <Input placeholder="Gig ID" value={gigId} onChange={(e) => setGigId(e.target.value)} />
          <Input placeholder="Amount" value={amount} onChange={(e) => setAmount(e.target.value)} />
          <Input placeholder="Reason" value={reason} onChange={(e) => setReason(e.target.value)} />
          <div className="flex justify-end">
            <Button onClick={() => createMutation.mutate()} loading={createMutation.isPending}>Create</Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
