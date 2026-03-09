"use client";

import { z } from "zod";
import { useState } from "react";
import { useAuth } from "@/lib/auth/store";
import { Button, Card, Input } from "@/design-system/primitives";
import { endpoints } from "@/lib/api/endpoints";

const Schema = z.object({ email: z.string().email(), password: z.string().min(8) });

export default function ProRegisterPage() {
  const { setSession } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [ok, setOk] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function loginAndUpgradePro(inputEmail: string, inputPassword: string) {
    const token = await endpoints.login(inputEmail, inputPassword);
    await endpoints.upgradeToPro(token.access_token);
    const me = await endpoints.me(token.access_token);
    setSession({
      accessToken: token.access_token,
      refreshToken: token.refresh_token,
      roles: me.roles as any,
      userId: me.user_id,
      locale: me.locale || "en-GB",
    });
  }

  async function onSubmit() {
    setError(null);
    const parsed = Schema.safeParse({ email, password });
    if (!parsed.success) return setError("Invalid credentials format.");

    try {
      await endpoints.register(email, password);
      await loginAndUpgradePro(email, password);
      setOk(true);
    } catch {
      try {
        // If account already exists, continue with login + pro upgrade.
        await loginAndUpgradePro(email, password);
        setOk(true);
      } catch {
        setError("Pro registration failed.");
      }
    }
  }

  return (
    <div className="mx-auto max-w-md">
      <Card className="space-y-3">
        <h1 className="text-xl font-semibold">Pro Register</h1>
        <Input placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <Input placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        <Button onClick={onSubmit}>Create Pro Account</Button>
        {ok ? <p className="text-sm text-green-700">Registered and upgraded to Pro. You can continue to your Pro dashboard.</p> : null}
        {error ? <p className="text-sm text-red-700">{error}</p> : null}
        <p className="text-sm text-neutral-600">Already have an account? <a className="text-brand-700 underline" href="/pro/login">Go to Pro login</a></p>
        {ok ? <p><a className="text-sm text-brand-700 underline" href="/pro/dashboard">Open Pro dashboard</a></p> : null}
      </Card>
    </div>
  );
}
