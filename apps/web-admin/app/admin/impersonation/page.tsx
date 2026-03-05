"use client";

import { useState } from "react";
import { useMutation } from "@tanstack/react-query";
import { startImpersonation, endImpersonation } from "@/api/routes/adminImpersonation";
import { PageHeader } from "@/components/layout/PageHeader";
import { SectionCard } from "@/components/layout/SectionCard";
import { Input } from "@/components/forms/Input";
import { Button } from "@/components/forms/Button";
import { InlineBanner } from "@/components/feedback/InlineBanner";
import { ConfirmDialog } from "@/components/overlays/ConfirmDialog";
import { recordAndTrackAdminAction } from "@/core/audit/audit";

export default function ImpersonationPage() {
  const [userId, setUserId] = useState("");
  const [active, setActive] = useState<string | null>(null);
  const [startConfirm, setStartConfirm] = useState(false);
  const [endConfirm, setEndConfirm] = useState(false);

  const start = useMutation({ mutationFn: () => startImpersonation({ user_id: userId }), onSuccess: async () => { setActive(userId); await recordAndTrackAdminAction({ action: "impersonation.start", entityType: "user", entityId: userId }); } });
  const end = useMutation({ mutationFn: () => endImpersonation(), onSuccess: async () => { await recordAndTrackAdminAction({ action: "impersonation.end", entityType: "user", entityId: active || undefined }); setActive(null); } });

  return (
    <div className="space-y-4">
      <PageHeader title="Impersonation" subtitle="Temporarily impersonate user context for support." />
      {active ? <InlineBanner variant="info" text={`Impersonating user ${active}`} /> : null}
      <SectionCard>
        <div className="flex gap-2">
          <Input placeholder="User ID" value={userId} onChange={(e) => setUserId(e.target.value)} />
          <Button onClick={() => setStartConfirm(true)}>Start</Button>
          <Button variant="danger" onClick={() => setEndConfirm(true)}>End</Button>
        </div>
      </SectionCard>
      <ConfirmDialog open={startConfirm} title="Start impersonation" description={`Start impersonation for ${userId}?`} onCancel={() => setStartConfirm(false)} onConfirm={() => { start.mutate(); setStartConfirm(false); }} />
      <ConfirmDialog open={endConfirm} title="End impersonation" description="End current impersonation session?" onCancel={() => setEndConfirm(false)} onConfirm={() => { end.mutate(); setEndConfirm(false); }} danger />
    </div>
  );
}
