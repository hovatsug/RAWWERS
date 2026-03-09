const ACCESS_TOKEN_KEY = "rawwers_admin_access_token";
const REFRESH_TOKEN_KEY = "rawwers_admin_refresh_token";

function hasWindow() {
  return typeof window !== "undefined";
}

export function getAccessToken() {
  if (!hasWindow()) return null;
  return window.localStorage.getItem(ACCESS_TOKEN_KEY);
}

export function getRefreshToken() {
  if (!hasWindow()) return null;
  return window.localStorage.getItem(REFRESH_TOKEN_KEY);
}

export function setAuthTokens(tokens: { access_token: string; refresh_token: string }) {
  if (!hasWindow()) return;
  window.localStorage.setItem(ACCESS_TOKEN_KEY, tokens.access_token);
  window.localStorage.setItem(REFRESH_TOKEN_KEY, tokens.refresh_token);
}

export function clearAuthTokens() {
  if (!hasWindow()) return;
  window.localStorage.removeItem(ACCESS_TOKEN_KEY);
  window.localStorage.removeItem(REFRESH_TOKEN_KEY);
}
