"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import {
  admin,
  type MarketingConsentRow,
  type MarketingTakeDown,
  type MarketingUse
} from "@/lib/api/admin";
import {
  AdminButton,
  DataTable,
  FieldLabel,
  Notice,
  PageHeader,
  Panel,
  SelectField,
  StatusBadge,
  TextField,
  type Column,
  type Tone
} from "@/app/admin/_components/ui";

/**
 * The marketing content library (closed beta). Only the per-photo consent
 * records count here: they are the sole authority for RAWWERS using a
 * client's photos in its own marketing - organic posts on its own channels,
 * nothing else.
 *
 * Four parts: the photos clients have allowed (with filters, and the
 * original behind a short signed link for an active permission, every
 * opening logged); recording a use against chosen photos; content by the
 * date it has to be retired (the earliest end of its photos' permissions);
 * and, for permissions withdrawn or ended after being used, the date the
 * content must be down by.
 */

type Tab = "library" | "expiring" | "take-down";

function day(value: string): string {
  return new Date(value).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" });
}

function toneFor(status: string): Tone {
  return status === "active" ? "positive" : status === "withdrawn" ? "attention" : "neutral";
}

export default function AdminMarketingPage() {
  const [tab, setTab] = useState<Tab>("library");
  return (
    <>
      <PageHeader
        title="Marketing library"
        description="Photos clients let RAWWERS feature on its own channels, organic posts only. Always credit the photographer."
      />
      <div className="mb-4 flex gap-2">
        <AdminButton tone={tab === "library" ? "primary" : "secondary"} onClick={() => setTab("library")}>
          Photos
        </AdminButton>
        <AdminButton tone={tab === "expiring" ? "primary" : "secondary"} onClick={() => setTab("expiring")}>
          Expiring soon
        </AdminButton>
        <AdminButton tone={tab === "take-down" ? "primary" : "secondary"} onClick={() => setTab("take-down")}>
          Take down by
        </AdminButton>
      </div>
      {tab === "library" ? <Library /> : tab === "expiring" ? <Expiring /> : <TakeDown />}
    </>
  );
}

function Library() {
  const queryClient = useQueryClient();
  const [status, setStatus] = useState("active");
  const [pro, setPro] = useState("");
  const [chosen, setChosen] = useState<Set<string>>(new Set());
  const [content, setContent] = useState("");
  const [usedOn, setUsedOn] = useState(() => new Date().toISOString().slice(0, 10));
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  const query = useQuery({
    queryKey: ["admin", "marketing", "consents", status, pro],
    queryFn: () => admin.marketingConsents({ status, pro_user_id: pro.trim() })
  });
  const rows = query.data?.ok ? query.data.data.items : undefined;

  const openOriginal = async (row: MarketingConsentRow) => {
    const res = await admin.marketingOriginal(row.id);
    if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
    window.open(res.data.url, "_blank", "noopener");
  };

  const recordUse = async () => {
    const res = await admin.recordMarketingUse({ content_name: content.trim(), used_on: usedOn, consent_ids: [...chosen] });
    if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
    setMessage({ tone: "success", text: `Recorded "${res.data.content_name}". Retire it by ${day(res.data.retire_by)}.` });
    setChosen(new Set());
    setContent("");
    queryClient.invalidateQueries({ queryKey: ["admin", "marketing"] });
  };

  const columns: Column<MarketingConsentRow>[] = [
    {
      header: "",
      className: "w-px",
      cell: (row) =>
        row.status === "active" ? (
          <input
            type="checkbox"
            aria-label="Choose for a use"
            checked={chosen.has(row.id)}
            onChange={(e) => {
              const next = new Set(chosen);
              if (e.target.checked) next.add(row.id);
              else next.delete(row.id);
              setChosen(next);
            }}
          />
        ) : null
    },
    {
      header: "Photo",
      cell: (row) =>
        row.thumbnail_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={row.thumbnail_url} alt="" className="h-14 w-14 rounded object-cover" />
        ) : (
          <div className="h-14 w-14 rounded bg-white/5" />
        )
    },
    { header: "Client", cell: (row) => row.client_first_name },
    { header: "Credit", cell: (row) => row.photographer_credit },
    { header: "Scope", cell: (row) => (row.scope === "rawwers_organic" ? "RAWWERS channels, organic" : row.scope) },
    { header: "Ends", className: "whitespace-nowrap", cell: (row) => day(row.ends_at) },
    { header: "Status", cell: (row) => <StatusBadge label={row.status} tone={toneFor(row.status)} /> },
    { header: "Uses", className: "tabular-nums", cell: (row) => row.uses },
    {
      header: "",
      className: "w-px whitespace-nowrap text-right",
      cell: (row) =>
        row.status === "active" ? (
          <AdminButton tone="secondary" onClick={() => openOriginal(row)}>
            Open original
          </AdminButton>
        ) : null
    }
  ];

  return (
    <div className="space-y-4">
      {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
      <Panel className="flex flex-wrap items-end gap-4 p-4">
        <div>
          <FieldLabel htmlFor="status">Status</FieldLabel>
          <SelectField id="status" value={status} onChange={(e) => setStatus(e.target.value)}>
            <option value="active">Active</option>
            <option value="withdrawn">Withdrawn</option>
            <option value="expired">Expired</option>
            <option value="">All</option>
          </SelectField>
        </div>
        <div className="min-w-72">
          <FieldLabel htmlFor="pro">Photographer (user id)</FieldLabel>
          <TextField id="pro" value={pro} onChange={(e) => setPro(e.target.value)} placeholder="All photographers" />
        </div>
      </Panel>
      <DataTable
        columns={columns}
        rows={rows}
        rowKey={(row) => row.id}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : query.error ? "Check that the API is reachable." : null}
        onRetry={() => query.refetch()}
        empty={{ title: "No photos", body: "Photos clients let RAWWERS feature appear here." }}
      />
      <Panel className="flex flex-wrap items-end gap-4 p-4">
        <div className="min-w-72 flex-1">
          <FieldLabel htmlFor="content">Used in</FieldLabel>
          <TextField id="content" value={content} onChange={(e) => setContent(e.target.value)} placeholder="e.g. Instagram reel: autumn portraits" />
        </div>
        <div>
          <FieldLabel htmlFor="used-on">On</FieldLabel>
          <TextField id="used-on" type="date" value={usedOn} onChange={(e) => setUsedOn(e.target.value)} />
        </div>
        <AdminButton disabled={chosen.size === 0 || !content.trim()} onClick={recordUse}>
          Record use of {chosen.size} {chosen.size === 1 ? "photo" : "photos"}
        </AdminButton>
      </Panel>
    </div>
  );
}

