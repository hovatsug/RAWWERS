"use client";

import { useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { proApi } from "@/lib/api/proApi";

export default function ProDashboardPage() {
  const { accessToken } = useAuth();
  const checksQ = useQuery({ queryKey: ["pro", "checks"], queryFn: () => proApi.getOnboardingChecks(accessToken), enabled: !!accessToken });
  const balanceQ = useQuery({ queryKey: ["pro", "balance"], queryFn: () => proApi.getEarningsBalance(accessToken), enabled: !!accessToken });
  const threadsQ = useQuery({ queryKey: ["pro", "threads", "dashboard"], queryFn: () => proApi.listProThreads({ limit: 5 }, accessToken), enabled: !!accessToken });

  useEffect(() => {
    if (!accessToken) return;
    proApi.track("pro_dashboard_viewed", { source: "web" }, accessToken);
  }, [accessToken]);

  if (!accessToken) return <EmptyState title="Sign in required" body="Please login as a pro." />;
  if (checksQ.isLoading || balanceQ.isLoading || threadsQ.isLoading) {
    return <div className="space-y-3"><Skeleton className="h-24" /><Skeleton className="h-24" /><Skeleton className="h-24" /></div>;
  }
  if (checksQ.isError || balanceQ.isError || threadsQ.isError) {
    return <EmptyState title="Failed to load dashboard" body="Retry from browser refresh." />;
  }

  const checks = checksQ.data?.ok ? checksQ.data.data : {};
  const balance = balanceQ.data?.ok ? balanceQ.data.data : {};
  const threads = threadsQ.data?.ok ? ((threadsQ.data.data as any).items || []) : [];

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Dashboard</h1>
      <div className="grid grid-cols-1 gap-3 md:grid-cols-3">
        <Card><p className="text-sm text-neutral-500">Pending checks</p><p className="mt-1 text-2xl font-semibold">{Object.values(checks || {}).filter((v) => v === false).length}</p></Card>
        <Card><p className="text-sm text-neutral-500">Earnings balance</p><p className="mt-1 text-2xl font-semibold">{String((balance as any).available_balance ?? (balance as any).available ?? "-")}</p></Card>
        <Card><p className="text-sm text-neutral-500">Recent threads</p><p className="mt-1 text-2xl font-semibold">{threads.length}</p></Card>
      </div>
      {threads.length === 0 ? <EmptyState title="No recent activity" body="Start from leads or gigs." /> : null}
    </div>
  );
}
