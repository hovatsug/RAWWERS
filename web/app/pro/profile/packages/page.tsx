"use client";

import { useMemo, useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { BottomSheet, Button, Card, EmptyState, Input, Skeleton, Textarea } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { proApi } from "@/lib/api/proApi";

export default function ProPackagesPage() {
  const { accessToken, userId } = useAuth();
  const [packagePayload, setPackagePayload] = useState('{"title":"","price_per_photo":0,"min_photo_qty":0}');
  const [packageId, setPackageId] = useState("");
  const [updatePayload, setUpdatePayload] = useState("{}");
  const [disableTarget, setDisableTarget] = useState("");

  const publicQ = useQuery({ queryKey: ["pro", "public", "packages", userId], queryFn: () => proApi.getPublicProProfile(userId || "", accessToken), enabled: !!accessToken && !!userId });

  const createM = useMutation({
    mutationFn: async () => {
      const payload = JSON.parse(packagePayload) as Record<string, unknown>;
      return proApi.createPackage(payload, accessToken);
    },
    onSuccess: async () => {
      await publicQ.refetch();
      await proApi.track("pro_package_saved", { source: "web", mode: "create" }, accessToken);
    },
  });

  const updateM = useMutation({
    mutationFn: async () => {
      const payload = JSON.parse(updatePayload) as Record<string, unknown>;
      return proApi.updatePackage(packageId, payload, accessToken);
    },
    onSuccess: async () => {
      await publicQ.refetch();
      await proApi.track("pro_package_saved", { source: "web", mode: "update", package_id: packageId }, accessToken);
    },
  });

  const disableM = useMutation({
    mutationFn: () => proApi.disablePackage(disableTarget, accessToken),
    onSuccess: () => publicQ.refetch(),
  });

  const packages = useMemo(() => {
    if (!publicQ.data?.ok) return [] as any[];
    return ((publicQ.data.data as any).packages || []) as any[];
  }, [publicQ.data]);

  if (!accessToken) return <EmptyState title="Sign in required" body="Please login as a pro." />;
  if (publicQ.isLoading) return <Skeleton className="h-24" />;
  if (publicQ.isError || !publicQ.data?.ok) return <EmptyState title="Packages unavailable" body="Refresh to retry." />;

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Packages & Pricing</h1>

      <Card className="space-y-2">
        <p className="text-sm font-medium">Current public packages</p>
        {packages.length === 0 ? <EmptyState title="No packages" body="Create your first package below." /> : null}
        {packages.map((pkg) => {
          const perPhoto = Number(pkg.price_per_photo ?? pkg.extra_photo_price ?? 0);
          const minQty = Number(pkg.min_photo_qty ?? 0);
          const fromPrice = perPhoto * minQty;
          return (
            <div key={pkg.id} className="rounded-xl border border-black/10 p-3">
              <p className="font-medium">{pkg.title || pkg.id}</p>
              <p className="text-sm text-neutral-600">per photo: {perPhoto} | min qty: {minQty} | derived from price: {fromPrice}</p>
              <button className="mt-2 text-xs text-red-600 underline" onClick={() => setDisableTarget(pkg.id)}>Disable package</button>
            </div>
          );
        })}
      </Card>

      <Card className="space-y-2">
        <p className="text-sm font-medium">Create package</p>
        <Textarea rows={6} value={packagePayload} onChange={(e) => setPackagePayload(e.target.value)} />
        <Button disabled={createM.isPending} onClick={() => createM.mutate()}>{createM.isPending ? "Saving..." : "Create"}</Button>
      </Card>

      <Card className="space-y-2">
        <p className="text-sm font-medium">Update package</p>
        <Input value={packageId} onChange={(e) => setPackageId(e.target.value)} placeholder="package id" />
        <Textarea rows={6} value={updatePayload} onChange={(e) => setUpdatePayload(e.target.value)} />
        <Button disabled={!packageId || updateM.isPending} onClick={() => updateM.mutate()}>{updateM.isPending ? "Saving..." : "Update"}</Button>
      </Card>

      <BottomSheet open={!!disableTarget} title="Disable package" onClose={() => setDisableTarget("")}>
        <p className="mb-3 text-sm">Disable package `{disableTarget}`?</p>
        <Button
          className="bg-red-600"
          disabled={disableM.isPending}
          onClick={async () => {
            await disableM.mutateAsync();
            setDisableTarget("");
          }}
        >
          {disableM.isPending ? "Disabling..." : "Confirm disable"}
        </Button>
      </BottomSheet>
    </div>
  );
}
