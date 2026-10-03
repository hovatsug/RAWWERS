"use client";

import { useEffect, useRef, useState, type ReactNode } from "react";
import { cn } from "@/lib/utils";

/**
 * The admin panel's own building blocks.
 *
 * The web app's tokens - the same dark ground, slate text and violet accent -
 * without the glow orbs, glass blur and gradients the client-facing pages
 * use. This is a dense working surface people use daily, not a marketing
 * page; decoration here only competes with the data.
 *
 * Every admin page is built from these, so pages agree by construction:
 * one header, one table, one badge, one confirmation step.
 */

// ─── Surfaces and buttons ──────────────────────────────────────────────────

export function Panel({ className, children }: { className?: string; children: ReactNode }) {
  return <div className={cn("rounded-xl border border-white/10 bg-white/[0.03]", className)}>{children}</div>;
}

type ButtonTone = "primary" | "secondary" | "danger" | "quiet";

export function AdminButton({
  tone = "primary",
  className,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { tone?: ButtonTone }) {
  return (
    <button
      type="button"
      className={cn(
        "inline-flex h-9 items-center justify-center rounded-lg px-3.5 text-sm font-medium transition-colors",
        "disabled:cursor-not-allowed disabled:opacity-40",
        "focus:outline-none focus-visible:ring-2 focus-visible:ring-violet-400/60",
        tone === "primary" && "bg-violet-600 text-white hover:bg-violet-500",
        tone === "secondary" && "border border-white/15 text-slate-200 hover:bg-white/[0.06]",
        tone === "danger" && "bg-rose-600 text-white hover:bg-rose-500",
        tone === "quiet" && "text-slate-400 hover:text-slate-100",
        className
      )}
      {...props}
    />
  );
}

const field =
  "w-full rounded-lg border border-white/15 bg-[#0D0D1A] px-3 py-2 text-sm text-slate-100 placeholder:text-slate-500 focus:border-violet-500/60 focus:outline-none focus:ring-2 focus:ring-violet-500/20";

export function TextField(props: React.InputHTMLAttributes<HTMLInputElement>) {
  return <input {...props} className={cn(field, props.className)} />;
}

export function TextArea(props: React.TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return <textarea rows={3} {...props} className={cn(field, "resize-y", props.className)} />;
}

export function SelectField(props: React.SelectHTMLAttributes<HTMLSelectElement>) {
  return <select {...props} className={cn(field, props.className)} />;
}

export function FieldLabel({ children, htmlFor }: { children: ReactNode; htmlFor?: string }) {
  return (
    <label htmlFor={htmlFor} className="mb-1 block text-xs font-medium text-slate-400">
      {children}
    </label>
  );
}

// ─── Page header ───────────────────────────────────────────────────────────

export function PageHeader({
  title,
  description,
  actions
}: {
  title: string;
  description?: ReactNode;
  actions?: ReactNode;
}) {
  return (
    <header className="mb-5 flex flex-wrap items-start justify-between gap-3">
      <div className="min-w-0">
        <h1 className="text-xl font-semibold text-slate-50">{title}</h1>
        {description ? <p className="mt-1 max-w-3xl text-sm text-slate-400">{description}</p> : null}
      </div>
      {actions ? <div className="flex flex-wrap items-center gap-2">{actions}</div> : null}
    </header>
  );
}

// ─── Status badge ──────────────────────────────────────────────────────────

export type Tone = "neutral" | "attention" | "positive" | "negative" | "info";

const TONE_CLASS: Record<Tone, string> = {
  neutral: "border-white/15 bg-white/[0.06] text-slate-300",
  attention: "border-amber-500/30 bg-amber-500/15 text-amber-300",
  positive: "border-emerald-500/30 bg-emerald-500/15 text-emerald-300",
  negative: "border-rose-500/30 bg-rose-500/15 text-rose-300",
  info: "border-violet-500/30 bg-violet-500/15 text-violet-300"
};

/**
 * Every status the panel shows, in words and one of five tones. One table
 * for all of them so "pending review" reads the same on gear as on a
 * payout, and so a status the server adds later still shows as words.
 */
const STATUS: Record<string, { label: string; tone: Tone }> = {
  // payouts
  requested: { label: "Requested", tone: "attention" },
  approved: { label: "Approved", tone: "info" },
  processing: { label: "Processing", tone: "info" },
  paid: { label: "Paid", tone: "positive" },
  failed: { label: "Failed", tone: "negative" },
  rejected: { label: "Rejected", tone: "negative" },
  cancelled: { label: "Cancelled", tone: "neutral" },
  // gear
  pending_review: { label: "Needs review", tone: "attention" },
  verified: { label: "Verified", tone: "positive" },
  // disputes
  open: { label: "Open", tone: "attention" },
  under_review: { label: "Under review", tone: "attention" },
  awaiting_evidence: { label: "Awaiting evidence", tone: "attention" },
  escalated: { label: "Escalated", tone: "negative" },
  resolved_refund: { label: "Refunded", tone: "positive" },
  resolved_partial_refund: { label: "Partly refunded", tone: "positive" },
  resolved_no_refund: { label: "No refund", tone: "neutral" },
  closed: { label: "Closed", tone: "neutral" },
  // photographers
  approved_public: { label: "Live", tone: "positive" },
  ready_for_review: { label: "Ready for review", tone: "attention" },
  pending: { label: "Pending", tone: "attention" }
};

export function statusLabel(status: string): string {
  return STATUS[status]?.label ?? status.replace(/_/g, " ").replace(/^\w/, (c) => c.toUpperCase());
}

export function StatusBadge({ status, label, tone }: { status?: string; label?: string; tone?: Tone }) {
  const known = status ? STATUS[status] : undefined;
  const resolvedTone = tone ?? known?.tone ?? "neutral";
  return (
    <span
      className={cn(
        "inline-flex items-center whitespace-nowrap rounded-full border px-2 py-0.5 text-xs font-medium",
        TONE_CLASS[resolvedTone]
      )}
    >
      {label ?? (status ? statusLabel(status) : "")}
    </span>
  );
}

// ─── Inline messages ───────────────────────────────────────────────────────

export function Notice({ tone, children }: { tone: "error" | "success" | "warning"; children: ReactNode }) {
  return (
    <p
      role={tone === "error" ? "alert" : "status"}
      className={cn(
        "rounded-lg border px-3 py-2 text-sm",
        tone === "error" && "border-rose-500/30 bg-rose-500/10 text-rose-200",
        tone === "success" && "border-emerald-500/30 bg-emerald-500/10 text-emerald-200",
        tone === "warning" && "border-amber-500/30 bg-amber-500/10 text-amber-200"
      )}
    >
      {children}
    </p>
  );
}

// ─── Data table ────────────────────────────────────────────────────────────

export type Column<T> = {
  header: string;
  cell: (row: T) => ReactNode;
  className?: string;
};

/**
 * The one list component. Loading, failure (with retry) and empty are part of
 * it rather than each page's job, so no list can ship without them.
 */
export function DataTable<T>({
  columns,
  rows,
  rowKey,
  loading,
  error,
  onRetry,
  empty
}: {
  columns: Column<T>[];
  rows: T[] | undefined;
  rowKey: (row: T) => string;
  loading?: boolean;
  error?: string | null;
  onRetry?: () => void;
  empty: { title: string; body?: string };
}) {
  return (
    <Panel className="overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full border-collapse text-sm">
          <thead>
            <tr className="border-b border-white/10 text-left">
              {columns.map((c) => (
                <th key={c.header} scope="col" className={cn("px-4 py-2.5 text-xs font-medium uppercase tracking-wide text-slate-500", c.className)}>
                  {c.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {loading ? (
              [0, 1, 2].map((i) => (
                <tr key={i} className="border-b border-white/[0.06] last:border-0">
                  {columns.map((c) => (
                    <td key={c.header} className="px-4 py-3">
                      <div className="h-4 w-3/4 animate-pulse rounded bg-white/[0.06]" />
                    </td>
                  ))}
                </tr>
              ))
            ) : error ? (
              <tr>
                <td colSpan={columns.length} className="px-4 py-8 text-center">
                  <p className="text-sm text-slate-200">Could not load this list.</p>
                  <p className="mt-1 text-xs text-slate-500">{error}</p>
                  {onRetry ? (
                    <AdminButton tone="secondary" className="mt-3" onClick={onRetry}>
                      Try again
                    </AdminButton>
                  ) : null}
                </td>
              </tr>
            ) : !rows || rows.length === 0 ? (
              <tr>
                <td colSpan={columns.length} className="px-4 py-10 text-center">
                  <p className="text-sm font-medium text-slate-200">{empty.title}</p>
                  {empty.body ? <p className="mt-1 text-sm text-slate-500">{empty.body}</p> : null}
                </td>
              </tr>
            ) : (
              rows.map((row) => (
                <tr key={rowKey(row)} className="border-b border-white/[0.06] align-top last:border-0 hover:bg-white/[0.02]">
                  {columns.map((c) => (
                    <td key={c.header} className={cn("px-4 py-3 text-slate-200", c.className)}>
                      {c.cell(row)}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </Panel>
  );
}

// ─── Confirmation ──────────────────────────────────────────────────────────

/**
 * The only way a consequential action fires.
 *
 * It says what will happen and to whom before anything is sent, keeps the
 * dialog open with the server's reason if the action is refused, and - where
 * the person on the other end will read the reason - will not confirm with
 * it blank. `onConfirm` resolves to an error message, or null on success.
 */
export function ConfirmDialog({
  open,
  title,
  children,
  confirmLabel,
  tone = "primary",
  reason,
  canConfirm = true,
  onConfirm,
  onClose
}: {
  open: boolean;
  title: string;
  children?: ReactNode;
  confirmLabel: string;
  tone?: "primary" | "danger";
  /** Ask for a reason, required to confirm. */
  reason?: { label: string; placeholder?: string };
  /** Extra condition from fields the caller renders in `children`. */
  canConfirm?: boolean;
  onConfirm: (reason: string) => Promise<string | null>;
  onClose: () => void;
}) {
  const [text, setText] = useState("");
  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const dialogRef = useRef<HTMLDivElement>(null);
  // Callers pass `onClose` inline, so it is a new function on every render of
  // the page. Depending on it would re-run the opening below whenever the
  // page re-renders - wiping a half-typed reason and pulling focus out of
  // whatever field the admin is typing in.
  const onCloseRef = useRef(onClose);
  onCloseRef.current = onClose;

  useEffect(() => {
    if (!open) return;
    setText("");
    setError(null);
    setPending(false);
    dialogRef.current?.focus();
    const onKey = (event: KeyboardEvent) => {
      if (event.key === "Escape") onCloseRef.current();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open]);

  if (!open) return null;

  const reasonMissing = reason !== undefined && text.trim() === "";
  const disabled = pending || reasonMissing || !canConfirm;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4" onMouseDown={onClose}>
      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby="confirm-title"
        tabIndex={-1}
        className="w-full max-w-md rounded-xl border border-white/15 bg-[#0D0D1A] p-5 shadow-2xl focus:outline-none"
        onMouseDown={(event) => event.stopPropagation()}
      >
        <h2 id="confirm-title" className="text-base font-semibold text-slate-50">
          {title}
        </h2>
        {children ? <div className="mt-2 space-y-3 text-sm text-slate-300">{children}</div> : null}
        {reason ? (
          <div className="mt-3">
            <FieldLabel htmlFor="confirm-reason">{reason.label}</FieldLabel>
            <TextArea
              id="confirm-reason"
              value={text}
              placeholder={reason.placeholder}
              onChange={(event) => setText(event.target.value)}
            />
          </div>
        ) : null}
        {error ? (
          <div className="mt-3">
            <Notice tone="error">{error}</Notice>
          </div>
        ) : null}
        <div className="mt-5 flex justify-end gap-2">
          <AdminButton tone="secondary" onClick={onClose} disabled={pending}>
            Cancel
          </AdminButton>
          <AdminButton
            tone={tone === "danger" ? "danger" : "primary"}
            disabled={disabled}
            onClick={async () => {
              setPending(true);
              setError(null);
              const failure = await onConfirm(text.trim());
              setPending(false);
              if (failure) {
                setError(failure);
                return;
              }
              onClose();
            }}
          >
            {pending ? "Working…" : confirmLabel}
          </AdminButton>
        </div>
      </div>
    </div>
  );
}

// ─── Formatting ────────────────────────────────────────────────────────────

/** Amounts arrive as decimal strings; shown as they are, never as floats. */
export function money(amount: string | null | undefined, currency = "EUR"): string {
  if (amount === null || amount === undefined || amount === "") return "—";
  const symbol = currency === "EUR" ? "€" : currency === "GBP" ? "£" : `${currency} `;
  return `${symbol}${amount}`;
}

export function words(value: string | null | undefined): string {
  return value ? value.replace(/_/g, " ") : "—";
}
