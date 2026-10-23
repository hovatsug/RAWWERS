"use client";

import { useEffect, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type AccountabilityPolicy } from "@/lib/api/admin";
import { AdminButton, FieldLabel, Notice, PageHeader, Panel, TextField } from "@/app/admin/_components/ui";

/**
 * Every number the non-delivery ladder uses, in one place an admin edits.
 * Each change is audited. Changing a number never reaches back: findings
 * already in effect keep the consequence they were given.
 */
const FIELDS: { key: keyof AccountabilityPolicy; label: string; hint: string }[] = [
  { key: "contest_window_days", label: "Days to respond", hint: "From when the photographer first sees the finding" },
  { key: "unseen_grace_days", label: "Days before the window starts anyway", hint: "If they never open it" },
  { key: "rolling_window_months", label: "Months strikes count back", hint: "The rolling window" },
  { key: "pause_at", label: "Strike that pauses new bookings", hint: "The first is always a warning" },
  { key: "suspension_review_at", label: "Strike that raises a suspension review", hint: "And every one after" }
];

export default function AccountabilityPolicyPage() {
  const queryClient = useQueryClient();
  const query = useQuery({ queryKey: ["admin", "accountability-policy"], queryFn: () => admin.accountabilityPolicy() });
  const [form, setForm] = useState<Record<string, string>>({});
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  const data = query.data?.ok ? query.data.data : null;

  useEffect(() => {
    if (data) setForm(Object.fromEntries(FIELDS.map((f) => [f.key, String(data[f.key])])));
  }, [data]);

  return (
    <>
      <PageHeader title="Accountability policy" description="The numbers behind findings for photos not delivered." />
      <Panel className="p-4">
        <div className="grid gap-3 md:grid-cols-2">
          {FIELDS.map((f) => (
            <div key={f.key}>
              <FieldLabel htmlFor={f.key}>{f.label}</FieldLabel>
              <TextField id={f.key} inputMode="numeric" value={form[f.key] ?? ""} onChange={(e) => setForm({ ...form, [f.key]: e.target.value })} />
              <p className="mt-1 text-xs text-slate-400">{f.hint}</p>
            </div>
          ))}
        </div>
        {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
        <AdminButton
          className="mt-3"
          onClick={async () => {
            const body = Object.fromEntries(FIELDS.map((f) => [f.key, Number(form[f.key])]));
            const res = await admin.saveAccountabilityPolicy(body);
            if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
            setMessage({ tone: "success", text: "Saved." });
            queryClient.invalidateQueries({ queryKey: ["admin", "accountability-policy"] });
          }}
        >
          Save
        </AdminButton>
      </Panel>
    </>
  );
}
