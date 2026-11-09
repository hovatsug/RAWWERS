"use client";

import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useState, type ReactNode } from "react";
import { cn } from "@/lib/utils";
import { AdminButton, Panel, TextField } from "@/app/admin/_components/ui";
import type { BiHonest, BiWaterfallStep } from "@/lib/api/admin";

/**
 * The business dashboard's shared parts (docs/BI.md): the period and filter
 * bar (kept in the URL, so a view can be shared), money in integer cents,
 * the honest-numbers rule, and three small SVG charts. No chart library:
 * the admin had none, and these three shapes do not need one.
 *
 * Colours are Okabe-Ito (colour-blind safe), and every bar carries its
 * value as text, so colour is never the only signal.
 */

export const COLOURS = {
  inflow: "#56B4E9",
  outflow: "#E69F00",
  total: "#009E73",
  line: "#CC79A7",
  muted: "#64748b"
};

// ─── Money and numbers ─────────────────────────────────────────────────────

/** Integer cents to "€1,234.56". Integer arithmetic only; null is the fallback text. */
export function eur(cents: number | null | undefined, fallback = "no data"): string {
  if (cents === null || cents === undefined) return fallback;
  const sign = cents < 0 ? "−" : "";
  const abs = Math.abs(cents);
  const whole = Math.floor(abs / 100).toLocaleString("en-GB");
  return `${sign}€${whole}.${String(abs % 100).padStart(2, "0")}`;
}

/** Short form for chart labels: €1.2k. */
export function eurShort(cents: number): string {
  const euros = cents / 100;
  const abs = Math.abs(euros);
  const sign = euros < 0 ? "−" : "";
  if (abs >= 1_000_000) return `${sign}€${(abs / 1_000_000).toFixed(1)}m`;
  if (abs >= 1_000) return `${sign}€${(abs / 1_000).toFixed(1)}k`;
  return `${sign}€${abs.toFixed(0)}`;
}

/** Basis points to "+12.3%". */
export function percent(bp: number | null | undefined, signed = false): string {
  if (bp === null || bp === undefined) return "—";
  const sign = signed && bp > 0 ? "+" : bp < 0 ? "−" : "";
  return `${sign}${(Math.abs(bp) / 100).toFixed(1)}%`;
}

/** An average or a percentage, or "low sample (n=…)". */
export function Honest({ value, format }: { value: BiHonest; format: (v: number) => string }) {
  if (value.low_sample) return <span className="text-slate-500">low sample (n={value.n})</span>;
  if (value.value === null) return <span className="text-slate-500">no data</span>;
  return <span className="tabular-nums">{format(value.value)}</span>;
}

// ─── Period and filters, in the URL ────────────────────────────────────────

const PERIODS: [string, string][] = [
  ["today", "Today"],
  ["7d", "7 days"],
  ["30d", "30 days"],
  ["this_month", "This month"],
  ["last_month", "Last month"],
  ["custom", "Custom"]
];
export const PARAM_KEYS = ["period", "start", "end", "niche", "country", "tier", "pro"] as const;

export function useBiParams() {
  const params = useSearchParams();
  const router = useRouter();
  const pathname = usePathname();
  const current: Record<string, string> = {};
  PARAM_KEYS.forEach((key) => {
    const value = params.get(key);
    if (value) current[key] = value;
  });
  if (!current.period) current.period = "30d";
  const qs = new URLSearchParams(current).toString();
  const set = (changes: Record<string, string | null>) => {
    const next = new URLSearchParams(current);
    Object.entries(changes).forEach(([key, value]) => (value ? next.set(key, value) : next.delete(key)));
    if (next.get("period") !== "custom") {
      next.delete("start");
      next.delete("end");
    }
    router.replace(`${pathname}?${next.toString()}` as never, { scroll: false });
  };
  return { current, qs, set };
}

/** A link to the bookings behind a number, with the view's period and filters. */
export function drillHref(current: Record<string, string>, extra: Record<string, string>): string {
  const next = new URLSearchParams(current);
  Object.entries(extra).forEach(([key, value]) => next.set(key, value));
  return `/admin/bi/bookings?${next.toString()}`;
}

