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
  /** Whether their gear meets the floor, and how many pieces are waiting on a person. */
  gear_verified: boolean;
  gear_awaiting_review: number;
  payout_blocked: boolean;
  submitted_at: string;
};

/** One piece of gear waiting for, or past, a reviewer's decision. */
export type GearQueueRow = {
  id: string;
  pro_user_id: string;
  pro_display_name: string | null;
  category: "camera_body" | "lens" | "lighting";
  status: "verified" | "rejected" | "pending_review" | "declared";
  make: string | null;
  model: string | null;
  /** Whole, unlike the photographer's own view: what a reviewer compares. */
  serial_number: string | null;
  sensor_size: "full_frame" | "crop" | "medium_format" | null;
  aperture_type: "prime" | "fixed_zoom" | "variable_zoom" | null;
  min_focal_mm: string | null;
  max_focal_mm: string | null;
  max_aperture: string | null;
  review_reason: string | null;
  exif_snapshot: Record<string, unknown>;
  evidence_url: string | null;
  created_at: string;
  reviewed_at: string | null;
  review_note: string | null;
};

export type GearApproveBody = {
  sensor_size?: "full_frame" | "crop" | "medium_format";
  aperture_type?: "prime" | "fixed_zoom" | "variable_zoom";
  note?: string;
  add_to_reference?: boolean;
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


/** One cell of the tier x niche price-cap grid. */
export type PriceCapRow = {
  niche_id: string;
  niche_slug: string;
  tier: "rookie" | "skilled" | "pro" | "elite" | "master";
  entry_price_min: string;
  /** Null means uncapped. Master is uncapped in every niche by design. */
  entry_price_max: string | null;
  currency: string;
  updated_at: string;
};

export type AdminNiche = { id: string; slug: string; name: string; is_active: boolean };

export type SkillTier = "rookie" | "skilled" | "pro" | "elite" | "master";
export const SKILL_TIERS: SkillTier[] = ["rookie", "skilled", "pro", "elite", "master"];

/** One niche's tier for a photographer: what is in force, what the evidence
 * alone says, and the admin override behind any difference. */
export type NicheSkillRow = {
  niche_id: string;
  niche_slug: string;
  niche_name: string;
  tier: SkillTier;
  evidence_tier: SkillTier | null;
  evidence_disagrees: boolean;
  score: number;
  verified: boolean;
  gigs_completed: number;
  active_override: { tier: SkillTier | null; by: string | null; at: string | null; reason: string | null } | null;
};

export const admin = {
  niches: () => adminFetch<AdminNiche[]>("niches"),
  priceCaps: () => adminFetch<PriceCapRow[]>("pricing/niche-package-price-caps"),
  savePriceCaps: (
    items: Array<{
      niche_slug: string;
      tier: string;
      entry_price_min: string;
      entry_price_max: string | null;
      currency: string;
    }>
  ) =>
    adminFetch<PriceCapRow[]>("pricing/niche-package-price-caps", {
      method: "PUT",
      body: JSON.stringify({ items })
    }),

  reviewQueue: () => adminFetch<{ items: ProReviewRow[] }>("pros/review-queue"),
  reviewDetail: (proUserId: string) => adminFetch<ProReviewDetail>(`pros/${proUserId}/review`),
  nicheSkills: (proUserId: string) => adminFetch<{ items: NicheSkillRow[] }>(`pros/${proUserId}/niche-skill`),
  setTierOverride: (proUserId: string, nicheId: string, tier: SkillTier, note: string) =>
    adminFetch<unknown>(`pros/${proUserId}/niche-skill/${nicheId}/override`, {
      method: "POST",
      body: JSON.stringify({ tier, note })
    }),
  removeTierOverride: (proUserId: string, nicheId: string, reason: string) =>
    adminFetch<unknown>(`pros/${proUserId}/niche-skill/${nicheId}/override`, {
      method: "DELETE",
      body: JSON.stringify({ reason })
    }),
  approvePro: (proUserId: string, note?: string) =>
    adminFetch<ProApprovalResult>(`pros/${proUserId}/approve`, {
      method: "POST",
      body: JSON.stringify({ note: note || null })
    }),
  gearQueue: () => adminFetch<{ items: GearQueueRow[] }>("gear-verifications?status=pending_review"),
  approveGear: (id: string, body: GearApproveBody) =>
    adminFetch<GearQueueRow>(`gear-verifications/${id}/approve`, { method: "POST", body: JSON.stringify(body) }),
  rejectGear: (id: string, reason: string) =>
    adminFetch<GearQueueRow>(`gear-verifications/${id}/reject`, { method: "POST", body: JSON.stringify({ reason }) }),
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
    }),

  cameraModels: () => adminFetch<CameraModelList>("camera-models"),
  addCameraModel: (body: { model: string; make: string | null; display_name: string | null; sensor_size: SensorSize }) =>
    adminFetch<CameraModelRow>("camera-models", { method: "POST", body: JSON.stringify(body) }),
  editCameraModel: (
    normalisedModel: string,
    body: { make: string | null; display_name: string; sensor_size: SensorSize; reason: string | null }
  ) =>
    adminFetch<CameraModelRow>(`camera-models/${encodeURIComponent(normalisedModel)}`, {
      method: "PUT",
      body: JSON.stringify(body)
    }),
  importCameraModels: (csv: string, apply: boolean, reason?: string | null) =>
    adminFetch<CameraImportResult>("camera-models/import", {
      method: "POST",
      body: JSON.stringify({ csv, apply, reason: reason ?? null })
    }),

  reviews: (params: { status?: ReviewStatus | ""; ratingMax?: number | null; q?: string; offset?: number; limit?: number }) => {
    const query = new URLSearchParams();
    if (params.status) query.set("status", params.status);
    if (params.ratingMax) query.set("rating_max", String(params.ratingMax));
    if (params.q?.trim()) query.set("q", params.q.trim());
    query.set("limit", String(params.limit ?? 50));
    query.set("offset", String(params.offset ?? 0));
    return adminFetch<AdminReviewList>(`reviews?${query.toString()}`);
  },
  moderateReview: (id: string, action: ReviewStatus, reason: string) =>
    adminFetch<unknown>(`reviews/${id}/moderate`, { method: "POST", body: JSON.stringify({ action, reason }) })
};

