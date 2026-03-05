"use client";

import { useQuery } from "@tanstack/react-query";
import { Card } from "@/design-system/primitives";
import { endpoints } from "@/lib/api/endpoints";
import { useAuth } from "@/lib/auth/store";
import { Flag } from "@/lib/flags/provider";

export default function ProOnboardingPage() {
  const { accessToken } = useAuth();
  const { data } = useQuery({ queryKey: ["pro-onboarding"], queryFn: () => endpoints.myOnboarding(accessToken) });

  return (
    <Flag name="pro_onboarding_enabled" fallback={<Card>Onboarding module is disabled.</Card>}>
      <Card>
        <h1 className="text-xl font-semibold">Pro onboarding</h1>
        <p className="mt-2 text-sm text-neutral-600">Pipeline stages and verification checks.</p>
        <a className="mt-2 inline-block text-sm text-brand-700 underline" href="/pro/profile/listing-card">
          Edit Listing Card
        </a>
        <pre className="mt-3 overflow-auto rounded bg-neutral-100 p-2 text-xs">{JSON.stringify(data || { status: "pending" }, null, 2)}</pre>
      </Card>
    </Flag>
  );
}
