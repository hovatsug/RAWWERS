"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { getLocales, getBundles, createBundle, activateBundle, getMissingKeys } from "@/api/routes/adminI18n";
import { PageHeader } from "@/components/layout/PageHeader";
import { SectionCard } from "@/components/layout/SectionCard";
import { CodeBlock } from "@/components/data/CodeBlock";
import { Input } from "@/components/forms/Input";
import { Button } from "@/components/forms/Button";

export default function I18nPage() {
  const queryClient = useQueryClient();
  const locales = useQuery({ queryKey: ["admin", "i18n-locales"], queryFn: getLocales });
  const bundles = useQuery({ queryKey: ["admin", "i18n-bundles"], queryFn: getBundles });
  const missing = useQuery({ queryKey: ["admin", "i18n-missing-keys"], queryFn: getMissingKeys });

  const [bundlePayload, setBundlePayload] = useState("{}");
  const [activateId, setActivateId] = useState("");

  const create = useMutation({ mutationFn: () => createBundle(JSON.parse(bundlePayload || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "i18n-bundles"] }) });
  const activate = useMutation({ mutationFn: () => activateBundle(activateId), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "i18n-bundles"] }) });

  return (
    <div className="space-y-4">
      <PageHeader title="I18N" subtitle="Locales, bundles and missing keys" />
      <SectionCard><h3 className="mb-3 font-semibold">Locales</h3><CodeBlock value={locales.data || {}} /></SectionCard>
      <SectionCard>
        <h3 className="mb-3 font-semibold">Bundles</h3>
        <CodeBlock value={bundles.data || {}} />
        <div className="mt-3 flex gap-2">
          <Input value={bundlePayload} onChange={(e) => setBundlePayload(e.target.value)} placeholder='{"locale":"en-US"}' />
          <Button onClick={() => create.mutate()}>Create</Button>
        </div>
        <div className="mt-3 flex gap-2">
          <Input value={activateId} onChange={(e) => setActivateId(e.target.value)} placeholder="Bundle ID" />
          <Button onClick={() => activate.mutate()}>Activate</Button>
        </div>
      </SectionCard>
      <SectionCard><h3 className="mb-3 font-semibold">Missing Keys</h3><CodeBlock value={missing.data || {}} /></SectionCard>
    </div>
  );
}
