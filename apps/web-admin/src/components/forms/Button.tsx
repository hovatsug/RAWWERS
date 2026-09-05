import { ButtonHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "danger";
  loading?: boolean;
}

export function Button({ className, variant = "primary", loading, children, ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        "inline-flex items-center justify-center rounded-xl px-4 py-2 text-sm font-medium transition",
        variant === "primary" && "bg-accent text-white hover:bg-accent/90",
        variant === "secondary" && "border border-borderSubtle bg-surface2 text-textPrimary hover:bg-surface",
        variant === "danger" && "border border-red-300 bg-white text-red-700 hover:bg-red-50",
        className
      )}
      {...props}
    >
      {loading ? "Working..." : children}
    </button>
  );
}
