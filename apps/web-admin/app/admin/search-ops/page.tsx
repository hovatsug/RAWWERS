"use client";

import { useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { getSearchStatus, rebuildSearch, purgeSearch } from "@/api/routes/adminSearchOps";
import { PageHeader } from "@/components/layout/PageHeader";
import { SectionCard } from "@/components/layout/SectionCard";
import { CodeBlock } from "@/components/data/CodeBlock";
import { Button } from "@/components/forms/Button";
import { ConfirmDialog } from "@/components/overlays/ConfirmDialog";

export default function SearchOpsPage() {
  const [purgeOpen, setPurgeOpen] = useState(false);
  const status = useQuery({ queryKey: ["admin", "search-status"], queryFn: getSearchStatus });
  const rebuild = useMutation({ mutationFn: () => rebuildSearch() });
  const purge = useMutation({ mutationFn: () => purgeSearch() });

  return (
    <div className="space-y-4">
      <PageHeader title="Search Ops" subtitle="Search index operational controls." />
      <SectionCard>
        <div className="mb-3 flex gap-2">
          <Button onClick={() => rebuild.mutate()} loading={rebuild.isPending}>Rebuild</Button>
          <Button variant="danger" onClick={() => setPurgeOpen(true)}>Purge</Button>
        </div>
        <CodeBlock value={status.data || {}} />
      </SectionCard>
      <ConfirmDialog
        open={purgeOpen}
        title="Confirm purge"
        description="Purge search index now?"
        onCancel={() => setPurgeOpen(false)}
        onConfirm={() => {
          purge.mutate();
          setPurgeOpen(false);
        }}
        danger
      />
    </div>
  );
}
