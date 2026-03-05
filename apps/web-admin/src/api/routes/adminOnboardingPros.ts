import { z } from "zod";
import { getPaginated, postLoose, ListParams } from "@/api/routes/_common";

export const listOnboardingPros = (params: ListParams) => getPaginated("/v1/admin/onboarding/pros", params, z.object({}).passthrough());
export const approveOnboardingPro = (id: string, body?: unknown) => postLoose(`/v1/admin/onboarding/pros/${id}/approve`, body);
export const rejectOnboardingPro = (id: string, body?: unknown) => postLoose(`/v1/admin/onboarding/pros/${id}/reject`, body);
export const setOnboardingProStatus = (id: string, body?: unknown) => postLoose(`/v1/admin/onboarding/pros/${id}/set-status`, body);
export const updateProKyc = (userId: string, body?: unknown) => postLoose(`/v1/admin/pros/${userId}/kyc`, body);
