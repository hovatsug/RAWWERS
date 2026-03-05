import { putLoose } from "@/api/routes/_common";

export const updateAIFeatureFlags = (body: unknown) => putLoose("/v1/admin/ai/feature-flags", body);
