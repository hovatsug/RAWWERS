import { z } from "zod";

export const unknownRecordSchema = z.record(z.any());

export const meSchema = z
  .object({
    id: z.union([z.string(), z.number()]).optional(),
    email: z.string().optional(),
    roles: z.array(z.string()).default([]),
    permissions: z.array(z.string()).optional()
  })
  .passthrough();

export function paginatedSchema<T extends z.ZodTypeAny>(itemSchema: T) {
  return z
    .object({
      items: z.array(itemSchema).optional(),
      data: z.array(itemSchema).optional(),
      page: z.number().optional(),
      pageSize: z.number().optional(),
      total: z.number().optional()
    })
    .passthrough();
}

export function safeParseOrError<T>(schema: z.ZodType<T>, data: unknown): T {
  const parsed = schema.safeParse(data);
  if (!parsed.success) {
    throw new Error(`Invalid API response: ${parsed.error.message}`);
  }
  return parsed.data;
}
