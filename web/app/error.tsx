"use client";

import { Button, Card } from "@/design-system/primitives";

export default function Error({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  return (
    <Card>
      <p className="text-base font-semibold">Something failed</p>
      <p className="mt-2 text-sm text-neutral-600">{error.message}</p>
      <p className="mt-1 text-xs text-neutral-500">request_id: {error.digest || "n/a"}</p>
      <Button className="mt-3" onClick={reset}>
        Retry
      </Button>
    </Card>
  );
}
