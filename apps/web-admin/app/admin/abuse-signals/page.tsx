"use client";

import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { listAbuseSignals, resolveAbuseSignal } from "@/api/routes/adminAbuseSignals";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";
import { Button } from "@/components/forms/Button";
import { ConfirmDialog } from "@/components/overlays/ConfirmDialog";

export default function AbuseSignalsPage() {
  const queryClient = useQueryClient();
  const [target, setTarget] = useState<string | null>(null);
  const resolveMutation = useMutation({ mutationFn: (id: string) => resolveAbuseSignal(id), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "abuse-signals"] }) });

  return (
    <div className="space-y-4">
      <PageHeader title="Abuse Signals" subtitle="Resolve abuse and anti-fraud signals." />
      <ListPage
        queryKey={["admin", "abuse-signals"]}
        queryFn={listAbuseSignals}
        columns={[
          { key: "id", title: "Signal", render: (r: any) => String(r.signal_id || r.id || "-") },
          { key: "type", title: "Type", render: (r: any) => r.type || r.signal_type || "-" },
          { key: "score", title: "Score", render: (r: any) => String(r.score ?? "-") },
          { key: "user", title: "User", render: (r: any) => String(r.user_id || "-") },
          { key: "created", title: "Created", render: (r: any) => r.created_at || "-" },
          { key: "action", title: "", render: (r: any) => <Button onClick={(e) => { e.stopPropagation(); setTarget(String(r.signal_id || r.id)); }}>Resolve</Button> }
        ]}
      />
      <ConfirmDialog
        open={!!target}
        title="Resolve signal"
        description={`Mark signal ${target} as resolved?`}
        onCancel={() => setTarget(null)}
        onConfirm={() => {
          if (target) resolveMutation.mutate(target);
          setTarget(null);
        }}
      />
    </div>
  );
}
