"use client";

import { useQuery } from "@tanstack/react-query";
import { Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { proApi } from "@/lib/api/proApi";

export default function ProProfilePage() {
  const { accessToken } = useAuth();
  const profileQ = useQuery({ queryKey: ["pro", "profile-summary"], queryFn: () => proApi.getMyProProfile(accessToken), enabled: !!accessToken });
  if (profileQ.isLoading) return <Skeleton className="h-24" />;
  if (!profileQ.data?.ok) return <EmptyState title="Profile unavailable" />;

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Profile</h1>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(profileQ.data.data, null, 2)}</pre></Card>
      <div className="flex gap-3 text-sm">
        <a href="/pro/profile/listing-card" className="text-brand-700 underline">Listing card</a>
        <a href="/pro/profile/packages" className="text-brand-700 underline">Packages</a>
        <a href="/pro/profile/portfolio" className="text-brand-700 underline">Portfolio</a>
      </div>
    </div>
  );
}
