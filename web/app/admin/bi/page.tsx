"use client";

import Link from "next/link";
import { Suspense, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { adminBi, type BiGroup, type BiOverview, type BiOwed } from "@/lib/api/admin";
import { DataTable, Notice, PageHeader, Panel } from "@/app/admin/_components/ui";
import { cn } from "@/lib/utils";
import { BarList, COLOURS, Honest, PeriodBar, Section, SeriesBars, Waterfall, drillHref, eur, eurShort, percent, useBiParams } from "./_parts";

/**
 * The business dashboard (docs/BI.md is the source of every definition).
 * Correct before pretty: a number that cannot be computed says why; an
 * average over fewer than 30 items says "low sample"; a waterfall that does
 * not add up and a reconciliation that does not match are shown, not
 * hidden. Clicking a bar or a row opens the bookings behind it.
 */
export default function BusinessDashboardPage() {
  return (
    <Suspense fallback={<PageHeader title="Business" description="Loading…" />}>
      <Dashboard />
    </Suspense>
  );
}

function Dashboard() {
  const { current, qs, set } = useBiParams();
  const overview = useQuery({ queryKey: ["admin", "bi", "overview", qs], queryFn: () => adminBi.overview(qs) });
  const niches = useQuery({ queryKey: ["admin", "bi", "breakdown", "niche", qs], queryFn: () => adminBi.breakdown("niche", qs) });
  const countries = useQuery({ queryKey: ["admin", "bi", "breakdown", "country", qs], queryFn: () => adminBi.breakdown("country", qs) });
  const tiers = useQuery({ queryKey: ["admin", "bi", "breakdown", "tier", qs], queryFn: () => adminBi.breakdown("tier", qs) });
  const keys = (q: typeof niches) => (q.data?.ok ? q.data.data.items.map((i) => i.key) : []);
  const o = overview.data?.ok ? overview.data.data : null;

  return (
    <>
      <PageHeader
        title="Business"
        description="What the business makes, where it comes from, what it costs, and how much cash is really ours. Amounts in EUR; days in Europe/London."
        actions={
          <Link href={"/admin/bi/costs" as never} className="text-sm text-violet-300 hover:text-violet-200">
            Costs and company cash →
          </Link>
        }
      />
      <PeriodBar current={current} set={set} options={{ niches: keys(niches), countries: keys(countries), tiers: keys(tiers) }} />
      {overview.data && !overview.data.ok ? <Notice tone="error">{overview.data.error.message}</Notice> : null}
      {o ? (
        <>
          <Warnings o={o} />
          <Section id="overview" title="Overview" description={`${o.period.from} to ${o.period.to}, against ${o.previous.from} to ${o.previous.to}.`}>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
              {o.kpis.map((k) => (
                <Panel key={k.key} className="p-3">
                  <div className="text-xs uppercase tracking-wide text-slate-400">{k.label}</div>
                  <div className={cn("mt-1 text-xl tabular-nums", k.value === null ? "text-slate-500" : "text-slate-50")}>
                    {k.key === "bookings" ? (k.value ?? "no data") : eur(k.value)}
                  </div>
                  <div className="mt-0.5 text-xs text-slate-400">
                    {k.value === null ? (
                      k.reason
                    ) : k.change_bp === null ? (
                      "no previous period to compare"
                    ) : (
                      <span>
                        {percent(k.change_bp, true)} vs {k.key === "bookings" ? k.previous : eur(k.previous)}
                      </span>
                    )}
                  </div>
                </Panel>
              ))}
              <LiquidCard />
            </div>
          </Section>
          <Section
            id="waterfall"
            title="From GMV to operating profit"
            description="Each step comes from the definitions; the running total is checked at the retained fee, contribution profit and operating profit."
          >
            <Panel className="p-4">
              {!o.waterfall.adds_up
                ? o.waterfall.mismatches.map((m) => (
                    <Notice key={m.at} tone="error">
                      Does not add up at {m.at.replace(/_/g, " ")}: the steps give {eur(m.running_cents)}, the total is {eur(m.reported_cents)} (difference{" "}
                      {eur(m.difference_cents)}).
                    </Notice>
                  ))
                : null}
              {o.waterfall.incomplete ? <Notice tone="warning">Stops early: {o.waterfall.incomplete}.</Notice> : null}
              <Waterfall steps={o.waterfall.steps} />
            </Panel>
          </Section>
        </>
      ) : overview.isLoading ? (
        <p className="text-sm text-slate-400">Loading…</p>
      ) : null}
      <SeriesSection current={current} qs={qs} />
      <Section id="breakdowns" title="Breakdowns" description="n is the number of bookings. Averages and take rates under 30 bookings show as low sample.">
        <div className="grid gap-4 md:grid-cols-2">
          <Breakdown title="By niche" by="niche" query={niches} current={current} />
          <Breakdown title="By country (photographer's)" by="country" query={countries} current={current} />
          <Breakdown title="By tier (today's)" by="tier" query={tiers} current={current} />
          <TopPhotographers current={current} qs={qs} />
        </div>
      </Section>
      <Reconciliation current={current} qs={qs} />
      <OwedSection />
    </>
  );
}

function Warnings({ o }: { o: BiOverview }) {
  const notes: string[] = [];
  if (o.period.stripe_unsynced_days) notes.push(`${o.period.stripe_unsynced_days} day(s) have no Stripe data yet: Stripe fees and profit show "no data".`);
  if (o.period.other_currency_lines) notes.push(`${o.period.other_currency_lines} money line(s) in another currency are left out.`);
  if (o.period.other_currency_costs) notes.push(`${o.period.other_currency_costs} cost(s) in another currency are left out.`);
  if (o.period.shelf_cost_not_set_orders) notes.push(`${o.period.shelf_cost_not_set_orders} Shelf order(s) have no item cost: left out of the Shelf margin.`);
  if (!notes.length) return null;
  return (
    <div className="mb-5 space-y-2">
      {notes.map((n) => (
        <Notice key={n} tone="warning">
          {n}
        </Notice>
      ))}
    </div>
  );
}

function LiquidCard() {
  const owed = useQuery({ queryKey: ["admin", "bi", "owed"], queryFn: () => adminBi.owed() });
  const d = owed.data?.ok ? owed.data.data : null;
  return (
    <Panel className="p-3">
      <div className="text-xs uppercase tracking-wide text-slate-400">Liquid now</div>
      <div className={cn("mt-1 text-xl tabular-nums", d?.liquid.cents === null ? "text-slate-500" : "text-slate-50")}>
        {d ? eur(d.liquid.cents) : "…"}
      </div>
      <div className="mt-0.5 text-xs text-slate-400">{d?.liquid.reason || "cash held minus money owed, as of now"}</div>
    </Panel>
  );
}

function bucketEnd(start: string, grain: string): string {
  const d = new Date(`${start}T00:00:00Z`);
  if (grain === "week") d.setUTCDate(d.getUTCDate() + 6);
  if (grain === "month") {
    d.setUTCMonth(d.getUTCMonth() + 1);
    d.setUTCDate(0);
  }
  return d.toISOString().slice(0, 10);
}

function SeriesSection({ current, qs }: { current: Record<string, string>; qs: string }) {
  const [grain, setGrain] = useState("day");
  const series = useQuery({ queryKey: ["admin", "bi", "series", qs, grain], queryFn: () => adminBi.series(`${qs}&grain=${grain}`) });
  const items = series.data?.ok ? series.data.data.items : [];
  const href = (start: string) => drillHref(current, { period: "custom", start, end: bucketEnd(start, grain) });
  const charts: { title: string; colour: string; points: { start: string; value: number | null }[]; money: boolean }[] = [
    { title: "GMV", colour: COLOURS.inflow, points: items.map((p) => ({ start: p.start, value: p.gmv_cents })), money: true },
    { title: "Bookings", colour: COLOURS.line, points: items.map((p) => ({ start: p.start, value: p.bookings })), money: false },
    { title: "Retained fee", colour: COLOURS.total, points: items.map((p) => ({ start: p.start, value: p.retained_cents })), money: true },
    {
      title: "Contribution profit",
      colour: COLOURS.outflow,
      points: items.map((p) => ({ start: p.start, value: p.contribution_cents })),
      money: true
    }
  ];
  return (
    <Section id="series" title="Over time" description="Click a bar for its bookings. “?” is a bucket without Stripe data (or a filtered view, where Stripe fees are not split).">
      <div className="mb-3 flex gap-1" role="group" aria-label="Grain">
        {["day", "week", "month"].map((g) => (
          <button
            key={g}
            type="button"
            aria-pressed={grain === g}
            onClick={() => setGrain(g)}
            className={cn("rounded-md px-2.5 py-1 text-sm", grain === g ? "bg-white/[0.12] text-slate-50" : "text-slate-400 hover:bg-white/[0.05]")}
          >
            By {g}
          </button>
        ))}
      </div>
      <div className="grid gap-4 md:grid-cols-2">
        {charts.map((c) => (
          <Panel key={c.title} className="p-3">
            <div className="mb-2 text-sm text-slate-300">{c.title}</div>
            <SeriesBars points={c.points} value={c.title} colour={c.colour} href={href} format={c.money ? eurShort : (v) => String(v)} />
          </Panel>
        ))}
      </div>
    </Section>
  );
}

function groupExtra(row: BiGroup) {
  return (
    <>
      net {eur(row.net_gmv_cents)} · per booking <Honest value={row.avg_booking} format={(v) => eur(v)} /> · take rate{" "}
      <Honest value={row.take_rate_bp} format={(v) => percent(v)} />
    </>
  );
}

function Breakdown({
  title,
  by,
  query,
  current
}: {
  title: string;
  by: string;
  query: { data?: Awaited<ReturnType<typeof adminBi.breakdown>> };
  current: Record<string, string>;
}) {
  const items = query.data?.ok ? query.data.data.items : [];
  return (
    <Panel className="p-3">
      <div className="mb-2 text-sm text-slate-300">{title}</div>
      <BarList
        rows={items.map((r) => ({ key: r.key, label: r.label, cents: r.gmv_cents, n: r.n, extra: groupExtra(r) }))}
        href={(key) => drillHref(current, { [by]: key })}
      />
    </Panel>
  );
}

function TopPhotographers({ current, qs }: { current: Record<string, string>; qs: string }) {
  const query = useQuery({ queryKey: ["admin", "bi", "breakdown", "photographer", qs], queryFn: () => adminBi.breakdown("photographer", qs) });
  const items = query.data?.ok ? query.data.data.items : [];
  return (
    <Panel className="p-3">
      <div className="mb-2 text-sm text-slate-300">Top 10 photographers</div>
      <BarList
        rows={items.map((r) => ({ key: r.key, label: r.label, cents: r.gmv_cents, n: r.n, extra: groupExtra(r) }))}
        href={(key) => drillHref(current, { pro: key })}
      />
    </Panel>
  );
}

function Reconciliation({ current, qs }: { current: Record<string, string>; qs: string }) {
  const query = useQuery({ queryKey: ["admin", "bi", "reconciliation", qs], queryFn: () => adminBi.reconciliation(qs) });
  const r = query.data?.ok ? query.data.data : null;
  return (
    <Section id="reconciliation" title="Reconciliation with Stripe" description="Our totals against Stripe's balance transactions for the same period (not filtered by niche, country or tier).">
      {r && r.differences.length ? <Notice tone="error">Differences: {r.differences.join(", ")}. Look at each line below.</Notice> : null}
      <div className="mt-2">
        <DataTable
          rows={r?.lines || []}
          rowKey={(row) => row.key}
          loading={query.isLoading}
          error={query.data && !query.data.ok ? query.data.error.message : null}
          empty={{ title: "No data" }}
          columns={[
            { header: "", cell: (row) => <span className="text-slate-200">{row.label}</span> },
            { header: "Ours", cell: (row) => <span className="tabular-nums">{eur(row.ours_cents, "—")}</span> },
            { header: "Stripe", cell: (row) => <span className="tabular-nums">{row.stripe_cents === null ? row.reason || "no data" : eur(row.stripe_cents)}</span> },
            {
              header: "Difference",
              cell: (row) =>
                row.difference_cents === null ? (
                  <span className="text-slate-500">—</span>
                ) : (
                  <span className={cn("tabular-nums", row.difference_cents !== 0 ? "font-semibold text-amber-300" : "text-emerald-300")}>
                    {row.difference_cents === 0 ? "matches" : eur(row.difference_cents)}
                  </span>
                )
            },
            { header: "Note", cell: (row) => <span className="text-xs text-slate-400">{row.note}</span> }
          ]}
        />
      </div>
      <p className="mt-2 text-xs text-slate-500">
        A difference names a day to look at: <Link href={drillHref(current, {}) as never} className="text-violet-300">the bookings in this period</Link>.
      </p>
    </Section>
  );
}

function OwedSection() {
  const query = useQuery({ queryKey: ["admin", "bi", "owed"], queryFn: () => adminBi.owed() });
  const d: BiOwed | null = query.data?.ok ? query.data.data : null;
  if (!d) return query.data && !query.data.ok ? <Notice tone="error">{query.data.error.message}</Notice> : null;
  const used = d.client_credit.budget_cents ? Math.round((d.client_credit.used_cents / d.client_credit.budget_cents) * 100) : null;
  const card = (label: string, value: string, note?: string) => (
    <div>
      <div className="text-xs uppercase text-slate-400">{label}</div>
      <div className="text-lg tabular-nums text-slate-50">{value}</div>
      {note ? <div className="text-xs text-slate-500">{note}</div> : null}
    </div>
  );
  return (
    <Section id="owed" title="Money owed and cash, now" description="Liquid = Stripe balance (available and pending) + company cash − photographer cash owed − money owed to clients. The RAWW liability is shown, not subtracted.">
      <div className="grid gap-4 md:grid-cols-2">
        <Panel className="grid grid-cols-2 gap-3 p-4">
          {card("Photographer cash in settlement", eur(d.photographers.in_settlement_cents), "the 7-day delay")}
          {card("Held", eur(d.photographers.held_cents), "disputes, reported problems, admin holds")}
          {card("Due", eur(d.photographers.due_cents), "settled, not yet paid")}
          {card("Paid out", eur(d.photographers.paid_out_cents))}
          {card("Owed to clients", eur(d.clients.owed_cents), d.clients.items.map((i) => `${i.kind.replace(/_/g, " ")} ×${i.n}`).join(", ") || "none")}
          {card("Owed back by photographers", eur(d.photographers.owed_back_by_photographers_cents), "refunds after payout")}
        </Panel>
        <Panel className="grid grid-cols-2 gap-3 p-4">
          {card("Stripe available", eur(d.stripe.available_cents), d.stripe.reason || undefined)}
          {card("Stripe pending", eur(d.stripe.pending_cents), "not yet available (balance timing)")}
          {card("Company cash", eur(d.company_cash.total_cents, "not set"), d.company_cash.accounts.map((a) => `${a.account} (${a.date})`).join(", ") || "add it under Costs and company cash")}
          {card("Liquid", eur(d.liquid.cents), d.liquid.reason || undefined)}
          {card(
            "RAWW outstanding (liability)",
            eur(d.raww.outstanding_cents),
            `${d.raww.outstanding_raww.toLocaleString("en-GB")} RAWW${d.raww.valued_at_current_rate_cents ? `, ${eur(d.raww.valued_at_current_rate_cents)} at today's rate` : ""}`
          )}
          {card(
            `Client credit, ${d.client_credit.month}`,
            `${eur(d.client_credit.used_cents)} used`,
            d.client_credit.budget_cents ? `of ${eur(d.client_credit.budget_cents)} budget (${used}%), ${eur(d.client_credit.awarded_cents)} awarded` : "no budget set"
          )}
        </Panel>
      </div>
    </Section>
  );
}
