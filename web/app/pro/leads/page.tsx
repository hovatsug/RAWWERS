"use client";

import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { proApi } from "@/lib/api/proApi";

export default function ProLeadsPage() {
  const { accessToken } = useAuth();
  const threadsQ = useQuery({ queryKey: ["pro", "threads", "leads"], queryFn: () => proApi.listProThreads({ limit: 50 }, accessToken), enabled: !!accessToken });

  if (!accessToken) return <EmptyState title="Sign in required" />;
  if (threadsQ.isLoading) return <div className="space-y-2"><Skeleton className="h-16" /><Skeleton className="h-16" /></div>;
  if (threadsQ.isError || !threadsQ.data?.ok) return <EmptyState title="Could not load leads" body="Retry from browser refresh." />;

  const items = (((threadsQ.data.data as any) || {}).items || []) as any[];
  if (!items.length) return <EmptyState title="No leads yet" body="Leads appear from chat/request contexts." />;

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Leads</h1>
      {items.map((item, idx) => {
        const requestId = item.booking_request_id || item.request_id;
        const gigId = item.gig_id;
        return (
          <Card key={item.id || idx} className="flex items-center justify-between">
            <div>
              <p className="font-medium">{item.title || item.subject || `Thread ${item.id || idx}`}</p>
              <p className="text-sm text-neutral-500">request: {requestId || "-"} gig: {gigId || "-"}</p>
            </div>
            {gigId ? <a className="text-sm text-brand-700 underline" href={`/pro/gigs/${gigId}`}>Open gig</a> : null}
          </Card>
        );
      })}
    </div>
  );
}
