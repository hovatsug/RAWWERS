"use client";

import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { clientApi } from "@/lib/api/clientApi";

export default function RewardsPage() {
  const { accessToken } = useAuth();
  const balQ = useQuery({ queryKey: ["client", "rewards", "balance"], queryFn: () => clientApi.rewardsBalance(accessToken), enabled: !!accessToken });
  const ledgerQ = useQuery({ queryKey: ["client", "rewards", "ledger"], queryFn: () => clientApi.rewardsLedger({ limit: 50 }, accessToken), enabled: !!accessToken });

  if (balQ.isLoading || ledgerQ.isLoading) return <Skeleton className="h-24" />;
  if (!balQ.data?.ok || !ledgerQ.data?.ok) return <EmptyState title="Rewards unavailable" />;

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Rewards</h1>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(balQ.data.data, null, 2)}</pre></Card>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(ledgerQ.data.data, null, 2)}</pre></Card>
    </div>
  );
}
