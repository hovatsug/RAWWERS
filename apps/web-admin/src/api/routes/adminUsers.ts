import { z } from "zod";
import { getPaginated, getLoose, postLoose, ListParams } from "@/api/routes/_common";

const userSchema = z
  .object({
    user_id: z.union([z.string(), z.number()]).optional(),
    id: z.union([z.string(), z.number()]).optional(),
    email: z.string().optional(),
    roles: z.array(z.string()).optional(),
    banned: z.boolean().optional(),
    created_at: z.string().optional(),
    last_seen: z.string().optional()
  })
  .passthrough();

export function listAdminUsers(params: ListParams) {
  return getPaginated("/v1/admin/users", params, userSchema);
}

export function getAdminUser(userId: string) {
  return getLoose(`/v1/admin/users/${userId}`);
}

export function banAdminUser(userId: string, payload?: Record<string, unknown>) {
  return postLoose(`/v1/admin/users/${userId}/ban`, payload ?? {});
}

export function updateAdminUserRoles(userId: string, roles: string[]) {
  return postLoose(`/v1/admin/users/${userId}/roles`, { roles });
}
