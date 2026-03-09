"use client";

import { apiRequest } from "@/lib/api/client";
import type { components } from "@/lib/api/generated/schema";

type MeResponse = components["schemas"]["MeResponse"];

export type ProProfileView = {
  user_id: string;
  display_name?: string | null;
  headline?: string | null;
  cover_media_asset_id?: string | null;
  bio?: string | null;
  city?: string | null;
  country?: string | null;
  languages: string[];
  styles: string[];
  gear: Record<string, unknown>;
  is_accepting_bookings: boolean;
  completeness_score: number;
  kyc_status: string;
};

export type PublicProProfile = {
  pro_user_id: string;
  display_name?: string | null;
  headline?: string | null;
  cover_media_asset_id?: string | null;
  city?: string | null;
  country?: string | null;
  styles: string[];
  avg_rating: number;
  review_count: number;
  packages: Array<{
    id: string;
    title: string;
    price: number;
    currency: string;
    included_photos: number;
    extra_photo_price: number;
  }>;
};

export type SearchProsResponse = {
  total: number;
  items: Array<{
    id: string;
    display_name?: string | null;
    headline?: string | null;
    cover_media_asset_id?: string | null;
    city?: string | null;
    country?: string | null;
    niche_slugs?: string[];
    top_niche?: string | null;
    price_min?: number | null;
    price_max?: number | null;
    avg_rating?: number | null;
    review_count?: number;
  }>;
};

export type MyNichesResponse = {
  primary_niche_slug?: string | null;
  niches: Array<{
    slug: string;
    name: string;
    declared_level?: string | null;
    is_primary: boolean;
  }>;
};

export const endpoints = {
  me: (accessToken?: string | null) => apiRequest<MeResponse>("/me", { accessToken }),
  login: (email: string, password: string) => apiRequest<{ access_token: string; refresh_token: string; expires_in: number }>("/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password })
  }),
  register: (email: string, password: string) => apiRequest<{ ok: boolean; user_id: string }>("/auth/register", {
    method: "POST",
    body: JSON.stringify({ email, password })
  }),
  upgradeToPro: (accessToken?: string | null) =>
    apiRequest<Record<string, unknown>>("/me/upgrade-to-pro", { method: "POST", accessToken, body: JSON.stringify({}) }),
  logout: (refreshToken: string | null, accessToken?: string | null) =>
    apiRequest<void>("/auth/logout", { method: "POST", accessToken, body: JSON.stringify({ refresh_token: refreshToken, revoke_family: true }) }),
  discover: (accessToken?: string | null) => apiRequest<{ items: Array<{ pro_user_id: string; score: number; city?: string; country?: string }> }>("/client/discover", { accessToken }),
  proProfile: (id: string, accessToken?: string | null) => apiRequest<Record<string, unknown>>(`/client/pros/${id}`, { accessToken }),
  createBookingRequest: (payload: Record<string, unknown>, accessToken?: string | null) =>
    apiRequest<{ booking_request_id: string }>("/client/bookings/request", { method: "POST", accessToken, body: JSON.stringify(payload) }),
  clientBookings: (accessToken?: string | null) => apiRequest<{ items: Array<Record<string, unknown>> }>("/client/bookings", { accessToken }),
  clientBooking: (id: string, accessToken?: string | null) => apiRequest<Record<string, unknown>>(`/client/bookings/${id}`, { accessToken }),
  payBooking: (id: string, accessToken?: string | null) => apiRequest<Record<string, unknown>>(`/client/bookings/${id}/pay`, { method: "POST", accessToken, body: JSON.stringify({}) }),
  notifications: (accessToken?: string | null) => apiRequest<{ items: Array<{ id: string; title: string; body: string; created_at: string }> }>("/notifications", { accessToken }),
  markNotificationRead: (id: string, accessToken?: string | null) => apiRequest<void>(`/notifications/${id}/read`, { method: "POST", accessToken }),
  flags: (accessToken?: string | null) => apiRequest<Array<{ name: string; enabled: boolean }>>("/feature-flags", { accessToken }),
  myOnboarding: (accessToken?: string | null) => apiRequest<Record<string, unknown>>("/pro/onboarding/status", { accessToken }),
  inbox: (accessToken?: string | null) => apiRequest<{ items: Array<Record<string, unknown>> }>("/pro/bookings/inbox", { accessToken }),
  scheduleSlots: (accessToken?: string | null) => apiRequest<{ items: Array<Record<string, unknown>> }>("/pro/scheduling/slots", { accessToken }),
  myPayouts: (accessToken?: string | null) => apiRequest<{ items: Array<Record<string, unknown>> }>("/pro/payouts", { accessToken }),
  i18nBundle: (locale: string, namespace: string) => apiRequest<{ locale: string; namespace: string; version: number; content: Record<string, string> }>("/i18n/bundles", { query: { locale, namespace } }),
  myProProfile: (accessToken?: string | null) => apiRequest<ProProfileView>("/pro/me/profile", { accessToken }),
  updateMyProProfile: (
    payload: Partial<Pick<ProProfileView, "display_name" | "headline" | "cover_media_asset_id" | "bio" | "city" | "country" | "languages" | "styles" | "gear">>,
    accessToken?: string | null,
  ) => apiRequest<ProProfileView>("/pro/me/profile", { method: "PUT", accessToken, body: JSON.stringify(payload) }),
  myNiches: (accessToken?: string | null) => apiRequest<MyNichesResponse>("/pro/niches/mine", { accessToken }),
  updateMyNiches: (payload: { primary_niche_slug?: string | null; niches: Array<{ slug: string; declared_level?: string | null; is_primary?: boolean }> }, accessToken?: string | null) =>
    apiRequest<MyNichesResponse>("/pro/niches/mine", { method: "PUT", accessToken, body: JSON.stringify(payload) }),
  nichesCatalog: (accessToken?: string | null) =>
    apiRequest<Array<{ id: string; slug: string; name: string; name_key?: string; is_active: boolean }>>("/niches", { accessToken }),
  publicProProfile: (id: string, accessToken?: string | null) => apiRequest<PublicProProfile>(`/pros/${id}/public`, { accessToken }),
  searchPros: (params: { q?: string; niche?: string; city?: string; country?: string; limit?: number; offset?: number }, accessToken?: string | null) =>
    apiRequest<SearchProsResponse>("/search/pros", { accessToken, query: params }),
};
