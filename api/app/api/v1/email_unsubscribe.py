"""Unsubscribe from email, from a signed link, without signing in
(services/unsubscribe.py). GET only checks the link, for the page; POST,
from the page's button or a mail client's one-click unsubscribe, makes the
change."""
from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.api.deps import get_db_session
from app.services import unsubscribe

router = APIRouter(prefix="/email", tags=["email"])


class UnsubscribeAllLink(BaseModel):
    k: str
    s: str


class UnsubscribeLinkView(BaseModel):
    topic: str
    topic_label: str
    #: A signed link for "every email except security", offered on the page.
    all: UnsubscribeAllLink


class UnsubscribedView(BaseModel):
    topic: str
    unsubscribed: bool


@router.get("/unsubscribe", response_model=UnsubscribeLinkView)
def check_unsubscribe_link(
    u: str = Query(...),
    t: str = Query(..., max_length=64),
    k: str = Query(..., max_length=64),
    s: str = Query(..., max_length=128),
) -> UnsubscribeLinkView:
    """What the link would stop. Changes nothing: mail scanners open links."""
    user, topic = unsubscribe.checked(u, t, k, s)
    kid, sig = unsubscribe.sign(user, unsubscribe.ALL)
    return UnsubscribeLinkView(
        topic=topic, topic_label=unsubscribe.TOPIC_LABELS.get(topic, topic), all=UnsubscribeAllLink(k=kid, s=sig)
    )


@router.post("/unsubscribe", response_model=UnsubscribedView)
def unsubscribe_from_link(
    u: str = Query(...),
    t: str = Query(..., max_length=64),
    k: str = Query(..., max_length=64),
    s: str = Query(..., max_length=128),
    db: Session = Depends(get_db_session),
) -> UnsubscribedView:
    """Stop that email. The link's parameters are in the query, so a mail
    client's one-click POST (body "List-Unsubscribe=One-Click") works as it is."""
    user, topic = unsubscribe.checked(u, t, k, s)
    unsubscribe.apply(db, user, topic)
    db.commit()
    return UnsubscribedView(topic=topic, unsubscribed=True)
