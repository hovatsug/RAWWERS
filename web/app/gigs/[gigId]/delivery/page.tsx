"use client";

import { useParams } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { clientApi } from "@/lib/api/clientApi";

export default function DeliveryPage() {
  const { gigId } = useParams<{ gigId: string }>();
  const { accessToken } = useAuth();
  const mediaQ = useQuery({ queryKey: ["client", "gig", gigId, "media"], queryFn: () => clientApi.listGigMedia(gigId, accessToken), enabled: !!gigId });

  if (mediaQ.isLoading) return <Skeleton className="h-24" />;
  if (!mediaQ.data?.ok) return <EmptyState title="Delivery unavailable" />;

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Delivery</h1>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(mediaQ.data.data, null, 2)}</pre></Card>
    </div>
  );
}
