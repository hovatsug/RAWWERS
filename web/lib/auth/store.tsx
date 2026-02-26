"use client";

import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";

export type Role = "admin" | "pro" | "client";

type Session = {
  accessToken: string | null;
  refreshToken: string | null;
  roles: Role[];
  userId: string | null;
  locale: string;
};

type AuthContextValue = Session & {
  hydrated: boolean;
  setSession: (value: Partial<Session>) => void;
  clearSession: () => void;
};

const AuthContext = createContext<AuthContextValue | null>(null);
const DEFAULT_SESSION: Session = { accessToken: null, refreshToken: null, roles: [], userId: null, locale: "en-GB" };

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSessionState] = useState<Session>(DEFAULT_SESSION);
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    const raw = window.sessionStorage.getItem("rawwers_session");
    if (!raw) {
      setHydrated(true);
      return;
    }
    try {
      setSessionState(JSON.parse(raw) as Session);
    } catch {
      setSessionState(DEFAULT_SESSION);
    } finally {
      setHydrated(true);
    }
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({
      ...session,
      hydrated,
      setSession: (patch) =>
        setSessionState((prev) => {
          const next = { ...prev, ...patch };
          if (typeof window !== "undefined") window.sessionStorage.setItem("rawwers_session", JSON.stringify(next));
          return next;
        }),
      clearSession: () =>
        setSessionState(() => {
          if (typeof window !== "undefined") window.sessionStorage.removeItem("rawwers_session");
          return DEFAULT_SESSION;
        })
    }),
    [hydrated, session]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
