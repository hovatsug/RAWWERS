"use client";

import { apiGet, apiPost, apiPut, type Result } from "@/lib/api/client";
import type { components } from "@/lib/api/generated/schema";

// Identity, session, and account-level settings ($RAWW balance/ledger,
// notifications, preferences). Grouped together because they're all "my
// account" /me-scoped concerns with no natural home of their own among
// booking/gigs/media/pro - see the W-0 discovery report for the full list
// of functions that didn't fit the six original domain names.

type MeResponse = components["schemas"]["MeResponse"];
type TokenResponse = { access_token: string; refresh_token: string; expires_in: number };

export const auth = {
  me: (accessToken?: string | null) => apiGet<MeResponse>("/me", accessToken),
  login: (email: string, password: string) => apiPost<TokenResponse>("/auth/login", { email, password }),
  register: (email: string, password: string) => apiPost<{ ok: boolean; user_id: string }>("/auth/register", { email, password }),
  upgradeToPro: (accessToken?: string | null) => apiPost<Record<string, unknown>>("/me/upgrade-to-pro", {}, accessToken),
  logout: (refreshToken: string | null, accessToken?: string | null) =>
    apiPost<void>("/auth/logout", { refresh_token: refreshToken, revoke_family: true }, accessToken),
  refresh: (refreshToken: string) => apiPost<TokenResponse>("/auth/refresh", { refresh_token: refreshToken }),
  requestPasswordReset: (email: string) => apiPost<void>("/auth/password-reset/request", { email }),
  confirmPasswordReset: (code: string, newPassword: string) => apiPost<void>("/auth/password-reset/confirm", { code, new_password: newPassword }),
  requestVerifyEmail: (email: string) => apiPost<void>("/auth/verify-email/request", { email }),
  confirmVerifyEmail: (code: string) => apiPost<void>("/auth/verify-email/confirm", { code }),

  putContact: (payload: Record<string, unknown>, accessToken?: string | null) => apiPut<any>("/me/contact", payload, accessToken),
  getClientPreference: (accessToken?: string | null) => apiGet<any>("/me/client-preference", accessToken),
  putClientPreference: (payload: Record<string, unknown>, accessToken?: string | null) => apiPut<any>("/me/client-preference", payload, accessToken),
  getNotificationPreferences: (accessToken?: string | null) => apiGet<any>("/me/notification-preferences", accessToken),
  putNotificationPreferences: (payload: Record<string, unknown>, accessToken?: string | null) => apiPut<any>("/me/notification-preferences", payload, accessToken),

  // Fixed paths - the old `endpoints.ts` versions hit `/notifications` and
  // `/notifications/{id}/read` (no `/me` prefix), which 404 every time.
  getNotifications: (params: Record<string, string | number | boolean | undefined> = {}, accessToken?: string | null) =>
    apiGet<{ items: Array<{ id: string; title: string; body: string; created_at: string }> }>("/me/notifications", accessToken, params),
  markNotificationRead: (notificationId: string, accessToken?: string | null) => apiPost<void>(`/me/notifications/${notificationId}/read`, {}, accessToken),
  readAllNotifications: (accessToken?: string | null) => apiPost<any>("/me/notifications/read-all", {}, accessToken),

  // $RAWW ledger - explicit MVP scope (C12/C13), unlike the referral/growth
  // endpoints which were deleted below.
  getRewardsBalance: (accessToken?: string | null) => apiGet<any>("/me/rewards/balance", accessToken),
  getRewardsBalanceShared: (accessToken?: string | null) => apiGet<any>("/rewards/balance", accessToken),
  getRewardsLedger: (params: Record<string, string | number | boolean | undefined> = {}, accessToken?: string | null) => apiGet<any>("/rewards/ledger", accessToken, params),
  spendRewards: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/rewards/spend", payload, accessToken),

  getI18nBundle: (locale: string, namespace: string) =>
    apiGet<{ locale: string; namespace: string; version: number; content: Record<string, string> }>("/i18n/bundles", undefined, { locale, namespace }),

  // GET /v1/feature-flags does not exist - only /v1/admin/feature-flags
  // (admin-only) and /v1/admin/ai/feature-flags do. This call always 404s;
  // callers fall back to a hardcoded flag map. Reported, not invented -
  // needs a backend decision (either a public flags route, or drop this
  // call and remove the dead fallback path).
  getFeatureFlags: (accessToken?: string | null) => apiGet<Array<{ name: string; enabled: boolean }>>("/feature-flags", accessToken),
};

export type { Result };
