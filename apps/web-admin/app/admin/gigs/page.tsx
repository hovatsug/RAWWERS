"use client";

import { useState } from "react";
import { useMutation } from "@tanstack/react-query";
import { getGig, setGigStatus } from "@/api/routes/adminGigs";
import { PageHeader } from "@/components/layout/PageHeader";
import { SectionCard } from "@/components/layout/SectionCard";
import { Input } from "@/components/forms/Input";
import { Button } from "@/components/forms/Button";
import { CodeBlock } from "@/components/data/CodeBlock";
import { ConfirmDialog } from "@/components/overlays/ConfirmDialog";

export default function GigsPage() {
  const [gigId, setGigId] = useState("");
  const [status, setStatus] = useState("");
  const [confirm, setConfirm] = useState(false);

  const gigQuery = useMutation({ mutationFn: () => getGig(gigId) });
  const statusMutation = useMutation({ mutationFn: () => setGigStatus(gigId, { status }) });

  return (
    <div className="space-y-4">
      <PageHeader title="Gig Ops" subtitle="Lookup a gig and set operational status." />
      <SectionCard>
        <div className="grid gap-3 md:grid-cols-3">
          <Input placeholder="Gig ID" value={gigId} onChange={(e) => setGigId(e.target.value)} />
          <Button onClick={() => gigQuery.mutate()} loading={gigQuery.isPending}>Fetch Gig</Button>
          <Input placeholder="New status" value={status} onChange={(e) => setStatus(e.target.value)} />
        </div>
        <div className="mt-3">
          <Button variant="danger" onClick={() => setConfirm(true)}>Set Status</Button>
        </div>
        <div className="mt-4"><CodeBlock value={gigQuery.data || {}} /></div>
      </SectionCard>
      <ConfirmDialog
        open={confirm}
        title="Confirm status update"
        description={`Set gig ${gigId} to status ${status}?`}
        onCancel={() => setConfirm(false)}
        onConfirm={() => {
          statusMutation.mutate();
          setConfirm(false);
        }}
        danger
      />
    </div>
  );
}
