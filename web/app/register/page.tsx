"use client";

import Link from "next/link";
import { z } from "zod";
import { useState } from "react";
import { Button, Card, Input } from "@/design-system/primitives";
import { endpoints } from "@/lib/api/endpoints";

const Schema = z.object({ email: z.string().email(), password: z.string().min(8) });

export default function RegisterPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [ok, setOk] = useState(false);

  async function onSubmit() {
    const parsed = Schema.safeParse({ email, password });
    if (!parsed.success) return;
    await endpoints.register(email, password);
    setOk(true);
  }

  return (
    <Card className="space-y-3">
      <h1 className="text-xl font-semibold">Register</h1>
      <Input placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
      <Input placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
      <Button onClick={onSubmit}>Create account</Button>
      {ok ? <p className="text-sm text-green-700">Registered. <Link href="/verify-email">Verify email</Link></p> : null}
    </Card>
  );
}
