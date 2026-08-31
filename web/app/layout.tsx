import "@/styles/globals.css";
import type { Metadata } from "next";
import type { ReactNode } from "react";
import { Fraunces, Inter } from "next/font/google";
import { AppProviders } from "./providers";
import { AppShell } from "@/components/app-shell";
import { Guard } from "@/components/guard";

const fraunces = Fraunces({
  subsets: ["latin"],
  variable: "--font-fraunces",
  weight: ["400", "500", "600"],
  style: ["normal", "italic"],
  display: "swap"
});

const inter = Inter({
  subsets: ["latin"],
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
