"use client";

import { useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Button, Card, EmptyState, Input } from "@/design-system/primitives";
import { useAuth } from "@/lib/auth/store";
import { discovery } from "@/lib/api/discovery";

export default function WaitlistPage() {
  const { accessToken } = useAuth();
  const [email, setEmail] = useState("");
  const [city, setCity] = useState("");

  const accessQ = useQuery({ queryKey: ["client", "access"], queryFn: () => discovery.getClientAccess(accessToken), enabled: !!accessToken });
  const joinM = useMutation({ mutationFn: () => discovery.joinWaitlist({ email, city }, accessToken) });

  if (!accessToken) return <EmptyState title="Login required" />;

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Waitlist</h1>
      <Card><pre className="overflow-auto text-xs">{JSON.stringify(accessQ.data, null, 2)}</pre></Card>
      <Card className="space-y-2">
        <Input placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <Input placeholder="City" value={city} onChange={(e) => setCity(e.target.value)} />
        <Button onClick={() => joinM.mutate()} disabled={joinM.isPending}>{joinM.isPending ? 'Submitting...' : 'Join waitlist'}</Button>
      </Card>
    </div>
  );
}
