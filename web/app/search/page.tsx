"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Button, Card, EmptyState, Input, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { clientApi } from "@/lib/api/clientApi";

export default function SearchPage() {
  const { accessToken } = useAuth();
  const [q, setQ] = useState("");
  const [city, setCity] = useState("");

  const query = useMemo(() => ({ q: q || undefined, city: city || undefined, limit: 24 }), [q, city]);
  const searchQ = useQuery({ queryKey: ["client", "search", query], queryFn: () => clientApi.searchPros(query, accessToken), staleTime: 30_000 });

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Search</h1>
      <Card className="space-y-2">
        <Input placeholder="Search by name or niche" value={q} onChange={(e) => setQ(e.target.value)} />
        <Input placeholder="City" value={city} onChange={(e) => setCity(e.target.value)} />
        <Button onClick={() => searchQ.refetch()}>Apply filters</Button>
      </Card>

      {searchQ.isLoading ? <div className="space-y-2"><Skeleton className="h-20" /><Skeleton className="h-20" /></div> : null}
      {searchQ.isError || (searchQ.data && !searchQ.data.ok) ? <EmptyState title="Search failed" body="Retry filters." /> : null}

      {searchQ.data?.ok ? (
        (((searchQ.data.data as any)?.items || []) as any[]).length ? (
          <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
            {(((searchQ.data.data as any)?.items || []) as any[]).map((item, idx) => (
              <Link key={item.id || idx} href={`/pros/${item.id}`}>
                <Card>
                  <p className="font-medium">{item.display_name || item.headline || item.id}</p>
                  <p className="text-sm text-neutral-600">{item.city || "-"}, {item.country || "-"}</p>
                  <p className="mt-1 text-sm">From {item.price_min ?? "-"}</p>
                </Card>
              </Link>
            ))}
          </div>
        ) : <EmptyState title="No results" body="Try wider filters." />
      ) : null}
    </div>
  );
}
