# RAWWERS — Pro app identity + logo and icons (two briefs, one task)

Save this file verbatim as `docs/briefs/rawwers-identity-and-brand-prompt.md`, then do the task below.

## How to run this task
- **Brief 1** = the pro app visual identity ("Contact sheet"). **Brief 2** = the logo, app icons and splash screens.
- **Step 1, discovery for both, one report**: do Part A1 and Part A2 together, as ONE report with one table per item, then a single "needs a decision from the owner" list. Then **stop and wait for approval**. Build nothing before that.
- **Step 2, after approval**: build Brief 1 (B1 to B5) first, then Brief 2 (B1 to B5). One commit per step, never mixing the two briefs in a commit.
- Brief 1 uses a plain-text "RAWWERS" in the pro header band. Brief 2's `RLogo` widget then replaces it in the same places (the swap is a Brief 2 commit).
- Where the briefs overlap (the design tokens, the widget gallery, the `paper` colour, the Meter colours), define it once in Brief 1 and reuse it in Brief 2.
- If one brief's report surfaces a blocker, finish the other brief's work if it is independent and say so.

## Process rules (as always, for both briefs)
Tests first, with break checks. Isolated DB per run (`make test-isolated`) for any backend suite you touch (you should not need to). Max 3 parallel suites. Full suite diffed by name against `docs/KNOWN_FAILURES.txt` (26 known). A clean worktree per commit, byte-identical branch check before pushing. A DEPLOY_CHECKLIST.md entry only if a commit needs one (this should be none), and a "how to see it" note per commit. No secrets in the repo or chat. Do not regenerate the API client unless a file you touch requires it. Keep commits small and single-purpose. Do not touch money, booking, availability, ranking, notification or API logic.

---

# BRIEF 1 — Pro app visual identity ("Contact sheet")

## Why
The pro app feels too white and does not look like the same product as the client app. The owner chose **direction C, "Contact sheet"**: a dark header band that carries the brand and the money (same dark as the client app), then a light working area underneath for reading outdoors in daylight. Unity comes from the top band and the shared tokens. Legibility comes from the body.

This is a visual change only. **No money, booking, API or database logic changes.**

## Decisions already made (do not reopen)
1. Pro app = dark header band + light body. Client app stays dark everywhere and is not redesigned here.
2. **One accent only**: Meter blue. No second accent colour. Developed green and Shade blue stay for status only, as today.
3. Two signature motifs, used sparingly:
   - **Viewfinder frame**: four corner brackets (16px arms, 2px stroke, accent colour) around the single most important number on a screen (the withdrawable amount, the booking price). One per screen at most.
   - **Exposure scale**: a thin tick-mark scale with a 4px fill and a 2px needle, replacing plain progress bars for tier progress, rating and gear credit. Needs an accessible label ("70 percent to Tier 3").
4. Shape: photos sharp (0), controls 4px, surfaces 8px, sheets 16px. No pills or stadium shapes (switches are rectangular). Depth by hairline borders, not shadows. 8px grid. 44px minimum touch target.
5. Type: Archivo. Hero money number 52px / weight 600 / tabular figures / letter-spacing -0.01em. Body 15. Labels and meta 13. Section labels 11px, weight 500, tracking 0.14em, uppercase.
6. Every value comes from the token files. **No hex literals, no hardcoded sizes or radii in screens.** Currency symbol and amounts come from the server data, never hardcoded.
7. Honest copy. Do not invent features, numbers or claims in empty or placeholder states.

