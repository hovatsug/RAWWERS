"use client";

import { useEffect, useMemo, useState } from "react";
import { useParams } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import {
  admin,
  type BannerImageFields,
  type BannerLimits,
  type BannerStyle,
  type BannerUploadCompleted,
  type NicheBannerDetail
} from "@/lib/api/admin";
import {
  AdminButton,
  ConfirmDialog,
  FieldLabel,
  Notice,
  PageHeader,
  Panel,
  SelectField,
  StatusBadge,
  TextField
} from "@/app/admin/_components/ui";
import { BannerPreview, type PreviewImage } from "@/app/admin/niches/banner-preview";

/**
 * One niche's banner: its style, its tagline and its image, with previews of
 * both styles as the app draws them before anything is saved.
 *
 * An image goes straight from this browser to storage through a presigned
 * upload, then the server checks it (format, size, dimensions), makes its
 * copies and measures its scrim. Nothing is lost by any change here: a
 * replaced or removed image stays in the history and the previous one can
 * be restored; switching to Text only keeps the image.
 */
type Pending = BannerUploadCompleted & { objectUrl: string; fileName: string };

const LABELS: Record<string, string> = { "image/jpeg": "JPEG", "image/png": "PNG", "image/webp": "WebP" };

function formats(limits: BannerLimits): string {
  const names = limits.mime_types.map((t) => LABELS[t] ?? t);
  return names.length === 1 ? names[0] : `${names.slice(0, -1).join(", ")} or ${names[names.length - 1]}`;
}

function megabytes(n: number): string {
  return n >= 1_000_000 ? `${Math.round(n / 1_000_000)} MB` : `${(n / 1_000_000).toFixed(2)} MB`;
}

/** The checks the server makes, made first here so the words come before the wait. */
async function checkFile(file: File, limits: BannerLimits): Promise<{ error: string | null; warning: string | null }> {
  if (!limits.mime_types.includes(file.type)) return { error: `A banner must be a ${formats(limits)} image.`, warning: null };
  if (file.size > limits.max_bytes) return { error: `The image is ${megabytes(file.size)}; the limit is ${megabytes(limits.max_bytes)}.`, warning: null };
  let width = 0;
  let height = 0;
  try {
    const bitmap = await createImageBitmap(file);
    width = bitmap.width;
    height = bitmap.height;
    bitmap.close();
  } catch {
    return { error: `This file is not a ${formats(limits)} image.`, warning: null };
  }
  if (width < limits.min_width || height < limits.min_height) {
    return { error: `The image is ${width}×${height} pixels; a full-width banner needs at least ${limits.min_width}×${limits.min_height}.`, warning: null };
  }
  return { error: null, warning: height > width ? "This image is portrait. Banners are wide, so most of it will be cropped away - check both previews." : null };
}

const EMPTY_FIELDS: BannerImageFields = { alt_text: "", focal_x: 0.5, focal_y: 0.5, source: "owner", credit: null, licence: null, source_url: null };

function fieldsOf(detail: NicheBannerDetail | undefined): BannerImageFields {
  const c = detail?.current;
  return c
    ? { alt_text: c.alt_text, focal_x: c.focal_x, focal_y: c.focal_y, source: c.source, credit: c.credit, licence: c.licence, source_url: c.source_url }
    : EMPTY_FIELDS;
}

