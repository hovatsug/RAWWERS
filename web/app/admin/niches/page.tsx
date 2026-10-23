"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { admin, type NicheBannerRow } from "@/lib/api/admin";
import { DataTable, PageHeader, StatusBadge } from "@/app/admin/_components/ui";

/**
 * Every niche's banner at a glance. "Image missing" is the one to act on: a
 * niche meant to show an image that has none, so the app shows a plain
 * ground in its place.
 */
export default function NicheBannersPage() {
  const query = useQuery({ queryKey: ["admin", "niche-banners"], queryFn: () => admin.nicheBanners() });
  const data = query.data?.ok ? query.data.data : undefined;

  return (
    <>
      <PageHeader
        title="Niche banners"
        description="The image or text banner each niche shows on Discover and at the top of its page. Changes reach the apps on their next load."
      />
      <DataTable<NicheBannerRow>
        rows={data?.items}
        rowKey={(row) => row.slug}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : null}
        onRetry={() => query.refetch()}
        empty={{ title: "No niches" }}
        columns={[
          {
            header: "Niche",
            cell: (row) => (
              <Link href={`/admin/niches/${row.slug}`} className="font-medium text-violet-300 hover:underline">
                {row.name}
                {row.is_active ? null : <span className="ml-2 text-xs text-slate-500">inactive</span>}
              </Link>
            )
          },
          {
            header: "Banner",
            cell: (row) =>
              row.banner_style === "image" && row.current?.tile_url ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={row.current.tile_url} alt={row.current.alt_text} className="h-10 w-28 rounded object-cover" />
              ) : (
                <span className="text-xs text-slate-500">{row.banner_style === "text" ? "Typographic" : "None"}</span>
              )
          },
          { header: "Alt text", cell: (row) => <span className="text-slate-300">{row.current?.alt_text ?? "—"}</span> },
          { header: "Style", cell: (row) => (row.banner_style === "text" ? "Text only" : "Image") },
          { header: "Status", cell: (row) => <StatusBadge status={row.status} /> }
        ]}
      />
    </>
  );
}
