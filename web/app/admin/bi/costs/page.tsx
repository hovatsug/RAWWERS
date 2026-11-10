"use client";

import Link from "next/link";
import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { adminBi, type BiCash, type BiCashInput, type BiCost, type BiCostInput } from "@/lib/api/admin";
import { AdminButton, DataTable, FieldLabel, Notice, PageHeader, Panel, SelectField, TextField } from "@/app/admin/_components/ui";
import { eur } from "../_parts";

/**
 * The dashboard's two manual tables (docs/BI.md):
 * - costs: ad spend and marketing (marketing spend), everything else
 *   (other costs). A recurring cost repeats monthly on its day of the month
 *   until its end date. Shelf shipping is entered on each Shelf order; old
 *   rows in the retired shelf_shipping category show "legacy" and still
 *   come off the Shelf margin.
 * - company cash: an account's balance on a date; the latest per account is
 *   its balance now, used by the liquid view.
 * Amounts are typed in euros with at most two decimals and stored in cents.
 * Every create, edit and delete is recorded (who, when, before and after).
 */
const today = () => new Date().toISOString().slice(0, 10);
const asEuros = (cents: number) => `${cents < 0 ? "-" : ""}${Math.floor(Math.abs(cents) / 100)}.${String(Math.abs(cents) % 100).padStart(2, "0")}`;

export default function BiCostsPage() {
  const client = useQueryClient();
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  const refresh = () => client.invalidateQueries({ queryKey: ["admin", "bi"] });
  const done = (res: { ok: boolean; error?: { message: string } }, text: string) => {
    if (!res.ok) {
      setMessage({ tone: "error", text: res.error?.message || "Not saved" });
      return false;
    }
    setMessage({ tone: "success", text });
    refresh();
    return true;
  };
  return (
    <>
      <PageHeader
        title="Costs and company cash"
        description="The two tables the dashboard cannot know by itself. Every change is recorded with who made it and when."
        actions={
          <Link href={"/admin/bi" as never} className="text-sm text-violet-300 hover:text-violet-200">
            ← Dashboard
          </Link>
        }
      />
      {message ? (
        <div className="mb-4">
          <Notice tone={message.tone}>{message.text}</Notice>
        </div>
      ) : null}
      <Costs done={done} />
      <Cash done={done} />
    </>
  );
}

type Done = (res: { ok: boolean; error?: { message: string } }, text: string) => boolean;

