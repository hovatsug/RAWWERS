"use client";

import { useMemo, useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { BottomSheet, Button, Card, EmptyState, Input, Skeleton, Textarea } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { proApi } from "@/lib/api/proApi";

export default function ProWalletPage() {
  const { accessToken } = useAuth();
  const [accountJson, setAccountJson] = useState("{}");
  const [requestJson, setRequestJson] = useState('{"amount": 0}');
  const [confirmOpen, setConfirmOpen] = useState(false);

  const balanceQ = useQuery({ queryKey: ["pro", "wallet", "balance"], queryFn: () => proApi.getEarningsBalance(accessToken), enabled: !!accessToken });
  const ledgerQ = useQuery({ queryKey: ["pro", "wallet", "ledger"], queryFn: () => proApi.getEarningsLedger({ limit: 50 }, accessToken), enabled: !!accessToken });
  const payoutsQ = useQuery({ queryKey: ["pro", "wallet", "payouts"], queryFn: () => proApi.getPayouts({ limit: 50 }, accessToken), enabled: !!accessToken });
  const accountQ = useQuery({ queryKey: ["pro", "wallet", "account"], queryFn: () => proApi.getPayoutAccount(accessToken), enabled: !!accessToken });

  const saveAccount = useMutation({
    mutationFn: async () => {
      const payload = JSON.parse(accountJson) as Record<string, unknown>;
      return proApi.putPayoutAccount(payload, accessToken);
    },
    onSuccess: async () => {
      await accountQ.refetch();
      await proApi.track("pro_profile_updated", { source: "web", section: "payout_account" }, accessToken);
    },
  });

  const requestPayout = useMutation({
    mutationFn: async () => {
      const payload = JSON.parse(requestJson) as Record<string, unknown>;
      return proApi.requestPayout(payload, accessToken);
    },
    onSuccess: async () => {
      await payoutsQ.refetch();
      await balanceQ.refetch();
      await proApi.track("pro_payout_requested", { source: "web" }, accessToken);
    },
  });

  const loading = balanceQ.isLoading || ledgerQ.isLoading || payoutsQ.isLoading || accountQ.isLoading;
  const failed = balanceQ.isError || ledgerQ.isError || payoutsQ.isError || accountQ.isError;

  const canRequestPayout = useMemo(() => {
    const checks = (accountQ.data?.ok ? accountQ.data.data : {}) as Record<string, unknown>;
    return Boolean(checks && Object.keys(checks).length > 0);
  }, [accountQ.data]);

  if (!accessToken) return <EmptyState title="Sign in required" body="Please login as a pro." />;
  if (loading) return <div className="space-y-2"><Skeleton className="h-24" /><Skeleton className="h-24" /><Skeleton className="h-24" /></div>;
  if (failed) return <EmptyState title="Wallet unavailable" body="Refresh to retry." />;

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Wallet & Payouts</h1>

      <div className="grid grid-cols-1 gap-3 md:grid-cols-3">
        <Card>
          <p className="text-xs uppercase text-neutral-500">Balance</p>
          <p className="mt-1 text-2xl font-semibold">{String(balanceQ.data?.ok ? (balanceQ.data.data as any).available_balance ?? (balanceQ.data.data as any).available ?? "-" : "-")}</p>
        </Card>
        <Card>
          <p className="text-xs uppercase text-neutral-500">Ledger entries</p>
          <p className="mt-1 text-2xl font-semibold">{String(ledgerQ.data?.ok ? ((ledgerQ.data.data as any).items || []).length : 0)}</p>
        </Card>
        <Card>
          <p className="text-xs uppercase text-neutral-500">Payout requests</p>
          <p className="mt-1 text-2xl font-semibold">{String(payoutsQ.data?.ok ? ((payoutsQ.data.data as any).items || []).length : 0)}</p>
        </Card>
      </div>

      <Card className="space-y-2">
        <p className="text-sm font-medium">Payout account</p>
        <Textarea rows={7} value={accountJson} onChange={(e) => setAccountJson(e.target.value)} placeholder={JSON.stringify(accountQ.data?.ok ? accountQ.data.data : {}, null, 2)} />
        <Button disabled={saveAccount.isPending} onClick={() => saveAccount.mutate()}>{saveAccount.isPending ? "Saving..." : "Save payout account"}</Button>
      </Card>

      <Card className="space-y-2">
        <p className="text-sm font-medium">Request payout</p>
        <Input value={requestJson} onChange={(e) => setRequestJson(e.target.value)} />
        <Button disabled={!canRequestPayout || requestPayout.isPending} onClick={() => setConfirmOpen(true)}>
          {requestPayout.isPending ? "Requesting..." : "Request payout"}
        </Button>
        {!canRequestPayout ? <p className="text-xs text-red-600">Set payout account before requesting payout.</p> : null}
      </Card>

      <BottomSheet open={confirmOpen} title="Confirm payout request" onClose={() => setConfirmOpen(false)}>
        <p className="mb-3 text-sm">This action affects money movement. Continue?</p>
        <Button
          disabled={requestPayout.isPending}
          onClick={async () => {
            await requestPayout.mutateAsync();
            setConfirmOpen(false);
          }}
        >
          {requestPayout.isPending ? "Submitting..." : "Confirm"}
        </Button>
      </BottomSheet>
    </div>
  );
}
