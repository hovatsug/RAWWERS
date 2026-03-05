"use client";

import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { listDisputes, resolveDispute, setDisputeStatus, getDispute } from "@/api/routes/adminDisputes";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";
import { Button } from "@/components/forms/Button";
import { ConfirmDialog } from "@/components/overlays/ConfirmDialog";
import { Drawer } from "@/components/overlays/Drawer";
import { CodeBlock } from "@/components/data/CodeBlock";
import { useQuery } from "@tanstack/react-query";

export default function DisputesPage() {
  const [activeDispute, setActiveDispute] = useState<string | null>(null);
  const [action, setAction] = useState<{ type: "resolve" | "status"; id: string } | null>(null);
  const queryClient = useQueryClient();

  const detail = useQuery({
    queryKey: ["admin", "dispute", activeDispute],
    queryFn: () => getDispute(activeDispute || ""),
    enabled: !!activeDispute
  });

  const mutation = useMutation({
    mutationFn: ({ type, id }: { type: "resolve" | "status"; id: string }) =>
      type === "resolve" ? resolveDispute(id) : setDisputeStatus(id, { status: "updated" }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "disputes"] })
  });

  return (
    <div className="space-y-4">
      <PageHeader title="Disputes" subtitle="Review and resolve dispute workflows." />
      <ListPage
        queryKey={["admin", "disputes"]}
        queryFn={listDisputes}
        columns={[
          { key: "id", title: "Dispute", render: (r: any) => String(r.dispute_id || r.id || "-") },
          { key: "status", title: "Status", render: (r: any) => r.status || "-" },
          {
            key: "actions",
            title: "Actions",
            render: (r: any) => (
              <div className="flex gap-2" onClick={(e) => e.stopPropagation()}>
                <Button onClick={() => setAction({ type: "resolve", id: String(r.dispute_id || r.id) })}>Resolve</Button>
                <Button variant="secondary" onClick={() => setAction({ type: "status", id: String(r.dispute_id || r.id) })}>Set Status</Button>
              </div>
            )
          }
        ]}
        onRowClick={(row: any) => setActiveDispute(String(row.dispute_id || row.id))}
      />
      <Drawer open={!!activeDispute} onClose={() => setActiveDispute(null)} title={`Dispute ${activeDispute || ""}`}>
        <CodeBlock value={detail.data || {}} />
      </Drawer>
      <ConfirmDialog
        open={!!action}
        title="Confirm dispute action"
        description={`Apply ${action?.type} to dispute ${action?.id}?`}
        onCancel={() => setAction(null)}
        onConfirm={() => {
          if (!action) return;
          mutation.mutate(action);
          setAction(null);
        }}
      />
    </div>
  );
}
