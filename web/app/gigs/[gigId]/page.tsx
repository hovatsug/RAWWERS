"use client";

import Link from "next/link";
import type { Route } from "next";
import { useParams } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { clientApi } from "@/lib/api/clientApi";

export default function GigPage() {
  const { gigId } = useParams<{ gigId: string }>();
  const { accessToken } = useAuth();
  const gigQ = useQuery({ queryKey: ["client", "gig", gigId], queryFn: () => clientApi.getGig(gigId, accessToken), enabled: !!gigId });

  if (gigQ.isLoading) return <Skeleton className="h-24" />;
  if (!gigQ.data?.ok) return <EmptyState title="Gig unavailable" />;

  const galleryId = (gigQ.data.data as any)?.gallery_id || (gigQ.data.data as any)?.proof_gallery_id;

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Gig {gigId}</h1>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(gigQ.data.data, null, 2)}</pre></Card>
      <div className="flex gap-3 text-sm">
        {galleryId ? <Link href={`/gigs/${gigId}/gallery/${galleryId}` as Route} className="text-brand-700 underline">Open gallery</Link> : null}
        <Link href={`/gigs/${gigId}/delivery` as Route} className="text-brand-700 underline">Delivery</Link>
      </div>
    </div>
  );
}
