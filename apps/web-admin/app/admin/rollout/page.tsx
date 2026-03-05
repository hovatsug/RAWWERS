"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  getRolloutCities,
  updateRolloutCities,
  bulkEnableCities,
  getRolloutOverride,
  updateRolloutOverride
} from "@/api/routes/adminRollout";
import { PageHeader } from "@/components/layout/PageHeader";
import { JsonEditorCard } from "@/components/shared/JsonEditorCard";
import { SectionCard } from "@/components/layout/SectionCard";
import { Input } from "@/components/forms/Input";
import { Button } from "@/components/forms/Button";
import { CodeBlock } from "@/components/data/CodeBlock";

export default function RolloutPage() {
  const queryClient = useQueryClient();
  const [overrideUserId, setOverrideUserId] = useState("");
  const [overrideBody, setOverrideBody] = useState("{}");
  const cities = useQuery({ queryKey: ["admin", "rollout-cities"], queryFn: getRolloutCities });
  const override = useQuery({
    queryKey: ["admin", "rollout-override", overrideUserId],
    queryFn: () => getRolloutOverride(overrideUserId),
    enabled: !!overrideUserId
  });

  const saveCities = useMutation({ mutationFn: updateRolloutCities, onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "rollout-cities"] }) });
  const bulk = useMutation({ mutationFn: bulkEnableCities, onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "rollout-cities"] }) });
  const saveOverride = useMutation({ mutationFn: () => updateRolloutOverride(overrideUserId, JSON.parse(overrideBody)), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "rollout-override", overrideUserId] }) });

  return (
    <div className="space-y-4">
      <PageHeader title="Rollout" subtitle="City rollout control and per-user overrides." />
      <JsonEditorCard title="Cities" value={cities.data || {}} onSave={async (v) => saveCities.mutateAsync(v)} />
      <SectionCard>
        <h3 className="mb-3 font-semibold">Bulk enable cities</h3>
        <Button onClick={() => bulk.mutate({ enabled: true })}>Run Bulk Enable</Button>
      </SectionCard>
      <SectionCard>
        <h3 className="mb-3 font-semibold">User override</h3>
        <div className="flex flex-wrap gap-2">
          <Input className="max-w-sm" placeholder="User ID" value={overrideUserId} onChange={(e) => setOverrideUserId(e.target.value)} />
          <Input className="flex-1" placeholder='{"enabled":true}' value={overrideBody} onChange={(e) => setOverrideBody(e.target.value)} />
          <Button onClick={() => saveOverride.mutate()}>Save</Button>
        </div>
        <div className="mt-4"><CodeBlock value={override.data || {}} /></div>
      </SectionCard>
    </div>
  );
}
