"use client";

import { ApiError, apiRequest } from "@/lib/api/client";

export type ApiErrorKind = "unauthorized" | "forbidden" | "validation" | "rate_limited" | "server" | "network" | "unknown";

export type ClientApiError = {
  kind: ApiErrorKind;
  code: string;
  message: string;
  status?: number;
  details?: Record<string, unknown>;
};

export type Result<T> = { ok: true; data: T } | { ok: false; error: ClientApiError };

function toError(error: unknown): ClientApiError {
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
    return { ok: true, data: await fn() };
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

export const clientApi = {
  me: (accessToken?: string | null) => wrap(() => get<any>("/me", accessToken)),
  login: (payload: { email: string; password: string }) => wrap(() => post<any>("/auth/login", payload)),
  register: (payload: { email: string; password: string }) => wrap(() => post<any>("/auth/register", payload)),
  logout: (refreshToken: string | null, accessToken?: string | null) => wrap(() => post<void>("/auth/logout", { refresh_token: refreshToken, revoke_family: true }, accessToken)),
  refresh: (refreshToken: string) => wrap(() => post<any>("/auth/refresh", { refresh_token: refreshToken })),
  requestPasswordReset: (payload: { email: string }) => wrap(() => post<void>("/auth/password-reset/request", payload)),
  confirmPasswordReset: (payload: { code: string; new_password: string }) => wrap(() => post<void>("/auth/password-reset/confirm", payload)),
  requestVerifyEmail: (payload: { email: string }) => wrap(() => post<void>("/auth/verify-email/request", payload)),
  confirmVerifyEmail: (payload: { code: string }) => wrap(() => post<void>("/auth/verify-email/confirm", payload)),

  getClientAccess: (accessToken?: string | null) => wrap(() => get<any>("/client/access", accessToken)),
  clientDiscover: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/client/discover", accessToken, params)),
  clientMatch: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/client/match", payload, accessToken)),
  searchPros: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/search/pros", accessToken, params)),
  getProPublic: (proUserId: string, accessToken?: string | null) => wrap(() => get<any>(`/pros/${proUserId}/public`, accessToken)),
  getClientProProfile: (proUserId: string, accessToken?: string | null) => wrap(() => get<any>(`/client/pros/${proUserId}`, accessToken)),
  joinWaitlist: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/client/waitlist", payload, accessToken)),

  createBookingRequest: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/client/bookings/request", payload, accessToken)),
  getClientBooking: (bookingId: string, accessToken?: string | null) => wrap(() => get<any>(`/client/bookings/${bookingId}`, accessToken)),
  payClientBooking: (bookingId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/client/bookings/${bookingId}/pay`, payload, accessToken)),
  submitTimeWindows: (bookingRequestId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/client/bookings/${bookingRequestId}/time-windows`, payload, accessToken)),

  getBookingRequest: (requestId: string, accessToken?: string | null) => wrap(() => get<any>(`/booking-requests/${requestId}`, accessToken)),
  cancelBookingRequest: (requestId: string, accessToken?: string | null) => wrap(() => post<any>(`/booking-requests/${requestId}/cancel`, {}, accessToken)),

  getGig: (gigId: string, accessToken?: string | null) => wrap(() => get<any>(`/gigs/${gigId}`, accessToken)),
  getGigConsent: (gigId: string, accessToken?: string | null) => wrap(() => get<any>(`/gigs/${gigId}/consent`, accessToken)),
  putGigConsent: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>(`/gigs/${gigId}/consent`, payload, accessToken)),
  createGigStripeIntent: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/gigs/${gigId}/payments/stripe/create-intent`, payload, accessToken)),
  createGigReview: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/gigs/${gigId}/review`, payload, accessToken)),

  listGigMedia: (gigId: string, accessToken?: string | null) => wrap(() => get<any>(`/gigs/${gigId}/media`, accessToken)),
  getGigMediaSignedUrl: (gigId: string, mediaAssetId: string, accessToken?: string | null) => wrap(() => get<any>(`/gigs/${gigId}/media/${mediaAssetId}/signed-url`, accessToken)),
  downloadGigMedia: (gigId: string, mediaAssetId: string, accessToken?: string | null) => wrap(() => get<any>(`/gigs/${gigId}/media/${mediaAssetId}/download`, accessToken)),

  getProofGallery: (galleryId: string, accessToken?: string | null) => wrap(() => get<any>(`/proof-galleries/${galleryId}`, accessToken)),
  saveSelection: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/proof-galleries/${galleryId}/selections`, payload, accessToken)),
  submitSelection: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/proof-galleries/${galleryId}/selections/submit`, payload, accessToken)),
  createUpsellIntent: (galleryId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/proof-galleries/${galleryId}/upsell/create-intent`, payload, accessToken)),
  getGalleryDownloads: (galleryId: string, accessToken?: string | null) => wrap(() => get<any>(`/proof-galleries/${galleryId}/downloads`, accessToken)),

  listDisputes: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/disputes", accessToken, params)),
  createDispute: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/disputes", payload, accessToken)),
  getDispute: (disputeId: string, accessToken?: string | null) => wrap(() => get<any>(`/disputes/${disputeId}`, accessToken)),
  cancelDispute: (disputeId: string, accessToken?: string | null) => wrap(() => post<any>(`/disputes/${disputeId}/cancel`, {}, accessToken)),
  addDisputeEvidence: (disputeId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/disputes/${disputeId}/evidence`, payload, accessToken)),
  addDisputeMessage: (disputeId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/disputes/${disputeId}/messages`, payload, accessToken)),

  putContact: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>("/me/contact", payload, accessToken)),
  getClientPreference: (accessToken?: string | null) => wrap(() => get<any>("/me/client-preference", accessToken)),
  putClientPreference: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>("/me/client-preference", payload, accessToken)),
  getNotificationPreferences: (accessToken?: string | null) => wrap(() => get<any>("/me/notification-preferences", accessToken)),
  putNotificationPreferences: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>("/me/notification-preferences", payload, accessToken)),
  listNotifications: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/me/notifications", accessToken, params)),
  readAllNotifications: (accessToken?: string | null) => wrap(() => post<any>("/me/notifications/read-all", {}, accessToken)),
  readNotification: (notificationId: string, accessToken?: string | null) => wrap(() => post<any>(`/me/notifications/${notificationId}/read`, {}, accessToken)),
  rewardsBalance: (accessToken?: string | null) => wrap(() => get<any>("/me/rewards/balance", accessToken)),
  rewardsBalanceShared: (accessToken?: string | null) => wrap(() => get<any>("/rewards/balance", accessToken)),
  rewardsLedger: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/rewards/ledger", accessToken, params)),
  rewardsSpend: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/rewards/spend", payload, accessToken)),

  printsCatalog: (accessToken?: string | null) => wrap(() => get<any>("/prints/catalog", accessToken)),
  myPrintOrders: (params: Record<string, string | number | boolean | undefined>, accessToken?: string | null) => wrap(() => get<any>("/prints/orders/mine", accessToken, params)),
  printOrderDetail: (orderId: string, accessToken?: string | null) => wrap(() => get<any>(`/prints/orders/${orderId}`, accessToken)),
  payPrintOrder: (orderId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/prints/orders/${orderId}/pay`, payload, accessToken)),
  updatePrintOrder: (orderId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => put<any>(`/prints/orders/${orderId}`, payload, accessToken)),
  createGigPrintOrder: (gigId: string, payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>(`/gigs/${gigId}/prints/orders`, payload, accessToken)),

  myReferralCode: (accessToken?: string | null) => wrap(() => get<any>("/me/referral-code", accessToken)),
  regenerateReferralCode: (accessToken?: string | null) => wrap(() => post<any>("/me/referral-code/regenerate", {}, accessToken)),
  referralStats: (accessToken?: string | null) => wrap(() => get<any>("/me/referrals/stats", accessToken)),
  referralLanding: (code: string, accessToken?: string | null) => wrap(() => get<any>(`/ref/${code}`, accessToken)),
  claimReferral: (payload: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/referrals/claim", payload, accessToken)),

  track: (name: string, props: Record<string, unknown>, accessToken?: string | null) => wrap(() => post<any>("/analytics", { name, props }, accessToken)),
};
