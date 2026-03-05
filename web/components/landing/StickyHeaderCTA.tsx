"use client";

import { Button } from "@/design-system/primitives";

type Props = {
  onPrimary: () => void;
  onSecondary: () => void;
};

export function StickyHeaderCTA({ onPrimary, onSecondary }: Props) {
  return (
    <header className="sticky top-1 z-40 border-b border-neutral-200 bg-white/95 backdrop-blur">
      <div className="mx-auto flex w-full max-w-3xl items-center justify-between gap-2 px-4 py-3">
        <p className="text-sm font-semibold tracking-wide text-neutral-900">PACT</p>
        <div className="flex items-center gap-2">
          <Button
            className="px-3 py-2 text-xs font-semibold focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600"
            onClick={onPrimary}
            aria-label="Start in Telegram"
          >
            Start in Telegram
          </Button>
          <Button
            className="bg-neutral-100 px-3 py-2 text-xs text-neutral-900 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600"
            onClick={onSecondary}
            aria-label="Connect dashboard"
          >
            Connect dashboard
          </Button>
        </div>
      </div>
    </header>
  );
}

