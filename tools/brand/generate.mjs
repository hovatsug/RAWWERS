// Regenerates every RAWWERS brand asset from two inputs: the colour tokens
// (app/lib/design/tokens.dart) and the app's own Archivo font. Run from the
// repo root with `make brand`, or here with `npm ci && npm run generate`.
//
// Outputs (all committed):
//   design/brand/*.svg             vector sources, text converted to outlines
//   design/brand/exports/          PNG exports for e-mail and print
//
// Nothing is drawn by hand: change a token or a proportion below and run it
// again.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as fontkit from 'fontkit';
import { Resvg } from '@resvg/resvg-js';

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, '../..');
const out = (...p) => path.join(repo, ...p);

// --- Inputs ---------------------------------------------------------------

/** The token colours, read from the Dart source so the two cannot drift. */
function readTokens() {
  const dart = fs.readFileSync(out('app/lib/design/tokens.dart'), 'utf8');
  const hex = (name) => {
    const m = dart.match(new RegExp(`static const ${name} = Color\\(0xFF([0-9A-Fa-f]{6})\\)`));
    if (!m) throw new Error(`token ${name} not found in tokens.dart`);
    return `#${m[1].toUpperCase()}`;
  };
  return {
    ink950: hex('i950'), // the dark ground and dark text
    ink050: hex('i050'), // light text on dark
    meter500: hex('meter500'), // corners on dark
    meter700: hex('meter700'), // corners on light
    paper: hex('paper'), // the pro icon's ground
  };
}

const C = readTokens();
const font = fontkit.openSync(out('app/assets/fonts/Archivo-Variable.ttf')).getVariation({ wght: 700, wdth: 100 });

// --- Geometry -------------------------------------------------------------
// Proportions are fractions of the cap height, so the logo is the same shape
// at any size. At a 32 cap height: 2 stroke and 14 arm (the brief's), and
// 24 / 20 of padding around the word, so the corners read as a viewfinder
// framing it rather than marks at its ends.

const LOGO = { stroke: 2 / 32, arm: 14 / 32, padX: 24 / 32, padY: 20 / 32, tracking: 0.16 };
// The icon mark is drawn heavier than the logo: it is read at 29-60px on a
// home screen, where a 2/32 stroke would vanish.
const MARK = { cap: 380, stroke: 30 / 380, arm: 160 / 380, pad: 171 / 380 };
const ICON = 1024;
// Android adaptive icons: a 108dp canvas, of which only a 66dp circle is
// sure to survive every launcher's mask.
const ADAPTIVE_SAFE_RADIUS = (ICON * 33) / 108;

const r2 = (n) => Math.round(n * 100) / 100;
const tidy = (d) => d.replace(/-?\d+\.\d+/g, (n) => String(r2(Number(n))));

/** Glyph outlines for [text] at [cap] height, baseline at y=0, from x=0. */
function outline(text, cap, tracking = 0) {
  const scale = cap / font.capHeight;
  const run = font.layout(text);
  let x = 0;
  const paths = [];
  run.glyphs.forEach((glyph, i) => {
    paths.push(glyph.path.scale(scale, -scale).translate(x, 0));
    x += run.positions[i].xAdvance * scale;
    if (i < run.glyphs.length - 1) x += tracking * (cap / (font.capHeight / font.unitsPerEm));
  });
  const boxes = paths.map((p) => p.bbox).filter((b) => Number.isFinite(b.minX));
  const bbox = {
    minX: Math.min(...boxes.map((b) => b.minX)),
    maxX: Math.max(...boxes.map((b) => b.maxX)),
    minY: -cap,
    maxY: 0,
  };
  return { d: paths.map((p) => p.toSVG()).join(' '), bbox };
}

/** Four corner brackets on the box (x, y, w, h), as filled shapes. */
function brackets(x, y, w, h, stroke, arm) {
  const t = stroke;
  const a = arm;
  const corner = (cx, cy, sx, sy) =>
    `M${r2(cx)} ${r2(cy)}h${r2(sx * a)}v${r2(sy * t)}h${r2(-sx * (a - t))}v${r2(sy * (a - t))}h${r2(-sx * t)}z`;
  return [
    corner(x, y, 1, 1),
    corner(x + w, y, -1, 1),
    corner(x, y + h, 1, -1),
    corner(x + w, y + h, -1, -1),
  ].join('');
}

const svg = (w, h, body) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${r2(w)} ${r2(h)}" width="${r2(w)}" height="${r2(h)}">\n${body}\n</svg>\n`;

// --- The logo: RAWWERS in four corners -------------------------------------

