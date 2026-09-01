import { PropsWithChildren } from "react";

export function Drawer({ open, onClose, title, children }: PropsWithChildren<{ open: boolean; onClose: () => void; title: string }>) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-40" onClick={onClose}>
      <div className="absolute inset-0 bg-black/30" />
      <aside className="absolute right-0 top-0 h-full w-full max-w-2xl border-l border-borderSubtle bg-surface p-6 shadow-soft" onClick={(e) => e.stopPropagation()}>
        <h3 className="mb-4 text-lg font-semibold">{title}</h3>
        <div className="h-[calc(100%-2rem)] overflow-auto">{children}</div>
      </aside>
    </div>
  );
}
