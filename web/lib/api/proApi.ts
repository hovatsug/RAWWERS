"use client";

import { ApiError, apiRequest } from "@/lib/api/client";

export type ApiErrorKind = "unauthorized" | "forbidden" | "validation" | "rate_limited" | "server" | "network" | "unknown";

export type ProApiError = {
  kind: ApiErrorKind;
  code: string;
  message: string;
  status?: number;
  details?: Record<string, unknown>;
};

export type Result<T> = { ok: true; data: T } | { ok: false; error: ProApiError };

function toError(error: unknown): ProApiError {
  if (error instanceof ApiError) {
    const status = Number(error.details?.status || 0) || undefined;
    const code = error.code || "unknown";
    const kind: ApiErrorKind =
      code === "unauthorized" || status === 401
        ? "unauthorized"
        : code === "forbidden" || status === 403
          ? "forbidden"
          : code === "validation_error" || status === 422
            ? "validation"
            : status === 429
              ? "rate_limited"
              : status && status >= 500
                ? "server"
                : "unknown";
    return { kind, code, message: error.message, status, details: error.details };
  }
  return { kind: "network", code: "network_error", message: error instanceof Error ? error.message : "Network error" };
}

async function wrap<T>(fn: () => Promise<T>): Promise<Result<T>> {
  try {
    const data = await fn();
    return { ok: true, data };
  } catch (error) {
    return { ok: false, error: toError(error) };
  }
}

function get<T>(path: string, accessToken?: string | null, query?: Record<string, string | number | boolean | undefined>) {
  return apiRequest<T>(path, { accessToken, query });
}
function post<T>(path: string, body: unknown, accessToken?: string | null) {
  return apiRequest<T>(path, { method: "POST", accessToken, body: JSON.stringify(body) });
}
function put<T>(path: string, body: unknown, accessToken?: string | null) {
  return apiRequest<T>(path, { method: "PUT", accessToken, body: JSON.stringify(body) });
}

