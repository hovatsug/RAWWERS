"use client";

import { useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Badge, Button, Card, Skeleton, Textarea } from "@/design-system/primitives";
import { admin } from "@/lib/api/admin";
import { humanise } from "@/app/admin/labels";

/**
 * One photographer, and the decision.
 *
 * Approving is a single action that clears both gates the backend
 * requires - identity and public listing - because doing them separately
 * leaves people approved but invisible, which nobody notices until they
 * ask why no requests arrive.
 */
export default function AdminProReviewPage() {
  const { proId } = useParams<{ proId: string }>();
  const router = useRouter();
  const queryClient = useQueryClient();
  const [note, setNote] = useState("");
  const [result, setResult] = useState<string | null>(null);
  const [failure, setFailure] = useState<string | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["admin", "review", proId],
    queryFn: () => admin.reviewDetail(proId)
  });

  const approve = useMutation({
    mutationFn: () => admin.approvePro(proId, note.trim() || undefined),
    onSuccess: (res) => {
      if (!res.ok) {
        setFailure(res.error.message);
        return;
      }
      setFailure(null);
      setResult(
        res.data.payout_blocked
          ? "Approved and live. They still have no payout method, so they cannot withdraw yet."
          : "Approved and live."
      );
      queryClient.invalidateQueries({ queryKey: ["admin"] });
    }
  });

  const reject = useMutation({
    mutationFn: () => admin.rejectPro(proId, note.trim() || "Not approved"),
    onSuccess: (res) => {
      if (!res.ok) {
        setFailure(res.error.message);
        return;
      }
      queryClient.invalidateQueries({ queryKey: ["admin"] });
      router.push("/admin");
    }
  });

  if (isLoading) return <Skeleton className="h-64 w-full" />;
  if (!data?.ok) {
    return (
      <Card>
        <p className="text-sm">Could not load this photographer.</p>
        <p className="mt-1 text-xs text-neutral-600">{data && !data.ok ? data.error.message : ""}</p>
      </Card>
    );
  }

  const { row, packages, portfolio_urls: portfolio } = data.data;
  const alreadyLive = row.onboarding_status === "approved_public" && row.kyc_status === "approved";

  return (
    <div className="space-y-5">
      <Link href="/admin" className="text-sm text-neutral-500 hover:underline">
        ← Queue
      </Link>

      <div className="flex flex-wrap items-center gap-3">
        <h1 className="text-xl font-semibold">{row.display_name || "Unnamed"}</h1>
        {alreadyLive ? <Badge variant="emerald">Live</Badge> : <Badge variant="amber">Not live</Badge>}
        {row.payout_blocked ? <Badge variant="amber">No payout method</Badge> : null}
      </div>
      {row.headline ? <p className="text-sm text-neutral-400">{row.headline}</p> : null}

      <Card>
        <h2 className="text-sm font-semibold">The three gates</h2>
        <ul className="mt-3 space-y-2 text-sm">
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
            detail={alreadyLive ? "Approved and published" : "Approving below clears both at once"}
          />
          {/* Deliberately not actionable here. The bank details belong to
              the photographer; entering them on their behalf would put
              whoever runs this panel in the middle of other people's
              financial data. */}
          <Gate
            label="Payout method"
            done={!row.payout_blocked}
            detail={
              row.payout_blocked
                ? `${data.data.payout_account_status} — they set this up in the app; you cannot do it for them`
                : "Ready"
            }
          />
        </ul>
      </Card>

      <Card>
        <h2 className="text-sm font-semibold">What a client would see</h2>
        <div className="mt-3 grid grid-cols-4 gap-2 sm:grid-cols-6">
          {portfolio.slice(0, 12).map((url, i) => (
            // eslint-disable-next-line @next/next/no-img-element
            <img key={i} src={url} alt="" className="aspect-square w-full rounded object-cover" />
          ))}
        </div>
        <dl className="mt-4 space-y-1 text-sm">
          <Row label="Where" value={[row.city, row.country].filter(Boolean).join(", ") || "—"} />
          <Row label="Travels" value={data.data.travel_radius_km ? `${data.data.travel_radius_km} km` : "Not said"} />
          <Row label="Styles" value={data.data.styles.join(", ") || "—"} />
          <Row label="Languages" value={data.data.languages.join(", ") || "—"} />
        </dl>
        {data.data.bio ? <p className="mt-3 text-sm text-neutral-400">{data.data.bio}</p> : null}
        <div className="mt-4 space-y-1 text-sm">
          {packages.map((p) => (
            <p key={p.title}>
              {p.title} — {p.currency} {p.price}/photo, {p.included_photos} included, {p.duration_minutes} min ({p.niche_slug})
            </p>
          ))}
        </div>
      </Card>

      <Card>
        <h2 className="text-sm font-semibold">Decision</h2>
        <Textarea
          className="mt-3"
          placeholder="Note (optional for approval, shown on rejection)"
          value={note}
          onChange={(e) => setNote(e.target.value)}
          rows={2}
        />
        {failure ? <p className="mt-2 text-sm text-amber-400">{failure}</p> : null}
        {result ? <p className="mt-2 text-sm text-emerald-400">{result}</p> : null}
        <div className="mt-3 flex gap-2">
          <Button
            onClick={() => approve.mutate()}
            disabled={!row.ready_to_approve || approve.isPending || alreadyLive}
          >
            {alreadyLive ? "Already approved" : approve.isPending ? "Approving…" : "Approve this photographer"}
          </Button>
          <Button variant="ghost" onClick={() => reject.mutate()} disabled={reject.isPending}>
            Reject
          </Button>
        </div>
        {!row.ready_to_approve ? (
          <p className="mt-2 text-xs text-neutral-500">
            They have not finished setting up, so there is nothing to approve yet.
          </p>
        ) : null}
      </Card>
    </div>
  );
}

function Gate({ label, done, detail }: { label: string; done: boolean; detail: string }) {
  return (
    <li className="flex gap-3">
      <span className={done ? "text-emerald-400" : "text-neutral-500"}>{done ? "✓" : "○"}</span>
      <span className="flex-1">
        <span className="font-medium">{label}</span>
        <span className="ml-2 text-neutral-500">{detail}</span>
      </span>
    </li>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex gap-3">
      <dt className="w-24 flex-none text-neutral-500">{label}</dt>
      <dd>{value}</dd>
    </div>
  );
}
