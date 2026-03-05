import { postLoose } from "@/api/routes/_common";

export const startImpersonation = (body: unknown) => postLoose("/v1/admin/impersonate/start", body);
export const endImpersonation = (body?: unknown) => postLoose("/v1/admin/impersonate/end", body);