export const proApi = {
  me: (accessToken?: string | null) => wrap(() => get<any>("/me", accessToken)),
  logout: (refreshToken: string | null, accessToken?: string | null) => wrap(() => post<void>("/auth/logout", { refresh_token: refreshToken, revoke_family: true }, accessToken)),
  refresh: (refreshToken: string) => wrap(() => post<{ access_token: string; refresh_token: string; expires_in: number }>("/auth/refresh", { refresh_token: refreshToken })),
  requestVerifyEmail: (email: string) => wrap(() => post<void>("/auth/verify-email/request", { email })),
  confirmVerifyEmail: (code: string) => wrap(() => post<void>("/auth/verify-email/confirm", { code })),

  getMyProProfile: (accessToken?: string | null) => wrap(() => get<any>("/pro/me/profile", accessToken)),
  updateMyProProfile: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>("/pro/me/profile", payload, accessToken)),
  getOnboarding: (accessToken?: string | null) => wrap(() => get<any>("/pro/onboarding", accessToken)),
  getOnboardingChecks: (accessToken?: string | null) => wrap(() => get<any>("/pro/onboarding/checks", accessToken)),
  onboardingStart: (accessToken?: string | null) => wrap(() => post<any>("/pro/onboarding/start", {}, accessToken)),
  onboardingCompleteProfile: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/pro/onboarding/complete-profile", payload, accessToken)),
  onboardingSelectNiches: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/pro/onboarding/select-niches", payload, accessToken)),
  onboardingConfigurePackages: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/pro/onboarding/configure-packages", payload, accessToken)),
  onboardingUploadPortfolio: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/pro/onboarding/upload-portfolio", payload, accessToken)),
  onboardingSubmitKyc: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/pro/onboarding/submit-kyc", payload, accessToken)),
  listNiches: (accessToken?: string | null) => wrap(() => get<any>("/niches", accessToken)),
  getMyNiches: (accessToken?: string | null) => wrap(() => get<any>("/pro/niches/mine", accessToken)),
  putMyNiches: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>("/pro/niches/mine", payload, accessToken)),
  createPackage: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/pro/me/packages", payload, accessToken)),
  updatePackage: (packageId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>(`/pro/me/packages/${packageId}`, payload, accessToken)),
  disablePackage: (packageId: string, accessToken?: string | null) => wrap(() => post<any>(`/pro/me/packages/${packageId}/disable`, {}, accessToken)),
  tagPortfolioMediaNiches: (mediaAssetId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/pro/me/portfolio/${mediaAssetId}/niches`, payload, accessToken)),

  searchPros: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/search/pros", accessToken, params)),
  getPublicProProfile: (proUserId: string, accessToken?: string | null) => wrap(() => get<any>(`/pros/${proUserId}/public`, accessToken)),

  getAvailabilityRules: (accessToken?: string | null) => wrap(() => get<any>("/pro/scheduling/availability-rules", accessToken)),
  putAvailabilityRules: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>("/pro/scheduling/availability-rules", payload, accessToken)),
  getSchedulingExceptions: (accessToken?: string | null) => wrap(() => get<any>("/pro/scheduling/exceptions", accessToken)),
  putSchedulingExceptions: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>("/pro/scheduling/exceptions", payload, accessToken)),
  getSchedulingPolicy: (accessToken?: string | null) => wrap(() => get<any>("/pro/scheduling/policy", accessToken)),
  putSchedulingPolicy: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>("/pro/scheduling/policy", payload, accessToken)),
  getCandidateSlots: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/pro/scheduling/slots", accessToken, params)),
  getPublicAvailability: (proUserId: string, params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>(`/pro/${proUserId}/availability`, accessToken, params)),

  getBookingRequest: (requestId: string, accessToken?: string | null) => wrap(() => get<any>(`/booking-requests/${requestId}`, accessToken)),
  acceptBookingRequest: (requestId: string, accessToken?: string | null) => wrap(() => post<any>(`/booking-requests/${requestId}/accept`, {}, accessToken)),
  declineBookingRequest: (requestId: string, reason: string | null, accessToken?: string | null) => wrap(() => post<any>(`/booking-requests/${requestId}/decline`, reason ? { reason } : {}, accessToken)),
  cancelBookingRequest: (requestId: string, accessToken?: string | null) => wrap(() => post<any>(`/booking-requests/${requestId}/cancel`, {}, accessToken)),
  confirmSlot: (bookingRequestId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/pro/bookings/${bookingRequestId}/confirm-slot`, payload, accessToken)),

  getGig: (gigId: string, accessToken?: string | null) => wrap(() => get<any>(`/gigs/${gigId}`, accessToken)),
  createGig: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/gigs", payload, accessToken)),
  cancelGigSlot: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/gigs/${gigId}/cancel-slot`, payload, accessToken)),
  requestReschedule: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/gigs/${gigId}/reschedule-request`, payload, accessToken)),
  getGigConsent: (gigId: string, accessToken?: string | null) => wrap(() => get<any>(`/gigs/${gigId}/consent`, accessToken)),
  putGigConsent: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>(`/gigs/${gigId}/consent`, payload, accessToken)),
  listGigMedia: (gigId: string, accessToken?: string | null) => wrap(() => get<any>(`/gigs/${gigId}/media`, accessToken)),
  getGigMediaSignedUrl: (gigId: string, mediaAssetId: string, accessToken?: string | null) => wrap(() => get<any>(`/gigs/${gigId}/media/${mediaAssetId}/signed-url`, accessToken)),
  downloadGigMedia: (gigId: string, mediaAssetId: string, accessToken?: string | null) => wrap(() => get<any>(`/gigs/${gigId}/media/${mediaAssetId}/download`, accessToken)),
  createGigShareLink: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/gigs/${gigId}/share-links`, payload, accessToken)),

  createProofGalleryForGig: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/gigs/${gigId}/proof-gallery`, payload, accessToken)),
  getProofGallery: (galleryId: string, accessToken?: string | null) => wrap(() => get<any>(`/proof-galleries/${galleryId}`, accessToken)),
  addProofGalleryItems: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/proof-galleries/${galleryId}/items`, payload, accessToken)),
  publishProofGallery: (galleryId: string, accessToken?: string | null) => wrap(() => post<any>(`/proof-galleries/${galleryId}/publish`, {}, accessToken)),
  saveGallerySelection: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/proof-galleries/${galleryId}/selections`, payload, accessToken)),
  submitGallerySelection: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/proof-galleries/${galleryId}/selections/submit`, payload, accessToken)),
  createUpsellIntent: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/proof-galleries/${galleryId}/upsell/create-intent`, payload, accessToken)),
  getProofGalleryDownloads: (galleryId: string, accessToken?: string | null) => wrap(() => get<any>(`/proof-galleries/${galleryId}/downloads`, accessToken)),

  createPhotoUpload: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/media/photos/uploads", payload, accessToken)),
  completePhotoUpload: (mediaAssetId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/media/photos/${mediaAssetId}/complete`, payload, accessToken)),
  getMediaAsset: (mediaAssetId: string, accessToken?: string | null) => wrap(() => get<any>(`/media/${mediaAssetId}`, accessToken)),

  listProThreads: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/pro/chat/threads", accessToken, params)),
  getProThread: (threadId: string, accessToken?: string | null) => wrap(() => get<any>(`/pro/chat/threads/${threadId}`, accessToken)),
  sendProMessage: (threadId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/pro/chat/threads/${threadId}/messages`, payload, accessToken)),
  getAIDraft: (threadId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/pro/chat/threads/${threadId}/ai-draft`, payload, accessToken)),

  getEarningsBalance: (accessToken?: string | null) => wrap(() => get<any>("/pro/earnings/balance", accessToken)),
  getEarningsLedger: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/pro/earnings/ledger", accessToken, params)),
  getPayouts: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/pro/payouts", accessToken, params)),
  getPayoutAccount: (accessToken?: string | null) => wrap(() => get<any>("/pro/payouts/account", accessToken)),
  putPayoutAccount: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>("/pro/payouts/account", payload, accessToken)),
  requestPayout: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/pro/payouts/request", payload, accessToken)),

  track: (name: string, props: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/analytics", { name, props }, accessToken)),
};
