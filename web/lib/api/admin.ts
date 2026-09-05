"use client";

import { getAccessToken, type Result } from "@/lib/api/client";

/**
 * Admin calls go through the same-origin proxy at /api/admin/*, never
 * straight to the backend: the admin API key is server-only and is added
 * there. See app/api/admin/[...path]/route.ts.
 */

export type ProReviewRow = {
  pro_user_id: string;
  display_name: string | null;
  headline: string | null;
  city: string | null;
  country: string | null;
  onboarding_status: string;
  kyc_status: string;
  portfolio_photo_count: number;
  portfolio_minimum: number;
  active_packages: number;
  min_price: string | null;
  currency: string;
  cover_url: string | null;
  ready_to_approve: boolean;
  missing: string[];
  payout_blocked: boolean;
  submitted_at: string;
};

export type ProReviewDetail = {
  row: ProReviewRow;
  bio: string | null;
  languages: string[];
  styles: string[];
  travel_radius_km: number | null;
  checks: Record<string, unknown>;
  portfolio_urls: string[];
  packages: Array<{
    title: string;
    niche_slug: string;
    price: string;
    currency: string;
    included_photos: number;
    duration_minutes: number;
  }>;
  payout_account_status: string;
};

export type ProApprovalResult = {
  pro_user_id: string;
  kyc_status: string;
  onboarding_status: string;
  is_accepting_bookings: boolean;
  payout_account_status: string;
  payout_blocked: boolean;
};

async function adminFetch<T>(path: string, init?: RequestInit): Promise<Result<T>> {
  const token = getAccessToken();
  try {
    const res = await fetch(`/api/admin/${path}`, {
      ...init,
      headers: {
        "Content-Type": "application/json",
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...(init?.headers || {})
      },
      cache: "no-store"
    });
    const payload = await res.json().catch(() => null);
    if (!res.ok) {
      const message = payload?.error?.message || `Request failed (${res.status})`;
      return {
        ok: false,
        error: {
          kind: res.status === 403 ? "forbidden" : res.status >= 500 ? "server" : "validation",
          code: payload?.error?.code || "unknown",
          message,
          status: res.status
        }
      };
    }
    return { ok: true, data: payload as T };
  } catch (error) {
    return {
      ok: false,
      error: { kind: "network", code: "network_error", message: "Could not reach the server." }
    };
  }
}

export type PayoutQueueRow = {
  payout_request_id: string;
  pro_user_id: string;
  display_name: string | null;
  email: string | null;
  amount_eur: string;
  status: string;
  requested_at: string;
  payout_method: string;
  payout_account_status: string;
  approval_blocked: boolean;
  blocked_reason: string | null;
  available_eur: string;
  pending_eur: string;
  withdrawable_eur: string;
  exceeds_withdrawable: boolean;
  lifetime_payouts: number;
};

export type DisputeRow = {
  id: string;
  gig_id?: string | null;
  status: string;
  category?: string | null;
  reason?: string | null;
  summary?: string | null;
  requested_refund_amount?: string | null;
  currency?: string | null;
  opened_at?: string | null;
  due_response_at?: string | null;
};

export const admin = {
  reviewQueue: () => adminFetch<{ items: ProReviewRow[] }>("pros/review-queue"),
  reviewDetail: (proUserId: string) => adminFetch<ProReviewDetail>(`pros/${proUserId}/review`),
  approvePro: (proUserId: string, note?: string) =>
    adminFetch<ProApprovalResult>(`pros/${proUserId}/approve`, {
      method: "POST",
      body: JSON.stringify({ note: note || null })
    }),
  payoutQueue: () => adminFetch<{ items: PayoutQueueRow[] }>("payouts/queue"),
  approvePayout: (id: string) => adminFetch<unknown>(`payouts/${id}/approve`, { method: "POST" }),
  markPayoutPaid: (id: string, reference: Record<string, string>) =>
    adminFetch<unknown>(`payouts/${id}/mark-paid`, {
      method: "POST",
      body: JSON.stringify({ reference })
    }),
  rejectPayout: (id: string, reason: string) =>
    adminFetch<unknown>(`payouts/${id}/reject`, { method: "POST", body: JSON.stringify({ reason }) }),

  disputes: () => adminFetch<DisputeRow[]>("disputes"),
  dispute: (id: string) => adminFetch<Record<string, unknown>>(`disputes/${id}`),
  resolveDispute: (id: string, decision: string, rationale: string, amount?: string) =>
    adminFetch<unknown>(`disputes/${id}/resolve`, {
      method: "POST",
      body: JSON.stringify({ decision, rationale, amount: amount ?? null })
    }),

  rejectPro: (proUserId: string, note: string) =>
    adminFetch<unknown>(`onboarding/pros/${proUserId}/reject`, {
      method: "POST",
      body: JSON.stringify({ note })
    })
};
