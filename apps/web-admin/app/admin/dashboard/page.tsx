"use client";

import { useMutation, useQuery } from "@tanstack/react-query";
import { getMetricsSummary } from "@/api/routes/adminOps";
import { listNotificationLogs } from "@/api/routes/adminNotifications";
import { purgeSearch, rebuildSearch } from "@/api/routes/adminSearchOps";
import { PageHeader } from "@/components/layout/PageHeader";
import { SectionCard } from "@/components/layout/SectionCard";
import { Button } from "@/components/forms/Button";
import { Skeleton } from "@/components/feedback/Skeleton";
import { ErrorState } from "@/components/feedback/ErrorState";
import { ConfirmDialog } from "@/components/overlays/ConfirmDialog";
import { useState } from "react";
import { queryKeys } from "@/core/queryKeys";
import { trackEvent } from "@/api/routes/analytics";

export default function DashboardPage() {
  const [confirmPurge, setConfirmPurge] = useState(false);
  const metrics = useQuery({ queryKey: queryKeys.admin.metricsSummary, queryFn: getMetricsSummary });
  const logs = useQuery({
    queryKey: queryKeys.admin.notificationsLogs({ top: 10 }),
    queryFn: () => listNotificationLogs({ page: 1, pageSize: 10 })
  });

  useQuery({
    queryKey: ["admin-dashboard-viewed"],
    queryFn: async () => trackEvent({ name: "admin_dashboard_viewed" }),
    staleTime: Infinity
  });

  const rebuild = useMutation({ mutationFn: () => rebuildSearch() });
  const purge = useMutation({ mutationFn: () => purgeSearch() });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Dashboard"
        subtitle="Operational summary and quick actions"
        actions={
          <>
            <Button onClick={() => rebuild.mutate()} loading={rebuild.isPending}>
              Rebuild Search
            </Button>
            <Button variant="danger" onClick={() => setConfirmPurge(true)}>
              Purge Search
            </Button>
          </>
        }
      />

      {metrics.isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 6 }).map((_, idx) => (
            <Skeleton className="h-32" key={idx} />
          ))}
        </div>
      ) : metrics.isError ? (
        <ErrorState message={(metrics.error as any)?.message} onRetry={() => metrics.refetch()} />
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {Object.entries((metrics.data as Record<string, unknown>) || {}).slice(0, 12).map(([key, value]) => (
            <SectionCard key={key} className="p-5">
              <div className="text-xs uppercase tracking-wide text-textSecondary">{key.replaceAll("_", " ")}</div>
              <div className="mt-2 text-2xl font-semibold">{String(value)}</div>
            </SectionCard>
          ))}
        </div>
      )}

      <SectionCard>
        <h3 className="mb-3 text-base font-semibold">Recent Notifications</h3>
        {logs.isLoading ? (
          <Skeleton className="h-24 w-full" />
        ) : logs.isError ? (
          <ErrorState message={(logs.error as any)?.message} onRetry={() => logs.refetch()} />
        ) : (
          <ul className="space-y-2 text-sm">
            {(logs.data?.items || []).map((item: any, idx: number) => (
              <li key={idx} className="rounded-xl border border-borderSubtle bg-surface2 p-3">
                {item.type || item.id || "Notification"}
              </li>
            ))}
          </ul>
        )}
      </SectionCard>

      <ConfirmDialog
        open={confirmPurge}
        title="Purge search index"
        description="This is destructive and should only be used for incidents. Continue?"
        onCancel={() => setConfirmPurge(false)}
        onConfirm={() => {
          purge.mutate();
          setConfirmPurge(false);
        }}
        confirmLabel="Purge"
        danger
        loading={purge.isPending}
      />
    </div>
  );
}
