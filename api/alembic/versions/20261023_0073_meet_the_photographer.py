"""Meet the photographer: interview questions (admin-edited) and photographers' answers.

interview_question holds the questions; the five defaults (from the five parts
of the intro-video guide, docs/briefs/rawwers-intro-video-guide.md) are
written on first use by services/meet.py, like the price-reduction reasons.
pro_interview_answer keeps each photographer's draft and what they last
published. Nothing existing changes; no photographer has answers.

Revision ID: 20261023_0073
Revises: 20261023_0072
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261023_0073"
down_revision = "20261023_0072"
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.create_table(
        "interview_question",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("key", sa.Text(), nullable=False, unique=True),
        sa.Column("prompt", sa.Text(), nullable=False),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("hint", sa.Text(), nullable=True),
        sa.Column("min_chars", sa.Integer(), nullable=False),
        sa.Column("max_chars", sa.Integer(), nullable=False),
        sa.Column("position", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.CheckConstraint("min_chars >= 0 AND max_chars > min_chars", name="ck_interview_question_lengths"),
    )
    op.create_table(
        "pro_interview_answer",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("question_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("interview_question.id"), nullable=False),
        sa.Column("draft_text", sa.Text(), nullable=True),
        sa.Column("published_text", sa.Text(), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("published_at", sa.DateTime(timezone=True), nullable=True),
        sa.UniqueConstraint("pro_user_id", "question_id", name="uq_pro_interview_answer"),
    )
    op.create_index("ix_pro_interview_answer_pro_user_id", "pro_interview_answer", ["pro_user_id"])


def downgrade() -> None:
    op.drop_index("ix_pro_interview_answer_pro_user_id", table_name="pro_interview_answer")
    op.drop_table("pro_interview_answer")
    op.drop_table("interview_question")
