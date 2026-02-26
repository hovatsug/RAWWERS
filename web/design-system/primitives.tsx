"use client";

import type { ButtonHTMLAttributes, HTMLAttributes, InputHTMLAttributes, ReactNode, SelectHTMLAttributes, TextareaHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

export function Button({ className, ...props }: ButtonHTMLAttributes<HTMLButtonElement>) {
  return <button className={cn("rounded-md bg-brand-600 px-4 py-2 text-sm font-medium text-white disabled:opacity-50", className)} {...props} />;
}

export function IconButton({ className, ...props }: ButtonHTMLAttributes<HTMLButtonElement>) {
  return <button className={cn("rounded-md border border-neutral-200 p-2 text-neutral-700", className)} {...props} />;
}

export function Card({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return <div className={cn("rounded-lg bg-white p-4 shadow-card", className)} {...props} />;
}

export function Input({ className, ...props }: InputHTMLAttributes<HTMLInputElement>) {
  return <input className={cn("w-full rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm", className)} {...props} />;
}

export function Textarea({ className, ...props }: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return <textarea className={cn("w-full rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm", className)} {...props} />;
}

export function Select({ className, children, ...props }: SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select className={cn("w-full rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm", className)} {...props}>
      {children}
    </select>
  );
}

export function Badge({ className, ...props }: HTMLAttributes<HTMLSpanElement>) {
  return <span className={cn("inline-flex rounded-full bg-brand-50 px-2 py-1 text-xs text-brand-700", className)} {...props} />;
}

export function Skeleton({ className }: { className?: string }) {
  return <div className={cn("animate-pulse rounded-md bg-neutral-100", className)} />;
}

export function EmptyState({ title, body }: { title: string; body?: string }) {
  return (
    <Card className="text-center">
      <p className="text-base font-semibold">{title}</p>
      {body ? <p className="mt-1 text-sm text-neutral-600">{body}</p> : null}
    </Card>
  );
}

export function Tabs({ tabs, active, onChange }: { tabs: string[]; active: string; onChange: (value: string) => void }) {
  return (
    <div className="flex gap-2 overflow-x-auto pb-1">
      {tabs.map((tab) => (
        <button
          key={tab}
          onClick={() => onChange(tab)}
          className={cn("rounded-md px-3 py-2 text-sm", active === tab ? "bg-brand-600 text-white" : "bg-white text-neutral-700")}
        >
          {tab}
        </button>
      ))}
    </div>
  );
}

export function BottomSheet({ open, title, children, onClose }: { open: boolean; title: string; children: ReactNode; onClose: () => void }) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 bg-black/40" onClick={onClose}>
      <div className="fixed bottom-0 left-0 right-0 rounded-t-lg bg-white p-4 shadow-sheet" onClick={(e) => e.stopPropagation()}>
        <p className="mb-3 text-base font-semibold">{title}</p>
        {children}
      </div>
    </div>
  );
}

export function Toast({ message }: { message: string }) {
  return <div className="fixed bottom-4 left-1/2 z-50 -translate-x-1/2 rounded-md bg-neutral-900 px-3 py-2 text-sm text-white">{message}</div>;
}
