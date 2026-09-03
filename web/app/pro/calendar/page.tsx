"use client";

import { useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Button, Card, EmptyState, Input, Skeleton, Textarea } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { pro as proApi } from "@/lib/api/pro";

export default function ProCalendarPage() {
  const { accessToken } = useAuth();
  const [slotsDate, setSlotsDate] = useState("");
  const [rulesJson, setRulesJson] = useState("{}");
  const [exceptionsJson, setExceptionsJson] = useState("{}");
  const [policyJson, setPolicyJson] = useState("{}");

  const rulesQ = useQuery({ queryKey: ["pro", "calendar", "rules"], queryFn: () => proApi.getAvailabilityRules(accessToken), enabled: !!accessToken });
  const exceptionsQ = useQuery({ queryKey: ["pro", "calendar", "exceptions"], queryFn: () => proApi.getSchedulingExceptions(accessToken), enabled: !!accessToken });
  const policyQ = useQuery({ queryKey: ["pro", "calendar", "policy"], queryFn: () => proApi.getSchedulingPolicy(accessToken), enabled: !!accessToken });
  const slotsQ = useQuery({
    queryKey: ["pro", "calendar", "slots", slotsDate],
    queryFn: () => proApi.getCandidateSlots(slotsDate ? { date: slotsDate } : {}, accessToken),
    enabled: !!accessToken,
  });

  const saveRules = useMutation({
    mutationFn: async () => {
      const payload = JSON.parse(rulesJson) as Record<string, unknown>;
      return proApi.putAvailabilityRules(payload, accessToken);
    },
    onSuccess: () => rulesQ.refetch(),
  });
  const saveExceptions = useMutation({
    mutationFn: async () => {
      const payload = JSON.parse(exceptionsJson) as Record<string, unknown>;
      return proApi.putSchedulingExceptions(payload, accessToken);
    },
    onSuccess: () => exceptionsQ.refetch(),
  });
  const savePolicy = useMutation({
    mutationFn: async () => {
      const payload = JSON.parse(policyJson) as Record<string, unknown>;
      return proApi.putSchedulingPolicy(payload, accessToken);
    },
    onSuccess: () => policyQ.refetch(),
  });

  if (!accessToken) return <EmptyState title="Sign in required" body="Please login as a pro." />;
  if (rulesQ.isLoading || exceptionsQ.isLoading || policyQ.isLoading) {
    return <div className="space-y-2"><Skeleton className="h-24" /><Skeleton className="h-24" /><Skeleton className="h-24" /></div>;
  }
  if (rulesQ.isError || exceptionsQ.isError || policyQ.isError) return <EmptyState title="Calendar unavailable" body="Refresh to retry." />;

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Calendar & Availability</h1>

      <Card className="space-y-2">
        <p className="text-sm font-medium">Availability rules</p>
        <Textarea rows={8} value={rulesJson} onChange={(e) => setRulesJson(e.target.value)} placeholder={JSON.stringify(rulesQ.data?.ok ? rulesQ.data.data : {}, null, 2)} />
        <Button disabled={saveRules.isPending} onClick={() => saveRules.mutate()}>{saveRules.isPending ? "Saving..." : "Save rules"}</Button>
      </Card>

      <Card className="space-y-2">
        <p className="text-sm font-medium">Scheduling exceptions</p>
        <Textarea rows={8} value={exceptionsJson} onChange={(e) => setExceptionsJson(e.target.value)} placeholder={JSON.stringify(exceptionsQ.data?.ok ? exceptionsQ.data.data : {}, null, 2)} />
        <Button disabled={saveExceptions.isPending} onClick={() => saveExceptions.mutate()}>{saveExceptions.isPending ? "Saving..." : "Save exceptions"}</Button>
      </Card>

      <Card className="space-y-2">
        <p className="text-sm font-medium">Scheduling policy</p>
        <Textarea rows={8} value={policyJson} onChange={(e) => setPolicyJson(e.target.value)} placeholder={JSON.stringify(policyQ.data?.ok ? policyQ.data.data : {}, null, 2)} />
        <Button disabled={savePolicy.isPending} onClick={() => savePolicy.mutate()}>{savePolicy.isPending ? "Saving..." : "Save policy"}</Button>
      </Card>

      <Card className="space-y-2">
        <p className="text-sm font-medium">Candidate slots</p>
        <Input type="date" value={slotsDate} onChange={(e) => setSlotsDate(e.target.value)} />
        {slotsQ.isLoading ? <Skeleton className="h-20" /> : null}
        {slotsQ.data?.ok ? <pre className="overflow-auto rounded bg-neutral-50 p-3 text-xs">{JSON.stringify(slotsQ.data.data, null, 2)}</pre> : null}
      </Card>
    </div>
  );
}
