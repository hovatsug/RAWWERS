import { request } from "@/api/httpClient";

export interface AnalyticsPayload {
  name: string;
  props?: Record<string, unknown>;
}

export async function trackEvent(payload: AnalyticsPayload) {
  return request("/v1/analytics", { method: "POST", body: payload });
}
