"use client";

import { useState } from "react";
import { Button, Card, EmptyState, Input } from "@/design-system/primitives";

export default function ProGigsPage() {
  const [gigId, setGigId] = useState("");
  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Gigs</h1>
      <Card className="space-y-2">
        <p className="text-sm text-neutral-600">No list endpoint is available in the catalog. Open by ID or from lead/thread context.</p>
        <Input value={gigId} onChange={(e) => setGigId(e.target.value)} placeholder="Paste gig id" />
        <div>{gigId ? <a href={`/pro/gigs/${gigId}`}><Button>Open Gig</Button></a> : <EmptyState title="Enter gig id" />}</div>
      </Card>
    </div>
  );
}
