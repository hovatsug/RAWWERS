"""'Meet the photographer': the interview, from the question to the profile.

A photographer writes answers as a draft, previews them and publishes; clients
only ever read what was published. Optional in every way: it never gates
onboarding, never feeds ranking and never sorts anything - nothing here is
read by the ranking or by any row's ordering, and a test holds that.

The video slot is behind PRESENTATION_VIDEO_ENABLED, off by default, and
nothing yet produces a video: the section is laid out for one so the video
can be added without redoing it.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.meet import InterviewQuestion, ProInterviewAnswer
from app.schemas.meet import (
    InterviewAnswerView,
    MeetInterviewItem,
    MeetThePhotographerView,
    MyInterviewView,
    PhotographerTeaser,
    TeaserKind,
)
from app.services.audit import add_admin_audit_log
from app.services.cache import bump_public_index_version
from app.services.contact_details import find_contact_details, warning_for

settings = get_settings()

#: The five parts of the intro-video guide (docs/briefs/rawwers-intro-video-guide.md),
#: as written questions. Written once, on first use; an admin edits them after.
DEFAULT_QUESTIONS = [
    ("who", "Who are you, what do you shoot, and where?", "Who I am",
     "Your first name, what you photograph and where. One or two sentences.", 20, 200),
    ("style", "Who do you work with, and how do your photos look and feel?", "My style",
     'One plain sentence about how your photos look. "No stiff poses" says more than "I capture memories".', 30, 300),
    ("experience", "What is it like to work with you, before, during and after the shoot?", "Working with me",
     'This is the part only you can say. Speak to one person: "you", not "clients".', 50, 500),
    ("detail", "Tell clients one true detail: your experience, your training, or why you started.", "One true detail",
     "If you're new, say so. Honesty works. Only things that are true.", 20, 300),
    ("invitation", "How would you invite someone to send you a request?", "An invitation",
     "Point them to your packages. Don't mention prices, dates or how fast you reply: they change, and your profile already shows them.",
     20, 200),
]


def _fail(message: str, status_code: int = 422, code: str = "validation_error") -> APIError:
    return APIError(code=code, message=message, status_code=status_code)


def ensure_default_questions(db: Session) -> None:
    if db.execute(select(InterviewQuestion.id).limit(1)).first() is not None:
        return
    for position, (key, prompt, title, hint, lo, hi) in enumerate(DEFAULT_QUESTIONS):
        db.add(InterviewQuestion(key=key, prompt=prompt, title=title, hint=hint, min_chars=lo, max_chars=hi, position=position))
    db.flush()


def all_questions(db: Session) -> list[InterviewQuestion]:
    ensure_default_questions(db)
    return list(db.execute(select(InterviewQuestion).order_by(InterviewQuestion.position, InterviewQuestion.key)).scalars())


def active_questions(db: Session) -> list[InterviewQuestion]:
    return [q for q in all_questions(db) if q.is_active]


def _answers(db: Session, pro_user_id: uuid.UUID) -> dict[uuid.UUID, ProInterviewAnswer]:
    rows = db.execute(select(ProInterviewAnswer).where(ProInterviewAnswer.pro_user_id == pro_user_id)).scalars()
    return {row.question_id: row for row in rows}


def _clean(text: str | None) -> str | None:
    return (text or "").strip() or None


# --- The photographer ----------------------------------------------------------------------


def my_interview(db: Session, pro_user_id: uuid.UUID) -> MyInterviewView:
    questions = active_questions(db)
    answers = _answers(db, pro_user_id)
    items = []
    for q in questions:
        a = answers.get(q.id)
        draft = a.draft_text if a else None
        items.append(
            InterviewAnswerView(
                question_id=q.id, prompt=q.prompt, title=q.title, hint=q.hint, min_chars=q.min_chars, max_chars=q.max_chars,
                draft=draft, published=a.published_text if a else None, warning=warning_for(find_contact_details(draft)),
            )
        )
    published_at = max((a.published_at for a in answers.values() if a.published_at), default=None)
    is_published = any(i.published for i in items)
    changed = any((i.draft or None) != (i.published or None) for i in items)
    return MyInterviewView(items=items, is_published=is_published, published_at=published_at, has_unpublished_changes=changed)


def save_draft(db: Session, pro_user_id: uuid.UUID, drafts: dict[uuid.UUID, str | None]) -> MyInterviewView:
    """Saves as they write. Only the longest an answer may be is checked here:
    a draft is allowed to be short until it is published."""
    questions = {q.id: q for q in active_questions(db)}
    answers = _answers(db, pro_user_id)
    for question_id, text in drafts.items():
        q = questions.get(question_id)
        if q is None:
            raise _fail("That question is no longer asked.", 404, "not_found")
        value = _clean(text)
        if value and len(value) > q.max_chars:
            raise _fail(f"“{q.title}” can be at most {q.max_chars} characters (this one is {len(value)}).")
        row = answers.get(question_id)
        if row is None:
            row = ProInterviewAnswer(pro_user_id=pro_user_id, question_id=question_id)
            db.add(row)
        row.draft_text = value
    db.commit()
    return my_interview(db, pro_user_id)


def publish(db: Session, pro_user_id: uuid.UUID) -> MyInterviewView:
    questions = active_questions(db)
    answers = _answers(db, pro_user_id)
    texts = {q.id: _clean(answers[q.id].draft_text) if q.id in answers else None for q in questions}
    if not any(texts.values()):
        raise _fail("Answer at least one question to publish.")
    for q in questions:
        text = texts[q.id]
        if text and len(text) < q.min_chars:
            raise _fail(f"“{q.title}” needs at least {q.min_chars} characters (it has {len(text)}).")
        if text and len(text) > q.max_chars:
            raise _fail(f"“{q.title}” can be at most {q.max_chars} characters (this one is {len(text)}).")
    now = datetime.now(timezone.utc)
    for q in questions:
        row = answers.get(q.id)
        if row is None:
            continue
        row.published_text = texts[q.id]
        row.published_at = now
    db.commit()
    # The profile and the Discover card's teaser are cached with the index.
    bump_public_index_version()
    return my_interview(db, pro_user_id)


def unpublish(db: Session, pro_user_id: uuid.UUID) -> MyInterviewView:
    for row in _answers(db, pro_user_id).values():
        row.published_text = None
        row.published_at = None
    db.commit()
    bump_public_index_version()
    return my_interview(db, pro_user_id)


# --- What clients read ---------------------------------------------------------------------


def _published(db: Session, pro_ids: list[uuid.UUID]) -> dict[uuid.UUID, list[tuple[InterviewQuestion, str]]]:
    if not pro_ids:
        return {}
    rows = db.execute(
        select(ProInterviewAnswer, InterviewQuestion)
        .join(InterviewQuestion, InterviewQuestion.id == ProInterviewAnswer.question_id)
        .where(
            ProInterviewAnswer.pro_user_id.in_(pro_ids),
            ProInterviewAnswer.published_text.is_not(None),
            InterviewQuestion.is_active.is_(True),
        )
        .order_by(InterviewQuestion.position, InterviewQuestion.key)
    ).all()
    out: dict[uuid.UUID, list[tuple[InterviewQuestion, str]]] = {}
    for answer, question in rows:
        out.setdefault(answer.pro_user_id, []).append((question, answer.published_text))
    return out


def meet_views(db: Session, pro_ids: list[uuid.UUID]) -> dict[uuid.UUID, MeetThePhotographerView]:
    """Only photographers with something to show: no entry means no section."""
    views = {}
    for pro_id, answers in _published(db, pro_ids).items():
        views[pro_id] = MeetThePhotographerView(
            video=None,  # The slot: nothing produces a video until it is built (PRESENTATION_VIDEO_ENABLED).
            interview=[MeetInterviewItem(question_id=q.id, title=q.title, answer=text) for q, text in answers],
        )
    return views


def _first_sentence(text: str, limit: int) -> str:
    sentence = text.strip().split("\n")[0]
    for stop in (". ", "! ", "? "):
        if stop in sentence:
            sentence = sentence.split(stop)[0] + stop.strip()
            break
    if len(sentence) <= limit:
        return sentence
    return sentence[: limit - 1].rsplit(" ", 1)[0].rstrip(",;:") + "…"


def teasers(db: Session, pro_ids: list[uuid.UUID]) -> dict[uuid.UUID, PhotographerTeaser]:
    """A Discover card's teaser: one line from the interview, where there is one.
    A video badge takes its place once videos exist and the flag is on."""
    out = {}
    for pro_id, answers in _published(db, pro_ids).items():
        _question, text = answers[0]
        out[pro_id] = PhotographerTeaser(kind=TeaserKind.interview, line=_first_sentence(text, settings.interview_teaser_max_chars))
    return out


# --- Admin ---------------------------------------------------------------------------------

_EDITABLE = ("prompt", "title", "hint", "min_chars", "max_chars", "position", "is_active")


def _check_question(fields: dict) -> None:
    for name in ("prompt", "title"):
        if not (fields.get(name) or "").strip():
            raise _fail(f"A question needs its {'wording' if name == 'prompt' else 'title for clients'}.")
    lo, hi = fields.get("min_chars"), fields.get("max_chars")
    if lo is None or hi is None or lo < 0 or hi <= lo:
        raise _fail("The longest answer must be longer than the shortest, and the shortest at least 0.")


def _record(q: InterviewQuestion) -> dict:
    return {name: getattr(q, name) for name in _EDITABLE}


def create_question(db: Session, *, admin_user_id: uuid.UUID, fields: dict) -> InterviewQuestion:
    ensure_default_questions(db)
    _check_question(fields)
    key = (fields.get("key") or "").strip() or f"q-{uuid.uuid4().hex[:8]}"
    if db.execute(select(InterviewQuestion).where(InterviewQuestion.key == key)).scalar_one_or_none():
        raise _fail("A question with that key already exists.", 409, "conflict")
    position = fields.get("position")
    if position is None:
        position = 1 + max((q.position for q in all_questions(db)), default=-1)
    q = InterviewQuestion(
        key=key, prompt=fields["prompt"].strip(), title=fields["title"].strip(), hint=_clean(fields.get("hint")),
        min_chars=fields["min_chars"], max_chars=fields["max_chars"], position=position,
        is_active=fields.get("is_active", True), updated_by_user_id=admin_user_id,
    )
    db.add(q)
    db.flush()
    add_admin_audit_log(db, actor_user_id=admin_user_id, target_type="interview_question", target_id=str(q.id),
                        action="interview_question_created", metadata={"to": _record(q)})
    db.commit()
    bump_public_index_version()
    return q


def update_question(db: Session, question_id: uuid.UUID, *, admin_user_id: uuid.UUID, changes: dict) -> InterviewQuestion:
    q = db.get(InterviewQuestion, question_id)
    if q is None:
        raise _fail("Question not found", 404, "not_found")
    before = _record(q)
    proposed = {**before, **{k: v for k, v in changes.items() if k in _EDITABLE}}
    _check_question(proposed)
    for name in _EDITABLE:
        value = proposed[name]
        setattr(q, name, value.strip() if isinstance(value, str) else value)
    q.hint = _clean(q.hint)
    q.updated_by_user_id = admin_user_id
    db.flush()
    after = _record(q)
    diff = {k: {"from": before[k], "to": after[k]} for k in _EDITABLE if before[k] != after[k]}
    if diff:
        add_admin_audit_log(db, actor_user_id=admin_user_id, target_type="interview_question", target_id=str(q.id),
                            action="interview_question_updated", metadata=diff)
    db.commit()
    # A title clients read may have changed.
    bump_public_index_version()
    return q
