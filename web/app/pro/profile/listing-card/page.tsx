"use client";

import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Badge, BottomSheet, Button, Card, EmptyState, Input, Tabs } from "@/design-system/primitives";
import { ProListingCard } from "@/components/discover/pro-listing-card";
import { pro as proApi } from "@/lib/api/pro";
import { discovery } from "@/lib/api/discovery";
import { useAuth } from "@/lib/auth/store";

function normalizeTags(tags: string[]) {
  return [...new Set(tags)].slice(0, 5);
}

export default function ListingCardEditorPage() {
  const { accessToken, userId } = useAuth();
  const [headline, setHeadline] = useState("");
  const [coverMediaAssetId, setCoverMediaAssetId] = useState("");
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [previewMode, setPreviewMode] = useState<"list" | "grid">("list");
  const [verifyOpen, setVerifyOpen] = useState(false);

  const profileQ = useQuery({ queryKey: ["my-pro-profile"], queryFn: () => proApi.myProProfile(accessToken), enabled: !!accessToken });
  const nichesQ = useQuery({ queryKey: ["my-niches"], queryFn: () => proApi.getMyNiches(accessToken), enabled: !!accessToken });
  const catalogQ = useQuery({ queryKey: ["niches-catalog"], queryFn: () => discovery.getNichesCatalog(accessToken), enabled: !!accessToken });
  const publicQ = useQuery({
    queryKey: ["public-pro-profile", userId],
    queryFn: () => discovery.getPublicProProfile(userId!, accessToken),
    enabled: !!accessToken && !!userId,
  });

  const profileData = profileQ.data?.ok ? profileQ.data.data : null;
  const nichesData = nichesQ.data?.ok ? nichesQ.data.data : null;
  const publicData = publicQ.data?.ok ? publicQ.data.data : null;

  useEffect(() => {
    if (!profileData || !nichesData) return;
    setHeadline(profileData.headline || "");
    setCoverMediaAssetId(profileData.cover_media_asset_id || "");
    setSelectedTags(nichesData.niches.map((item) => item.slug));
  }, [profileData, nichesData]);

  const minPackage = useMemo(() => {
    const packages = publicData?.packages || [];
    if (!packages.length) return null;
    return [...packages].sort((a, b) => a.price - b.price)[0];
  }, [publicData]);

  const previewData = useMemo(() => {
    return {
      proUserId: userId || profileData?.user_id || "unknown",
      displayName: profileData?.display_name,
      headline,
      coverMediaAssetId: coverMediaAssetId || null,
      city: profileData?.city,
      country: profileData?.country,
      tags: normalizeTags(selectedTags),
      fromPrice: minPackage?.price ?? null,
      currency: minPackage?.currency ?? "EUR",
      avgRating: publicData?.avg_rating,
      reviewCount: publicData?.review_count,
    };
  }, [userId, profileData, headline, coverMediaAssetId, selectedTags, minPackage, publicData]);

  const baseline = useMemo(() => {
    if (!profileData || !nichesData) return null;
    return {
      headline: profileData.headline || "",
      coverMediaAssetId: profileData.cover_media_asset_id || "",
      tags: normalizeTags(nichesData.niches.map((item) => item.slug)),
    };
  }, [profileData, nichesData]);

  const dirty = useMemo(() => {
    if (!baseline) return false;
    const tagA = normalizeTags(selectedTags).sort().join(",");
    const tagB = baseline.tags.sort().join(",");
    return headline !== baseline.headline || coverMediaAssetId !== baseline.coverMediaAssetId || tagA !== tagB;
  }, [baseline, headline, coverMediaAssetId, selectedTags]);

  const saveMutation = useMutation({
    mutationFn: async () => {
      if (!profileData || !nichesData) return { ok: false as const, error: { kind: "unknown" as const, code: "no_baseline", message: "Profile not loaded yet." } };
      const profileResult = await proApi.updateMyProProfile(
        {
          headline: headline.trim() || null,
          cover_media_asset_id: coverMediaAssetId.trim() || null,
        },
        accessToken,
      );
      if (!profileResult.ok) return profileResult;

      const previousBySlug = new Map(nichesData.niches.map((n) => [n.slug, n]));
      const normalized = normalizeTags(selectedTags);
      return proApi.updateMyNiches(
        {
          primary_niche_slug: normalized[0] || null,
          niches: normalized.map((slug, idx) => ({
            slug,
            declared_level: previousBySlug.get(slug)?.declared_level || null,
            is_primary: idx === 0,
          })),
        },
        accessToken,
      );
    },
    onSuccess: async (result) => {
      if (!result.ok) return;
      await Promise.all([profileQ.refetch(), nichesQ.refetch(), publicQ.refetch()]);
    },
  });

  const verifyQ = useQuery({
    queryKey: ["verify-public", userId, verifyOpen],
    queryFn: async () => {
      const pub = await discovery.getPublicProProfile(userId!, accessToken);
      if (!pub.ok) throw new Error(pub.error.message || "Could not load public profile.");
      const search = await discovery.searchPros({ limit: 50, city: pub.data.city || undefined, country: pub.data.country || undefined }, accessToken);
      if (!search.ok) throw new Error(search.error.message || "Could not load search results.");
      return { pub: pub.data, search: search.data.items.find((item) => item.id === userId) || null };
    },
    enabled: verifyOpen && !!userId && !!accessToken,
  });

  if (!accessToken) return <EmptyState title="Sign in required" body="Please sign in as a pro user." />;
  if (profileQ.isLoading || nichesQ.isLoading || catalogQ.isLoading || publicQ.isLoading) return <Card>Loading listing card data...</Card>;
  if (!profileData || !nichesData || !catalogQ.data?.ok || !publicData) return <EmptyState title="Failed to load" body="Could not load listing card sources." />;

  const availableTags = (catalogQ.data.data || []).filter((n) => n.is_active);

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Listing Card</h1>

      <Card className="space-y-3">
        <h2 className="text-base font-semibold">What clients see</h2>
        <div className="space-y-1">
          <label className="text-sm font-medium">Headline</label>
          <Input value={headline} maxLength={80} onChange={(e) => setHeadline(e.target.value)} placeholder="Add a short, specific headline" />
          <p className="text-xs text-neutral-500">{headline.length}/80</p>
        </div>

        <div className="space-y-1">
          <label className="text-sm font-medium">Cover image media asset ID</label>
          <Input value={coverMediaAssetId} onChange={(e) => setCoverMediaAssetId(e.target.value)} placeholder="Paste a portfolio media_asset_id" />
        </div>

        <div className="space-y-2">
          <p className="text-sm font-medium">Tags (max 5)</p>
          <div className="flex flex-wrap gap-2">
            {availableTags.map((tag) => {
              const active = selectedTags.includes(tag.slug);
              return (
                <button
                  key={tag.slug}
                  type="button"
                  className={`rounded-full border px-3 py-1 text-xs ${active ? "border-brand-600 bg-brand-50 text-brand-700" : "border-neutral-300 bg-white text-neutral-700"}`}
                  onClick={() => {
                    if (active) {
                      setSelectedTags((prev) => prev.filter((x) => x !== tag.slug));
                      return;
                    }
                    setSelectedTags((prev) => normalizeTags([...prev, tag.slug]));
                  }}
                >
                  {tag.name}
                </button>
              );
            })}
          </div>
        </div>

        <div className="rounded-md bg-neutral-50 p-3">
          <p className="text-sm font-medium">Pricing preview</p>
          {minPackage ? (
            <div className="mt-1 space-y-1 text-sm text-neutral-700">
              <p>Base package: {minPackage.currency} {Math.round(minPackage.price)}</p>
              <p>Extra image: {minPackage.currency} {Math.round(minPackage.extra_photo_price)} / photo</p>
              <p>Included photos: {minPackage.included_photos}</p>
            </div>
          ) : (
            <p className="mt-1 text-sm text-neutral-600">No active packages yet.</p>
          )}
          <a className="mt-2 inline-block text-sm text-brand-700 underline" href="/pro/onboarding">Edit Pricing</a>
        </div>

        {dirty ? (
          <Button disabled={saveMutation.isPending} onClick={() => saveMutation.mutate()}>
            {saveMutation.isPending ? "Saving..." : "Save"}
          </Button>
        ) : null}
        {saveMutation.data && !saveMutation.data.ok ? (
          <p className="text-sm text-red-700">{saveMutation.data.error.message || "Couldn't save. Try again."}</p>
        ) : null}
      </Card>

      <Card className="space-y-3">
        <h2 className="text-base font-semibold">Live preview</h2>
        <Tabs tabs={["list", "grid"]} active={previewMode} onChange={(value) => setPreviewMode(value as "list" | "grid")} />
        {previewMode === "grid" ? (
          <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
            <ProListingCard item={previewData} mode="grid" />
            <ProListingCard item={previewData} mode="grid" />
          </div>
        ) : (
          <div className="space-y-3">
            <ProListingCard item={previewData} mode="list" />
            <ProListingCard item={previewData} mode="list" />
          </div>
        )}
      </Card>

      <Card className="space-y-2">
        <h2 className="text-base font-semibold">Verify Public View</h2>
        <p className="text-sm text-neutral-600">Compare your draft with the latest public profile and search data.</p>
        <Button onClick={() => setVerifyOpen(true)}>Verify Public View</Button>
      </Card>

      <BottomSheet open={verifyOpen} title="Public view verification" onClose={() => setVerifyOpen(false)}>
        {verifyQ.isLoading ? <p className="text-sm">Loading...</p> : null}
        {verifyQ.error ? <p className="text-sm text-red-600">Verification failed.</p> : null}
        {verifyQ.data ? (
          <div className="space-y-3 text-sm">
            <div>
              <p className="font-medium">/v1/pros/{userId}/public</p>
              <pre className="max-h-48 overflow-auto rounded bg-neutral-100 p-2 text-xs">{JSON.stringify(verifyQ.data.pub, null, 2)}</pre>
            </div>
            <div>
              <p className="font-medium">/v1/search/pros match</p>
              <pre className="max-h-48 overflow-auto rounded bg-neutral-100 p-2 text-xs">{JSON.stringify(verifyQ.data.search, null, 2)}</pre>
            </div>
            <div className="rounded bg-neutral-100 p-2">
              <p className="font-medium">Draft vs Public</p>
              <p>Headline: <Badge>{headline === (verifyQ.data.pub.headline || "") ? "match" : "diff"}</Badge></p>
              <p>Cover: <Badge>{(coverMediaAssetId || "") === (verifyQ.data.pub.cover_media_asset_id || "") ? "match" : "diff"}</Badge></p>
              <p>Tags: <Badge>{normalizeTags(selectedTags).sort().join(",") === normalizeTags((verifyQ.data.search?.niche_slugs || [])).sort().join(",") ? "match" : "diff"}</Badge></p>
            </div>
          </div>
        ) : null}
      </BottomSheet>
    </div>
  );
}
