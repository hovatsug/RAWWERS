import { InputHTMLAttributes, forwardRef } from "react";
import { cn } from "@/lib/utils";

export const Input = forwardRef<HTMLInputElement, InputHTMLAttributes<HTMLInputElement>>(function Input(
  { className, ...props },
  ref
) {
  return (
    <input
      ref={ref}
      className={cn(
        "h-10 w-full rounded-xl border border-borderSubtle bg-white px-3 text-sm text-textPrimary outline-none ring-accent/25 focus:ring",
        className
      )}
      {...props}
    />
  );
});
