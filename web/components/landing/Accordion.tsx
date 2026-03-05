"use client";

import { useState } from "react";
import { track } from "@/lib/analytics/client";

type Item = {
  id: string;
  title: string;
  content: string | string[];
};

export function Accordion({ items }: { items: Item[] }) {
  const [openId, setOpenId] = useState<string | null>(null);

  return (
    <div className="space-y-3">
      {items.map((item) => {
        const open = openId === item.id;
        return (
          <div key={item.id} className="rounded-lg border border-neutral-200 bg-white p-4">
            <button
              className="flex w-full items-center justify-between text-left text-base font-semibold text-neutral-900"
              onClick={() => {
                const next = open ? null : item.id;
                setOpenId(next);
                if (next) track("accordion_open", { id: item.id });
              }}
              aria-expanded={open}
              aria-controls={`acc-${item.id}`}
            >
              <span>{item.title}</span>
              <span className="text-neutral-600">{open ? "−" : "+"}</span>
            </button>
            {open ? (
              <div id={`acc-${item.id}`} className="mt-3 space-y-2 text-sm text-neutral-700">
                {Array.isArray(item.content) ? (
                  <ul className="list-disc space-y-1 pl-5">
                    {item.content.map((line) => (
                      <li key={line}>{line}</li>
                    ))}
                  </ul>
                ) : (
                  <p>{item.content}</p>
                )}
              </div>
            ) : null}
          </div>
        );
      })}
    </div>
  );
}