## Colour spec (add as tokens where missing; reuse existing ones where they match)
| Role | Value | Notes |
|---|---|---|
| Header band background | RInk 950 `#0E0F11` | same as client app background |
| Header band text | RInk 050 `#FAFAFA`; meta `#9A9CA0` | |
| Header band hairline | `#2A2C30` | check against the existing dark border token and reuse it if close |
| Body background ("paper") | `#F2F2F0` | **new token** (warm grey). Replaces the pure white scaffold background in the pro theme |
| Card surface | `#FFFFFF` | |
| Card border | RInk 100 `#E4E4E3` | |
| Body text | RInk 950; secondary `#56585C` | |
| Accent on dark | Meter 500 `#4A7FA5` | corner brackets, needle, active indicators |
| Accent on light | Meter 700 `#2C4F66` | buttons, links, active tab indicator, scale fill |
| Primary button on light | fill Meter 700, label `#FAFAFA` | |
| Primary button **on the dark band** | fill Meter 500, label RInk 950 | **Do not use Meter 700 on the dark band**: it has almost no contrast against `#0E0F11`. The design mockup got this wrong; fix it as specified here |

Everything must pass WCAG AA: 4.5:1 for text under 18px, 3:1 for large text and for UI boundaries.

---

## PART A1 — Quick discovery (report only; then stop and wait for approval)

1. List every screen and widget in the **pro flavor** with hardcoded colours, radii, font sizes or spacing, or that bypass `theme_pro.dart`. Give file and count.
2. Which shared widgets in `app/lib/design/components` are used by both flavors? Which of my changes would also alter the client app? Propose how to scope them (a pro-only variant or a theme-driven parameter), so the client app is visually unchanged.
3. Current pro theme: where `RInk.i050` / `i100` are used as scaffold and card colours, and what depends on them.
4. Which pro screens exist today (You, Wallet, Requests, Shoots/bookings, Messages, Pricing, Portfolio, Availability, Findings, onboarding/training)? Give the route for each.
5. Contrast check of the current pro theme text/background pairs, with ratios.
6. Which screens would you do in which order, and the estimated commit count. Keep it to as few commits as possible without mixing concerns.

Report as one table per item, then "needs a decision from the owner". Then **stop**.

---

## PART B1 — Build (after approval). One commit per step

**B1. Tokens and primitives (no screen changes yet)**
- Add the `paper` colour token and any missing ones from the table. Pro theme: scaffold = paper, cards = white with hairline border.
- New components in `app/lib/design/components`, documented in the widget gallery with both light and dark-band variants:
  - `RHeaderBand` (dark band container for pro screens; handles status bar area and safe area)
  - `RViewfinderFrame` (corner brackets around a child; accent colour and arm length from tokens; decorative, hidden from screen readers; the child keeps its own semantics)
  - `RExposureScale` (value 0 to 1, semantic label, optional tick count; respects reduced motion if it animates, and defaults to no animation)
  - Any small helper for the section label style
- Tests: contrast test over the token pairs in the table (fails if any pair drops below its threshold), a no-hex test over pro screens (fails on any new `Color(0x…)` outside `design/`), widget tests for the three components, and a **break check** for each (break the rule, the test must fail).

**B2. You tab** (the reference screen, from the approved mockup)
- Dark `RHeaderBand` with: wordmark "RAWWERS" + muted "PRO" (plain text in Archivo for now; Brief 2 replaces it with the real logo widget), the date, a label "Available to withdraw", the amount inside the viewfinder frame (hero size), a one-line meta ("£x pending · £x on hold", from the same wallet source as the Wallet screen, never a second implementation), and the **Request payout** button (Meter 500 fill, dark label) only when payouts are possible, with the existing disabled/explanatory states untouched.
- Below, on paper: Available now row (existing switch behaviour untouched; the switch becomes rectangular, 4px radius), tier card with the exposure scale and the existing "how to reach the next tier" copy from the server, next shoot card, a "Needs you" list (new requests with the existing expiry, galleries due) with a 3px accent left border on the item that needs action first.
- Empty and error states use the existing `r_empty_state` / `r_error_state`, restyled. The Available-now card must still show a retry state on load error (do not regress that fix).

**B3. Wallet, Requests, Shoots, Messages, Pricing**
- Apply the band + paper pattern consistently: dark band for the screen's headline number or title, light body. Wallet keeps its card layout (Booked, Platform fees, Cash earned add up; RAW credit is a separate line, not in the sum). Do not touch any amount logic.
- Bottom tab bar: white, hairline top border, 12px labels, active label weight 600 with a 20×2px Meter 700 indicator under it. No filled pills.

