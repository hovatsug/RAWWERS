"use client";

import { z } from "zod";
import { useState } from "react";
import { Button, Card, Input } from "@/design-system/primitives";
import { auth } from "@/lib/api/auth";
import { useAuth } from "@/lib/auth/store";

const Schema = z.object({ email: z.string().email(), password: z.string().min(8) });

export default function ProLoginPage() {
  const { setSession } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);

  async function onSubmit() {
    setError(null);
    const parsed = Schema.safeParse({ email, password });
    if (!parsed.success) return setError("Invalid credentials format.");

    const token = await auth.login(email, password);
    if (!token.ok) return setError(token.error.message || "Pro login failed.");

    let me = await auth.me(token.data.access_token);
    if (!me.ok) return setError(me.error.message || "Pro login failed.");

    if (!me.data.roles.includes("pro")) {
      const upgraded = await auth.upgradeToPro(token.data.access_token);
      if (!upgraded.ok) return setError(upgraded.error.message || "Could not enable Pro role for this account.");
      me = await auth.me(token.data.access_token);
      if (!me.ok) return setError(me.error.message || "Pro login failed.");
    }

    setSession({
      accessToken: token.data.access_token,
      refreshToken: token.data.refresh_token,
      roles: me.data.roles as any,
      userId: me.data.user_id,
      locale: me.data.locale || "en-GB",
    });

    if (!me.data.roles.includes("pro")) {
      setError("Could not enable Pro role for this account.");
      return;
    }

    window.location.assign("/pro/dashboard");
  }

  return (
    <div className="mx-auto max-w-md">
      <Card className="space-y-3">
        <h1 className="text-xl font-semibold">Pro Login</h1>
        <Input placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <Input placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        <Button onClick={onSubmit}>Login as Pro</Button>
        <p className="text-sm text-neutral-600">Need an account? <a className="text-brand-700 underline" href="/pro/register">Register as Pro</a></p>
        {error ? <p className="text-sm text-red-700">{error}</p> : null}
      </Card>
    </div>
  );
}
