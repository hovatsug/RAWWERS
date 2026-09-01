"use client";

import { useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { EmptyState, GlassCard, GlowOrbs, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { proApi } from "@/lib/api/proApi";

function StatCard({
  label,
  value,
  accent = "violet",
}: {
  label: string;
  value: string | number;
  accent?: "violet" | "emerald" | "amber";
}) {
  const orbColors: Record<string, string> = {
    violet: "bg-violet-600/20",
    emerald: "bg-emerald-500/20",
    amber: "bg-amber-500/20",
  };
  const valueColors: Record<string, string> = {
    violet: "text-violet-300",
    emerald: "text-emerald-300",
    amber: "text-amber-300",
  };

  return (
    <GlassCard className="p-5 overflow-hidden">
      <div className={`pointer-events-none absolute -right-3 -top-3 h-20 w-20 rounded-full blur-2xl ${orbColors[accent]}`} />
      <p className="text-xs font-medium uppercase tracking-widest text-slate-500">{label}</p>
      <p className={`mt-2 text-3xl font-bold ${valueColors[accent]}`}>{value}</p>
    </GlassCard>
  );
}

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
    return (
      <div className="space-y-4">
        <GlowOrbs variant="dashboard" />
        <Skeleton className="h-8 w-48" />
        <div className="grid grid-cols-1 gap-3 md:grid-cols-3">
          <Skeleton className="h-28" />
          <Skeleton className="h-28" />
          <Skeleton className="h-28" />
        </div>
        <Skeleton className="h-40" />
      </div>
    );
  }

  if (checksQ.isError || balanceQ.isError || threadsQ.isError) {
    return <EmptyState title="Failed to load dashboard" body="Retry from browser refresh." />;
  }

  const checks = checksQ.data?.ok ? checksQ.data.data : {};
  const balance = balanceQ.data?.ok ? balanceQ.data.data : {};
  const threads = threadsQ.data?.ok ? ((threadsQ.data.data as any).items || []) : [];
  const pendingCount = Object.values(checks || {}).filter((v) => v === false).length;
  const availableBalance = String((balance as any).available_balance ?? (balance as any).available ?? "—");

  return (
    <div className="relative space-y-5">
      <GlowOrbs variant="dashboard" />

      <div>
        <h1 className="text-2xl font-bold text-white">Dashboard</h1>
        <p className="mt-1 text-sm text-slate-400">Welcome back. Here's what's happening.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 gap-3 md:grid-cols-3">
        <StatCard label="Pending checks" value={pendingCount} accent="amber" />
        <StatCard label="Earnings balance" value={availableBalance} accent="emerald" />
        <StatCard label="Recent threads" value={threads.length} accent="violet" />
      </div>

      {/* Recent threads */}
      {threads.length === 0 ? (
        <EmptyState title="No recent activity" body="Start from leads or gigs." />
      ) : (
        <GlassCard className="p-5">
          <h2 className="mb-4 text-sm font-semibold uppercase tracking-widest text-slate-500">Recent Threads</h2>
          <div className="space-y-3">
            {threads.map((thread: any) => (
              <div key={thread.id ?? thread.thread_id} className="flex items-center justify-between rounded-xl border border-white/[0.06] bg-white/[0.03] px-4 py-3">
                <div>
                  <p className="text-sm font-medium text-white">{thread.subject ?? thread.title ?? "Thread"}</p>
                  <p className="text-xs text-slate-500">{thread.last_message_at ? new Date(thread.last_message_at).toLocaleDateString() : "—"}</p>
                </div>
                <div className="h-2 w-2 rounded-full bg-violet-400" />
              </div>
            ))}
          </div>
        </GlassCard>
      )}
    </div>
  );
}
