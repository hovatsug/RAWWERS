"use client";

import { useEffect, useState } from "react";
import { track } from "@/lib/analytics/client";

const THRESHOLDS = [25, 50, 75, 90];

export function ScrollProgress() {
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const fired = new Set<number>();
    const onScroll = () => {
      const total = document.documentElement.scrollHeight - window.innerHeight;
      if (total <= 0) return;
      const pct = Math.min(100, Math.max(0, Math.round((window.scrollY / total) * 100)));
      setProgress(pct);

      for (const t of THRESHOLDS) {
        if (pct >= t && !fired.has(t)) {
          fired.add(t);
          track(`lp_scroll_${t}`);
        }
      }
    };

    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <>
      <div aria-hidden className="fixed left-0 right-0 top-0 z-50 h-1 bg-neutral-200">
        <div className="h-full bg-brand-600 transition-[width] duration-150" style={{ width: `${progress}%` }} />
      </div>
      <div className="fixed right-3 top-3 z-50 rounded-full bg-white/90 px-2 py-1 text-xs text-neutral-700 shadow-card">{progress}%</div>
    </>
  );
}

