"use client";

import type { ButtonHTMLAttributes, HTMLAttributes, InputHTMLAttributes, ReactNode, SelectHTMLAttributes, TextareaHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

// ─── Glow Orbs ────────────────────────────────────────────────────────────────

export function GlowOrbs({ variant = "default" }: { variant?: "default" | "dashboard" | "discovery" }) {
  return (
    <div className="pointer-events-none fixed inset-0 overflow-hidden" aria-hidden>
      {variant === "dashboard" ? (
        <>
          <div className="absolute left-32 top-[-80px] h-[480px] w-[480px] rounded-full bg-violet-600/50 blur-[120px]" />
          <div className="absolute bottom-0 right-[10%] h-[360px] w-[360px] rounded-full bg-emerald-500/30 blur-[90px]" />
          <div className="absolute bottom-[20%] left-[-40px] h-[300px] w-[300px] rounded-full bg-blue-500/25 blur-[80px]" />
        </>
      ) : variant === "discovery" ? (
        <>
          <div className="absolute right-[-60px] top-[-80px] h-[500px] w-[500px] rounded-full bg-violet-600/45 blur-[120px]" />
          <div className="absolute left-[-60px] top-[40%] h-[380px] w-[380px] rounded-full bg-indigo-600/35 blur-[100px]" />
          <div className="absolute bottom-[5%] left-[40%] h-[280px] w-[280px] rounded-full bg-emerald-500/25 blur-[80px]" />
        </>
      ) : (
        <>
          <div className="absolute left-[-80px] top-[-100px] h-[560px] w-[560px] rounded-full bg-violet-600/50 blur-[130px]" />
          <div className="absolute right-[-40px] top-[25%] h-[440px] w-[440px] rounded-full bg-blue-500/40 blur-[110px]" />
          <div className="absolute bottom-0 left-[30%] h-[320px] w-[320px] rounded-full bg-amber-500/25 blur-[90px]" />
        </>
      )}
    </div>
  );
}

// ─── Glass Card ───────────────────────────────────────────────────────────────

export function GlassCard({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "relative rounded-2xl border border-white/10",
        "bg-white/[0.05] backdrop-blur-xl",
        "shadow-glass transition-all duration-300",
        "hover:bg-white/[0.08] hover:border-white/[0.18]",
        "hover:shadow-[0_12px_48px_rgba(124,58,237,0.12),inset_0_1px_0_rgba(255,255,255,0.10)]",
        className
      )}
      {...props}
    />
  );
}

// ─── Button ───────────────────────────────────────────────────────────────────

export function Button({
  className,
  variant = "primary",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & { variant?: "primary" | "glass" | "ghost" }) {
  return (
    <button
      className={cn(
        "inline-flex items-center justify-center rounded-xl px-5 py-2.5 text-sm font-semibold transition-all duration-300 disabled:opacity-50",
        variant === "primary" && [
          "bg-gradient-to-r from-violet-600 to-blue-500 text-white",
          "shadow-glow-sm hover:shadow-glow-violet hover:scale-[1.02] active:scale-[0.98]"
        ],
        variant === "glass" && [
          "border border-white/10 bg-white/[0.06] text-white backdrop-blur-xl",
          "hover:bg-white/[0.10] hover:border-white/20"
        ],
        variant === "ghost" && "text-slate-400 hover:text-white hover:bg-white/[0.05] rounded-xl",
        className
      )}
      {...props}
    />
  );
}

export function IconButton({ className, ...props }: ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      className={cn(
        "rounded-xl border border-white/10 bg-white/[0.05] p-2 text-slate-300",
        "hover:bg-white/[0.09] hover:text-white transition-all duration-200",
        className
      )}
      {...props}
    />
  );
}

// ─── Card (glass) ─────────────────────────────────────────────────────────────

export function Card({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "relative rounded-2xl border border-white/10",
        "bg-white/[0.05] backdrop-blur-xl p-4",
        "shadow-glass transition-all duration-300",
        "hover:bg-white/[0.08] hover:border-white/[0.18]",
        className
      )}
      {...props}
    />
  );
}

// ─── Input ────────────────────────────────────────────────────────────────────

export function Input({ className, ...props }: InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      className={cn(
        "w-full rounded-xl border border-white/10 bg-white/[0.05] px-3 py-2.5 text-sm text-white",
        "placeholder:text-slate-500 backdrop-blur-xl",
        "focus:border-violet-500/60 focus:bg-white/[0.08] focus:outline-none focus:ring-2 focus:ring-violet-500/20",
        "transition-all duration-200",
        className
      )}
      {...props}
    />
  );
}

