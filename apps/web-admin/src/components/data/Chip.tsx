import { PropsWithChildren } from "react";

export function Chip({ children }: PropsWithChildren) {
  return <span className="rounded-full bg-surface2 px-2.5 py-1 text-xs text-textSecondary">{children}</span>;
}
