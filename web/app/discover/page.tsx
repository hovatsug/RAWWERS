"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { EmptyState, GlowOrbs, Skeleton } from "@/design-system/primitives";
import { ProListingCard } from "@/components/discover/pro-listing-card";
import { endpoints } from "@/lib/api/endpoints";
import { useAuth } from "@/lib/auth/store";
import { Flag } from "@/lib/flags/provider";

export default function DiscoverPage() {
  const { accessToken } = useAuth();
  const { data, isLoading, error } = useQuery({ queryKey: ["discover"], queryFn: () => endpoints.discover(accessToken), staleTime: 30_000 });

  if (isLoading) return (
    <div className="space-y-3">
      <GlowOrbs variant="discovery" />
      <Skeleton className="h-8 w-40" />
      <Skeleton className="h-32 w-full" />
      <Skeleton className="h-32 w-full" />
      <Skeleton className="h-32 w-full" />
    </div>
  );
  if (error) return <EmptyState title="Discover unavailable" body="Please try again." />;
  if (!data?.items?.length) return <EmptyState title="No pros yet" body="Check back soon." />;

  return (
    <Flag name="client_discovery_enabled" fallback={<EmptyState title="Discovery disabled" />}>
      <GlowOrbs variant="discovery" />
      <div className="relative space-y-4">
        <div>
          <h1 className="text-2xl font-bold text-white">Discover</h1>
          <p className="mt-1 text-sm text-slate-400">Find your perfect creative professional</p>
        </div>
        <div className="space-y-3">
          {data.items.map((item) => (
            <Link key={item.pro_user_id} href={`/pros/${item.pro_user_id}`}>
              <ProListingCard
                item={{
                  proUserId: item.pro_user_id,
                  displayName: `Pro ${item.pro_user_id.slice(0, 8)}`,
                  city: item.city,
                  country: item.country,
                }}
              />
            </Link>
          ))}
        </div>
      </div>
    </Flag>
  );
}
