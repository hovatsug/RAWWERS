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
    const needsAuth = pathname.startsWith("/client") || pathname.startsWith("/pro") || pathname.startsWith("/chat") || pathname.startsWith("/admin");
    if (needsAuth && !accessToken) router.replace("/login");
    if (pathname.startsWith("/client") && accessToken && !roles.includes("client")) router.replace("/");
    if (pathname.startsWith("/pro") && accessToken && !roles.includes("pro")) router.replace("/");
    if (pathname.startsWith("/admin") && accessToken && !roles.includes("admin")) router.replace("/");
  }, [accessToken, hydrated, roles, pathname, router]);

  return <>{children}</>;
}
