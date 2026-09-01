"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { PropsWithChildren, useState } from "react";
import { ApiError } from "@/api/errors";

function shouldRetry(failureCount: number, error: Error) {
  if (failureCount >= 1) return false;
  const apiError = error as unknown as ApiError;
  if (!apiError || typeof apiError !== "object") return true;
  return ![401, 403, 422].includes(apiError.status || 0);
}

export function AppQueryProvider({ children }: PropsWithChildren) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: { retry: shouldRetry, refetchOnWindowFocus: false },
          mutations: { retry: false }
        }
      })
  );
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
