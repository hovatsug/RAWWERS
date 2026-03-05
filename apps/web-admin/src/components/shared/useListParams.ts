"use client";

import { usePathname, useRouter, useSearchParams } from "next/navigation";

export function useListParams() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const page = Number(searchParams.get("page") || 1);
  const pageSize = Number(searchParams.get("pageSize") || 20);
  const search = searchParams.get("search") || "";

  const setParam = (key: string, value?: string | number | boolean) => {
    const next = new URLSearchParams(searchParams.toString());
    if (value === undefined || value === "") next.delete(key);
    else next.set(key, String(value));
    if (key !== "page") next.set("page", "1");
    router.replace(`${pathname}?${next.toString()}`);
  };

  return {
    page,
    pageSize,
    search,
    get: (k: string) => searchParams.get(k) || "",
    setParam,
    setPage: (nextPage: number) => setParam("page", Math.max(1, nextPage))
  };
}