export function PeriodBar({
  current,
  set,
  options
}: {
  current: Record<string, string>;
  set: (changes: Record<string, string | null>) => void;
  options?: { niches: string[]; countries: string[]; tiers: string[] };
}) {
  const [start, setStart] = useState(current.start || "");
  const [end, setEnd] = useState(current.end || "");
  const filter = (key: "niche" | "country" | "tier", label: string, values: string[]) => (
    <label className="flex items-center gap-1.5 text-xs text-slate-400">
      {label}
      <select
        value={current[key] || ""}
        onChange={(e) => set({ [key]: e.target.value || null })}
        className="rounded-md border border-white/15 bg-[#0D0D1A] px-2 py-1 text-sm text-slate-100"
      >
        <option value="">All</option>
        {Array.from(new Set([...(current[key] ? [current[key]] : []), ...values])).map((v) => (
          <option key={v} value={v}>
            {v === "-" ? "not set" : v.replace(/_/g, " ")}
          </option>
        ))}
      </select>
    </label>
  );
  return (
    <Panel className="mb-5 flex flex-wrap items-center gap-3 p-3">
      <div className="flex flex-wrap gap-1" role="group" aria-label="Period">
        {PERIODS.map(([key, label]) => (
          <button
            key={key}
            type="button"
            aria-pressed={current.period === key}
            onClick={() => set({ period: key, ...(key === "custom" ? { start: start || null, end: end || null } : {}) })}
            className={cn(
              "rounded-md px-2.5 py-1 text-sm",
              current.period === key ? "bg-white/[0.12] text-slate-50" : "text-slate-400 hover:bg-white/[0.05]"
            )}
          >
            {label}
          </button>
        ))}
      </div>
      {current.period === "custom" ? (
        <div className="flex flex-wrap items-center gap-2">
          <TextField type="date" aria-label="From" value={start} onChange={(e) => setStart(e.target.value)} className="w-40" />
          <TextField type="date" aria-label="To" value={end} onChange={(e) => setEnd(e.target.value)} className="w-40" />
          <AdminButton tone="secondary" disabled={!start || !end} onClick={() => set({ period: "custom", start, end })}>
            Apply
          </AdminButton>
        </div>
      ) : null}
      {options ? (
        <div className="flex flex-wrap items-center gap-3">
          {filter("niche", "Niche", options.niches)}
          {filter("country", "Country", options.countries)}
          {filter("tier", "Tier", options.tiers)}
        </div>
      ) : null}
    </Panel>
  );
}

// ─── Sections ──────────────────────────────────────────────────────────────

export function Section({ id, title, description, children }: { id: string; title: string; description?: ReactNode; children: ReactNode }) {
  return (
    <section id={id} className="mb-8 scroll-mt-4">
      <h2 className="text-base font-semibold text-slate-100">{title}</h2>
      {description ? <p className="mb-3 mt-0.5 max-w-3xl text-sm text-slate-400">{description}</p> : <div className="mb-3" />}
      {children}
    </section>
  );
}

// ─── Charts ────────────────────────────────────────────────────────────────

/**
 * GMV down to operating profit. Each step floats from the running total;
 * totals stand on the axis. When the steps do not add up, the warning says
 * so above the chart, with both numbers: it is never smoothed over.
 */
export function Waterfall({ steps }: { steps: BiWaterfallStep[] }) {
  const bars: { label: string; from: number; to: number; kind: string; cents: number }[] = [];
  let running = 0;
  steps.forEach((step) => {
    if (step.kind === "step") {
      bars.push({ label: step.label, from: running, to: running + step.cents, kind: step.cents >= 0 ? "in" : "out", cents: step.cents });
      running += step.cents;
    } else {
      bars.push({ label: step.label, from: 0, to: step.cents, kind: "total", cents: step.cents });
      running = step.cents;
    }
  });
  const values = bars.flatMap((b) => [b.from, b.to, 0]);
  const max = Math.max(...values);
  const min = Math.min(...values);
  const span = max - min || 1;
  const width = 760;
  const rowH = 30;
  const labelW = 230;
  const valueW = 110;
  const plotW = width - labelW - valueW;
  const x = (v: number) => labelW + ((v - min) / span) * plotW;
  return (
    <div className="overflow-x-auto">
      <svg viewBox={`0 0 ${width} ${bars.length * rowH + 10}`} className="min-w-[560px]" role="img" aria-label="Waterfall from GMV to operating profit">
        <line x1={x(0)} x2={x(0)} y1={0} y2={bars.length * rowH} stroke={COLOURS.muted} strokeDasharray="2 3" />
        {bars.map((b, i) => {
          const left = x(Math.min(b.from, b.to));
          const w = Math.max(1, Math.abs(x(b.to) - x(b.from)));
          const colour = b.kind === "total" ? COLOURS.total : b.kind === "in" ? COLOURS.inflow : COLOURS.outflow;
          return (
            <g key={`${b.label}-${i}`} transform={`translate(0, ${i * rowH + 4})`}>
              <text x={0} y={17} fill="#cbd5e1" fontSize={12} fontWeight={b.kind === "total" ? 600 : 400}>
                {b.label}
              </text>
              <rect x={left} y={4} width={w} height={rowH - 12} rx={2} fill={colour} opacity={b.kind === "total" ? 0.95 : 0.8} />
              <text x={width - 4} y={17} fill="#e2e8f0" fontSize={12} textAnchor="end" className="tabular-nums">
                {b.kind === "step" && b.cents >= 0 ? "+" : ""}
                {eur(b.cents)}
              </text>
            </g>
          );
        })}
      </svg>
    </div>
  );
}

