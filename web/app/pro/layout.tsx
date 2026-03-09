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
    <div className="grid grid-cols-1 gap-4 md:grid-cols-[220px_minmax(0,1fr)]">
      <aside className="rounded-2xl border border-black/10 bg-white p-4">
        <p className="mb-4 text-sm font-semibold text-neutral-900">RAWWERS Pro</p>
        <nav className="space-y-1">
          {links.map((link) => {
            const active = pathname === link.href || pathname.startsWith(`${link.href}/`);
            return (
              <a
                key={link.href}
                href={link.href}
                className={`block rounded-xl px-3 py-2 text-sm transition ${active ? "bg-brand-50 text-brand-700" : "text-neutral-700 hover:bg-neutral-50"}`}
              >
                {link.label}
              </a>
            );
          })}
        </nav>
      </aside>
      <section className="space-y-4">
        <div className="rounded-2xl border border-black/10 bg-[#F5F5F7] px-5 py-4">
          <p className="text-xs uppercase tracking-wide text-neutral-500">Pro Workspace</p>
          <p className="text-lg font-semibold text-neutral-900">{links.find((l) => pathname.startsWith(l.href))?.label || "Overview"}</p>
        </div>
        {children}
      </section>
    </div>
  );
}
