"use client";

import { useEffect } from "react";
import type { ReactNode } from "react";
import { usePathname, useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth/store";

export function Guard({ children }: { children: ReactNode }) {
  const { accessToken, roles, hydrated } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (!hydrated) return;
    const isProAuthPath = pathname === "/pro/login" || pathname === "/pro/register";
    const needsAuth = pathname.startsWith("/client") || (pathname.startsWith("/pro") && !isProAuthPath) || pathname.startsWith("/chat") || pathname.startsWith("/admin");
    if (needsAuth && !accessToken) {
      if (pathname.startsWith("/pro")) {
        router.replace("/pro/login" as any);
        return;
      }
      router.replace("/login");
      return;
    }
    if (pathname.startsWith("/client") && accessToken && !roles.includes("client")) router.replace("/");
    if (pathname.startsWith("/pro") && !isProAuthPath && accessToken && !roles.includes("pro")) router.replace("/");
    if (pathname.startsWith("/admin") && accessToken && !roles.includes("admin")) router.replace("/");
  }, [accessToken, hydrated, roles, pathname, router]);

  return <>{children}</>;
}
