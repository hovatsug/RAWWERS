"use client";

import { track } from "@/lib/analytics/client";

const TELEGRAM_BOT_URL = process.env.NEXT_PUBLIC_TELEGRAM_BOT_URL || "https://t.me/your_bot";
const WEBAPP_URL = process.env.NEXT_PUBLIC_WEBAPP_URL || "/link";

export function primaryCta(sectionId: string) {
  track("cta_click_primary", { section_id: sectionId });
  window.open(TELEGRAM_BOT_URL, "_blank", "noopener,noreferrer");
}

export function secondaryCta(sectionId: string) {
  track("cta_click_secondary", { section_id: sectionId });
  if (WEBAPP_URL.startsWith("http://") || WEBAPP_URL.startsWith("https://")) {
    window.open(WEBAPP_URL, "_blank", "noopener,noreferrer");
    return;
  }
  const target = document.getElementById("connect-dashboard");
  if (target) {
    target.scrollIntoView({ behavior: "smooth", block: "start" });
    return;
  }
  window.location.assign(WEBAPP_URL);
}
