"use client";

import { useState } from "react";
import { useMutation } from "@tanstack/react-query";
import { Button, Card, EmptyState, Input, Textarea } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { proApi } from "@/lib/api/proApi";

export default function ProPortfolioPage() {
  const { accessToken } = useAuth();
  const [uploadPayload, setUploadPayload] = useState('{"filename":"image.jpg","content_type":"image/jpeg"}');
  const [mediaId, setMediaId] = useState("");
  const [completePayload, setCompletePayload] = useState("{}");
  const [tagMediaId, setTagMediaId] = useState("");
  const [tagPayload, setTagPayload] = useState('{"niche_slugs":[]}');

  const createUploadM = useMutation({
    mutationFn: async () => {
      const payload = JSON.parse(uploadPayload) as Record<string, unknown>;
      return proApi.createPhotoUpload(payload, accessToken);
    },
    onSuccess: async () => {
      await proApi.track("pro_gallery_items_added", { source: "web", stage: "upload_created" }, accessToken);
    },
  });

  const completeUploadM = useMutation({
    mutationFn: async () => {
      const payload = JSON.parse(completePayload || "{}") as Record<string, unknown>;
      return proApi.completePhotoUpload(mediaId, payload, accessToken);
    },
  });

  const tagM = useMutation({
    mutationFn: async () => {
      const payload = JSON.parse(tagPayload) as Record<string, unknown>;
      return proApi.tagPortfolioMediaNiches(tagMediaId, payload, accessToken);
    },
  });

  if (!accessToken) return <EmptyState title="Sign in required" body="Please login as a pro." />;

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Portfolio Manager</h1>

      <Card className="space-y-2">
        <p className="text-sm font-medium">1) Create upload</p>
        <Textarea rows={4} value={uploadPayload} onChange={(e) => setUploadPayload(e.target.value)} />
        <Button disabled={createUploadM.isPending} onClick={() => createUploadM.mutate()}>{createUploadM.isPending ? "Creating..." : "Create upload target"}</Button>
        {createUploadM.data?.ok ? (
          <pre className="overflow-auto rounded bg-neutral-50 p-3 text-xs">{JSON.stringify(createUploadM.data.data, null, 2)}</pre>
        ) : null}
      </Card>

      <Card className="space-y-2">
        <p className="text-sm font-medium">2) Complete upload</p>
        <Input value={mediaId} onChange={(e) => setMediaId(e.target.value)} placeholder="media asset id" />
        <Textarea rows={4} value={completePayload} onChange={(e) => setCompletePayload(e.target.value)} />
        <Button disabled={!mediaId || completeUploadM.isPending} onClick={() => completeUploadM.mutate()}>{completeUploadM.isPending ? "Completing..." : "Complete upload"}</Button>
      </Card>

      <Card className="space-y-2">
        <p className="text-sm font-medium">3) Tag media niches</p>
        <Input value={tagMediaId} onChange={(e) => setTagMediaId(e.target.value)} placeholder="media asset id" />
        <Textarea rows={4} value={tagPayload} onChange={(e) => setTagPayload(e.target.value)} />
        <Button disabled={!tagMediaId || tagM.isPending} onClick={() => tagM.mutate()}>{tagM.isPending ? "Saving..." : "Save tags"}</Button>
      </Card>
    </div>
  );
}
