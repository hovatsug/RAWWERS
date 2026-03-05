"use client";

import { useMutation, useQuery } from "@tanstack/react-query";
import {
  getRawwCaps,
  updateRawwCaps,
  getRawwIssuanceRules,
  updateRawwIssuanceRules,
  getRawwMultiplierPolicy,
  updateRawwMultiplierPolicy,
  getRawwMints,
  clawbackRaww
} from "@/api/routes/adminRaww";
import { PageHeader } from "@/components/layout/PageHeader";
import { JsonEditorCard } from "@/components/shared/JsonEditorCard";
import { SectionCard } from "@/components/layout/SectionCard";
import { CodeBlock } from "@/components/data/CodeBlock";
import { Input } from "@/components/forms/Input";
import { Button } from "@/components/forms/Button";
import { useState } from "react";

export default function RawwPage() {
  const caps = useQuery({ queryKey: ["admin", "raww-caps"], queryFn: getRawwCaps });
  const issuance = useQuery({ queryKey: ["admin", "raww-issuance-rules"], queryFn: getRawwIssuanceRules });
  const multiplier = useQuery({ queryKey: ["admin", "raww-multiplier-policy"], queryFn: getRawwMultiplierPolicy });
  const mints = useQuery({ queryKey: ["admin", "raww-mints"], queryFn: getRawwMints });
  const [clawbackBody, setClawbackBody] = useState("{}");
  const clawback = useMutation({ mutationFn: () => clawbackRaww(JSON.parse(clawbackBody || "{}")) });

  return (
    <div className="space-y-4">
      <PageHeader title="RAWW" subtitle="Token policy and clawback controls." />
      <JsonEditorCard title="Caps" value={caps.data || {}} onSave={updateRawwCaps} />
      <JsonEditorCard title="Issuance Rules" value={issuance.data || {}} onSave={updateRawwIssuanceRules} />
      <JsonEditorCard title="Multiplier Policy" value={multiplier.data || {}} onSave={updateRawwMultiplierPolicy} />
      <SectionCard>
        <h3 className="mb-3 font-semibold">Mints</h3>
        <CodeBlock value={mints.data || {}} />
      </SectionCard>
      <SectionCard className="border-red-300">
        <h3 className="mb-3 font-semibold text-red-700">Danger Zone: Clawback</h3>
        <Input value={clawbackBody} onChange={(e) => setClawbackBody(e.target.value)} placeholder='{"user_id":"...","amount":10}' />
        <div className="mt-3"><Button variant="danger" onClick={() => clawback.mutate()}>Execute Clawback</Button></div>
      </SectionCard>
    </div>
  );
}
