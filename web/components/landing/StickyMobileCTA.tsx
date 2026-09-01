"use client";

import { Button } from "@/design-system/primitives";

export function StickyMobileCTA({ onClick }: { onClick: () => void }) {
  return (
    <div className="fixed bottom-0 left-0 right-0 z-40 border-t border-neutral-200 bg-white/95 p-3 sm:hidden">
      <Button
        className="w-full py-3 text-sm font-semibold focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600"
        onClick={onClick}
        aria-label="Start in Telegram"
      >
        Start in Telegram
      </Button>
      <p className="mt-1 text-center text-xs text-neutral-600">Start in Telegram. Connect dashboard in 2 minutes.</p>
    </div>
  );
}

