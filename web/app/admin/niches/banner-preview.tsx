"use client";

import type { BannerStyle } from "@/lib/api/admin";

/**
 * How the app will draw a niche banner, for the admin to judge before saving.
 *
 * Mirrors RNicheBanner in the app (app/lib/design/components/r_niche_banner.dart):
 * the same shapes, the same crop around the focal point, the same scrim and
 * the same text-only design. The colours are the app's RBanner tokens
 * (app/lib/design/tokens.dart), repeated here because the web cannot read the
 * Dart file; change them there and here together.
 */
const TOKENS = {
  textGround: "#2C4F66", // RAccent.meter700
  textName: "#FAFAFA", // RInk.i050
  textTagline: "#E4E4E3", // RInk.i200
  textRule: "#4A7FA5", // RAccent.meter500
  scrim: "14, 15, 17", // RInk.i950
  title: "#FAFAFA" // RInk.i050
};

/** Tile is the Discover row heading, hero the niche page's top - at a phone's width. */
const SHAPES = {
  tile: { width: 360, height: 96, title: "text-sm font-semibold", pad: "p-2" },
  hero: { width: 360, height: 200, title: "text-xl font-semibold", pad: "p-6" }
} as const;

export type PreviewImage = { url: string; focalX: number; focalY: number; scrim: number; alt: string };

export function BannerPreview({
  shape,
  style,
  title,
  tagline,
  image
}: {
  shape: keyof typeof SHAPES;
  style: BannerStyle;
  title: string;
  tagline: string | null;
  image: PreviewImage | null;
}) {
  const s = SHAPES[shape];
  const line = shape === "hero" && tagline ? tagline : null;
  const frame = { width: s.width, height: s.height };

  if (style === "text") {
    return (
      <div data-testid={`preview-${shape}-text`} className={`relative flex flex-col justify-end ${s.pad}`} style={{ ...frame, background: TOKENS.textGround }}>
        <span className="mb-2 block h-0.5 w-6" style={{ background: TOKENS.textRule }} />
        <span className={s.title} style={{ color: TOKENS.textName }}>{title}</span>
        {line ? <span className="mt-1 truncate text-sm" style={{ color: TOKENS.textTagline }}>{line}</span> : null}
      </div>
    );
  }

  if (!image) {
    return (
      <div data-testid={`preview-${shape}-neutral`} className={`relative flex items-end bg-slate-300 ${s.pad}`} style={frame}>
        <span className={`${s.title} text-slate-900`}>{title}</span>
      </div>
    );
  }

  return (
    <div data-testid={`preview-${shape}-image`} className="relative overflow-hidden" style={frame}>
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src={image.url}
        alt={image.alt}
        className="absolute inset-0 h-full w-full object-cover"
        style={{ objectPosition: `${image.focalX * 100}% ${image.focalY * 100}%` }}
      />
      <div
        data-testid={`preview-${shape}-scrim`}
        className="absolute inset-0"
        style={{ background: `linear-gradient(to bottom, rgba(${TOKENS.scrim},0) 35%, rgba(${TOKENS.scrim},${image.scrim}) 100%)` }}
      />
      <div className={`absolute inset-0 flex flex-col justify-end ${s.pad}`}>
        <span className={s.title} style={{ color: TOKENS.title }}>{title}</span>
        {line ? <span className="mt-1 truncate text-sm" style={{ color: TOKENS.title }}>{line}</span> : null}
      </div>
    </div>
  );
}
