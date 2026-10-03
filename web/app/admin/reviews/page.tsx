"use client";

import { useEffect, useState } from "react";
import { keepPreviousData, useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type AdminReviewRow, type ReviewStatus } from "@/lib/api/admin";
import {
  AdminButton,
  ConfirmDialog,
  DataTable,
  PageHeader,
  SelectField,
  StatusBadge,
  TextField,
  statusLabel,
  type Column
} from "@/app/admin/_components/ui";

/**
 * Every review, in any status, newest first.
 *
 * The public list shows published reviews only, so this is the only place a
 * hidden review can be found again. Each row names who wrote it about whom -
 * a moderator has to be able to see that one client is leaving the same
 * review on every competitor - and the last decision made on it, and why.
 *
 * Hidden and removed have the same effect today: off the photographer's
 * profile and out of their rating. The dialogs say so rather than implying a
 * difference that does not exist; the distinction is only in the record.
 */

const PAGE = 50;

type Action = { row: AdminReviewRow; to: ReviewStatus };

const ACTIONS: Record<ReviewStatus, { label: string; to: ReviewStatus; tone: "primary" | "danger" }[]> = {
  published: [
    { label: "Hide…", to: "hidden", tone: "primary" },
    { label: "Remove…", to: "removed", tone: "danger" }
  ],
  hidden: [
    { label: "Restore…", to: "published", tone: "primary" },
    { label: "Remove…", to: "removed", tone: "danger" }
  ],
  removed: [{ label: "Restore…", to: "published", tone: "primary" }]
};

