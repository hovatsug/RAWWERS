"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState, type ReactNode } from "react";
import { useQuery } from "@tanstack/react-query";
import { cn } from "@/lib/utils";
import { brand } from "@/lib/brand";
import { Logo } from "@/components/logo";
import { admin } from "@/lib/api/admin";
import { isOpenDispute } from "@/app/admin/labels";
import { activeGroup, activeItem, NAV_GROUPS, type CountKey, type NavGroup } from "@/app/admin/_components/nav";

/**
 * The admin desk: a sidebar of collapsible categories, and a wide page.
 *
 * Replaces the consumer app's phone-width column and bottom tab bar, which
 * the admin pages used to render inside - a six-column price grid scrolling
 * sideways in a 672px column, under a "Discover / Bookings" nav.
 *
 * The categories (app/admin/_components/nav.ts) open and close with a click,
 * Enter or Space. The one holding the current page opens by itself and is
 * marked. What is open is remembered in this browser when it can be; the
 * menu works the same without it. A category shows the sum of its items'
 * waiting counts. On a phone the whole menu folds behind one button.
 */

const STORAGE_KEY = "rawwers_admin_nav_open";

function useQueueCounts(): Record<CountKey, number | null> {
  // The same query keys the pages use, so a decision made on a page updates
  // its count here without a second request.
  const photographers = useQuery({ queryKey: ["admin", "review-queue"], queryFn: () => admin.reviewQueue() });
  const gear = useQuery({ queryKey: ["admin", "gear-queue"], queryFn: () => admin.gearQueue() });
  const payouts = useQuery({ queryKey: ["admin", "payout-queue"], queryFn: () => admin.payoutQueue() });
  const disputes = useQuery({ queryKey: ["admin", "disputes"], queryFn: () => admin.disputes() });
  const money = useQuery({ queryKey: ["admin", "money-attention"], queryFn: () => admin.moneyAttention() });
  const emails = useQuery({ queryKey: ["admin", "failed-emails"], queryFn: () => admin.failedEmails() });

  return {
    photographers: photographers.data?.ok ? photographers.data.data.items.length : null,
    gear: gear.data?.ok ? gear.data.data.items.length : null,
    payouts: payouts.data?.ok ? payouts.data.data.items.filter((p) => p.status === "requested").length : null,
    disputes: disputes.data?.ok && Array.isArray(disputes.data.data) ? disputes.data.data.filter(isOpenDispute).length : null,
    money: money.data?.ok ? money.data.data.items.filter((item) => item.status === "open").length : null,
    // Failed emails not yet dealt with (resent, or a code nobody resends).
    emails: emails.data?.ok ? emails.data.data.items.filter((e) => !e.resent_at && !e.security).length : null
  };
}

type OpenState = Record<string, boolean>;

function readOpen(): OpenState | null {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed: unknown = JSON.parse(raw);
    if (!parsed || typeof parsed !== "object") return null;
    const state: OpenState = {};
    for (const group of NAV_GROUPS) {
      const value = (parsed as Record<string, unknown>)[group.id];
      if (typeof value === "boolean") state[group.id] = value;
    }
    return state;
  } catch {
    return null;
  }
}

function writeOpen(state: OpenState) {
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // No storage (private window, blocked): the menu still works, it just
    // does not remember.
  }
}

function Badge({ count, label }: { count: number; label: string }) {
  return (
    <span
      className="min-w-[1.25rem] rounded-full bg-violet-600/80 px-1.5 text-center text-[11px] font-medium normal-case tracking-normal tabular-nums text-white"
      aria-label={label}
    >
      {count}
    </span>
  );
}