export function Textarea({ className, ...props }: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <textarea
      className={cn(
        "w-full rounded-xl border border-white/10 bg-white/[0.05] px-3 py-2.5 text-sm text-white",
        "placeholder:text-slate-500 backdrop-blur-xl resize-none",
        "focus:border-violet-500/60 focus:bg-white/[0.08] focus:outline-none focus:ring-2 focus:ring-violet-500/20",
        "transition-all duration-200",
        className
      )}
      {...props}
    />
  );
}

export function Select({ className, children, ...props }: SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select
      className={cn(
        "w-full rounded-xl border border-white/10 bg-[#0D0D1A] px-3 py-2.5 text-sm text-white",
        "focus:border-violet-500/60 focus:outline-none focus:ring-2 focus:ring-violet-500/20",
        "transition-all duration-200",
        className
      )}
      {...props}
    >
      {children}
    </select>
  );
}

// ─── Badge ────────────────────────────────────────────────────────────────────

export function Badge({
  className,
  variant = "default",
  ...props
}: HTMLAttributes<HTMLSpanElement> & { variant?: "default" | "violet" | "emerald" | "amber" }) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-1 text-xs font-medium backdrop-blur-sm",
        variant === "default" && "border border-white/10 bg-white/[0.08] text-slate-300",
        variant === "violet" && "border border-violet-500/30 bg-violet-500/20 text-violet-300",
        variant === "emerald" && "border border-emerald-500/30 bg-emerald-500/20 text-emerald-300",
        variant === "amber" && "border border-amber-500/30 bg-amber-500/20 text-amber-300",
        className
      )}
      {...props}
    />
  );
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

export function Skeleton({ className }: { className?: string }) {
  return <div className={cn("animate-pulse rounded-xl bg-white/[0.06]", className)} />;
}

// ─── Empty State ──────────────────────────────────────────────────────────────

export function EmptyState({ title, body }: { title: string; body?: string }) {
  return (
    <GlassCard className="p-6 text-center">
      <p className="text-base font-semibold text-white">{title}</p>
      {body ? <p className="mt-1 text-sm text-slate-400">{body}</p> : null}
    </GlassCard>
  );
}

// ─── Tabs ─────────────────────────────────────────────────────────────────────

export function Tabs({ tabs, active, onChange }: { tabs: string[]; active: string; onChange: (value: string) => void }) {
  return (
    <div className="flex gap-1.5 overflow-x-auto pb-1">
      {tabs.map((tab) => (
        <button
          key={tab}
          onClick={() => onChange(tab)}
          className={cn(
            "rounded-xl px-4 py-2 text-sm font-medium transition-all duration-200 whitespace-nowrap",
            active === tab
              ? "bg-gradient-to-r from-violet-600 to-blue-500 text-white shadow-glow-sm"
              : "border border-white/10 bg-white/[0.05] text-slate-400 hover:bg-white/[0.08] hover:text-white"
          )}
        >
          {tab}
        </button>
      ))}
    </div>
  );
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

export function BottomSheet({ open, title, children, onClose }: { open: boolean; title: string; children: ReactNode; onClose: () => void }) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm" onClick={onClose}>
      <div
        className="fixed bottom-0 left-0 right-0 rounded-t-2xl border-t border-white/10 bg-[#0D0D1A]/90 p-4 backdrop-blur-2xl shadow-glass-lg"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="mx-auto mb-3 h-1 w-10 rounded-full bg-white/20" />
        <p className="mb-4 text-base font-semibold text-white">{title}</p>
        {children}
      </div>
    </div>
  );
}

// ─── Toast ────────────────────────────────────────────────────────────────────

export function Toast({ message }: { message: string }) {
  return (
    <div className="fixed bottom-4 left-1/2 z-50 -translate-x-1/2 rounded-2xl border border-white/10 bg-[#0D0D1A]/90 px-4 py-2.5 text-sm text-white backdrop-blur-xl shadow-glass">
      {message}
    </div>
  );
}

// ─── Editorial system (flat, rationed accent) ──────────────────────────────────
// Shared across screens restyled under the RAWWERS editorial design system.
// Accent (--accent) is reserved for: primary CTA, progress indicators, focus ring.

export function EditorialCard({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn("rounded-card border border-line bg-surface p-[22px]", className)}
      {...props}
    />
  );
}

