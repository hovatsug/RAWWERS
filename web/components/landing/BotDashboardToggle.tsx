"use client";

import Image from "next/image";
import { useState } from "react";
import { Card } from "@/design-system/primitives";
import { track } from "@/lib/analytics/client";

export function BotDashboardToggle() {
  const [view, setView] = useState<"bot" | "dashboard">("bot");

  const selectView = (next: "bot" | "dashboard") => {
    setView(next);
    track("toggle_view", { view: next });
  };

  return (
    <div className="space-y-4">
      <div className="inline-flex rounded-lg border border-neutral-200 bg-white p-1">
        <button
          className={`rounded-md px-4 py-2 text-sm ${view === "bot" ? "bg-brand-600 text-white" : "text-neutral-700"}`}
          onClick={() => selectView("bot")}
          aria-label="Show bot view"
        >
          Bot view
        </button>
        <button
          className={`rounded-md px-4 py-2 text-sm ${view === "dashboard" ? "bg-brand-600 text-white" : "text-neutral-700"}`}
          onClick={() => selectView("dashboard")}
          aria-label="Show dashboard view"
        >
          Dashboard view
        </button>
      </div>

      <Card className="border border-neutral-200 p-3">
        <Image
          src={view === "bot" ? "/assets/bot.png" : "/assets/dashboard.png"}
          alt={view === "bot" ? "PACT Telegram bot screen mock" : "PACT dashboard screen mock"}
          width={1200}
          height={720}
          className="h-auto w-full rounded-md"
          loading="lazy"
        />
        <p className="mt-3 text-sm text-neutral-700">Everything is logged. Nothing is erased.</p>
      </Card>
    </div>
  );
}

