"use client";

import { QueryClient, QueryClientProvider, useQuery } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { useMemo, type ReactNode } from "react";
import { AuthProvider, useAuth } from "@/lib/auth/store";
import { endpoints } from "@/lib/api/endpoints";
import { FlagsProvider } from "@/lib/flags/provider";

function FlagsBridge({ children }: { children: ReactNode }) {
  const { accessToken } = useAuth();
  const { data } = useQuery({
    queryKey: ["flags", accessToken],
    queryFn: async () => {
      try {
        const flags = await endpoints.flags(accessToken);
        return Object.fromEntries(flags.map((f) => [f.name, f.enabled]));
      } catch {
        return {
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
        } as Record<string, boolean>;
      }
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
