"use client";

import { useEffect, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin } from "@/lib/api/admin";
import { AdminButton, FieldLabel, Notice, PageHeader, Panel, TextField, money } from "@/app/admin/_components/ui";

/**
 * Client credit is RAWWERS's marketing cost, out of the platform's retained
 * share (the photographer is paid on the price before credit). This month,
 * in Europe/London: the budget for marketing-permission awards, what was
 * awarded, what clients used at checkout, what is outstanding (every
 * client's unspent credit) and what remains. Admins are told at 80% and 100%.
 */
export default function AdminClientCreditPage() {
  const queryClient = useQueryClient();
  const budget = useQuery({ queryKey: ["admin", "marketing-budget"], queryFn: () => admin.marketingBudget() });
  const settings = useQuery({ queryKey: ["admin", "client-credit-settings"], queryFn: () => admin.clientCreditSettings() });
  const [cap, setCap] = useState("");
  const [monthly, setMonthly] = useState("");
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  useEffect(() => {
    if (settings.data?.ok) {
      setCap(String(settings.data.data.max_discount_percent));
      setMonthly(settings.data.data.monthly_marketing_credit_budget_eur);
    }
  }, [settings.data]);
  const b = budget.data?.ok ? budget.data.data : null;

  return (
    <>
      <PageHeader title="Client credit" description="Marketing credit this month, and the rules for using it." />
      <div className="space-y-4">
        {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
        {b ? (
          <Panel className="grid gap-4 p-4 sm:grid-cols-6">
            {[
              ["Budget", b.budget_eur],
              ["Awarded", b.awarded_eur],
              ["Used at checkout", b.used_eur],
              ["Returned on refunds", b.returned_on_refunds_eur],
              ["Outstanding", b.outstanding_eur],
              ["Remaining", b.remaining_eur]
            ].map(([label, value]) => (
              <div key={label}>
                <div className="text-xs uppercase text-slate-400">{label}</div>
                <div className="text-xl tabular-nums">{money(value, "EUR")}</div>
              </div>
            ))}
            <p className="text-xs text-slate-400 sm:col-span-6">{b.month}, Europe/London. Outstanding is every client&apos;s unspent credit, whenever earned.</p>
          </Panel>
        ) : budget.data && !budget.data.ok ? (
          <Notice tone="error">{budget.data.error.message}</Notice>
        ) : null}
        <Panel className="max-w-xl space-y-3 p-4">
          <div>
            <FieldLabel htmlFor="monthly">Monthly marketing credit budget (EUR, 0 awards none)</FieldLabel>
            <TextField id="monthly" inputMode="decimal" value={monthly} onChange={(e) => setMonthly(e.target.value.replace(/[^0-9.]/g, ""))} />
          </div>
          <div>
            <FieldLabel htmlFor="cap">Most credit may take off a booking&apos;s payment (%)</FieldLabel>
            <TextField id="cap" inputMode="numeric" value={cap} onChange={(e) => setCap(e.target.value.replace(/[^0-9]/g, ""))} />
          </div>
          <AdminButton
            disabled={cap === "" || monthly === ""}
            onClick={async () => {
              const res = await admin.saveClientCreditSettings({ max_discount_percent: Number(cap), monthly_marketing_credit_budget_eur: monthly });
              if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
              setMessage({ tone: "success", text: "Saved." });
              queryClient.invalidateQueries({ queryKey: ["admin", "marketing-budget"] });
            }}
          >
            Save
          </AdminButton>
        </Panel>
      </div>
    </>
  );
}
