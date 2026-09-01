"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { listRiskUsers, getRiskUser, clearRiskUserAction, setRiskUserScore, listRiskRules, updateRiskRule } from "@/api/routes/adminRisk";
import { PageHeader } from "@/components/layout/PageHeader";
import { ListPage } from "@/components/shared/ListPage";
import { Button } from "@/components/forms/Button";
import { Drawer } from "@/components/overlays/Drawer";
import { CodeBlock } from "@/components/data/CodeBlock";
import { Modal } from "@/components/overlays/Modal";
import { Input } from "@/components/forms/Input";

export default function RiskPage() {
  const queryClient = useQueryClient();
  const [userId, setUserId] = useState<string | null>(null);
  const [ruleId, setRuleId] = useState<string | null>(null);
  const [ruleBody, setRuleBody] = useState("{}");

  const userDetail = useQuery({ queryKey: ["admin", "risk-user", userId], queryFn: () => getRiskUser(userId || ""), enabled: !!userId });
  const rules = useQuery({ queryKey: ["admin", "risk-rules"], queryFn: listRiskRules });
  const clearMutation = useMutation({ mutationFn: (id: string) => clearRiskUserAction(id), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "risk-users"] }) });
  const scoreMutation = useMutation({ mutationFn: ({ id, score }: { id: string; score: number }) => setRiskUserScore(id, { score }), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "risk-users"] }) });
  const updateRuleMutation = useMutation({ mutationFn: () => updateRiskRule(ruleId || "", JSON.parse(ruleBody || "{}")), onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "risk-rules"] }) });

  return (
    <div className="space-y-4">
      <PageHeader title="Risk" subtitle="Risk users and rules." />
      <ListPage
        queryKey={["admin", "risk-users"]}
        queryFn={listRiskUsers}
        columns={[
          { key: "user", title: "User", render: (r: any) => String(r.user_id || r.id || "-") },
          { key: "score", title: "Score", render: (r: any) => String(r.score ?? "-") },
          {
            key: "actions",
            title: "Actions",
            render: (r: any) => {
              const id = String(r.user_id || r.id);
              return (
                <div className="flex gap-2" onClick={(e) => e.stopPropagation()}>
                  <Button variant="secondary" onClick={() => clearMutation.mutate(id)}>Clear Action</Button>
                  <Button onClick={() => scoreMutation.mutate({ id, score: Number(r.score || 0) + 1 })}>+1 Score</Button>
                </div>
              );
            }
          }
        ]}
        onRowClick={(row: any) => setUserId(String(row.user_id || row.id))}
      />
      <Drawer open={!!userId} onClose={() => setUserId(null)} title={`Risk user ${userId || ""}`}>
        <CodeBlock value={userDetail.data || {}} />
      </Drawer>
      <div className="rounded-2xl border border-borderSubtle bg-surface p-6">
        <h3 className="mb-3 font-semibold">Risk rules</h3>
        <CodeBlock value={rules.data || {}} />
        <div className="mt-3 flex gap-2">
          <Input placeholder="Rule ID" value={ruleId || ""} onChange={(e) => setRuleId(e.target.value)} />
          <Input placeholder='{"enabled":false}' value={ruleBody} onChange={(e) => setRuleBody(e.target.value)} />
          <Button onClick={() => updateRuleMutation.mutate()}>Update Rule</Button>
        </div>
      </div>
    </div>
  );
}
