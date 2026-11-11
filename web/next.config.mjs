import { withSentryConfig } from "@sentry/nextjs";
import withPWA from "next-pwa";

const isDev = process.env.NODE_ENV === "development";

// Routes of the removed client and pro pages, each with everything under it.
export const REMOVED_PAGES = [
  "/bookings",
  "/chat",
  "/client",
  "/discover",
  "/disputes",
  "/gigs",
  "/notifications",
  "/pro",
  "/pros",
  "/rewards",
  "/search",
  "/settings"
];

const nextConfig = {
  reactStrictMode: true,
  experimental: {
    typedRoutes: true,
    // instrumentation.ts starts Sentry on the server (off without a DSN).
    instrumentationHook: true
  },
  // The web is the admin panel and the landing page (owner's decisions,
  // 2026-11-08). The old client and pro pages (raw JSON over the API, the
  // rewards ledger among them) are gone; each of their routes sends people
  // to the app. Kept: the landing, login, register, reset password, verify
  // email, unsubscribe, share, waitlist and the admin.
  // scripts/check-web-user-pages.sh holds this list to the app/ folder.
  async redirects() {
    return REMOVED_PAGES.flatMap((base) => [
      { source: base, destination: "/get-the-app", permanent: false },
      { source: `${base}/:path*`, destination: "/get-the-app", permanent: false }
    ]);
  }
};

const withPwa = withPWA({
  dest: "public",
  disable: isDev,
  register: true,
  skipWaiting: true
})(nextConfig);

// Error reporting (sentry.*.config.ts, off without a DSN). No source maps are
// uploaded and no build step talks to Sentry: nothing here needs a token.
export default withSentryConfig(withPwa, {
  silent: true,
  telemetry: false,
  sourcemaps: { disable: true },
  disableLogger: true,
  autoInstrumentMiddleware: false
});
