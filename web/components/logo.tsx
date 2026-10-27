import Image from "next/image";
import { brand } from "@/lib/brand";

type Ground = "dark" | "light";

/**
 * The RAWWERS logo, drawn from the generated SVG files (tools/brand writes
 * them to public/brand, with their geometry in lib/brand.ts) - never the
 * name typed out. Under the minimum width the one-colour logo for the same
 * ground takes over, as the brand rules ask (design/brand/README.md).
 */
export function Logo({ width, ground = "dark", className }: { width: number; ground?: Ground; className?: string }) {
  const primary = width >= brand.logoMinPrimaryWidth;
  const src =
    ground === "dark"
      ? primary
        ? brand.logos.primaryOnDark
        : brand.logos.monoWhite
      : primary
        ? brand.logos.primaryOnLight
        : brand.logos.monoInk;
  return (
    <Image
      src={src}
      alt="RAWWERS"
      width={width}
      height={Math.round((width / brand.logoAspectRatio) * 100) / 100}
      // An SVG needs no resizing, and the optimiser refuses SVGs by default.
      unoptimized
      priority
      className={className}
    />
  );
}
