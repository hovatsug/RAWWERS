"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Button, Card, Input, Textarea } from "@/design-system/primitives";
import { discovery } from "@/lib/api/discovery";
import { booking } from "@/lib/api/booking";
import { useAuth } from "@/lib/auth/store";
import { useState } from "react";

export default function ProProfilePage() {
  const { id } = useParams<{ id: string }>();
  const { accessToken } = useAuth();
  const [requestedStart, setRequestedStart] = useState("");
  const [requestedEnd, setRequestedEnd] = useState("");
  const [message, setMessage] = useState("Quick session request");

  useQuery({ queryKey: ["pro", id], queryFn: () => discovery.getClientProProfile(id, accessToken) });
  // NOTE: this payload shape is known-wrong against the real
  // ClientBookingRequestCreateRequest schema (missing niche_slug/
  // package_id, flat dates instead of a nested date_window, `message`
  // instead of `notes`) - fixing it is scoped to a separate booking-request
  // task, not this consolidation. Left as-is intentionally.
  const create = useMutation({
    mutationFn: () =>
      booking.createBookingRequest(
        {
          pro_user_id: id,
          requested_start: new Date(requestedStart).toISOString(),
          requested_end: new Date(requestedEnd).toISOString(),
          message
        },
        accessToken
      )
  });

  return (
    <div className="space-y-3">
      <Card>
        <p className="text-xl font-semibold">Pro {id.slice(0, 8)}</p>
        <p className="text-sm text-neutral-600">Public profile and portfolio.</p>
      </Card>
      <Card className="space-y-2">
        <p className="font-medium">Request booking</p>
        <Input type="datetime-local" value={requestedStart} onChange={(e) => setRequestedStart(e.target.value)} />
        <Input type="datetime-local" value={requestedEnd} onChange={(e) => setRequestedEnd(e.target.value)} />
        <Textarea value={message} onChange={(e) => setMessage(e.target.value)} />
        <Button onClick={() => create.mutate()} disabled={!requestedStart || !requestedEnd || create.isPending}>Send request</Button>
        {create.data?.ok ? <p className="text-sm text-green-700">Created: {(create.data.data as any).booking_request_id}</p> : null}
        {create.data && !create.data.ok ? <p className="text-sm text-red-700">{create.data.error.message || "Request failed."}</p> : null}
      </Card>
      <Link href={`/chat/${id}`} className="text-sm">Open chat</Link>
    </div>
  );
}
