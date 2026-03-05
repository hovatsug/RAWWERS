import { PropsWithChildren } from "react";
import { cn } from "@/lib/utils";

export function SectionCard({ children, className }: PropsWithChildren<{ className?: string }>) {
  return (
    <section className={cn("rounded-2xl border border-borderSubtle bg-surface p-6 shadow-card", className)}>
      {children}
    </section>
  );
}
