import { PropsWithChildren } from "react";

export function FiltersBar({ children }: PropsWithChildren) {
  return <div className="mb-4 flex flex-wrap items-center gap-3">{children}</div>;
}
