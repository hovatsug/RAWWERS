"use client";

import { z } from "zod";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button, Card, Input } from "@/design-system/primitives";
import { auth } from "@/lib/api/auth";
import { useAuth } from "@/lib/auth/store";

const Schema = z.object({ email: z.string().email(), password: z.string().min(8) });

export default function LoginPage() {
  const router = useRouter();
  const { setSession } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);

  async function onSubmit() {
    setError(null);
    const parsed = Schema.safeParse({ email, password });
    if (!parsed.success) return setError("Invalid credentials format.");
    const token = await auth.login(email, password);
    if (!token.ok) return setError(token.error.message || "Login failed.");
    const me = await auth.me(token.data.access_token);
    if (!me.ok) return setError(me.error.message || "Login failed.");
    setSession({
      accessToken: token.data.access_token,
      refreshToken: token.data.refresh_token,
      roles: me.data.roles as any,
      userId: me.data.user_id,
      locale: me.data.locale || "en-GB"
    });
    if (me.data.roles.includes("pro")) router.replace("/pro/inbox");
    else router.replace("/client/home");
  }

  return (
    <Card className="space-y-3">
      <h1 className="text-xl font-semibold">Login</h1>
      <Input placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
      <Input placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
      <Button onClick={onSubmit}>Login</Button>
      {error ? <p className="text-sm text-red-700">{error}</p> : null}
    </Card>
  );
}
