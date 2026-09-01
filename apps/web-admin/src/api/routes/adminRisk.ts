import { z } from "zod";
import { getPaginated, getLoose, postLoose, putLoose, ListParams } from "@/api/routes/_common";

export const listRiskUsers = (params: ListParams) => getPaginated("/v1/admin/risk/users", params, z.object({}).passthrough());
export const getRiskUser = (userId: string) => getLoose(`/v1/admin/risk/users/${userId}`);
export const clearRiskUserAction = (userId: string, body?: unknown) => postLoose(`/v1/admin/risk/users/${userId}/clear-action`, body);
export const setRiskUserScore = (userId: string, body: unknown) => postLoose(`/v1/admin/risk/users/${userId}/set-score`, body);
export const listRiskRules = () => getLoose("/v1/admin/risk/rules");
export const updateRiskRule = (ruleId: string, body: unknown) => putLoose(`/v1/admin/risk/rules/${ruleId}`, body);
