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
 *   - Every active niche has a row, whether or not it has caps yet. The grid
 *     used to list only niches that already had one, so on an empty table -
 *     a new database - it listed nothing and nothing could be entered.
 *   - An empty cell is uncapped, not a missing value, so it says so.
 *   - A cap that does not rise with tier is almost certainly a typo. Those
 *     cells are flagged rather than silently saved.
 *
 * Saving shows exactly which caps change, from what to what, before anything
 * is sent, and sends only those. "Import CSV" fills the grid from a file and
 * goes through the same review; "Download CSV" writes the same columns, so
 * caps can be moved from one database to another.
 */

const TIERS = ["rookie", "skilled", "pro", "elite", "master"] as const;
type Tier = (typeof TIERS)[number];
type Draft = Record<string, string>;

const cellKey = (niche: string, tier: Tier) => `${niche}:${tier}`;
const shown = (value: string | null | undefined) => (value === null || value === undefined || value === "" ? "uncapped" : value);
const PRICE = /^\d+(\.\d{1,2})?$/;

export default function AdminPricingCapsPage() {
  const queryClient = useQueryClient();
  const [draft, setDraft] = useState<Draft>({});
  const [confirming, setConfirming] = useState(false);
  const [saved, setSaved] = useState(false);
  const [importing, setImporting] = useState(false);
  const [imported, setImported] = useState<string | null>(null);

  const query = useQuery({ queryKey: ["admin", "price-caps"], queryFn: () => admin.priceCaps() });
  const nicheQuery = useQuery({ queryKey: ["admin", "niches"], queryFn: () => admin.niches() });
  const rows: PriceCapRow[] = useMemo(() => (query.data?.ok ? query.data.data : []), [query.data]);

  const byCell = useMemo(() => {
    const map = new Map<string, PriceCapRow>();
    rows.forEach((row) => map.set(cellKey(row.niche_slug, row.tier), row));
    return map;
  }, [rows]);

  // Every active niche, plus any inactive one that still has caps on record.
  const niches = useMemo(() => {
    const names = new Map<string, string>();
    if (nicheQuery.data?.ok && Array.isArray(nicheQuery.data.data)) {
      nicheQuery.data.data.filter((n) => n.is_active).forEach((n) => names.set(n.slug, n.name));
    }
    rows.forEach((row) => names.has(row.niche_slug) || names.set(row.niche_slug, row.niche_slug.replace(/_/g, " ")));
    return Array.from(names, ([slug, name]) => ({ slug, name })).sort((a, b) => a.name.localeCompare(b.name));
  }, [nicheQuery.data, rows]);

  // Seed the draft from the server, so an edit shows what is stored rather
  // than an empty box the admin has to remember the old value for.
  useEffect(() => {
    const next: Draft = {};
    rows.forEach((row) => {
      next[cellKey(row.niche_slug, row.tier)] = row.entry_price_max ?? "";
    });
    setDraft(next);
  }, [rows]);

  /** Cells whose cap does not rise with the tier below it, or is not a price. */
  const suspicious = useMemo(() => {
    const flagged = new Set<string>();
    niches.forEach(({ slug }) => {
      let previous: number | null = null;
      TIERS.forEach((tier) => {
        const raw = (draft[cellKey(slug, tier)] ?? "").trim();
        if (raw === "") return;
        if (!PRICE.test(raw)) {
          flagged.add(cellKey(slug, tier));
          return;
        }
        const value = Number(raw);
        if (previous !== null && value < previous) flagged.add(cellKey(slug, tier));
        previous = value;
      });
    });
    return flagged;
  }, [draft, niches]);

  const changes = useMemo(
    () =>
      niches.flatMap(({ slug, name }) =>
        TIERS.flatMap((tier) => {
          const before = byCell.get(cellKey(slug, tier))?.entry_price_max ?? "";
          const after = (draft[cellKey(slug, tier)] ?? "").trim();
          // An empty cell with no row is already uncapped: not a change.
          return before === after ? [] : [{ slug, name, tier, before, after, flagged: suspicious.has(cellKey(slug, tier)) }];
        })
      ),
    [niches, byCell, draft, suspicious]
  );
  const invalid = changes.filter((c) => c.after !== "" && !PRICE.test(c.after));

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
        <>
          <AdminButton tone="secondary" disabled={rows.length === 0} onClick={() => downloadCsv(rows)}>
            Download CSV
          </AdminButton>
          <AdminButton tone="secondary" onClick={() => setImporting((open) => !open)}>
            Import CSV…
          </AdminButton>
          <AdminButton disabled={changes.length === 0 || invalid.length > 0} onClick={() => setConfirming(true)}>
            {changes.length === 0 ? "No changes" : `Review ${changes.length} change${changes.length === 1 ? "" : "s"}…`}
          </AdminButton>
        </>
      }
    />
  );

  if (query.isLoading || nicheQuery.isLoading) {
    return (
      <>
        {header}
        <div className="h-64 animate-pulse rounded-xl bg-white/[0.04]" />
      </>
    );
  }
  const failure = !query.data?.ok ? query.data : !nicheQuery.data?.ok ? nicheQuery.data : null;
  if (!query.data?.ok || !nicheQuery.data?.ok) {
    return (
      <>
        {header}
        <Panel className="p-6 text-center">
          <p className="text-sm text-slate-200">Could not load the price caps.</p>
          <p className="mt-1 text-xs text-slate-500">{failure && !failure.ok ? failure.error.message : "Check that the API is reachable."}</p>
          <AdminButton
            tone="secondary"
            className="mt-3"
            onClick={() => {
              query.refetch();
              nicheQuery.refetch();
            }}
          >
            Try again
          </AdminButton>
        </Panel>
      </>
    );
  }

  return (
    <>
      {header}
      {rows.length === 0 ? (
        <div className="mb-4">
          <Notice tone="warning">
            No caps are set, so no price is limited: a rookie can charge master rates. Fill in the grid or import a CSV.
          </Notice>
        </div>
      ) : null}
      {saved ? (
        <div className="mb-4">
          <Notice tone="success">Saved.</Notice>
        </div>
      ) : null}
      {imported ? (
        <div className="mb-4">
          <Notice tone="success">{imported}</Notice>
        </div>
      ) : null}

      {importing ? (
        <ImportPanel
          niches={niches.map((n) => n.slug)}
          onClose={() => setImporting(false)}
          onLoad={(values) => {
            setDraft((current) => ({ ...current, ...values }));
            setSaved(false);
            setImporting(false);
            setImported(
              `Loaded ${Object.keys(values).length} cap${Object.keys(values).length === 1 ? "" : "s"} from the file. Nothing is saved yet: review the changes below.`
            );
          }}
        />
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
              {niches.map(({ slug, name }) => (
                <tr key={slug} className="border-b border-white/[0.06] last:border-0">
                  <td className="px-4 py-2 font-medium text-slate-100">{name}</td>
                  {TIERS.map((tier) => {
                    const key = cellKey(slug, tier);
                    const flagged = suspicious.has(key);
                    const changed = (byCell.get(key)?.entry_price_max ?? "") !== (draft[key] ?? "").trim();
                    return (
                      <td key={tier} className="px-4 py-2">
                        <input
                          aria-label={`${slug} ${tier} cap`}
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

      {invalid.length > 0 ? (
        <div className="mt-4">
          <Notice tone="error">
            {invalid.map((c) => `${c.name} · ${c.tier}`).join(", ")}: not a price. Use a number like 4 or 4.50, or leave the cell empty for
            uncapped.
          </Notice>
        </div>
      ) : suspicious.size > 0 ? (
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
          // Only what changed: sending every cell would turn each untouched
          // empty cell on a new database into a row, and log it as a decision.
          const items = changes.map(({ slug, tier, after }) => {
            const row = byCell.get(cellKey(slug, tier));
            return {
              niche_slug: slug,
              tier,
              entry_price_min: row?.entry_price_min ?? "0.00",
              // An empty box means uncapped, which is a real setting; null
              // is the value the enforcement already understands.
              entry_price_max: after === "" ? null : after,
              currency: row?.currency ?? "EUR"
            };
          });
          const res = await admin.savePriceCaps(items);
          if (!res.ok) return res.error.message;
          setSaved(true);
          setImported(null);
          queryClient.invalidateQueries({ queryKey: ["admin", "price-caps"] });
          return null;
        }}
      >
        <p>Every photographer in these niches and tiers is held to the new caps from now on.</p>
        <ul className="max-h-60 space-y-1 overflow-y-auto rounded-lg border border-white/10 p-3 text-xs">
          {changes.map((c) => (
            <li key={`${c.slug}:${c.tier}`} className="flex justify-between gap-3 tabular-nums">
              <span className="text-slate-300">
                {c.name} · {c.tier}
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

/**
 * Reads a CSV into the grid. Writes nothing: the loaded caps go through the
 * same review as typed ones. A file with any bad line loads none of it, and
 * says which lines - half a file in the grid is worse than none.
 */
function ImportPanel({
  niches,
  onClose,
  onLoad
}: {
  niches: string[];
  onClose: () => void;
  onLoad: (values: Draft) => void;
}) {
  const [text, setText] = useState("");
  const [errors, setErrors] = useState<string[]>([]);

  const load = () => {
    const result = parseCaps(text, new Set(niches));
    setErrors(result.errors);
    if (result.errors.length === 0) onLoad(result.values);
  };

  return (
    <Panel className="mb-4 space-y-3 p-4">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-sm font-medium text-slate-100">Import a CSV</p>
          <p className="text-xs text-slate-500">
            Columns: <code>niche_slug</code>, <code>tier</code>, <code>entry_price_max</code> (empty for uncapped). The same columns
            &ldquo;Download CSV&rdquo; writes. Caps not in the file are left as they are.
          </p>
        </div>
        <AdminButton tone="quiet" onClick={onClose}>
          Close
        </AdminButton>
      </div>
      <input
        type="file"
        accept=".csv,text/csv"
        aria-label="CSV file"
        className="block text-xs text-slate-400 file:mr-3 file:rounded-md file:border-0 file:bg-white/[0.08] file:px-3 file:py-1.5 file:text-slate-200"
        onChange={async (event) => {
          const file = event.target.files?.[0];
          if (file) setText(await file.text());
          setErrors([]);
        }}
      />
      <textarea
        aria-label="Or paste it"
        rows={4}
        value={text}
        placeholder={"niche_slug,tier,entry_price_max\nweddings,rookie,3.00"}
        onChange={(event) => {
          setText(event.target.value);
          setErrors([]);
        }}
        className="w-full resize-y rounded-lg border border-white/15 bg-[#0D0D1A] px-3 py-2 font-mono text-xs text-slate-100 placeholder:text-slate-500 focus:outline-none"
      />
      <AdminButton tone="secondary" disabled={text.trim() === ""} onClick={load}>
        Load into the grid
      </AdminButton>
      {errors.length ? (
        <Notice tone="error">
          Nothing was loaded. Fix these and try again:
          <ul className="mt-1 space-y-0.5">
            {errors.map((error) => (
              <li key={error}>{error}</li>
            ))}
          </ul>
        </Notice>
      ) : null}
    </Panel>
  );
}

function parseCaps(text: string, niches: Set<string>): { values: Draft; errors: string[] } {
  const lines = text.replace(/^﻿/, "").split(/\r?\n/);
  const header = (lines[0] ?? "").split(",").map((h) => h.trim().toLowerCase());
  const col = (name: string) => header.indexOf(name);
  if (col("niche_slug") < 0 || col("tier") < 0 || col("entry_price_max") < 0) {
    return { values: {}, errors: ["The first line must be the header: niche_slug,tier,entry_price_max"] };
  }
  const values: Draft = {};
  const errors: string[] = [];
  const seen = new Map<string, number>();
  lines.slice(1).forEach((line, index) => {
    const number = index + 2;
    if (line.trim() === "") return;
    const cells = line.split(",").map((c) => c.trim());
    const slug = cells[col("niche_slug")] ?? "";
    const tier = (cells[col("tier")] ?? "").toLowerCase();
    const price = cells[col("entry_price_max")] ?? "";
    if (!niches.has(slug)) return errors.push(`Line ${number}: no active niche "${slug}"`);
    if (!(TIERS as readonly string[]).includes(tier)) return errors.push(`Line ${number}: "${tier}" is not a tier`);
    if (price !== "" && !PRICE.test(price)) return errors.push(`Line ${number}: "${price}" is not a price`);
    const key = cellKey(slug, tier as Tier);
    if (seen.has(key)) return errors.push(`Line ${number}: ${slug} · ${tier} is already on line ${seen.get(key)}`);
    seen.set(key, number);
    values[key] = price;
  });
  if (errors.length === 0 && Object.keys(values).length === 0) errors.push("The file has no caps in it");
  return { values, errors };
}

function downloadCsv(rows: PriceCapRow[]) {
  const sorted = [...rows].sort(
    (a, b) => a.niche_slug.localeCompare(b.niche_slug) || TIERS.indexOf(a.tier as Tier) - TIERS.indexOf(b.tier as Tier)
  );
  const lines = ["niche_slug,tier,entry_price_max", ...sorted.map((row) => `${row.niche_slug},${row.tier},${row.entry_price_max ?? ""}`)];
  const blob = new Blob([lines.join("\n") + "\n"], { type: "text/csv" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "price-caps.csv";
  link.click();
  URL.revokeObjectURL(url);
}
