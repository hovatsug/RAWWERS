"use client";

import { useQuery } from "@tanstack/react-query";
import { usePathname, useRouter } from "next/navigation";
import { PropsWithChildren, useEffect } from "react";
import { getMe } from "@/api/routes/me";
import { queryKeys } from "@/core/queryKeys";
import { Skeleton } from "@/components/feedback/Skeleton";

export function AdminGate({ children }: PropsWithChildren) {
  const router = useRouter();
  const pathname = usePathname();
  const meQuery = useQuery({ queryKey: queryKeys.me, queryFn: getMe });

  useEffect(() => {
    if (meQuery.isError) {
      const status = (meQuery.error as any)?.status;
      if (status === 401) router.replace("/login");
    }
  }, [meQuery.isError, meQuery.error, router]);

  useEffect(() => {
    if (!meQuery.data) return;
    const roles = meQuery.data.roles || [];
    if (!roles.includes("admin") && pathname !== "/admin/not-authorized") {
      router.replace("/admin/not-authorized");
    }
  }, [meQuery.data, router, pathname]);

  if (meQuery.isLoading) {
    return (
      <div className="p-8">
        <Skeleton className="h-16 w-full" />
      </div>
    );
  }

  return <>{children}</>;
}