**B4. Remaining pro screens + sweep**
- Portfolio, Findings, onboarding/training, Availability, settings, dialogs and sheets: move onto the tokens. Remove every hardcoded value found in Part A.
- Update the widget gallery with every new/changed component in both themes.

**B5. Verification**
- Golden or screenshot tests for the You and Wallet screens in the pro flavor (small and large text scale 1.3), if goldens already exist in the repo. If not, do not introduce a new framework; use widget tests plus simulator screenshots.
- Run the pro app on the simulator and give me screenshots of: You, Wallet, Requests, a Shoot detail, Messages, Pricing, an empty state, an error state. Note that the agent cannot tap in the simulator: use deep links, test routes or the widget gallery as before, and say which screens you could not reach.
- Client app: run its existing tests and confirm it is visually unchanged (list any shared component you touched).
- Accessibility: text scale 1.3 does not break the band or clip the hero amount (`FittedBox` or scale-down is allowed on the hero number only); screen reader order on the You screen reads: available amount, then payout action, then the rest.

---

# BRIEF 2 — Logo, app icons and splash screens

## Decisions already made (do not reopen)
1. **Primary logo**: the word RAWWERS in Archivo Bold (700), letter-spacing 0.16em, inside four viewfinder corner brackets (2px stroke at 32px cap-size scale, arm length about 14px at that scale, same proportions at any size). **No exposure bar in the logo**: the owner found it too much. The bar belongs to the app identity (the `RExposureScale` component), not to the logo. Two colourways: on dark (corners Meter 500 `#4A7FA5`, text `#FAFAFA`) and on light (corners Meter 700 `#2C4F66`, text `#0E0F11`). A one-colour version (single ink colour) for tiny sizes under 120px wide and for stamps, emails and print.
2. **App icon mark**: a bold Archivo "R" inside the four corner brackets, on RInk 950 `#0E0F11`, R in `#FAFAFA`, brackets in Meter 500 `#4A7FA5`.
   - **Client app icon**: the mark as above.
   - **Pro app icon**: the same R-in-corners mark, **inverted**: background paper `#F2F2F0`, R in `#0E0F11`, brackets in Meter 700 `#2C4F66`. No exposure bar. Same geometry as the client icon, so the two apps read as one brand and are told apart on a home screen by dark vs light.
3. No gradients, no shadows, no 3D, no photo content in any icon. No text in icons other than the R.
4. All text in logo files is **converted to outlines** (no live font dependency). Archivo is open licence, so this is fine.
5. One accent only. Nothing in the brand assets introduces a second colour.

---

## PART A2 — Discovery (report only; then stop and wait for approval)

1. Current state of icons and launch screens: Android (`mipmap`, adaptive icon, `launch_background`, flavor source sets), iOS (`AppIcon.appiconset`, `LaunchScreen.storyboard`, flavors/schemes), web (`favicon`, `manifest`) for the Next.js admin, and any logo usage inside the Flutter apps and the admin.
2. How icons are configured per flavor today (client vs pro), including the iOS bundle id situation (single `com.rawwers.rawwers` vs Android `com.rawwers.client` / `com.rawwers.pro`). Can the pro and client iOS apps have different icons today? If not, what is the minimum change (separate bundle ids, build configurations and schemes)? **Do not make that change in this task**; describe it and say whether the store-readiness work already covers it.
3. Which tool you propose for generating all icon sizes from one source (for example a pinned `flutter_launcher_icons` config per flavor, or a script in `tools/`). It must be reproducible: one command regenerates everything from the SVG sources.
4. Where the wordmark should appear in the apps (splash, login/onboarding, pro header band, client app bar if any, empty states) and in the admin (login, sidebar, favicon). Only places that already have a branded spot; do not invent new screens.
5. A list of every file you would add or change, grouped by commit. Then **stop**.