export default function NicheBannerEditor() {
  const { slug } = useParams<{ slug: string }>();
  const queryClient = useQueryClient();
  const query = useQuery({ queryKey: ["admin", "niche-banner", slug], queryFn: () => admin.nicheBanner(slug) });
  const detail = query.data?.ok ? query.data.data : undefined;

  const [style, setStyle] = useState<BannerStyle>("image");
  const [tagline, setTagline] = useState("");
  const [fields, setFields] = useState<BannerImageFields>(EMPTY_FIELDS);
  const [pending, setPending] = useState<Pending | null>(null);
  const [checking, setChecking] = useState<{ error: string | null; warning: string | null }>({ error: null, warning: null });
  const [busy, setBusy] = useState<string | null>(null);
  const [message, setMessage] = useState<{ tone: "error" | "success" | "warning"; text: string } | null>(null);
  const [confirmRemove, setConfirmRemove] = useState(false);

  useEffect(() => {
    if (!detail) return;
    setStyle(detail.banner_style);
    setTagline(detail.banner_tagline ?? "");
    setFields(fieldsOf(detail));
  }, [detail]);

  const refresh = (next?: NicheBannerDetail) => {
    if (next) queryClient.setQueryData(["admin", "niche-banner", slug], { ok: true, data: next });
    queryClient.invalidateQueries({ queryKey: ["admin", "niche-banners"] });
  };

  const previewImage: PreviewImage | null = useMemo(() => {
    if (pending) return { url: pending.objectUrl, focalX: fields.focal_x, focalY: fields.focal_y, scrim: pending.scrim_opacity, alt: fields.alt_text };
    const c = detail?.current;
    if (c?.hero_url) return { url: c.hero_url, focalX: fields.focal_x, focalY: fields.focal_y, scrim: c.scrim_opacity, alt: fields.alt_text };
    return null;
  }, [pending, detail, fields]);

  if (query.isLoading) return <PageHeader title="Niche banner" description="Loading…" />;
  if (!detail) {
    return (
      <>
        <PageHeader title="Niche banner" />
        <Notice tone="error">{query.data && !query.data.ok ? query.data.error.message : "Check that the API is reachable."}</Notice>
      </>
    );
  }

  const limits = detail.limits;
  const taglineTooLong = tagline.trim().length > limits.tagline_max;
  const styleChanged = style !== detail.banner_style || (tagline.trim() || null) !== (detail.banner_tagline ?? null);
  const stockMissing =
    fields.source === "stock" ? (["credit", "licence", "source_url"] as const).filter((k) => !(fields[k] ?? "").trim()) : [];
  const altMissing = !fields.alt_text.trim();
  const fieldsChanged = JSON.stringify(fields) !== JSON.stringify(fieldsOf(detail));
  const canSaveImage = (pending !== null || (detail.current !== null && fieldsChanged)) && !altMissing && stockMissing.length === 0 && busy === null;

  async function onFile(file: File | undefined) {
    setMessage(null);
    setPending(null);
    if (!file) return;
    const result = await checkFile(file, limits);
    setChecking(result);
    if (result.error) return;
    setBusy("Uploading…");
    try {
      const started = await admin.startBannerUpload(file.type, file.name);
      if (!started.ok) return setMessage({ tone: "error", text: started.error.message });
      const put = await fetch(started.data.upload.url, { method: "PUT", headers: started.data.upload.headers, body: file });
      if (!put.ok) return setMessage({ tone: "error", text: `The upload to storage failed (${put.status}). Nothing was saved.` });
      const done = await admin.completeBannerUpload(started.data.media_asset_id);
      if (!done.ok) return setMessage({ tone: "error", text: done.error.message });
      setPending({ ...done.data, objectUrl: URL.createObjectURL(file), fileName: file.name });
      setFields(EMPTY_FIELDS);
      if (done.data.warnings.length) setMessage({ tone: "warning", text: done.data.warnings.join(" ") });
    } finally {
      setBusy(null);
    }
  }

  async function saveImage() {
    setMessage(null);
    setBusy("Saving…");
    try {
      const res = pending
        ? await admin.setBannerImage(slug, { ...fields, media_asset_id: pending.media_asset_id })
        : await admin.editBannerImage(slug, fields);
      if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
      setPending(null);
      refresh(res.data);
      setMessage({ tone: "success", text: "Saved. The apps show it on their next load." });
    } finally {
      setBusy(null);
    }
  }

  async function saveStyle() {
    setMessage(null);
    const body: { banner_style?: BannerStyle; banner_tagline?: string | null } = {};
    if (style !== detail!.banner_style) body.banner_style = style;
    if ((tagline.trim() || null) !== (detail!.banner_tagline ?? null)) body.banner_tagline = tagline.trim() || null;
    const res = await admin.editNicheBanner(slug, body);
    if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
    refresh(res.data);
    setMessage({ tone: "success", text: "Saved. The apps show it on their next load." });
  }

  async function revert() {
    setMessage(null);
    const res = await admin.revertBannerImage(slug);
    if (!res.ok) return setMessage({ tone: "error", text: res.error.message });
    refresh(res.data);
    setMessage({ tone: "success", text: "The previous image is back." });
  }

  const setField = <K extends keyof BannerImageFields>(key: K, value: BannerImageFields[K]) => setFields({ ...fields, [key]: value });

  return (
    <>
      <PageHeader title={`${detail.name} banner`} description={<StatusBadge status={detail.status} />} />
      {message ? <div className="mb-4"><Notice tone={message.tone}>{message.text}</Notice></div> : null}

      <div className="grid gap-4 lg:grid-cols-2">
        <Panel className="p-4">
          <h2 className="mb-3 text-sm font-semibold text-slate-200">Style</h2>
          <fieldset className="flex gap-4 text-sm text-slate-200">
            <legend className="sr-only">Banner style</legend>
            <label className="flex items-center gap-2">
              <input type="radio" name="style" checked={style === "image"} onChange={() => setStyle("image")} /> Image
            </label>
            <label className="flex items-center gap-2">
              <input type="radio" name="style" checked={style === "text"} onChange={() => setStyle("text")} /> Text only
            </label>
          </fieldset>
          <p className="mt-2 text-xs text-slate-400">
            Text only draws a typographic banner with no image. It keeps the image and its history; switch back at any time.
          </p>
          <div className="mt-3">
            <FieldLabel htmlFor="tagline">Tagline (optional, up to {limits.tagline_max} characters)</FieldLabel>
            <TextField id="tagline" value={tagline} onChange={(e) => setTagline(e.target.value)} />
            <p className={`mt-1 text-xs ${taglineTooLong ? "text-rose-300" : "text-slate-500"}`}>
              {tagline.trim().length} / {limits.tagline_max}
              {taglineTooLong ? ` - ${tagline.trim().length - limits.tagline_max} too many` : ""}
            </p>
          </div>
          <AdminButton className="mt-2" disabled={!styleChanged || taglineTooLong} onClick={saveStyle}>
            Save style and tagline
          </AdminButton>
        </Panel>

        <Panel className="p-4">
          <h2 className="mb-3 text-sm font-semibold text-slate-200">Preview</h2>
          <p className="mb-2 text-xs text-slate-400">As the app draws it, with your unsaved changes. On Discover the city follows the name.</p>
          <div className="grid gap-3">
            {(["image", "text"] as const).map((s) => (
              <div key={s}>
                <p className="mb-1 text-xs font-medium text-slate-300">{s === "image" ? "Image" : "Text only"}</p>
                <div className="flex flex-wrap gap-3">
                  <BannerPreview shape="tile" style={s} title={detail.name} tagline={tagline.trim() || null} image={previewImage} />
                  <BannerPreview shape="hero" style={s} title={detail.name} tagline={tagline.trim() || null} image={previewImage} />
                </div>
              </div>
            ))}
          </div>
        </Panel>
      </div>

      <Panel className="mt-4 p-4">
        <h2 className="mb-3 text-sm font-semibold text-slate-200">Image</h2>
        <FieldLabel htmlFor="file">
          {detail.current ? "Replace with a new image" : "Upload an image"} ({formats(limits)}, up to {megabytes(limits.max_bytes)}, at least{" "}
          {limits.min_width}×{limits.min_height})
        </FieldLabel>
        <input
          id="file"
          type="file"
          accept={limits.mime_types.join(",")}
          className="text-sm text-slate-300"
          onChange={(e) => onFile(e.target.files?.[0])}
        />
        {checking.error ? <div className="mt-2"><Notice tone="error">{checking.error}</Notice></div> : null}
        {checking.warning ? <div className="mt-2"><Notice tone="warning">{checking.warning}</Notice></div> : null}
        {busy ? <p className="mt-2 text-sm text-slate-400" role="status">{busy}</p> : null}

        {previewImage ? (
          <div className="mt-4 grid gap-4 lg:grid-cols-2">
            <div>
              <FieldLabel>Focal point - click what must stay visible</FieldLabel>
              <div
                data-testid="focal-picker"
                className="relative inline-block cursor-crosshair"
                onClick={(e) => {
                  const box = e.currentTarget.getBoundingClientRect();
                  const round = (v: number) => Math.round(Math.min(1, Math.max(0, v)) * 100) / 100;
                  setFields({ ...fields, focal_x: round((e.clientX - box.left) / box.width), focal_y: round((e.clientY - box.top) / box.height) });
                }}
              >
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={previewImage.url} alt={fields.alt_text || "The banner image"} className="block max-h-72 max-w-full" />
                <span
                  aria-hidden
                  className="pointer-events-none absolute h-5 w-5 -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-white shadow"
                  style={{ left: `${fields.focal_x * 100}%`, top: `${fields.focal_y * 100}%` }}
                />
              </div>
              <div className="mt-2 flex gap-3">
                <div>
                  <FieldLabel htmlFor="focal-x">Across (0-1)</FieldLabel>
                  <TextField id="focal-x" inputMode="decimal" value={fields.focal_x} onChange={(e) => setField("focal_x", Number(e.target.value))} />
                </div>
                <div>
                  <FieldLabel htmlFor="focal-y">Down (0-1)</FieldLabel>
                  <TextField id="focal-y" inputMode="decimal" value={fields.focal_y} onChange={(e) => setField("focal_y", Number(e.target.value))} />
                </div>
              </div>
            </div>

            <div className="grid content-start gap-3">
              <div>
                <FieldLabel htmlFor="alt">Alt text (required) - what the image shows, for people who cannot see it</FieldLabel>
                <TextField id="alt" maxLength={limits.alt_max} value={fields.alt_text} onChange={(e) => setField("alt_text", e.target.value)} />
              </div>
              <div>
                <FieldLabel htmlFor="source">Source</FieldLabel>
                <SelectField id="source" value={fields.source} onChange={(e) => setField("source", e.target.value as "owner" | "stock")}>
                  <option value="owner">Our own upload</option>
                  <option value="stock">Stock image</option>
                </SelectField>
              </div>
              <div className="grid gap-3 md:grid-cols-3">
                <div>
                  <FieldLabel htmlFor="credit">Photographer credit{fields.source === "stock" ? " (required)" : ""}</FieldLabel>
                  <TextField id="credit" value={fields.credit ?? ""} onChange={(e) => setField("credit", e.target.value)} />
                </div>
                <div>
                  <FieldLabel htmlFor="licence">Licence{fields.source === "stock" ? " (required)" : ""}</FieldLabel>
                  <TextField id="licence" value={fields.licence ?? ""} onChange={(e) => setField("licence", e.target.value)} />
                </div>
                <div>
                  <FieldLabel htmlFor="source-url">Source URL{fields.source === "stock" ? " (required)" : ""}</FieldLabel>
                  <TextField id="source-url" value={fields.source_url ?? ""} onChange={(e) => setField("source_url", e.target.value)} />
                </div>
              </div>
              {altMissing ? <p className="text-xs text-amber-300">Add alt text to save.</p> : null}
              {stockMissing.length ? <p className="text-xs text-amber-300">A stock image needs its credit, licence and source URL.</p> : null}
              <div className="flex flex-wrap gap-2">
                <AdminButton disabled={!canSaveImage} onClick={saveImage}>
                  {pending ? "Save new image" : "Save changes"}
                </AdminButton>
                {detail.current && !pending ? (
                  <AdminButton tone="danger" onClick={() => setConfirmRemove(true)}>
                    Remove image
                  </AdminButton>
                ) : null}
              </div>
            </div>
          </div>
        ) : (
          <p className="mt-3 text-sm text-slate-400">
            {detail.banner_style === "image" ? "No image yet: the app shows a plain ground until one is uploaded." : "No image on file."}
          </p>
        )}
      </Panel>

      <Panel className="mt-4 p-4">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-sm font-semibold text-slate-200">History</h2>
          {detail.has_previous ? (
            <AdminButton tone="secondary" onClick={revert}>
              Go back to the previous image
            </AdminButton>
          ) : null}
        </div>
        {detail.history.length ? (
          <ul className="grid gap-3 md:grid-cols-3">
            {detail.history.map((h) => (
              <li key={h.banner_id} className="text-xs text-slate-400">
                {h.tile_url ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={h.tile_url} alt={h.alt_text} className="mb-1 h-16 w-full rounded object-cover" />
                ) : null}
                <p>
                  <StatusBadge label={h.state === "current" ? "Current" : h.state === "previous" ? "Previous" : "Earlier"} tone={h.state === "current" ? "positive" : "neutral"} />{" "}
                  {new Date(h.created_at).toLocaleString()}
                </p>
                <p>{h.source === "stock" ? `${h.credit ?? ""} · ${h.licence ?? ""}` : "Our own upload"}</p>
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-sm text-slate-400">No images yet.</p>
        )}
      </Panel>

      <ConfirmDialog
        open={confirmRemove}
        title="Remove this image?"
        confirmLabel="Remove image"
        tone="danger"
        onClose={() => setConfirmRemove(false)}
        onConfirm={async () => {
          const res = await admin.removeBannerImage(slug);
          if (!res.ok) return res.error.message;
          refresh(res.data);
          setMessage({ tone: "success", text: "Removed. It stays in the history and can be restored." });
          return null;
        }}
      >
        The niche shows a plain ground until another image is uploaded. The image stays in the history, and you can go back to it.
      </ConfirmDialog>
    </>
  );
}
