"use client";

import Link from "next/link";
import { useState } from "react";
import { Button, Card, Input } from "@/design-system/primitives";
import { useParams } from "next/navigation";
import { Flag } from "@/lib/flags/provider";

export default function ClientProofsPage() {
  const { id } = useParams<{ id: string }>();
  const [selected, setSelected] = useState(12);
  const included = 10;
  const perExtra = 7;
  const extras = Math.max(0, selected - included);

  return (
    <Flag name="proof_gallery_enabled" fallback={<Card>Proof gallery module is disabled.</Card>}>
      <div className="space-y-3">
        <Card>
          <h1 className="text-xl font-semibold">Proof gallery</h1>
          <p className="text-sm text-neutral-600">Gig {id.slice(0, 8)} • Select included photos and extras.</p>
        </Card>
        <Card className="space-y-2">
          <label className="text-sm">Selected images</label>
          <Input type="number" value={selected} onChange={(e) => setSelected(Number(e.target.value || 0))} />
          <p className="text-sm">Included: {included}</p>
          <p className="text-sm">Extras: {extras} × €{perExtra} = €{extras * perExtra}</p>
          <Link href={`/client/gigs/${id}/checkout-extras`}><Button>Checkout extras</Button></Link>
        </Card>
      </div>
    </Flag>
  );
}
