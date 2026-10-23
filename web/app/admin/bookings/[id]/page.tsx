"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type ReductionLine, type ReductionPreview } from "@/lib/api/admin";
import { AdminButton, FieldLabel, Notice, PageHeader, Panel, SelectField, TextArea, TextField, money } from "@/app/admin/_components/ui";

/**
 * One booking's money, and the one way to lower its price after payment.
 *
 * Reducing a price refunds the client everything they paid beyond the new
 * price and brings the photographer's earnings down to it - the server does
 * both, in one step. So the form always previews first: the client's refund
 * and the photographer's earnings before and after, from the server, before
 * anything is confirmed. Every reduction needs a reason (from the admin-
 * editable list) and a note.
 */
export default function AdminBookingMoneyPage() {
  const { id } = useParams<{ id: string }>();
  const queryClient = useQueryClient();
  const query = useQuery({ queryKey: ["admin", "booking-money", id], queryFn: () => admin.bookingMoney(id) });
  const data = query.data?.ok ? query.data.data : undefined;

  const [reason, setReason] = useState("");
  const [amount, setAmount] = useState("");
  const [note, setNote] = useState("");
  const [preview, setPreview] = useState<ReductionPreview | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState<string | null>(null);
  const [key] = useState(() => (typeof crypto !== "undefined" && "randomUUID" in crypto ? crypto.randomUUID() : String(Date.now())));

  const lines = (): ReductionLine[] => [{ reason_code: reason, amount }];

  if (query.isLoading) return <PageHeader title="Booking money" description="Loading…" />;
  if (!data) {
    return (
      <>
        <PageHeader title="Booking money" />
        <Notice tone="error">{query.data && !query.data.ok ? query.data.error.message : "Check that the API is reachable."}</Notice>
      </>
    );
  }

  return (
    <>
      <PageHeader title="Booking money" description={`Booking ${data.gig_id} · ${data.status.replace(/_/g, " ")}`} />

      <div className="grid gap-4 md:grid-cols-2">
        <Panel>
          <h2 className="mb-2 text-sm font-semibold text-slate-200">Price</h2>
          <dl className="space-y-1 text-sm text-slate-300">
            <div className="flex justify-between"><dt>Deposit (at booking)</dt><dd className="tabular-nums">{money(data.deposit.amount, data.currency)}</dd></div>
            <div className="flex justify-between"><dt>Final price</dt><dd className="tabular-nums font-semibold">{money(data.final_price, data.currency)}</dd></div>
            {data.final_split ? (
              <>
                <div className="flex justify-between"><dt>Photographer cash</dt><dd className="tabular-nums">{money(data.final_split.pro_cash, data.currency)}</dd></div>
                <div className="flex justify-between"><dt>Platform retained</dt><dd className="tabular-nums">{money(data.final_split.platform_retained, data.currency)}</dd></div>
                <div className="flex justify-between"><dt>RAWW credit</dt><dd className="tabular-nums">{money(data.final_split.pro_raww, data.currency)}</dd></div>
              </>
            ) : null}
            <div className="flex justify-between"><dt>Photographer balance (real)</dt><dd className="tabular-nums">{money(data.photographer.available, data.currency)}</dd></div>
          </dl>
        </Panel>

        <Panel>
          <h2 className="mb-2 text-sm font-semibold text-slate-200">Payments</h2>
          <ul className="space-y-1 text-sm text-slate-300">
            {data.payments.map((p) => (
              <li key={p.payment_intent} className="flex justify-between gap-2">
                <span>{p.kind} · {p.status}</span>
                <span className="tabular-nums">{money(p.amount, data.currency)}{p.amount_refunded !== "0.00" ? ` (−${money(p.amount_refunded, data.currency)} refunded)` : ""}</span>
              </li>
            ))}
          </ul>
        </Panel>
      </div>

      {data.reductions.length ? (
        <Panel className="mt-4">
          <h2 className="mb-2 text-sm font-semibold text-slate-200">Reductions</h2>
          <ul className="space-y-2 text-sm text-slate-300">
            {data.reductions.map((r) => (
              <li key={r.id}>
                <p>{money(r.from_amount, data.currency)} → {money(r.to_amount, data.currency)} · refund {money(r.refund_amount, data.currency)} · {r.source}</p>
                <p className="text-xs text-slate-400">{r.lines.map((l) => `${l.label} ${money(l.amount, data.currency)}`).join(" · ")} — {r.note}</p>
              </li>
            ))}
          </ul>
        </Panel>
      ) : null}

      {data.reductions.some((r) => r.lines.some((l) => data.reasons.find((x) => x.code === l.reason_code)?.may_carry_fault)) ? (
        <RecordFinding gigId={id} proId={data.photographer.pro_user_id} />
      ) : null}

      <Panel className="mt-4">
        <h2 className="mb-2 text-sm font-semibold text-slate-200">Reduce price</h2>
        <div className="grid gap-3 md:grid-cols-3">
          <div>
            <FieldLabel htmlFor="reason">Reason</FieldLabel>
            <SelectField id="reason" value={reason} onChange={(e) => { setReason(e.target.value); setPreview(null); }}>
              <option value="">Choose…</option>
              {data.reasons.filter((r) => r.is_active).map((r) => (
                <option key={r.code} value={r.code}>{r.label}</option>
              ))}
            </SelectField>
          </div>
          <div>
            <FieldLabel htmlFor="amount">Reduce by ({data.currency})</FieldLabel>
            <TextField id="amount" inputMode="decimal" value={amount} onChange={(e) => { setAmount(e.target.value); setPreview(null); }} />
          </div>
          <div className="md:col-span-3">
            <FieldLabel htmlFor="note">Note (required)</FieldLabel>
            <TextArea id="note" value={note} onChange={(e) => setNote(e.target.value)} />
          </div>
        </div>
        {error ? <Notice tone="error">{error}</Notice> : null}
        {done ? <Notice tone="success">{done}</Notice> : null}
        {preview ? (
          <div className="mt-3 rounded border border-slate-700 p-3 text-sm text-slate-200" role="status">
            <p>Price {money(preview.from_amount, preview.currency)} → {money(preview.to_amount, preview.currency)}</p>
            <p>The client is refunded <strong>{money(preview.client_refund, preview.currency)}</strong></p>
            <p>Photographer cash {money(preview.photographer_cash_before, preview.currency)} → {money(preview.photographer_cash_after, preview.currency)}</p>
          </div>
        ) : null}
        <div className="mt-3 flex gap-2">
          <AdminButton
            disabled={!reason || !amount}
            onClick={async () => {
              setError(null);
              setDone(null);
              const res = await admin.previewReduction(id, lines());
              if (!res.ok) return setError(res.error.message);
              setPreview(res.data);
            }}
          >
            Preview
          </AdminButton>
          <AdminButton
            disabled={!preview || !note.trim()}
            onClick={async () => {
              setError(null);
              const res = await admin.reducePrice(id, lines(), note, key);
              if (!res.ok) return setError(res.error.message);
              setDone("Price reduced. The client's refund is on its way.");
              setPreview(null);
              queryClient.invalidateQueries({ queryKey: ["admin", "booking-money", id] });
            }}
          >
            Confirm reduction
          </AdminButton>
        </div>
      </Panel>
    </>
  );
}