function Costs({ done }: { done: Done }) {
  const [offset, setOffset] = useState(0);
  const query = useQuery({ queryKey: ["admin", "bi", "costs", offset], queryFn: () => adminBi.costs(offset) });
  const page = query.data?.ok ? query.data.data : null;
  const blank: BiCostInput = { date: today(), category: "ad_spend", amount: "", currency: "EUR", note: "", recurring: false, end_date: null };
  const [form, setForm] = useState<BiCostInput>(blank);
  const [editing, setEditing] = useState<string | null>(null);
  // Editing a row in a retired category: it keeps its category and dates
  // (they decide which Shelf orders' shipping it covers); amount and note can change.
  const legacy = !!editing && (page?.legacy_categories || ["shelf_shipping"]).includes(form.category);
  const edit = (row: BiCost) => {
    setEditing(row.id);
    setForm({ date: row.date, category: row.category, amount: asEuros(row.amount_cents), currency: row.currency, note: row.note || "", recurring: row.recurring, end_date: row.end_date });
  };
  const save = async () => {
    const body = { ...form, note: form.note || null, end_date: form.recurring ? form.end_date || null : null };
    const res = editing ? await adminBi.updateCost(editing, body) : await adminBi.createCost(body);
    if (done(res, editing ? "Cost updated." : "Cost added.")) {
      setForm(blank);
      setEditing(null);
    }
  };
  return (
    <section className="mb-8">
      <h2 className="mb-2 text-base font-semibold text-slate-100">Costs</h2>
      <Panel className="mb-3 grid gap-3 p-4 sm:grid-cols-3 lg:grid-cols-6">
        <div>
          <FieldLabel htmlFor="cost-date">Date</FieldLabel>
          <TextField id="cost-date" type="date" disabled={legacy} value={form.date} onChange={(e) => setForm({ ...form, date: e.target.value })} />
        </div>
        <div>
          <FieldLabel htmlFor="cost-category">Category</FieldLabel>
          <SelectField id="cost-category" value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })}>
            {(page?.categories || ["ad_spend", "marketing", "salaries", "software", "legal", "office", "other"]).map((c) => (
              <option key={c} value={c}>
                {c.replace(/_/g, " ")}
              </option>
            ))}
            {legacy ? <option value={form.category}>{form.category.replace(/_/g, " ")} (legacy)</option> : null}
          </SelectField>
        </div>
        <div>
          <FieldLabel htmlFor="cost-amount">Amount</FieldLabel>
          <TextField id="cost-amount" inputMode="decimal" placeholder="0.00" value={form.amount} onChange={(e) => setForm({ ...form, amount: e.target.value.replace(/[^0-9.]/g, "") })} />
        </div>
        <div>
          <FieldLabel htmlFor="cost-currency">Currency</FieldLabel>
          <TextField id="cost-currency" maxLength={3} value={form.currency} onChange={(e) => setForm({ ...form, currency: e.target.value.toUpperCase() })} />
        </div>
        <div className="sm:col-span-2">
          <FieldLabel htmlFor="cost-note">Note</FieldLabel>
          <TextField id="cost-note" value={form.note || ""} onChange={(e) => setForm({ ...form, note: e.target.value })} />
        </div>
        <label className="flex items-center gap-2 text-sm text-slate-300">
          <input type="checkbox" disabled={legacy} checked={form.recurring} onChange={(e) => setForm({ ...form, recurring: e.target.checked })} />
          Repeats monthly
        </label>
        {form.recurring ? (
          <div>
            <FieldLabel htmlFor="cost-end">Until (optional)</FieldLabel>
            <TextField id="cost-end" type="date" disabled={legacy} value={form.end_date || ""} onChange={(e) => setForm({ ...form, end_date: e.target.value || null })} />
          </div>
        ) : null}
        <div className="flex items-end gap-2 sm:col-span-2">
          <AdminButton disabled={!form.amount || !form.date} onClick={save}>
            {editing ? "Save changes" : "Add cost"}
          </AdminButton>
          {editing ? (
            <AdminButton tone="quiet" onClick={() => { setEditing(null); setForm(blank); }}>
              Cancel
            </AdminButton>
          ) : null}
        </div>
      </Panel>
      <DataTable
        rows={page?.items}
        rowKey={(row) => row.id}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : null}
        empty={{ title: "No costs yet", body: "Add ad spend, marketing and running costs above." }}
        columns={[
          { header: "Date", cell: (row) => `${row.date}${row.recurring ? ` → monthly${row.end_date ? ` to ${row.end_date}` : ""}` : ""}` },
          {
            header: "Category",
            cell: (row) => (
              <>
                {row.category.replace(/_/g, " ")}
                {row.legacy ? (
                  <span className="ml-2 rounded bg-slate-700 px-1.5 py-0.5 text-xs text-slate-300" title="Retired category: still counted; new shipping goes on each Shelf order">
                    legacy
                  </span>
                ) : null}
              </>
            )
          },
          { header: "Amount", cell: (row) => <span className="tabular-nums">{row.currency === "EUR" ? eur(row.amount_cents) : `${row.currency} ${asEuros(row.amount_cents)}`}</span> },
          { header: "Note", cell: (row) => row.note || "—" },
          { header: "Changed", cell: (row) => <span className="text-xs text-slate-400">{(row.updated_at || row.created_at).slice(0, 16).replace("T", " ")}</span> },
          {
            header: "",
            cell: (row) => (
              <div className="flex gap-1">
                <AdminButton tone="quiet" onClick={() => edit(row)}>Edit</AdminButton>
                <AdminButton tone="quiet" onClick={async () => { if (window.confirm("Delete this cost?")) done(await adminBi.deleteCost(row.id), "Cost deleted."); }}>
                  Delete
                </AdminButton>
              </div>
            )
          }
        ]}
      />
      <Pager offset={offset} next={page?.next_offset ?? null} setOffset={setOffset} />
    </section>
  );
}

