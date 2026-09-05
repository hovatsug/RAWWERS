"use client";

import { useMutation, useQuery } from "@tanstack/react-query";
import {
  adjustRewards,
  getRewardsConsentPolicies,
  updateRewardsConsentPolicies,
  getRewardsRules,
  executeRewardsRule,
  getShareThresholds,
  updateShareThresholds,
  getShareGrants,
  getShareFraudSettings,
  updateShareFraudSettings
} from "@/api/routes/adminRewards";
import { PageHeader } from "@/components/layout/PageHeader";
import { SectionCard } from "@/components/layout/SectionCard";
import { Input } from "@/components/forms/Input";
import { Button } from "@/components/forms/Button";
import { JsonEditorCard } from "@/components/shared/JsonEditorCard";
import { CodeBlock } from "@/components/data/CodeBlock";
import { useState } from "react";

export default function RewardsPage() {
  const [userId, setUserId] = useState("");
  const [amount, setAmount] = useState("0");
  const [code, setCode] = useState("");

  const consentPolicies = useQuery({ queryKey: ["admin", "rewards-consent-policies"], queryFn: getRewardsConsentPolicies });
  const rules = useQuery({ queryKey: ["admin", "rewards-rules"], queryFn: getRewardsRules });
  const thresholds = useQuery({ queryKey: ["admin", "share-thresholds"], queryFn: getShareThresholds });
  const grants = useQuery({ queryKey: ["admin", "share-grants"], queryFn: getShareGrants });
  const fraudSettings = useQuery({ queryKey: ["admin", "share-fraud-settings"], queryFn: getShareFraudSettings });

  const adjust = useMutation({ mutationFn: () => adjustRewards({ user_id: userId, amount: Number(amount) }) });
  const runRule = useMutation({ mutationFn: () => executeRewardsRule(code) });

  return (
    <div className="space-y-4">
      <PageHeader title="Rewards" subtitle="Reward adjustments, policies and anti-fraud settings." />
      <SectionCard>
        <h3 className="mb-3 font-semibold">Adjust Rewards</h3>
        <div className="flex flex-wrap gap-2">
          <Input placeholder="User ID" value={userId} onChange={(e) => setUserId(e.target.value)} />
          <Input placeholder="Amount" value={amount} onChange={(e) => setAmount(e.target.value)} />
          <Button onClick={() => adjust.mutate()}>Apply</Button>
        </div>
      </SectionCard>
      <SectionCard>
        <h3 className="mb-3 font-semibold">Rules</h3>
        <div className="mb-3 flex gap-2">
          <Input placeholder="Rule code" value={code} onChange={(e) => setCode(e.target.value)} />
          <Button onClick={() => runRule.mutate()}>Run Rule</Button>
        </div>
        <CodeBlock value={rules.data || {}} />
      </SectionCard>
      <JsonEditorCard title="Consent Policies" value={consentPolicies.data || {}} onSave={updateRewardsConsentPolicies} />
      <JsonEditorCard title="Share Thresholds" value={thresholds.data || {}} onSave={updateShareThresholds} />
      <SectionCard>
        <h3 className="mb-3 font-semibold">Share Grants</h3>
        <CodeBlock value={grants.data || {}} />
      </SectionCard>
      <JsonEditorCard title="Fraud Settings" value={fraudSettings.data || {}} onSave={updateShareFraudSettings} />
    </div>
  );
}
