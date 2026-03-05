"use client";

import { useParams } from "next/navigation";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { getAdminUser, banAdminUser, updateAdminUserRoles } from "@/api/routes/adminUsers";
import { getRiskUser } from "@/api/routes/adminRisk";
import { getRolloutOverride, updateRolloutOverride } from "@/api/routes/adminRollout";
import { getFinancePro } from "@/api/routes/adminPayouts";
import { PageHeader } from "@/components/layout/PageHeader";
import { SectionCard } from "@/components/layout/SectionCard";
import { CodeBlock } from "@/components/data/CodeBlock";
import { Button } from "@/components/forms/Button";
import { Input } from "@/components/forms/Input";
import { useState } from "react";
import { recordAndTrackAdminAction } from "@/core/audit/audit";
import { CopyIdButton } from "@/components/shared/CopyIdButton";

export default function UserDetailPage() {
  const params = useParams<{ userId: string }>();
  const userId = params.userId;
  const queryClient = useQueryClient();
  const [rolesText, setRolesText] = useState("");
  const [overrideText, setOverrideText] = useState("{}");

  const userQuery = useQuery({ queryKey: ["admin", "users", userId], queryFn: () => getAdminUser(userId) });
  const riskQuery = useQuery({ queryKey: ["admin", "risk-user", userId], queryFn: () => getRiskUser(userId) });
  const overrideQuery = useQuery({ queryKey: ["admin", "rollout-override", userId], queryFn: () => getRolloutOverride(userId) });
  const financeQuery = useQuery({ queryKey: ["admin", "finance-pro", userId], queryFn: () => getFinancePro(userId) });

  const banMutation = useMutation({
    mutationFn: () => banAdminUser(userId),
    onSuccess: async () => {
      await recordAndTrackAdminAction({ action: "users.ban", entityType: "user", entityId: userId });
      queryClient.invalidateQueries({ queryKey: ["admin", "users", userId] });
    }
  });
  const rolesMutation = useMutation({
    mutationFn: () => updateAdminUserRoles(userId, rolesText.split(",").map((x) => x.trim()).filter(Boolean)),
    onSuccess: async () => {
      await recordAndTrackAdminAction({ action: "users.roles", entityType: "user", entityId: userId });
      queryClient.invalidateQueries({ queryKey: ["admin", "users", userId] });
    }
  });
  const overrideMutation = useMutation({
    mutationFn: () => updateRolloutOverride(userId, JSON.parse(overrideText || "{}")),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "rollout-override", userId] })
  });

  const user = userQuery.data as any;

  return (
    <div className="space-y-4">
      <PageHeader title={`User ${userId}`} subtitle="Identity, risk, rollout and finance context" />
      <SectionCard>
        <div className="flex items-center gap-3">
          <div className="text-sm text-textSecondary">ID: {userId}</div>
          <CopyIdButton value={userId} />
        </div>
        <div className="mt-4 grid gap-3 md:grid-cols-2">
          <div>
            <div className="text-xs text-textSecondary">Email</div>
            <div>{user?.email || "-"}</div>
          </div>
          <div>
            <div className="text-xs text-textSecondary">Roles</div>
            <div>{(user?.roles || []).join(", ") || "-"}</div>
          </div>
        </div>
        <div className="mt-4 flex flex-wrap gap-2">
          <Button variant="danger" onClick={() => banMutation.mutate()} loading={banMutation.isPending}>Ban/Unban</Button>
          <Input className="max-w-sm" placeholder="admin,ops" value={rolesText} onChange={(e) => setRolesText(e.target.value)} />
          <Button onClick={() => rolesMutation.mutate()} loading={rolesMutation.isPending}>Update Roles</Button>
        </div>
      </SectionCard>
      <SectionCard>
        <h3 className="mb-3 font-semibold">Risk profile</h3>
        <CodeBlock value={riskQuery.data || {}} />
      </SectionCard>
      <SectionCard>
        <h3 className="mb-3 font-semibold">Rollout override</h3>
        <Input value={overrideText} onChange={(e) => setOverrideText(e.target.value)} />
        <div className="mt-3">
          <Button onClick={() => overrideMutation.mutate()} loading={overrideMutation.isPending}>Save override</Button>
        </div>
        <div className="mt-4"><CodeBlock value={overrideQuery.data || {}} /></div>
      </SectionCard>
      <SectionCard>
        <h3 className="mb-3 font-semibold">Finance pro detail</h3>
        <CodeBlock value={financeQuery.data || {}} />
      </SectionCard>
    </div>
  );
}
