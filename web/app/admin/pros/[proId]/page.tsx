"use client";

import { useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { admin, SKILL_TIERS, type NicheSkillRow, type SkillTier } from "@/lib/api/admin";
import { humanise } from "@/app/admin/labels";
import { Findings } from "./findings";
import {
  AdminButton,
  ConfirmDialog,
  Notice,
  PageHeader,
  Panel,
  StatusBadge,
  money
} from "@/app/admin/_components/ui";

/**
 * One photographer, and the decision.
 *
 * Approving is a single action that clears both gates the backend requires -
 * identity and public listing - because doing them separately leaves people
 * approved but invisible, which nobody notices until they ask why no
 * requests arrive.
 *
 * Both decisions go through a confirmation. Rejection needs a reason: the
 * photographer reads it, and it used to default silently to "Not approved"
 * when the box was left empty.
 */
export default function AdminProReviewPage() {
  const { proId } = useParams<{ proId: string }>();
  const router = useRouter();
  const queryClient = useQueryClient();
  const [dialog, setDialog] = useState<"approve" | "reject" | null>(null);
  const [result, setResult] = useState<string | null>(null);

  const query = useQuery({
    queryKey: ["admin", "review", proId],
    queryFn: () => admin.reviewDetail(proId)
  });

  const back = (
    <Link href="/admin" className="mb-3 inline-block text-sm text-slate-500 hover:text-slate-300">
      ← Photographers
    </Link>
  );

  if (query.isLoading) {
    return (
      <>
        {back}
        <div className="h-64 animate-pulse rounded-xl bg-white/[0.04]" />
      </>
    );
  }
  if (!query.data?.ok) {
    return (
      <>
        {back}
        <Panel className="p-6 text-center">
          <p className="text-sm text-slate-200">Could not load this photographer.</p>
          <p className="mt-1 text-xs text-slate-500">{query.data && !query.data.ok ? query.data.error.message : ""}</p>
          <AdminButton tone="secondary" className="mt-3" onClick={() => query.refetch()}>
            Try again
          </AdminButton>
        </Panel>
      </>
    );
  }

  const detail = query.data.data;
  const { row, packages, portfolio_urls: portfolio } = detail;
  const alreadyLive = row.onboarding_status === "approved_public" && row.kyc_status === "approved";
  const name = row.display_name || "this photographer";

  return (
    <>
      {back}
      <PageHeader
        title={row.display_name || "Unnamed"}
        description={row.headline || undefined}
        actions={
          <>
            {alreadyLive ? <StatusBadge label="Live" tone="positive" /> : <StatusBadge label="Not live" tone="attention" />}
            {row.payout_blocked ? <StatusBadge label="No payout method" tone="attention" /> : null}
          </>
        }
      />

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="space-y-4 lg:col-span-2">
          <Panel className="p-4">
            <h2 className="text-sm font-semibold text-slate-100">What a client would see</h2>
            <div className="mt-3 grid grid-cols-4 gap-2 sm:grid-cols-6">
              {portfolio.slice(0, 12).map((url, i) => (
                // eslint-disable-next-line @next/next/no-img-element
                <img key={i} src={url} alt="" className="aspect-square w-full rounded object-cover" />
              ))}
            </div>
            <dl className="mt-4 grid grid-cols-[6rem_1fr] gap-y-1 text-sm">
              <dt className="text-slate-500">Where</dt>
              <dd>{[row.city, row.country].filter(Boolean).join(", ") || "—"}</dd>
              <dt className="text-slate-500">Travels</dt>
              <dd>{detail.travel_radius_km ? `${detail.travel_radius_km} km` : "Not said"}</dd>
              <dt className="text-slate-500">Styles</dt>
              <dd>{detail.styles.join(", ") || "—"}</dd>
              <dt className="text-slate-500">Languages</dt>
              <dd>{detail.languages.join(", ") || "—"}</dd>
            </dl>
            {detail.bio ? <p className="mt-3 text-sm text-slate-400">{detail.bio}</p> : null}
          </Panel>

          <Panel className="p-4">
            <h2 className="text-sm font-semibold text-slate-100">Packages</h2>
            {packages.length === 0 ? (
              <p className="mt-2 text-sm text-slate-500">No packages yet.</p>
            ) : (
              <ul className="mt-2 space-y-1 text-sm">
                {packages.map((p) => (
                  <li key={p.title}>
                    <span className="text-slate-100">{p.title}</span>
                    <span className="text-slate-400">
                      {" "}
                      — {money(p.price, p.currency)}/photo, {p.included_photos} included, {p.duration_minutes} min ({p.niche_slug})
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </Panel>
        </div>

        <div className="space-y-4">
          <Panel className="p-4">
            <h2 className="text-sm font-semibold text-slate-100">The three gates</h2>
            <ul className="mt-3 space-y-3 text-sm">
              <Gate
                label="Setup complete"
                done={row.ready_to_approve}
                detail={
                  row.ready_to_approve
                    ? `${row.portfolio_photo_count} photos, ${row.active_packages} package(s)`
                    : `Missing: ${row.missing.map(humanise).join(", ")}`
                }
              />
              <Gate
                label="Identity and listing"
                done={alreadyLive}
                detail={alreadyLive ? "Approved and published" : "Approving clears both at once"}
              />
              {/* Deliberately not actionable here. Bank details belong to the
                  photographer; entering them on their behalf would put
                  whoever runs this panel in the middle of other people's
                  financial data. */}
              <Gate
                label="Payout method"
                done={!row.payout_blocked}
                detail={
                  row.payout_blocked
                    ? `${detail.payout_account_status.replace(/_/g, " ")} — they set this up in the app`
                    : "Ready"
                }
              />
            </ul>
          </Panel>

          <Panel className="p-4">
            <h2 className="text-sm font-semibold text-slate-100">Decision</h2>
            {result ? (
              <div className="mt-3">
                <Notice tone="success">{result}</Notice>
              </div>
            ) : null}
            <div className="mt-3 flex flex-wrap gap-2">
              <AdminButton disabled={!row.ready_to_approve || alreadyLive} onClick={() => setDialog("approve")}>
                {alreadyLive ? "Already approved" : "Approve…"}
              </AdminButton>
              <AdminButton tone="secondary" onClick={() => setDialog("reject")}>
                Reject…
              </AdminButton>
            </div>
            {!row.ready_to_approve ? (
              <p className="mt-2 text-xs text-slate-500">They have not finished setting up, so there is nothing to approve yet.</p>
            ) : null}
          </Panel>
        </div>
      </div>

      <NicheTiers proId={proId} name={name} />

      <Findings proId={proId} />

      <ConfirmDialog
        open={dialog === "approve"}
        title={`Approve ${name}?`}
        confirmLabel="Approve and publish"
        onClose={() => setDialog(null)}
        onConfirm={async () => {
          const res = await admin.approvePro(proId);
          if (!res.ok) return res.error.message;
          setResult(
            res.data.payout_blocked
              ? "Approved and live. They still have no payout method, so they cannot withdraw yet."
              : "Approved and live."
          );
          queryClient.invalidateQueries({ queryKey: ["admin"] });
          return null;
        }}
      >
        <p>
          Their identity is marked approved and their listing goes public: clients in {row.city || "their city"} can
          find and book them straight away.
        </p>
        {row.payout_blocked ? <p className="text-amber-300">They have no payout method yet, so they cannot withdraw until they add one.</p> : null}
      </ConfirmDialog>

      <ConfirmDialog
        open={dialog === "reject"}
        title={`Reject ${name}?`}
        confirmLabel="Reject"
        tone="danger"
        reason={{ label: "Reason — the photographer reads this", placeholder: "What they need to change" }}
        onClose={() => setDialog(null)}
        onConfirm={async (reason) => {
          const res = await admin.rejectPro(proId, reason);
          if (!res.ok) return res.error.message;
          queryClient.invalidateQueries({ queryKey: ["admin"] });
          router.push("/admin");
          return null;
        }}
      >
        <p>They will not be listed, and they see your reason.</p>
      </ConfirmDialog>
    </>
  );
}

function Gate({ label, done, detail }: { label: string; done: boolean; detail: string }) {
  return (
    <li className="flex gap-3">
      <span aria-hidden className={done ? "text-emerald-400" : "text-slate-600"}>
        {done ? "✓" : "○"}
      </span>
      <span className="flex-1">
        <span className="block font-medium text-slate-100">
          {label}
          <span className="sr-only">{done ? " (done)" : " (not done)"}</span>
        </span>
        <span className="block text-xs text-slate-500">{detail}</span>
      </span>
    </li>
  );
}

/**
 * Tier per niche: what is in force, what the evidence alone says, and the
 * admin override behind any difference - who set it, when and why.
 *
 * An override lasts until someone removes it here; recomputes and
 * rebuild-all keep it and keep working out the evidence beside it. Where the
 * two disagree it says so, because an override nobody remembers setting is
 * how a photographer ends up priced at a tier their work does not support.
 * Setting and removing both ask for a reason, kept in the audit log.
 */
function NicheTiers({ proId, name }: { proId: string; name: string }) {
  const queryClient = useQueryClient();
  const [setting, setSetting] = useState<NicheSkillRow | null>(null);
  const [removing, setRemoving] = useState<NicheSkillRow | null>(null);
  const [tier, setTier] = useState<SkillTier>("pro");
  const skills = useQuery({ queryKey: ["admin", "niche-skills", proId], queryFn: () => admin.nicheSkills(proId) });
  const refresh = () => queryClient.invalidateQueries({ queryKey: ["admin", "niche-skills", proId] });
  const rows = skills.data?.ok ? skills.data.data.items : [];

  return (
    <Panel className="mt-4 p-4">
      <h2 className="text-sm font-semibold text-slate-100">Niche tiers</h2>
      <p className="mt-1 text-xs text-slate-400">
        Tiers from evidence change at most once a week in either direction (seven-day hysteresis). An override takes
        effect at once, bypasses that wait, and stays until it is removed; removing it returns to the evidence tier at once.
      </p>
      {skills.isLoading ? <div className="mt-3 h-16 animate-pulse rounded bg-white/[0.04]" /> : null}
      {skills.data && !skills.data.ok ? (
        <div className="mt-3">
          <Notice tone="error">Could not load tiers: {skills.data.error.message}</Notice>
        </div>
      ) : null}
      {skills.data?.ok && rows.length === 0 ? <p className="mt-2 text-sm text-slate-400">No niches yet.</p> : null}
      <ul className="mt-3 divide-y divide-white/[0.06]">
        {rows.map((row) => (
          <li key={row.niche_slug} className="flex flex-wrap items-start justify-between gap-3 py-3">
            <div className="min-w-0">
              <p className="text-sm text-slate-100">
                {row.niche_name} · <span className="font-semibold">{humanise(row.tier)}</span>
                {row.active_override ? <span className="ml-2"><StatusBadge tone="info" label="Admin override" /></span> : null}
              </p>
              {row.active_override ? (
                <p className="mt-1 text-xs text-slate-400">
                  Set {row.active_override.at ? new Date(row.active_override.at).toLocaleDateString() : ""} — “{row.active_override.reason}”
                </p>
              ) : null}
              {row.evidence_disagrees && row.evidence_tier ? (
                <p className="mt-1 text-xs text-amber-300">
                  The evidence alone says {humanise(row.evidence_tier)} ({row.gigs_completed} completed gigs
                  {row.verified ? ", verified" : ", not verified"}).
                </p>
              ) : null}
            </div>
            <div className="flex gap-2">
              <AdminButton
                tone="secondary"
                onClick={() => {
                  setTier(row.active_override?.tier ?? row.tier);
                  setSetting(row);
                }}
              >
                {row.active_override ? "Change…" : "Override…"}
              </AdminButton>
              {row.active_override ? (
                <AdminButton tone="secondary" onClick={() => setRemoving(row)}>
                  Remove override…
                </AdminButton>
              ) : null}
            </div>
          </li>
        ))}
      </ul>

      <ConfirmDialog
        open={setting !== null}
        title={setting ? `Set ${name}'s ${setting.niche_name} tier` : ""}
        confirmLabel="Set tier"
        reason={{ label: "Reason — kept in the audit log", placeholder: "e.g. Portfolio reviewed by the team" }}
        onClose={() => setSetting(null)}
        onConfirm={async (reason) => {
          if (!setting) return null;
          const res = await admin.setTierOverride(proId, setting.niche_id, tier, reason);
          if (!res.ok) return res.error.message;
          refresh();
          return null;
        }}
      >
        <label className="block text-sm text-slate-300">
          Tier
          <select
            className="mt-1 block w-full rounded border border-white/10 bg-transparent p-2"
            value={tier}
            onChange={(e) => setTier(e.target.value as SkillTier)}
          >
            {SKILL_TIERS.map((t) => (
              <option key={t} value={t}>
                {humanise(t)}
              </option>
            ))}
          </select>
        </label>
        <p className="mt-2">It stays in force until someone removes it here. Recomputes keep it.</p>
      </ConfirmDialog>

      <ConfirmDialog
        open={removing !== null}
        title={removing ? `Remove the override on ${name}'s ${removing.niche_name} tier?` : ""}
        confirmLabel="Remove override"
        tone="danger"
        reason={{ label: "Reason — kept in the audit log", placeholder: "e.g. Evidence has caught up" }}
        onClose={() => setRemoving(null)}
        onConfirm={async (reason) => {
          if (!removing) return null;
          const res = await admin.removeTierOverride(proId, removing.niche_id, reason);
          if (!res.ok) return res.error.message;
          refresh();
          return null;
        }}
      >
        <p>
          Their tier goes to what the evidence says
          {removing?.evidence_tier ? ` — ${humanise(removing.evidence_tier)}` : ""} — straight away.
        </p>
      </ConfirmDialog>
    </Panel>
  );
}
