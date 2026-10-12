"""When each side last read a conversation.

Unread counts for the photographer's Messages tab and badge, and for the
client's message list. One timestamp per side on the thread: everything the
other side sent after it is unread. NULL means never read, so every message
from the other side counts - which is what a conversation nobody has opened
is.

Revision ID: 20261012_0057
Revises: 20261007_0056
"""
from alembic import op
import sqlalchemy as sa

revision = "20261012_0057"
down_revision = "20261007_0056"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("chat_thread", sa.Column("pro_last_read_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("chat_thread", sa.Column("client_last_read_at", sa.DateTime(timezone=True), nullable=True))


def downgrade() -> None:
    op.drop_column("chat_thread", "client_last_read_at")
    op.drop_column("chat_thread", "pro_last_read_at")
