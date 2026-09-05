"use client";

import { apiGet, apiPost, apiPut } from "@/lib/api/client";

// Gigs, proof galleries (selection + delivery lifecycle), and disputes.
// Proof galleries and disputes are gig-scoped resources (both carry a
// gig_id) rather than domains of their own, so they live here alongside
// plain gig CRUD instead of splitting into more files.

export const gigs = {
  getGig: (gigId: string, accessToken?: string | null) => apiGet<any>(`/gigs/${gigId}`, accessToken),
  createGig: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/gigs", payload, accessToken),
  cancelGigSlot: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/gigs/${gigId}/cancel-slot`, payload, accessToken),
  requestReschedule: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/gigs/${gigId}/reschedule-request`, payload, accessToken),

  getGigConsent: (gigId: string, accessToken?: string | null) => apiGet<any>(`/gigs/${gigId}/consent`, accessToken),
  putGigConsent: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPut<any>(`/gigs/${gigId}/consent`, payload, accessToken),

  createGigStripeIntent: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/gigs/${gigId}/payments/stripe/create-intent`, payload, accessToken),
  createGigReview: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/gigs/${gigId}/review`, payload, accessToken),

  listGigMedia: (gigId: string, accessToken?: string | null) => apiGet<any>(`/gigs/${gigId}/media`, accessToken),
  getGigMediaSignedUrl: (gigId: string, mediaAssetId: string, accessToken?: string | null) => apiGet<any>(`/gigs/${gigId}/media/${mediaAssetId}/signed-url`, accessToken),
  downloadGigMedia: (gigId: string, mediaAssetId: string, accessToken?: string | null) => apiGet<any>(`/gigs/${gigId}/media/${mediaAssetId}/download`, accessToken),
  createGigShareLink: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/gigs/${gigId}/share-links`, payload, accessToken),

  createProofGalleryForGig: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/gigs/${gigId}/proof-gallery`, payload, accessToken),
  getProofGallery: (galleryId: string, accessToken?: string | null) => apiGet<any>(`/proof-galleries/${galleryId}`, accessToken),
  addProofGalleryItems: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/proof-galleries/${galleryId}/items`, payload, accessToken),
  publishProofGallery: (galleryId: string, accessToken?: string | null) => apiPost<any>(`/proof-galleries/${galleryId}/publish`, {}, accessToken),
  // Was split as clientApi.saveSelection / proApi.saveGallerySelection (and
  // submitSelection / submitGallerySelection) - same endpoint, two names.
  // Consolidated on the name the one live caller already uses.
  saveSelection: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/proof-galleries/${galleryId}/selections`, payload, accessToken),
  submitSelection: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/proof-galleries/${galleryId}/selections/submit`, payload, accessToken),
  createUpsellIntent: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/proof-galleries/${galleryId}/upsell/create-intent`, payload, accessToken),
  getGalleryDownloads: (galleryId: string, accessToken?: string | null) => apiGet<any>(`/proof-galleries/${galleryId}/downloads`, accessToken),

  listDisputes: (params: Record<string, string | number | boolean | undefined> = {}, accessToken?: string | null) => apiGet<any>("/disputes", accessToken, params),
  createDispute: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/disputes", payload, accessToken),
  getDispute: (disputeId: string, accessToken?: string | null) => apiGet<any>(`/disputes/${disputeId}`, accessToken),
  cancelDispute: (disputeId: string, accessToken?: string | null) => apiPost<any>(`/disputes/${disputeId}/cancel`, {}, accessToken),
  addDisputeEvidence: (disputeId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/disputes/${disputeId}/evidence`, payload, accessToken),
  addDisputeMessage: (disputeId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/disputes/${disputeId}/messages`, payload, accessToken),
};
