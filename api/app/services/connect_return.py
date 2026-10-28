"""The two pages Stripe returns a photographer to after hosted Connect
onboarding.

Stripe refuses a custom-scheme return_url ("Not a valid URL", seen on real
Stripe in test mode), so it returns here, over http(s), and these pages
hand over to the pro app through its own scheme. They are a hint, never
the truth: back in the app, it asks the server for the account's status.

Static on purpose. Built once from constants, they never read the request:
no query parameter is parsed, stored or repeated, so nothing Stripe or
anyone else puts in the address can end up on the page. No script, no user
data, nothing loaded from elsewhere.
"""
from __future__ import annotations

from html import escape

#: The pro app's URL scheme (registered by the pro flavor only).
PRO_APP_SCHEME = "rawwerspro"

#: Headers on both pages: never cached, never sending this address on, no
#: guessing the content type, and nothing allowed to load or run.
PAGE_HEADERS = {
    "Cache-Control": "no-store",
    "Referrer-Policy": "no-referrer",
    "X-Content-Type-Options": "nosniff",
    "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
}


def _page(*, title: str, body: str, app_url: str) -> str:
    title, body, app_url = escape(title), escape(body), escape(app_url, quote=True)
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="refresh" content="0;url={app_url}">
<title>{title}</title>
<style>
  body {{ margin: 0; min-height: 100vh; display: flex; align-items: center; justify-content: center;
         background: #0E0F11; color: #FAFAFA; font: 17px/1.4 -apple-system, system-ui, sans-serif; }}
  main {{ max-width: 22rem; padding: 1.5rem; text-align: center; }}
  h1 {{ font-size: 1.25rem; margin: 0 0 .5rem; }}
  p {{ margin: 0 0 1.5rem; color: #C9CACC; }}
  a {{ display: inline-block; padding: .75rem 1.25rem; border-radius: 4px; background: #4A7FA5;
      color: #0E0F11; font-weight: 600; text-decoration: none; }}
</style>
</head>
<body>
<main>
<h1>{title}</h1>
<p>{body}</p>
<a href="{app_url}">Back to RAWWERS Pro</a>
</main>
</body>
</html>
"""


RETURN_PAGE = _page(
    title="You can go back to the app",
    body="RAWWERS Pro will check with Stripe where your payout setup stands.",
    app_url=f"{PRO_APP_SCHEME}://payouts/return",
)

REFRESH_PAGE = _page(
    title="This setup link expired",
    body="Go back to RAWWERS Pro and tap Continue setup to get a fresh one.",
    app_url=f"{PRO_APP_SCHEME}://payouts/refresh",
)
