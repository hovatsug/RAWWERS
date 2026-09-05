"use client";

import { Badge, GlassCard } from "@/design-system/primitives";

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
  const fromPrice = item.fromPrice != null ? `${item.currency ?? "EUR"} ${Math.round(item.fromPrice)}` : null;
  const tags = (item.tags ?? []).slice(0, 5);

  return (
    <GlassCard className={`p-4 ${mode === "grid" ? "h-full" : ""}`}>
      {/* Inner accent orb */}
      <div className="pointer-events-none absolute -right-4 -top-4 h-24 w-24 rounded-full bg-violet-600/15 blur-2xl" />

      <div className="space-y-2">
        <div className="flex items-center justify-between gap-2">
          <div className="flex items-center gap-3">
            {/* Avatar placeholder */}
            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-gradient-to-br from-violet-600 to-blue-500 text-sm font-bold text-white shadow-glow-sm shrink-0">
              {(item.displayName ?? "P")[0].toUpperCase()}
            </div>
            <div>
              <p className="text-sm font-semibold text-white">
                {item.displayName || `Pro ${item.proUserId.slice(0, 8)}`}
              </p>
              <p className="text-xs text-slate-500">
                {item.city || "Unknown city"}, {item.country || "Unknown"}
              </p>
            </div>
          </div>
          {fromPrice ? (
            <Badge variant="violet">From {fromPrice}</Badge>
          ) : null}
        </div>

        {item.headline ? (
          <p className="text-sm text-slate-400 leading-relaxed">{item.headline}</p>
        ) : null}

        {tags.length ? (
          <div className="flex flex-wrap gap-1">
            {tags.map((tag) => (
              <Badge key={tag}>{tag}</Badge>
            ))}
          </div>
        ) : null}

        {item.avgRating != null ? (
          <div className="flex items-center gap-1.5">
            <span className="text-amber-400 text-xs">★</span>
            <span className="text-xs font-medium text-white">{item.avgRating.toFixed(1)}</span>
            <span className="text-xs text-slate-500">· {item.reviewCount ?? 0} reviews</span>
          </div>
        ) : null}
      </div>
    </GlassCard>
  );
}
