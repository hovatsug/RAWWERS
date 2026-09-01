"use client";

export async function track(eventName: string, properties: Record<string, unknown> = {}) {
  try {
    const endpoint = process.env.NEXT_PUBLIC_ANALYTICS_ENDPOINT;
    if (!endpoint) return;
    await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ event_name: eventName, properties })
    });
  } catch {
    // no-op
  }
}
