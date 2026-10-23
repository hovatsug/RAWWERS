"""Spotting contact details in free text a photographer writes for clients.

A light filter that warns and never blocks: it looks for what someone would
use to take a client off RAWWERS - an email address, a phone number, a link
or a social handle - and says so, so the writer can take it out. False
positives are expected (a year, a lens's focal length) and cost nothing,
because nothing is refused.
"""
from __future__ import annotations

import re

_EMAIL = re.compile(r"[A-Za-z0-9_.+-]+@[A-Za-z0-9-]+\.[A-Za-z0-9.-]+")
# Seven or more digits, allowing the spaces, dots, dashes and brackets people
# write numbers with, optionally after a +.
_PHONE = re.compile(r"\+?\(?\d[\d\s().-]{5,}\d")
_LINK = re.compile(r"(https?://|www\.)\S+|\b[\w-]+\.(com|pt|net|org|io|me|co|uk|de|fr|es|br)(/\S*)?\b", re.IGNORECASE)
_MESSENGERS = re.compile(r"\b(wa\.me|whatsapp|telegram|t\.me|instagram|insta|facebook|tiktok|linkedin|signal)\b", re.IGNORECASE)
# @name, but not an email (handled above).
_HANDLE = re.compile(r"(?<![\w.])@[A-Za-z0-9_.]{2,}")

KINDS = ("email", "phone", "link", "handle")


def find_contact_details(text: str | None) -> list[str]:
    """The kinds of contact detail the text seems to contain, in a fixed order."""
    if not text:
        return []
    found = set()
    without_emails = _EMAIL.sub(" ", text)
    if without_emails != text:
        found.add("email")
    if any(sum(c.isdigit() for c in m.group()) >= 7 for m in _PHONE.finditer(without_emails)):
        found.add("phone")
    if _LINK.search(without_emails) or _MESSENGERS.search(without_emails):
        found.add("link")
    if _HANDLE.search(without_emails):
        found.add("handle")
    return [k for k in KINDS if k in found]


WARNING = (
    "This looks like contact details ({kinds}). Keep conversations on RAWWERS, where payments are secure "
    "and there's a way to resolve problems."
)
_WORDS = {"email": "an email address", "phone": "a phone number", "link": "a link or messaging app", "handle": "a social handle"}


def warning_for(kinds: list[str]) -> str | None:
    if not kinds:
        return None
    words = [_WORDS[k] for k in kinds]
    joined = words[0] if len(words) == 1 else ", ".join(words[:-1]) + " or " + words[-1]
    return WARNING.format(kinds=joined)
