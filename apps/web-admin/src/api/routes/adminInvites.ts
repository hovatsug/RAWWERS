import { z } from "zod";
import { getLoose, getPaginated, postLoose, ListParams } from "@/api/routes/_common";

export const listInviteWaves = () => getLoose("/v1/admin/invites/waves");
export const createInviteWave = (body: unknown) => postLoose("/v1/admin/invites/waves", body);
export const generateInviteWaveCodes = (waveId: string, body?: unknown) =>
  postLoose(`/v1/admin/invites/waves/${waveId}/generate`, body);
export const listInviteCodes = (params: ListParams) =>
  getPaginated("/v1/admin/invites/codes", params, z.object({}).passthrough());
export const revokeInviteCode = (code: string, body?: unknown) => postLoose(`/v1/admin/invites/codes/${code}/revoke`, body);
