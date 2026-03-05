import { ApiError } from "@/api/errors";
import { InlineBanner } from "@/components/feedback/InlineBanner";

export function ApiErrorBanner({ error }: { error: unknown }) {
  const apiError = (error || {}) as ApiError;
  const status = apiError.status || 0;
  if (!status || ![401, 403, 500, 502, 503, 504].includes(status)) return null;
  return (
    <InlineBanner
      variant="danger"
      text={`${status === 401 ? "Unauthorized" : status === 403 ? "Forbidden" : "Server error"}: ${apiError.message || "Please retry."}`}
    />
  );
}
