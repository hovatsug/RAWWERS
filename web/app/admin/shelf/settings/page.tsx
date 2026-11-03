"use client";

import { useEffect, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type ShelfSettings } from "@/lib/api/admin";
import { AdminButton, FieldLabel, Notice, PageHeader, Panel, StatusBadge, TextArea, TextField } from "@/app/admin/_components/ui";

/**
 * The Shelf's settings. Every save is logged with the admin, the time and
 * what changed. The RAWWS value is stamped on each earning and order when
 * it is made, so a change here never rewrites RAWWS already earned or spent.
 *
 * In production The Shelf opens only with "Shelf on" AND approved terms:
 * the seeded terms are a draft placeholder until the lawyer's reviewed text
 * is pasted and approved here.
 */

const TIERS = ["rookie", "skilled", "pro", "elite", "master"];

type Form = {
  raww_eur_value: string;
  gbp_eur_rate: string;
  shelf_discount_percent: string;
  inactivity_months: string;
  warning_days: string;
  level_band_raww: string[];
  tier_max_level: Record<string, string>;
  wishlist_max: string;
  max_orders_per_month: string;
  same_item_cooldown_days: string;
  allowed_countries: string;
  shelf_enabled: boolean;
};

function toForm(s: ShelfSettings): Form {
  return {
    raww_eur_value: s.raww_eur_value,
    gbp_eur_rate: s.gbp_eur_rate,
    shelf_discount_percent: String(s.shelf_discount_percent),
    inactivity_months: String(s.inactivity_months),
    warning_days: String(s.warning_days),
    level_band_raww: s.level_band_raww.map(String),
    tier_max_level: Object.fromEntries(TIERS.map((t) => [t, String(s.tier_max_level[t] ?? "")])),
    wishlist_max: String(s.wishlist_max),
    max_orders_per_month: String(s.max_orders_per_month),
    same_item_cooldown_days: String(s.same_item_cooldown_days),
    allowed_countries: s.allowed_countries.join(", "),
    shelf_enabled: s.shelf_enabled
  };
}

function toBody(f: Form): Partial<ShelfSettings> {
  return {
    raww_eur_value: f.raww_eur_value.trim(),
    gbp_eur_rate: f.gbp_eur_rate.trim(),
    shelf_discount_percent: Number(f.shelf_discount_percent),
    inactivity_months: Number(f.inactivity_months),
    warning_days: Number(f.warning_days),
    level_band_raww: f.level_band_raww.map(Number),
    tier_max_level: Object.fromEntries(TIERS.map((t) => [t, Number(f.tier_max_level[t])])),
    wishlist_max: Number(f.wishlist_max),
    max_orders_per_month: Number(f.max_orders_per_month),
    same_item_cooldown_days: Number(f.same_item_cooldown_days),
    allowed_countries: f.allowed_countries.split(/[,\s]+/).filter(Boolean),
    shelf_enabled: f.shelf_enabled
  };
}

function NumberField({ id, label, value, onChange, hint }: { id: string; label: string; value: string; onChange: (v: string) => void; hint?: string }) {
  return (
    <div>
      <FieldLabel htmlFor={id}>{label}</FieldLabel>
      <TextField id={id} inputMode="decimal" value={value} onChange={(e) => onChange(e.target.value)} />
      {hint ? <p className="mt-1 text-xs text-slate-400">{hint}</p> : null}
    </div>
  );
}

