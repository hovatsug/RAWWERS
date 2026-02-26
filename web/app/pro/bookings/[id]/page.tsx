"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { Button, Card } from "@/design-system/primitives";

export default function ProBookingDetailPage() {
  const { id } = useParams<{ id: string }>();

  return (
    <div className="space-y-3">
      <Card>
        <h1 className="text-xl font-semibold">Booking request {id.slice(0, 8)}</h1>
        <p className="text-sm text-neutral-600">Accept request, confirm slot, and move to paid workflow.</p>
      </Card>
      <Card className="space-y-2">
        <Button>Accept request</Button>
        <Button className="bg-neutral-700">Confirm schedule slot</Button>
      </Card>
      <Card>
        <Link href={`/pro/gigs/${id}/upload`}>Upload proofs</Link>
      </Card>
    </div>
  );
}