export type ReviewStatus = "published" | "hidden" | "removed";

/** A review as a moderator sees it: unlike the public list, it names the client. */
export type AdminReviewRow = {
  id: string;
  status: ReviewStatus;
  rating: number;
  text: string | null;
  tags: string[];
  would_book_again: boolean;
  has_video: boolean;
  niche_name: string | null;
  gig_id: string;
  pro_user_id: string;
  pro_display_name: string | null;
  client_user_id: string;
  client_email: string | null;
  reply_text: string | null;
  created_at: string;
  last_moderation: { action: string; reason: string | null; at: string; actor_user_id: string } | null;
};

export type AdminReviewList = {
  items: AdminReviewRow[];
  total: number;
  counts: Record<ReviewStatus, number>;
};

export type SensorSize = "full_frame" | "crop" | "medium_format";

/** One row of the table the upload check reads to decide a body's sensor size. */
export type CameraModelRow = {
  /** The lookup key: lowercased, separators dropped. */
  normalised_model: string;
  make: string | null;
  display_name: string;
  sensor_size: SensorSize;
  updated_at: string;
};

export type CameraModelList = {
  items: CameraModelRow[];
  /** Across the whole table, whatever is being shown. */
  total: number;
  full_frame: number;
};

export type CameraImportLine = {
  line: number;
  model: string;
  normalised_model: string;
  make: string | null;
  display_name: string;
  sensor_size: string | null;
  outcome: "create" | "update" | "unchanged" | "error";
  error: string | null;
  before: { make: string | null; display_name: string; sensor_size: SensorSize } | null;
};

export type CameraImportResult = {
  lines: CameraImportLine[];
  create: number;
  update: number;
  unchanged: number;
  errors: number;
  changes_sensor_size: boolean;
  applied: boolean;
};
