"use client";

import { usePathname } from "next/navigation";
import { useEffect } from "react";
import { trackEvent } from "@/api/routes/analytics";

export function PageViewTracker() {
  const pathname = usePathname();

  useEffect(() => {
    if (!pathname.startsWith("/admin")) return;
    trackEvent({ name: "admin_page_view", props: { path: pathname } }).catch(() => undefined);
  }, [pathname]);

  return null;
}
