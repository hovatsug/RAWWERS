"use client";

import Link from "next/link";
import type { Route } from "next";
import { useParams } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { clientApi } from "@/lib/api/clientApi";

export default function BookingDetailPage() {
  const { bookingId } = useParams<{ bookingId: string }>();
  const { accessToken } = useAuth();
  const bookingQ = useQuery({ queryKey: ["client", "booking", bookingId], queryFn: () => clientApi.getClientBooking(bookingId, accessToken), enabled: !!bookingId });

  if (bookingQ.isLoading) return <Skeleton className="h-24" />;
  if (!bookingQ.data?.ok) return <EmptyState title="Booking unavailable" />;

  const gigId = (bookingQ.data.data as any)?.gig_id;
  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Booking {bookingId}</h1>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(bookingQ.data.data, null, 2)}</pre></Card>
      {gigId ? <Link href={`/gigs/${gigId}` as Route} className="text-sm text-brand-700 underline">Open gig</Link> : null}
    </div>
  );
}
