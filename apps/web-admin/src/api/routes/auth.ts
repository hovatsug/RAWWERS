import { request } from "@/api/httpClient";
import { clearAuthTokens, getRefreshToken, setAuthTokens } from "@/core/auth/tokenStore";

export interface LoginPayload {
  email: string;
  password: string;
}

interface TokenResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
}

export async function login(payload: LoginPayload) {
  const tokens = await request<TokenResponse>("/v1/auth/login", { method: "POST", body: payload, authRetry: false });
  setAuthTokens(tokens);
  return tokens;
}

export async function logout() {
  const refreshToken = getRefreshToken();
  try {
    return await request("/v1/auth/logout", {
      method: "POST",
      body: refreshToken ? { refresh_token: refreshToken } : {}
    });
  } finally {
    clearAuthTokens();
  }
}

export async function refresh() {
  const refreshToken = getRefreshToken();
  if (!refreshToken) throw new Error("Missing refresh token");
  const tokens = await request<TokenResponse>("/v1/auth/refresh", {
    method: "POST",
    authRetry: false,
    body: { refresh_token: refreshToken }
  });
  setAuthTokens(tokens);
  return tokens;
}

export function requestPasswordReset(email: string) {
  return request("/v1/auth/password-reset/request", { method: "POST", body: { email } });
}

export function confirmPasswordReset(payload: { token: string; password: string }) {
  return request("/v1/auth/password-reset/confirm", { method: "POST", body: payload });
}
