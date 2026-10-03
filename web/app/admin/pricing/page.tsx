"use client";

import { useEffect, useMemo, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type PriceCapRow } from "@/lib/api/admin";
import { cn } from "@/lib/utils";
import { AdminButton, ConfirmDialog, Notice, PageHeader, Panel } from "@/app/admin/_components/ui";

/**
 * The ceiling on what a photographer may charge per photo, by tier and niche.
 *
 * A grid rather than a form per cell, because the numbers only make sense
 * against each other: a cap is judged by whether it rises sensibly across
 * tiers and sits correctly relative to neighbouring niches. Reading them one
 * at a time hides exactly the mistakes worth catching.
 *
 *   - Master is uncapped in every niche. An empty cell is that, not a missing
 *     value, so it says "uncapped" rather than showing a blank that reads as
 *     unset.
 *   - A cap that does not rise with tier is almost certainly a typo. Those
 *     cells are flagged rather than silently saved.
 *
 * Saving shows exactly which caps change, from what to what, before anything
 * is sent - every photographer in those niches and tiers is held to them.
 */

const TIERS = ["rookie", "skilled", "pro", "elite", "master"] as const;
type Tier = (typeof TIERS)[number];
type Draft = Record<string, string>;

const cellKey = (niche: string, tier: Tier) => `${niche}:${tier}`;
const shown = (value: string | null | undefined) => (value === null || value === undefined || value === "" ? "uncapped" : value);

