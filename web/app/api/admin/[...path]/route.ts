import { NextRequest, NextResponse } from "next/server";

/**
 * Server-side proxy for admin API calls.
 *
 * The backend requires X-Admin-Api-Key on every /v1/admin route. That key
 * cannot go anywhere near the browser: a NEXT_PUBLIC_ variable is inlined
 * into the client bundle and served to every visitor, which would hand out
 * the credential the backend refuses to start without. So the key lives in
 * a server-only env var and never leaves this process.
 *
 * The caller's own bearer token is forwarded untouched, so the backend
 * still authenticates and authorises the individual admin. This proxy adds
 * the shared key; it does not grant anything on its own.
 */
const API_BASE_URL = process.env.API_BASE_URL || process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000";
const ADMIN_API_KEY = process.env.ADMIN_API_KEY || "";

async function forward(req: NextRequest, path: string[]) {
  if (!ADMIN_API_KEY) {
    // Mirrors the backend's own refusal rather than failing obscurely at
    // the API with a 403 the operator would have to go and decode.
    return NextResponse.json(
      { error: { code: "admin_key_missing", message: "ADMIN_API_KEY is not set on the web server." } },
      { status: 500 }
    );
  }

  const url = new URL(`/v1/admin/${path.join("/")}`, API_BASE_URL);
  req.nextUrl.searchParams.forEach((value, key) => url.searchParams.set(key, value));

  const headers = new Headers();
  headers.set("Content-Type", "application/json");
  headers.set("X-Admin-Api-Key", ADMIN_API_KEY);
  const auth = req.headers.get("authorization");
  if (auth) headers.set("Authorization", auth);

  const body = req.method === "GET" || req.method === "HEAD" ? undefined : await req.text();
  const res = await fetch(url.toString(), { method: req.method, headers, body, cache: "no-store" });
  const text = await res.text();

  return new NextResponse(text || null, {
    status: res.status,
    headers: { "Content-Type": res.headers.get("Content-Type") || "application/json" }
  });
}

export async function GET(req: NextRequest, ctx: { params: { path: string[] } }) {
  return forward(req, ctx.params.path);
}

export async function POST(req: NextRequest, ctx: { params: { path: string[] } }) {
  return forward(req, ctx.params.path);
}

export async function PUT(req: NextRequest, ctx: { params: { path: string[] } }) {
  return forward(req, ctx.params.path);
}
