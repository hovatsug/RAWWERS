import "@/styles/globals.css";
import type { Metadata } from "next";
import type { ReactNode } from "react";
import localFont from "next/font/local";
import { AppProviders } from "./providers";
import { AppShell } from "@/components/app-shell";
import { Guard } from "@/components/guard";

// Self-hosted (OFL, web/fonts/, from @fontsource-variable 5.2.x latin
// files), so a build needs no network beyond the package registry; it used
// to download them from Google Fonts at build time.
const fraunces = localFont({
  src: [
    { path: "../fonts/fraunces-latin-wght-normal.woff2", weight: "100 900", style: "normal" },
    { path: "../fonts/fraunces-latin-wght-italic.woff2", weight: "100 900", style: "italic" }
  ],
  variable: "--font-fraunces",
  display: "swap"
});

const inter = localFont({
  src: [{ path: "../fonts/inter-latin-wght-normal.woff2", weight: "100 900", style: "normal" }],
  variable: "--font-inter",
  display: "swap"
});

export const metadata: Metadata = {
  title: "RAWWERS",
  description: "RAWWERS mobile-first web app",
  manifest: "/manifest.webmanifest"
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en-GB" className={`${fraunces.variable} ${inter.variable}`}>
      <body>
        <AppProviders>
          <Guard>
            <AppShell>{children}</AppShell>
          </Guard>
        </AppProviders>
      </body>
    </html>
  );
}
