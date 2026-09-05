"use client";

import { useMutation } from "@tanstack/react-query";
import { updateAIFeatureFlags } from "@/api/routes/adminAIFeatureFlags";
import { PageHeader } from "@/components/layout/PageHeader";
import { JsonEditorCard } from "@/components/shared/JsonEditorCard";

export default function AIFeatureFlagsPage() {
  const mutation = useMutation({ mutationFn: updateAIFeatureFlags });
  return (
    <div className="space-y-4">
      <PageHeader title="AI Feature Flags" subtitle="Central AI flag payload editor." />
      <JsonEditorCard title="AI Feature Flags" value={{}} onSave={async (v) => mutation.mutateAsync(v)} />
    </div>
  );
}
