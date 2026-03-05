"use client";

import { Badge, Card } from "@/design-system/primitives";

export type ProListingCardData = {
  proUserId: string;
  displayName?: string | null;
  headline?: string | null;
  coverMediaAssetId?: string | null;
  city?: string | null;
  country?: string | null;
  tags?: string[];
  fromPrice?: number | null;
  currency?: string | null;
  avgRating?: number | null;
  reviewCount?: number | null;
};

export function ProListingCard({ item, mode = "list" }: { item: ProListingCardData; mode?: "list" | "grid" }) {
  const fromPrice = item.fromPrice != null ? `${item.currency ?? "EUR"} ${Math.round(item.fromPrice)}` : "Price unavailable";
  const tags = (item.tags ?? []).slice(0, 5);

  return (
    <Card className={mode === "grid" ? "h-full" : undefined}>
      <div className="space-y-2">
        <div className="flex items-center justify-between gap-2">
          <p className="text-base font-semibold">{item.displayName || `Pro ${item.proUserId.slice(0, 8)}`}</p>
          <Badge>{`From ${fromPrice}`}</Badge>
        </div>
        <p className="text-sm text-neutral-600">{item.headline || "No headline yet"}</p>
        <p className="text-xs text-neutral-500">{item.city || "Unknown city"}, {item.country || "Unknown"}</p>
        {item.coverMediaAssetId ? <p className="text-xs text-neutral-500">Cover media: {item.coverMediaAssetId.slice(0, 8)}...</p> : null}
        {tags.length ? (
          <div className="flex flex-wrap gap-1">
            {tags.map((tag) => (
              <Badge key={tag} className="bg-neutral-100 text-neutral-700">{tag}</Badge>
            ))}
          </div>
        ) : null}
        <p className="text-xs text-neutral-500">
          {item.avgRating != null ? item.avgRating.toFixed(1) : "-"} rating • {item.reviewCount ?? 0} reviews
        </p>
      </div>
    </Card>
  );
}
