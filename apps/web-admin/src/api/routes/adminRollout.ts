import { getLoose, postLoose, putLoose } from "@/api/routes/_common";

export const getRolloutCities = () => getLoose("/v1/admin/rollout/cities");
export const updateRolloutCities = (body: unknown) => putLoose("/v1/admin/rollout/cities", body);
export const bulkEnableCities = (body: unknown) => postLoose("/v1/admin/rollout/cities/bulk-enable", body);
export const getRolloutOverride = (userId: string) => getLoose(`/v1/admin/rollout/overrides/${userId}`);
export const updateRolloutOverride = (userId: string, body: unknown) => putLoose(`/v1/admin/rollout/overrides/${userId}`, body);
