import { SelectHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

export function Select({ className, ...props }: SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select
      className={cn("h-10 rounded-xl border border-borderSubtle bg-white px-3 text-sm text-textPrimary outline-none", className)}
      {...props}
    />
  );
}