/** Vertical bars over time; each bar a link to its bookings. */
export function SeriesBars({
  points,
  value,
  format,
  href,
  colour = COLOURS.inflow
}: {
  points: { start: string; value: number | null }[];
  value?: string;
  format: (v: number) => string;
  href: (start: string) => string;
  colour?: string;
}) {
  const height = 180;
  const width = Math.max(320, points.length * 18);
  const vals = points.map((p) => p.value ?? 0);
  const max = Math.max(1, ...vals);
  const min = Math.min(0, ...vals);
  const span = max - min || 1;
  const bw = width / Math.max(points.length, 1);
  const y = (v: number) => 10 + ((max - v) / span) * (height - 30);
  return (
    <div className="overflow-x-auto">
      <svg viewBox={`0 0 ${width} ${height}`} className="min-w-[320px]" style={{ width: "100%", maxWidth: width * 2 }} role="img" aria-label={value}>
        <line x1={0} x2={width} y1={y(0)} y2={y(0)} stroke={COLOURS.muted} strokeWidth={0.5} />
        {points.map((p, i) => {
          if (p.value === null) {
            return (
              <text key={p.start} x={i * bw + bw / 2} y={y(0) - 4} fontSize={9} fill={COLOURS.muted} textAnchor="middle">
                ?
              </text>
            );
          }
          const top = Math.min(y(p.value), y(0));
          const h = Math.max(1, Math.abs(y(p.value) - y(0)));
          return (
            <a key={p.start} href={href(p.start)}>
              <title>{`${p.start}: ${format(p.value)}`}</title>
              <rect x={i * bw + 2} y={top} width={Math.max(2, bw - 4)} height={h} fill={colour} opacity={0.85} />
            </a>
          );
        })}
        <text x={0} y={height - 4} fontSize={10} fill="#94a3b8">
          {points[0]?.start}
        </text>
        <text x={width} y={height - 4} fontSize={10} fill="#94a3b8" textAnchor="end">
          {points[points.length - 1]?.start}
        </text>
        <text x={width} y={10} fontSize={10} fill="#94a3b8" textAnchor="end">
          max {format(max)}
        </text>
      </svg>
    </div>
  );
}

/** Horizontal bars, one per group, each with its n and a link to its bookings. */
export function BarList({
  rows,
  href
}: {
  rows: { key: string; label: string; cents: number; n: number; extra?: ReactNode }[];
  href: (key: string) => string;
}) {
  const max = Math.max(1, ...rows.map((r) => Math.abs(r.cents)));
  if (!rows.length) return <p className="text-sm text-slate-500">No data in this period.</p>;
  return (
    <ul className="space-y-1.5">
      {rows.map((r) => (
        <li key={r.key}>
          <Link href={href(r.key) as never} className="group block rounded-md px-1 py-1 hover:bg-white/[0.04]">
            <div className="flex items-baseline justify-between gap-2 text-sm">
              <span className="truncate text-slate-200">{r.label === "-" ? "not set" : r.label.replace(/_/g, " ")}</span>
              <span className="shrink-0 tabular-nums text-slate-100">
                {eur(r.cents)} <span className="text-xs text-slate-500">n={r.n}</span>
              </span>
            </div>
            <div className="mt-1 h-1.5 rounded bg-white/[0.06]">
              <div className="h-1.5 rounded" style={{ width: `${(Math.abs(r.cents) / max) * 100}%`, background: COLOURS.inflow }} />
            </div>
            {r.extra ? <div className="mt-1 text-xs text-slate-400">{r.extra}</div> : null}
          </Link>
        </li>
      ))}
    </ul>
  );
}
