"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type MarketingWording } from "@/lib/api/admin";
import {
  AdminButton,
  DataTable,
  FieldLabel,
  Notice,
  PageHeader,
  Panel,
  SelectField,
  StatusBadge,
  TextArea,
  TextField,
  type Column,
  type Tone
} from "@/app/admin/_components/ui";

/**
 * The wording clients and photographers agree to for marketing use, as
 * versions. A version is pasted in EN or PT and starts as a draft; once a
 * lawyer has reviewed it, publishing it - with who reviewed it and a note,
 * logged with the admin and the time - makes it the one shown. A published
 * version is never edited: a change is a new version. In production,
 * marketing consent is offered only while the version shown is a reviewed one.
 */

function tone(status: string): Tone {
  return status === "published" ? "positive" : status === "reviewed" ? "info" : "attention";
}

export default function MarketingWordingPage() {
  const queryClient = useQueryClient();
  const query = useQuery({ queryKey: ["admin", "marketing", "wordings"], queryFn: () => admin.marketingWordings() });
  const [audience, setAudience] = useState("client");
  const [language, setLanguage] = useState("en");
  const [text, setText] = useState("");
  const [publishing, setPublishing] = useState<MarketingWording | null>(null);
  const [reviewedBy, setReviewedBy] = useState("");
  const [note, setNote] = useState("");
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  const refresh = () => queryClient.invalidateQueries({ queryKey: ["admin", "marketing", "wordings"] });

  const create = async () => {
    const res = await admin.createMarketingWording({ audience, language, text });
    if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
    setMessage({ tone: "success", text: `Draft ${res.data.version} created.` });
    setText("");
    refresh();
  };

  const publish = async () => {
    if (!publishing) return;
    const res = await admin.publishMarketingWording(publishing.version, { reviewed_by: reviewedBy, note });
    if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
    setMessage({ tone: "success", text: `${res.data.version} is published and shown now.` });
    setPublishing(null);
    setReviewedBy("");
    setNote("");
    refresh();
  };

  const columns: Column<MarketingWording>[] = [
    { header: "Version", cell: (row) => <span className="font-mono text-xs">{row.version}</span> },
    { header: "For", cell: (row) => (row.audience === "client" ? "Clients" : "Photographers") },
    { header: "Language", cell: (row) => row.language.toUpperCase() },
    {
      header: "Status",
      cell: (row) => (
        <div className="space-y-1">
          <StatusBadge label={row.status} tone={tone(row.status)} />
          {row.in_use ? <p className="text-xs text-slate-400">Shown now</p> : null}
        </div>
      )
    },
    {
      header: "Reviewed by",
      cell: (row) => (row.reviewed_by ? <p className="text-xs">{row.reviewed_by}</p> : <p className="text-xs text-slate-500">—</p>)
    },
    { header: "Text", cell: (row) => <p className="max-w-md whitespace-pre-line text-xs text-slate-400">{row.text}</p> },
    {
      header: "",
      className: "w-px whitespace-nowrap text-right",
      cell: (row) =>
        row.status === "draft" && !row.version.endsWith("draft-1") ? (
          <AdminButton tone="secondary" onClick={() => setPublishing(row)}>
            Publish…
          </AdminButton>
        ) : null
    }
  ];

  return (
    <div className="space-y-4">
      <PageHeader
        title="Marketing wording"
        description="Versions of the marketing-consent wording. Publish one only after it has been legally reviewed."
      />
      {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
      <DataTable
        columns={columns}
        rows={query.data?.ok ? query.data.data.items : undefined}
        rowKey={(row) => row.version}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : null}
        onRetry={() => query.refetch()}
        empty={{ title: "No versions" }}
      />
      {publishing ? (
        <Panel className="space-y-3 p-4">
          <p className="font-medium text-slate-50">Publish {publishing.version}</p>
          <div>
            <FieldLabel htmlFor="reviewed-by">Reviewed by</FieldLabel>
            <TextField id="reviewed-by" value={reviewedBy} onChange={(e) => setReviewedBy(e.target.value)} placeholder="Lawyer's name and firm" />
          </div>
          <div>
            <FieldLabel htmlFor="note">Note</FieldLabel>
            <TextField id="note" value={note} onChange={(e) => setNote(e.target.value)} placeholder="What was reviewed" />
          </div>
          <div className="flex gap-2">
            <AdminButton disabled={!reviewedBy.trim() || !note.trim()} onClick={publish}>
              Publish
            </AdminButton>
            <AdminButton tone="quiet" onClick={() => setPublishing(null)}>
              Cancel
            </AdminButton>
          </div>
        </Panel>
      ) : null}
      <Panel className="space-y-3 p-4">
        <p className="font-medium text-slate-50">New version</p>
        <div className="flex gap-4">
          <div>
            <FieldLabel htmlFor="audience">For</FieldLabel>
            <SelectField id="audience" value={audience} onChange={(e) => setAudience(e.target.value)}>
              <option value="client">Clients</option>
              <option value="photographer">Photographers</option>
            </SelectField>
          </div>
          <div>
            <FieldLabel htmlFor="language">Language</FieldLabel>
            <SelectField id="language" value={language} onChange={(e) => setLanguage(e.target.value)}>
              <option value="en">EN</option>
              <option value="pt">PT</option>
            </SelectField>
          </div>
        </div>
        <div>
          <FieldLabel htmlFor="text">Wording</FieldLabel>
          <TextArea id="text" rows={6} value={text} onChange={(e) => setText(e.target.value)} placeholder="Paste the reviewed text" />
        </div>
        <AdminButton disabled={!text.trim()} onClick={create}>
          Create draft
        </AdminButton>
      </Panel>
    </div>
  );
}
