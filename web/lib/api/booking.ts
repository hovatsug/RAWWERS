"use client";

import { apiGet, apiPost } from "@/lib/api/client";

// Booking-request and client-booking lifecycle. Booking-request actions
// (accept/decline/confirm-slot) live here rather than in pro.ts because
// they operate on the shared /booking-requests/{id} resource, not a
// pro-only one - this file is organized by resource, not by audience.

function getClientBookingImpl(bookingId: string, accessToken?: string | null) {
  return apiGet<Record<string, unknown>>(`/client/bookings/${bookingId}`, accessToken);
}

export const booking = {
  // GET /v1/client/bookings/{id} has two call sites from two different,
  // apparently-competing screens (`/client/bookings/[id]` and
  // `/bookings/[bookingId]`). Per direction: both wrapper names stay and
  // point at the same request for now; picking a surviving screen and
  // deleting the other is a separate follow-up task, not part of this
  // consolidation.
  clientBooking: getClientBookingImpl,
  getClientBooking: getClientBookingImpl,

  payClientBooking: (bookingId: string, accessToken?: string | null) => apiPost<Record<string, unknown>>(`/client/bookings/${bookingId}/pay`, {}, accessToken),
  submitBookingTimeWindows: (bookingRequestId: string, payload: Record<string, unknown>, accessToken?: string | null) =>
    apiPost<any>(`/client/bookings/${bookingRequestId}/time-windows`, payload, accessToken),

  // BACKEND GAP, reported not fixed: GET /v1/client/bookings (list) does
  // not exist on the API - only the single-booking GET above does. This
  // call always fails. Spec screen C13 ("My bookings") cannot be built
  // against this backend until a list-bookings route is added - that's a
  // separate backend task, not something to invent here.
  clientBookings: (accessToken?: string | null) => apiGet<{ items: Array<Record<string, unknown>> }>("/client/bookings", accessToken),

  // The request shape this sends is known-wrong (missing niche_slug/
  // package_id, flat dates instead of nested date_window, `message`
  // instead of `notes`) - fixing that shape is W-3's job. Kept as a
  // generic passthrough here (like the old clientApi.createBookingRequest)
  // so the existing, still-wrong call site needs no change beyond its
  // import until W-3 rebuilds the form.
  createBookingRequest: (payload: Record<string, unknown>, accessToken?: string | null) => apiPost<{ booking_id: string; status: string }>("/client/bookings/request", payload, accessToken),

  getBookingRequest: (requestId: string, accessToken?: string | null) => apiGet<Record<string, unknown>>(`/booking-requests/${requestId}`, accessToken),
  cancelBookingRequest: (requestId: string, accessToken?: string | null) => apiPost<any>(`/booking-requests/${requestId}/cancel`, {}, accessToken),
  acceptBookingRequest: (requestId: string, accessToken?: string | null) => apiPost<any>(`/booking-requests/${requestId}/accept`, {}, accessToken),
  declineBookingRequest: (requestId: string, reason: string | null, accessToken?: string | null) =>
    apiPost<any>(`/booking-requests/${requestId}/decline`, reason ? { reason } : {}, accessToken),
  confirmSlot: (bookingRequestId: string, payload: Record<string, unknown>, accessToken?: string | null) =>
    apiPost<any>(`/pro/bookings/${bookingRequestId}/confirm-slot`, payload, accessToken),
};
