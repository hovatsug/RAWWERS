// Regenerates every RAWWERS brand asset from two inputs: the colour tokens
// (app/lib/design/tokens.dart) and the app's own Archivo font. Run from the
// repo root with `make brand`, or here with `npm ci && npm run generate`.
//
// Outputs (all committed):
//   design/brand/*.svg             vector sources, text converted to outlines
//   design/brand/exports/          PNG exports for e-mail and print
//   app/ios/.../AppIcon-{client,pro}.appiconset   iOS icons, no alpha
//   app/android/app/src/{client,pro}/res          adaptive + legacy icons
//   web/app/icon.svg, icon.png, apple-icon.png    admin favicons
//   web/public/icons/, manifest.webmanifest       PWA icons and colours
//   app/ios/Runner/LaunchScreen{Client,Pro}.storyboard, LaunchLogo  splash
//   app/android/app/src/main/res/drawable-*/launch_logo.png         splash
//   app/android/app/src/{client,pro}/res/values/colors.xml          splash ground
//   app/assets/brand/, app/lib/design/brand.dart    the logo in the app (RLogo)
//   web/public/brand/, web/lib/brand.ts             the logo in the admin
//
// Nothing is drawn by hand: change a token or a proportion below and run it
// again.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as fontkit from 'fontkit';
import { Resvg } from '@resvg/resvg-js';
import { PNG } from 'pngjs';

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

// --- Platform icons --------------------------------------------------------

/** RGBA from resvg to an RGB PNG: iOS rejects an icon with an alpha channel. */
function opaque(rgbaPng) {
  const src = PNG.sync.read(rgbaPng);
  const dst = new PNG({ width: src.width, height: src.height, colorType: 2, inputHasAlpha: true });
  src.data.copy(dst.data);
  return PNG.sync.write(dst, { colorType: 2, inputHasAlpha: true });
}

const IOS_ICONS = [
  ['20x20', 'iphone', '2x'], ['20x20', 'iphone', '3x'],
  ['29x29', 'iphone', '1x'], ['29x29', 'iphone', '2x'], ['29x29', 'iphone', '3x'],
  ['40x40', 'iphone', '2x'], ['40x40', 'iphone', '3x'],
  ['60x60', 'iphone', '2x'], ['60x60', 'iphone', '3x'],
  ['20x20', 'ipad', '1x'], ['20x20', 'ipad', '2x'],
  ['29x29', 'ipad', '1x'], ['29x29', 'ipad', '2x'],
  ['40x40', 'ipad', '1x'], ['40x40', 'ipad', '2x'],
  ['76x76', 'ipad', '1x'], ['76x76', 'ipad', '2x'],
  ['83.5x83.5', 'ipad', '2x'],
  ['1024x1024', 'ios-marketing', '1x'],
];

// Android densities: the legacy icon is 48dp, an adaptive layer 108dp.
const DENSITIES = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };

