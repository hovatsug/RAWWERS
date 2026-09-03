"use client";

import { z } from "zod";

const ApiErrorSchema = z.object({
  error: z.object({
    code: z.string(),
    message: z.string(),
    details: z.record(z.any()).optional()
  })
});

export class ApiError extends Error {
  code: string;
  details: Record<string, unknown>;
  constructor(code: string, message: string, details: Record<string, unknown> = {}) {
    super(message);
    this.code = code;
    this.details = details;
  }
}

export type ApiErrorKind = "unauthorized" | "forbidden" | "validation" | "rate_limited" | "server" | "network" | "unknown";

export type ClientApiError = {
  kind: ApiErrorKind;
  code: string;
  message: string;
  status?: number;
  details?: Record<string, unknown>;
};

export type Result<T> = { ok: true; data: T } | { ok: false; error: ClientApiError };

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000";
const SESSION_STORAGE_KEY = "rawwers_session";
export const SESSION_UPDATED_EVENT = "rawwers:session-updated";

type StoredSession = { accessToken: string | null; refreshToken: string | null };

function readStoredSession(): StoredSession | null {
  if (typeof window === "undefined") return null;
  const raw = window.sessionStorage.getItem(SESSION_STORAGE_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as StoredSession;
  } catch {
    return null;
  }
}

function writeRefreshedTokens(accessToken: string, refreshToken: string): void {
  if (typeof window === "undefined") return;
  const raw = window.sessionStorage.getItem(SESSION_STORAGE_KEY);
  let prev: Record<string, unknown> = {};
  try {
    prev = raw ? JSON.parse(raw) : {};
  } catch {
    prev = {};
  }
  const next = { ...prev, accessToken, refreshToken };
  window.sessionStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(next));
  window.dispatchEvent(new CustomEvent(SESSION_UPDATED_EVENT));
}

// De-dupes concurrent refresh attempts (e.g. several requests 401 around the
// same time during a long upload) into a single in-flight refresh call.
let refreshPromise: Promise<string | null> | null = null;

async function refreshAccessToken(): Promise<string | null> {
  if (refreshPromise) return refreshPromise;
  refreshPromise = (async () => {
    const stored = readStoredSession();
    if (!stored?.refreshToken) return null;
    try {
      const url = new URL("/v1/auth/refresh", API_BASE_URL);
      const res = await fetch(url.toString(), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        cache: "no-store",
        body: JSON.stringify({ refresh_token: stored.refreshToken })
      });
      if (!res.ok) return null;
      const data = (await res.json().catch(() => null)) as { access_token?: string; refresh_token?: string } | null;
      if (!data?.access_token) return null;
      writeRefreshedTokens(data.access_token, data.refresh_token || stored.refreshToken);
      return data.access_token;
    } catch {
      return null;
    }
  })();
  try {
    return await refreshPromise;
  } finally {
    refreshPromise = null;
  }
}

type RequestOpts = RequestInit & {
  accessToken?: string | null;
  query?: Record<string, string | number | boolean | undefined>;
};

async function performRequest<T>(path: string, opts: RequestOpts, isRetry: boolean): Promise<T> {
  const url = new URL(`/v1${path}`, API_BASE_URL);
  if (opts.query) {
    Object.entries(opts.query).forEach(([key, value]) => {
      if (value !== undefined) url.searchParams.set(key, String(value));
    });
  }

  const headers = new Headers(opts.headers || {});
  headers.set("Content-Type", "application/json");
  if (opts.accessToken) headers.set("Authorization", `Bearer ${opts.accessToken}`);

  const res = await fetch(url.toString(), {
    ...opts,
    headers,
    credentials: "include",
    cache: "no-store"
  });

  if (!res.ok) {
    if (res.status === 401 && !isRetry && opts.accessToken) {
      const newToken = await refreshAccessToken();
      if (newToken) return performRequest<T>(path, { ...opts, accessToken: newToken }, true);
    }
    const payload = await res.json().catch(() => null);
    const parsed = ApiErrorSchema.safeParse(payload);
    if (parsed.success) {
      throw new ApiError(parsed.data.error.code, parsed.data.error.message, parsed.data.error.details || { status: res.status });
    }
    // Non-JSON or unexpected-shape error body (e.g. a bare 500, an HTML
    // error page) - still carry the real status through so callers can
    // classify it correctly instead of falling into "unknown".
    throw new ApiError("http_error", `HTTP ${res.status}`, { status: res.status });
  }

  if (res.status === 204) return null as T;
  return (await res.json()) as T;
}

export async function apiRequest<T>(path: string, opts: RequestOpts = {}): Promise<T> {
  return performRequest<T>(path, opts, false);
}

function toError(error: unknown): ClientApiError {
  if (error instanceof ApiError) {
    const status = Number(error.details?.status || 0) || undefined;
    const code = error.code || "unknown";
    const kind: ApiErrorKind =
      code === "unauthorized" || status === 401
        ? "unauthorized"
        : code === "forbidden" || status === 403
          ? "forbidden"
          : code === "validation_error" || status === 422
            ? "validation"
            : status === 429
              ? "rate_limited"
              : status && status >= 500
                ? "server"
                : "unknown";
    return { kind, code, message: error.message, status, details: error.details };
  }
  return { kind: "network", code: "network_error", message: error instanceof Error ? error.message : "Network error" };
}

async function wrap<T>(fn: () => Promise<T>): Promise<Result<T>> {
  try {
    return { ok: true, data: await fn() };
  } catch (error) {
    return { ok: false, error: toError(error) };
  }
}

export function apiGet<T>(path: string, accessToken?: string | null, query?: Record<string, string | number | boolean | undefined>): Promise<Result<T>> {
  return wrap(() => apiRequest<T>(path, { accessToken, query }));
}
export function apiPost<T>(path: string, body: unknown, accessToken?: string | null): Promise<Result<T>> {
  return wrap(() => apiRequest<T>(path, { method: "POST", accessToken, body: JSON.stringify(body) }));
}
export function apiPut<T>(path: string, body: unknown, accessToken?: string | null): Promise<Result<T>> {
  return wrap(() => apiRequest<T>(path, { method: "PUT", accessToken, body: JSON.stringify(body) }));
}

// Cross-cutting instrumentation, not a domain concern - lives on the
// transport rather than any one domain file (matches how it's called from
// pages across several different domains).
export function trackEvent(name: string, props: Record<string, unknown> = {}, accessToken?: string | null): Promise<Result<void>> {
  return apiPost<void>("/analytics", { name, props }, accessToken);
}
