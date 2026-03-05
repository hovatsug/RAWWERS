import { z } from "zod";
import { getLoose, getPaginated, postLoose, putLoose, ListParams } from "@/api/routes/_common";

export const listPrintOrders = (params: ListParams) =>
  getPaginated("/v1/admin/prints/orders", params, z.object({}).passthrough());
export const getPrintOrder = (orderId: string) => getLoose(`/v1/admin/prints/orders/${orderId}`);
export const setPrintOrderStatus = (orderId: string, body: unknown) =>
  postLoose(`/v1/admin/prints/orders/${orderId}/set-status`, body);
export const setPrintOrderTracking = (orderId: string, body: unknown) =>
  postLoose(`/v1/admin/prints/orders/${orderId}/set-tracking`, body);
export const getPrintCatalogProducts = () => getLoose("/v1/admin/prints/catalog/products");
export const updatePrintCatalogProducts = (body: unknown) => putLoose("/v1/admin/prints/catalog/products", body);
export const getPrintPartners = () => getLoose("/v1/admin/prints/partners");
export const updatePrintPartners = (body: unknown) => putLoose("/v1/admin/prints/partners", body);
