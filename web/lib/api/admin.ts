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

/** This month's marketing credit (Europe/London), in euros. */
export type MarketingBudget = {
  month: string;
  budget_eur: string;
  awarded_eur: string;
  used_eur: string;
  outstanding_eur: string;
  remaining_eur: string;
  max_discount_percent: number;
};
export type ClientCreditSettings = { max_discount_percent: number; monthly_marketing_credit_budget_eur: string };

/** The Stripe reconcile job's last run, shown above Money attention. */
export type StripeCheckRun = {
  started_at: string;
  finished_at: string | null;
  dry_run: boolean;
  checked: number;
  recorded: number;
  flagged: number;
  error: string | null;
};

/** Money an admin has to act on (GET /v1/admin/money-attention). */
export type MoneyAttentionItem = {
  id: string;
  kind: "client_owed" | "refund_outside_rawwers" | "chargeback_evidence_due" | "chargeback_lost" | string;
  status: "open" | "resolved" | string;
  gig_id: string | null;
  client_user_id: string | null;
  refund_case_id: string | null;
  stripe_refund_id: string | null;
  stripe_dispute_id: string | null;
  stripe_payment_intent_id?: string | null;
  amount: string;
  currency: string;
  note: string | null;
  due_at: string | null;
  created_at: string;
  resolved_at: string | null;
  /** True while the item holds a photographer's earning (a reported
   *  problem): it is released or kept on hold, never just closed. */
  hold_open?: boolean | null;
};

export type HoldOutcome = "release" | "keep";

/** Marketing-use consent (closed beta): one photo a client let RAWWERS feature. */
export type MarketingConsentRow = {
  id: string;
  media_asset_id: string;
  thumbnail_url: string | null;
  gig_id: string;
  client_first_name: string;
  pro_user_id: string;
  photographer_credit: string;
  scope: string;
  term_months: number;
  granted_at: string;
  ends_at: string;
  status: "active" | "withdrawn" | "expired" | string;
  withdrawn_at: string | null;
  expired_at: string | null;
  uses: number;
};

export type MarketingUse = {
  id: string;
  content_name: string;
  used_on: string;
  owned_channel: boolean;
  retire_by: string;
  consents: { id: string; status: string; ends_at: string }[];
};

export type MarketingWording = {
  version: string;
  audience: "client" | "photographer" | string;
  language: "en" | "pt" | string;
  text: string;
  status: "draft" | "reviewed" | "published" | string;
  in_use: boolean;
  reviewed_by: string | null;
  review_note: string | null;
  created_at: string;
  published_at: string | null;
};

export type ShelfSettings = {
  raww_eur_value: string;
  gbp_eur_rate: string;
  shelf_discount_percent: number;
  inactivity_months: number;
  warning_days: number;
  level_band_raww: number[];
  tier_max_level: Record<string, number>;
  wishlist_max: number;
  max_orders_per_month: number;
  same_item_cooldown_days: number;
  allowed_countries: string[];
  free_shipping: boolean;
  shelf_enabled: boolean;
  shelf_open: boolean;
  terms_text: string;
  terms_draft: boolean;
  terms_reviewed_by: string | null;
  terms_review_note: string | null;
  terms_approved_at: string | null;
  updated_at: string;
};

export type ShelfPriceHelper = {
  suggested_price_raww: number;
  street_price_eur: string;
  supplier_cost_eur: string;
  band_low_raww: number;
  band_high_raww: number | null;
  price_eur: string | null;
  margin_eur: string | null;
  band_warning: string | null;
};

export type ShelfItemInput = {
  title: string;
  brand: string | null;
  category: string;
  description: string | null;
  image_url: string | null;
  level: number;
  price_raww: number;
  street_price: string;
  street_currency: string;
  supplier_cost: string;
  supplier_currency: string;
  supplier_name: string;
  supplier_sku: string | null;
  supplier_url: string | null;
  stock_status: "in_stock" | "out_of_stock" | string;
  active: boolean;
  camera_models: string[];
};

