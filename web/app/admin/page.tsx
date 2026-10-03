"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { admin, type ProReviewRow } from "@/lib/api/admin";
import { humanise } from "@/app/admin/labels";
import { DataTable, PageHeader, StatusBadge, money, type Column } from "@/app/admin/_components/ui";

/**
 * Photographers waiting on a decision.
 *
 * Work to do, not a log: each row carries enough to decide without opening
 * it - how far they got, whether they can be paid - and opens the full
 * review, where the decision is made.
 */
export default function AdminPhotographersPage() {
  const query = useQuery({
    queryKey: ["admin", "review-queue"],
    queryFn: () => admin.reviewQueue(),
    refetchOnWindowFocus: true
  });
  const items = query.data?.ok ? query.data.data.items : undefined;

  const columns: Column<ProReviewRow>[] = [
    {
      header: "Photographer",
      cell: (row) => (
        <Link href={`/admin/pros/${row.pro_user_id}`} className="flex items-center gap-3 hover:underline">
          {/* The cover is the first thing a client sees; it should be the
              first thing the reviewer sees too. */}
          {row.cover_url ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={row.cover_url} alt="" className="h-10 w-14 flex-none rounded object-cover" />
          ) : (
            <span className="flex h-10 w-14 flex-none items-center justify-center rounded bg-white/[0.06] text-[10px] text-slate-500">
              No cover
            </span>
          )}
          <span>
            <span className="block font-medium text-slate-50">{row.display_name || "Unnamed"}</span>
            {row.city ? <span className="block text-xs text-slate-500">{row.city}</span> : null}
          </span>
        </Link>
      )
    },
    {
      header: "Setup",
      cell: (row) => (
        <div className="space-y-1">
          {row.ready_to_approve ? (
            <StatusBadge label="Ready" tone="positive" />
          ) : (
            <StatusBadge label="Incomplete" tone="attention" />
          )}
          {row.missing.length > 0 ? (
            <p className="text-xs text-slate-500">Missing: {row.missing.map(humanise).join(", ")}</p>
          ) : null}
        </div>
      )
    },
    {
      header: "Portfolio",
      cell: (row) => (
        <span className="tabular-nums">
          {row.portfolio_photo_count}/{row.portfolio_minimum} photos · {row.active_packages} package
          {row.active_packages === 1 ? "" : "s"}
        </span>
      )
    },
    {
      header: "From",
      cell: (row) => (row.min_price ? `${money(row.min_price, row.currency)}/photo` : "—")
    },
    {
      header: "Checks",
      cell: (row) => (
        <div className="flex flex-wrap gap-1">
          {row.kyc_status === "approved" ? null : <StatusBadge label={`ID ${row.kyc_status}`} tone="neutral" />}
          {/* In the queue, not just on the review page: a photographer who
              cannot be paid is something to know before approving. */}
          {row.payout_blocked ? <StatusBadge label="No payout method" tone="attention" /> : null}
          {row.kyc_status === "approved" && !row.payout_blocked ? <span className="text-xs text-slate-500">—</span> : null}
        </div>
      )
    }
  ];

  return (
    <>
      <PageHeader
        title="Photographers waiting"
        description={
          items === undefined
            ? "New photographers appear here once they finish setting up."
            : items.length === 0
              ? "Nobody is waiting on you."
              : `${items.length} waiting on a decision. Open one to review and decide.`
        }
      />
      <DataTable
        columns={columns}
        rows={items}
        rowKey={(row) => row.pro_user_id}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : query.error ? "Check that the API is reachable." : null}
        onRetry={() => query.refetch()}
        empty={{ title: "Queue is empty", body: "New photographers appear here once they finish setting up." }}
      />
    </>
  );
}
