"use client";

import Image from "next/image";
import { useState } from "react";
import { Card } from "@/design-system/primitives";
import { track } from "@/lib/analytics/client";

export function ScreenshotToggle() {
  const [view, setView] = useState<"bot" | "dashboard">("bot");

  return (
    <div className="space-y-4">
      <div className="inline-flex rounded-lg border border-neutral-200 bg-white p-1">
        <button
          className={`rounded-md px-4 py-2 text-sm ${view === "bot" ? "bg-brand-600 text-white" : "text-neutral-700"}`}
          onClick={() => {
            setView("bot");
            track("screenshot_toggle", { view: "bot" });
          }}
        >
          Bot view
        </button>
        <button
          className={`rounded-md px-4 py-2 text-sm ${view === "dashboard" ? "bg-brand-600 text-white" : "text-neutral-700"}`}
          onClick={() => {
            setView("dashboard");
            track("screenshot_toggle", { view: "dashboard" });
          }}
        >
          Dashboard view
        </button>
      </div>

      <Card className="border border-neutral-200 p-3">
        {view === "bot" ? (
          <Image
            src="/assets/bot.png"
            alt="PACT Telegram bot screenshot placeholder"
            width={1200}
            height={720}
            className="h-auto w-full rounded-md"
            loading="lazy"
          />
        ) : (
          <Image
            src="/assets/dashboard.png"
            alt="PACT dashboard screenshot placeholder"
            width={1200}
            height={720}
            className="h-auto w-full rounded-md"
            loading="lazy"
          />
        )}
        <p className="mt-3 text-sm text-neutral-700">Everything is logged. Nothing is erased.</p>
      </Card>
    </div>
  );
}

