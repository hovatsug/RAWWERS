"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Button, Card } from "@/design-system/primitives";
import { booking as bookingApi } from "@/lib/api/booking";
import { useAuth } from "@/lib/auth/store";

export default function ClientBookingDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { accessToken } = useAuth();
  const booking = useQuery({ queryKey: ["client-booking", id], queryFn: () => bookingApi.clientBooking(id, accessToken) });
  const pay = useMutation({ mutationFn: () => bookingApi.payClientBooking(id, accessToken) });

  return (
    <div className="space-y-3">
      <Card>
        <h1 className="text-xl font-semibold">Booking {id.slice(0, 8)}</h1>
        <p className="text-sm text-neutral-600">Timeline, chat, payment status.</p>
      </Card>
      <Card className="space-y-2">
        <Button onClick={() => pay.mutate()} disabled={pay.isPending}>Pay now</Button>
        {pay.data?.ok ? <p className="text-sm text-green-700">Payment trigger sent.</p> : null}
        {pay.data && !pay.data.ok ? <p className="text-sm text-red-700">{pay.data.error.message || "Payment failed."}</p> : null}
        <Link href={`/chat/${id}`} className="text-sm">Open chat</Link>
      </Card>
      <Card>
        <Link href={`/client/gigs/${id}/proofs`}>Open proof gallery</Link>
      </Card>
      {booking.isLoading ? <p className="text-sm">Loading booking…</p> : null}
      {booking.data && !booking.data.ok ? <p className="text-sm text-red-700">Couldn't load this booking.</p> : null}
    </div>
  );
}
