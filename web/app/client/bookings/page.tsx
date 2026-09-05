"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { booking } from "@/lib/api/booking";
import { useAuth } from "@/lib/auth/store";

export default function ClientBookingsPage() {
  const { accessToken } = useAuth();
  // BACKEND GAP: GET /v1/client/bookings (list) does not exist - this call
  // always fails. Reported, not fixed here; see booking.clientBookings.
  const { data, isLoading } = useQuery({ queryKey: ["client-bookings"], queryFn: () => booking.clientBookings(accessToken) });

  if (isLoading) return <Skeleton className="h-20 w-full" />;
  if (data && !data.ok) return <EmptyState title="Bookings unavailable" body="This list isn't wired up on the backend yet." />;
  if (!data?.data.items?.length) return <EmptyState title="No bookings yet" />;

  return (
    <div className="space-y-2">
      <h1 className="text-xl font-semibold">Bookings</h1>
      {data.data.items.map((item: any) => (
        <Link key={item.id || item.booking_request_id} href={`/client/bookings/${item.id || item.booking_request_id}`}>
          <Card>
            <p className="text-sm">Booking {String(item.id || item.booking_request_id).slice(0, 8)}</p>
          </Card>
        </Link>
      ))}
    </div>
  );
}
