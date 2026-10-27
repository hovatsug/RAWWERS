"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import type { ReactNode } from "react";
import { useQuery } from "@tanstack/react-query";
import { cn } from "@/lib/utils";
import { brand } from "@/lib/brand";
import { Logo } from "@/components/logo";
import { admin } from "@/lib/api/admin";
import { isOpenDispute } from "@/app/admin/labels";

/**
 * The admin desk: a sidebar grouped by the kind of work, and a wide page.
 *
 * Replaces the consumer app's phone-width column and bottom tab bar, which
 * the admin pages used to render inside - a six-column price grid scrolling
 * sideways in a 672px column, under a "Discover / Bookings" nav.
 *
 * Only pages that exist are listed. A link to a page that is not built yet
 * is a dead end with a label on it.
 */

type NavItem = { href: string; label: string; count?: number | null };

function useQueueCounts() {
  // The same query keys the pages use, so a decision made on a page updates
  // its count here without a second request.
  const photographers = useQuery({ queryKey: ["admin", "review-queue"], queryFn: () => admin.reviewQueue() });
  const gear = useQuery({ queryKey: ["admin", "gear-queue"], queryFn: () => admin.gearQueue() });
  const payouts = useQuery({ queryKey: ["admin", "payout-queue"], queryFn: () => admin.payoutQueue() });
  const disputes = useQuery({ queryKey: ["admin", "disputes"], queryFn: () => admin.disputes() });
  const money = useQuery({ queryKey: ["admin", "money-attention"], queryFn: () => admin.moneyAttention() });

  return {
    photographers: photographers.data?.ok ? photographers.data.data.items.length : null,
    gear: gear.data?.ok ? gear.data.data.items.length : null,
    payouts: payouts.data?.ok ? payouts.data.data.items.filter((p) => p.status === "requested").length : null,
    disputes: disputes.data?.ok && Array.isArray(disputes.data.data) ? disputes.data.data.filter(isOpenDispute).length : null,
    money: money.data?.ok ? money.data.data.items.filter((item) => item.status === "open").length : null
  };
}

export default function AdminLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const counts = useQueueCounts();

  const groups: { title: string; items: NavItem[] }[] = [
    {
      title: "Approvals",
      items: [
        { href: "/admin", label: "Photographers", count: counts.photographers },
        { href: "/admin/gear", label: "Gear", count: counts.gear }
      ]
    },
    {
      title: "Moderation",
      items: [{ href: "/admin/reviews", label: "Reviews" }]
    },
    {
      title: "Money",
      items: [
        { href: "/admin/payouts", label: "Payouts", count: counts.payouts },
        { href: "/admin/disputes", label: "Disputes", count: counts.disputes },
        { href: "/admin/money-attention", label: "Money to act on", count: counts.money }
      ]
    },
    {
      title: "Catalog & pricing",
      items: [
        { href: "/admin/pricing", label: "Price caps" },
        { href: "/admin/niches", label: "Niche banners" },
        { href: "/admin/interview-questions", label: "Interview questions" },
        { href: "/admin/accountability", label: "Accountability policy" },
        { href: "/admin/camera-models", label: "Camera reference" }
      ]
    }
  ];

  const isActive = (href: string) =>
    href === "/admin" ? pathname === "/admin" || pathname.startsWith("/admin/pros") : pathname.startsWith(href);

  return (
    <div className="min-h-screen bg-[#08080F] text-slate-200 md:flex">
      <aside className="border-b border-white/10 md:sticky md:top-0 md:h-screen md:w-56 md:flex-none md:border-b-0 md:border-r">
        <div className="px-4 py-4">
          <Link href="/admin" aria-label="RAWWERS admin" className="inline-flex items-end gap-2 text-slate-50">
            <Logo width={brand.logoMinPrimaryWidth} ground="dark" />
            <span className="text-xs font-medium lowercase tracking-wide text-slate-400">admin</span>
          </Link>
        </div>
        <nav aria-label="Admin" className="flex gap-6 overflow-x-auto px-4 pb-4 md:block md:space-y-5 md:overflow-visible">
          {groups.map((group) => (
            <div key={group.title} className="min-w-max">
              <p className="mb-1.5 text-[11px] font-medium uppercase tracking-wider text-slate-500">{group.title}</p>
              <ul className="flex gap-1 md:block md:space-y-0.5">
                {group.items.map((item) => (
                  <li key={item.href}>
                    <Link
                      href={item.href as never}
                      aria-current={isActive(item.href) ? "page" : undefined}
                      className={cn(
                        "flex items-center justify-between gap-3 rounded-md px-2 py-1.5 text-sm",
                        isActive(item.href)
                          ? "bg-white/[0.08] text-slate-50"
                          : "text-slate-400 hover:bg-white/[0.04] hover:text-slate-200"
                      )}
                    >
                      <span>{item.label}</span>
                      {item.count ? (
                        <span
                          className="rounded-full bg-violet-600/80 px-1.5 text-[11px] font-medium tabular-nums text-white"
                          aria-label={`${item.count} waiting`}
                        >
                          {item.count}
                        </span>
                      ) : null}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </nav>
      </aside>
      <main className="min-w-0 flex-1 px-4 py-6 md:px-8">
        <div className="mx-auto max-w-6xl">{children}</div>
      </main>
    </div>
  );
}
