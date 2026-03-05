import { z } from "zod";
import { request } from "@/api/httpClient";
import { paginatedSchema, safeParseOrError } from "@/api/zod";
import { buildQuery } from "@/lib/urls";
import { recordAndTrackAdminAction } from "@/core/audit/audit";

export const anyItemSchema = z.object({ id: z.any().optional() }).passthrough();

export interface ListParams {
  page?: number;
  pageSize?: number;
  search?: string;
  [key: string]: unknown;
}

export interface PaginatedResult<T> {
  items: T[];
  page: number;
  pageSize: number;
  total: number;
  raw: unknown;
}

export async function getPaginated<T>(
  path: string,
  params: ListParams,
  itemSchema: z.ZodType<T>
): Promise<PaginatedResult<T>> {
  const raw = await request<any>(`${path}${buildQuery(params as Record<string, any>)}`);
  const parsed = safeParseOrError(paginatedSchema(itemSchema), raw);
  const items = parsed.items ?? parsed.data ?? [];
  return {
    items,
    page: parsed.page ?? Number(params.page || 1),
    pageSize: parsed.pageSize ?? Number(params.pageSize || 20),
    total: parsed.total ?? items.length,
    raw
  };
}

export async function getLoose<T = any>(path: string): Promise<T> {
  return request<T>(path);
}

export async function postLoose<T = any>(path: string, body?: unknown): Promise<T> {
  const result = await request<T>(path, { method: "POST", body });
  if (path.startsWith("/v1/admin")) {
    await recordAndTrackAdminAction({
      action: path.replace("/v1/admin/", "").replaceAll("/", "."),
      entityType: "admin",
      entityId: extractEntityId(path),
      payloadSummary: summarizeBody(body)
    });
  }
  return result;
}

export async function putLoose<T = any>(path: string, body?: unknown): Promise<T> {
  const result = await request<T>(path, { method: "PUT", body });
  if (path.startsWith("/v1/admin")) {
    await recordAndTrackAdminAction({
      action: path.replace("/v1/admin/", "").replaceAll("/", "."),
      entityType: "admin",
      entityId: extractEntityId(path),
      payloadSummary: summarizeBody(body)
    });
  }
  return result;
}

function extractEntityId(path: string) {
  const parts = path.split("/").filter(Boolean);
  return parts.length >= 4 ? parts[3] : undefined;
}

function summarizeBody(body: unknown) {
  if (body == null) return undefined;
  try {
    const text = JSON.stringify(body);
    return text.length > 160 ? `${text.slice(0, 157)}...` : text;
  } catch {
    return undefined;
  }
}
