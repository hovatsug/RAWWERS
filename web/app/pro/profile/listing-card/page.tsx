"use client";

import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Badge, BottomSheet, Button, Card, EmptyState, Input, Tabs } from "@/design-system/primitives";
import { ProListingCard } from "@/components/discover/pro-listing-card";
import { endpoints } from "@/lib/api/endpoints";
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

  const profileQ = useQuery({ queryKey: ["my-pro-profile"], queryFn: () => endpoints.myProProfile(accessToken), enabled: !!accessToken });
  const nichesQ = useQuery({ queryKey: ["my-niches"], queryFn: () => endpoints.myNiches(accessToken), enabled: !!accessToken });
  const catalogQ = useQuery({ queryKey: ["niches-catalog"], queryFn: () => endpoints.nichesCatalog(accessToken), enabled: !!accessToken });
  const publicQ = useQuery({
    queryKey: ["public-pro-profile", userId],
    queryFn: () => endpoints.publicProProfile(userId!, accessToken),
    enabled: !!accessToken && !!userId,
  });

  useEffect(() => {
    if (!profileQ.data || !nichesQ.data) return;
    setHeadline(profileQ.data.headline || "");
    setCoverMediaAssetId(profileQ.data.cover_media_asset_id || "");
    setSelectedTags(nichesQ.data.niches.map((item) => item.slug));
  }, [profileQ.data, nichesQ.data]);

  const minPackage = useMemo(() => {
    const packages = publicQ.data?.packages || [];
    if (!packages.length) return null;
    return [...packages].sort((a, b) => a.price - b.price)[0];
  }, [publicQ.data]);

  const previewData = useMemo(() => {
    return {
      proUserId: userId || profileQ.data?.user_id || "unknown",
      displayName: profileQ.data?.display_name,
      headline,
      coverMediaAssetId: coverMediaAssetId || null,
      city: profileQ.data?.city,
      country: profileQ.data?.country,
      tags: normalizeTags(selectedTags),
      fromPrice: minPackage?.price ?? null,
      currency: minPackage?.currency ?? "EUR",
      avgRating: publicQ.data?.avg_rating,
      reviewCount: publicQ.data?.review_count,
    };
  }, [userId, profileQ.data, headline, coverMediaAssetId, selectedTags, minPackage, publicQ.data]);

  const baseline = useMemo(() => {
    if (!profileQ.data || !nichesQ.data) return null;
    return {
      headline: profileQ.data.headline || "",
      coverMediaAssetId: profileQ.data.cover_media_asset_id || "",
      tags: normalizeTags(nichesQ.data.niches.map((item) => item.slug)),
    };
  }, [profileQ.data, nichesQ.data]);

  const dirty = useMemo(() => {
    if (!baseline) return false;
    const tagA = normalizeTags(selectedTags).sort().join(",");
    const tagB = baseline.tags.sort().join(",");
    return headline !== baseline.headline || coverMediaAssetId !== baseline.coverMediaAssetId || tagA !== tagB;
  }, [baseline, headline, coverMediaAssetId, selectedTags]);

  const saveMutation = useMutation({
    mutationFn: async () => {
      if (!profileQ.data || !nichesQ.data) return;
      await endpoints.updateMyProProfile(
        {
          headline: headline.trim() || null,
          cover_media_asset_id: coverMediaAssetId.trim() || null,
        },
        accessToken,
      );

      const previousBySlug = new Map(nichesQ.data.niches.map((n) => [n.slug, n]));
      const normalized = normalizeTags(selectedTags);
      await endpoints.updateMyNiches(
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
    onSuccess: async () => {
      await Promise.all([profileQ.refetch(), nichesQ.refetch(), publicQ.refetch()]);
    },
  });

  const verifyQ = useQuery({
    queryKey: ["verify-public", userId, verifyOpen],
    queryFn: async () => {
      const pub = await endpoints.publicProProfile(userId!, accessToken);
      const search = await endpoints.searchPros({ limit: 50, city: pub.city || undefined, country: pub.country || undefined }, accessToken);
      return { pub, search: search.items.find((item) => item.id === userId) || null };
    },
    enabled: verifyOpen && !!userId && !!accessToken,
  });

  if (!accessToken) return <EmptyState title="Sign in required" body="Please sign in as a pro user." />;
  if (profileQ.isLoading || nichesQ.isLoading || catalogQ.isLoading || publicQ.isLoading) return <Card>Loading listing card data...</Card>;
  if (profileQ.error || nichesQ.error || catalogQ.error || publicQ.error) return <EmptyState title="Failed to load" body="Could not load listing card sources." />;

  const availableTags = (catalogQ.data || []).filter((n) => n.is_active);

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
