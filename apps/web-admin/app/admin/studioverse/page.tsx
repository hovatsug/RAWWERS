"use client";

import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { listStudioversePacks, reviewStudioversePack, takedownStudioversePack } from "@/api/routes/adminStudioverse";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";
import { Button } from "@/components/forms/Button";
import { ConfirmDialog } from "@/components/overlays/ConfirmDialog";

export default function StudioversePage() {
  const queryClient = useQueryClient();
  const [action, setAction] = useState<{ type: "review" | "takedown"; id: string } | null>(null);

  const mutation = useMutation({
    mutationFn: ({ type, id }: { type: "review" | "takedown"; id: string }) =>
      type === "review" ? reviewStudioversePack(id) : takedownStudioversePack(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "studioverse-packs"] })
  });

  return (
    <div className="space-y-4">
      <PageHeader title="Studioverse" subtitle="Review and moderate packs." />
      <ListPage
        queryKey={["admin", "studioverse-packs"]}
        queryFn={listStudioversePacks}
        columns={[
          { key: "pack", title: "Pack", render: (r: any) => String(r.pack_id || r.id || "-") },
          { key: "status", title: "Status", render: (r: any) => r.status || "-" },
          {
            key: "actions",
            title: "",
            render: (r: any) => (
              <div className="flex gap-2" onClick={(e) => e.stopPropagation()}>
                <Button onClick={() => setAction({ type: "review", id: String(r.pack_id || r.id) })}>Review</Button>
                <Button variant="danger" onClick={() => setAction({ type: "takedown", id: String(r.pack_id || r.id) })}>Takedown</Button>
              </div>
            )
          }
        ]}
      />
      <ConfirmDialog
        open={!!action}
        title="Confirm action"
        description={`Apply ${action?.type} for pack ${action?.id}?`}
        onCancel={() => setAction(null)}
        onConfirm={() => {
          if (!action) return;
          mutation.mutate(action);
          setAction(null);
        }}
        danger={action?.type === "takedown"}
      />
    </div>
  );
}
