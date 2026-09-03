"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import type { ReactNode } from "react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/lib/auth/store";
import { auth } from "@/lib/api/auth";

export function AppShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const isLanding = pathname === "/";
  const { roles, accessToken, refreshToken, clearSession } = useAuth();
  const links = [
    { href: "/discover", label: "Discover", show: true },
    { href: "/client/bookings", label: "Bookings", show: roles.includes("client") },
    { href: "/pro/inbox", label: "Pro Inbox", show: roles.includes("pro") },
    { href: "/admin", label: "Admin", show: roles.includes("admin") },
    { href: "/client/notifications", label: "Alerts", show: roles.includes("client") || roles.includes("pro") }
  ];

  return (
    <div className={cn("min-h-screen", isLanding ? "pb-0" : "pb-20")}>
      <main className={cn(isLanding ? "" : "container-mobile py-4")}>{children}</main>
      {isLanding ? null : (
        <nav className="fixed bottom-0 left-0 right-0 border-t border-white/[0.08] bg-[#08080F]/80 backdrop-blur-2xl">
          <div className="container-mobile flex items-center justify-between py-3">
            {links.filter((link) => link.show).map((link) => (
              <Link
                key={link.href}
                href={link.href as any}
                className={cn(
                  "text-xs font-medium transition-colors duration-200",
                  pathname.startsWith(link.href)
                    ? "text-violet-400"
                    : "text-slate-500 hover:text-slate-300"
                )}
              >
                {link.label}
              </Link>
            ))}
            {accessToken ? (
              <button
                className="text-xs font-medium text-slate-500 hover:text-slate-300 transition-colors duration-200"
                onClick={async () => {
                  await auth.logout(refreshToken, accessToken);
                  clearSession();
                }}
              >
                Logout
              </button>
            ) : null}
          </div>
        </nav>
      )}
    </div>
  );
}