export default function ShelfSettingsPage() {
  const queryClient = useQueryClient();
  const query = useQuery({ queryKey: ["admin", "shelf", "settings"], queryFn: () => admin.shelfSettings() });
  const settings = query.data?.ok ? query.data.data : null;
  const [form, setForm] = useState<Form | null>(null);
  const [terms, setTerms] = useState("");
  const [reviewedBy, setReviewedBy] = useState("");
  const [note, setNote] = useState("");
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);

  useEffect(() => {
    if (settings) {
      setForm(toForm(settings));
      setTerms(settings.terms_text);
    }
  }, [settings]);

  const done = (res: Awaited<ReturnType<typeof admin.shelfSettings>>, text: string) => {
    if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
    setMessage({ tone: "success", text });
    queryClient.setQueryData(["admin", "shelf", "settings"], res);
  };

  if (!form || !settings) {
    return (
      <>
        <PageHeader title="Shelf settings" description="RAWWS value, levels, limits and expiry." />
        {query.data && !query.data.ok ? <Notice tone="error">{query.data.error.message}</Notice> : <p className="text-sm text-slate-400">Loading…</p>}
      </>
    );
  }

  const set = <K extends keyof Form>(key: K, value: Form[K]) => setForm({ ...form, [key]: value });

  return (
    <>
      <PageHeader
        title="Shelf settings"
        description="RAWWS value, levels, limits and expiry. Values are stamped on each earning and order, so a change applies from now on."
      />
      <div className="space-y-4">
        {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
        <Panel className="flex flex-wrap items-center gap-3 p-4">
          <StatusBadge label={settings.shelf_open ? "Open to photographers" : "Closed to photographers"} tone={settings.shelf_open ? "positive" : "attention"} />
          {settings.shelf_enabled && !settings.shelf_open ? (
            <span className="text-sm text-slate-400">On, but closed in production until the terms are approved.</span>
          ) : null}
          <label className="ml-auto flex items-center gap-2 text-sm">
            <input type="checkbox" checked={form.shelf_enabled} onChange={(e) => set("shelf_enabled", e.target.checked)} />
            Shelf on
          </label>
        </Panel>

        <Panel className="grid gap-4 p-4 sm:grid-cols-2 lg:grid-cols-3">
          <NumberField id="raww" label="Euros per RAWW" value={form.raww_eur_value} onChange={(v) => set("raww_eur_value", v)} hint="0.10 means a €150 booking's 5% (€7.50) earns 75 RAWWS." />
          <NumberField id="gbp" label="GBP to EUR (price suggestions only)" value={form.gbp_eur_rate} onChange={(v) => set("gbp_eur_rate", v)} />
          <NumberField id="discount" label="Below street price (%)" value={form.shelf_discount_percent} onChange={(v) => set("shelf_discount_percent", v)} hint="Used for the suggested price." />
          <NumberField id="inactivity" label="Expire after (months without earning or spending)" value={form.inactivity_months} onChange={(v) => set("inactivity_months", v)} />
          <NumberField id="warning" label="Warn this many days before" value={form.warning_days} onChange={(v) => set("warning_days", v)} />
          <NumberField id="wishlist" label="Wish list size" value={form.wishlist_max} onChange={(v) => set("wishlist_max", v)} />
          <NumberField id="orders" label="Orders per photographer per month" value={form.max_orders_per_month} onChange={(v) => set("max_orders_per_month", v)} />
          <NumberField id="cooldown" label="Days before the same item again" value={form.same_item_cooldown_days} onChange={(v) => set("same_item_cooldown_days", v)} />
          <div>
            <FieldLabel htmlFor="countries">Ships to (country codes)</FieldLabel>
            <TextField id="countries" value={form.allowed_countries} onChange={(e) => set("allowed_countries", e.target.value)} />
            <p className="mt-1 text-xs text-slate-400">Shipping is free in the beta.</p>
          </div>
        </Panel>

        <Panel className="space-y-3 p-4">
          <h2 className="text-sm font-semibold">Levels</h2>
          <div className="grid grid-cols-5 gap-3">
            {form.level_band_raww.map((value, i) => (
              <NumberField
                key={i}
                id={`band-${i}`}
                label={`Level ${i + 1} (RAWWS)`}
                value={value}
                onChange={(v) => set("level_band_raww", form.level_band_raww.map((b, j) => (j === i ? v : b)))}
              />
            ))}
          </div>
          <h2 className="pt-2 text-sm font-semibold">Highest level each tier sees</h2>
          <div className="grid grid-cols-5 gap-3">
            {TIERS.map((tier) => (
              <NumberField
                key={tier}
                id={`tier-${tier}`}
                label={tier[0].toUpperCase() + tier.slice(1)}
                value={form.tier_max_level[tier]}
                onChange={(v) => set("tier_max_level", { ...form.tier_max_level, [tier]: v })}
              />
            ))}
          </div>
        </Panel>

        <div className="flex justify-end">
          <AdminButton onClick={async () => done(await admin.saveShelfSettings(toBody(form)), "Settings saved.")}>Save settings</AdminButton>
        </div>

        <Panel className="space-y-3 p-4">
          <div className="flex items-center gap-3">
            <h2 className="text-sm font-semibold">Terms for The Shelf</h2>
            <StatusBadge label={settings.terms_draft ? "Draft, not reviewed" : `Approved, reviewed by ${settings.terms_reviewed_by}`} tone={settings.terms_draft ? "attention" : "positive"} />
          </div>
          <TextArea rows={6} value={terms} onChange={(e) => setTerms(e.target.value)} />
          <div className="flex justify-end">
            <AdminButton tone="secondary" disabled={terms.trim() === settings.terms_text.trim()} onClick={async () => done(await admin.saveShelfTerms(terms), "Terms saved as a draft.")}>
              Save as draft
            </AdminButton>
          </div>
          {settings.terms_draft ? (
            <div className="grid gap-3 border-t border-white/10 pt-3 sm:grid-cols-[1fr_2fr_auto] sm:items-end">
              <div>
                <FieldLabel htmlFor="reviewed-by">Reviewed by</FieldLabel>
                <TextField id="reviewed-by" value={reviewedBy} onChange={(e) => setReviewedBy(e.target.value)} />
              </div>
              <div>
                <FieldLabel htmlFor="review-note">Note</FieldLabel>
                <TextField id="review-note" value={note} onChange={(e) => setNote(e.target.value)} />
              </div>
              <AdminButton
                disabled={!reviewedBy.trim() || !note.trim()}
                onClick={async () => done(await admin.approveShelfTerms({ reviewed_by: reviewedBy, note }), "Terms approved.")}
              >
                Approve terms
              </AdminButton>
            </div>
          ) : null}
        </Panel>
      </div>
    </>
  );
}