/**
 * Recording fault is an admin's decision, never the system's: only here, on a
 * booking whose price came down because photos were not delivered. The
 * photographer is told and can respond; nothing takes effect before their
 * window to respond ends.
 */
function RecordFinding({ gigId, proId }: { gigId: string; proId: string }) {
  const [note, setNote] = useState("");
  const [severe, setSevere] = useState(false);
  const [severeNote, setSevereNote] = useState("");
  const [message, setMessage] = useState<{ tone: "error" | "success"; text: string } | null>(null);
  return (
    <Panel className="mt-4">
      <h2 className="mb-2 text-sm font-semibold text-slate-200">Record a finding</h2>
      <FieldLabel htmlFor="finding-note">What was found (the photographer reads this)</FieldLabel>
      <TextArea id="finding-note" value={note} onChange={(e) => setNote(e.target.value)} />
      <label className="mt-2 flex items-center gap-2 text-sm text-slate-300">
        <input type="checkbox" checked={severe} onChange={(e) => setSevere(e.target.checked)} /> Severe (skips to a suspension review)
      </label>
      {severe ? (
        <>
          <FieldLabel htmlFor="severe-note">Why it is severe</FieldLabel>
          <TextArea id="severe-note" value={severeNote} onChange={(e) => setSevereNote(e.target.value)} />
        </>
      ) : null}
      {message ? <Notice tone={message.tone}>{message.text}</Notice> : null}
      <AdminButton
        className="mt-2"
        disabled={!note.trim() || (severe && !severeNote.trim())}
        onClick={async () => {
          const res = await admin.recordFinding(gigId, note, severe, severe ? severeNote : null);
          if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
          setMessage({ tone: "success", text: `Recorded. The photographer is told and can respond; see it on their page (${proId}).` });
          setNote("");
        }}
      >
        Record finding
      </AdminButton>
    </Panel>
  );
}
