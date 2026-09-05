"use client";

import { apiGet, apiPost, apiPut } from "@/lib/api/client";
import type { ProProfileView } from "@/lib/api/discovery";

// Everything scoped to the pro's own account: profile/niches/packages/
// portfolio, onboarding, scheduling, pro-side chat, and payouts/earnings.
// The largest of the domain files by a wide margin (~60 functions) because
// it's genuinely where most of the pro app's surface area lives - see the
// W-0 discovery report if this seems disproportionate; splitting it
// further wasn't part of what was approved for this pass.

export type MyNichesResponse = {
  primary_niche_slug?: string | null;
  niches: Array<{ slug: string; name: string; declared_level?: string | null; is_primary: boolean }>;
};

function getMyProProfileImpl(accessToken?: string | null) {
  return apiGet<ProProfileView>("/pro/me/profile", accessToken);
}

export const pro = {
  // GET /v1/pro/me/profile has two call sites from two different,
  // apparently-competing screens (`/pro/profile` and
  // `/pro/profile/listing-card`). Per direction: both wrapper names stay
  // and point at the same request for now; picking a surviving screen is a
  // separate follow-up task. (The PUT side already shared one name,
  // `updateMyProProfile`, in both source files - no alias needed there.)
  myProProfile: getMyProProfileImpl,
  getMyProProfile: getMyProProfileImpl,
  updateMyProProfile: (
    payload: Partial<Pick<ProProfileView, "display_name" | "headline" | "cover_media_asset_id" | "bio" | "city" | "country" | "languages" | "styles" | "gear">>,
    accessToken?: string | null,
  ) => apiPut<ProProfileView>("/pro/me/profile", payload, accessToken),

  getMyNiches: (accessToken?: string | null) => apiGet<MyNichesResponse>("/pro/niches/mine", accessToken),
  updateMyNiches: (payload: { primary_niche_slug?: string | null; niches: Array<{ slug: string; declared_level?: string | null; is_primary?: boolean }> }, accessToken?: string | null) =>
    apiPut<MyNichesResponse>("/pro/niches/mine", payload, accessToken),

  getOnboarding: (accessToken?: string | null) => apiGet<any>("/pro/onboarding", accessToken),
  getOnboardingChecks: (accessToken?: string | null) => apiGet<any>("/pro/onboarding/checks", accessToken),
  onboardingStart: (accessToken?: string | null) => apiPost<any>("/pro/onboarding/start", {}, accessToken),
  onboardingCompleteProfile: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/pro/onboarding/complete-profile", payload, accessToken),
  onboardingSelectNiches: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/pro/onboarding/select-niches", payload, accessToken),
  onboardingConfigurePackages: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/pro/onboarding/configure-packages", payload, accessToken),
  onboardingUploadPortfolio: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/pro/onboarding/upload-portfolio", payload, accessToken),
  onboardingSubmitKyc: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/pro/onboarding/submit-kyc", payload, accessToken),

  createPackage: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/pro/me/packages", payload, accessToken),
  updatePackage: (packageId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPut<any>(`/pro/me/packages/${packageId}`, payload, accessToken),
  disablePackage: (packageId: string, accessToken?: string | null) => apiPost<any>(`/pro/me/packages/${packageId}/disable`, {}, accessToken),

  tagPortfolioMediaNiches: (mediaAssetId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/pro/me/portfolio/${mediaAssetId}/niches`, payload, accessToken),

  getAvailabilityRules: (accessToken?: string | null) => apiGet<any>("/pro/scheduling/availability-rules", accessToken),
  putAvailabilityRules: (payload: Record<string, unknown>, accessToken?: string | null) => apiPut<any>("/pro/scheduling/availability-rules", payload, accessToken),
  getSchedulingExceptions: (accessToken?: string | null) => apiGet<any>("/pro/scheduling/exceptions", accessToken),
  putSchedulingExceptions: (payload: Record<string, unknown>, accessToken?: string | null) => apiPut<any>("/pro/scheduling/exceptions", payload, accessToken),
  getSchedulingPolicy: (accessToken?: string | null) => apiGet<any>("/pro/scheduling/policy", accessToken),
  putSchedulingPolicy: (payload: Record<string, unknown>, accessToken?: string | null) => apiPut<any>("/pro/scheduling/policy", payload, accessToken),
  getCandidateSlots: (params: Record<string, string | number | boolean | undefined> = {}, accessToken?: string | null) => apiGet<any>("/pro/scheduling/slots", accessToken, params),
  getPublicAvailability: (proUserId: string, params: Record<string, string | number | boolean | undefined> = {}, accessToken?: string | null) => apiGet<any>(`/pro/${proUserId}/availability`, accessToken, params),

  listProThreads: (params: Record<string, string | number | boolean | undefined> = {}, accessToken?: string | null) => apiGet<any>("/pro/chat/threads", accessToken, params),
  getProThread: (threadId: string, accessToken?: string | null) => apiGet<any>(`/pro/chat/threads/${threadId}`, accessToken),
  sendProMessage: (threadId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/pro/chat/threads/${threadId}/messages`, payload, accessToken),
  getAIDraft: (threadId: string, payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>(`/pro/chat/threads/${threadId}/ai-draft`, payload, accessToken),

  getEarningsBalance: (accessToken?: string | null) => apiGet<any>("/pro/earnings/balance", accessToken),
  getEarningsLedger: (params: Record<string, string | number | boolean | undefined> = {}, accessToken?: string | null) => apiGet<any>("/pro/earnings/ledger", accessToken, params),
  getPayouts: (params: Record<string, string | number | boolean | undefined> = {}, accessToken?: string | null) => apiGet<any>("/pro/payouts", accessToken, params),
  getPayoutAccount: (accessToken?: string | null) => apiGet<any>("/pro/payouts/account", accessToken),
  putPayoutAccount: (payload: Record<string, unknown>, accessToken?: string | null) => apiPut<any>("/pro/payouts/account", payload, accessToken),
  requestPayout: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/pro/payouts/request", payload, accessToken),
};
