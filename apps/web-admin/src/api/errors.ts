export type ApiErrorCode =
  | "UNAUTHORIZED"
  | "FORBIDDEN"
  | "VALIDATION"
  | "NOT_FOUND"
  | "SERVER"
  | "NETWORK"
  | "UNKNOWN";

export interface ApiError {
  code: ApiErrorCode;
  status?: number;
  message: string;
  details?: unknown;
}

export function toApiError(status: number, payload?: any): ApiError {
  const message = payload?.detail || payload?.message || "Request failed";
  if (status === 401) return { code: "UNAUTHORIZED", status, message };
  if (status === 403) return { code: "FORBIDDEN", status, message };
  if (status === 404) return { code: "NOT_FOUND", status, message };
  if (status === 422) return { code: "VALIDATION", status, message, details: payload };
  if (status >= 500) return { code: "SERVER", status, message };
  return { code: "UNKNOWN", status, message, details: payload };
}
