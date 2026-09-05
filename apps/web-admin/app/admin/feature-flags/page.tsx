"use client";

import { useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { getFeatureFlags, updateFeatureFlag } from "@/api/routes/adminFeatureFlags";
import { PageHeader } from "@/components/layout/PageHeader";
import { SectionCard } from "@/components/layout/SectionCard";
import { DataTable } from "@/components/data/DataTable";
import { Toggle } from "@/components/forms/Toggle";
import { Button } from "@/components/forms/Button";
import { Modal } from "@/components/overlays/Modal";
import { Input } from "@/components/forms/Input";
import { TextArea } from "@/components/forms/TextArea";
import { InlineBanner } from "@/components/feedback/InlineBanner";

export default function FeatureFlagsPage() {
  const queryClient = useQueryClient();
  const [editKey, setEditKey] = useState("");
  const [configText, setConfigText] = useState("{}");
  const [enabled, setEnabled] = useState(false);
  const [unsaved, setUnsaved] = useState(false);

  const flagsQuery = useQuery({ queryKey: ["admin", "feature-flags"], queryFn: getFeatureFlags });
  const mutation = useMutation({
    mutationFn: ({ key, body }: { key: string; body: unknown }) => updateFeatureFlag(key, body),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "feature-flags"] })
  });

  const rows = useMemo(() => {
    const raw = flagsQuery.data as any;
    if (Array.isArray(raw)) return raw;
    if (raw?.items && Array.isArray(raw.items)) return raw.items;
    return Object.entries(raw || {}).map(([key, value]) => ({ key, ...(value as object) }));
  }, [flagsQuery.data]);

  return (
    <div className="space-y-4">
      <PageHeader title="Feature Flags" subtitle="Toggle and update platform flags." />
      {unsaved ? <InlineBanner text="You have unsaved changes" /> : null}
      <SectionCard>
        <DataTable
          columns={[
            { key: "key", title: "Key", render: (r: any) => r.key || "-" },
            {
              key: "enabled",
              title: "Enabled",
              render: (r: any) => (
                <Toggle
                  checked={Boolean(r.enabled)}
                  onCheckedChange={(checked) => mutation.mutate({ key: String(r.key), body: { ...r, enabled: checked } })}
                />
              )
            },
            { key: "description", title: "Description", render: (r: any) => r.description || "-" },
            {
              key: "edit",
              title: "Edit",
              render: (r: any) => (
                <Button
                  variant="secondary"
                  onClick={() => {
                    setEditKey(String(r.key));
                    setEnabled(Boolean(r.enabled));
                    setConfigText(JSON.stringify(r.config || {}, null, 2));
                  }}
                >
                  Edit
                </Button>
              )
            }
          ]}
          rows={rows}
        />
      </SectionCard>
      <Modal open={!!editKey} onClose={() => setEditKey("")} title={`Edit flag: ${editKey}`}>
        <div className="space-y-3">
          <Input value={editKey} readOnly />
          <Toggle checked={enabled} onCheckedChange={(val) => { setEnabled(val); setUnsaved(true); }} />
          <TextArea rows={10} value={configText} onChange={(e) => { setConfigText(e.target.value); setUnsaved(true); }} />
          <div className="flex justify-end">
            <Button
              onClick={() => {
                mutation.mutate({ key: editKey, body: { enabled, config: JSON.parse(configText || "{}") } });
                setUnsaved(false);
                setEditKey("");
              }}
            >
              Save
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
