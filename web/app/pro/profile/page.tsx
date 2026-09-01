"use client";

import { useEffect, useMemo, useState, type ReactNode } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ChipInput,
  EditorialButton,
  EditorialCard,
  EditorialInput,
  EditorialTextarea,
  ProgressRing,
  StatusPill,
  Toast,
} from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { proApi } from "@/lib/api/proApi";

type ProProfile = {
  user_id: string;
  display_name: string | null;
  headline: string | null;
  cover_media_asset_id: string | null;
  bio: string | null;
  city: string | null;
  country: string | null;
  languages: string[];
  styles: string[];
  gear: { camera?: string; lenses?: string[]; [key: string]: unknown };
  is_accepting_bookings: boolean;
  completeness_score: number;
  kyc_status: "unsubmitted" | "pending" | "approved" | "rejected" | string;
};

const KYC_COPY: Record<string, { label: string; tone: "ok" | "warn" }> = {
  approved: { label: "Verified", tone: "ok" },
  pending: { label: "Verification in review", tone: "warn" },
  rejected: { label: "Verification needs attention", tone: "warn" },
  unsubmitted: { label: "Verification not started", tone: "warn" },
};

function CameraIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" className={className} aria-hidden>
      <path d="M4 8.5A1.5 1.5 0 0 1 5.5 7h2.13a1.5 1.5 0 0 0 1.28-.72l.7-1.16A1.5 1.5 0 0 1 10.9 4.4h2.2a1.5 1.5 0 0 1 1.28.72l.7 1.16A1.5 1.5 0 0 0 16.37 7H18.5A1.5 1.5 0 0 1 20 8.5v9A1.5 1.5 0 0 1 18.5 19h-13A1.5 1.5 0 0 1 4 17.5v-9Z" stroke="currentColor" strokeWidth="1.4" />
      <circle cx="12" cy="12.5" r="3.4" stroke="currentColor" strokeWidth="1.4" />
    </svg>
  );
}

function Field({ label, hint, children }: { label: string; hint?: string; children: ReactNode }) {
  return (
    <div className="space-y-1.5">
      <label className="text-xs font-medium uppercase tracking-wide text-muted">{label}</label>
      {children}
      {hint ? <p className="text-xs text-faint">{hint}</p> : null}
    </div>
  );
}

