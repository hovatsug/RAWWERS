"""'Meet the photographer': the photographer's interview, and the admin's questions."""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.schemas.media import CurrentUser
from app.schemas.meet import InterviewDraftIn, InterviewQuestionIn, InterviewQuestionView, MyInterviewView
from app.services import meet
from app.services.authz import get_user_roles

router = APIRouter(tags=["meet"])


def _pro(db: Session, user: CurrentUser) -> uuid.UUID:
    if UserRoleType.pro not in get_user_roles(db, user.user_id):
        raise APIError(code="forbidden", message="Only photographers have an interview", status_code=403)
    return user.user_id


@router.get("/pro/me/interview", response_model=MyInterviewView)
def my_interview(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> MyInterviewView:
    view = meet.my_interview(db, _pro(db, user))
    db.commit()
    return view


@router.put("/pro/me/interview", response_model=MyInterviewView)
def save_interview(body: InterviewDraftIn, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)):
    return meet.save_draft(db, _pro(db, user), body.answers)


@router.post("/pro/me/interview/publish", response_model=MyInterviewView)
def publish_interview(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)):
    return meet.publish(db, _pro(db, user))


@router.post("/pro/me/interview/unpublish", response_model=MyInterviewView)
def unpublish_interview(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)):
    return meet.unpublish(db, _pro(db, user))


def _view(q) -> InterviewQuestionView:
    return InterviewQuestionView(id=q.id, key=q.key, prompt=q.prompt, title=q.title, hint=q.hint, min_chars=q.min_chars,
                                 max_chars=q.max_chars, position=q.position, is_active=q.is_active)


@router.get("/admin/interview-questions", response_model=list[InterviewQuestionView])
def list_questions(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)):
    questions = meet.all_questions(db)
    db.commit()
    return [_view(q) for q in questions]


@router.post("/admin/interview-questions", response_model=InterviewQuestionView)
def create_question(body: InterviewQuestionIn, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)):
    return _view(meet.create_question(db, admin_user_id=actor.user_id, fields=body.model_dump()))


@router.patch("/admin/interview-questions/{question_id}", response_model=InterviewQuestionView)
def update_question(question_id: uuid.UUID, body: InterviewQuestionIn, actor: CurrentUser = Depends(require_admin),
                    db: Session = Depends(get_db_session)):
    return _view(meet.update_question(db, question_id, admin_user_id=actor.user_id, changes=body.model_dump(exclude_unset=True)))
