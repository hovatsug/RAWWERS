/**
 * The admin menu: every admin page, in collapsible categories.
 *
 * Only pages that exist are listed. A link to a page that is not built yet
 * is a dead end with a label on it. Every page under app/admin is either an
 * item here or a deeper page of one (`also`), which
 * tests/e2e/admin-menu.spec.ts checks against the files themselves.
 */

/** Which waiting count an item shows (the layout fills them in). */
export type CountKey = "photographers" | "gear" | "payouts" | "disputes" | "money" | "emails";

export type NavItem = {
  href: string;
  label: string;
  count?: CountKey;
  /** Deeper pages that belong to this item: path prefixes. */
  also?: string[];
};

export type NavGroup = { id: string; title: string; items: NavItem[]; also?: string[] };

export const NAV_GROUPS: NavGroup[] = [
  {
    id: "business",
    title: "Overview and Business",
    items: [
      { href: "/admin/bi", label: "Dashboard", also: ["/admin/bi/bookings"] },
      { href: "/admin/bi/costs", label: "Costs & company cash" }
    ]
  },
  {
    id: "people",
    title: "People",
    items: [
      { href: "/admin", label: "Photographers", count: "photographers", also: ["/admin/pros/"] },
      { href: "/admin/gear", label: "Gear", count: "gear" }
    ]
  },
  {
    id: "money",
    title: "Bookings and Money",
    // A booking's page is reached from disputes, money to act on and the
    // dashboard's bookings; it belongs to this category, not to one item.
    also: ["/admin/bookings/"],
    items: [
      { href: "/admin/payouts", label: "Payouts", count: "payouts" },
      { href: "/admin/disputes", label: "Disputes", count: "disputes" },
      { href: "/admin/money-attention", label: "Money to act on", count: "money" },
      { href: "/admin/client-credit", label: "Client credit" }
    ]
  },
  {
    id: "trust",
    title: "Trust and Content",
    items: [
      { href: "/admin/reviews", label: "Reviews" },
      { href: "/admin/marketing", label: "Marketing library" },
      { href: "/admin/marketing-wording", label: "Marketing wording" }
    ]
  },
  {
    id: "shelf",
    title: "Shelf and RAWW",
    items: [
      { href: "/admin/shelf/orders", label: "Shelf orders" },
      { href: "/admin/shelf/items", label: "Shelf items" },
      { href: "/admin/shelf/raww", label: "RAWW ledger" },
      { href: "/admin/shelf/settings", label: "Shelf settings" }
    ]
  },
  {
    id: "operations",
    title: "Operations",
    items: [{ href: "/admin/emails", label: "Failed emails", count: "emails" }]
  },
  {
    id: "settings",
    title: "Settings",
    items: [
      { href: "/admin/pricing", label: "Price caps" },
      { href: "/admin/galleries", label: "Galleries" },
      { href: "/admin/niches", label: "Niche banners" },
      { href: "/admin/interview-questions", label: "Interview questions" },
      { href: "/admin/accountability", label: "Accountability policy" },
      { href: "/admin/camera-models", label: "Camera reference" }
    ]
  }
];

const under = (pathname: string, prefix: string) =>
  prefix.endsWith("/") ? pathname.startsWith(prefix) : pathname === prefix || pathname.startsWith(`${prefix}/`);

/** The item for this page: its own path, or one of its deeper pages. The
 *  longest match wins, so /admin/bi/costs is Costs, not the Dashboard. */
export function activeItem(pathname: string): NavItem | null {
  let best: { item: NavItem; length: number } | null = null;
  for (const group of NAV_GROUPS) {
    for (const item of group.items) {
      const exact = item.href === "/admin" ? pathname === "/admin" : under(pathname, item.href);
      const deeper = (item.also ?? []).some((prefix) => under(pathname, prefix));
      const length = exact ? item.href.length : deeper ? Math.max(...(item.also ?? []).map((p) => (under(pathname, p) ? p.length : 0))) : 0;
      if ((exact || deeper) && (!best || length > best.length)) best = { item, length };
    }
  }
  return best?.item ?? null;
}

/** The category holding this page, by its item or its own deeper pages. */
export function activeGroup(pathname: string): NavGroup | null {
  const item = activeItem(pathname);
  if (item) return NAV_GROUPS.find((group) => group.items.includes(item)) ?? null;
  return NAV_GROUPS.find((group) => (group.also ?? []).some((prefix) => under(pathname, prefix))) ?? null;
}
