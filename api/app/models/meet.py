"""'Meet the photographer': an interview a photographer writes, in their own words.

The questions are data an admin edits, each with the length an answer must
fall within. A photographer's answers are kept as a draft until they publish;
clients only ever read what was published. None of it is a ranking input,
and none of it sorts anything.
"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import CheckConstraint, DateTime, ForeignKey, Integer, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class InterviewQuestion(Base):
    __tablename__ = "interview_question"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    # Stable, for code and seeds; never shown.
    key: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    # What the photographer is asked, in the pro app.
    prompt: Mapped[str] = mapped_column(Text, nullable=False)
    # The heading a client reads above the answer.
    title: Mapped[str] = mapped_column(Text, nullable=False)
    hint: Mapped[str | None] = mapped_column(Text, nullable=True)
    min_chars: Mapped[int] = mapped_column(Integer, nullable=False)
    max_chars: Mapped[int] = mapped_column(Integer, nullable=False)
    position: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )
    updated_by_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)

    __table_args__ = (
        CheckConstraint("min_chars >= 0 AND max_chars > min_chars", name="ck_interview_question_lengths"),
    )


class ProInterviewAnswer(Base):
    __tablename__ = "pro_interview_answer"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    question_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("interview_question.id"), nullable=False)
    # What they are writing; only they see it.
    draft_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    # What clients read, as of the last time they published.
    published_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )
    published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    __table_args__ = (UniqueConstraint("pro_user_id", "question_id", name="uq_pro_interview_answer"),)