export function platforms() {
  const written = [];
  const b = (name) => fs.readFileSync(out(`design/brand/${name}.svg`), 'utf8');
  const ground = { client: C.ink950, pro: C.paper };

  for (const flavor of ['client', 'pro']) {
    // iOS: one set per flavor, chosen by the flavor's xcconfig.
    const set = `app/ios/Runner/Assets.xcassets/AppIcon-${flavor}.appiconset`;
    fs.rmSync(out(set), { recursive: true, force: true });
    const images = IOS_ICONS.map(([size, idiom, scale]) => {
      const filename = `Icon-App-${size}@${scale}.png`;
      const px = Math.round(Number(size.split('x')[0]) * Number(scale[0]));
      if (!fs.existsSync(out(set, filename))) written.push(write(`${set}/${filename}`, opaque(png(b(`icon-${flavor}`), px))));
      return { size, idiom, filename, scale };
    });
    written.push(write(`${set}/Contents.json`, `${JSON.stringify({ images, info: { version: 1, author: 'tools/brand' } }, null, 2)}\n`));

    // Android: adaptive (foreground, background colour, monochrome) and a
    // legacy square for launchers before API 26.
    const res = `app/android/app/src/${flavor}/res`;
    // The generator owns these folders: cleared first, so nothing stale
    // (a density dropped, a layer renamed) survives a regeneration.
    for (const dir of fs.existsSync(out(res)) ? fs.readdirSync(out(res)) : []) {
      if (dir.startsWith('mipmap-')) fs.rmSync(out(res, dir), { recursive: true, force: true });
    }
    for (const [density, k] of Object.entries(DENSITIES)) {
      written.push(
        write(`${res}/mipmap-${density}/ic_launcher.png`, png(b(`icon-${flavor}`), 48 * k)),
        write(`${res}/mipmap-${density}/ic_launcher_foreground.png`, png(b(`icon-foreground-${flavor}`), 108 * k)),
        write(`${res}/mipmap-${density}/ic_launcher_monochrome.png`, png(b('icon-monochrome'), 108 * k)),
      );
    }
    written.push(
      write(
        `${res}/mipmap-anydpi-v26/ic_launcher.xml`,
        [
          '<?xml version="1.0" encoding="utf-8"?>',
          '<!-- Generated by tools/brand. -->',
          '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">',
          '    <background android:drawable="@color/ic_launcher_background"/>',
          '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>',
          '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>',
          '</adaptive-icon>',
          '',
        ].join('\n'),
      ),
      write(
        `${res}/values/ic_launcher_background.xml`,
        [
          '<?xml version="1.0" encoding="utf-8"?>',
          '<!-- Generated by tools/brand from the tokens. -->',
          '<resources>',
          `    <color name="ic_launcher_background">${ground[flavor]}</color>`,
          '</resources>',
          '',
        ].join('\n'),
      ),
    );
  }

  // The template icons in main/ would show for any variant a flavor misses.
  for (const density of Object.keys(DENSITIES)) {
    fs.rmSync(out(`app/android/app/src/main/res/mipmap-${density}`), { recursive: true, force: true });
  }

  // Web (admin and the client web app): the dark R mark.
  const client = b('icon-client');
  fs.rmSync(out('web/public/icons'), { recursive: true, force: true });
  written.push(
    write('web/app/icon.svg', client),
    write('web/app/icon.png', png(client, 32)),
    write('web/app/apple-icon.png', opaque(png(client, 180))),
    write('web/public/icons/icon-192.png', png(client, 192)),
    write('web/public/icons/icon-512.png', png(client, 512)),
  );
  const manifestPath = out('web/public/manifest.webmanifest');
  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  manifest.background_color = C.ink950;
  manifest.theme_color = C.ink950;
  manifest.icons = [
    { src: '/icons/icon-192.png', sizes: '192x192', type: 'image/png', purpose: 'any' },
    { src: '/icons/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'any' },
  ];
  written.push(write('web/public/manifest.webmanifest', `${JSON.stringify(manifest, null, 2)}\n`));
  return written;
}

// --- Launch screens ---------------------------------------------------------
// Always dark, both flavors, light or dark mode: the logo on Ink 950,
// centred, no animation. The first Flutter frame (/launch) paints the same
// ground, so start-up reads as one screen.

/** The logo's width on the launch screen, in points (iOS) and dp (Android). */
export const LAUNCH_LOGO_WIDTH = 200;

const storyboardColour = (hex) => {
  const [r, g, b] = [1, 3, 5].map((i) => (parseInt(hex.slice(i, i + 2), 16) / 255).toFixed(11));
  return `red="${r}" green="${g}" blue="${b}"`;
};

function storyboard(flavor, logoHeight) {
  const id = flavor === 'client' ? 'cl' : 'pr';
  return `<?xml version="1.0" encoding="UTF-8"?>
<!-- Generated by tools/brand. The launch screen for the ${flavor} app: the
     logo on Ink 950, centred. The logo is an image (LaunchLogo) rendered from
     design/brand, so UIKit needs no copy of the font. -->
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="22505" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="01J">
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="22504"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
    </dependencies>
    <scenes>
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <imageView clipsSubviews="YES" userInteractionEnabled="NO" contentMode="scaleAspectFit" image="LaunchLogo" translatesAutoresizingMaskIntoConstraints="NO" id="lgo-${id}-001">
                                <rect key="frame" x="${r2((393 - LAUNCH_LOGO_WIDTH) / 2)}" y="${r2((852 - logoHeight) / 2)}" width="${LAUNCH_LOGO_WIDTH}" height="${r2(logoHeight)}"/>
                                <constraints>
                                    <constraint firstAttribute="width" constant="${LAUNCH_LOGO_WIDTH}" id="w-${id}-001"/>
                                    <constraint firstAttribute="height" constant="${r2(logoHeight)}" id="h-${id}-001"/>
                                </constraints>
                            </imageView>
                        </subviews>
                        <viewLayoutGuide key="safeArea" id="sfa-${id}-001"/>
                        <color key="backgroundColor" ${storyboardColour(C.ink950)} alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                        <constraints>
                            <constraint firstItem="lgo-${id}-001" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="cx-${id}-001"/>
                            <constraint firstItem="lgo-${id}-001" firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="cy-${id}-001"/>
                        </constraints>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
    <resources>
        <image name="LaunchLogo" width="${LAUNCH_LOGO_WIDTH}" height="${r2(logoHeight)}"/>
    </resources>
</document>
`;
}

export function launch() {
  const written = [];
  const logoSvg = fs.readFileSync(out('design/brand/logo-primary-on-dark.svg'), 'utf8');
  const [w, h] = logoSvg.match(/viewBox="0 0 ([\d.]+) ([\d.]+)"/).slice(1).map(Number);
  const logoHeight = (LAUNCH_LOGO_WIDTH * h) / w;

  // iOS: the logo image at 1x/2x/3x, and both flavors' storyboards.
  const set = 'app/ios/Runner/Assets.xcassets/LaunchLogo.imageset';
  fs.rmSync(out(set), { recursive: true, force: true });
  const images = [1, 2, 3].map((k) => {
    const filename = `LaunchLogo@${k}x.png`;
    written.push(write(`${set}/${filename}`, png(logoSvg, LAUNCH_LOGO_WIDTH * k)));
    return { idiom: 'universal', filename, scale: `${k}x` };
  });
  written.push(write(`${set}/Contents.json`, `${JSON.stringify({ images, info: { version: 1, author: 'tools/brand' } }, null, 2)}\n`));
  for (const flavor of ['client', 'pro']) {
    const name = flavor === 'client' ? 'LaunchScreenClient' : 'LaunchScreenPro';
    written.push(write(`app/ios/Runner/${name}.storyboard`, storyboard(flavor, logoHeight)));
  }

  // Android: the logo per density, and both flavors' launch ground.
  for (const [density, k] of Object.entries(DENSITIES)) {
    written.push(write(`app/android/app/src/main/res/drawable-${density}/launch_logo.png`, png(logoSvg, LAUNCH_LOGO_WIDTH * k)));
  }
  for (const flavor of ['client', 'pro']) {
    written.push(
      write(
        `app/android/app/src/${flavor}/res/values/colors.xml`,
        [
          '<?xml version="1.0" encoding="utf-8"?>',
          '<!-- Generated by tools/brand. The launch ground: RInk.i950 for both',
          '     flavors - the splash is always dark, and the first Flutter frame',
          '     (/launch) paints the same colour. -->',
          '<resources>',
          `    <color name="launch_ground">#FF${C.ink950.slice(1)}</color>`,
          '</resources>',
          '',
        ].join('\n'),
      ),
    );
  }
  return written;
}

// --- The logo in the apps ----------------------------------------------------
// RLogo draws the same four SVG files, and sizes itself from the numbers
// below rather than from copies typed into Dart: the launch width the
// storyboards use, the logo's proportions, and the width under which the
// one-colour logo takes over (design/brand/README.md).

/** Below this width (px, pt, dp) the two-colour logo gives way to the mono one. */
export const LOGO_MIN_PRIMARY_WIDTH = 120;

/** The logo at the top of a signed-out screen, in the apps and on the web. */
export const LOGO_SIGN_IN_WIDTH = 160;

const LOGOS = ['logo-primary-on-dark', 'logo-primary-on-light', 'logo-mono-ink', 'logo-mono-white'];

export function inApp() {
  const written = [];
  for (const dir of ['app/assets/brand', 'web/public/brand']) {
    fs.rmSync(out(dir), { recursive: true, force: true });
    for (const name of LOGOS) {
      written.push(write(`${dir}/${name}.svg`, fs.readFileSync(out(`design/brand/${name}.svg`), 'utf8')));
    }
  }
  const [w, h] = fs
    .readFileSync(out('design/brand/logo-primary-on-dark.svg'), 'utf8')
    .match(/viewBox="0 0 ([\d.]+) ([\d.]+)"/)
    .slice(1)
    .map(Number);
  const camel = (name) => name.replace(/^logo-/, '').replace(/-(\w)/g, (_, c) => c.toUpperCase());
  written.push(
    write(
      'app/lib/design/brand.dart',
      [
        '// Generated by tools/brand (`make brand`). Do not edit: change',
        '// tools/brand/generate.mjs and regenerate.',
        '',
        '/// The logo\'s files and geometry, as the generator drew them. RLogo',
        '/// sizes itself from these, and the launch screens use the same width.',
        'abstract final class RBrand {',
        '  /// Width over height, the same for all four logo files.',
        `  static const logoAspectRatio = ${w} / ${h};`,
        '',
        '  /// The logo\'s width on the native launch screens (iOS points, Android',
        '  /// dp), so the first Flutter frame can draw it in the same place.',
        `  static const launchLogoWidth = ${LAUNCH_LOGO_WIDTH.toFixed(1)};`,
        '',
        '  /// Below this width the one-colour logo replaces the two-colour one.',
        `  static const logoMinPrimaryWidth = ${LOGO_MIN_PRIMARY_WIDTH.toFixed(1)};`,
        '',
        '  /// The logo at the top of a signed-out screen.',
        `  static const signInLogoWidth = ${LOGO_SIGN_IN_WIDTH.toFixed(1)};`,
        '',
        ...LOGOS.map((name) => `  static const ${camel(name)} = 'assets/brand/${name}.svg';`),
        '}',
        '',
      ].join('\n'),
    ),
  );
  written.push(
    write(
      'web/lib/brand.ts',
      [
        '// Generated by tools/brand (`make brand`). Do not edit: change',
        '// tools/brand/generate.mjs and regenerate.',
        '',
        '/** The logo\'s files (in public/brand) and geometry, as the generator drew them. */',
        'export const brand = {',
        '  /** Width over height, the same for all four logo files. */',
        `  logoAspectRatio: ${w} / ${h},`,
        '  /** Below this width (CSS px) the one-colour logo replaces the two-colour one. */',
        `  logoMinPrimaryWidth: ${LOGO_MIN_PRIMARY_WIDTH},`,
        '  /** The logo at the top of a signed-out screen (CSS px). */',
        `  signInLogoWidth: ${LOGO_SIGN_IN_WIDTH},`,
        '  logos: {',
        ...LOGOS.map((name) => `    ${camel(name)}: "/brand/${name}.svg",`),
        '  }',
        '} as const;',
        '',
      ].join('\n'),
    ),
  );
  return written;
}

export const internals = { C, ICON, ADAPTIVE_SAFE_RADIUS, MARK, png, write, out, adaptiveScale };

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  for (const f of [...sources(), ...platforms(), ...launch(), ...inApp()]) console.log(f);
}
