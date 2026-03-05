import { request } from "@/api/httpClient";

let refreshingPromise: Promise<boolean> | null = null;

export async function refreshSession(): Promise<boolean> {
  if (!refreshingPromise) {
    refreshingPromise = request("/v1/auth/refresh", {
      method: "POST",
      authRetry: false,
      parseAs: "text"
    })
      .then(() => true)
      .catch(() => false)
      .finally(() => {
        refreshingPromise = null;
      });
  }
  return refreshingPromise;
}