export default function AdminPricingCapsPage() {
  const queryClient = useQueryClient();
  const [draft, setDraft] = useState<Draft>({});
  const [confirming, setConfirming] = useState(false);
  const [saved, setSaved] = useState(false);

  const query = useQuery({ queryKey: ["admin", "price-caps"], queryFn: () => admin.priceCaps() });
  const rows: PriceCapRow[] = useMemo(() => (query.data?.ok ? query.data.data : []), [query.data]);

  const byCell = useMemo(() => {
    const map = new Map<string, PriceCapRow>();
    rows.forEach((row) => map.set(cellKey(row.niche_slug, row.tier), row));
    return map;
  }, [rows]);
  const niches = useMemo(() => Array.from(new Set(rows.map((row) => row.niche_slug))).sort(), [rows]);

  // Seed the draft from the server, so an edit shows what is stored rather
  // than an empty box the admin has to remember the old value for.
  useEffect(() => {
    const next: Draft = {};
    rows.forEach((row) => {
      next[cellKey(row.niche_slug, row.tier)] = row.entry_price_max ?? "";
    });
    setDraft(next);
  }, [rows]);

  /** Cells whose cap does not rise with the tier below it. */
  const suspicious = useMemo(() => {
    const flagged = new Set<string>();
    niches.forEach((niche) => {
      let previous: number | null = null;
      TIERS.forEach((tier) => {
        const raw = (draft[cellKey(niche, tier)] ?? "").trim();
        if (raw === "") return;
        const value = Number(raw);
        if (!Number.isFinite(value)) {
          flagged.add(cellKey(niche, tier));
          return;
        }
        if (previous !== null && value < previous) flagged.add(cellKey(niche, tier));
        previous = value;
      });
    });
    return flagged;
  }, [draft, niches]);

  const changes = useMemo(
    () =>
      niches.flatMap((niche) =>
        TIERS.flatMap((tier) => {
          const before = byCell.get(cellKey(niche, tier))?.entry_price_max ?? "";
          const after = (draft[cellKey(niche, tier)] ?? "").trim();
          return before === after ? [] : [{ niche, tier, before, after, flagged: suspicious.has(cellKey(niche, tier)) }];
        })
      ),
    [niches, byCell, draft, suspicious]
  );

  const header = (
    <PageHeader
      title="Entry price caps"
      description={
        <>
          The most a photographer may charge <strong className="text-slate-200">per photo</strong> in each niche, by the tier they
          hold in that niche. Leave a cell empty for uncapped.
        </>
      }
      actions={
        <AdminButton disabled={changes.length === 0} onClick={() => setConfirming(true)}>
          {changes.length === 0 ? "No changes" : `Review ${changes.length} change${changes.length === 1 ? "" : "s"}…`}
        </AdminButton>
      }
    />
  );

  if (query.isLoading) {
    return (
      <>
        {header}
        <div className="h-64 animate-pulse rounded-xl bg-white/[0.04]" />
      </>
    );
  }
  if (!query.data?.ok) {
    return (
      <>
        {header}
        <Panel className="p-6 text-center">
          <p className="text-sm text-slate-200">Could not load the price caps.</p>
          <p className="mt-1 text-xs text-slate-500">{query.data && !query.data.ok ? query.data.error.message : "Check that the API is reachable."}</p>
          <AdminButton tone="secondary" className="mt-3" onClick={() => query.refetch()}>
            Try again
          </AdminButton>
        </Panel>
      </>
    );
  }
  if (rows.length === 0) {
    return (
      <>
        {header}
        <Panel className="p-8 text-center">
          <p className="text-sm font-medium text-slate-200">No caps configured</p>
          <p className="mt-1 text-sm text-slate-500">
            Every tier is currently uncapped, so a rookie can charge master rates. Seed the caps to switch enforcement on.
          </p>
        </Panel>
      </>
    );
  }

  return (
    <>
      {header}
      {saved ? (
        <div className="mb-4">
          <Notice tone="success">Saved.</Notice>
        </div>
      ) : null}

      <Panel className="overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full border-collapse text-sm">
            <thead>
              <tr className="border-b border-white/10 text-left">
                <th scope="col" className="px-4 py-2.5 text-xs font-medium uppercase tracking-wide text-slate-500">
                  Niche
                </th>
                {TIERS.map((tier) => (
                  <th key={tier} scope="col" className="px-4 py-2.5 text-xs font-medium uppercase tracking-wide text-slate-500">
                    {tier}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {niches.map((niche) => (
                <tr key={niche} className="border-b border-white/[0.06] last:border-0">
                  <td className="px-4 py-2 font-medium capitalize text-slate-100">{niche.replace(/_/g, " ")}</td>
                  {TIERS.map((tier) => {
                    const key = cellKey(niche, tier);
                    const flagged = suspicious.has(key);
                    const changed = (byCell.get(key)?.entry_price_max ?? "") !== (draft[key] ?? "").trim();
                    return (
                      <td key={tier} className="px-4 py-2">
                        <input
                          aria-label={`${niche} ${tier} cap`}
                          value={draft[key] ?? ""}
                          inputMode="decimal"
                          placeholder="uncapped"
                          onChange={(event) => {
                            setSaved(false);
                            setDraft((current) => ({ ...current, [key]: event.target.value }));
                          }}
                          className={cn(
                            "w-24 rounded-md border bg-[#0D0D1A] px-2 py-1 tabular-nums text-slate-100 placeholder:text-slate-600 focus:outline-none focus:ring-2 focus:ring-violet-500/30",
                            flagged ? "border-amber-500/70" : changed ? "border-violet-400/70" : "border-white/15"
                          )}
                        />
                      </td>
                    );
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Panel>

      {suspicious.size > 0 ? (
        <div className="mt-4">
          <Notice tone="warning">
            {suspicious.size} cap{suspicious.size === 1 ? "" : "s"} do not rise with tier. That is usually a typo — a higher tier
            priced below a lower one means promotion costs a photographer money. Saving is still allowed if it is deliberate.
          </Notice>
        </div>
      ) : null}

      <ConfirmDialog
        open={confirming}
        title={`Save ${changes.length} price cap change${changes.length === 1 ? "" : "s"}?`}
        confirmLabel="Save caps"
        onClose={() => setConfirming(false)}
        onConfirm={async () => {
          const items = niches.flatMap((niche) =>
            TIERS.map((tier) => {
              const row = byCell.get(cellKey(niche, tier));
              const value = (draft[cellKey(niche, tier)] ?? "").trim();
              return {
                niche_slug: niche,
                tier,
                entry_price_min: row?.entry_price_min ?? "0.00",
                // An empty box means uncapped, which is a real setting; null
                // is the value the enforcement already understands.
                entry_price_max: value === "" ? null : value,
                currency: row?.currency ?? "EUR"
              };
            })
          );
          const res = await admin.savePriceCaps(items);
          if (!res.ok) return res.error.message;
          setSaved(true);
          queryClient.invalidateQueries({ queryKey: ["admin", "price-caps"] });
          return null;
        }}
      >
        <p>Every photographer in these niches and tiers is held to the new caps from now on.</p>
        <ul className="max-h-60 space-y-1 overflow-y-auto rounded-lg border border-white/10 p-3 text-xs">
          {changes.map((c) => (
            <li key={`${c.niche}:${c.tier}`} className="flex justify-between gap-3 tabular-nums">
              <span className="capitalize text-slate-300">
                {c.niche.replace(/_/g, " ")} · {c.tier}
              </span>
              <span className={c.flagged ? "text-amber-300" : "text-slate-100"}>
                {shown(c.before)} → {shown(c.after)}
                {c.flagged ? " (does not rise with tier)" : ""}
              </span>
            </li>
          ))}
        </ul>
      </ConfirmDialog>
    </>
  );
}
