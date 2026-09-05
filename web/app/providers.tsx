"use client";

import { QueryClient, QueryClientProvider, useQuery } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { useMemo, type ReactNode } from "react";
import { AuthProvider, useAuth } from "@/lib/auth/store";
import { auth } from "@/lib/api/auth";
import { FlagsProvider } from "@/lib/flags/provider";

const FALLBACK_FLAGS: Record<string, boolean> = {
  client_discovery_enabled: true,
  client_bookings_enabled: true,
  proof_gallery_enabled: true,
  pro_onboarding_enabled: true,
  notifications_enabled: true,
  ai_concierge_enabled: false,
  rewards_enabled: false,
  share_gallery_enabled: false,
  pro_leads_enabled: false,
  checkout_extras_enabled: false
};

function FlagsBridge({ children }: { children: ReactNode }) {
  const { accessToken } = useAuth();
  const { data } = useQuery({
    queryKey: ["flags", accessToken],
    queryFn: async () => {
      // GET /v1/feature-flags does not exist on the backend (only the
      // admin-only variants do) - this always fails and falls back to the
      // hardcoded map below. See auth.getFeatureFlags for detail; needs a
      // backend decision, not something to work around further here.
      const result = await auth.getFeatureFlags(accessToken);
      if (!result.ok) return FALLBACK_FLAGS;
      return Object.fromEntries(result.data.map((f) => [f.name, f.enabled]));
    },
    staleTime: 30_000
  });

  return <FlagsProvider value={data || {}}>{children}</FlagsProvider>;
}

export function AppProviders({ children }: { children: ReactNode }) {
  const queryClient = useMemo(() => new QueryClient(), []);

  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <FlagsBridge>{children}</FlagsBridge>
      </AuthProvider>
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
