import { getLoose, postLoose } from "@/api/routes/_common";

export const getLocales = () => getLoose("/v1/admin/i18n/locales");
export const getBundles = () => getLoose("/v1/admin/i18n/bundles");
export const createBundle = (body: unknown) => postLoose("/v1/admin/i18n/bundles", body);
export const activateBundle = (bundleId: string, body?: unknown) => postLoose(`/v1/admin/i18n/bundles/${bundleId}/activate`, body);
export const getMissingKeys = () => getLoose("/v1/admin/i18n/missing-keys");
