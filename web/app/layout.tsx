import "@/styles/globals.css";
import type { Metadata } from "next";
import type { ReactNode } from "react";
import { AppProviders } from "./providers";
import { AppShell } from "@/components/app-shell";
import { Guard } from "@/components/guard";

export const metadata: Metadata = {
  title: "RAWWERS",
  description: "RAWWERS mobile-first web app",
  manifest: "/manifest.webmanifest"
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en-GB">
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
