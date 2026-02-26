"use client";

import { createContext, useContext, type ReactNode } from "react";

type FlagsMap = Record<string, boolean>;

const FlagsContext = createContext<FlagsMap>({});

export function FlagsProvider({ value, children }: { value: FlagsMap; children: ReactNode }) {
  return <FlagsContext.Provider value={value}>{children}</FlagsContext.Provider>;
}

export function useFlags() {
  return useContext(FlagsContext);
}

export function Flag({ name, fallback = null, children }: { name: string; fallback?: ReactNode; children: ReactNode }) {
  const flags = useFlags();
  return flags[name] ? <>{children}</> : <>{fallback}</>;
}
