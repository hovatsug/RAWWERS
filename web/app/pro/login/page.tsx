"use client";

import { z } from "zod";
import { useState } from "react";
import { Button, Card, Input } from "@/design-system/primitives";
import { endpoints } from "@/lib/api/endpoints";
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

    try {
      const token = await endpoints.login(email, password);
      let me = await endpoints.me(token.access_token);
      if (!me.roles.includes("pro")) {
        await endpoints.upgradeToPro(token.access_token);
        me = await endpoints.me(token.access_token);
      }
      setSession({
        accessToken: token.access_token,
        refreshToken: token.refresh_token,
        roles: me.roles as any,
        userId: me.user_id,
        locale: me.locale || "en-GB",
      });

      if (!me.roles.includes("pro")) {
        setError("Could not enable Pro role for this account.");
        return;
      }

      window.location.assign("/pro/dashboard");
    } catch {
      setError("Pro login failed.");
    }
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
