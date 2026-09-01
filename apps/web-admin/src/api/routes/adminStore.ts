import { z } from "zod";
import { getLoose, getPaginated, postLoose, putLoose, ListParams } from "@/api/routes/_common";

export const getStorePolicy = () => getLoose("/v1/admin/store/policy");
export const updateStorePolicy = (body: unknown) => putLoose("/v1/admin/store/policy", body);
export const getStorePartners = () => getLoose("/v1/admin/store/partners");
export const createStorePartner = (body: unknown) => postLoose("/v1/admin/store/partners", body);
export const updateStorePartner = (partnerId: string, body: unknown) => putLoose(`/v1/admin/store/partners/${partnerId}`, body);
export const syncStorePartner = (partnerId: string, body?: unknown) => postLoose(`/v1/admin/store/partners/${partnerId}/sync`, body);
export const listStoreProducts = (params: ListParams) =>
  getPaginated("/v1/admin/store/products", params, z.object({}).passthrough());
export const createStoreProduct = (body: unknown) => postLoose("/v1/admin/store/products", body);
export const updateStoreProduct = (productId: string, body: unknown) => putLoose(`/v1/admin/store/products/${productId}`, body);
export const getStorePriceRules = () => getLoose("/v1/admin/store/price-rules");
export const createStorePriceRule = (body: unknown) => postLoose("/v1/admin/store/price-rules", body);
export const updateStorePriceRule = (ruleId: string, body: unknown) => putLoose(`/v1/admin/store/price-rules/${ruleId}`, body);
export const updateStoreOrderStatus = (orderId: string, body: unknown) => postLoose(`/v1/admin/store/orders/${orderId}/update-status`, body);
export const setStoreOverride = (proUserId: string, body: unknown) => postLoose(`/v1/admin/store/overrides/${proUserId}`, body);
