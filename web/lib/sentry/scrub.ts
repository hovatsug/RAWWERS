/**
 * What may leave in a Sentry event from the web (admin panel and landing),
 * the same rules as the API's (api/app/core/sentry.py): no default PII,
 * every value under a sensitive key filtered at any depth, emails and
 * bearer tokens masked inside strings, the user reduced to an id.
 */
import type { ErrorEvent, Breadcrumb } from "@sentry/nextjs";

export const FILTERED = "[Filtered]";

const SENSITIVE_PARTS = [
  "authorization", "cookie", "password", "passwd", "secret", "token", "api_key", "apikey", "api-key",
  "x-admin-api-key", "signature", "dsn", "otp", "session", "csrf", "iban", "card"
];
const SENSITIVE_EXACT = new Set(["code", "s", "k", "sig", "key", "email", "to_email", "to", "phone", "phone_e164"]);

const EMAIL = /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/g;
const BEARER = /\bbearer\s+[A-Za-z0-9._~+/=-]+/gi;
const JWT = /\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g;

function sensitive(key: string): boolean {
  const k = key.toLowerCase();
  return SENSITIVE_EXACT.has(k) || SENSITIVE_PARTS.some((p) => k.includes(p));
}

export function scrubText(value: string): string {
  return value.replace(BEARER, "Bearer [Filtered]").replace(JWT, "[jwt]").replace(EMAIL, "[email]");
}

function scrubQuery(qs: string): string {
  const params = new URLSearchParams(qs);
  const out = new URLSearchParams();
  params.forEach((v, k) => out.append(k, sensitive(k) ? FILTERED : scrubText(v)));
  return out.toString();
}

export function scrub<T>(value: T, depth = 0): T {
  if (depth > 20) return FILTERED as unknown as T;
  if (typeof value === "string") return scrubText(value) as unknown as T;
  if (Array.isArray(value)) {
    if (value.length === 2 && typeof value[0] === "string" && sensitive(value[0])) return [value[0], FILTERED] as unknown as T;
    return value.map((v) => scrub(v, depth + 1)) as unknown as T;
  }
  if (value && typeof value === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) out[k] = sensitive(k) ? FILTERED : scrub(v, depth + 1);
    return out as T;
  }
  return value;
}

export function scrubEvent(event: ErrorEvent): ErrorEvent {
  const tags = event.tags;
  const request = event.request;
  if (request) {
    if (typeof request.query_string === "string") request.query_string = scrubQuery(request.query_string);
    if (typeof request.url === "string" && request.url.includes("?")) {
      const [base, qs] = request.url.split("?", 2);
      request.url = `${base}?${scrubQuery(qs)}`;
    }
    delete request.cookies;
    if (typeof request.data === "string") request.data = FILTERED;
  }
  if (event.user) event.user = event.user.id ? { id: event.user.id } : {};
  const { tags: _t, ...rest } = event;
  return { ...scrub(rest), tags } as ErrorEvent;
}

export function scrubBreadcrumb(crumb: Breadcrumb): Breadcrumb {
  return scrub(crumb);
}
