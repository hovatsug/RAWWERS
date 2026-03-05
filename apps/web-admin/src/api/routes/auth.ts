import { request } from "@/api/httpClient";

export interface LoginPayload {
  email: string;
  password: string;
}

export function login(payload: LoginPayload) {
  return request("/v1/auth/login", { method: "POST", body: payload });
}

export function logout() {
  return request("/v1/auth/logout", { method: "POST" });
}

export function refresh() {
  return request("/v1/auth/refresh", { method: "POST", authRetry: false });
}

export function requestPasswordReset(email: string) {
  return request("/v1/auth/password-reset/request", { method: "POST", body: { email } });
}

export function confirmPasswordReset(payload: { token: string; password: string }) {
  return request("/v1/auth/password-reset/confirm", { method: "POST", body: payload });
}
