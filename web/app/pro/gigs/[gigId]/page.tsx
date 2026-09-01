"use client";

import { useParams } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { proApi } from "@/lib/api/proApi";

export default function ProGigDetailPage() {
  const { gigId } = useParams<{ gigId: string }>();
  const { accessToken } = useAuth();
  const gigQ = useQuery({ queryKey: ["pro", "gig", gigId], queryFn: () => proApi.getGig(gigId, accessToken), enabled: !!accessToken && !!gigId });

  if (gigQ.isLoading) return <Skeleton className="h-32" />;
  if (gigQ.isError || !gigQ.data?.ok) return <EmptyState title="Gig not found" />;

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Gig {gigId}</h1>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(gigQ.data.data, null, 2)}</pre></Card>
      <div className="flex gap-3">
        <a className="text-sm text-brand-700 underline" href={`/pro/gigs/${gigId}/chat`}>Chat</a>
        <a className="text-sm text-brand-700 underline" href={`/pro/gigs/${gigId}/delivery`}>Delivery Studio</a>
      </div>
    </div>
  );
}
