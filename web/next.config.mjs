import withPWA from "next-pwa";

const isDev = process.env.NODE_ENV === "development";

const nextConfig = {
  reactStrictMode: true,
  experimental: {
    typedRoutes: true
  },
  // The web is the admin panel and the landing page (owner's decision,
  // 2026-11-08). The old client rewards page dumped the raw ledger and the
  // point balance; credit lives in the app now, in euros.
  // scripts/check-web-user-pages.sh keeps this redirect in place.
  async redirects() {
    return [{ source: "/rewards", destination: "/get-the-app", permanent: false }];
  }
};

export default withPWA({
  dest: "public",
  disable: isDev,
  register: true,
  skipWaiting: true
})(nextConfig);
