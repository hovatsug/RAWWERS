"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { useMutation, useQuery } from "@tanstack/react-query";
import { BottomSheet, Button, Card, EmptyState, Skeleton } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { clientApi } from "@/lib/api/clientApi";

export default function GalleryPage() {
  const { gigId, galleryId } = useParams<{ gigId: string; galleryId: string }>();
  const { accessToken } = useAuth();
  const [confirmSubmit, setConfirmSubmit] = useState(false);

  const galleryQ = useQuery({ queryKey: ["client", "gallery", galleryId], queryFn: () => clientApi.getProofGallery(galleryId, accessToken), enabled: !!galleryId });
  const saveM = useMutation({ mutationFn: () => clientApi.saveSelection(galleryId, { items: [] }, accessToken) });
  const submitM = useMutation({ mutationFn: () => clientApi.submitSelection(galleryId, { finalize: true }, accessToken) });

  if (galleryQ.isLoading) return <Skeleton className="h-24" />;
  if (!galleryQ.data?.ok) return <EmptyState title="Gallery unavailable" />;

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Proof Gallery</h1>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(galleryQ.data.data, null, 2)}</pre></Card>
      <Card className="flex gap-2">
        <Button onClick={() => saveM.mutate()} disabled={saveM.isPending}>{saveM.isPending ? "Saving..." : "Save selection"}</Button>
        <Button onClick={() => setConfirmSubmit(true)} disabled={submitM.isPending}>Submit selection</Button>
      </Card>
      <BottomSheet open={confirmSubmit} title="Confirm submit" onClose={() => setConfirmSubmit(false)}>
        <p className="mb-3 text-sm">Submit final selection for gig {gigId}?</p>
        <Button onClick={async () => { await submitM.mutateAsync(); setConfirmSubmit(false); }} disabled={submitM.isPending}>{submitM.isPending ? "Submitting..." : "Confirm"}</Button>
      </BottomSheet>
    </div>
  );
}