export type ShelfItem = ShelfItemInput & { id: string; helper: ShelfPriceHelper; updated_at: string };

export type ShelfOrderEvent = {
  from_status: string | null;
  to_status: string;
  actor_type: string;
  actor_user_id: string | null;
  note: string | null;
  created_at: string;
};

export type AdminShelfOrder = {
  id: string;
  pro_user_id: string;
  pro_name: string | null;
  item_id: string;
  title: string;
  supplier_name: string;
  supplier_sku: string | null;
  price_raww: number;
  raww_eur_value: string;
  price_eur: string;
  status: "placed" | "ordered" | "shipped" | "delivered" | "cancelled" | "refunded" | string;
  country: string;
  address: Record<string, string | null> | null;
  supplier_order_ref: string | null;
  tracking_code: string | null;
  tracking_url: string | null;
  cancel_reason: string | null;
  placed_at: string;
  events: ShelfOrderEvent[];
};

export type RawwLedgerRow = {
  id: string;
  kind: string;
  amount: number;
  status: string;
  gig_id: string | null;
  source_type: string;
  note: string | null;
  actor_user_id: string | null;
  created_at: string;
};

export type MarketingTakeDown = {
  use_id: string;
  content_name: string;
  used_on: string;
  consent_id: string;
  reason: "withdrawn" | "expired" | string;
  ended_at: string;
  take_down_by: string;
};

export type ReductionLine = { reason_code: string; amount: string };
export type ReductionReason = { code: string; label: string; client_wording: string; may_carry_fault: boolean; is_active: boolean };
export type BookingMoney = {
  gig_id: string;
  status: string;
  currency: string;
  /** Until when the client may add photos after choosing; null before they finish. */
  addon_window_ends_at: string | null;
  deposit: { amount: string; platform_fee: string; pro_gross: string };
  final_price: string;
  final_split: { gross: string; platform_retained: string; pro_raww: string; client_raww: string; pro_cash: string; stamped_at: string | null } | null;
  payments: { kind: string; amount: string; amount_refunded: string; status: string; payment_intent: string }[];
  reductions: { id: string; created_at: string; source: string; from_amount: string; to_amount: string; refund_amount: string; note: string; lines: (ReductionLine & { label: string })[] }[];
  reasons: ReductionReason[];
  photographer: { pro_user_id: string; available: string; withdrawable: string; adjustment_owed: string };
};
export type ReductionPreview = {
  from_amount: string;
  to_amount: string;
  client_refund: string;
  photographer_cash_before: string;
  photographer_cash_after: string;
  currency: string;
};