function Expiring() {
  const query = useQuery({ queryKey: ["admin", "marketing", "expiring"], queryFn: () => admin.marketingExpiring() });
  const columns: Column<MarketingUse>[] = [
    { header: "Retire by", className: "whitespace-nowrap font-semibold", cell: (row) => day(row.retire_by) },
    { header: "Content", cell: (row) => row.content_name },
    { header: "Used on", className: "whitespace-nowrap", cell: (row) => day(row.used_on) },
    { header: "Photos", className: "tabular-nums", cell: (row) => row.consents.length }
  ];
  return (
    <DataTable
      columns={columns}
      rows={query.data?.ok ? query.data.data.items : undefined}
      rowKey={(row) => row.id}
      loading={query.isLoading}
      error={query.data && !query.data.ok ? query.data.error.message : null}
      onRetry={() => query.refetch()}
      empty={{ title: "No content recorded", body: "Record a use from the Photos tab." }}
    />
  );
}

function TakeDown() {
  const query = useQuery({ queryKey: ["admin", "marketing", "take-down"], queryFn: () => admin.marketingTakeDowns() });
  const columns: Column<MarketingTakeDown>[] = [
    {
      header: "Down by",
      className: "whitespace-nowrap font-semibold",
      cell: (row) => {
        const overdue = new Date(row.take_down_by).getTime() < Date.now();
        return <StatusBadge label={overdue ? `Overdue since ${day(row.take_down_by)}` : day(row.take_down_by)} tone={overdue ? "attention" : "info"} />;
      }
    },
    { header: "Content", cell: (row) => row.content_name },
    { header: "Why", cell: (row) => (row.reason === "withdrawn" ? "Client withdrew" : "Permission ended") },
    { header: "Ended", className: "whitespace-nowrap", cell: (row) => day(row.ended_at) }
  ];
  return (
    <DataTable
      columns={columns}
      rows={query.data?.ok ? query.data.data.items : undefined}
      rowKey={(row) => `${row.use_id}:${row.consent_id}`}
      loading={query.isLoading}
      error={query.data && !query.data.ok ? query.data.error.message : null}
      onRetry={() => query.refetch()}
      empty={{ title: "Nothing to take down", body: "Content whose photos' permissions end appears here, with the date it must be down by." }}
    />
  );
}
