"""The client's IP address, the one way the API reads it.

`X-Forwarded-For` is whatever the caller says. It is read only when the
connection itself comes from a trusted proxy (`TRUSTED_PROXY_IPS`), and then
from the right: each trusted proxy appends the address it saw, so the entries
on the left are the caller's own and are never believed. Stepping back stops
at the first address that is not a trusted proxy, or after
`TRUSTED_PROXY_HOPS` proxies.

With no trusted proxies configured (dev, tests) the header is ignored and the
connection address is the answer. Uvicorn runs with --no-proxy-headers, so
that address is the socket's, not something Uvicorn rewrote.

Behind Cloudflare (TRUST_CLOUDFLARE=true) the walk above ends at the
Cloudflare edge that connected to Caddy. Only then - when that address is in
Cloudflare's published ranges (cloudflare_ips.txt, or CLOUDFLARE_IPS_FILE) -
is Cloudflare's own `CF-Connecting-IP` header believed. From anywhere else
the header is ignored, so a client that reaches the server directly cannot
name its own address and dodge a rate limit.

Everything that keys on an address goes through `client_ip`: the admin IP
allowlist, rate limits, download evidence, risk and abuse signals.
"""
from __future__ import annotations

import ipaddress
from functools import lru_cache
from pathlib import Path

from starlette.requests import Request

from app.core.config import get_settings

Network = ipaddress.IPv4Network | ipaddress.IPv6Network

#: The ranges shipped with the code; CLOUDFLARE_IPS_FILE points elsewhere.
DEFAULT_CLOUDFLARE_IPS_FILE = Path(__file__).with_name("cloudflare_ips.txt")


@lru_cache(maxsize=8)
def _networks(raw: str) -> tuple[Network, ...]:
    out: list[Network] = []
    for item in raw.split(","):
        item = item.strip()
        if item:
            out.append(ipaddress.ip_network(item, strict=False))
    return tuple(out)


@lru_cache(maxsize=4)
def _cloudflare_networks(path: str) -> tuple[Network, ...]:
    """One range per line; blank lines and # comments are skipped. A file
    that cannot be read, or a line that is not a range, raises: the startup
    guard reports it (core/production_guard.py)."""
    out: list[Network] = []
    for line in Path(path).read_text().splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            out.append(ipaddress.ip_network(line, strict=False))
    return tuple(out)


def cloudflare_networks() -> tuple[Network, ...]:
    return _cloudflare_networks(get_settings().cloudflare_ips_file or str(DEFAULT_CLOUDFLARE_IPS_FILE))


def is_cloudflare(address: str | None) -> bool:
    ip = parse_ip(address)
    if ip is None:
        return False
    addr = ipaddress.ip_address(ip)
    return any(addr in net for net in cloudflare_networks())


def parse_ip(value: str | None) -> str | None:
    """A bare address from a header entry or socket value, or None.

    Accepts "1.2.3.4", "1.2.3.4:5678", "2001:db8::1" and "[2001:db8::1]:443".
    """
    if not value:
        return None
    value = value.strip().strip('"')
    if value.startswith("["):
        value = value[1:].split("]", 1)[0]
    elif value.count(":") == 1:
        value = value.split(":", 1)[0]
    try:
        return str(ipaddress.ip_address(value))
    except ValueError:
        return None


def is_trusted_proxy(address: str | None) -> bool:
    ip = parse_ip(address)
    if ip is None:
        return False
    nets = _networks(get_settings().trusted_proxy_ips)
    addr = ipaddress.ip_address(ip)
    return any(addr in net for net in nets)


def client_ip(request: Request | None) -> str | None:
    """The address the request came from, believing only trusted proxies."""
    if request is None:
        return None
    peer_raw = request.client.host if request.client else None
    peer = parse_ip(peer_raw) or peer_raw
    candidate = peer
    chain: list[str] = []
    if is_trusted_proxy(peer):
        header = request.headers.get("x-forwarded-for") or ""
        chain = [entry for entry in (e.strip() for e in header.split(",")) if entry]
    hops = get_settings().trusted_proxy_hops
    while hops > 0 and chain and is_trusted_proxy(candidate):
        stepped = parse_ip(chain.pop())
        if stepped is None:
            # A malformed entry: nothing to its left can be trusted either.
            break
        candidate = stepped
        hops -= 1
    if get_settings().trust_cloudflare and is_cloudflare(candidate):
        real = parse_ip(request.headers.get("cf-connecting-ip"))
        if real is not None:
            return real
    return candidate
