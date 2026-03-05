import { cn } from "@/lib/utils";

interface InlineBannerProps {
  variant?: "info" | "success" | "danger";
  text: string;
}

export function InlineBanner({ variant = "info", text }: InlineBannerProps) {
  return (
    <div
      className={cn("rounded-xl border px-4 py-3 text-sm", {
        "border-blue-200 bg-blue-50 text-blue-700": variant === "info",
        "border-emerald-200 bg-emerald-50 text-emerald-700": variant === "success",
        "border-red-200 bg-red-50 text-red-700": variant === "danger"
      })}
    >
      {text}
    </div>
  );
}
