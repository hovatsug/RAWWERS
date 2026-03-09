"use client";

import Link from "next/link";
import type { Route } from "next";
import { useEffect, useState } from "react";
import { Card, EmptyState } from "@/design-system/primitives";

const KEY = "rawwers_client_recent_booking_ids";

export default function BookingsPage() {
  const [ids, setIds] = useState<string[]>([]);

  useEffect(() => {
    const raw = window.localStorage.getItem(KEY);
    if (!raw) return;
    try {
      setIds(JSON.parse(raw) as string[]);
    } catch {
      setIds([]);
    }
  }, []);

  if (!ids.length) return <EmptyState title="No recent bookings" body="Bookings appear here after creation." />;

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Bookings</h1>
      {ids.map((id) => (
        <Link key={id} href={`/bookings/${id}` as Route}>
          <Card>Booking {id}</Card>
        </Link>
      ))}
    </div>
  );
}
