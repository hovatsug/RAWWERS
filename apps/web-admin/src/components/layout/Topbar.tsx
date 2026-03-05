"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import { logout } from "@/api/routes/auth";
import { queryKeys } from "@/core/queryKeys";
import { Button } from "@/components/forms/Button";

export function Topbar() {
  const queryClient = useQueryClient();
  const mutation = useMutation({
    mutationFn: logout,
    onSettled: () => {
      queryClient.removeQueries({ queryKey: queryKeys.me });
      window.location.href = "/login";
    }
  });

  return (
    <header className="sticky top-0 z-20 flex h-16 items-center justify-end border-b border-borderSubtle bg-surface/75 px-6 backdrop-blur">
      <Button variant="secondary" onClick={() => mutation.mutate()} loading={mutation.isPending}>
        Sign out
      </Button>
    </header>
  );
}