export default function AdminReviewsPage() {
  const queryClient = useQueryClient();
  const [status, setStatus] = useState<"" | ReviewStatus>("");
  const [ratingMax, setRatingMax] = useState<number | null>(null);
  const [search, setSearch] = useState("");
  const [q, setQ] = useState("");
  const [offset, setOffset] = useState(0);
  const [acting, setActing] = useState<Action | null>(null);

  // Search as the moderator types, without a request per keystroke.
  useEffect(() => {
    const timer = setTimeout(() => {
      setQ(search);
      setOffset(0);
    }, 300);
    return () => clearTimeout(timer);
  }, [search]);

  const query = useQuery({
    queryKey: ["admin", "reviews", status, ratingMax, q, offset],
    queryFn: () => admin.reviews({ status, ratingMax, q, offset, limit: PAGE }),
    placeholderData: keepPreviousData
  });
  const list = query.data?.ok ? query.data.data : undefined;
  const refresh = () => queryClient.invalidateQueries({ queryKey: ["admin", "reviews"] });

  const columns: Column<AdminReviewRow>[] = [
    {
      header: "Review",
      cell: (row) => (
        <div className="max-w-xl space-y-1">
          <p className="text-sm">
            <span className="text-amber-300" aria-label={`${row.rating} out of 5`}>
              {"★".repeat(row.rating)}
              <span className="text-slate-600">{"★".repeat(5 - row.rating)}</span>
            </span>
            {row.would_book_again ? null : <span className="ml-2 text-xs text-slate-400">would not book again</span>}
          </p>
          {row.text ? (
            <p className="whitespace-pre-wrap text-slate-100">{row.text}</p>
          ) : (
            <p className="text-slate-500">No written review</p>
          )}
          {row.has_video ? <p className="text-xs text-slate-400">Includes a video</p> : null}
          {row.reply_text ? (
            <p className="border-l-2 border-white/10 pl-2 text-xs text-slate-400">Reply: {row.reply_text}</p>
          ) : null}
        </div>
      )
    },
    {
      header: "About · by",
      cell: (row) => (
        <div className="space-y-0.5 text-xs">
          <p className="text-sm text-slate-100">{row.pro_display_name || "Unnamed photographer"}</p>
          <p className="text-slate-400">{row.niche_name ?? ""}</p>
          <p className="text-slate-400">by {row.client_email || "a client with no email"}</p>
          <p className="text-slate-500">{date(row.created_at)}</p>
        </div>
      )
    },
    {
      header: "Status",
      cell: (row) => (
        <div className="space-y-1">
          <StatusBadge status={row.status} />
          {row.last_moderation ? (
            <p className="max-w-[14rem] text-xs text-slate-400">
              {row.last_moderation.action === "published" ? "Restored" : statusLabel(row.last_moderation.action)}{" "}
              {date(row.last_moderation.at)}
              {row.last_moderation.reason ? `: ${row.last_moderation.reason}` : ""}
            </p>
          ) : null}
        </div>
      )
    },
    {
      header: "",
      className: "w-px whitespace-nowrap text-right",
      cell: (row) => (
        <div className="flex justify-end gap-2">
          {ACTIONS[row.status].map((action) => (
            <AdminButton
              key={action.to}
              tone={action.tone === "danger" ? "danger" : "secondary"}
              onClick={() => setActing({ row, to: action.to })}
            >
              {action.label}
            </AdminButton>
          ))}
        </div>
      )
    }
  ];

  const counts = list?.counts;
  const total = list?.total ?? 0;
  const who = acting ? acting.row.pro_display_name || "this photographer" : "";

  return (
    <>
      <PageHeader
        title="Reviews"
        description={
          counts
            ? `${counts.published} published · ${counts.hidden} hidden · ${counts.removed} removed. Newest first.`
            : "Every review, in any status, newest first."
        }
      />

      <div className="mb-3 flex flex-wrap gap-2">
        <div className="w-full max-w-xs">
          <TextField
            aria-label="Search reviews"
            placeholder="Search text, photographer or client email"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
          />
        </div>
        <div className="w-40">
          <SelectField
            aria-label="Status"
            value={status}
            onChange={(event) => {
              setStatus(event.target.value as "" | ReviewStatus);
              setOffset(0);
            }}
          >
            <option value="">All statuses</option>
            <option value="published">Published</option>
            <option value="hidden">Hidden</option>
            <option value="removed">Removed</option>
          </SelectField>
        </div>
        <div className="w-40">
          <SelectField
            aria-label="Rating"
            value={ratingMax ?? ""}
            onChange={(event) => {
              setRatingMax(event.target.value ? Number(event.target.value) : null);
              setOffset(0);
            }}
          >
            <option value="">Any rating</option>
            <option value="2">2 stars or fewer</option>
            <option value="1">1 star</option>
          </SelectField>
        </div>
      </div>

      <DataTable
        columns={columns}
        rows={list?.items}
        rowKey={(row) => row.id}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : query.error ? "Check that the API is reachable." : null}
        onRetry={() => query.refetch()}
        empty={
          status || ratingMax || q
            ? { title: "No matches", body: "No review matches these filters." }
            : { title: "No reviews yet", body: "Reviews appear here as clients leave them after a shoot." }
        }
      />

      {total > PAGE ? (
        <div className="mt-3 flex items-center justify-between text-sm text-slate-400">
          <span>
            {offset + 1}–{Math.min(offset + PAGE, total)} of {total}
          </span>
          <div className="flex gap-2">
            <AdminButton tone="secondary" disabled={offset === 0} onClick={() => setOffset(Math.max(0, offset - PAGE))}>
              Newer
            </AdminButton>
            <AdminButton tone="secondary" disabled={offset + PAGE >= total} onClick={() => setOffset(offset + PAGE)}>
              Older
            </AdminButton>
          </div>
        </div>
      ) : null}

      <ConfirmDialog
        open={acting !== null}
        title={
          acting
            ? acting.to === "published"
              ? `Restore this review of ${who}?`
              : `${acting.to === "hidden" ? "Hide" : "Remove"} this ${acting.row.rating}-star review of ${who}?`
            : ""
        }
        confirmLabel={acting ? (acting.to === "published" ? "Restore" : acting.to === "hidden" ? "Hide" : "Remove") : ""}
        tone={acting?.to === "removed" ? "danger" : "primary"}
        reason={{ label: "Reason — kept in the audit log", placeholder: "e.g. Names a third party" }}
        onClose={() => setActing(null)}
        onConfirm={async (reason) => {
          if (!acting) return null;
          const res = await admin.moderateReview(acting.row.id, acting.to, reason);
          if (!res.ok) return res.error.message;
          refresh();
          return null;
        }}
      >
        {acting?.to === "published" ? (
          <p>It goes back on {who}&apos;s profile and counts towards their rating again.</p>
        ) : (
          <p>
            It comes off {who}&apos;s profile and stops counting towards their rating. Hidden and removed have the same effect; the
            difference is only in the record. It stays listed here and can be restored.
          </p>
        )}
      </ConfirmDialog>
    </>
  );
}

function date(value: string): string {
  return new Date(value).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" });
}
