"use client";

import { apiGet, apiPost } from "@/lib/api/client";

// Raw media asset creation/lookup. Deliberately small - gig-scoped media
// access (list/signed-url/download) lives in gigs.ts instead, since those
// routes are namespaced under /gigs/{id}/media and conceptually belong to
// a gig, not to generic asset management.

export const media = {
  createPhotoUpload: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/media/photos/uploads", payload, accessToken),
  completePhotoUpload: (mediaAssetId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/media/photos/${mediaAssetId}/complete`, payload, accessToken),
  getMediaAsset: (mediaAssetId: string, accessToken?: string | null) => apiGet<any>(`/media/${mediaAssetId}`, accessToken),
};
