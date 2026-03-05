import { Button, Card } from "@/design-system/primitives";

type Props = {
  onPrimary: () => void;
  onSecondary: () => void;
};

export function FinalCTA({ onPrimary, onSecondary }: Props) {
  return (
    <Card className="space-y-4 border border-neutral-200 p-6">
      <h2 className="max-w-[34ch] text-2xl font-semibold text-neutral-900">PACT is not here to motivate you. It is here to expose what you actually do.</h2>
      <p className="max-w-[62ch] text-base text-neutral-700">
        If you want another reset loop, skip this.
        If you want evidence, accountability, and a system that does not negotiate, start now.
      </p>
      <div className="flex flex-col gap-3 sm:flex-row">
        <Button
          className="flex-1 py-3 text-sm font-semibold focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600"
          onClick={onPrimary}
          aria-label="Start in Telegram"
        >
          Start in Telegram
        </Button>
        <Button
          className="flex-1 bg-neutral-100 py-3 text-sm text-neutral-900 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600"
          onClick={onSecondary}
          aria-label="Connect dashboard"
        >
          Connect dashboard
        </Button>
      </div>
    </Card>
  );
}

