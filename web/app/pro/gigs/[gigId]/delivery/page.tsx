"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { useMutation } from "@tanstack/react-query";
import { BottomSheet, Button, Card, EmptyState, Input } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { gigs } from "@/lib/api/gigs";

export default function ProGigDeliveryPage() {
  const { gigId } = useParams<{ gigId: string }>();
  const { accessToken } = useAuth();
  const [galleryId, setGalleryId] = useState("");
  const [confirmPublish, setConfirmPublish] = useState(false);

  const createGallery = useMutation({ mutationFn: () => gigs.createProofGalleryForGig(gigId, {}, accessToken) });
  const publishGallery = useMutation({ mutationFn: () => gigs.publishProofGallery(galleryId, accessToken) });

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Delivery Studio</h1>
      <Card className="space-y-2">
        <Button onClick={() => createGallery.mutate()} disabled={createGallery.isPending}>{createGallery.isPending ? "Creating..." : "Create Proof Gallery"}</Button>
        {createGallery.data?.ok ? <pre className="overflow-auto text-xs">{JSON.stringify(createGallery.data.data, null, 2)}</pre> : null}
      </Card>
      <Card className="space-y-2">
        <Input value={galleryId} onChange={(e) => setGalleryId(e.target.value)} placeholder="Gallery id" />
        <Button disabled={!galleryId} onClick={() => setConfirmPublish(true)}>Publish Gallery</Button>
      </Card>
      {!galleryId ? <EmptyState title="Paste gallery id to publish" /> : null}
      <BottomSheet open={confirmPublish} title="Confirm publish" onClose={() => setConfirmPublish(false)}>
        <p className="mb-3 text-sm">Publishing cannot be easily undone. Continue?</p>
        <Button
          disabled={publishGallery.isPending}
          onClick={async () => {
            await publishGallery.mutateAsync();
            setConfirmPublish(false);
          }}
        >
          {publishGallery.isPending ? "Publishing..." : "Confirm Publish"}
        </Button>
      </BottomSheet>
    </div>
  );
}
