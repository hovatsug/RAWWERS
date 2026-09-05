import { ButtonHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

interface ToggleProps extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, "onChange"> {
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
}

export function Toggle({ checked, onCheckedChange, className, ...props }: ToggleProps) {
  return (
    <button
      type="button"
      className={cn("relative h-7 w-12 rounded-full transition", checked ? "bg-accent" : "bg-surface2", className)}
      onClick={() => onCheckedChange(!checked)}
      {...props}
    >
      <span
        className={cn(
          "absolute top-1 h-5 w-5 rounded-full bg-white shadow transition",
          checked ? "right-1" : "left-1"
        )}
      />
    </button>
  );
}
