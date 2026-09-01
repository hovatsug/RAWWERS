import { getLoose, postLoose } from "@/api/routes/_common";

export const getSearchStatus = () => getLoose("/v1/admin/search/status");
export const rebuildSearch = (body?: unknown) => postLoose("/v1/admin/search/rebuild", body);
export const purgeSearch = (body?: unknown) => postLoose("/v1/admin/search/purge", body);
