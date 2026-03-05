"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { ProListingCard } from "@/components/discover/pro-listing-card";
import { endpoints } from "@/lib/api/endpoints";
import { useAuth } from "@/lib/auth/store";
import { Flag } from "@/lib/flags/provider";

export default function DiscoverPage() {
  const { accessToken } = useAuth();
  const { data, isLoading, error } = useQuery({ queryKey: ["discover"], queryFn: () => endpoints.discover(accessToken), staleTime: 30_000 });

  if (isLoading) return <Skeleton className="h-24 w-full" />;
  if (error) return <EmptyState title="Discover unavailable" body="Please try again." />;
  if (!data?.items?.length) return <EmptyState title="No pros yet" body="Check back soon." />;

  return (
    <Flag name="client_discovery_enabled" fallback={<EmptyState title="Discovery disabled" />}>
      <div className="space-y-3">
        <h1 className="text-xl font-semibold">Discover</h1>
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
    </Flag>
  );
}