---

## PART B2 — Build (after approval). One commit per step

**B1. Source assets (vector, in the repo)**
- `design/brand/` (or the path you propose in Part A): SVG sources, with text outlined:
  - `logo-primary-on-dark.svg`, `logo-primary-on-light.svg`, `logo-mono-ink.svg`, `logo-mono-white.svg` (all without the bar)
  - `icon-client.svg`, `icon-pro.svg` (square master, 1024 viewBox, artwork inside the central safe zone)
  - `icon-foreground-client.svg`, `icon-foreground-pro.svg` (transparent, for Android adaptive: artwork inside the central 66% safe zone), and flat background layers (`#0E0F11` client, `#F2F2F0` pro)
  - `icon-monochrome.svg` (single colour on transparent, for the Android themed icon)
- A short `design/brand/README.md`: colours with token names, clear space (the height of the "R" on all sides), minimum sizes, what not to do (no recolouring, no stretching, no gradients, no putting the logo on busy photos without the dark band).
- Colours must come from the same values as the design tokens; add a test that the SVG fills only use the allowed hex set from the token file.

**B2. Generated icons per flavor**
- iOS: 1024×1024 PNG with **no alpha channel and no pre-rounded corners**, plus the sizes the asset catalogue needs. Client and pro icons separate if Part A shows it is possible without the bundle id change; if not, use the client icon for the single bundle id and leave the pro swap to the store-readiness task (say so in the report).
- Android: adaptive icon per flavor (foreground, background, monochrome) and legacy fallback PNGs. Flavor source sets so `client` and `pro` get their own icon.
- Web (admin): favicon set (SVG + 32 and 180 PNG) with the R mark; `manifest` icons if a manifest exists.
- One regenerate command, documented. Generated files are committed; the generator and its pinned version are documented.
- Tests: a script or test that checks every expected file exists, dimensions are exact, the iOS 1024 has no alpha, the Android foreground has artwork only inside the safe zone, the two flavors' icons are not byte-identical, and the pro icon background is the paper colour. Break check: remove or change one input and the test must fail.

**B3. Launch screens**
- Splash/launch screen on both platforms and both flavors: background `#0E0F11`, the primary logo on dark (client) and the same for pro, centred, no animation, no loading text. No flash of white on start: the launch background and the first Flutter frame background must match (check the iOS storyboard colour, Android `windowBackground`, and the Flutter theme).
- Dark mode and light mode behave the same (the splash is always dark).

**B4. In-app and admin logo usage**
- Add an `RLogo` widget in `app/lib/design/components` (variants: primary on dark, primary on light, mono; a size parameter that picks the one-colour version automatically under the minimum width). It renders from the SVG assets (add the SVG package only if one is not already a dependency; otherwise use the existing one). Semantics label: "RAWWERS".
- Use it only in the places Part A approved (splash handoff, login/onboarding, pro header band). Add it to the widget gallery.
- Admin: logo in the login page and the sidebar; favicon.
- Do not use the logo in places with busy photo backgrounds without the dark band.

**B5. Verification**
- Simulator or emulator screenshots: home screen icon (iOS and Android where you can), splash, login/onboarding for both flavors. Say which you could not reach (the agent cannot tap).
- Confirm the client app and pro app both still build and start; run the full suite diffed by name against `docs/KNOWN_FAILURES.txt`.

---

## Not in this task (both briefs)
No client app redesign. No iOS bundle id or scheme split (report only). No store listing artwork or screenshots (separate task). No email template build (Brevo work will reuse `logo-mono-ink.svg` and the on-light logo; just produce a 2x PNG export of the on-light logo in `design/brand/exports/`). No new features, screens or copy claims. No new fonts. No animation beyond what exists.

## Reporting
Step 1: the combined discovery report and stop. Step 2: per commit, what changed visually, files touched, test and break-check counts, full-suite diff by name, screenshots, anything in the client app that changed, anything that could not be verified, and "how to see it".
