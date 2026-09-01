"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";

const sections = [
  { title: "Overview", items: [{ href: "/admin/dashboard", label: "Dashboard" }] },
  {
    title: "Users",
    items: [
      { href: "/admin/users", label: "Users" },
      { href: "/admin/onboarding-pros", label: "Onboarding (Pros)" }
    ]
  },
  {
    title: "Finance",
    items: [{ href: "/admin/payouts", label: "Payouts & Fee Policy" }]
  },
  {
    title: "Trust & Safety",
    items: [
      { href: "/admin/disputes", label: "Disputes" },
      { href: "/admin/refunds", label: "Refunds" },
      { href: "/admin/abuse-signals", label: "Abuse Signals" },
      { href: "/admin/risk", label: "Risk" }
    ]
  },
  {
    title: "Platform",
    items: [
      { href: "/admin/feature-flags", label: "Feature Flags" },
      { href: "/admin/ai-flags", label: "AI Feature Flags" },
      { href: "/admin/rollout", label: "Rollout (Cities)" },
      { href: "/admin/search-ops", label: "Search Ops" },
      { href: "/admin/notifications", label: "Notifications Logs" },
      { href: "/admin/consent-events", label: "Consent Events" },
      { href: "/admin/rewards", label: "Rewards" },
      { href: "/admin/invites", label: "Invites" },
      { href: "/admin/impersonation", label: "Impersonation" },
      { href: "/admin/i18n", label: "I18N" }
    ]
  },
  {
    title: "Commerce",
    items: [
      { href: "/admin/prints", label: "Prints" },
      { href: "/admin/store", label: "Store" }
    ]
  },
  {
    title: "Creator Economy",
    items: [
      { href: "/admin/studioverse", label: "Studioverse" },
      { href: "/admin/repairs", label: "Repairs" }
    ]
  },
  { title: "Token", items: [{ href: "/admin/raww", label: "RAWW" }] }
];

export function Sidebar() {
  const pathname = usePathname();
  return (
    <aside className="h-screen w-72 shrink-0 border-r border-borderSubtle bg-surface/80 p-5 backdrop-blur">
      <div className="mb-6 px-3 text-sm font-semibold text-textSecondary">RAWWERS Admin</div>
      <div className="space-y-4 overflow-auto pb-8">
        {sections.map((section) => (
          <div key={section.title}>
            <div className="px-3 pb-2 text-xs uppercase tracking-wide text-textSecondary">{section.title}</div>
            <div className="space-y-1">
              {section.items.map((item) => {
                const active = pathname === item.href || pathname.startsWith(`${item.href}/`);
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={cn(
                      "block rounded-xl px-3 py-2 text-sm transition",
                      active
                        ? "bg-accent/10 text-accent"
                        : "text-textSecondary hover:bg-surface2 hover:text-textPrimary"
                    )}
                  >
                    {item.label}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </div>
    </aside>
  );
}
