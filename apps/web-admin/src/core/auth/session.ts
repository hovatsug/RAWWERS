import { request } from "@/api/httpClient";
import { getRefreshToken, setAuthTokens, clearAuthTokens } from "@/core/auth/tokenStore";

let refreshingPromise: Promise<boolean> | null = null;

export async function refreshSession(): Promise<boolean> {
  if (!refreshingPromise) {
    const refreshToken = getRefreshToken();
    if (!refreshToken) return false;
    refreshingPromise = request<{ access_token: string; refresh_token: string }>("/v1/auth/refresh", {
      method: "POST",
      authRetry: false,
      body: { refresh_token: refreshToken }
    })
      .then((tokens) => {
        setAuthTokens(tokens);
        return true;
      })
      .catch(() => false)
      .finally(() => {
        refreshingPromise = null;
      });
  }
  const ok = await refreshingPromise;
  if (!ok) clearAuthTokens();
  return ok;
}
