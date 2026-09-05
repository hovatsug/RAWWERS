"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { Badge, Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { admin, type ProReviewRow } from "@/lib/api/admin";
import { humanise } from "@/app/admin/labels";

/**
 * The review queue.
 *
 * Work to do, not a log: it lists photographers awaiting a decision, with
 * enough on each row to make one without opening them. The previous admin
 * page fetched an i18n bundle.
 */
export default function AdminPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ["admin", "review-queue"],
    queryFn: () => admin.reviewQueue(),
    refetchOnWindowFocus: true
  });

  if (isLoading) {
    return (
      <div className="space-y-3">
        <h1 className="text-xl font-semibold">Photographers waiting</h1>
        <Skeleton className="h-24 w-full" />
        <Skeleton className="h-24 w-full" />
      </div>
    );
  }

  if (error || !data?.ok) {
    return (
      <div className="space-y-3">
        <h1 className="text-xl font-semibold">Photographers waiting</h1>
        <Card>
          <p className="text-sm">Could not load the queue.</p>
          <p className="mt-1 text-xs text-neutral-600">
            {data && !data.ok ? data.error.message : "Check that the API is reachable."}
          </p>
        </Card>
      </div>
    );
  }

  const items = data.data.items;

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-xl font-semibold">Photographers waiting</h1>
        <p className="mt-1 text-sm text-neutral-600">
          {items.length === 0
            ? "Nobody is waiting on you."
            : `${items.length} waiting on a decision.`}
        </p>
      </div>

      {items.length === 0 ? (
        <EmptyState title="Queue is empty" body="New photographers appear here once they finish setting up." />
      ) : (
        <div className="space-y-3">
          {items.map((row) => (
            <QueueRow key={row.pro_user_id} row={row} />
          ))}
        </div>
      )}
    </div>
  );
}

function QueueRow({ row }: { row: ProReviewRow }) {
  return (
    <Link href={`/admin/pros/${row.pro_user_id}`} className="block">
      <Card className="transition hover:border-neutral-400">
        <div className="flex gap-4">
          {/* The cover is the first thing a client sees; it should be the
              first thing the reviewer sees too. */}
          {row.cover_url ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={row.cover_url}
              alt=""
              className="h-20 w-28 flex-none rounded object-cover"
            />
          ) : (
            <div className="flex h-20 w-28 flex-none items-center justify-center rounded bg-neutral-100 text-xs text-neutral-500">
              No cover
            </div>
          )}

          <div className="min-w-0 flex-1">
            <div className="flex flex-wrap items-center gap-2">
              <span className="font-medium">{row.display_name || "Unnamed"}</span>
              {row.city ? <span className="text-sm text-neutral-600">{row.city}</span> : null}
              <StatusBadges row={row} />
            </div>
            {row.headline ? (
              <p className="mt-1 truncate text-sm text-neutral-700">{row.headline}</p>
            ) : null}
            <p className="mt-2 text-xs text-neutral-600">
              {row.portfolio_photo_count}/{row.portfolio_minimum} photos · {row.active_packages} package
              {row.active_packages === 1 ? "" : "s"}
              {row.min_price ? ` · from ${row.currency} ${row.min_price}/photo` : ""}
            </p>
            {row.missing.length > 0 ? (
              <p className="mt-1 text-xs text-amber-700">Still missing: {row.missing.map(humanise).join(", ")}</p>
            ) : null}
          </div>
        </div>
      </Card>
    </Link>
  );
}

function StatusBadges({ row }: { row: ProReviewRow }) {
  return (
    <>
      {row.ready_to_approve ? (
        <Badge variant="emerald">Ready</Badge>
      ) : (
        <Badge variant="amber">Incomplete</Badge>
      )}
      {row.kyc_status === "approved" ? null : <Badge>ID {row.kyc_status}</Badge>}
      {/* Shown in the queue, not just on the detail page: a photographer
          who cannot be paid is something to know before approving, not
          after. */}
      {row.payout_blocked ? <Badge variant="amber">No payout method</Badge> : null}
    </>
  );
}
