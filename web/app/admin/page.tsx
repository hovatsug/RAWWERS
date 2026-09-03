"use client";

import { useQuery } from "@tanstack/react-query";
import { Card } from "@/design-system/primitives";
import { auth } from "@/lib/api/auth";

export default function AdminPage() {
  const { data } = useQuery({ queryKey: ["bundle-core"], queryFn: () => auth.getI18nBundle("en-GB", "core") });

  return (
    <div className="space-y-3">
      <h1 className="text-xl font-semibold">Admin Console</h1>
      <Card>
        <p className="text-sm">Feature/module administration, finance ops, i18n bundles.</p>
        <p className="mt-2 text-xs text-neutral-600">Loaded core bundle version: {data?.ok ? data.data.version : "n/a"}</p>
      </Card>
    </div>
  );
}