function logo({ corners, text }) {
  const cap = 32;
  const word = outline('RAWWERS', cap, LOGO.tracking);
  const padX = LOGO.padX * cap;
  const padY = LOGO.padY * cap;
  const stroke = LOGO.stroke * cap;
  const arm = LOGO.arm * cap;
  const inkW = word.bbox.maxX - word.bbox.minX;
  const w = inkW + 2 * padX;
  const h = cap + 2 * padY;
  const dx = padX - word.bbox.minX;
  const dy = padY + cap;
  return svg(
    w,
    h,
    [
      `  <path fill="${corners}" d="${brackets(0, 0, w, h, stroke, arm)}"/>`,
      `  <path fill="${text}" transform="translate(${r2(dx)} ${r2(dy)})" d="${tidy(word.d)}"/>`,
    ].join('\n'),
  );
}

// --- The icon mark: R in four corners --------------------------------------

/** The mark's artwork, centred in a 1024 square, at [scale] of full size. */
function mark({ corners, letter, scale = 1 }) {
  const cap = MARK.cap * scale;
  const r = outline('R', cap);
  const side = cap + 2 * MARK.pad * cap;
  const box = (ICON - side) / 2;
  const inkW = r.bbox.maxX - r.bbox.minX;
  const dx = ICON / 2 - inkW / 2 - r.bbox.minX;
  const dy = ICON / 2 + cap / 2;
  return [
    `  <path fill="${corners}" d="${brackets(box, box, side, side, MARK.stroke * cap, MARK.arm * cap)}"/>`,
    `  <path fill="${letter}" transform="translate(${r2(dx)} ${r2(dy)})" d="${tidy(r.d)}"/>`,
  ].join('\n');
}

const ground = (colour) => `  <rect width="${ICON}" height="${ICON}" fill="${colour}"/>`;

/** The scale that puts the mark's corners inside the adaptive safe circle. */
function adaptiveScale() {
  const side = MARK.cap + 2 * MARK.pad * MARK.cap;
  const halfDiagonal = (side / 2) * Math.SQRT2;
  return (ADAPTIVE_SAFE_RADIUS * 0.96) / halfDiagonal;
}

// --- Write -----------------------------------------------------------------

function write(rel, content) {
  const file = out(rel);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, content);
  return rel;
}

function png(svgText, width) {
  return new Resvg(svgText, { fitTo: { mode: 'width', value: width }, font: { loadSystemFonts: false } }).render().asPng();
}

export function sources() {
  const written = [];
  const b = 'design/brand';
  const client = { corners: C.meter500, letter: C.ink050, ground: C.ink950 };
  const pro = { corners: C.meter700, letter: C.ink950, ground: C.paper };
  const fg = adaptiveScale();

  written.push(
    write(`${b}/logo-primary-on-dark.svg`, logo({ corners: C.meter500, text: C.ink050 })),
    write(`${b}/logo-primary-on-light.svg`, logo({ corners: C.meter700, text: C.ink950 })),
    write(`${b}/logo-mono-ink.svg`, logo({ corners: C.ink950, text: C.ink950 })),
    write(`${b}/logo-mono-white.svg`, logo({ corners: C.ink050, text: C.ink050 })),
    write(`${b}/icon-client.svg`, svg(ICON, ICON, `${ground(client.ground)}\n${mark(client)}`)),
    write(`${b}/icon-pro.svg`, svg(ICON, ICON, `${ground(pro.ground)}\n${mark(pro)}`)),
    write(`${b}/icon-foreground-client.svg`, svg(ICON, ICON, mark({ ...client, scale: fg }))),
    write(`${b}/icon-foreground-pro.svg`, svg(ICON, ICON, mark({ ...pro, scale: fg }))),
    write(`${b}/icon-background-client.svg`, svg(ICON, ICON, ground(client.ground))),
    write(`${b}/icon-background-pro.svg`, svg(ICON, ICON, ground(pro.ground))),
    write(`${b}/icon-monochrome.svg`, svg(ICON, ICON, mark({ corners: C.ink950, letter: C.ink950, scale: fg }))),
  );

  // For e-mail (Brevo) and print: the on-light logo at twice its size.
  const onLight = fs.readFileSync(out(`${b}/logo-primary-on-light.svg`), 'utf8');
  const width = Number(onLight.match(/width="([\d.]+)"/)[1]);
  written.push(write(`${b}/exports/logo-primary-on-light@2x.png`, png(onLight, Math.round(width * 2))));
  return written;
}

export const internals = { C, ICON, ADAPTIVE_SAFE_RADIUS, MARK, png, write, out, adaptiveScale };

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  for (const f of sources()) console.log(f);
}
