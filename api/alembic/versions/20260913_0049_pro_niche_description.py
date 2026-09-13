"""What a photographer says about one particular kind of work.

The public profile can now split a portfolio by niche, which raises a
question the data could not answer: a wedding photographer who also shoots
corporate headshots has one bio covering both, and it reads as written for
whichever tab you are not looking at.

Nullable, with no default. Most photographers will never write one, and the
profile falls back to the general bio rather than rendering an empty section
under a tab - so "not written" has to stay distinguishable from "written and
empty" only in the sense that both fall back. Adding a NOT NULL default would
have made every existing row claim a description it does not have.

Adding a nullable column with no default is metadata-only in Postgres: no
table rewrite and no lock beyond a brief ACCESS EXCLUSIVE.

Revision ID: 20260913_0049
Revises: 20260905_0048
"""
from alembic import op
import sqlalchemy as sa

revision = "20260913_0049"
down_revision = "20260905_0048"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("pro_niche", sa.Column("description", sa.Text(), nullable=True))


def downgrade() -> None:
    op.drop_column("pro_niche", "description")
