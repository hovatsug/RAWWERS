"use client";

import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { useMutation } from "@tanstack/react-query";
import { login } from "@/api/routes/auth";
import { Button } from "@/components/forms/Button";
import { Input } from "@/components/forms/Input";
import { SectionCard } from "@/components/layout/SectionCard";
import { InlineBanner } from "@/components/feedback/InlineBanner";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const mutation = useMutation({
    mutationFn: login,
    onSuccess: () => router.push("/admin/dashboard")
  });

  const submit = (e: FormEvent) => {
    e.preventDefault();
    mutation.mutate({ email, password });
  };

  return (
    <main className="mx-auto flex min-h-screen max-w-md items-center px-6">
      <SectionCard className="w-full">
        <h1 className="mb-2 text-2xl font-semibold">Admin Sign in</h1>
        <p className="mb-6 text-sm text-textSecondary">Use your administrator credentials.</p>
        {mutation.isError ? <InlineBanner variant="danger" text={(mutation.error as any)?.message || "Login failed"} /> : null}
        <form className="mt-4 space-y-3" onSubmit={submit}>
          <Input placeholder="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          <Input
            placeholder="Password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          <Button type="submit" className="w-full" loading={mutation.isPending}>
            Sign in
          </Button>
        </form>
      </SectionCard>
    </main>
  );
}
