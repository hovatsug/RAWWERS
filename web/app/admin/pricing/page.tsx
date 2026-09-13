"use client";

import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Button, Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { admin, type PriceCapRow } from "@/lib/api/admin";

/**
 * The ceiling on what a photographer may charge per photo, by tier and niche.
 *
 * A grid rather than a form per cell, because the numbers only make sense
 * against each other: a cap is judged by whether it rises sensibly across
 * tiers and sits correctly relative to neighbouring niches. Reading them one
 * at a time hides exactly the mistakes worth catching.
 *
 * Two things the layout is trying to make obvious:
 *
 *   - Master is uncapped in every niche. An empty cell is that, not a missing
 *     value, so it says "uncapped" rather than showing a blank that reads as
 *     unset.
 *   - A cap that does not rise with tier is almost certainly a typo. Those
 *     cells are flagged rather than silently saved, because the mechanism
 *     spent months enforcing nothing and a wrong number would be just as
 *     invisible.
 */

const TIERS = ["rookie", "skilled", "pro", "elite", "master"] as const;
type Tier = (typeof TIERS)[number];

type Draft = Record<string, string>;

const cellKey = (niche: string, tier: Tier) => `${niche}:${tier}`;

export default function AdminPricingCapsPage() {
  const queryClient = useQueryClient();
  const [draft, setDraft] = useState<Draft>({});
  const [note, setNote] = useState<string | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["admin", "price-caps"],
    queryFn: () => admin.priceCaps()
  });

  const rows: PriceCapRow[] = data?.ok ? data.data : [];

  const byCell = useMemo(() => {
    const map = new Map<string, PriceCapRow>();
    rows.forEach((row) => map.set(cellKey(row.niche_slug, row.tier), row));
    return map;
  }, [rows]);

  const niches = useMemo(
    () => Array.from(new Set(rows.map((row) => row.niche_slug))).sort(),
    [rows]
  );

  // Seed the draft from the server once, so an edit shows what is stored
  // rather than an empty box the admin has to remember the old value for.
  useEffect(() => {
    if (rows.length === 0) return;
    const next: Draft = {};
    rows.forEach((row) => {
      next[cellKey(row.niche_slug, row.tier)] = row.entry_price_max ?? "";
    });
    setDraft(next);
  }, [rows]);

  const save = useMutation({
    mutationFn: async () => {
      const items = niches.flatMap((niche) =>
        TIERS.map((tier) => {
          const row = byCell.get(cellKey(niche, tier));
          const value = (draft[cellKey(niche, tier)] ?? "").trim();
          return {
            niche_slug: niche,
            tier,
            entry_price_min: row?.entry_price_min ?? "0.00",
            // An empty box means uncapped, which is a real setting rather
            // than a missing one. Sending "" would be a parse error; null is
            // the value the enforcement already understands.
            entry_price_max: value === "" ? null : value,
            currency: row?.currency ?? "EUR"
          };
        })
      );
      return admin.savePriceCaps(items);
    },
    onSuccess: (res) => {
      setNote(res.ok ? "Saved." : res.error.message);
      queryClient.invalidateQueries({ queryKey: ["admin", "price-caps"] });
    }
  });

  /** Cells whose cap does not rise with the tier below it. */
  const suspicious = useMemo(() => {
    const flagged = new Set<string>();
    niches.forEach((niche) => {
      let previous: number | null = null;
      TIERS.forEach((tier) => {
        const raw = (draft[cellKey(niche, tier)] ?? "").trim();
        if (raw === "") return; // uncapped, nothing to compare
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

  if (isLoading) return <Skeleton className="h-64 w-full" />;

  if (!data?.ok) {
    return (
      <Card>
        <p className="text-sm">Could not load the price caps.</p>
        <p className="mt-1 text-xs text-neutral-500">{data && !data.ok ? data.error.message : ""}</p>
      </Card>
    );
  }

  if (rows.length === 0) {
    return (
      <EmptyState
        title="No caps configured"
        body="Every tier is currently uncapped, so a rookie can charge master rates. Seed the caps to switch enforcement on."
      />
    );
  }

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-lg font-semibold">Entry price caps</h1>
        <p className="mt-1 text-sm text-neutral-500">
          The most a photographer may charge <strong>per photo</strong> in each niche, by the tier
          they hold in that niche. Leave a cell empty for uncapped.
        </p>
      </div>

      <Card>
        <div className="overflow-x-auto">
          <table className="w-full border-collapse text-sm">
            <thead>
              <tr>
                <th className="px-3 py-2 text-left font-medium">Niche</th>
                {TIERS.map((tier) => (
                  <th key={tier} className="px-3 py-2 text-left font-medium capitalize">
                    {tier}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {niches.map((niche) => (
                <tr key={niche} className="border-t border-neutral-200">
                  <td className="px-3 py-2 font-medium">{niche.replace(/_/g, " ")}</td>
                  {TIERS.map((tier) => {
                    const key = cellKey(niche, tier);
                    const value = draft[key] ?? "";
                    const flagged = suspicious.has(key);
                    return (
                      <td key={tier} className="px-3 py-2">
                        <input
                          aria-label={`${niche} ${tier} cap`}
                          value={value}
                          inputMode="decimal"
                          placeholder="uncapped"
                          onChange={(event) =>
                            setDraft((current) => ({ ...current, [key]: event.target.value }))
                          }
                          className={`w-24 rounded border px-2 py-1 tabular-nums ${
                            flagged ? "border-amber-500 bg-amber-50" : "border-neutral-300"
                          }`}
                        />
                      </td>
                    );
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      {suspicious.size > 0 && (
        <p className="text-sm text-amber-700">
          {suspicious.size} cap{suspicious.size === 1 ? "" : "s"} do not rise with tier. That is
          usually a typo — a higher tier priced below a lower one means promotion costs a
          photographer money. Saving is still allowed if it is deliberate.
        </p>
      )}

      <div className="flex items-center gap-3">
        <Button onClick={() => save.mutate()} disabled={save.isPending}>
          {save.isPending ? "Saving…" : "Save all caps"}
        </Button>
        {note && <span className="text-sm text-neutral-600">{note}</span>}
      </div>
    </div>
  );
}