export type Finding = {
  id: string;
  gig_id: string;
  status: "pending" | "confirmed" | "withdrawn" | string;
  reason: string;
  note: string;
  severe: boolean;
  severe_note: string | null;
  created_at: string;
  first_seen_at: string | null;
  window_ends_at: string;
  response: string | null;
  decision_note: string | null;
  consequence: string | null;
  strike_number: number | null;
};
export type ProFindings = { strikes: number; pause: { reason: string; since: string } | null; items: Finding[] };
export type AccountabilityPolicy = {
  contest_window_days: number;
  unseen_grace_days: number;
  rolling_window_months: number;
  pause_at: number;
  suspension_review_at: number;
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

  bookingMoney: (gigId: string) => adminFetch<BookingMoney>(`gigs/${gigId}/money`),
  marketingBudget: () => adminFetch<MarketingBudget>("client-credit/budget"),
  clientCreditSettings: () => adminFetch<ClientCreditSettings>("client-credit/settings"),
  saveClientCreditSettings: (body: Partial<ClientCreditSettings>) =>
    adminFetch<ClientCreditSettings>("client-credit/settings", { method: "PUT", body: JSON.stringify(body) }),
  extendSelectionWindow: (gigId: string, days: number, note: string) =>
    adminFetch<{ addon_window_ends_at: string }>(`gigs/${gigId}/selection-window/extend`, { method: "POST", body: JSON.stringify({ days, note }) }),
  galleryPolicy: () => adminFetch<{ shortfall_min_photos: number; selection_addon_days: number }>("policies/delivery-review"),
  saveGalleryPolicy: (selectionAddonDays: number) =>
    adminFetch<{ shortfall_min_photos: number; selection_addon_days: number }>("policies/delivery-review", {
      method: "PUT",
      body: JSON.stringify({ selection_addon_days: selectionAddonDays })
    }),
  previewReduction: (gigId: string, lines: ReductionLine[]) =>
    adminFetch<ReductionPreview>(`gigs/${gigId}/price-reductions/preview`, { method: "POST", body: JSON.stringify({ lines }) }),
  reducePrice: (gigId: string, lines: ReductionLine[], note: string, idempotencyKey: string) =>
    adminFetch<unknown>(`gigs/${gigId}/price-reductions`, {
      method: "POST",
      body: JSON.stringify({ lines, note, idempotency_key: idempotencyKey })
    }),
  proFindings: (proId: string) => adminFetch<ProFindings>(`pros/${proId}/findings`),
  recordFinding: (gigId: string, note: string, severe: boolean, severeNote: string | null) =>
    adminFetch<Finding>(`gigs/${gigId}/findings`, {
      method: "POST",
      body: JSON.stringify({ note, severe, severe_note: severeNote })
    }),
  decideFinding: (id: string, decision: "confirm" | "withdraw", note: string) =>
    adminFetch<Finding>(`findings/${id}/decision`, { method: "POST", body: JSON.stringify({ decision, note }) }),
  liftBookingPause: (proId: string, note: string) =>
    adminFetch<unknown>(`pros/${proId}/booking-pause/lift`, { method: "POST", body: JSON.stringify({ note }) }),
  accountabilityPolicy: () => adminFetch<AccountabilityPolicy>("policies/accountability"),
  interviewQuestions: () => adminFetch<InterviewQuestion[]>("interview-questions"),
  createInterviewQuestion: (body: InterviewQuestionInput) =>
    adminFetch<InterviewQuestion>("interview-questions", { method: "POST", body: JSON.stringify(body) }),
  updateInterviewQuestion: (id: string, body: Partial<InterviewQuestionInput>) =>
    adminFetch<InterviewQuestion>(`interview-questions/${id}`, { method: "PATCH", body: JSON.stringify(body) }),
  nicheBanners: () => adminFetch<NicheBannerList>("niche-banners"),
  nicheBanner: (slug: string) => adminFetch<NicheBannerDetail>(`niche-banners/${slug}`),
  editNicheBanner: (slug: string, body: { banner_style?: BannerStyle; banner_tagline?: string | null }) =>
    adminFetch<NicheBannerDetail>(`niche-banners/${slug}`, { method: "PATCH", body: JSON.stringify(body) }),
  startBannerUpload: (content_type: string, file_name: string) =>
    adminFetch<BannerUploadStarted>("niche-banner-uploads", { method: "POST", body: JSON.stringify({ content_type, file_name }) }),
  completeBannerUpload: (mediaAssetId: string) =>
    adminFetch<BannerUploadCompleted>(`niche-banner-uploads/${mediaAssetId}/complete`, { method: "POST" }),
  setBannerImage: (slug: string, body: BannerImageFields & { media_asset_id: string }) =>
    adminFetch<NicheBannerDetail>(`niche-banners/${slug}/image`, { method: "PUT", body: JSON.stringify(body) }),
  editBannerImage: (slug: string, body: Partial<BannerImageFields>) =>
    adminFetch<NicheBannerDetail>(`niche-banners/${slug}/image`, { method: "PATCH", body: JSON.stringify(body) }),
  removeBannerImage: (slug: string) => adminFetch<NicheBannerDetail>(`niche-banners/${slug}/image`, { method: "DELETE" }),
  revertBannerImage: (slug: string) => adminFetch<NicheBannerDetail>(`niche-banners/${slug}/image/revert`, { method: "POST" }),
  saveAccountabilityPolicy: (body: Partial<AccountabilityPolicy>) =>
    adminFetch<AccountabilityPolicy>("policies/accountability", { method: "PUT", body: JSON.stringify(body) }),
  moneyAttention: () => adminFetch<{ items: MoneyAttentionItem[]; stripe_check: StripeCheckRun | null }>("money-attention"),
  resolveMoneyAttention: (id: string, note: string, holdOutcome?: HoldOutcome) =>
    adminFetch<MoneyAttentionItem>(`money-attention/${id}/resolve`, {
      method: "POST",
      body: JSON.stringify(holdOutcome ? { note, hold_outcome: holdOutcome } : { note })
    }),
  marketingConsents: (filters: { status?: string; pro_user_id?: string }) => {
    const query = new URLSearchParams(Object.entries(filters).filter(([, v]) => v) as [string, string][]).toString();
    return adminFetch<{ items: MarketingConsentRow[] }>(`marketing/consents${query ? `?${query}` : ""}`);
  },
  marketingOriginal: (consentId: string) =>
    adminFetch<{ url: string; expires_in_seconds: number }>(`marketing/consents/${consentId}/original`, { method: "POST" }),
  recordMarketingUse: (body: { content_name: string; used_on: string; consent_ids: string[] }) =>
    adminFetch<MarketingUse>("marketing/uses", { method: "POST", body: JSON.stringify(body) }),
  marketingUses: () => adminFetch<{ items: MarketingUse[] }>("marketing/uses"),
  marketingExpiring: () => adminFetch<{ items: MarketingUse[] }>("marketing/expiring"),
  marketingTakeDowns: () => adminFetch<{ items: MarketingTakeDown[] }>("marketing/take-down"),
  marketingWordings: () => adminFetch<{ items: MarketingWording[] }>("marketing/wordings"),
  createMarketingWording: (body: { audience: string; language: string; text: string }) =>
    adminFetch<MarketingWording>("marketing/wordings", { method: "POST", body: JSON.stringify(body) }),
  publishMarketingWording: (version: string, body: { reviewed_by: string; note: string }) =>
    adminFetch<MarketingWording>(`marketing/wordings/${encodeURIComponent(version)}/publish`, {
      method: "POST",
      body: JSON.stringify(body)
    }),
  shelfSettings: () => adminFetch<ShelfSettings>("shelf/settings"),
  saveShelfSettings: (body: Partial<ShelfSettings>) =>
    adminFetch<ShelfSettings>("shelf/settings", { method: "PUT", body: JSON.stringify(body) }),
  saveShelfTerms: (text: string) =>
    adminFetch<ShelfSettings>("shelf/settings/terms", { method: "PUT", body: JSON.stringify({ text }) }),
  approveShelfTerms: (body: { reviewed_by: string; note: string }) =>
    adminFetch<ShelfSettings>("shelf/settings/terms/approve", { method: "POST", body: JSON.stringify(body) }),
  shelfItems: () => adminFetch<{ items: ShelfItem[] }>("shelf/items"),
  createShelfItem: (body: ShelfItemInput) => adminFetch<ShelfItem>("shelf/items", { method: "POST", body: JSON.stringify(body) }),
  updateShelfItem: (id: string, body: ShelfItemInput) =>
    adminFetch<ShelfItem>(`shelf/items/${id}`, { method: "PUT", body: JSON.stringify(body) }),
  shelfPriceHelper: (body: {
    level: number;
    price_raww: number | null;
    street_price: string;
    street_currency: string;
    supplier_cost: string;
    supplier_currency: string;
  }) => adminFetch<ShelfPriceHelper>("shelf/items/price-helper", { method: "POST", body: JSON.stringify(body) }),
  shelfOrders: (status?: string) => adminFetch<{ items: AdminShelfOrder[] }>(`shelf/orders${status ? `?status=${status}` : ""}`),
  shelfOrderOrdered: (id: string, supplier_order_ref: string) =>
    adminFetch<AdminShelfOrder>(`shelf/orders/${id}/ordered`, { method: "POST", body: JSON.stringify({ supplier_order_ref }) }),
  shelfOrderShipped: (id: string, tracking_code: string, tracking_url: string | null) =>
    adminFetch<AdminShelfOrder>(`shelf/orders/${id}/shipped`, { method: "POST", body: JSON.stringify({ tracking_code, tracking_url }) }),
  shelfOrderDelivered: (id: string) => adminFetch<AdminShelfOrder>(`shelf/orders/${id}/delivered`, { method: "POST" }),
  shelfOrderCancel: (id: string, reason: string, note: string) =>
    adminFetch<AdminShelfOrder>(`shelf/orders/${id}/cancel`, { method: "POST", body: JSON.stringify({ reason, note }) }),
  rawwLedger: (proUserId: string) =>
    adminFetch<{ spendable: number; pending: number; items: RawwLedgerRow[] }>(`shelf/raww/${proUserId}`),
  rawwAdjust: (proUserId: string, amount: number, note: string, request_id: string) =>
    adminFetch<RawwLedgerRow>(`shelf/raww/${proUserId}/adjust`, { method: "POST", body: JSON.stringify({ amount, note, request_id }) }),
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

// ─── Niche banners ─────────────────────────────────────────────────────────

export type BannerStyle = "image" | "text";
export type BannerStatus = "image_set" | "image_missing" | "text_only";

export type BannerImageFields = {
  alt_text: string;
  focal_x: number;
  focal_y: number;
  source: "owner" | "stock";
  credit: string | null;
  licence: string | null;
  source_url: string | null;
};

export type BannerRecord = BannerImageFields & {
  banner_id: string;
  media_asset_id: string;
  state: "current" | "previous" | "past";
  width: number;
  height: number;
  scrim_opacity: number;
  created_at: string;
  created_by_user_id: string;
  tile_url: string | null;
  hero_url: string | null;
  placeholder: string;
};

export type BannerLimits = {
  mime_types: string[];
  max_bytes: number;
  min_width: number;
  min_height: number;
  tagline_max: number;
  alt_max: number;
  min_contrast: number;
};

export type NicheBannerRow = {
  slug: string;
  name: string;
  is_active: boolean;
  banner_style: BannerStyle;
  banner_tagline: string | null;
  status: BannerStatus;
  current: BannerRecord | null;
  has_previous: boolean;
};

export type NicheBannerList = { items: NicheBannerRow[]; limits: BannerLimits };

export type NicheBannerDetail = NicheBannerRow & {
  previous: BannerRecord | null;
  history: BannerRecord[];
  limits: BannerLimits;
};

export type BannerUploadStarted = {
  media_asset_id: string;
  upload: { method: string; url: string; headers: Record<string, string>; storage_key: string; expires_in: number };
};

export type BannerUploadCompleted = {
  media_asset_id: string;
  width: number;
  height: number;
  scrim_opacity: number;
  placeholder: string;
  warnings: string[];
};

// ─── Meet the photographer ─────────────────────────────────────────────────

export type InterviewQuestion = {
  id: string;
  key: string;
  /** What the photographer is asked. */
  prompt: string;
  /** The heading clients read above the answer. */
  title: string;
  hint: string | null;
  min_chars: number;
  max_chars: number;
  position: number;
  is_active: boolean;
};

export type InterviewQuestionInput = Omit<InterviewQuestion, "id" | "key">;
