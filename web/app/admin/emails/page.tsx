"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type FailedEmail } from "@/lib/api/admin";
import { AdminButton, ConfirmDialog, DataTable, PageHeader, StatusBadge, type Column, type Tone } from "@/app/admin/_components/ui";

/**
 * Emails that did not go out (api/app/services/email_alerts.py).
 *
 * - "Our side" (Brevo answered 401/403: the API key, the sender, or this
 *   server's IP not authorised in Brevo) is never retried; it also raised a
 *   Sentry event and an in-app alert. Fix the setting, then resend.
 * - "Refused" (another 4xx) and "No answer" (a timeout, maybe delivered) are
 *   not retried either.
 * - "Retrying" (429/5xx) is retried by the outbox for about half an hour;
 *   it can be resent once that is over.
 * A verification or reset code is never resent: the person asks for a new one.
 */

const FAILURE: Record<string, { label: string; tone: Tone }> = {
  config: { label: "Our side (401/403)", tone: "negative" },
  rejected: { label: "Refused", tone: "attention" },
  uncertain: { label: "No answer", tone: "attention" },
  transient: { label: "Retrying", tone: "info" }
};

function when(iso: string): string {
  return new Date(iso).toLocaleString("en-GB", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" });
}

export default function AdminFailedEmailsPage() {
  const queryClient = useQueryClient();
  const [resending, setResending] = useState<FailedEmail | null>(null);
  const query = useQuery({ queryKey: ["admin", "failed-emails"], queryFn: () => admin.failedEmails() });
  const items = query.data?.ok ? query.data.data.items : undefined;
  const configFailures = items?.filter((i) => i.failure === "config" && !i.resent_at).length ?? 0;

  const columns: Column<FailedEmail>[] = [
    {
      header: "Email",
      cell: (row) => (
        <div>
          <p className="font-medium text-slate-50">{row.subject}</p>
          <p className="text-xs text-slate-400">
            {row.template_key} · {row.to_email}
          </p>
        </div>
      )
    },
    {
      header: "Why",
      cell: (row) => {
        const f = row.failure ? FAILURE[row.failure] : undefined;
        return (
          <div>
            <StatusBadge label={f?.label ?? "Failed"} tone={f?.tone ?? "neutral"} />
            <p className="mt-1 max-w-md break-words font-mono text-[11px] text-slate-500">{row.error ?? "—"}</p>
          </div>
        );
      }
    },
    { header: "When", className: "whitespace-nowrap text-xs", cell: (row) => when(row.updated_at) },
    {
      header: "",
      className: "w-px whitespace-nowrap text-right",
      cell: (row) =>
        row.resent_at ? (
          <span className="text-xs text-slate-400">Resent {when(row.resent_at)}</span>
        ) : row.security ? (
          <span className="text-xs text-slate-400">Code: not resent</span>
        ) : row.resendable ? (
          <AdminButton onClick={() => setResending(row)}>Resend…</AdminButton>
        ) : (
          <span className="text-xs text-slate-400">Still retrying</span>
        )
    }
  ];

  return (
    <>
      <PageHeader
        title="Failed emails"
        description={
          items === undefined
            ? "Emails that did not go out."
            : items.length === 0
              ? "No failed emails."
              : `${items.length} failed. Resend once the cause is fixed.`
        }
      />
      {configFailures > 0 ? (
        <p className="mb-3 rounded-md border border-rose-500/30 bg-rose-500/10 p-3 text-sm text-rose-200">
          {configFailures} email{configFailures === 1 ? "" : "s"} failed on our side: Brevo refused the request (401/403). Check
          BREVO_API_KEY, the sender address, and that this server&apos;s IP is authorised in Brevo (docs/BREVO_SETUP.md), then resend.
        </p>
      ) : null}
      <DataTable
        columns={columns}
        rows={items}
        rowKey={(row) => row.id}
        loading={query.isLoading}
        error={query.data && !query.data.ok ? query.data.error.message : query.error ? "Check that the API is reachable." : null}
        onRetry={() => query.refetch()}
        empty={{ title: "No failed emails", body: "Emails that could not be sent appear here." }}
      />
      <ConfirmDialog
        open={resending !== null}
        title={resending ? `Resend: ${resending.subject}` : ""}
        confirmLabel="Resend"
        onClose={() => setResending(null)}
        onConfirm={async () => {
          if (!resending) return null;
          const res = await admin.resendEmail(resending.id);
          if (!res.ok) return res.error.message;
          queryClient.invalidateQueries({ queryKey: ["admin", "failed-emails"] });
          return null;
        }}
      >
        <p>
          It goes to {resending?.to_email} again, through the same checks as the first time (the person&apos;s email switches,
          suppression, the daily limit). Its new attempt appears here if it fails too.
        </p>
      </ConfirmDialog>
    </>
  );
}