export function EditorialButton({
  className,
  variant = "primary",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & { variant?: "primary" | "ghost" }) {
  return (
    <button
      className={cn(
        "inline-flex items-center justify-center rounded-control px-5 py-2.5 text-sm font-semibold",
        "transition-colors duration-200 disabled:opacity-40 disabled:pointer-events-none",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent focus-visible:ring-offset-2 focus-visible:ring-offset-canvas",
        variant === "primary" && "bg-accent text-white hover:brightness-110",
        variant === "ghost" && "border border-line-2 bg-transparent text-ink hover:bg-surface-2",
        className
      )}
      {...props}
    />
  );
}

export function EditorialInput({ className, ...props }: InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      className={cn(
        "w-full rounded-control border border-line bg-surface-2 px-3 py-2.5 text-sm text-ink",
        "placeholder:text-faint",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent focus-visible:border-transparent",
        "transition-colors duration-200",
        className
      )}
      {...props}
    />
  );
}

export function EditorialTextarea({ className, ...props }: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <textarea
      className={cn(
        "w-full rounded-control border border-line bg-surface-2 px-3 py-2.5 text-sm text-ink resize-none",
        "placeholder:text-faint",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent focus-visible:border-transparent",
        "transition-colors duration-200",
        className
      )}
      {...props}
    />
  );
}

export function ProgressRing({ value, size = 56, label }: { value: number; size?: number; label?: string }) {
  const clamped = Math.max(0, Math.min(100, value));
  const stroke = 4;
  const radius = (size - stroke) / 2;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference * (1 - clamped / 100);
  return (
    <div className="relative inline-flex items-center justify-center" style={{ width: size, height: size }}>
      <svg width={size} height={size} className="-rotate-90">
        <circle cx={size / 2} cy={size / 2} r={radius} stroke="var(--line-2)" strokeWidth={stroke} fill="none" />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke="var(--accent)"
          strokeWidth={stroke}
          fill="none"
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          className="transition-[stroke-dashoffset] duration-[1000ms] ease-editorial"
        />
      </svg>
      <div className="absolute flex flex-col items-center justify-center">
        <span className="text-sm font-semibold text-ink">{clamped}%</span>
        {label ? <span className="text-[10px] text-faint">{label}</span> : null}
      </div>
    </div>
  );
}

export function ChipInput({
  values,
  onChange,
  placeholder,
  max,
}: {
  values: string[];
  onChange: (next: string[]) => void;
  placeholder?: string;
  max?: number;
}) {
  const atLimit = max != null && values.length >= max;
  return (
    <div className="flex flex-wrap items-center gap-1.5 rounded-control border border-line bg-surface-2 p-2">
      {values.map((value) => (
        <span
          key={value}
          className="inline-flex items-center gap-1 rounded-pill border border-line-2 bg-surface-3 px-2.5 py-1 text-xs text-ink"
        >
          {value}
          <button
            type="button"
            aria-label={`Remove ${value}`}
            onClick={() => onChange(values.filter((v) => v !== value))}
            className="text-faint hover:text-ink focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent rounded-full"
          >
            ×
          </button>
        </span>
      ))}
      {!atLimit ? (
        <input
          type="text"
          placeholder={placeholder}
          className="min-w-[96px] flex-1 bg-transparent px-1 py-1 text-sm text-ink placeholder:text-faint focus-visible:outline-none"
          onKeyDown={(e) => {
            const target = e.currentTarget;
            if (e.key === "Enter" || e.key === ",") {
              e.preventDefault();
              const next = target.value.trim();
              if (next && !values.includes(next)) onChange([...values, next]);
              target.value = "";
            } else if (e.key === "Backspace" && target.value === "" && values.length) {
              onChange(values.slice(0, -1));
            }
          }}
        />
      ) : null}
    </div>
  );
}

export function StatusPill({ tone, children }: { tone: "ok" | "warn" | "neutral"; children: ReactNode }) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-pill px-2.5 py-1 text-xs font-medium",
        tone === "ok" && "bg-[rgba(63,207,142,0.12)] text-ok",
        tone === "warn" && "bg-[rgba(224,164,88,0.12)] text-warn",
        tone === "neutral" && "bg-surface-2 text-muted"
      )}
    >
      <span
        className={cn(
          "h-1.5 w-1.5 rounded-full",
          tone === "ok" && "bg-ok",
          tone === "warn" && "bg-warn",
          tone === "neutral" && "bg-faint"
        )}
      />
      {children}
    </span>
  );
}
