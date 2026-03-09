import { ApiError, toApiError } from "@/api/errors";
import { refreshSession } from "@/core/auth/session";
import { clearAuthTokens, getAccessToken } from "@/core/auth/tokenStore";

type ParseMode = "json" | "text";

export interface RequestOptions extends Omit<RequestInit, "body"> {
  body?: unknown;
  authRetry?: boolean;
  parseAs?: ParseMode;
}

const BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "";

function reqId() {
  return `${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

async function parseResponse(response: Response, parseAs: ParseMode) {
  if (response.status === 204) return null;
  if (parseAs === "text") return response.text();
  const text = await response.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    return { raw: text };
  }
}

export async function request<T = unknown>(path: string, options: RequestOptions = {}): Promise<T> {
  const { body, headers, authRetry = true, parseAs = "json", ...rest } = options;
  const url = `${BASE_URL}${path}`;

  const doFetch = async () => {
    const accessToken = getAccessToken();
    const response = await fetch(url, {
      ...rest,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        "X-Request-Id": reqId(),
        ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}),
        ...(headers || {})
      },
      body: body === undefined ? undefined : JSON.stringify(body)
    });

    if (!response.ok) {
      const errorPayload = await parseResponse(response, "json");
      throw toApiError(response.status, errorPayload);
    }

    return parseResponse(response, parseAs) as Promise<T>;
  };

  try {
    return await doFetch();
  } catch (error) {
    const apiError = error as ApiError;
    if (apiError.code === "UNAUTHORIZED" && authRetry) {
      const refreshed = await refreshSession();
      if (refreshed) return doFetch();
      clearAuthTokens();
    }
    throw error;
  }
}
