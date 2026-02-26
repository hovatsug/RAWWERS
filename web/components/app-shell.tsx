"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import type { ReactNode } from "react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/lib/auth/store";
import { endpoints } from "@/lib/api/endpoints";

export function AppShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const { roles, accessToken, refreshToken, clearSession } = useAuth();
  const links = [
    { href: "/discover", label: "Discover", show: true },
    { href: "/client/bookings", label: "Bookings", show: roles.includes("client") },
    { href: "/pro/inbox", label: "Pro Inbox", show: roles.includes("pro") },
    { href: "/admin", label: "Admin", show: roles.includes("admin") },
    { href: "/client/notifications", label: "Alerts", show: roles.includes("client") || roles.includes("pro") }
  ];

  return (
    <div className="min-h-screen pb-16">
      <main className="container-mobile py-4">{children}</main>
      <nav className="fixed bottom-0 left-0 right-0 border-t border-neutral-200 bg-white">
        <div className="container-mobile flex items-center justify-between py-2">
          {links.filter((link) => link.show).map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className={cn("text-xs", pathname.startsWith(link.href) ? "text-brand-700" : "text-neutral-600")}
            >
              {link.label}
            </Link>
          ))}
          {accessToken ? (
            <button
              className="text-xs text-neutral-600"
              onClick={async () => {
                await endpoints.logout(refreshToken, accessToken).catch(() => undefined);
                clearSession();
              }}
            >
              Logout
            </button>
          ) : null}
        </div>
      </nav>
    </div>
  );
}
