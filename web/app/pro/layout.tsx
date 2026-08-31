"use client";

import type { ReactNode } from "react";
import { usePathname } from "next/navigation";

const links = [
  { href: "/pro/dashboard", label: "Dashboard" },
  { href: "/pro/leads", label: "Leads" },
  { href: "/pro/gigs", label: "Gigs" },
  { href: "/pro/calendar", label: "Calendar" },
  { href: "/pro/wallet", label: "Wallet" },
  { href: "/pro/profile", label: "Profile" },
];

export default function ProLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const isAuthPage = pathname === "/pro/login" || pathname === "/pro/register";

  if (isAuthPage) return <>{children}</>;

  return (
    <div className="grid grid-cols-1 gap-4 bg-canvas md:grid-cols-[220px_minmax(0,1fr)]">
      <aside className="rounded-card border border-line bg-surface p-4">
        <p className="mb-4 text-sm font-semibold text-ink">RAWWERS Pro</p>
        <nav className="space-y-1">
          {links.map((link) => {
            const active = pathname === link.href || pathname.startsWith(`${link.href}/`);
            return (
              <a
                key={link.href}
                href={link.href}
                className={`block border-l-2 px-3 py-2 text-sm transition-colors duration-200 ${
                  active ? "border-accent text-ink" : "border-transparent text-muted hover:text-ink"
                }`}
              >
                {link.label}
              </a>
            );
          })}
        </nav>
      </aside>
      <section className="space-y-4">
        <div className="rounded-card border border-line bg-surface px-5 py-4">
          <p className="text-xs uppercase tracking-wide text-muted">Pro workspace</p>
          <p className="text-lg font-semibold text-ink">{links.find((l) => pathname.startsWith(l.href))?.label || "Overview"}</p>
        </div>
        {children}
      </section>
    </div>
  );
}
