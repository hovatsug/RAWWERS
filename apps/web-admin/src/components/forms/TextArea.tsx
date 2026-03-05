import { TextareaHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

export function TextArea({ className, ...props }: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return <textarea className={cn("w-full rounded-xl border border-borderSubtle bg-white p-3 text-sm outline-none", className)} {...props} />;
}
