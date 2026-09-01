import { request } from "@/api/httpClient";
import { meSchema, safeParseOrError } from "@/api/zod";

export type Me = ReturnType<typeof meSchema.parse>;

export async function getMe() {
  const data = await request("/v1/me");
  return safeParseOrError(meSchema, data);
}
