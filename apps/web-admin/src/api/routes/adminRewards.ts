import { getLoose, postLoose, putLoose } from "@/api/routes/_common";

export const adjustRewards = (body: unknown) => postLoose("/v1/admin/rewards/adjust", body);
export const getRewardsConsentPolicies = () => getLoose("/v1/admin/rewards/consent-policies");
export const updateRewardsConsentPolicies = (body: unknown) => putLoose("/v1/admin/rewards/consent-policies", body);
export const getRewardsRules = () => getLoose("/v1/admin/rewards/rules");
export const executeRewardsRule = (code: string, body?: unknown) => postLoose(`/v1/admin/rewards/rules/${code}`, body);
export const getShareThresholds = () => getLoose("/v1/admin/rewards/share-thresholds");
export const updateShareThresholds = (body: unknown) => putLoose("/v1/admin/rewards/share-thresholds", body);
export const getShareGrants = () => getLoose("/v1/admin/rewards/share-grants");
export const getShareFraudSettings = () => getLoose("/v1/admin/rewards/share-fraud-settings");
export const updateShareFraudSettings = (body: unknown) => putLoose("/v1/admin/rewards/share-fraud-settings", body);
