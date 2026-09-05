import { getLoose, putLoose } from "@/api/routes/_common";

export const getFeatureFlags = () => getLoose("/v1/admin/feature-flags");
export const updateFeatureFlag = (key: string, body: unknown) => putLoose(`/v1/admin/feature-flags/${key}`, body);
