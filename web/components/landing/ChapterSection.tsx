import type { ReactNode } from "react";
import { Button, Card } from "@/design-system/primitives";

type Props = {
  id: string;
  title: string;
  kicker?: string;
  children: ReactNode;
  ctaLabel?: string;
  ctaSubcopy?: string;
  onCta?: () => void;
};

export function ChapterSection({ id, title, kicker, children, ctaLabel, ctaSubcopy, onCta }: Props) {
  return (
    <section id={id} className="scroll-mt-20 space-y-4 py-8">
      <div className="space-y-2">
        {kicker ? <p className="text-xs font-semibold uppercase tracking-[0.14em] text-brand-700">{kicker}</p> : null}
        <h2 className="max-w-[36ch] text-2xl font-semibold text-neutral-900">{title}</h2>
      </div>
      {children}
      {ctaLabel && onCta ? (
        <Card className="space-y-2 border border-neutral-200 p-5">
          <Button
            className="w-full py-3 text-sm font-semibold focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-600"
            onClick={onCta}
            aria-label={ctaLabel}
          >
            {ctaLabel}
          </Button>
          {ctaSubcopy ? <p className="text-center text-sm text-neutral-600">{ctaSubcopy}</p> : null}
        </Card>
      ) : null}
    </section>
  );
}

