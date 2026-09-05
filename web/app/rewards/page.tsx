"use client";

import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { clientApi } from "@/lib/api/clientApi";
import { Flag } from "@/lib/flags/provider";

export default function RewardsPage() {
  const { accessToken } = useAuth();
  const balQ = useQuery({ queryKey: ["client", "rewards", "balance"], queryFn: () => clientApi.rewardsBalance(accessToken), enabled: !!accessToken });
  const ledgerQ = useQuery({ queryKey: ["client", "rewards", "ledger"], queryFn: () => clientApi.rewardsLedger({ limit: 50 }, accessToken), enabled: !!accessToken });

  return (
    <Flag name="rewards_enabled" fallback={<Card>Rewards module is disabled.</Card>}>
      {balQ.isLoading || ledgerQ.isLoading ? (
        <Skeleton className="h-24" />
      ) : !balQ.data?.ok || !ledgerQ.data?.ok ? (
        <EmptyState title="Rewards unavailable" />
      ) : (
        <div className="space-y-3">
          <h1 className="text-xl font-semibold">Rewards</h1>
          <Card><pre className="overflow-auto text-xs">{JSON.stringify(balQ.data.data, null, 2)}</pre></Card>
          <Card><pre className="overflow-auto text-xs">{JSON.stringify(ledgerQ.data.data, null, 2)}</pre></Card>
        </div>
      )}
    </Flag>
  );
}
