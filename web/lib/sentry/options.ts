import { scrubBreadcrumb, scrubEvent } from "@/lib/sentry/scrub";

/**
 * Shared Sentry options. Off unless a DSN is set: NEXT_PUBLIC_SENTRY_DSN for
 * the browser (inlined at build time), SENTRY_DSN (or the public one) on the
 * server. EU region: the Sentry organisation is created in the EU, so its
 * DSNs end in .de.sentry.io. docs/DEPLOY_CHECKLIST.md.
 */
export function sentryOptions(dsn: string | undefined) {
  return {
    dsn,
    enabled: Boolean(dsn),
    environment: process.env.NEXT_PUBLIC_SENTRY_ENVIRONMENT || process.env.NODE_ENV,
    release: process.env.NEXT_PUBLIC_SENTRY_RELEASE || undefined,
    sendDefaultPii: false,
    tracesSampleRate: 0,
    beforeSend: scrubEvent,
    beforeBreadcrumb: scrubBreadcrumb,
    initialScope: { tags: { component: "web" } }
  };
}
