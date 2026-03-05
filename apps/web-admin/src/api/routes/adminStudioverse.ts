import { z } from "zod";
import { getPaginated, postLoose, ListParams } from "@/api/routes/_common";

export const listStudioversePacks = (params: ListParams) =>
  getPaginated("/v1/admin/studioverse/packs", params, z.object({}).passthrough());
export const reviewStudioversePack = (packId: string, body?: unknown) => postLoose(`/v1/admin/studioverse/packs/${packId}/review`, body);
export const takedownStudioversePack = (packId: string, body?: unknown) => postLoose(`/v1/admin/studioverse/packs/${packId}/takedown`, body);
