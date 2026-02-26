"use client";

import { apiRequest } from "@/lib/api/client";
import type { components } from "@/lib/api/generated/schema";

type MeResponse = components["schemas"]["MeResponse"];

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
  i18nBundle: (locale: string, namespace: string) => apiRequest<{ locale: string; namespace: string; version: number; content: Record<string, string> }>("/i18n/bundles", { query: { locale, namespace } })
};
