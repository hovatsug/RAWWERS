"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, type Finding } from "@/lib/api/admin";
import { AdminButton, ConfirmDialog, Panel, StatusBadge } from "@/app/admin/_components/ui";

/**
 * A photographer's findings for non-delivery: what was found, what they
 * answered, and the decision - plus the booking pause, which only an admin
 * lifts. Findings are recorded from a booking reduced for non-delivery; a
 * confirmation takes effect only once the photographer's window to respond
 * has ended, and nothing here touches ranking.
 */
export function Findings({ proId }: { proId: string }) {
  const queryClient = useQueryClient();
  const query = useQuery({ queryKey: ["admin", "findings", proId], queryFn: () => admin.proFindings(proId) });
  const [deciding, setDeciding] = useState<{ finding: Finding; decision: "confirm" | "withdraw" } | null>(null);
  const [lifting, setLifting] = useState(false);
  const data = query.data?.ok ? query.data.data : null;
  if (!data) return null;
  const refresh = () => queryClient.invalidateQueries({ queryKey: ["admin", "findings", proId] });

  return (
    <Panel className="mt-4 p-4">
      <div className="flex items-center justify-between">
        <h2 className="text-sm font-semibold text-slate-200">Findings</h2>
        <p className="text-xs text-slate-400">{data.strikes} strike{data.strikes === 1 ? "" : "s"} in the rolling window</p>
      </div>
      {data.pause ? (
        <div className="mt-2 flex items-center justify-between rounded border border-amber-700 p-2 text-sm text-amber-200">
          <span>New bookings paused since {new Date(data.pause.since).toLocaleDateString("en-GB")}: {data.pause.reason}</span>
          <AdminButton onClick={() => setLifting(true)}>Lift pause…</AdminButton>
        </div>
      ) : null}
      {data.items.length === 0 ? <p className="mt-2 text-sm text-slate-400">No findings.</p> : null}
      <ul className="mt-2 space-y-3">
        {data.items.map((f) => (
          <li key={f.id} className="rounded border border-slate-700 p-3 text-sm text-slate-300">
            <div className="flex items-center gap-2">
              <StatusBadge label={f.status} tone={f.status === "confirmed" ? "attention" : "info"} />
              <span>{f.reason}</span>
              {f.severe ? <StatusBadge label="severe" tone="attention" /> : null}
              {f.consequence ? <span className="text-xs text-slate-400">strike {f.strike_number}: {f.consequence.replace(/_/g, " ")}</span> : null}
            </div>
            <p className="mt-1">{f.note}</p>
            <p className="mt-1 text-xs text-slate-400">
              {f.first_seen_at ? `Seen ${new Date(f.first_seen_at).toLocaleDateString("en-GB")}` : "Not seen yet"} · window ends{" "}
              {new Date(f.window_ends_at).toLocaleDateString("en-GB")}
            </p>
            {f.response ? <p className="mt-1 text-xs">Their response: {f.response}</p> : null}
            {f.decision_note ? <p className="mt-1 text-xs">Decision: {f.decision_note}</p> : null}
            {f.status === "pending" ? (
              <div className="mt-2 flex gap-2">
                <AdminButton onClick={() => setDeciding({ finding: f, decision: "confirm" })}>Confirm…</AdminButton>
                <AdminButton onClick={() => setDeciding({ finding: f, decision: "withdraw" })}>Withdraw…</AdminButton>
              </div>
            ) : null}
          </li>
        ))}
      </ul>

      <ConfirmDialog
        open={deciding !== null}
        title={deciding?.decision === "confirm" ? "Confirm this finding?" : "Withdraw this finding?"}
        confirmLabel={deciding?.decision === "confirm" ? "Confirm" : "Withdraw"}
        reason={{ label: "Note (recorded with the decision)", placeholder: "What you found, and why" }}
        onClose={() => setDeciding(null)}
        onConfirm={async (note) => {
          if (!deciding) return null;
          const res = await admin.decideFinding(deciding.finding.id, deciding.decision, note);
          if (!res.ok) return res.error.message;
          refresh();
          return null;
        }}
      >
        <p>
          {deciding?.decision === "confirm"
            ? "It takes effect when their window to respond has ended - not before."
            : "A withdrawn finding leaves no strike."}
        </p>
      </ConfirmDialog>

      <ConfirmDialog
        open={lifting}
        title="Lift the booking pause?"
        confirmLabel="Lift pause"
        reason={{ label: "Note", placeholder: "What you reviewed" }}
        onClose={() => setLifting(false)}
        onConfirm={async (note) => {
          const res = await admin.liftBookingPause(proId, note);
          if (!res.ok) return res.error.message;
          refresh();
          return null;
        }}
      >
        <p>They can take new bookings again and are back on Discover.</p>
      </ConfirmDialog>
    </Panel>
  );
}
