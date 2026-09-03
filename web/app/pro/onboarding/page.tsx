"use client";

import { useQuery } from "@tanstack/react-query";
import { Card } from "@/design-system/primitives";
import { pro as proApi } from "@/lib/api/pro";
import { useAuth } from "@/lib/auth/store";
import { Flag } from "@/lib/flags/provider";

export default function ProOnboardingPage() {
  const { accessToken } = useAuth();
  const onboardingQ = useQuery({ queryKey: ["pro-onboarding"], queryFn: () => proApi.getOnboarding(accessToken), enabled: !!accessToken });
  const checksQ = useQuery({ queryKey: ["pro-onboarding-checks"], queryFn: () => proApi.getOnboardingChecks(accessToken), enabled: !!accessToken });

  return (
    <Flag name="pro_onboarding_enabled" fallback={<Card>Onboarding module is disabled.</Card>}>
      <Card>
        <h1 className="text-xl font-semibold">Pro onboarding</h1>
        <p className="mt-2 text-sm text-neutral-600">Pipeline stages and verification checks.</p>
        <a className="mt-2 inline-block text-sm text-brand-700 underline" href="/pro/profile/listing-card">
          Edit Listing Card
        </a>
        <pre className="mt-3 overflow-auto rounded bg-neutral-100 p-2 text-xs">
          {JSON.stringify({ onboarding: onboardingQ.data?.ok ? onboardingQ.data.data : null, checks: checksQ.data?.ok ? checksQ.data.data : null }, null, 2)}
        </pre>
      </Card>
    </Flag>
  );
}
