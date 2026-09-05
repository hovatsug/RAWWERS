"use client";

import { apiGet, apiPost } from "@/lib/api/client";

// Pre-booking discovery and public profile lookups - the client's path to
// finding a pro, before any booking resource exists. Not folded into
// booking.ts because nothing here is booking-scoped yet; not pro.ts because
// clients (not just pros) call getPublicProProfile/searchPros too.

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

export const discovery = {
  // Fixed: the old `endpoints.discover` sent no query params at all, but
  // country/city are required, default-less query params on the backend -
  // every call 422d. Callers must now supply them.
  discover: (params: { country: string; city: string } & Record<string, string | number | boolean | undefined>, accessToken?: string | null) =>
    apiGet<{ items: Array<{ pro_user_id: string; score: number; city?: string; country?: string }> }>("/client/discover", accessToken, params),
  clientMatch: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/client/match", payload, accessToken),
  searchPros: (params: { q?: string; niche?: string; city?: string; country?: string; limit?: number; offset?: number }, accessToken?: string | null) =>
    apiGet<SearchProsResponse>("/search/pros", accessToken, params),

  // Two distinct backend routes, not duplicates of each other:
  // /client/pros/{id} is the client-facing view; /pros/{id}/public is the
  // general public profile (also used by a pro to preview their own card).
  getClientProProfile: (proUserId: string, accessToken?: string | null) => apiGet<Record<string, unknown>>(`/client/pros/${proUserId}`, accessToken),
  getPublicProProfile: (proUserId: string, accessToken?: string | null) => apiGet<PublicProProfile>(`/pros/${proUserId}/public`, accessToken),

  getNichesCatalog: (accessToken?: string | null) =>
    apiGet<Array<{ id: string; slug: string; name: string; name_key?: string; is_active: boolean }>>("/niches", accessToken),

  getClientAccess: (accessToken?: string | null) => apiGet<any>("/client/access", accessToken),
  joinWaitlist: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<any>("/client/waitlist", payload, accessToken),
};
