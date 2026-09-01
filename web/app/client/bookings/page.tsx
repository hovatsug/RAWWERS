"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { endpoints } from "@/lib/api/endpoints";
import { useAuth } from "@/lib/auth/store";

export default function ClientBookingsPage() {
  const { accessToken } = useAuth();
  const { data, isLoading } = useQuery({ queryKey: ["client-bookings"], queryFn: () => endpoints.clientBookings(accessToken) });

  if (isLoading) return <Skeleton className="h-20 w-full" />;
  if (!data?.items?.length) return <EmptyState title="No bookings yet" />;

  return (
    <div className="space-y-2">
      <h1 className="text-xl font-semibold">Bookings</h1>
      {data.items.map((item: any) => (
        <Link key={item.id || item.booking_request_id} href={`/client/bookings/${item.id || item.booking_request_id}`}>
          <Card>
            <p className="text-sm">Booking {String(item.id || item.booking_request_id).slice(0, 8)}</p>
          </Card>
        </Link>
      ))}
    </div>
  );
}