function Cash({ done }: { done: Done }) {
  const [offset, setOffset] = useState(0);
  const query = useQuery({ queryKey: ["admin", "bi", "cash", offset], queryFn: () => adminBi.cash(offset) });
  const page = query.data?.ok ? query.data.data : null;
  const blank: BiCashInput = { date: today(), account: "", amount: "", currency: "EUR", note: "" };
  const [form, setForm] = useState<BiCashInput>(blank);
  const [editing, setEditing] = useState<string | null>(null);
  const edit = (row: BiCash) => {
    setEditing(row.id);
    setForm({ date: row.date, account: row.account, amount: asEuros(row.amount_cents), currency: row.currency, note: row.note || "" });
  };
  const save = async () => {
    const body = { ...form, note: form.note || null };
    const res = editing ? await adminBi.updateCash(editing, body) : await adminBi.createCash(body);
    if (done(res, editing ? "Balance updated." : "Balance added.")) {
      setForm(blank);
      setEditing(null);
    }
  };
  return (
    <section className="mb-8">
      <h2 className="mb-2 text-base font-semibold text-slate-100">Company cash</h2>
      <p className="mb-2 text-sm text-slate-400">The balance of each company account on a date. The latest per account counts as its balance now.</p>
      <Panel className="mb-3 grid gap-3 p-4 sm:grid-cols-3 lg:grid-cols-6">
        <div>
          <FieldLabel htmlFor="cash-date">Date</FieldLabel>
          <TextField id="cash-date" type="date" value={form.date} onChange={(e) => setForm({ ...form, date: e.target.value })} />
        </div>
        <div>
          <FieldLabel htmlFor="cash-account">Account</FieldLabel>
          <TextField id="cash-account" placeholder="Bank" value={form.account} onChange={(e) => setForm({ ...form, account: e.target.value })} />
        </div>
        <div>
          <FieldLabel htmlFor="cash-amount">Balance</FieldLabel>
          <TextField id="cash-amount" inputMode="decimal" placeholder="0.00" value={form.amount} onChange={(e) => setForm({ ...form, amount: e.target.value.replace(/[^0-9.-]/g, "") })} />
        </div>
        <div>
          <FieldLabel htmlFor="cash-currency">Currency</FieldLabel>
          <TextField id="cash-currency" maxLength={3} value={form.currency} onChange={(e) => setForm({ ...form, currency: e.target.value.toUpperCase() })} />
        </div>
        <div>
          <FieldLabel htmlFor="cash-note">Note</FieldLabel>
          <TextField id="cash-note" value={form.note || ""} onChange={(e) => setForm({ ...form, note: e.target.value })} />
        </div>
        <div className="flex items-end gap-2">
          <AdminButton disabled={!form.amount || !form.account || !form.date} onClick={save}>
            {editing ? "Save" : "Add balance"}
          </AdminButton>
          {editing ? (
            <AdminButton tone="quiet" onClick={() => { setEditing(null); setForm(blank); }}>
              Cancel
            </AdminButton>
          ) : null}
        </div>
      </Panel>
      <DataTable
        rows={page?.items}
        rowKey={(row) => row.id}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : null}
        empty={{ title: "No balances yet", body: "Until one is added, the liquid view counts Stripe only and says so." }}
        columns={[
          { header: "Date", cell: (row) => row.date },
          { header: "Account", cell: (row) => row.account },
          { header: "Balance", cell: (row) => <span className="tabular-nums">{row.currency === "EUR" ? eur(row.amount_cents) : `${row.currency} ${asEuros(row.amount_cents)}`}</span> },
          { header: "Note", cell: (row) => row.note || "—" },
          { header: "Changed", cell: (row) => <span className="text-xs text-slate-400">{(row.updated_at || row.created_at).slice(0, 16).replace("T", " ")}</span> },
          {
            header: "",
            cell: (row) => (
              <div className="flex gap-1">
                <AdminButton tone="quiet" onClick={() => edit(row)}>Edit</AdminButton>
                <AdminButton tone="quiet" onClick={async () => { if (window.confirm("Delete this balance?")) done(await adminBi.deleteCash(row.id), "Balance deleted."); }}>
                  Delete
                </AdminButton>
              </div>
            )
          }
        ]}
      />
      <Pager offset={offset} next={page?.next_offset ?? null} setOffset={setOffset} />
    </section>
  );
}

function Pager({ offset, next, setOffset }: { offset: number; next: number | null; setOffset: (n: number) => void }) {
  if (offset === 0 && next === null) return null;
  return (
    <div className="mt-2 flex gap-2">
      <AdminButton tone="secondary" disabled={offset === 0} onClick={() => setOffset(Math.max(0, offset - 50))}>
        Previous
      </AdminButton>
      <AdminButton tone="secondary" disabled={next === null} onClick={() => setOffset(next ?? offset)}>
        Next
      </AdminButton>
    </div>
  );
}
