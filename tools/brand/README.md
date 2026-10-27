# tools/brand

Generates every RAWWERS brand asset from the colour tokens and the Archivo
font in the app. One command, from the repo root:

    make brand

(or here: `npm ci && npm run generate`). Outputs are committed; see
`design/brand/README.md` for what each file is.

- Pinned exactly in `package.json` and `package-lock.json`: `fontkit` 2.0.4
  (outlines the font), `@resvg/resvg-js` 2.6.2 (renders SVG to PNG), `pngjs`
  7.0.0 (writes PNGs without an alpha channel where a platform needs that).
- Dev-only: no app or site depends on these. Licences: `LICENCES.md`
  (`npm run licences` after any dependency change).
- Node 20 or later.
