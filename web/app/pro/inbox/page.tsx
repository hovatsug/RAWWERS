"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState } from "@/design-system/primitives";
import { proApi } from "@/lib/api/proApi";
import { useAuth } from "@/lib/auth/store";

export default function ProInboxPage() {
  const { accessToken } = useAuth();
  const { data } = useQuery({ queryKey: ["pro-inbox"], queryFn: () => proApi.listProThreads({ limit: 50 }, accessToken), enabled: !!accessToken });
  const items = data?.ok ? (((data.data as any) || {}).items || []) : [];

  if (!items.length) return <EmptyState title="No requests" />;
  return (
    <div className="space-y-2">
      <h1 className="text-xl font-semibold">Pro inbox</h1>
      {items.map((item: any) => (
        <Link key={item.id || item.booking_request_id} href={`/pro/bookings/${item.id || item.booking_request_id}`}>
          <Card>Request {String(item.id || item.booking_request_id).slice(0, 8)}</Card>
        </Link>
      ))}
    </div>
  );
}
