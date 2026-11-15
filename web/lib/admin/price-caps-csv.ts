/**
 * The price caps CSV the admin's caps grid imports and downloads, one file
 * per currency (docs/PRICE_CAPS.md; the files production is loaded from are
 * api/data/price_caps/price-caps-<CURRENCY>.csv).
 *
 * Columns: niche_slug, tier, entry_price_max (empty for uncapped), and
 * optionally currency. When the file names a currency, every line must name
 * the grid's: a pound file is never loaded into the euro grid, where its
 * numbers would be read as euros. Files without the column (from before)
 * still load into the grid on screen.
 */

export const TIERS = ["rookie", "skilled", "pro", "elite", "master"] as const;
export type Tier = (typeof TIERS)[number];
export type Draft = Record<string, string>;

export const cellKey = (niche: string, tier: Tier) => `${niche}:${tier}`;
export const PRICE = /^\d+(\.\d{1,2})?$/;

export const CSV_HEADER = "niche_slug,tier,entry_price_max,currency";

export function parseCaps(text: string, niches: Set<string>, currency: string): { values: Draft; errors: string[] } {
  const lines = text.replace(/^﻿/, "").split(/\r?\n/);
  const header = (lines[0] ?? "").split(",").map((h) => h.trim().toLowerCase());
  const col = (name: string) => header.indexOf(name);
  if (col("niche_slug") < 0 || col("tier") < 0 || col("entry_price_max") < 0) {
    return { values: {}, errors: [`The first line must be the header: ${CSV_HEADER} (currency optional)`] };
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
    if (col("currency") >= 0) {
      const lineCurrency = (cells[col("currency")] ?? "").toUpperCase();
      if (lineCurrency !== currency) {
        return errors.push(`Line ${number}: a ${lineCurrency || "no"} currency cap; this grid is ${currency}. Switch to ${lineCurrency || "the file's currency"} first.`);
      }
    }
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

/** The grid's caps as a file the import reads back, with its currency. */
export function capsCsv(rows: { niche_slug: string; tier: string; entry_price_max: string | null }[], currency: string): string {
  const sorted = [...rows].sort(
    (a, b) => a.niche_slug.localeCompare(b.niche_slug) || TIERS.indexOf(a.tier as Tier) - TIERS.indexOf(b.tier as Tier)
  );
  return [CSV_HEADER, ...sorted.map((row) => `${row.niche_slug},${row.tier},${row.entry_price_max ?? ""},${currency}`)].join("\n") + "\n";
}
