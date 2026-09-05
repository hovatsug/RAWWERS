import { cn } from "@/lib/utils";

export function StatusChip({ value }: { value?: string | boolean | null }) {
  const normalized = String(value ?? "unknown").toLowerCase();
  return (
    <span
      className={cn("rounded-full px-2.5 py-1 text-xs", {
        "bg-emerald-100 text-emerald-700": ["approved", "paid", "enabled", "active", "true", "resolved"].includes(normalized),
        "bg-amber-100 text-amber-700": ["pending", "review"].includes(normalized),
        "bg-red-100 text-red-700": ["rejected", "disabled", "banned", "false", "failed"].includes(normalized),
        "bg-surface2 text-textSecondary": true
      })}
    >
      {String(value ?? "unknown")}
    </span>
  );
}