export default function ProProfilePage() {
  const { accessToken } = useAuth();
  const queryClient = useQueryClient();
  const profileQ = useQuery({
    queryKey: ["pro", "profile-summary"],
    queryFn: () => proApi.getMyProProfile(accessToken),
    enabled: !!accessToken,
  });

  const profile = profileQ.data?.ok ? (profileQ.data.data as ProProfile) : null;

  const [headline, setHeadline] = useState("");
  const [bio, setBio] = useState("");
  const [city, setCity] = useState("");
  const [country, setCountry] = useState("");
  const [languages, setLanguages] = useState<string[]>([]);
  const [styles, setStyles] = useState<string[]>([]);
  const [camera, setCamera] = useState("");
  const [lenses, setLenses] = useState<string[]>([]);
  const [coverAssetId, setCoverAssetId] = useState("");
  const [showCoverInput, setShowCoverInput] = useState(false);
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    if (!profile) return;
    setHeadline(profile.headline || "");
    setBio(profile.bio || "");
    setCity(profile.city || "");
    setCountry(profile.country || "");
    setLanguages(profile.languages || []);
    setStyles(profile.styles || []);
    setCamera(profile.gear?.camera || "");
    setLenses(profile.gear?.lenses || []);
    setCoverAssetId(profile.cover_media_asset_id || "");
  }, [profile]);

  const baseline = useMemo(() => {
    if (!profile) return null;
    return {
      headline: profile.headline || "",
      bio: profile.bio || "",
      city: profile.city || "",
      country: profile.country || "",
      languages: [...(profile.languages || [])].sort().join(","),
      styles: [...(profile.styles || [])].sort().join(","),
      camera: profile.gear?.camera || "",
      lenses: [...(profile.gear?.lenses || [])].sort().join(","),
      coverAssetId: profile.cover_media_asset_id || "",
    };
  }, [profile]);

  const dirty = useMemo(() => {
    if (!baseline) return false;
    return (
      headline !== baseline.headline ||
      bio !== baseline.bio ||
      city !== baseline.city ||
      country !== baseline.country ||
      [...languages].sort().join(",") !== baseline.languages ||
      [...styles].sort().join(",") !== baseline.styles ||
      camera !== baseline.camera ||
      [...lenses].sort().join(",") !== baseline.lenses ||
      coverAssetId !== baseline.coverAssetId
    );
  }, [baseline, headline, bio, city, country, languages, styles, camera, lenses, coverAssetId]);

  const saveMutation = useMutation({
    mutationFn: () =>
      proApi.updateMyProProfile(
        {
          headline: headline.trim() || null,
          bio: bio.trim() || null,
          city: city.trim() || null,
          country: country.trim() || null,
          languages,
          styles,
          cover_media_asset_id: coverAssetId.trim() || null,
          gear: { ...(profile?.gear || {}), camera: camera.trim() || undefined, lenses },
        },
        accessToken,
      ),
    onSuccess: async (result) => {
      if (!result.ok) {
        setToast(result.error.message || "Couldn't save your profile. Try again.");
        return;
      }
      await queryClient.invalidateQueries({ queryKey: ["pro", "profile-summary"] });
      setToast("Profile saved");
    },
  });

  useEffect(() => {
    if (!toast) return;
    const t = setTimeout(() => setToast(null), 3000);
    return () => clearTimeout(t);
  }, [toast]);

  if (!accessToken) {
    return (
      <div className="mx-auto max-w-lg py-10">
        <EditorialCard className="text-center">
          <p className="font-display text-xl text-ink">Sign in required</p>
          <p className="mt-2 text-sm text-muted">Sign in as a pro to view and edit your profile.</p>
        </EditorialCard>
      </div>
    );
  }

  if (profileQ.isLoading) {
    return (
      <div className="mx-auto max-w-2xl space-y-4 py-6">
        <div className="h-40 animate-pulse rounded-card bg-surface" />
        <div className="h-6 w-48 animate-pulse rounded-control bg-surface" />
        <div className="h-4 w-72 animate-pulse rounded-control bg-surface" />
        <div className="h-32 animate-pulse rounded-card bg-surface" />
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="mx-auto max-w-lg py-10">
        <EditorialCard className="text-center">
          <p className="font-display text-xl text-ink">Couldn't load your profile</p>
          <p className="mt-2 text-sm text-muted">Refresh the page, or try again in a moment.</p>
          <EditorialButton variant="ghost" className="mt-4" onClick={() => profileQ.refetch()}>
            Try again
          </EditorialButton>
        </EditorialCard>
      </div>
    );
  }

  const kyc = KYC_COPY[profile.kyc_status] ?? { label: profile.kyc_status, tone: "warn" as const };

  const missing: string[] = [];
  if (!profile.bio) missing.push("a bio");
  if (!profile.languages?.length) missing.push("languages");
  if (!profile.styles?.length) missing.push("shooting styles");
  if (!profile.gear?.camera) missing.push("your gear");
  if (!profile.cover_media_asset_id) missing.push("a cover photo");

  return (
    <div className="editorial-fade-up mx-auto max-w-2xl space-y-6 pb-28">
      {/* Cover */}
      {coverAssetId ? (
        <div className="relative flex aspect-[16/7] items-center justify-center overflow-hidden rounded-card border border-line bg-surface">
          <div className="flex flex-col items-center gap-2 text-muted">
            <CameraIcon className="h-6 w-6" />
            <span className="text-xs">Cover photo attached</span>
          </div>
          <button
            type="button"
            onClick={() => setShowCoverInput((v) => !v)}
            className="absolute bottom-3 right-3 rounded-control border border-line-2 bg-surface/80 px-3 py-1.5 text-xs font-medium text-ink hover:bg-surface-3 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent"
          >
            Replace
          </button>
        </div>
      ) : (
        <button
          type="button"
          onClick={() => setShowCoverInput(true)}
          className="flex aspect-[16/7] w-full flex-col items-center justify-center gap-2 rounded-card border border-dashed border-line-2 bg-surface text-center hover:bg-surface-2 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent"
        >
          <CameraIcon className="h-6 w-6 text-faint" />
          <span className="text-sm font-medium text-ink">Add a cover photo</span>
          <span className="max-w-xs text-xs text-faint">This is the first thing clients see — make it count.</span>
        </button>
      )}
      {showCoverInput ? (
        <div className="-mt-3 flex gap-2">
          <EditorialInput
            value={coverAssetId}
            onChange={(e) => setCoverAssetId(e.target.value)}
            placeholder="Paste a portfolio photo reference"
            className="flex-1"
          />
          <EditorialButton variant="ghost" onClick={() => setShowCoverInput(false)}>
            Done
          </EditorialButton>
        </div>
      ) : null}

      {/* Identity */}
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h1 className="font-display text-3xl text-ink">{profile.display_name || "Your profile"}</h1>
          <p className="mt-1 text-sm text-muted">
            {city || country ? [city, country].filter(Boolean).join(", ") : "Add your location below"}
          </p>
          <div className="mt-3 flex flex-wrap gap-2">
            <StatusPill tone={kyc.tone}>{kyc.label}</StatusPill>
            <StatusPill tone={profile.is_accepting_bookings ? "ok" : "neutral"}>
              {profile.is_accepting_bookings ? "Open for bookings" : "Not accepting bookings"}
            </StatusPill>
          </div>
        </div>
        <div className="flex flex-col items-center gap-1">
          <ProgressRing value={profile.completeness_score} label="strength" />
        </div>
      </div>
      {missing.length ? (
        <p className="text-xs text-faint">
          Add {missing.join(", ")} to strengthen your profile.
        </p>
      ) : null}

      <div className="h-px w-full bg-line" />

      {/* About */}
      <EditorialCard className="space-y-4">
        <Field label="Headline">
          <EditorialInput
            value={headline}
            maxLength={80}
            onChange={(e) => setHeadline(e.target.value)}
            placeholder="A short, specific line clients see first"
          />
        </Field>
        <Field
          label="Bio"
          hint={!bio ? "Clients read this before booking — a few sentences goes a long way." : undefined}
        >
          <EditorialTextarea
            rows={4}
            value={bio}
            onChange={(e) => setBio(e.target.value)}
            placeholder="Tell clients about your style and experience"
          />
        </Field>
        <div className="grid grid-cols-2 gap-3">
          <Field label="City">
            <EditorialInput value={city} onChange={(e) => setCity(e.target.value)} placeholder="Add your city" />
          </Field>
          <Field label="Country">
            <EditorialInput value={country} onChange={(e) => setCountry(e.target.value)} placeholder="Add your country" />
          </Field>
        </div>
      </EditorialCard>

      {/* Languages & styles */}
      <EditorialCard className="space-y-4">
        <Field
          label="Languages"
          hint={!languages.length ? "Add languages you speak so clients know before they book." : "Press Enter to add."}
        >
          <ChipInput values={languages} onChange={setLanguages} placeholder="Add a language" />
        </Field>
        <Field
          label="Shooting styles"
          hint={!styles.length ? "Add your styles so the right clients find you." : "Press Enter to add."}
        >
          <ChipInput values={styles} onChange={setStyles} placeholder="Add a style" />
        </Field>
      </EditorialCard>

      {/* Gear */}
      <EditorialCard className="space-y-4">
        <Field label="Camera body" hint={!camera ? "List your gear so clients know what to expect." : undefined}>
          <EditorialInput value={camera} onChange={(e) => setCamera(e.target.value)} placeholder="e.g. Sony A7IV" />
        </Field>
        <Field label="Lenses">
          <ChipInput values={lenses} onChange={setLenses} placeholder="Add a lens" />
        </Field>
      </EditorialCard>

      {/* Save bar */}
      <div className="fixed inset-x-0 bottom-0 z-40 border-t border-line bg-canvas/95 px-4 py-3 backdrop-blur">
        <div className="mx-auto flex max-w-2xl items-center justify-end gap-3">
          {saveMutation.isSuccess && !dirty ? <span className="text-xs text-ok">Saved</span> : null}
          <EditorialButton disabled={!dirty || saveMutation.isPending} onClick={() => saveMutation.mutate()}>
            {saveMutation.isPending ? "Saving profile…" : "Save profile"}
          </EditorialButton>
        </div>
      </div>

      {toast ? <Toast message={toast} /> : null}
    </div>
  );
}
