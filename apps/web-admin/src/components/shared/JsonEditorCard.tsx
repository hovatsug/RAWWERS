"use client";

import { useState } from "react";
import { SectionCard } from "@/components/layout/SectionCard";
import { TextArea } from "@/components/forms/TextArea";
import { Button } from "@/components/forms/Button";
import { InlineBanner } from "@/components/feedback/InlineBanner";

interface JsonEditorCardProps {
  title: string;
  value: unknown;
  onSave: (value: unknown) => Promise<void>;
  danger?: boolean;
}

export function JsonEditorCard({ title, value, onSave, danger }: JsonEditorCardProps) {
  const [text, setText] = useState(JSON.stringify(value ?? {}, null, 2));
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);
  const [loading, setLoading] = useState(false);

  const save = async () => {
    try {
      setError(null);
      const parsed = JSON.parse(text);
      setLoading(true);
      await onSave(parsed);
      setSaved(true);
      setTimeout(() => setSaved(false), 1500);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <SectionCard className={danger ? "border-red-300" : undefined}>
      <h3 className="mb-3 text-base font-semibold">{title}</h3>
      {error ? <InlineBanner variant="danger" text={error} /> : null}
      {saved ? <InlineBanner variant="success" text="Saved" /> : null}
      <div className="mt-3">
        <TextArea value={text} onChange={(e) => setText(e.target.value)} rows={14} />
      </div>
      <div className="mt-4">
        <Button variant={danger ? "danger" : "primary"} loading={loading} onClick={save}>
          Save
        </Button>
      </div>
    </SectionCard>
  );
}
