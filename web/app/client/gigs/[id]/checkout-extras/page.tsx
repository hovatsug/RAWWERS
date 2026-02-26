"use client";

import { Button, Card } from "@/design-system/primitives";
import { useState } from "react";

export default function ClientExtrasCheckoutPage() {
  const [done, setDone] = useState(false);

  return (
    <Card className="space-y-3">
      <h1 className="text-xl font-semibold">Extras checkout</h1>
      <p className="text-sm text-neutral-600">Purchase extra images and unlock final download entitlement.</p>
      <Button onClick={() => setDone(true)}>Pay extras</Button>
      {done ? <p className="text-sm text-green-700">Extras payment submitted. Download rights updated.</p> : null}
    </Card>
  );
}
