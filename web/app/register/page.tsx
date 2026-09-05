"use client";

import Link from "next/link";
import { z } from "zod";
import { useState } from "react";
import { Button, Card, Input } from "@/design-system/primitives";
import { auth } from "@/lib/api/auth";

const Schema = z.object({ email: z.string().email(), password: z.string().min(8) });

export default function RegisterPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [ok, setOk] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onSubmit() {
    setError(null);
    const parsed = Schema.safeParse({ email, password });
    if (!parsed.success) return setError("Invalid credentials format.");
    const result = await auth.register(email, password);
    if (!result.ok) return setError(result.error.message || "Registration failed.");
    setOk(true);
  }

  return (
    <Card className="space-y-3">
      <h1 className="text-xl font-semibold">Register</h1>
      <Input placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
      <Input placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
      <Button onClick={onSubmit}>Create account</Button>
      {ok ? <p className="text-sm text-green-700">Registered. <Link href="/verify-email">Verify email</Link></p> : null}
      {error ? <p className="text-sm text-red-700">{error}</p> : null}
    </Card>
  );
}
