"use client";

import { z } from "zod";
import { useState } from "react";
import { useAuth } from "@/lib/auth/store";
import { Button, Card, Input } from "@/design-system/primitives";
import { auth } from "@/lib/api/auth";

const Schema = z.object({ email: z.string().email(), password: z.string().min(8) });

export default function ProRegisterPage() {
  const { setSession } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [ok, setOk] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function loginAndUpgradePro(inputEmail: string, inputPassword: string): Promise<boolean> {
    const token = await auth.login(inputEmail, inputPassword);
    if (!token.ok) return false;
    const upgraded = await auth.upgradeToPro(token.data.access_token);
    if (!upgraded.ok) return false;
    const me = await auth.me(token.data.access_token);
    if (!me.ok) return false;
    setSession({
      accessToken: token.data.access_token,
      refreshToken: token.data.refresh_token,
      roles: me.data.roles as any,
      userId: me.data.user_id,
      locale: me.data.locale || "en-GB",
    });
    return true;
  }

  async function onSubmit() {
    setError(null);
    const parsed = Schema.safeParse({ email, password });
    if (!parsed.success) return setError("Invalid credentials format.");

    const registered = await auth.register(email, password);
    // If registration failed (e.g. account already exists), fall through
    // and try login + pro upgrade instead of failing outright.
    const loggedIn = await loginAndUpgradePro(email, password);
    if (loggedIn) {
      setOk(true);
    } else {
      setError(registered.ok ? "Pro registration failed." : registered.error.message || "Pro registration failed.");
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
