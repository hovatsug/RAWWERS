import { getLoose, postLoose, putLoose } from "@/api/routes/_common";

export const getRawwCaps = () => getLoose("/v1/admin/raww/caps");
export const updateRawwCaps = (body: unknown) => putLoose("/v1/admin/raww/caps", body);
export const getRawwIssuanceRules = () => getLoose("/v1/admin/raww/issuance-rules");
export const updateRawwIssuanceRules = (body: unknown) => putLoose("/v1/admin/raww/issuance-rules", body);
export const getRawwMultiplierPolicy = () => getLoose("/v1/admin/raww/multiplier-policy");
export const updateRawwMultiplierPolicy = (body: unknown) => putLoose("/v1/admin/raww/multiplier-policy", body);
export const getRawwMints = () => getLoose("/v1/admin/raww/mints");
export const clawbackRaww = (body: unknown) => postLoose("/v1/admin/raww/clawback", body);