function Chevron({ open }: { open: boolean }) {
  return (
    <svg aria-hidden="true" viewBox="0 0 16 16" className={cn("h-3.5 w-3.5 flex-none text-slate-500", open ? "rotate-90" : "rotate-0")}>
      <path d="M6 4l4 4-4 4" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

const focusRing = "focus:outline-none focus-visible:ring-2 focus-visible:ring-violet-400/60";

export default function AdminLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname() ?? "/admin";
  const counts = useQueueCounts();
  const currentItem = activeItem(pathname);
  const currentGroup = activeGroup(pathname);

  // Before storage is read (and on the server) only the current category is
  // open, so the first paint is the same on both.
  const [open, setOpen] = useState<OpenState>(() => (currentGroup ? { [currentGroup.id]: true } : {}));
  const [phoneMenu, setPhoneMenu] = useState(false);

  useEffect(() => {
    const stored = readOpen();
    if (stored) setOpen((now) => ({ ...stored, ...now }));
  }, []);

  // The category of the page just opened opens by itself; on a phone the
  // menu folds away again once a page is chosen.
  const currentGroupId = currentGroup?.id;
  useEffect(() => {
    setPhoneMenu(false);
    if (!currentGroupId) return;
    setOpen((now) => {
      if (now[currentGroupId]) return now;
      const next = { ...now, [currentGroupId]: true };
      writeOpen(next);
      return next;
    });
  }, [currentGroupId, pathname]);

  const update = (next: OpenState) => {
    setOpen(next);
    writeOpen(next);
  };
  const toggle = (group: NavGroup) => update({ ...open, [group.id]: !open[group.id] });
  const allOpen = NAV_GROUPS.every((group) => open[group.id]);
  const setAll = (value: boolean) => update(Object.fromEntries(NAV_GROUPS.map((group) => [group.id, value])));

  const groupCount = (group: NavGroup) => group.items.reduce((sum, item) => sum + (item.count ? counts[item.count] ?? 0 : 0), 0);

  return (
    <div className="min-h-screen bg-[#08080F] text-slate-200 md:flex">
      <aside className="border-b border-white/10 md:sticky md:top-0 md:flex md:h-screen md:w-60 md:flex-none md:flex-col md:border-b-0 md:border-r">
        <div className="flex items-center justify-between gap-3 px-4 py-4">
          <Link href="/admin" aria-label="RAWWERS admin" className="inline-flex items-end gap-2 text-slate-50">
            <Logo width={brand.logoMinPrimaryWidth} ground="dark" />
            <span className="text-xs font-medium lowercase tracking-wide text-slate-400">admin</span>
          </Link>
          <button
            type="button"
            className={cn("inline-flex min-w-0 items-center gap-2 rounded-md border border-white/15 px-3 py-1.5 text-sm text-slate-200 md:hidden", focusRing)}
            aria-expanded={phoneMenu}
            aria-controls="admin-nav"
            onClick={() => setPhoneMenu((value) => !value)}
          >
            <span className="truncate">{phoneMenu ? "Close menu" : `Menu · ${currentItem?.label ?? currentGroup?.title ?? "Admin"}`}</span>
            <Chevron open={phoneMenu} />
          </button>
        </div>
        <nav
          id="admin-nav"
          aria-label="Admin"
          className={cn("px-3 pb-4 md:block md:min-h-0 md:flex-1 md:overflow-y-auto", phoneMenu ? "block" : "hidden")}
        >
          <div className="mb-1 flex justify-end">
            <button
              type="button"
              className={cn("rounded px-1.5 py-0.5 text-[11px] text-slate-500 hover:text-slate-200", focusRing)}
              onClick={() => setAll(!allOpen)}
            >
              {allOpen ? "Collapse all" : "Expand all"}
            </button>
          </div>
          <ul className="space-y-1">
            {NAV_GROUPS.map((group) => {
              const isOpen = Boolean(open[group.id]);
              const holdsPage = currentGroup?.id === group.id;
              const waiting = groupCount(group);
              return (
                <li key={group.id}>
                  <button
                    type="button"
                    id={`admin-nav-${group.id}`}
                    aria-expanded={isOpen}
                    aria-controls={`admin-nav-${group.id}-items`}
                    data-current={holdsPage ? "true" : undefined}
                    onClick={() => toggle(group)}
                    className={cn(
                      "flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left text-[11px] font-medium uppercase tracking-wider",
                      focusRing,
                      holdsPage ? "bg-white/[0.04] text-violet-300" : "text-slate-500 hover:text-slate-300"
                    )}
                  >
                    <Chevron open={isOpen} />
                    <span className="flex-1">{group.title}</span>
                    {waiting > 0 ? <Badge count={waiting} label={`${waiting} waiting in ${group.title}`} /> : null}
                  </button>
                  <ul
                    id={`admin-nav-${group.id}-items`}
                    aria-labelledby={`admin-nav-${group.id}`}
                    hidden={!isOpen}
                    className="mb-2 ml-3.5 mt-0.5 space-y-0.5 border-l border-white/10 pl-2"
                  >
                    {group.items.map((item) => {
                      const active = currentItem?.href === item.href;
                      const count = item.count ? counts[item.count] : null;
                      return (
                        <li key={item.href}>
                          <Link
                            href={item.href as never}
                            aria-current={active ? "page" : undefined}
                            className={cn(
                              "flex items-center justify-between gap-3 rounded-md px-2 py-1.5 text-sm",
                              focusRing,
                              active ? "bg-white/[0.08] text-slate-50" : "text-slate-400 hover:bg-white/[0.04] hover:text-slate-200"
                            )}
                          >
                            <span>{item.label}</span>
                            {count ? <Badge count={count} label={`${count} waiting`} /> : null}
                          </Link>
                        </li>
                      );
                    })}
                  </ul>
                </li>
              );
            })}
          </ul>
        </nav>
      </aside>
      <main className="min-w-0 flex-1 px-4 py-6 md:px-8">
        <div className="mx-auto max-w-6xl">{children}</div>
      </main>
    </div>
  );
}
