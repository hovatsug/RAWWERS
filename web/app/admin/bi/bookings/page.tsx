"use client";

import Link from "next/link";
import { Suspense, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { adminBi } from "@/lib/api/admin";
import { AdminButton, DataTable, PageHeader } from "@/app/admin/_components/ui";
import { PARAM_KEYS, PeriodBar, eur, useBiParams } from "../_parts";

/** The bookings behind a number on the dashboard: their money lines in the period. */
export default function BiBookingsPage() {
  return (
    <Suspense fallback={<PageHeader title="Bookings behind the numbers" description="Loading…" />}>
      <Bookings />
    </Suspense>
  );
}

function Bookings() {
  const { current, set } = useBiParams();
  const pro = current.pro;
  const [offset, setOffset] = useState(0);
  const qs = new URLSearchParams({ ...current, offset: String(offset), limit: "50" }).toString();
  const query = useQuery({ queryKey: ["admin", "bi", "bookings", qs], queryFn: () => adminBi.bookings(qs) });
  const page = query.data?.ok ? query.data.data : null;
  const back = new URLSearchParams(Object.fromEntries(PARAM_KEYS.filter((k) => k !== "pro" && current[k]).map((k) => [k, current[k]]))).toString();
  const filters = [current.niche && `niche ${current.niche}`, current.country && `country ${current.country}`, current.tier && `tier ${current.tier}`, pro && "one photographer"]
    .filter(Boolean)
    .join(", ");
  return (
    <>
      <PageHeader
        title="Bookings behind the numbers"
        description={`Money lines in the period${filters ? `, ${filters}` : ""}. Largest GMV first.`}
        actions={
          <Link href={`/admin/bi?${back}` as never} className="text-sm text-violet-300 hover:text-violet-200">
            ← Dashboard
          </Link>
        }
      />
      <PeriodBar current={current} set={set} />
      <DataTable
        rows={page?.items || []}
        rowKey={(row) => row.gig_id}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : null}
        empty={{ title: "No bookings", body: "No money moved on a booking in this view." }}
        columns={[
          {
            header: "Booking",
            cell: (row) => (
              <Link href={`/admin/bookings/${row.gig_id}` as never} className="font-mono text-xs text-violet-300 hover:text-violet-200">
                {row.gig_id.slice(0, 8)}
              </Link>
            )
          },
          { header: "Photographer", cell: (row) => row.pro_name || "—" },
          { header: "Niche", cell: (row) => (row.niche === "-" ? "not set" : row.niche.replace(/_/g, " ")) },
          { header: "Country", cell: (row) => (row.country === "-" ? "not set" : row.country) },
          { header: "Tier", cell: (row) => (row.tier === "-" ? "not set" : row.tier) },
          { header: "Status", cell: (row) => row.status.replace(/_/g, " ") },
          { header: "First day", cell: (row) => row.first_day },
          { header: "GMV", cell: (row) => <span className="tabular-nums">{eur(row.gmv_cents)}</span> },
          { header: "Refunds", cell: (row) => <span className="tabular-nums">{eur(row.refund_cents)}</span> },
          { header: "Retained", cell: (row) => <span className="tabular-nums">{eur(row.retained_cents)}</span> }
        ]}
      />
      {page ? (
        <div className="mt-3 flex items-center gap-3 text-sm text-slate-400">
          <span>
            {page.total ? `${page.offset + 1}–${page.offset + page.items.length} of ${page.total}` : "No bookings in this view."}
          </span>
          <AdminButton tone="secondary" disabled={offset === 0} onClick={() => setOffset(Math.max(0, offset - 50))}>
            Previous
          </AdminButton>
          <AdminButton tone="secondary" disabled={page.next_offset === null} onClick={() => setOffset(page.next_offset ?? offset)}>
            Next
          </AdminButton>
        </div>
      ) : null}
    </>
  );
}
