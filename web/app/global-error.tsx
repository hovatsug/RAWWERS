"use client";

import * as Sentry from "@sentry/nextjs";
import { useEffect } from "react";

/** The last resort when the root layout itself fails: reported, then a plain page. */
export default function GlobalError({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  useEffect(() => {
    Sentry.captureException(error);
  }, [error]);
  return (
    <html lang="en">
      <body style={{ fontFamily: "system-ui, sans-serif", padding: 24 }}>
        <p style={{ fontWeight: 600 }}>Something failed</p>
        <p style={{ fontSize: 12, color: "#666" }}>request_id: {error.digest || "n/a"}</p>
        <button onClick={reset} style={{ marginTop: 12 }}>
          Retry
        </button>
      </body>
    </html>
  );
}
