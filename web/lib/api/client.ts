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

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000";

export async function apiRequest<T>(
  path: string,
  opts: RequestInit & { accessToken?: string | null; query?: Record<string, string | number | boolean | undefined> } = {}
): Promise<T> {
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
    const payload = await res.json().catch(() => null);
    const parsed = ApiErrorSchema.safeParse(payload);
    if (parsed.success) {
      throw new ApiError(parsed.data.error.code, parsed.data.error.message, parsed.data.error.details || {});
    }
    throw new ApiError("http_error", `HTTP ${res.status}`);
  }

  if (res.status === 204) return null as T;
  return (await res.json()) as T;
}
