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
 *
 * Credit is per currency (MULTI_CURRENCY.md decision M3): credit earned on a
 * booking in pounds is in pounds and pays only for bookings in pounds, and
 * each currency has its own monthly budget. Nothing is converted.
 */
const CURRENCIES = ["GBP", "EUR"] as const;
export default function AdminClientCreditPage() {
  const queryClient = useQueryClient();
  const [currency, setCurrency] = useState<(typeof CURRENCIES)[number]>("GBP");
  const budget = useQuery({ queryKey: ["admin", "marketing-budget", currency], queryFn: () => admin.marketingBudget(currency) });
  const settings = useQuery({ queryKey: ["admin", "client-credit-settings"], queryFn: () => admin.clientCreditSettings() });
  const [cap, setCap] = useState("");
  const [monthly, setMonthly] = useState("");
  const [monthlyGbp, setMonthlyGbp] = useState("");
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  useEffect(() => {
    if (settings.data?.ok) {
      setCap(String(settings.data.data.max_discount_percent));
      setMonthly(settings.data.data.monthly_marketing_credit_budget_eur);
      setMonthlyGbp(settings.data.data.monthly_marketing_credit_budget_gbp);
    }
  }, [settings.data]);
  const b = budget.data?.ok ? budget.data.data : null;

  return (
    <>
      <PageHeader
        title="Client credit"
        description="Marketing credit this month, per currency, and the rules for using it."
        actions={
          <>
            {CURRENCIES.map((code) => (
              <AdminButton key={code} tone={code === currency ? "primary" : "secondary"} onClick={() => setCurrency(code)}>
                {code}
              </AdminButton>
            ))}
          </>
        }
      />
      <div className="space-y-4">
        {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
        {b ? (
          <Panel className="grid gap-4 p-4 sm:grid-cols-6">
            {[
              ["Budget", b.budget],
              ["Awarded", b.awarded],
              ["Used at checkout", b.used],
              ["Returned on refunds", b.returned_on_refunds],
              ["Outstanding", b.outstanding],
              ["Remaining", b.remaining]
            ].map(([label, value]) => (
              <div key={label}>
                <div className="text-xs uppercase text-slate-400">{label}</div>
                <div className="text-xl tabular-nums">{money(value, b.currency)}</div>
              </div>
            ))}
            <p className="text-xs text-slate-400 sm:col-span-6">{b.month}, Europe/London. Outstanding is every client&apos;s unspent credit, whenever earned.</p>
          </Panel>
        ) : budget.data && !budget.data.ok ? (
          <Notice tone="error">{budget.data.error.message}</Notice>
        ) : null}
        <Panel className="max-w-xl space-y-3 p-4">
          <div>
            <FieldLabel htmlFor="monthly-gbp">Monthly marketing credit budget in pounds (GBP, 0 awards none)</FieldLabel>
            <TextField id="monthly-gbp" inputMode="decimal" value={monthlyGbp} onChange={(e) => setMonthlyGbp(e.target.value.replace(/[^0-9.]/g, ""))} />
          </div>
          <div>
            <FieldLabel htmlFor="monthly">Monthly marketing credit budget in euros (EUR, 0 awards none)</FieldLabel>
            <TextField id="monthly" inputMode="decimal" value={monthly} onChange={(e) => setMonthly(e.target.value.replace(/[^0-9.]/g, ""))} />
          </div>
          <div>
            <FieldLabel htmlFor="cap">Most credit may take off a booking&apos;s payment (%)</FieldLabel>
            <TextField id="cap" inputMode="numeric" value={cap} onChange={(e) => setCap(e.target.value.replace(/[^0-9]/g, ""))} />
          </div>
          <AdminButton
            disabled={cap === "" || monthly === "" || monthlyGbp === ""}
            onClick={async () => {
              const res = await admin.saveClientCreditSettings({
                max_discount_percent: Number(cap),
                monthly_marketing_credit_budget_eur: monthly,
                monthly_marketing_credit_budget_gbp: monthlyGbp
              });
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
