import { z } from "zod";
import { getPaginated, ListParams } from "@/api/routes/_common";

export const listConsentEvents = (params: ListParams) =>
  getPaginated("/v1/admin/consent/events", params, z.object({}).passthrough());
